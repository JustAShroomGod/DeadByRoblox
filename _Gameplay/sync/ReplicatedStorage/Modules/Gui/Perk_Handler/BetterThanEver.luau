local Player = game:GetService("Players").LocalPlayer
local Backpack = Player.Backpack
local Perk = Backpack:WaitForChild("Scripts"):WaitForChild("PerksBase"):WaitForChild("BetterThanEver")

local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	
	local Duration = Perk:GetAttribute("Duration")
	
	local Fill,stayOn = 100,2

	if ((workspace:GetServerTimeNow() - Perk:GetAttribute("timestamp")) <= Duration) then
		stayOn = 1
		
		Fill = 100 / (Duration - (workspace:GetServerTimeNow() - Perk:GetAttribute("timestamp")))
		Fill = math.clamp(Fill, 0, 100)
	else
		Fill = 0
	end

	
	return Fill, stayOn -- return filled bar by default
end

return Perk_Progress
