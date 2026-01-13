local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Shattered Momentum'))
local Perk_Progress = {}
local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild("Data"))
function Perk_Progress:GetInfo(perkData, playerData) -- used to get percentage we are at or value
	local PerksBase = game.Players.LocalPlayer.Backpack.Scripts.PerksBase
	local Perk = PerksBase["Shattered Momentum"]
	
	script:SetAttribute("Stacks", Perk:GetAttribute("Count"))
	
	return 100, 1
end

return Perk_Progress