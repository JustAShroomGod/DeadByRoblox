local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('SaveTheBestForLast'))
local Perk_Progress = {}
local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild("Data"))
function Perk_Progress:GetInfo(perkData, playerData) -- used to get percentage we are at or value
	local PerksBase = game.Players.LocalPlayer.Backpack.Scripts.PerksBase
	local has, Tier = Data_Module.GetPerk("SaveTheBestForLast","SaveTheBestForLast")
	local Perk = PerksBase.SaveTheBestForLast
	script:SetAttribute("Stacks", Perk:GetAttribute("Stacks"))
	return 100, 1
end

return Perk_Progress