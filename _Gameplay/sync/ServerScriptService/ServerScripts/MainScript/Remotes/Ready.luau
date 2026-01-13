local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RemoteStorage = ReplicatedStorage:WaitForChild('RemoteEvents')
local Folder = ReplicatedStorage:WaitForChild('Match')
local playerFolder = Folder:WaitForChild('Players')

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

		connection.OnServerEvent:Connect(function(player, mode)
			
			if player:GetAttribute("READY") then
				player:SetAttribute("READY", false)
			else
				player:SetAttribute("READY", true)
			end
		end)
	else
		warn('Remote does not exist:', script.Name)
	end

	return self
end

return remote.new()
