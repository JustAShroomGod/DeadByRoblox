local Code = require(script.Parent.Parent.Parent:WaitForChild("Code"))

local Player = game:GetService("Players").LocalPlayer
local Backpack = Player.Backpack
local Perk = Backpack:WaitForChild("Scripts"):WaitForChild("PerksBase"):WaitForChild("Unbreakable")
local isUsed = Perk:WaitForChild("Used")

local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local Fill,stayOn = 100,2

	if not isUsed.Value then
		if Code:IsDown(Player) then
			stayOn = 1
		end
	else
		Fill = 0
	end

	
	return Fill, stayOn -- return filled bar by default
end

return Perk_Progress
