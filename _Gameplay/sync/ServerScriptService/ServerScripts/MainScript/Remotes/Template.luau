local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
local Game_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data')

local Modules = {
	Data = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'));
	Code = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'));
}

local remote = {}

local function GrabRemote()
	
	for _,r in pairs(RemoteStorage:GetChildren())do
		
		if string.lower(r.Name) == string.lower(script.Name) then
			return r
		end
	end
	
	return false
end

function remote.new()
	local self = {}
	setmetatable(self, remote)
	
	local connection = GrabRemote()
	
	if connection then
		
		connection.OnServerEvent:Connect(function(player)
			
		end)
	elseif script.Name ~= "Template" then
		warn('Remote does not exist:', script.Name)
	end
	
	return self
end

return remote.new()
