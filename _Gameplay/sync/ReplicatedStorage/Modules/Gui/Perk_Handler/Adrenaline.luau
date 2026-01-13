local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("StunningEncore"))

local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData, playerData) -- used to get percentage we are at or value
	local PerksBase = game.Players.LocalPlayer.Backpack.Scripts.PerksBase
	local Perk = PerksBase.Adrenaline

	local Percent = if (Perk:GetAttribute("Available")) then 100 else 0
	local override = if (Perk:GetAttribute("Available")) then 1 else 0

	return Percent, override
end

return Perk_Progress
