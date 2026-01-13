local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('EmpoweringStrength'))
local Perk_Progress = {}
local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild("Data"))

function Perk_Progress:GetInfo(perkData, playerData) -- used to get percentage we are at or value
	local PerksBase = game.Players.LocalPlayer.Backpack.Scripts.PerksBase
	local Perk = PerksBase.EmpoweringStrength
	
	local token = Perk:GetAttribute("Token")
	script:SetAttribute("Stacks", token)
	
	return 100, 1
end

return Perk_Progress