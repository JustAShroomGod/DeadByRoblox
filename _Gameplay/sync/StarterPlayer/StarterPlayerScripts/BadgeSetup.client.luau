local ts = game:GetService("TeleportService")
local data = ts:GetLocalPlayerTeleportData()

local remote = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Solo")

if data then
	remote:FireServer(data)
end