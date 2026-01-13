local ServerScriptService = game:GetService("ServerScriptService")
local Data = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')


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
		connection.OnServerInvoke = function(Player,...)
			local args = {...}
			local Request = args[1]

			if Request == "PERFORMANCE_MODE" then
				local PlayerData = Data:GetRaw(Player, "Survivor")

				return PlayerData.Other.Settings.PERFORMANCE_MODE
			end
		end
	elseif script.Name ~= "Template" then
		warn('Remote does not exist:', script.Name)
	end
	
	return self
end

return remote--.new()
