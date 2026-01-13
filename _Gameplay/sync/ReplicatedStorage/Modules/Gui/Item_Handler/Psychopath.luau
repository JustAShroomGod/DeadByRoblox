--[[local Prefix = "rbxgameasset://Images/"
local Prefix2 = "rbxassetid://"
local PowerClass = {}

local Settings = {
	powerColor = Color3.fromRGB(25, 21, 20);
	powerPictureID = Prefix2.."10098704485";
}

function PowerClass:GetInfo(playerInfo)
	local Percentage, Count, CurrentTier = 100, 0, Settings.powerPictureID

	--this image will need to change so it's gonna be wierd

	local Power = game.Players.LocalPlayer.Character:FindFirstChild("BloodRage")

	if (Power) then
		Percentage = tonumber(Power:GetAttribute("Progress"))
	else
		Percentage = -1
	end
	
	return Percentage, Count, CurrentTier, Settings.powerColor
end

return PowerClass]]

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
