local Perk_Progress = {}

local data_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local wardenAttribute, TimeLeft = workspace:GetAttribute("No_Escape"), 0
	local override = 0
	
	if wardenAttribute then
		local rigTable = string.split(wardenAttribute, ":")
		local TimeElapsed, TotalTime = workspace:GetServerTimeNow() - tonumber(rigTable[2]), tonumber(rigTable[1])
		
		TimeLeft = 100 - ((math.clamp(TimeElapsed, 0, TotalTime)/TotalTime) * 100)
	end
	
	if TimeLeft > 0 then
		override = 1
	end
	
	return TimeLeft, override -- return filled bar by default | make it stay over-ride when active
end

return Perk_Progress
