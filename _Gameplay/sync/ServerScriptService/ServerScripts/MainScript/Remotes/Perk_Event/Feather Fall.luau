local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('BalancedLanding'))
local module = {}

function module:Activate(player, ...)
	local args = {...}
	local hasPerk, perkTier = Data_Module:GetPerk("BalancedLanding", player)
	
	if not hasPerk then return warn("Cheating") end
	if Code_Module:IsExhausted(player) then return warn("Currently Exhausted") end
	
	Code_Module:Exhaust(player, Perk_Module.Tiers[perkTier])
	Code_Module:SetEffect("Haste", player, {Perk_Module.Duration, Perk_Module.Speed_Boost}, "Feather_Fall")
end

return module
