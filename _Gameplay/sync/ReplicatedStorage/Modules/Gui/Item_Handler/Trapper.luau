local Prefix = "rbxgameasset://Images/"
local Prefix2 = "rbxassetid://"
local PowerClass = {}

local Settings = {
	powerColor = Color3.fromRGB(25, 21, 20);
	powerPictureID = Prefix2.."9637320341";
}

function PowerClass:GetInfo(playerInfo)
	local Percentage, Count = -1, 0
	local TrapAttribute = game.Players.LocalPlayer.Character:GetAttribute("Traps")
	
	if TrapAttribute then
		local TrapTable = string.split(TrapAttribute, ':')
		Count = tonumber(TrapTable[1])
	end
	
	return Percentage, Count, Settings.powerPictureID, Settings.powerColor
end

return PowerClass
