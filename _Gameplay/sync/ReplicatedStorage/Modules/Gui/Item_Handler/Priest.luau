local Prefix = "rbxgameasset://Images/"
local Prefix2 = "rbxassetid://"
local PowerClass = {}

local Settings = {
	powerColor = Color3.fromRGB(25, 21, 20);
	powerPictureID = Prefix2.."9637320889";
}

function PowerClass:GetInfo(rawItem)
	local Percentage, Count = 100, 0
	
	return 100, 5, Settings.powerPictureID, Settings.powerColor
end

return PowerClass

