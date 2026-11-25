"""Visibility calculator based on B's visibility law.

Law (from B's Day-3 revision):
  Camera: y ~ 79.59, pitch 18 degrees down, half FOV 22.5 degrees
  Ground object visible iff:
    d >= 5.2m  (closer = pushed out of top of frame)
    AND topY <= camY + d * 0.0787

Usage: python visibility_calc.py <distance_m> <object_top_y> [cam_y]
"""
import sys

def check_visibility(distance_m, object_top_y, cam_y=79.59):
    """Check if a ground object is visible at the given distance."""
    # Near limit: closer than 5.2m pushes object out of top of frame
    near_limit = 5.2
    
    # Height limit: topY <= camY + d * 0.0787
    max_top_y = cam_y + distance_m * 0.0787
    
    visible = distance_m >= near_limit and object_top_y <= max_top_y
    
    reasons = []
    if distance_m < near_limit:
        reasons.append(f"TOO CLOSE: d={distance_m:.1f}m < {near_limit}m (top of frame)")
    if object_top_y > max_top_y:
        reasons.append(f"TOO HIGH: topY={object_top_y:.2f} > max={max_top_y:.2f} (above horizon)")
    
    return {
        "visible": visible,
        "distance_m": distance_m,
        "object_top_y": object_top_y,
        "max_top_y": round(max_top_y, 2),
        "near_limit_m": near_limit,
        "reasons": reasons if reasons else ["OK"],
    }

def main():
    if len(sys.argv) < 3:
        print("Usage: python visibility_calc.py <distance_m> <object_top_y> [cam_y]")
        print()
        print("Visibility law (B's Day-3 finding):")
        print("  Camera y ~ 79.59, pitch 18 deg down, half FOV 22.5 deg")
        print("  Ground object visible iff:")
        print("    d >= 5.2m")
        print("    AND topY <= camY + d * 0.0787")
        print()
        print("Examples:")
        print("  python visibility_calc.py 6 79.99    # red cube at 6m -> VISIBLE")
        print("  python visibility_calc.py 3 79.5     # too close -> NOT VISIBLE")
        print("  python visibility_calc.py 10 81.5    # too high -> NOT VISIBLE")
        return
    
    d = float(sys.argv[1])
    top_y = float(sys.argv[2])
    cam_y = float(sys.argv[3]) if len(sys.argv) > 3 else 79.59
    
    result = check_visibility(d, top_y, cam_y)
    
    status = "VISIBLE" if result["visible"] else "NOT VISIBLE"
    print(f"Distance: {d}m, Object top Y: {top_y}, Camera Y: {cam_y}")
    print(f"Max allowed top Y at {d}m: {result['max_top_y']}")
    print(f"Result: {status}")
    for r in result["reasons"]:
        print(f"  - {r}")

if __name__ == "__main__":
    main()
