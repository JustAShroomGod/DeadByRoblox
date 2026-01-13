local Player, ReplicatedStorage = game.Players.LocalPlayer, game:GetService('ReplicatedStorage')

local Bug = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents'):WaitForChild('BUGREAD')
local Script_Replication = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('SERVER_CLIENT')

local Ping = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Ping'))

Script_Replication.OnClientEvent:Connect(function(Folder)
	
	for _,s in pairs(Folder:GetChildren()) do
		local newScript = s:Clone()
		newScript.Parent = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
		newScript.Disabled = false
	end
end)

Bug.OnClientEvent:Connect(function(...)
	local args = {...}
	
	for _,statement in pairs(args) do
		print(statement)
	end
end)

