local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Cryo Retaliation'))
local Perk_Progress = {}
local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild("Data"))

function Perk_Progress:GetInfo(perkData, playerData) -- used to get percentage we are at or value
	local PerksBase = game.Players.LocalPlayer.Backpack.Scripts.PerksBase
	local Perk = PerksBase["Cryo Retaliation"]

	local Percent = math.clamp((((workspace:GetServerTimeNow() - Perk:GetAttribute("timestamp")) / Perk_Module.Cooldown)) * 100, 0, 100)

	return Percent, 1
end

return Perk_Progress