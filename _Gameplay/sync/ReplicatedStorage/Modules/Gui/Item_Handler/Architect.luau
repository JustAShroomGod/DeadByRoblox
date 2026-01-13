local Killer_File = require(game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild(script.Name))
local PowerClass = {}

function PowerClass:GetInfo(rawItem)
	local Percentage, Count = -1, 0
	local hasRage = game.Players.LocalPlayer.Character:GetAttribute("Power")

	if hasRage then
		hasRage = string.split(hasRage, ':')
		Percentage = tonumber(hasRage[1])/tonumber(hasRage[2]) * 100
	else
		Percentage = -1
	end
	
	return Percentage, Count, Killer_File.Power_Image, Killer_File.Power_Color
end

return PowerClass
