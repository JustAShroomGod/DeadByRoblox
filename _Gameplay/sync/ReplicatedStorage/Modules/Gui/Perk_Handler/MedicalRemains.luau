local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData, playerData) -- used to get percentage we are at or value
	local PerksBase = game.Players.LocalPlayer.Backpack.Scripts.PerksBase
	local Perk = PerksBase.MedicalRemains
	
	local Max = Perk:GetAttribute("MaxProgress")
	local Fill = (100 / Max) * Perk:GetAttribute("Progress")
	
	return Fill, 1 -- return filled bar by default | override lighting
end

return Perk_Progress
