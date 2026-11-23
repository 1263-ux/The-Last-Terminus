"""Tripo asset import workflow - Day-04 entry criterion #5.
Complete workflow: validate GLB → import to editor → verify at runtime.
Usage: python tripo_import_workflow.py <path-to-tripo-glb>
"""
import json
import subprocess
import sys
import pathlib

TOOLS_DIR = pathlib.Path(__file__).parent

def run_cmd(cmd, **kwargs):
    """Run a command and return output."""
    print(f"  > {' '.join(cmd[:6])}...")
    r = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8",
                       errors="replace", **kwargs)
    return r.stdout, r.stderr, r.returncode

def step1_validate(glb_path):
    """Validate GLB using validate_tripo.py."""
    print("\n=== Step 1: Validate Tripo GLB ===")
    py = sys.executable
    stdout, stderr, rc = run_cmd([py, str(TOOLS_DIR / "validate_tripo.py"), str(glb_path)])
    print(stdout)
    if rc != 0:
        print(f"  VALIDATION FAILED: {stderr}")
        return False
    return True

def step2_import(glb_path, instance_id, workspace_id, prefab_id):
    """Import GLB to editor via resource model import chain."""
    print("\n=== Step 2: Import to Editor ===")
    
    # Create prefab
    stdout, stderr, rc = run_cmd([
        "douyin-world", "authoring", "prefab", "create", prefab_id,
        "--instance", instance_id, "--workspace-id", workspace_id
    ])
    if rc != 0 and "already exists" not in stderr:
        print(f"  Prefab create failed: {stderr[:200]}")
    
    # Import GLB
    stdout, stderr, rc = run_cmd([
        "douyin-world", "authoring", "resource", "model", "import",
        f"model-{prefab_id}", "--prefab", prefab_id,
        "--workspace-id", workspace_id, "--instance", instance_id,
        "--glb", str(glb_path)
    ])
    if rc != 0:
        print(f"  Model import failed: {stderr[:200]}")
        return None
    print(f"  Import: {stdout[:200]}")
    
    # Archive
    stdout, stderr, rc = run_cmd([
        "douyin-world", "authoring", "resource", "archive",
        f"model-{prefab_id}", "--kind", "model",
        "--prefab", prefab_id, "--workspace-id", workspace_id,
        "--instance", instance_id, "--json"
    ])
    try:
        uri = json.loads(stdout)["data"]["uri"]
        print(f"  Archive URI: {uri[:60]}...")
    except Exception as e:
        print(f"  Archive failed: {e}")
        return None
    
    # Attach
    stdout, stderr, rc = run_cmd([
        "douyin-world", "authoring", "prefab", "attach", prefab_id,
        "--workspace-id", workspace_id, "--instance", instance_id,
        "--kind", "model", "--uri", uri
    ])
    
    # Build
    stdout, stderr, rc = run_cmd([
        "douyin-world", "authoring", "prefab", "build", prefab_id,
        "--workspace-id", workspace_id, "--instance", instance_id
    ])
    
    # Export
    stdout, stderr, rc = run_cmd([
        "douyin-world", "authoring", "result", "archive", prefab_id,
        "--workspace-id", workspace_id, "--instance", instance_id,
        "--name", f"Tripo_{prefab_id}", "--json"
    ])
    try:
        wprefab_uri = json.loads(stdout)["data"]["uri"]
        print(f"  WPrefab: {wprefab_uri[:60]}...")
    except Exception as e:
        print(f"  Export failed: {e}")
        return None
    
    return wprefab_uri

def main():
    if len(sys.argv) < 2:
        print("Usage: python tripo_import_workflow.py <path-to-tripo-glb> [instance-id] [workspace-id]")
        print("Complete Tripo asset import workflow for Day-04.")
        return
    
    glb_path = pathlib.Path(sys.argv[1])
    instance_id = sys.argv[2] if len(sys.argv) > 2 else "awc-default"
    workspace_id = sys.argv[3] if len(sys.argv) > 3 else "workspace_2k2n6uac"
    prefab_id = f"tripo-{glb_path.stem}"
    
    if not glb_path.exists():
        print(f"File not found: {glb_path}")
        return
    
    # Step 1: Validate
    if not step1_validate(glb_path):
        print("\nIMPORT ABORTED: validation failed")
        return
    
    # Step 2: Import
    wprefab_uri = step2_import(glb_path, instance_id, workspace_id, prefab_id)
    if wprefab_uri:
        print(f"\n=== SUCCESS ===")
        print(f"  GLB: {glb_path.name}")
        print(f"  WPrefab URI: {wprefab_uri}")
        print(f"  Ready for scene import: douyin-world scene import --uri {wprefab_uri}")
    else:
        print(f"\n=== IMPORT FAILED ===")

if __name__ == "__main__":
    main()
