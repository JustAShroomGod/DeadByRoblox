local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData, playerData) -- used to get percentage we are at or value
	local PerksBase = game.Players.LocalPlayer.Backpack.Scripts.PerksBase
	local Perk = PerksBase.WellMakeIt

	local Time, Max = Perk:GetAttribute("Timer"), Perk:GetAttribute("MaxCooldown")
	local Percent = (100 / Max) * Time
	Percent = math.clamp(Percent, 0, 100)
	local override = if (Percent > 0) then 1 else 0

	return Percent, 1
end

return Perk_Progress
