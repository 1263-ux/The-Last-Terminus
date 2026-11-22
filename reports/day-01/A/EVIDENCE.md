# reports/day-01/A/EVIDENCE.md

> 鎵€鏈?PASS 閮藉彲鍦ㄦ湰鏈虹敤涓嬪垪鍛戒护澶嶇幇銆傜紪杈戝櫒鐗堟湰 **1.0.104**锛孋LI `douyin-world 1.0.104`銆?> 璇佹嵁鏂囦欢鐩稿璺緞鍩哄潃锛歚reports/day-01/A/evidence/`

---

## 0. 鐜浜嬪疄

| 椤?| 鍊?|
|---|---|
| 缂栬緫鍣?| 閫犱笘鐣岀紪杈戝櫒 1.0.104锛宍D:\WOW-LAND\閫犱笘鐣岀紪杈戝櫒\閫犱笘鐣岀紪杈戝櫒.exe` |
| CLI | `C:\Users\zjx\.local\bin\douyin-world.cmd` |
| 椤圭洰 | `TrainCore_A` 鈫?`...\projects\project-fb583637-ca72-4350-8ff2-e6066aa03481` |
| 瀹炰緥 | 澶氭閲嶅缓锛涘叧閿竴娆?`awc-80e60d75-...` / `awc-085842da-...` |
| 璐﹀彿 | 宸茬櫥褰曪紙`config.json` 涓?uid `7514250895997486139`锛?|
| 灞忓箷/Mode | `offscreen` |

---

## 1. Git 璇佹嵁

```powershell
git clone https://ghfast.top/https://github.com/1263-ux/The-Last-Terminus.git D:\zjx\projects\The-Last-Terminus
cd D:\zjx\projects\The-Last-Terminus
git log --oneline -1          # d6361a3 docs: add A/B/C role-specific startup prompts
git checkout -b feature/train-core origin/main
git push -u origin feature/train-core --dry-run   # 鈫?FAIL锛氭棤鍑嵁
```

闀滃儚鍙敤鎬ф帰娴嬶紙鍚屾浼氳瘽锛夛細

| 闀滃儚 | `info/refs` 缁撴灉 |
|---|---|
| `ghfast.top` | **200**锛?792 B锛?|
| `gh-proxy.net` | 200锛?084 B锛?|
| `gh-proxy.com` | 200锛堢綉椤碉級锛屼絾 git 鍗忚 403 |
| `kkgithub.com` / `bgithub.xyz` / `gitclone.com` / `moyy` | 瓒呮椂 |

---

## 2. Probe 01 璇佹嵁

```powershell
# 淇濆瓨锛堝繀椤诲厛鍋滈瑙堬級
douyin-world runtime stop --instance <I>
douyin-world scene save --instance <I> --request-id p01-save-2
# 鈫?{"status":"committed","hasUnsavedChanges":false}
```

| 鏂囦欢 | 璇存槑 |
|---|---|
| `P01-01-initial-scene.png` | 鏂板缓椤圭洰鍒濆鍦烘櫙锛?133脳1142锛?|
| `P01-02-reopened-scene.png` | 鍏抽棴瀹炰緥鍚庨噸寮€鐨勫悓涓€鍦烘櫙 |
| `P01-scene-before-close.data` | 鍏抽棴鍓?`scene.data` 蹇収锛?79578 B锛?|

`scene.data` 瀛楄妭鍙樺寲锛歚758476 鈫?779578`锛堜繚瀛樺悗锛夛紱鍏抽棴鍚庢湭鍥為€€銆?
瑙ｅ寘鍛戒护锛堝彧璇伙級锛?
```powershell
Add-Type -AssemblyName System.IO.Compression.FileSystem
$z=[System.IO.Compression.ZipFile]::OpenRead("<projectRoot>\scene.data")
$z.Entries | Select FullName,Length
```

缁撴灉锛歚HeightMap_*.data` / `SplatMap_*_0.png` / `SplatMap_*_1.png` / `MatCoverTex_*.png` / `SerializePcgData.json`

---

## 3. Probe 02 璇佹嵁锛圙LB锛?
鐢熸垚鎺㈤拡璧勪骇锛堝彲閲嶆斁锛夛細

```powershell
& <python> D:\zjx\projects\probe-assets\make_glb.py     # 3 涓?GLB
& <python> D:\zjx\projects\probe-assets\make_axes.py    # 杞村悜娴嬭瘯 GLB
```

