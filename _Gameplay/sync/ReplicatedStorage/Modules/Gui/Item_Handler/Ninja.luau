local Killer_File = require(game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild(script.Name))
local PowerClass = {}

function PowerClass:GetInfo(playerInfo)
	local Percentage, Count = -1, 0
	local hasDash = game.Players.LocalPlayer.Character:GetAttribute("Power")

	if hasDash then
		hasDash = string.split(hasDash, ':')
		Percentage = tonumber(hasDash[1])/tonumber(hasDash[2]) * 100
	else
		Percentage = -1
	end

	return Percentage, Count, Killer_File.Power_Image, Killer_File.Power_Color
end

return PowerClass
