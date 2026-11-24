import json, io

lua = io.open(r'D:\competition\desk_proximity.lua', encoding='utf-8').read()

js = (
    '// Create the proximity script via SDK so headers are generated correctly,\n'
    '// then bind it to a dedicated ruler node in one transaction.\n'
    'const lua = ' + json.dumps(lua) + ';\n'
    'const {handle: scriptHandle, filePath} = await scene.scripts.create('
    '{path:"desk-proximity.lua", content: lua});\n'
    'const ruler = await scene.nodes.create('
    '{parent:"n1", name:"desk-ruler-rest", components:{}});\n'
    'const bound = await scene.scripts.bind({\n'
    '  nodes:[ruler.handle],\n'
    '  script:scriptHandle,\n'
    '  params:{TriggerZ:92.0, TriggerRadius:3.0}\n'
    '});\n'
    'return {scriptHandle, filePath, ruler:ruler.handle, bindings:bound};\n'
)

io.open(r'D:\competition\js-create-bind.js', 'w', encoding='utf-8').write(js)
print('js bytes:', len(js.encode('utf-8')))
print(js[:300])
