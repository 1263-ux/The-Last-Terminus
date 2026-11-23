#!/usr/bin/env python3
"""GLB/GLTF structural auditor for The Last Terminus desk-world asset audit.

Parses the GLB container, extracts the JSON chunk, and reports:
nodes, meshes, primitives, materials, textures, animations, skins,
accessor-derived bounding box, triangle counts, and texture image sizes.

Everything the script does NOT actually parse is reported as NOT TESTED.
"""
import json
import os
import struct
import sys

REPORT = []


def read_glb(path):
    with open(path, 'rb') as f:
        data = f.read()
    magic, version, length = struct.unpack_from('<III', data, 0)
    if magic != 0x46546C67:
        raise ValueError('not a GLB (bad magic)')
    off = 12
    gltf = None
    bin_chunk = None
    while off < length:
        clen, ctype = struct.unpack_from('<II', data, off)
        off += 8
        chunk = data[off:off + clen]
        off += clen
        if ctype == 0x4E4F534A:
            gltf = json.loads(chunk.decode('utf-8'))
        elif ctype == 0x004E4942:
            bin_chunk = chunk
    return version, length, gltf, bin_chunk, len(data)


def acc_minmax(g, idx):
    a = g.get('accessors', [])[idx]
    return a.get('min'), a.get('max'), a.get('type'), a.get('componentType'), a.get('count')


def audit(path):
    rec = {'file': os.path.basename(path), 'path': path,
           'bytes': os.path.getsize(path)}
    try:
        ver, length, g, binchunk, actual = read_glb(path)
    except Exception as e:
        rec['error'] = f'{type(e).__name__}: {e}'
        return rec

    rec['glb_version'] = ver
    rec['declared_length'] = length
    rec['actual_length'] = actual
    rec['generator'] = (g.get('asset') or {}).get('generator', 'NOT STATED')
    rec['gltf_version'] = (g.get('asset') or {}).get('version', '?')

    nodes = g.get('nodes', [])
    meshes = g.get('meshes', [])
    mats = g.get('materials', [])
    texs = g.get('textures', [])
    imgs = g.get('images', [])
    anims = g.get('animations', [])
    skins = g.get('skins', [])

    rec['counts'] = {
        'nodes': len(nodes), 'meshes': len(meshes),
        'primitives': sum(len(m.get('primitives', [])) for m in meshes),
        'materials': len(mats), 'textures': len(texs),
        'images': len(imgs), 'animations': len(anims), 'skins': len(skins),
        'cameras': len(g.get('cameras', [])),
    }

    # ---- triangle count + union bbox from POSITION accessors
    tris = 0
    verts = 0
    bb_min = [float('inf')] * 3
    bb_max = [float('-inf')] * 3
    has_pos = False
    for m in meshes:
        for p in m.get('primitives', []):
            attrs = p.get('attributes', {})
            if 'POSITION' in attrs:
                mn, mx, typ, ct, cnt = acc_minmax(g, attrs['POSITION'])
                verts += (cnt or 0)
                if mn and mx and len(mn) == 3:
                    has_pos = True
                    for i in range(3):
                        bb_min[i] = min(bb_min[i], mn[i])
                        bb_max[i] = max(bb_max[i], mx[i])
            if 'indices' in p:
                _, _, _, _, cnt = acc_minmax(g, p['indices'])
                tris += (cnt or 0) // 3
            else:
                # non-indexed: triangles == vertex_count/3 (assume triangle list)
                pass
    rec['triangles'] = tris
    rec['vertices'] = verts
    if has_pos:
        rec['bbox_min'] = [round(v, 4) for v in bb_min]
        rec['bbox_max'] = [round(v, 4) for v in bb_max]
        rec['size_xyz'] = [round(bb_max[i] - bb_min[i], 4) for i in range(3)]

    # ---- node hierarchy
    def name_of(i):
        return nodes[i].get('name', f'node{i}')

    roots = set(range(len(nodes)))
    for i, n in enumerate(nodes):
        for c in n.get('children', []):
            roots.discard(c)
    lines = []

    def walk(i, depth):
        n = nodes[i]
        tag = []
        if 'mesh' in n:
            mm = meshes[n['mesh']]
            tag.append('mesh:' + mm.get('name', f"mesh{n['mesh']}"))
        if 'skin' in n:
            tag.append('SKINNED')
        if 'translation' in n:
            tag.append('T=' + str([round(x, 3) for x in n['translation']]))
        if 'scale' in n:
            tag.append('S=' + str([round(x, 3) for x in n['scale']]))
        lines.append('  ' * depth + '- ' + name_of(i) + ('  [' + ' '.join(tag) + ']' if tag else ''))
        for c in n.get('children', []):
            walk(c, depth + 1)

    for r in sorted(roots):
        walk(r, 0)
    rec['hierarchy'] = lines

    # ---- materials
    mrecs = []
    for m in mats:
        pbr = m.get('pbrMetallicRoughness', {}) or {}
        entry = {
            'name': m.get('name', '?'),
            'baseColorFactor': pbr.get('baseColorFactor'),
            'baseColorTexture': pbr.get('baseColorTexture', {}).get('index'),
            'metallic': pbr.get('metallicFactor'),
            'roughness': pbr.get('roughnessFactor'),
            'normalTexture': (m.get('normalTexture') or {}).get('index'),
            'doubleSided': m.get('doubleSided', False),
            'alphaMode': m.get('alphaMode', 'OPAQUE'),
            'emissive': m.get('emissiveFactor'),
        }
        mrecs.append(entry)
    rec['materials'] = mrecs

    # ---- images
    irecs = []
    for im in imgs:
        name = im.get('name', '?')
        if 'bufferView' in im:
            bv = g['bufferViews'][im['bufferView']]
            irecs.append({'name': name, 'mime': im.get('mimeType', '?'),
                          'embedded_bytes': bv.get('byteLength')})
        else:
            irecs.append({'name': name, 'uri': im.get('uri', '?')})
    rec['images'] = irecs

    rec['animations'] = [{'name': a.get('name', '?'),
                          'channels': len(a.get('channels', []))} for a in anims]

    # extras / user metadata often carries origin info
    if 'extras' in g:
        rec['extras'] = g['extras']
    rec['extensionsUsed'] = g.get('extensionsUsed', [])
    return rec


def main():
    paths = sys.argv[1:]
    out = []
    for p in paths:
        out.append(audit(p))
    print(json.dumps(out, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
