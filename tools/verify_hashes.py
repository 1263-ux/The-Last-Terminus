import csv
import hashlib
import pathlib

base = pathlib.Path(r"D:\zjx\projects\The-Last-Terminus\reports\day-03\A\shared-assets")
rows = list(csv.DictReader(open(base / "ASSET-MANIFEST.csv", encoding="utf-8")))
ok = 0
fail = 0
for r in rows:
    name = r["asset"]
    p = base / name
    if not p.exists():
        p = base / "glb" / name
    if not p.exists():
        print(f"MISSING: {name}")
        fail += 1
        continue
    h = hashlib.sha256(p.read_bytes()).hexdigest()
    expected = r["sha256"]
    if h == expected:
        ok += 1
    else:
        print(f"MISMATCH: {name}")
        print(f"  expected: {expected[:16]}")
        print(f"  got:      {h[:16]}")
        fail += 1
print(f"{ok} OK, {fail} FAIL, {len(rows)} total")
