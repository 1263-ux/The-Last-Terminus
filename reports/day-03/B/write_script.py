import io

path = r'C:\Users\XiongCong\AppData\Roaming\AI World Creator\projects\project-2ab3d89a-6b01-49d6-8170-eb9dcc2152e6\ai-sessions\workspace_deskworld\wprefabs\deskworld\scripts\desk-proximity.lua'

# Preserve the SDK-generated headers exactly.
head = (
    '---@id aae47e30-ec23-4690-8e97-24bb552b9a55\n'
    '---@referenceName desk-proximity.lua\n'
)

body = io.open(r'D:\competition\desk_proximity.lua', encoding='utf-8').read()

io.open(path, 'w', encoding='utf-8').write(head + body)
print('written', len((head + body).encode('utf-8')), 'bytes')
print(io.open(path, encoding='utf-8').readline().strip())
