local Code = require(script.Parent.Parent.Parent:WaitForChild("Code"))

local Player = game:GetService("Players").LocalPlayer

local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local Fill,stayOn = 100,2

	if Code:IsInjured(Player) then
		stayOn = 1
	else
		Fill = 0
	end


	return Fill, stayOn -- return filled bar by default
end

return Perk_Progress