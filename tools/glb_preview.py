#!/usr/bin/env python3
"""Minimal headless GLB previewer.

Renders a GLB to a PNG contact sheet using a painter's-algorithm triangle
rasteriser with vertex base-color shading. Pure numpy + Pillow.

This exists so asset identification can be evidence-based (actual geometry)
rather than guessed from uninformative filenames.
"""
import json
import os
import struct
import sys

import numpy as np
from PIL import Image


def load_glb(path):
    with open(path, 'rb') as f:
        data = f.read()
    magic, version, length = struct.unpack_from('<III', data, 0)
    assert magic == 0x46546C67, 'not GLB'
    off = 12
    g = None
    binc = None
    while off < length:
        clen, ctype = struct.unpack_from('<II', data, off)
        off += 8
        chunk = data[off:off + clen]
        off += clen
        if ctype == 0x4E4F534A:
            g = json.loads(chunk.decode('utf-8'))
        elif ctype == 0x004E4942:
            binc = chunk
    return g, binc


CT = {5120: (np.int8, 1), 5121: (np.uint8, 1), 5122: (np.int16, 2),
      5123: (np.uint16, 2), 5125: (np.uint32, 4), 5126: (np.float32, 4)}
NC = {'SCALAR': 1, 'VEC2': 2, 'VEC3': 3, 'VEC4': 4, 'MAT4': 16}


def accessor(g, binc, idx):
    a = g['accessors'][idx]
    dt, size = CT[a['componentType']]
    n = NC[a['type']]
    count = a['count']
    # account for sparse (rare) by ignoring; record flag
    bv = g['bufferViews'][a['bufferView']]
    base = bv.get('byteOffset', 0) + a.get('byteOffset', 0)
    stride = bv.get('byteStride') or (size * n)
    if stride == size * n:
        arr = np.frombuffer(binc, dtype=dt, count=count * n, offset=base)
        return arr.reshape(count, n)
    out = np.empty((count, n), dtype=dt)
    for i in range(count):
        out[i] = np.frombuffer(binc, dtype=dt, count=n, offset=base + i * stride)
    return out


