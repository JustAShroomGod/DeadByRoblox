local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("StunningEncore"))

local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData, playerData) -- used to get percentage we are at or value
	local PerksBase = game.Players.LocalPlayer.Backpack.Scripts.PerksBase
	local Perk = PerksBase.StunningEncore

	local Time, Max = Perk:GetAttribute("Cooldown"), Perk_Module.Cooldown
	local Percent = (100 / Max) * (Max - Time)
	Percent = math.clamp(Percent, 0, 100)
	
	local override = if (Percent >= 100) then 1 else 0

	return Percent, override
end

return Perk_Progress
