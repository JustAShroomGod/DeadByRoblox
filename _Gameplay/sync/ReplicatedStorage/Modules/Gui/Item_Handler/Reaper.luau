local Killer_File = require(game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild(script.Name))
local PowerClass = {}

local Settings = {}

function PowerClass:GetInfo(playerInfo)
	local Percentage, Count = -1, 0
	local hasCharges = game.Players.LocalPlayer.Character:GetAttribute("Power")

	if hasCharges then
		hasCharges = string.split(hasCharges, ':')
		Count = tonumber(hasCharges[1])
	else
		Percentage = -1
	end

	return Percentage, Count, Killer_File.Power_Image, Killer_File.Power_Color
end

return PowerClass
