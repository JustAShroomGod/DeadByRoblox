local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
local Data_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))

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
		
		connection.OnServerEvent:Connect(function(player, ...)
			local args = {...}
			local Catagory, PointAmount, Action, Other_Player = args[1], args[2], args[3], args[4]
			
			if not Action then
				Action = ""
			end
			
			if Other_Player and typeof(Other_Player) == 'Instance' then
				player = Other_Player
				
				if Action == "KILLER BLIND" then
					
				end
			end
			
			Data_Module:GiveBlood(player, PointAmount, Catagory, Action)
		end)
	else
		warn('Remote does not exist:', script.Name)
	end
	
	return self
end

return remote.new()
