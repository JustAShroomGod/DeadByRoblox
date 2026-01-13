local Perk_Progress = {}
local perk_module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Power Swing'))
local data_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local Percent, override = 0, 0
	local _, powerTier = data_module:GetPerk("Power Swing")
	
	local timer = game.Players.LocalPlayer.Backpack.Scripts.PerksBase["Power Swing"]:GetAttribute("Timer")
	local cooldown = perk_module.Tiers[powerTier]
	
	local remaining_time = cooldown - timer
	Percent = (100 / cooldown) * remaining_time
	Percent = math.clamp(Percent, 0, 100)
	
	return Percent, override -- return filled bar by default | make it stay over-ride when active
end

return Perk_Progress
