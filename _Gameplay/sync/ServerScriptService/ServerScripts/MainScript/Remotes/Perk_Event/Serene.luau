local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Serene'))
local module = {}

function module:Activate(player, ...)
	local args = {...}
	local hasPerk, perkTier = Data_Module:GetPerk("Serene", player)
	
	if not hasPerk then return warn("Cheating") end

	Code_Module:SetEffect("Haste", player, {Perk_Module.Speed_Boost_Duration, Perk_Module.Speed_Boost}, "Serene")
end

return module
