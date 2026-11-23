"""Validate shared GLB assets have required attributes."""
import json
import pathlib
import struct

def parse_glb(path):
    """Parse GLB and return mesh info."""
    with open(path, 'rb') as f:
        magic = struct.unpack('<I', f.read(4))[0]
        if magic != 0x46546C67:
            return {"error": "not GLB"}
        version = struct.unpack('<I', f.read(4))[0]
        length = struct.unpack('<I', f.read(4))[0]
        
        # Read chunks
        json_data = None
        while f.tell() < length:
            chunk_len = struct.unpack('<I', f.read(4))[0]
            chunk_type = struct.unpack('<I', f.read(4))[0]
            if chunk_type == 0x4E4F534A:  # JSON
                json_data = f.read(chunk_len)
            else:
                f.read(chunk_len)
        
        gltf = json.loads(json_data.rstrip(b' \x00'))
        
        result = {
            "file": path.name,
            "version": version,
            "meshes": len(gltf.get("meshes", [])),
            "materials": len(gltf.get("materials", [])),
        }
        
        # Check mesh attributes
        for i, mesh in enumerate(gltf.get("meshes", [])):
            for j, prim in enumerate(mesh.get("primitives", [])):
                attrs = list(prim.get("attributes", {}).keys())
                result[f"mesh{i}_prim{j}_attrs"] = attrs
                result[f"mesh{i}_prim{j}_has_normal"] = "NORMAL" in attrs
                result[f"mesh{i}_prim{j}_has_texcoord"] = "TEXCOORD_0" in attrs
                result[f"mesh{i}_prim{j}_has_position"] = "POSITION" in attrs
        
        return result

base = pathlib.Path(r"D:\zjx\projects\The-Last-Terminus\reports\day-03\A\shared-assets\glb")
for p in sorted(base.glob("*.glb")):
    info = parse_glb(p)
    print(f"\n=== {info['file']} ===")
    print(f"  meshes={info['meshes']} materials={info['materials']}")
    for k, v in info.items():
        if k.startswith("mesh"):
            print(f"  {k}: {v}")
