#!/usr/bin/env python3
"""Generate Day-1 scale white-box GLBs for the Desk World.

Purpose: verify the MICRO-SCALE READ in the real editor, not to produce art.
Every mesh is a plain box/prism with flat vertex colours so that silhouette and
relative size are the only things being tested.

Scale basis [PROPOSED, measured in-engine]:
  - editor player character is a ~1.7 m tall humanoid (default avatar)
  - authored scene uses moveMaxSpeed=4.0, jumpMaxHeight=1.0
  - therefore "micro" is achieved by making DESK OBJECTS GIANT, not the player small.
    A real 30 cm ruler becomes a 30 m span == ~17x player height.
"""
import json
import os
import struct

import numpy as np

OUT = r'D:\competition\whitebox'


def box(w, h, d, color, origin=(0, 0, 0)):
    """Axis-aligned box centred in X/Z, sitting on y=0. Returns (verts, faces, colors)."""
    cx, cy, cz = origin
    x0, x1 = -w / 2 + cx, w / 2 + cx
    y0, y1 = 0 + cy, h + cy
    z0, z1 = -d / 2 + cz, d / 2 + cz
    v = np.array([
        [x0, y0, z0], [x1, y0, z0], [x1, y0, z1], [x0, y0, z1],
        [x0, y1, z0], [x1, y1, z0], [x1, y1, z1], [x0, y1, z1],
    ], dtype=np.float32)
    f = np.array([
        [0, 1, 2], [0, 2, 3],     # bottom
        [4, 5, 6], [4, 6, 7],     # top
        [0, 1, 5], [0, 5, 4],     # -z
        [1, 2, 6], [1, 6, 5],     # +x
        [2, 3, 7], [2, 7, 6],     # +z
        [3, 0, 4], [3, 4, 7],     # -x
    ], dtype=np.uint32)
    c = np.tile(np.array(color, dtype=np.float32), (len(v), 1))
    return v, f, c


def merge(parts):
    vs, fs, cs = [], [], []
    off = 0
    for v, f, c in parts:
        vs.append(v)
        fs.append(f + off)
        cs.append(c)
        off += len(v)
    return np.vstack(vs), np.vstack(fs), np.vstack(cs)


def write_glb(path, verts, faces, colors, name):
    """Write a minimal GLB: POSITION + COLOR_0 + indices, one node one mesh."""
    verts = np.asarray(verts, dtype=np.float32)
    faces = np.asarray(faces, dtype=np.uint32)
    colors = np.asarray(colors, dtype=np.float32)

    pos_bytes = verts.tobytes()
    col_bytes = colors.tobytes()
    idx_bytes = faces.tobytes()

    def pad4(b, fill=b'\x00'):
        return b + fill * ((4 - len(b) % 4) % 4)

    pos_bytes = pad4(pos_bytes)
    col_bytes = pad4(col_bytes)
    idx_bytes = pad4(idx_bytes, b'\x00')

    bin_blob = pos_bytes + col_bytes + idx_bytes
    glb_len = 12 + 8 + len(json.dumps({}).encode())  # placeholder
    mn = verts.min(axis=0).tolist()
    mx = verts.max(axis=0).tolist()

    gltf = {
        'asset': {'version': '2.0', 'generator': 'TLT whitebox generator'},
        'scene': 0,
        'scenes': [{'nodes': [0]}],
        'nodes': [{'name': name, 'mesh': 0}],
        'meshes': [{
            'name': name + '_mesh',
            'primitives': [{
                'attributes': {'POSITION': 0, 'COLOR_0': 1},
                'indices': 2,
                'material': 0,
            }],
        }],
        'materials': [{
            'name': name + '_mat',
            'pbrMetallicRoughness': {
                'baseColorFactor': [1, 1, 1, 1],
                'metallicFactor': 0.0,
                'roughnessFactor': 0.85,
            },
            'doubleSided': True,
        }],
        'accessors': [
            {'bufferView': 0, 'componentType': 5126, 'count': len(verts),
             'type': 'VEC3', 'min': mn, 'max': mx},
            {'bufferView': 1, 'componentType': 5126, 'count': len(colors),
             'type': 'VEC3'},
            {'bufferView': 2, 'componentType': 5125, 'count': faces.size,
             'type': 'SCALAR'},
        ],
        'bufferViews': [
            {'buffer': 0, 'byteOffset': 0, 'byteLength': len(pos_bytes)},
            {'buffer': 0, 'byteOffset': len(pos_bytes), 'byteLength': len(col_bytes)},
            {'buffer': 0, 'byteOffset': len(pos_bytes) + len(col_bytes),
             'byteLength': len(idx_bytes)},
        ],
        'buffers': [{'byteLength': len(bin_blob)}],
    }

    js = json.dumps(gltf, separators=(',', ':')).encode('utf-8')
    js = js + b' ' * ((4 - len(js) % 4) % 4)

    total = 12 + 8 + len(js) + 8 + len(bin_blob)
    with open(path, 'wb') as fh:
        fh.write(struct.pack('<III', 0x46546C67, 2, total))
        fh.write(struct.pack('<II', len(js), 0x4E4F534A))
        fh.write(js)
        fh.write(struct.pack('<II', len(bin_blob), 0x004E4942))
        fh.write(bin_blob)


