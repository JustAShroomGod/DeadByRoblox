local Players = game:GetService('Players')
local Picture = {}
Picture.__index = Picture

function Picture:Update()
	local User, Image = self.UserID, self.UI.Parent
	
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size420x420
	local content, isReady = Players:GetUserThumbnailAsync(User, thumbType, thumbSize)
	
	Image.BackgroundTransparency = 1
	Image.Image = content
end

local function GatherUI(parent) -- smart gather system will return a nice error if we do it incorrectly
	local Parent_Frame = parent
	
	if Parent_Frame.ClassName ~= "ImageLabel" and Parent_Frame.ClassName ~= "Decal" then
		return warn("Syntax: Needs to be a image label or image decal to convert!")
	end
	
	return {
		["Parent"] = Parent_Frame;
	}
end

local function BuildUI(parent)
	local Image = Instance.new("ImageLabel", parent)
	Image.Name = "Profile_Image"

	return {
		["Parent"] = Image;
	}
end

function CheckIfPlayer(character : StringValue)
	
	if Players:FindFirstChild(character.Name) then
		return Players[character.Name].UserId
	else
		return 1
	end
end

function Picture:New(newid) -- replace intvalue from percentage holder or add one
	
	self.UserID = newid or 1

	if typeof(self.UserID) == "Instance" and self.UserID.ClassName == "Player" then
		self.UserID = self.UserID.UserId -- swaap from players to number
	end

	self:Update()
end

function Picture.new(...) -- imageframe, recieve stringvalue
	local args = {...}
	
	local self = {}
	setmetatable(self, Picture) -- give it all the functions

	if typeof(args[2]) == "Instance" and args[1].ClassName ~= "Player" then -- got a stringvalue or character
		self.UI = GatherUI(args[1])

		self.UserID = CheckIfPlayer(args[2])
		
		if typeof(self.UI) ~= "table" then
			return warn("Could not convert the frame!\n")
		end
	elseif typeof(self.UserID) == "Instance" and self.UserID.ClassName == "Player" then
		self.UI = BuildUI(args[2])

		self.UserID = args[2].UserId or 1
	else -- sent a player id
		self.UI = GatherUI(args[1])

		self.UserID = args[2] or 1
	end

	--[[if typeof(self.UserID) == "Instance" and self.UserID.ClassName == "Player" then
		self.UserID = self.UserID.UserId -- swaap from players to number
	end]]--

	self:Update()

	return self
end

return Picture
