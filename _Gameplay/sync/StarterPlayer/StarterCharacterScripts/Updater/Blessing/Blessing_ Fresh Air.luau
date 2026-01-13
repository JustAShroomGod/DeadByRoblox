local Base_Perk = require(game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Blessing: Fresh Air'))

local Code_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Code'))

local Effect = {}

function Effect:Activate(Character, Tier)
	Code_Module:SetEffect("Rejuvenation", game.Players:FindFirstChild(Character.Name), {-1, Base_Perk.Tiers[Tier]}, "Fresh_Air")
end

function Effect:Deactivate(Character)
	Code_Module:SetEffect("Rejuvenation", game.Players:FindFirstChild(Character.Name), nil, "Fresh_Air")
end

return Effect