# ----------------------------------------------------------------- assets
# Colours are deliberately flat and materially distinct so the scale whitbox
# also tests whether material identity (paper / wood / metal / rubber) reads.
PAPER   = (0.92, 0.90, 0.84)
PAPER_D = (0.78, 0.74, 0.66)
WOOD    = (0.62, 0.42, 0.24)
WOOD_L  = (0.78, 0.62, 0.40)
RUBBER  = (0.85, 0.55, 0.55)
METAL   = (0.62, 0.64, 0.68)
TIN     = (0.55, 0.60, 0.62)


def make_desk():
    """Two desk-surface slabs separated by a 10 m chasm.

    The chasm is what makes the ruler bridge *necessary* rather than decorative:
    the player cannot walk around it (it spans the full Z depth of both slabs).
    Split along X: west slab + gap + east slab.
    """
    gap = 10.0
    total_x = 40.0
    depth = 30.0
    side = (total_x - gap) / 2          # 15 m each
    thick = 0.6
    west = box(side, thick, depth, WOOD, origin=(-(gap / 2 + side / 2), 0, 0))
    east = box(side, thick, depth, WOOD, origin=(gap / 2 + side / 2, 0, 0))
    return merge([west, east])


def make_book(w, h, d, cover, pages=0.82, name='book'):
    """A closed book: cover slab + page block + slightly smaller cover."""
    parts = []
    # bottom cover
    parts.append(box(w, h * 0.06, d, cover, origin=(0, 0, 0)))
    # page block, inset
    parts.append(box(w * 0.96, h * pages, d * 0.94, PAPER, origin=(w * 0.005, h * 0.06, 0)))
    # top cover
    parts.append(box(w, h * 0.06, d, cover, origin=(0, h * (0.06 + pages), 0)))
    # spine hint
    parts.append(box(w * 0.06, h, d, PAPER_D, origin=(-w / 2 + w * 0.03, 0, 0)))
    return merge(parts)


def make_ruler(length, width, thick):
    """A wooden ruler: body + a raised bevelled edge + tick marks as thin bars."""
    parts = [box(length, thick, width, WOOD_L)]
    # raised edge rail (reads as the bevelled rim of a real ruler)
    parts.append(box(length, thick * 0.25, width * 0.06, WOOD,
                     origin=(0, thick, -width / 2 + width * 0.08)))
    # tick marks: every 1/10 of length, long ticks every 5th
    n = 10
    for i in range(1, n):
        x = -length / 2 + length * i / n
        long = (i % 5 == 0)
        w = width * (0.34 if long else 0.18)
        parts.append(box(length * 0.006, thick * 0.12, w, (0.25, 0.18, 0.10),
                         origin=(x, thick, width / 2 - w / 2 - width * 0.06)))
    return merge(parts)


def make_eraser(w, h, d):
    parts = [box(w, h, d, RUBBER)]
    # paper sleeve band
    parts.append(box(w * 0.30, h * 1.01, d * 1.01, PAPER, origin=(w * 0.10, 0, 0)))
    return merge(parts)


def make_pencil(length, radius):
    """Hexagonal prism lying along X, plus a cone tip."""
    sides = 6
    verts = []
    for i in range(sides):
        a = 2 * np.pi * i / sides
        verts.append([-length / 2, radius * np.cos(a), radius * np.sin(a) + radius])
        verts.append([length / 2, radius * np.cos(a), radius * np.sin(a) + radius])
    verts = np.array(verts, dtype=np.float32)
    faces = []
    for i in range(sides):
        a0, a1 = 2 * i, 2 * i + 1
        b0, b1 = 2 * ((i + 1) % sides), 2 * ((i + 1) % sides) + 1
        faces.append([a0, b0, b1])
        faces.append([a0, b1, a1])
    # caps
    tip = np.array([[length / 2, 0, radius]], dtype=np.float32)
    verts = np.vstack([verts, tip])
    ti = len(verts) - 1
    for i in range(sides):
        a1 = 2 * i + 1
        b1 = 2 * ((i + 1) % sides) + 1
        faces.append([a1, b1, ti])
    faces = np.array(faces, dtype=np.uint32)
    col = np.tile(np.array((0.85, 0.72, 0.30), dtype=np.float32), (len(verts), 1))
    # graphite tip
    col[ti] = (0.15, 0.15, 0.17)
    return verts, faces, col


