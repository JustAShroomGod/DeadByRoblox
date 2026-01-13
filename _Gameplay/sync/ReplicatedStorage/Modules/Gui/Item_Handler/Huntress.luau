local Prefix = "rbxgameasset://Images/"
local Prefix2 = "rbxassetid://"
local PowerClass = {}

local Settings = {
	powerColor = Color3.fromRGB(25, 21, 20);
	powerPictureID = Prefix2.."93778432493923";
}

function PowerClass:GetInfo(playerInfo)
	local Percentage, Count = -1, 5
	local hasPower = game.Players.LocalPlayer.Character:GetAttribute("Power")
	local powerState = game.Players.LocalPlayer.Character:GetAttribute("Power_State")
	
	Count = tonumber(game.Players.LocalPlayer.Character:GetAttribute("Hatchet_Count"))
	
	if hasPower and powerState ~= "Idle" then
		hasPower = string.split(hasPower, ':')
		Percentage = tonumber(hasPower[1])/tonumber(hasPower[2]) * 100
	end
	
	return Percentage, Count, Settings.powerPictureID, Settings.powerColor
end

return PowerClass
