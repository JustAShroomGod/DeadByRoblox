local Player = game.Players.LocalPlayer
local Backpack = Player.Backpack
local Perk = Backpack:WaitForChild("Scripts"):WaitForChild("PerksBase"):WaitForChild("DecisiveStrike")

local Perk_Module = require(game.ReplicatedStorage.Game_Data.Perks.Survivor.DecisiveStrike)

local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData, playerData) -- used to get percentage we are at or value
	local percent, stayOn = 100, 2
	local Character = Player.Character or Player.CharacterAdded:Wait()
	
	percent = 100 / Perk:GetAttribute("Duration") * Perk:GetAttribute("Timer")
	stayOn = if (Perk:GetAttribute("Available")) then 1 else 2
	
	return percent, stayOn -- return filled bar by default | do not override lighting
end

return Perk_Progress
