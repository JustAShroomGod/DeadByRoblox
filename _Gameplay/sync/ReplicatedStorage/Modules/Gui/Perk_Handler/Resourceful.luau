local Player = game.Players.LocalPlayer

local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Resourceful'))
local data_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData, playerData) -- used to get percentage we are at or value
	local percent, stayOn = 0, 2
	local Character = Player.Character
	
	if Character then
		local Charges = Character:GetAttribute("Resourceful")
		
		if Charges then
			local HasPerk, PerkTier = data_module:GetPerk("Resourceful")
			
			percent = ((math.clamp(Charges, 0, Perk_Module.Tiers[PerkTier])/Perk_Module.Tiers[PerkTier]) * 100)
			
			
			if percent >= 100 then
				stayOn = 1
			else
				stayOn = 2
			end
		end
	end
	
	return percent, stayOn -- return filled bar by default | do not override lighting
end

return Perk_Progress
