local Perk_Progress = {}
local Totems = {}

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local PerksBase = game.Players.LocalPlayer.Backpack.Scripts.PerksBase
	local Perk = PerksBase["Curse: Resurrection"]
	
	local progress = if (Perk:GetAttribute("Active")) then 100 else 0
	local override = if (Perk:GetAttribute("Active")) then 1 else 0
	
	return progress, override -- return percentage or percentage.Value (pretty sure returning raw value would still work, but would make a lot and I mean a lot of connetions taht could be problematic.)
end

return Perk_Progress
