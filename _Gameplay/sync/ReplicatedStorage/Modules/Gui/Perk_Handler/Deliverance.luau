local Player = game:GetService("Players").LocalPlayer
local Backpack = Player.Backpack
local Perk = Backpack:WaitForChild("Scripts"):WaitForChild("PerksBase"):WaitForChild("Deliverance")
local isActive = Perk:WaitForChild("Active")

local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local Fill,stayOn = 100,2

	if isActive.Value then
		stayOn = 1
	end
	
	return Fill, stayOn -- return filled bar by default
end

return Perk_Progress
