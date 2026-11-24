local r = {}
local ok, err = pcall(function()
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local function find(n)
    local hit=nil
    local function w(t,d) if d>12 or hit then return end local o=t.gameObject
      if o.name==n then hit=o return end
      for i=0,t.childCount-1 do w(t:GetChild(i),d+1) end end
    local rs=scene:GetRootGameObjects()
    for i=0,rs.Length-1 do local o=rs:get_Item(i); if o then w(o.transform,0) end; if hit then break end end
    return hit
  end
  -- reset to UNSOLVED: ramp hidden, rest visible
  local ramp = find("PAPER_RULER_RAMP")
  if ramp then ramp:SetActive(false) end
  local rest = find("PAPER_RULER_REST")
  if rest then rest:SetActive(true) end
  for k = 0, 6 do
    local t = find("PAPER_TICK_" .. k)
    if t then t:SetActive(false) end
  end
  -- put the player back on the left page
  local pl = find("Player_1")
  if pl then
    local p = pl.transform.position
    pl.transform.position = CS.UnityEngine.Vector3(p.x, p.y, 90.0)
    r.playerZ = "90.00"
  end
  r.state = "RESET_TO_UNSOLVED"
end)
if not ok then r.error = tostring(err) end
return r
