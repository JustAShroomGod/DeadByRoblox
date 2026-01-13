local ModuleStorage = game:GetService('ReplicatedStorage'):WaitForChild('Modules')
local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('QuickFix'))

local remote = {}

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
		
		connection.OnServerEvent:Connect(function(Player : Player, ...) -- recieves player, adding/removing, killerfolder, beamer
			local args = {...}
			local Character = Player.Character
			local Scripts = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
			local QF = Scripts:WaitForChild('PerksBase'):WaitForChild('QuickFix')
			local tool = args[1]
			
			local HasFix, FixTier = require(ModuleStorage:WaitForChild('Data')):GetPerk("QuickFix", Player)
			
			if HasFix and tool and not tool:GetAttribute("QuickFixed") and tool.Parent == Character and tonumber(QF.Charge.Value) >= 100 then
				QF.Charge.Value = 0
				tool:SetAttribute("QuickFixed", true)
				tool:SetAttribute("Progress", math.clamp(Perk_Module.Tiers[FixTier] * 10 + tool:GetAttribute("Progress"), 0, 1000))
			end
		end)
	else
		warn('Remote does not exist:', script.Name)
	end

	return self
end

return remote.new()
