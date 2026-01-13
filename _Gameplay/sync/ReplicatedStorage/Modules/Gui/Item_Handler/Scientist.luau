local Player = game.Players.LocalPlayer
local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()

local Prefix = "rbxgameasset://Images/"
local Prefix2 = "rbxassetid://"
local PowerClass = {}

local Settings = {
	powerColor = Color3.fromRGB(25, 21, 20);
	powerPictureID = Prefix2.."87772277127004";
}

function PowerClass:GetInfo(rawItem)
	local Percentage, Count = 0, 0
	
	if (not Character:GetAttribute("IntroDone")) then
		return Percentage, Count, Settings.powerPictureID, Settings.powerColor
	end
	
	local Power = Character:WaitForChild("Time Dilation")
	local PowerValues = Power:WaitForChild("PowerValues")
	
	if (not Power:GetAttribute("Initialized")) then
		return
	end
	
	local current, max = PowerValues:GetAttribute("Current") or 100, 100
	
	Percentage = math.floor(100 / max * current)
	
	return Percentage, Count, Settings.powerPictureID, Settings.powerColor
end

return PowerClass

--[[local Killer_File = require(game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild(script.Name))
local PowerClass = {}

function PowerClass:GetInfo(rawItem)
	local Percentage, Count = -1, 0
	local Power = game.Players.LocalPlayer.Character:GetAttribute("Power")

	if Power then
		Power = string.split(Power, ':')
		Percentage = tonumber(Power[1])/tonumber(Power[2]) * 100
	else
		Percentage = -1
	end

	return Percentage, Count, Killer_File.Power_Image, Killer_File.Power_Color
end

return PowerClass]]
