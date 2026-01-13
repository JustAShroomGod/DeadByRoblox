local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RemoteStorage = ReplicatedStorage:WaitForChild('RemoteEvents')
local Folder = ReplicatedStorage:WaitForChild('Match')
local playerFolder = Folder:WaitForChild('Players')

local dataModule = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local remote = {
	lastSent = {};
}

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
			local command, survivor, validate = args[1], args[2], args[3]
			local Scripts = player:WaitForChild('Backpack'):WaitForChild('Scripts')
			local PerksBase, Values, IsKiller = Scripts:WaitForChild('PerksBase'), Scripts:WaitForChild('values'), Scripts:WaitForChild('Killer').Value

			if command == "Hit" and validate and IsKiller and Values.KillerAction.Value == "ChainsawAction" then -- is a killer and is chainsawing
				
				-- primary anti-cheat methods | time stamping | distance validation | and server time stamping --
				if (workspace:GetServerTimeNow() - validate[1]) >= 8 then return warn("Time stamp too far off!") end -- time validation 
				if (player.Character:GetPivot().Position - validate[2].Position).Magnitude >= 20 then return warn("Distance too far from sent distance!") end -- distance validation
				if remote.lastSent[player.Name] and (workspace:GetServerTimeNow() - remote.lastSent[player.Name]) <= 2 then return warn("Sent too many request too fast prolly cheating!") end

				remote.lastSent[player.Name] = workspace:GetServerTimeNow() -- server time stamp
				RemoteStorage:WaitForChild('Event'):Fire("Hit", player, survivor, "Chainsaw")
			end
		end)
	else
		warn('Remote does not exist:', script.Name)
	end

	return self
end

return remote.new()
