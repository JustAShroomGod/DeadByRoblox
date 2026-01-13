local remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
local beginPlayer = remoteEvents:WaitForChild("BeginPlayer")

local teleportService = game:GetService("TeleportService")

function joinEvent(data)
	if data then
		local mode = data[1]
		beginPlayer:FireServer(mode)
	else
		beginPlayer:FireServer('Killer')
	end
end

task.wait(1)

joinEvent(teleportService:GetTeleportSetting("MatchmakingData"))
