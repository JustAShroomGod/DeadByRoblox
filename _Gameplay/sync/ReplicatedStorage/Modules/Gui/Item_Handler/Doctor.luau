local Prefix = "rbxgameasset://Images/"
local Prefix2 = "rbxassetid://"
local PowerClass = {}

local Settings = {
	powerColor = Color3.fromRGB(25, 21, 20);
	powerPictureID = Prefix2.."9637319785";
}

function PowerClass:GetInfo(playerInfo)
	local Percentage, Count = -1, 0
	local hasPower = game.Players.LocalPlayer.Character:GetAttribute("Power")
	local powerState = game.Players.LocalPlayer.Character:GetAttribute("Power_State")

	if hasPower and powerState ~= "Idle" then
		hasPower = string.split(hasPower, ':')
		Percentage = tonumber(hasPower[1])/tonumber(hasPower[2]) * 100
	end

	return Percentage, Count, Settings.powerPictureID, Settings.powerColor
end

return PowerClass