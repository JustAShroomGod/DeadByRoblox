local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
local TweenService = game:GetService('TweenService')

local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Moris = {}
local remote = {}

-- getting moris --
for _, mori in pairs(script:WaitForChild('Moris'):GetChildren()) do
	if not mori:IsA('ModuleScript') then continue end
	Moris[mori.Name] = require(mori)
end

function GrabRemote()

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
			local Backpack = player:WaitForChild('Backpack'):WaitForChild('Scripts')
			local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')
			local Offering = Data_Module:GetOffering('Killer', player)

			if workspace:GetAttribute(player.Name .. '_Mori') and Offering ~= "Ultra Death Card" then
				return warn('Already Moried')
			end

			if not workspace:GetAttribute("TESTING") then

				if Offering ~= "Death Card" and Offering ~= "Ultra Death Card" then
					player:Kick('Exploits')
					return error('Cheats')
				end
			end
			
			if args[1] == "HillBilly_Mori_1" then -- if hillbilly mori and this mori has not been performed this game
				
				if Moris['Hillbilly'] then
					Moris.Hillbilly:Mori(player, args[2], Offering)
				end
			elseif args[1] == 'Architect_Mori' then
				
				if Moris['Architect'] then
					Moris.Architect:Mori(player, args[2], Offering)
				end
			elseif args[1] == "Ninja_Mori_1" then

				if Moris['Ninja'] then
					Moris.Ninja:Mori(player, args[2])
				end
			elseif args[1] == "Self_Mori" then
				
				if Moris['Survivor'] then
					Moris.Survivor:Mori(player, args[2])
				end
			end
		end)
	elseif script.Name ~= "Template" then
		warn('Remote does not exist:', script.Name)
	end

	return self
end

return remote.new()
