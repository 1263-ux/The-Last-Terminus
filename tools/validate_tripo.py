"""Tripo asset import validator - Day-04 entry criterion #5.
Validates GLB files exported from Tripo, checking texture container format.
Usage: python validate_tripo.py <path-to-tripo-glb>
"""
import json
import struct
import sys
import pathlib

def validate_glb(path):
    """Validate a Tripo-exported GLB file."""
    with open(path, 'rb') as f:
        magic = struct.unpack('<I', f.read(4))[0]
        if magic != 0x46546C67:
            return {"error": "not GLB", "file": path.name}
        
        version = struct.unpack('<I', f.read(4))[0]
        length = struct.unpack('<I', f.read(4))[0]
        
        json_data = None
        bin_data = None
        while f.tell() < length:
            chunk_len = struct.unpack('<I', f.read(4))[0]
            chunk_type = struct.unpack('<I', f.read(4))[0]
            if chunk_type == 0x4E4F534A:
                json_data = f.read(chunk_len)
            elif chunk_type == 0x004E4942:
                bin_data = f.read(chunk_len)
            else:
                f.read(chunk_len)
        
        gltf = json.loads(json_data.rstrip(b' \x00'))
        
        result = {
            "file": path.name,
            "version": version,
            "total_bytes": length,
            "meshes": len(gltf.get("meshes", [])),
            "materials": len(gltf.get("materials", [])),
            "textures": len(gltf.get("textures", [])),
            "images": len(gltf.get("images", [])),
        }
        
        # Check mesh attributes
        all_attrs = set()
        for mesh in gltf.get("meshes", []):
            for prim in mesh.get("primitives", []):
                all_attrs.update(prim.get("attributes", {}).keys())
        result["attributes"] = sorted(all_attrs)
        result["has_position"] = "POSITION" in all_attrs
        result["has_normal"] = "NORMAL" in all_attrs
        result["has_texcoord"] = "TEXCOORD_0" in all_attrs
        
        # Check texture format (embedded vs external)
        for i, img in enumerate(gltf.get("images", [])):
            if "bufferView" in img:
                result[f"image{i}_format"] = "embedded"
                bv = gltf["bufferViews"][img["bufferView"]]
                result[f"image{i}_mime"] = img.get("mimeType", "unknown")
            elif "uri" in img:
                result[f"image{i}_format"] = "external"
                result[f"image{i}_uri"] = img["uri"]
        
        # Check material textures
        for i, mat in enumerate(gltf.get("materials", [])):
            pbr = mat.get("pbrMetallicRoughness", {})
            if "baseColorTexture" in pbr:
                result[f"material{i}_has_basecolor"] = True
            if "metallicRoughnessTexture" in pbr:
                result[f"material{i}_has_mr"] = True
        
        # Vertex colors
        for i, mesh in enumerate(gltf.get("meshes", [])):
            for j, prim in enumerate(mesh.get("primitives", [])):
                if "COLOR_0" in prim.get("attributes", {}):
                    result[f"mesh{i}_has_vertexcolor"] = True
        
        return result

def main():
    if len(sys.argv) < 2:
        print("Usage: python validate_tripo.py <path-to-glb>")
        print("Validates Tripo GLB export for Day-04 import readiness.")
        return
    
    path = pathlib.Path(sys.argv[1])
    if not path.exists():
        print(f"File not found: {path}")
        return
    
    result = validate_glb(path)
    print(json.dumps(result, indent=2))
    
    # Summary
    print("\n=== Day-04 Import Readiness ===")
    issues = []
    if not result.get("has_position"):
        issues.append("MISSING POSITION attribute")
    if not result.get("has_normal"):
        issues.append("MISSING NORMAL attribute (causes 'shadow but no surface')")
    if not result.get("has_texcoord"):
        issues.append("MISSING TEXCOORD_0 (no UV mapping)")
    if result.get("textures", 0) == 0:
        issues.append("No textures found")
    
    if issues:
        print("ISSUES:")
        for issue in issues:
            print(f"  - {issue}")
    else:
        print("READY for import via resource model import chain")

if __name__ == "__main__":
    main()
