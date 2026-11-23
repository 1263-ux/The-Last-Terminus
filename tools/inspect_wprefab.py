#!/usr/bin/env python3
""".wprefab inspector for The Last Terminus asset audit.

A .wprefab file is a ZIP container, NOT a Unity bundle and NOT a full project.
Observed layout:
    SerializePcgData.json     scene/prefab data, structurally identical to a
                              project's scene.data payload
    asset-metadata.json       optional: schemaVersion / capacity / faceCount /
                              logicalCenter / rigged
    preview.png               optional render
    textures/*.png            optional referenced textures

Prints node count, named nodes, runtime script count, resource refs, the
player-movement fields, and metadata. Anything not present is reported as
NOT TESTED rather than assumed.
"""
import glob
import json
import os
import sys
import zipfile


def inspect(path):
    rec = {'file': os.path.basename(path), 'bytes': os.path.getsize(path)}
    try:
        zf = zipfile.ZipFile(path)
    except Exception as e:
        rec['error'] = f'not a zip: {e}'
        return rec

    names = zf.namelist()
    rec['members'] = names
    rec['has_preview'] = any(n.endswith('preview.png') for n in names)
    rec['textures'] = [n for n in names if n.lower().endswith(('.png', '.tga', '.jpg'))]

    meta_name = next((n for n in names if n.endswith('asset-metadata.json')), None)
    if meta_name:
        try:
            rec['metadata'] = json.loads(zf.read(meta_name).decode('utf-8-sig'))
        except Exception as e:
            rec['metadata'] = f'parse fail: {e}'
    else:
        rec['metadata'] = 'NOT TESTED (no asset-metadata.json)'

    data_name = next((n for n in names if n.endswith('SerializePcgData.json')), None)
    if not data_name:
        rec['error'] = 'no SerializePcgData.json'
        return rec

    try:
        g = json.loads(zf.read(data_name).decode('utf-8-sig'))
    except Exception as e:
        rec['error'] = f'json parse fail: {e}'
        return rec

    rec['top_keys'] = sorted(g.keys())

    nodes = g.get('nodeTransformDatas') or []
    rec['node_count'] = len(nodes)
    node_names = []
    for n in nodes:
        nm = (n.get('basic') or {}).get('nodeName')
        if nm:
            node_names.append(nm)
    rec['node_names'] = node_names
    rec['nodes_with_effects'] = sum(1 for n in nodes if 'effects' in n)
    rec['nodes_with_physics'] = sum(1 for n in nodes if 'physics' in n)

    rs = g.get('runtimeScripts') or []
    if isinstance(rs, dict):
        rs = list(rs.values())
    rec['runtime_script_count'] = len(rs)

    # player movement fields: these are the ones that make .wprefab more than a mesh
    for k in ('moveMaxSpeed', 'jumpMaxHeight', 'respawnHeightY', 'envType',
              'isOpenStreamingLoad'):
        rec[k] = g.get(k, 'NOT PRESENT')

    rr = g.get('resourceRefs') or []
    rec['resource_refs'] = [r.get('pathOrUrl') for r in rr]
    rec['spawn_point_data'] = g.get('spawnPointData')
    rec['audioData'] = 'present' if g.get('audioData') else None
    return rec


def main():
    targets = []
    for a in sys.argv[1:]:
        if os.path.isdir(a):
            targets += sorted(glob.glob(os.path.join(a, '*.wprefab')))
        else:
            targets.append(a)
    out = [inspect(t) for t in targets]
    print(json.dumps(out, ensure_ascii=False, indent=2, default=str))


if __name__ == '__main__':
    main()
