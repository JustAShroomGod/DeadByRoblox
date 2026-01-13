local remoteEvents = game.ReplicatedStorage:WaitForChild("-LockerAuras")
local remoteEvent = remoteEvents:WaitForChild("HuntressPowerAction")
local hitplayer = require(script.Parent.Parent:WaitForChild("ServerScripts"):WaitForChild("MainScript"):WaitForChild("Remotes"):WaitForChild("Server_Event"):WaitForChild("Modules"):WaitForChild("HitPlayer"))

remoteEvent.OnServerEvent:Connect(function(plr, ...)
	remoteEvent:FireAllClients(...)
end)

remoteEvents:WaitForChild("Hatchet_Event").OnServerEvent:Connect(function(p,s)
	hitplayer:Fire(0,p,s,"Hatchet")
end)