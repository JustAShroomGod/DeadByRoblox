local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
local remote = {}
local perk_modules = {}

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
		
		for _, mod in pairs(script:GetChildren()) do
			perk_modules[mod.Name] = require(mod)
		end
		
		connection.OnServerEvent:Connect(function(player, ...)
			local args = {...}
			
			if perk_modules[args[1]] then
				perk_modules[args[1]]:Activate(player, ...)
			else
				warn(args[1], 'does not exist as sub-module!')
			end
		end)
	elseif script.Name ~= "Template" then
		warn('Remote does not exist:', script.Name)
	end
	
	return self
end

return remote.new()
