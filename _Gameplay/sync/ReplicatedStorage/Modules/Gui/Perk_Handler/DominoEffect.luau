local Player = game:GetService("Players").LocalPlayer
local Backpack = Player.Backpack
local Perk = Backpack:WaitForChild("Scripts"):WaitForChild("PerksBase"):WaitForChild("DominoEffect")
local Timer = Perk:GetAttribute("Timer")
local MaxTimer = Perk:GetAttribute("MaxTimer")

local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local Fill,stayOn = 100,1

	Fill = (Timer / MaxTimer) * 100
	
	if Fill <= 0 then
		stayOn = 2
		Fill = 0
	end
	
	return Fill, stayOn -- return filled bar by default
end

return Perk_Progress