瀵煎叆锛?
```powershell
douyin-world authoring resource inspect .\out\probe-textured-cube.glb --instance <I>
# 鈫?銆岃祫浜у鍏ラ檺鍒?30000 闈?/ 10485760 瀛楄妭銆嶏紝min/max 卤0.5

douyin-world authoring resource model import model-probe-cube --prefab probeA --workspace-id <W> --glb .\out\probe-textured-cube.glb
douyin-world authoring resource model check model-probe-cube --prefab probeA --workspace-id <W>
douyin-world authoring resource archive model-probe-cube --kind model --prefab probeA --workspace-id <W>
douyin-world authoring prefab attach probeA --workspace-id <W> --kind model --uri <uri>
douyin-world authoring prefab build probeA --workspace-id <W>
douyin-world authoring result archive probeA --workspace-id <W> --name "A鎺㈤拡_GLB鍥涗欢濂?
douyin-world scene import --instance <I> --uri <wprefab-uri> --request-id <id>
```

璇诲洖锛圫cene SDK锛夛細

```powershell
douyin-world authoring prefab execute probeA --file readback.js --workspace-id <W> --json
```

| 鏂囦欢 | 鍐呭 |
|---|---|
| `P02-02-glb-object-closeup.png` | 璐村浘绔嬫柟浣撶壒鍐欙紙妫嬬洏 + 绾㈣鏍囷級 |
| `P02-03-four-probes.png` | 鍥涗欢濂楀悎浣擄紙灞傜骇/閫忔槑/鍔ㄧ敾/璐村浘锛?|
| `P02-04-transparent.png` | 鍗婇€忔槑闈㈡澘 |
| `P02-glb-property-readback.json` | 鍏ㄨ妭鐐?transform + 缁勪欢璇诲洖 |
| `P02-axis-readback.json` | 鈽?X 杞撮暅鍍忕洿鎺ヨ瘉鎹?|
| `P02-05-axis-test-front.png` / `P02-06-axis-test-side.png` | 杞村悜鍙鍖?|

`P02-axis-readback.json` 鍏抽敭鍐呭锛?
```json
[{"handle":"n8","name":"AxisTestPx","localPosition":{"x":-2,"y":0,"z":0}},
 {"handle":"n9","name":"AxisTestNx","localPosition":{"x":2,"y":0,"z":0}},
 {"handle":"n10","name":"AxisTestPz","localPosition":{"x":0,"y":0,"z":2}},
 {"handle":"n11","name":"AxisTestNz","localPosition":{"x":0,"y":0,"z":-2}}]
```

---

## 4. Probe 03 璇佹嵁锛圵PRE锛?
```powershell
douyin-world authoring prefab export probeA --workspace-id <W> --out D:\zjx\projects\wpre-handoff
# 鈫?probeA.wprefab 21244 B, sha256 46ca197c...

douyin-world authoring resource inspect D:\zjx\projects\wpre-handoff\probeA.wprefab --instance <I>
# 鈫?銆屾ā鍨嬭妭鐐?12 路 鑴氭湰 9 路 缁戝畾 0 路 瀹為檯渚濊禆 5 路 浣滆€呮潯鐩?1銆?```

瑙ｅ寘锛?
```powershell
[System.IO.Compression.ZipFile]::ExtractToDirectory("probeA.wprefab","unpacked")
Get-Content unpacked\asset-metadata.json
# {"schemaVersion":1,"capacity":2556,"faceCount":132,"logicalCenter":[...],"rigged":false}
```

`SerializePcgData.json`锛歚resourceRefs` = **绌烘暟缁?*锛?鑺傜偣褰㈠ `{"id":8,"basic":{...},"physics":{...},"resource":{"glbSliceData":{"sourceUri":"hamlet-ugc/...glb","slicePath":[0]}}}`銆?
---

## 5. Probe 05 璇佹嵁锛堜笘鐣岃繛鎺ワ級

### 5.1 鏋勫缓 Anchor

```powershell
douyin-world authoring prefab execute probeA --file build_anchors.js --workspace-id <W> --json
# 鈫?{"anchorA":"n14","anchorB":"n15", ...}
douyin-world authoring prefab execute probeA --file fix_trigger.js --workspace-id <W> --json
# 鈫?trigger {"center":{"x":0,"y":0.5,"z":0},"size":{"x":3,"y":4,"z":3}}
douyin-world authoring prefab execute probeA --file fix_params.js --workspace-id <W> --json
# 鈫?bindings n14:s:<scriptId> TargetX=119.74 TargetZ=103
#            n15:s:<scriptId> TargetX=119.74 TargetZ=86
```

`fix_params.js` 璇诲洖锛坄P05-fix-params.json`锛夛細