def gather(path):
    g, binc = load_glb(path)
    nodes = g.get('nodes', [])
    tris_all = []
    cols_all = []

    # build world transforms (assume no node scaling beyond listed)
    def trs(n):
        m = np.eye(4, dtype=np.float64)
        if 'matrix' in n:
            m = np.array(n['matrix'], dtype=np.float64).reshape(4, 4).T
            return m
        t = np.array(n.get('translation', [0, 0, 0]), dtype=np.float64)
        s = np.array(n.get('scale', [1, 1, 1]), dtype=np.float64)
        q = np.array(n.get('rotation', [0, 0, 0, 1]), dtype=np.float64)
        x, y, z, w = q
        R = np.array([
            [1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
            [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
            [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)],
        ], dtype=np.float64)
        m[:3, :3] = R * s[None, :]
        m[:3, 3] = t
        return m

    def walk(i, parent, depth=0):
        n = nodes[i]
        M = parent @ trs(n)
        if 'mesh' in n:
            mesh = g['meshes'][n['mesh']]
            for p in mesh.get('primitives', []):
                attrs = p.get('attributes', {})
                if 'POSITION' not in attrs:
                    continue
                P = accessor(g, binc, attrs['POSITION']).astype(np.float64)
                if 'indices' in p:
                    I = accessor(g, binc, p['indices']).astype(np.int64).ravel()
                else:
                    I = np.arange(len(P), dtype=np.int64)
                if len(I) < 3:
                    continue
                I = I[:len(I) - len(I) % 3].reshape(-1, 3)
                # vertex colours if present
                col = None
                if 'COLOR_0' in attrs:
                    C = accessor(g, binc, attrs['COLOR_0']).astype(np.float64)
                    if C.ndim == 2 and C.shape[1] >= 3:
                        c = C[:, :3]
                        if c.max() > 1.5:
                            c = c / 255.0
                        col = np.clip(c, 0, 1)
                # apply transform
                Ph = np.hstack([P, np.ones((len(P), 1))]) @ M.T
                Pw = Ph[:, :3]
                tris_all.append(Pw[I])
                if col is not None:
                    cols_all.append(col[I].mean(1))
                else:
                    cols_all.append(np.full((len(I), 3), -1.0))
        for c in n.get('children', []):
            walk(c, M, depth + 1)

    roots = set(range(len(nodes)))
    for i, n in enumerate(nodes):
        for c in n.get('children', []):
            roots.discard(c)
    for r in sorted(roots):
        walk(r, np.eye(4))

    if not tris_all:
        return None
    T = np.concatenate(tris_all, 0)
    C = np.concatenate(cols_all, 0)
    return T, C


def render(T, C, W=520, H=520, yaw=35.0, pitch=22.0, bg=(245, 245, 248)):
    # center & normalise
    pts = T.reshape(-1, 3)
    lo, hi = pts.min(0), pts.max(0)
    ctr = (lo + hi) / 2
    scale = np.max(hi - lo)
    if scale <= 0:
        scale = 1.0
    V = (T - ctr) / scale

    y = np.radians(yaw)
    p = np.radians(pitch)
    Ry = np.array([[np.cos(y), 0, np.sin(y)], [0, 1, 0], [-np.sin(y), 0, np.cos(y)]])
    Rx = np.array([[1, 0, 0], [0, np.cos(p), -np.sin(p)], [0, np.sin(p), np.cos(p)]])
    R = Rx @ Ry
    V = V @ R.T

    # orthographic projection, y up
    xy = V[:, :, :2]
    z = V[:, :, 2]
    s = 0.78 * min(W, H)
    sx = xy[:, :, 0] * s + W / 2
    sy = -xy[:, :, 1] * s + H / 2

    img = np.zeros((H, W, 3), dtype=np.float64)
    img[:, :] = np.array(bg, dtype=np.float64) / 255.0
    zbuf = np.full((H, W), -1e9)

    # light direction in view space
    L = np.array([0.35, 0.75, 0.55])
    L = L / np.linalg.norm(L)

    order = np.argsort(z.mean(1))
    for ti in order:
        x = sx[ti]
        yy = sy[ti]
        zz = z[ti]
        # face normal in view space for shading
        e1 = V[ti, 1] - V[ti, 0]
        e2 = V[ti, 2] - V[ti, 0]
        nrm = np.cross(e1, e2)
        ln = np.linalg.norm(nrm)
        if ln > 1e-12:
            nrm = nrm / ln
        else:
            continue
        shade = 0.30 + 0.70 * abs(float(np.dot(nrm, L)))
        # base colour: use per-vertex colours if valid
        cv = C[ti]
        if float(np.max(cv)) > -0.5:
            base = np.clip(np.asarray(cv, dtype=np.float64).ravel()[:3], 0, 1)
            if base.max() < 0.05:
                base = np.array([0.72, 0.70, 0.66])
        else:
            base = np.array([0.70, 0.68, 0.64])
        rgb = np.clip(base * shade, 0, 1)

        minx = max(int(np.floor(x.min())), 0)
        maxx = min(int(np.ceil(x.max())), W - 1)
        miny = max(int(np.floor(yy.min())), 0)
        maxy = min(int(np.ceil(yy.max())), H - 1)
        if minx > maxx or miny > maxy:
            continue
        gx, gy = np.meshgrid(np.arange(minx, maxx + 1), np.arange(miny, maxy + 1))
        # barycentric
        x0, y0 = x[0], yy[0]
        x1, y1 = x[1], yy[1]
        x2, y2 = x[2], yy[2]
        den = (y1 - y2) * (x0 - x2) + (x2 - x1) * (y0 - y2)
        if abs(den) < 1e-12:
            continue
        w0 = ((y1 - y2) * (gx - x2) + (x2 - x1) * (gy - y2)) / den
        w1 = ((y2 - y0) * (gx - x2) + (x0 - x2) * (gy - y2)) / den
        w2 = 1.0 - w0 - w1
        inside = (w0 >= -1e-9) & (w1 >= -1e-9) & (w2 >= -1e-9)
        if not inside.any():
            continue
        zz_ = w0 * zz[0] + w1 * zz[1] + w2 * zz[2]
        sub = zbuf[miny:maxy + 1, minx:maxx + 1]
        m = inside & (zz_ > sub)
        if not m.any():
            continue
        sub[m] = zz_[m]
        dst = img[miny:maxy + 1, minx:maxx + 1]
        dst[m] = rgb

    return Image.fromarray((np.clip(img, 0, 1) * 255).astype(np.uint8))


def main():
    outdir = sys.argv[1]
    files = sys.argv[2:]
    os.makedirs(outdir, exist_ok=True)
    tiles = []
    for f in files:
        name = os.path.splitext(os.path.basename(f))[0]
        try:
            T, C = gather(f)
        except Exception as e:
            print(f'FAIL {name}: {e}')
            continue
        if T is None or len(T) == 0:
            print(f'EMPTY {name}')
            continue
        # three views
        ims = [render(T, C, yaw=a, pitch=22) for a in (35, 125, 215)]
        sheet = Image.new('RGB', (520 * 3, 520), (255, 255, 255))
        for i, im in enumerate(ims):
            sheet.paste(im, (520 * i, 0))
        out = os.path.join(outdir, name + '.png')
        sheet.save(out)
        print(f'OK {name} tris={len(T)} -> {out}')


if __name__ == '__main__':
    main()
