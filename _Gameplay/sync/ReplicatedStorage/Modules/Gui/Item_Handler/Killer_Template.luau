local Prefix = "rbxgameasset://Images/"
local Prefix2 = "rbxassetid://"
local PowerClass = {}

local Settings = {
	powerColor = Color3.fromRGB(25, 21, 20);
	powerPictureID = Prefix2.." ";
}

function PowerClass:GetInfo(rawItem)
	local Percentage, Count = -1, 0
	
	return Percentage, Count, Settings.powerPictureID, Settings.powerColor
end

return PowerClass
