"""Platform walkability verifier for C's Floating Garden.
Since collision is unavailable (kinematic player), visual platforms may not
actually be walkable. This script tests if the engine terrain supports walking
at platform heights.

Usage: python verify_platform.py <instance-id> <runtime-id>
Tests walking at multiple Y heights to determine actual walkable range.
"""
import json
import subprocess
import sys
import time

def run_lua(instance_id, runtime_id, lua_code):
    """Run Lua code and return result."""
    import tempfile, pathlib
    with tempfile.NamedTemporaryFile(mode='w', suffix='.lua', delete=False, encoding='utf-8') as f:
        f.write(lua_code)
        path = f.name
    try:
        r = subprocess.run(
            ["douyin-world", "runtime", "lua", "eval", "--file", path,
             "--instance", instance_id, "--runtime-id", runtime_id, "--global"],
            capture_output=True, text=True, encoding="utf-8", errors="replace")
        try:
            data = json.loads(r.stdout)
            return data.get("result", "")
        except:
            return r.stdout[:200]
    finally:
        pathlib.Path(path).unlink(missing_ok=True)

def check_position(instance_id, runtime_id):
    """Get current player position."""
    code = '''local actor = CS.DouyinActorService.GetLocalActor()
if actor == nil then return 'no-actor' end
local p = actor.position
return string.format('%.2f|%.2f|%.2f', p.x, p.y, p.z)'''
    return run_lua(instance_id, runtime_id, code)

def teleport(instance_id, runtime_id, x, y, z):
    """Teleport player to position."""
    code = f'''local actor = CS.DouyinActorService.GetLocalActor()
if actor == nil then return 'no-actor' end
actor:Teleport(CS.UnityEngine.Vector3({x}, {y}, {z}), CS.UnityEngine.Quaternion.Euler(0,0,0))
return 'teleported' '''
    return run_lua(instance_id, runtime_id, code)

def walk_forward(instance_id, runtime_id, duration_ms=3000):
    """Walk forward for duration_ms."""
    r = subprocess.run(
        ["douyin-world", "runtime", "input", "keys", f"W:{duration_ms}",
         "--instance", instance_id, "--runtime-id", runtime_id],
        capture_output=True, text=True, encoding="utf-8", errors="replace")
    time.sleep(duration_ms / 1000 + 1)

def main():
    if len(sys.argv) < 3:
        print("Usage: python verify_platform.py <instance-id> <runtime-id>")
        return
    
    instance_id = sys.argv[1]
    runtime_id = sys.argv[2]
    
    print("=== Platform Walkability Verification ===")
    print("Testing if engine terrain supports walking at various heights...")
    
    # Test heights
    heights = [78, 79, 80, 81, 82, 83]
    
    for y in heights:
        teleport(instance_id, runtime_id, 119.74, y, 88)
        time.sleep(1)
        pos_before = check_position(instance_id, runtime_id)
        
        walk_forward(instance_id, runtime_id, 3000)
        pos_after = check_position(instance_id, runtime_id)
        
        before_z = float(pos_before.split("|")[2]) if "|" in pos_before else 0
        after_z = float(pos_after.split("|")[2]) if "|" in pos_after else 0
        distance = abs(after_z - before_z)
        
        status = "WALKABLE" if distance > 1 else "NOT WALKABLE"
        print(f"  Y={y}: before={pos_before} after={pos_after} dist={distance:.2f}m -> {status}")
    
    print("\n=== Summary ===")
    print("Y values with distance > 1m are walkable on engine terrain.")
    print("Visual platforms at non-walkable heights are NOT traversable.")

if __name__ == "__main__":
    main()
