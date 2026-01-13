local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
local remote = {
	['AddDebounce'] = false
}

local function GrabRemote()

	for _,r in pairs(RemoteStorage:GetChildren())do

		if string.lower(r.Name) == string.lower(script.Name) then
			return r
		end
	end

	return false
end

function checkForMatch(playerValue, Folder)
	for _,object in pairs(Folder:GetChildren())do
		if object.Value == playerValue then
			return object
		end
	end

	return nil
end

function remote.new()
	local self = {}
	setmetatable(self, remote)

	local connection = GrabRemote()

	if connection then
		
		connection.OnServerEvent:Connect(function(sender, ...) -- recieves player, adding/removing, killerfolder, beamer
			local Client_Remote = RemoteStorage:WaitForChild('Flashlight_Client')
			
			for _,player in pairs(game:GetService('Players'):GetPlayers()) do
				if player == sender then continue end
				Client_Remote:FireClient(player, ...)
			end
		end)
	else
		warn('Remote does not exist:', script.Name)
	end

	return self
end

return remote.new()
