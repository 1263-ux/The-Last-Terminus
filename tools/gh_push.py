#!/usr/bin/env python3
"""Push a set of files to a GitHub branch using the Git Data API.

Why this exists: on this machine `git` cannot reach github.com:443 (TLS reset
by the network), while api.github.com works. The Git Data API gives an
equivalent, verifiable push: blobs -> tree -> commit -> ref update.

Usage:
  python gh_push.py --repo owner/name --branch BRANCH --base SHA \
                    --message "commit message" FILES...
"""
import argparse
import base64
import json
import os
import subprocess
import sys


def gh(*args, input_json=None):
    cmd = ['gh'] + list(args)
    # gh needs an explicit --input - to read a JSON body from stdin; without it
    # the body is ignored and the API rejects the request (HTTP 422).
    if input_json is not None:
        cmd += ['--input', '-']
        p = subprocess.run(cmd, capture_output=True, text=True, encoding='utf-8',
                           input=json.dumps(input_json))
    else:
        p = subprocess.run(cmd, capture_output=True, text=True, encoding='utf-8')
    if p.returncode != 0:
        raise RuntimeError(f'gh {" ".join(args)} failed: {p.stderr.strip()}')
    return p.stdout


def gh_json(*args, input_json=None):
    out = gh(*args, input_json=input_json)
    return json.loads(out) if out.strip() else {}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', required=True)
    ap.add_argument('--branch', required=True)
    ap.add_argument('--base', default=None,
                    help='base commit sha; default = current branch head')
    ap.add_argument('--message', required=True)
    ap.add_argument('--repo-root', required=True,
                    help='local directory that maps to the repository root')
    ap.add_argument('--delete', nargs='*', default=[],
                    help='repo-relative paths to delete in this commit')
    ap.add_argument('files', nargs='*',
                    help='repo-relative paths to add/update')
    a = ap.parse_args()

    root = os.path.abspath(a.repo_root)

    # 1. base commit
    if a.base:
        base = a.base
    else:
        ref = gh_json('api', f'repos/{a.repo}/git/ref/heads/{a.branch}')
        base = ref['object']['sha']
    print(f'base commit: {base}')

    base_commit = gh_json('api', f'repos/{a.repo}/git/commits/{base}')
    base_tree = base_commit['tree']['sha']
    print(f'base tree  : {base_tree}')

    # 2. blobs
    tree_entries = []
    for rel in a.files:
        local = os.path.join(root, rel.replace('/', os.sep))
        if not os.path.isfile(local):
            print(f'  !! MISSING, skipped: {rel}')
            continue
        with open(local, 'rb') as fh:
            raw = fh.read()
        b64 = base64.b64encode(raw).decode('ascii')
        blob = gh_json('api', '-X', 'POST', f'repos/{a.repo}/git/blobs',
                       input_json={'content': b64, 'encoding': 'base64'})
        tree_entries.append({
            'path': rel.replace('\\', '/'),
            'mode': '100644',
            'type': 'blob',
            'sha': blob['sha'],
        })
        print(f'  blob {blob["sha"][:10]}  {rel}  ({len(raw)} bytes)')

    for rel in a.delete:
        tree_entries.append({
            'path': rel.replace('\\', '/'),
            'mode': '100644',
            'type': 'blob',
            'sha': None,
        })
        print(f'  delete {rel}')

    if not tree_entries:
        print('nothing to push')
        return 1

    # 3. tree
    tree = gh_json('api', '-X', 'POST', f'repos/{a.repo}/git/trees',
                   input_json={'base_tree': base_tree, 'tree': tree_entries})
    print(f'new tree   : {tree["sha"]}')

    # 4. commit
    commit = gh_json('api', '-X', 'POST', f'repos/{a.repo}/git/commits',
                     input_json={
                         'message': a.message,
                         'tree': tree['sha'],
                         'parents': [base],
                     })
    print(f'new commit : {commit["sha"]}')

    # 5. move the branch ref (fast-forward semantics; never touches main)
    updated = gh_json('api', '-X', 'PATCH',
                      f'repos/{a.repo}/git/refs/heads/{a.branch}',
                      input_json={'sha': commit['sha'], 'force': False})
    print(f'ref updated: {updated["ref"]} -> {updated["object"]["sha"]}')
    print(f'\nOK  https://github.com/{a.repo}/tree/{a.branch}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
