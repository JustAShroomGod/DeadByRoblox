local Player = game:GetService("Players").LocalPlayer
local Backpack = Player.Backpack
local Scripts = Backpack:WaitForChild("Scripts")
local values = Scripts:WaitForChild("values")
local Hooked = values:WaitForChild("Hooked")

local Perk = Backpack:WaitForChild("Scripts"):WaitForChild("PerksBase"):WaitForChild("Rakish")
local isActive = Perk:WaitForChild("Active")

local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local Fill,stayOn = 100,2

	if isActive.Value or (Hooked.Value and not Player.Character:GetAttribute("Rakish")) then
		stayOn = 1
	end
	
	return Fill, stayOn -- return filled bar by default
end

return Perk_Progress
