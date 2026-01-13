local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Cold Comfort'))
local Perk_Progress = {}
local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild("Data"))
function Perk_Progress:GetInfo(perkData, playerData) -- used to get percentage we are at or value
	local PerksBase = game.Players.LocalPlayer.Backpack.Scripts.PerksBase
	local Perk = PerksBase["Cold Comfort"]
	local EquippedColdComfort, TierComfort = Data_Module:GetPerk("Cold Comfort")

	local Percent = math.clamp((Perk:GetAttribute("Count") / Perk_Module.Tiers[TierComfort]) * 100 ,0,100)
	
	return Percent, 1
end

return Perk_Progress