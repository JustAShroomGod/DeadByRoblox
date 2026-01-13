local Perk_Progress = {}

local data_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local _, PerkTier = data_module:GetPerk("Fearless")
	local exhaustion = game.Players.LocalPlayer.Character:GetAttribute("Exhaustion")
	local TimeLeft = 0
	
	
	if exhaustion then
		exhaustion = string.split(exhaustion, ':')
		TimeLeft = tonumber(exhaustion[1]/tonumber(exhaustion[2]))
	else
		TimeLeft = 100
	end

	
	return TimeLeft, 0 -- return filled bar by default
end

return Perk_Progress
