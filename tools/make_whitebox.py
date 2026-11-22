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
    """Write a minimal GLB: POSITION + NORMAL + COLOR_0 + indices.

    NORMAL is REQUIRED. Without normals the engine renders the mesh invisible:
    the shadow map still draws (it only needs depth), so the symptom is a real
    object that casts a shadow but has no visible surface. That exact symptom
    cost a full debugging cycle, hence this comment.
    """
    verts = np.asarray(verts, dtype=np.float32)
    faces = np.asarray(faces, dtype=np.uint32)
    colors = np.asarray(colors, dtype=np.float32)

    # Smooth per-vertex normals: accumulate face normals, then normalise.
    #
    # WINDING MATTERS. The engine's default raster state culls back faces using
    # normal direction. The box() helper emits faces whose winding produces
    # INWARD normals, so a naive accumulate renders every surface back-face and
    # the object becomes invisible while still casting a shadow. We therefore
    # flip the accumulated normals to point OUTWARD from the mesh centroid.
    normals = np.zeros_like(verts)
    tri = verts[faces]                       # (n,3,3)
    fn = np.cross(tri[:, 1] - tri[:, 0], tri[:, 2] - tri[:, 0])
    for k in range(3):
        np.add.at(normals, faces[:, k], fn)

    # Orientation check against the centroid: if the summed normal points at the
    # centre rather than away from it, the winding (and thus the normals) are
    # inverted. Flip the whole set once, consistently.
    centroid = verts.mean(axis=0)
    outward = verts - centroid
    agree = np.sum(np.einsum('ij,ij->i', normals, outward))
    if agree < 0:
        normals = -normals

    ln = np.linalg.norm(normals, axis=1, keepdims=True)
    ln[ln < 1e-12] = 1.0
    normals = (normals / ln).astype(np.float32)

    def pad4(b):
        return b + b'\x00' * ((4 - len(b) % 4) % 4)

    pos_bytes = pad4(verts.tobytes())
    nrm_bytes = pad4(normals.tobytes())
    col_bytes = pad4(colors.tobytes())
    idx_bytes = pad4(faces.tobytes())

    bin_blob = pos_bytes + nrm_bytes + col_bytes + idx_bytes
    mn = verts.min(axis=0).tolist()
    mx = verts.max(axis=0).tolist()

    o_pos, o_nrm = 0, len(pos_bytes)
    o_col = o_nrm + len(nrm_bytes)
    o_idx = o_col + len(col_bytes)

    gltf = {
        'asset': {'version': '2.0', 'generator': 'TLT whitebox generator'},
        'scene': 0,
        'scenes': [{'nodes': [0]}],
        'nodes': [{'name': name, 'mesh': 0}],
        'meshes': [{
            'name': name + '_mesh',
            'primitives': [{
                'attributes': {'POSITION': 0, 'NORMAL': 1, 'COLOR_0': 2},
                'indices': 3,
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
            {'bufferView': 1, 'componentType': 5126, 'count': len(normals),
             'type': 'VEC3'},
            {'bufferView': 2, 'componentType': 5126, 'count': len(colors),
             'type': 'VEC3'},
            {'bufferView': 3, 'componentType': 5125, 'count': faces.size,
             'type': 'SCALAR'},
        ],
        'bufferViews': [
            {'buffer': 0, 'byteOffset': o_pos, 'byteLength': len(pos_bytes)},
            {'buffer': 0, 'byteOffset': o_nrm, 'byteLength': len(nrm_bytes)},
            {'buffer': 0, 'byteOffset': o_col, 'byteLength': len(col_bytes)},
            {'buffer': 0, 'byteOffset': o_idx, 'byteLength': len(idx_bytes)},
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
    """Desk slabs forming a 10 m chasm, anchored so the player stands at z=0
    on the near slab while the chasm lies AHEAD in +Z.

    Local frame: near slab z in [-6, +22], chasm z in [22, 32], far slab z in
    [32, 44]. The player spawn camera was measured to look toward +Z, so the
    player must walk forward into the gap.

    The near slab starts at z=-6 only; the player at z=0 stands safely on it and
    is never inside geometry (an earlier 40 m slab put the camera inside the
    desk, which is why nothing was visible).
    """
    gap_start, gap_end = 22.0, 32.0
    near = box(28.0, 0.6, (gap_start + 6.0), WOOD, origin=(0, 0, (gap_start - 6.0) / 2))
    far = box(28.0, 0.6, 12.0, WOOD, origin=(0, 0, (gap_end + 6.0)))
    return merge([near, far])


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


def make_book_flat(w, h, d, cover, pages=0.82):
    """A book LYING FLAT, i.e. wide in X/Z and thin in Y.

    This is the readable form for the Desk World, and the reason is a measured
    engine constraint rather than an art preference: the third-person camera
    sits at y=79.6 with only ~4.5 deg of upward visibility, so at 10 m the whole
    frame above y=80.67 is out of shot. A standing 7 m book is therefore never
    seen - only an unreadable slab edge. A book lying flat presents its cover
    and page block as a raised plateau inside the visible band, and it also
    gives the walker something to climb, which the 1.0 m jump limit requires.

    Local frame: cover on the ground, page block stacked on top, thickness h.
    """
    parts = []
    t = h * 0.10                                   # cover thickness
    parts.append(box(w, t, d, cover, origin=(0, 0, 0)))
    # page block, inset on all sides so the cover overhangs (deckle edge)
    parts.append(box(w * 0.94, h * pages, d * 0.94, PAPER,
                     origin=(0, t, 0)))
    parts.append(box(w, t, d, cover, origin=(0, t + h * pages, 0)))
    # spine: a raised rail along one long edge, reads as the book's binding
    parts.append(box(w * 0.04, h, d, PAPER_D, origin=(-w / 2 + w * 0.02, 0, 0)))
    return merge(parts)


def make_ruler(length, width, thick):
    """A wooden ruler whose LONG axis runs along Z.

    Orientation is baked into the geometry on purpose: this CLI exposes no
    rotate command for already-placed nodes, so an asset can only ever have the
    orientation its GLB was authored with. The desk chasm is a gap in Z, so the
    ruler must run along Z to span it.
    Body + a raised bevelled rail + tick marks as thin bars.
    """
    def zbox(w, h, d, color, origin=(0, 0, 0)):
        # box() builds w along X, h along Y, d along Z -- use directly.
        return box(w, h, d, color, origin=origin)

    parts = [zbox(width, thick, length, WOOD_L)]
    # raised edge rail along one long side
    parts.append(zbox(width * 0.06, thick * 0.25, length, WOOD,
                      origin=(-width / 2 + width * 0.08, thick, 0)))
    # tick marks: every 1/10 of length, long ticks every 5th, on one edge
    n = 10
    for i in range(1, n):
        z = -length / 2 + length * i / n
        long = (i % 5 == 0)
        w = width * (0.34 if long else 0.18)
        parts.append(zbox(w, thick * 0.12, length * 0.006, (0.25, 0.18, 0.10),
                          origin=(width / 2 - w / 2 - width * 0.06, thick, z)))
    return merge(parts)


def make_eraser(w, h, d):
    parts = [box(w, h, d, RUBBER)]
    # paper sleeve band
    parts.append(box(w * 0.30, h * 1.01, d * 1.01, PAPER, origin=(w * 0.10, 0, 0)))
    return merge(parts)


def make_pencil(length, radius):
    """Hexagonal prism lying along Z (same orientation rule as the ruler)."""
    sides = 6
    verts = []
    for i in range(sides):
        a = 2 * np.pi * i / sides
        verts.append([radius * np.cos(a) + radius, radius * np.sin(a), -length / 2])
        verts.append([radius * np.cos(a) + radius, radius * np.sin(a), length / 2])
    verts = np.array(verts, dtype=np.float32)
    faces = []
    for i in range(sides):
        a0, a1 = 2 * i, 2 * i + 1
        b0, b1 = 2 * ((i + 1) % sides), 2 * ((i + 1) % sides) + 1
        faces.append([a0, b0, b1])
        faces.append([a0, b1, a1])
    tip = np.array([[radius, 0, length / 2]], dtype=np.float32)
    verts = np.vstack([verts, tip])
    ti = len(verts) - 1
    for i in range(sides):
        a1 = 2 * i + 1
        b1 = 2 * ((i + 1) % sides) + 1
        faces.append([a1, b1, ti])
    faces = np.array(faces, dtype=np.uint32)
    col = np.tile(np.array((0.85, 0.72, 0.30), dtype=np.float32), (len(verts), 1))
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


def make_ramp(length, width, rise):
    """A wedge ramp rising along +Z: the optional branch route.

    Built as a stepped wedge (N steps) rather than a true incline, because the
    engine's player controller has jumpMaxHeight = 1.0 m and no verified slope
    handling; steps of <= 0.5 m are always climbable by walking.
    """
    n = 12
    parts = []
    for i in range(n):
        h = rise * (i + 1) / n
        z = -length / 2 + length * (i + 0.5) / n
        parts.append(box(width, h, length / n, WOOD_L,
                         origin=(0, 0, z)))
    return merge(parts)


def make_sign(height=6.0):
    """Exit marker: a tall post with a sign plate and a base pad.

    Day 2 needs a visible EXIT that reads from the village, so the route has a
    defined end instead of just stopping.
    """
    parts = [
        box(0.35, height, 0.35, METAL, origin=(0, 0, 0)),
        box(2.6, 1.1, 0.22, (0.90, 0.85, 0.62),
            origin=(0.9, height - 1.4, 0)),
        box(1.4, 0.28, 1.4, WOOD, origin=(0, 0, 0)),
    ]
    return merge(parts)


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
    # R1: 30 m was far too long for a 10 m chasm (necessarily overhung 20 m).
    # 12 m spans a 10 m gap with 1 m of seating on each edge.
    emit('WB_RULER.glb', make_ruler(12.0, 2.6, 0.45), 'WB_RULER')
    # Same ruler authored already in the SPANNING pose, for the two-preset-state
    # bridge solution (blocker B-03 degradation L0): swapping between
    # WB_RULER (rest) and WB_RULER_SPAN (spanning) needs no anchor API.
    emit('WB_RULER_SPAN.glb', make_ruler(12.0, 2.6, 0.45), 'WB_RULER_SPAN')
    emit('WB_ERASER.glb', make_eraser(4.0, 1.8, 2.4), 'WB_ERASER')
    emit('WB_PENCIL.glb', make_pencil(22.0, 0.85), 'WB_PENCIL')
    emit('WB_PENCILCASE.glb', make_pencil_case(14.0, 2.6, 9.0), 'WB_PENCILCASE')
    emit('WB_LAMP.glb', make_lamp(), 'WB_LAMP')
    emit('WB_MUG.glb', make_mug(), 'WB_MUG')

    # ---- SCALE A/B variants -------------------------------------------
    # The reference study's own basis [PROPOSED] says a 300 mm ruler against a
    # 15 mm player is 20x. With the editor's measured 1.7 m avatar that means a
    # 34 m ruler and a ~27 m book. The current white box is only 7.1x / 5.3x,
    # i.e. ~3x too small, which is why it reads as canyon walls rather than as
    # a giant book. These variants exist so the two readings can be compared
    # side by side in the real engine before any Tripo spend.
    emit('WB_BOOK_XL.glb', make_book(27.0, 21.0, 18.0, (0.45, 0.22, 0.20)), 'WB_BOOK_XL')
    emit('WB_RULER_XL.glb', make_ruler(34.0, 6.0, 1.0), 'WB_RULER_XL')

    # ---- Day-2 route pieces -------------------------------------------
    # Branch: a broad ramp climbing onto the far slab's side, so the optional
    # route is a real alternate path (not just a viewpoint).
    emit('WB_RAMP.glb', make_ramp(22.0, 9.0, 5.0), 'WB_RAMP')
    # Exit marker at the end of the far slab.
    emit('WB_SIGN.glb', make_sign(6.0), 'WB_SIGN')

    # ---- FLAT books: the only form that is actually visible ------------
    # SCALE BUG (found Day 2): the importer normalises each GLB to ~1 unit and
    # bakes a scale equal to the mesh's LONGEST dimension back onto the node.
    # Effective world size is therefore authored_size x authored_longest, i.e.
    # quadratic in the authored length. Verified in scene.data:
    #   WB_BOOK_FLAT_A (14 x 1.84 x 11) -> scale (14,14,14)
    # So to land a book at ~4 m across, author it at sqrt(4) ~ 2 m per side.
    # These variants are authored small on purpose ("S" = small).
    emit('WB_BOOK_S.glb', make_book_flat(2.0, 0.55, 1.6, (0.45, 0.22, 0.20)),
         'WB_BOOK_S')
    emit('WB_RULER_S.glb', make_ruler(3.2, 0.7, 0.14), 'WB_RULER_S')
    emit('WB_CASE_S.glb', make_pencil_case(2.2, 0.5, 1.5), 'WB_CASE_S')

    with open(os.path.join(OUT, 'manifest.json'), 'w', encoding='utf-8') as fh:
        json.dump(made, fh, ensure_ascii=False, indent=2)
    print(f'\n{len(made)} whitebox GLBs -> {OUT}')


if __name__ == '__main__':
    main()