def make_pencil_case(w, h, d):
    """Pencil-case village base: open-topped tray + lid standing up as a wall."""
    parts = []
    t = 0.35
    # floor
    parts.append(box(w, t, d, TIN))
    # 4 walls
    parts.append(box(w, h, t, TIN, origin=(0, t, -d / 2 + t / 2)))
    parts.append(box(w, h, t, TIN, origin=(0, t, d / 2 - t / 2)))
    parts.append(box(t, h, d, TIN, origin=(-w / 2 + t / 2, t, 0)))
    parts.append(box(t, h, d, TIN, origin=(w / 2 - t / 2, t, 0)))
    # interior partitions (reads as 'street blocks' from above)
    for k in (-0.22, 0.18):
        parts.append(box(t * 0.7, h * 0.8, d * 0.9, TIN, origin=(w * k, t, 0)))
    # a few warm 'houses' = small tall boxes to test window-light read later
    for (hx, hz, hh) in ((-0.32, -0.22, 1.1), (-0.05, 0.24, 0.85), (0.30, -0.10, 1.35)):
        parts.append(box(w * 0.10, hh, d * 0.16, (0.95, 0.80, 0.55),
                         origin=(w * hx, t, d * hz)))
    return merge(parts)


def make_lamp(scale=1.0):
    """Desk lamp as a distant silhouette landmark: base + stem + tilted shade."""
    parts = []
    parts.append(box(2.2, 0.35, 2.2, METAL))                      # base
    parts.append(box(0.28, 9.0, 0.28, METAL, origin=(0, 0.35, 0)))  # stem
    # shade approximated by two stacked boxes (wide bottom, narrow top)
    parts.append(box(3.6, 1.5, 2.6, (0.80, 0.66, 0.42), origin=(0.9, 9.0, 0)))
    parts.append(box(2.4, 0.9, 1.8, (0.86, 0.72, 0.48), origin=(0.9, 10.4, 0)))
    return merge(parts)


def make_mug(scale=1.0):
    """Mug as a far-landmark harbour: cylinder body + handle ring."""
    r, h, sides = 4.0, 6.5, 20
    verts, faces = [], []
    for i in range(sides):
        a = 2 * np.pi * i / sides
        for y in (0.0, h):
            verts.append([r * np.cos(a), y, r * np.sin(a)])
    for i in range(sides):
        a0, a1 = 2 * i, 2 * i + 1
        b0, b1 = 2 * ((i + 1) % sides), 2 * ((i + 1) % sides) + 1
        faces.append([a0, b0, b1]); faces.append([a0, b1, a1])
    verts = np.array(verts, dtype=np.float32)
    faces = np.array(faces, dtype=np.uint32)
    col = np.tile(np.array((0.90, 0.88, 0.82), dtype=np.float32), (len(verts), 1))
    body = (verts, faces, col)
    # handle: a flat bar on the side
    handle = box(1.2, 4.2, 3.0, (0.86, 0.84, 0.78), origin=(r + 0.4, 1.0, 0))
    return merge([body, handle])


def main():
    os.makedirs(OUT, exist_ok=True)
    made = []

    def emit(fname, parts, name):
        v, f, c = parts
        p = os.path.join(OUT, fname)
        write_glb(p, v, f, c, name)
        sz = (v.max(0) - v.min(0)).tolist()
        made.append((fname, name, [round(x, 2) for x in sz], len(f)))
        print(f'{fname:28s} {name:16s} size(xyz)={[round(x,2) for x in sz]} tris={len(f)}')

    emit('WB_DESK.glb', make_desk(), 'WB_DESK')
    emit('WB_BOOK_A.glb', make_book(9.0, 7.0, 6.0, (0.45, 0.22, 0.20)), 'WB_BOOK_A')
    emit('WB_BOOK_B.glb', make_book(7.5, 5.6, 5.0, (0.20, 0.32, 0.38)), 'WB_BOOK_B')
    emit('WB_RULER.glb', make_ruler(30.0, 2.6, 0.45), 'WB_RULER')
    emit('WB_ERASER.glb', make_eraser(4.0, 1.8, 2.4), 'WB_ERASER')
    emit('WB_PENCIL.glb', make_pencil(22.0, 0.85), 'WB_PENCIL')
    emit('WB_PENCILCASE.glb', make_pencil_case(14.0, 2.6, 9.0), 'WB_PENCILCASE')
    emit('WB_LAMP.glb', make_lamp(), 'WB_LAMP')
    emit('WB_MUG.glb', make_mug(), 'WB_MUG')

    with open(os.path.join(OUT, 'manifest.json'), 'w', encoding='utf-8') as fh:
        json.dump(made, fh, ensure_ascii=False, indent=2)
    print(f'\n{len(made)} whitebox GLBs -> {OUT}')


if __name__ == '__main__':
    main()
