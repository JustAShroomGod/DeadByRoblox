local Player = game.Players.LocalPlayer
local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData, playerData) -- used to get percentage we are at or value
	local Character = Player.Character
	local percent, stayOn = 0, 0
	
	if Character then
		
		if Character:GetAttribute("Perk_Silence") then
			local silenceTable = string.split(Character:GetAttribute("Perk_Silence"), ":") -- string math
			local TimeElapsed, TotalTime = workspace:GetServerTimeNow() - tonumber(silenceTable[2]), tonumber(silenceTable[1])
			
			percent = ((math.clamp(TimeElapsed, 0, TotalTime)/TotalTime) * 100)
		end
	end
	
	return percent, stayOn -- return filled bar by default | do not override lighting
end

return Perk_Progress
