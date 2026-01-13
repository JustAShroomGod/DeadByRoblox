local Prefix2 = "rbxassetid://"
local PowerClass = {}

local Images = {72592676566403, 126294197264067, 132524124111940}

local Settings = {
	powerColor = Color3.fromRGB(25, 21, 20);
	powerPictureID = Prefix2.."72592676566403";
}

function PowerClass:GetInfo(rawItem)
	local Percentage, Count, CurrentTier = 100, 0, Settings.powerPictureID
	
	local hasStalk = game.Players.LocalPlayer.Character:GetAttribute("Power_Progress")
	
	if hasStalk then
		hasStalk = string.split(hasStalk, ':')
		Percentage = tonumber(hasStalk[1])/tonumber(hasStalk[2]) * 100
		
		if Images[game.Players.LocalPlayer.Character:GetAttribute("Power_Tier")] then
			CurrentTier = Prefix2..Images[game.Players.LocalPlayer.Character:GetAttribute("Power_Tier")]
		end
	else
		Percentage = -1
	end
	
	return Percentage, Count, CurrentTier, Settings.powerColor
end

return PowerClass
