local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData, playerData) -- used to get percentage we are at or value
	
	local PerksBase = game.Players.LocalPlayer.Backpack.Scripts.PerksBase
	local Perk = PerksBase.Whispers
	
	local Fill = if (Perk:GetAttribute("isTracking")) then 100 else 0
	
	return Fill, 0 -- return filled bar by default | do not override lighting
end

return Perk_Progress
