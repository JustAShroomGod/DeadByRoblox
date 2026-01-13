local Prefix = "rbxgameasset://Images/"
local Prefix2 = "rbxassetid://"
local PowerClass = {}

local Settings = {
	powerColor = Color3.fromRGB(25, 21, 20);
	powerPictureID = Prefix2.."136812457602908";
}

local Player = game.Players.LocalPlayer

function PowerClass:GetInfo(rawItem)
	local Percentage, Count = -1, 0
	local Saw_Cooldown = Player.Character:GetAttribute("Power_Cooldown")
	
	if Saw_Cooldown then
		Saw_Cooldown = string.split(Saw_Cooldown, ':')

		Percentage = tonumber(Saw_Cooldown[1])/tonumber(Saw_Cooldown[2]) * 100
	end
	
	return Percentage, Count, Settings.powerPictureID, Settings.powerColor
end

return PowerClass