```json
{"bindA":"n14:s:fc4dd815-...","bindB":"n15:s:fc4dd815-...",
 "bindings":{"items":[
   {"handle":"n14:s:fc4dd815-...","params":{"TargetX":119.74,"TargetY":79.2,"TargetZ":103,"TargetYaw":180,"CooldownSeconds":2}},
   {"handle":"n15:s:fc4dd815-...","params":{"TargetX":119.74,"TargetY":79.2,"TargetZ":86,"TargetYaw":0,"CooldownSeconds":2}}]}}
```

### 5.2 杩愯鏃堕獙璇?
```powershell
douyin-world runtime lua targets --instance <I> --runtime-id <R>
# 鈫?涓ゆ潯锛?22884:fc4dd8... @.../Anchor_A_to_B ; -22894:fc4dd8... @.../Anchor_B_to_A

douyin-world runtime lua eval --file read_params.lua --instance <I> --runtime-id <R> --binding=<A>
# 鈫?"20.0|1.0|0.0|90.0"   锛堟棭鏈熺増鏈紝璇佹槑鍙傛暟鎸夎妭鐐归殧绂伙級
```

**鐪熷疄杈撳叆瑙﹀彂**锛?
```powershell
douyin-world runtime lua eval --file player_pos.lua --instance <I> --runtime-id <R> --global
# before 鈫?"119.74166870117|77.905349731445|88.640609741211"

douyin-world runtime input keys "W:3000" --instance <I> --runtime-id <R>

douyin-world runtime lua eval --file player_pos.lua --instance <I> --runtime-id <R> --global
# after  鈫?"20.000556945801|-30.228441238403|0.67697632312775"
```

x 鐢?**119.74 鈫?20.00**锛屽彧鍙兘鏉ヨ嚜 anchor 鑴氭湰鐨?`Teleport`銆?
**纰版挒浣撶‘璁?*锛堜慨姝?PuerTS 绫诲瀷杞崲鍚庯級锛?
```powershell
douyin-world runtime js eval --file check_collider2.js --instance <I> --runtime-id <R>
```

`P05-collider-recheck.json`锛?
```json
[{"name":"Anchor_A_to_B","hasCollider":true,"colliderType":"BoxCollider","isTrigger":true},
 {"name":"Anchor_B_to_A","hasCollider":true,"colliderType":"BoxCollider","isTrigger":true},
 {"name":"AxisTestPx","hasCollider":true,"colliderType":"MeshCollider","isTrigger":false}]
```

**鍑犱綍瀵圭収**锛堣瘉鏄庣 5.3 鑺傜殑鍧戯級锛?
```powershell
douyin-world runtime lua eval --file anchor_geometry.lua --instance <I> --runtime-id <R> --global
# 淇鍓嶏細 player=119.74,77.91,88.64 | colliderCenter=119.74,79.90,90.64 | size=2,2,2
#          鈫?涓績楂樹簬鐜╁ 2m锛屾案涓嶉噸鍙?# 淇鍚庯細 player=119.74,77.91,88.64 | colliderCenter=119.74,79.40,90.64 | size=3,4,3
#          鈫?璺ㄥ害 77.4鈥?1.4锛岃鐩栫帺瀹?```

**鏃犺皟璇曟畫鐣?*锛?
```powershell
douyin-world runtime verifyNoTempHooks --instance <I>
# 鈫?{"ok":true,"residues":[]}
```

---

## 6. Probe 06 璇佹嵁锛堣法宸ョ▼浜ゆ帴锛?
```powershell
# 1. 鏂板缓瀹屽叏鐙珛鐨勭浜屼釜宸ョ▼
douyin-world project create Handoff_Test
# 鈫?project-eda6f596-6339-4938-845f-dd7b65d6923e

# 2. 鍏堝仠鎺夌涓€涓伐绋嬬殑瀹炰緥锛屽啀鍚姩绗簩涓?douyin-world instance start --project "...\project-eda6f596-..." --mode offscreen
# 鈫?instanceId awc-9229c855-e0c6-4a18-9df6-3c0a06a54aa1

# 3. 瀵煎叆 A 宸ョ▼褰掓。鐨勫悓涓€ .wprefab URI
douyin-world scene import --instance <I2> --uri "hamlet-ugc/.../py3su7iecjmhlfah.wprefab" `
  --name "璺ㄥ伐绋嬩氦鎺閿氱偣" --request-id p06-import-1
