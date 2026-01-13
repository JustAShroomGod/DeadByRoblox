local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local Percent, override = 0, 0
	local Tic_Attribute = game.Players.LocalPlayer.Character:GetAttribute("Tic_Tac")
	
	if Tic_Attribute then
		local Tic_Table = string.split(Tic_Attribute, ':')
		local TimeElapsed, TotalTime = tonumber(Tic_Table[2]), tonumber(Tic_Table[1])
		
		Percent = math.clamp(TimeElapsed, 0, TotalTime)/TotalTime * 100
	end
	
	return Percent, override -- return filled bar by default | make it stay over-ride when active
end

return Perk_Progress