# 鈫?{"status":"committed","rootIDs":["201049467"]}

# 4. 淇濆瓨骞舵覆鏌?douyin-world scene save --instance <I2> --request-id p06-save-1
douyin-world runtime start --instance <I2>
douyin-world runtime screenshot --instance <I2> --runtime-id <R2> --out P06-01-cross-project-render.png

# 5. 楠岃瘉鑴氭湰涓庡弬鏁?douyin-world runtime lua targets --instance <I2> --runtime-id <R2>
# 鈫?-2076:fc4dd815-... @.../Anchor_A_to_B
#   -2090:fc4dd815-... @.../Anchor_B_to_A

douyin-world runtime lua eval --file read_params.lua --instance <I2> --runtime-id <R2> `
  --binding=-2076:fc4dd815-40f2-4300-944e-63660930fcb4
# 鈫?"20.0|1.0|0.0|90.0"

douyin-world runtime lua eval --file invoke_anchor.lua --instance <I2> --runtime-id <R2> `
  --binding=-2076:fc4dd815-40f2-4300-944e-63660930fcb4
# 鈫?before=119.74,77.91,88.64 after=20.00,1.00,0.00
```

| 鏂囦欢 | 鍐呭 |
|---|---|
| `P06-cross-project-import.json` | 瀵煎叆鍥炴墽锛坮ootIDs锛?|
| `P06-cross-project-tree.json` | 绗簩宸ョ▼瀹屾暣杩愯鏃跺眰绾?|
| `P06-01-cross-project-render.png` | 绗簩宸ョ▼娓叉煋缁撴灉 |
| `P06-collider-recheck.json` | 璺ㄥ伐绋嬬鎾炰綋璇诲洖 |
| `P06-param-a.txt` | 璺ㄥ伐绋嬪弬鏁拌鍥?|
| `P06-invoke-a.txt` | 璺ㄥ伐绋嬩紶閫佸疄娴?|

---

## 7. 璇佹嵁鏂囦欢绱㈠紩

| 鍒嗙粍 | 鏂囦欢 |
|---|---|
| P01 | `P01-01-initial-scene.png`, `P01-02-reopened-scene.png`, `P01-scene-before-close.data` |
| P02 | `P02-01..06*.png`, `P02-glb-property-readback.json`, `P02-axis-readback.json`, `P02-nodes.json`, `P02-snapshot.json`, `P02b/P02c-snapshot.json` |
| P03 | `P03-wpre-inspect.txt`锛? 澶栭儴 `D:\zjx\projects\wpre-handoff\`锛?|
| P06 | `P06-cross-project-import.json`, `P06-cross-project-tree.json`, `P06-01-cross-project-render.png`, `P06-collider-recheck.json`, `P06-param-a.txt`, `P06-invoke-a.txt` |
| P05 | `P05-01..04*.png`, `P05-trigger-schema.json`, `P05-builtins.json`, `P05-anchors-build.json`, `P05-fix-trigger.json`, `P05-fix-params.json`, `P05-collider-recheck.json`, `P05-param-readback-a/b.txt`, `P05-invoke-anchor-a/b.txt`, `P05-runtime-logs.json`, `P05-full-tree.json` |

---

## 7. 鏈噰鐢ㄤ负璇佹嵁鐨勫唴瀹?
- **缃戠粶椤甸潰**锛氫粎鐢ㄤ簬鍙傝€冪爺绌讹紝鏈綔涓轰换浣曟妧鏈?PASS 鐨勪緷鎹€?- **`DouyinWorldPortal`**锛氫粎纭绫诲瀷瀛樺湪锛?*鏈獙璇?*鍏堕厤缃笌璺ㄥ満鏅涔?鈫?璁颁负 NOT TESTED銆?- **GLB 鏉愯川鏁板€?*锛坆aseColor/roughness锛夛細缂栬緫鍣ㄦ湭鏆撮湶鐙珛瀛楁锛屽彧瑙傚療鍒版覆鏌撳瑙傛纭紝
  涓嶅０绉?鏁板€艰瀹屾暣淇濈暀"銆?
