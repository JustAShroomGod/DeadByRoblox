require(script:WaitForChild("Leaderboard")).Create()

local CollectionService : CollectionService, TweenService : TweenService = game:GetService("CollectionService"), game:GetService("TweenService")

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local PlayerGui = Player.PlayerGui

local Tag = "Art"
local Arts = {}

local TweenInfo_Hover = TweenInfo.new(0.2)

local function HoverEffect(ImageLabel : ImageLabel)
	local Hover = ImageLabel.Parent:WaitForChild("Hover")
	
	local TweenIn = TweenService:Create(Hover, TweenInfo_Hover, {TextTransparency = 0})
	local TweenOut = TweenService:Create(Hover, TweenInfo_Hover, {TextTransparency = 1})
	
	ImageLabel.MouseEnter:Connect(function()
		if not (TweenOut.PlaybackState == Enum.PlaybackState.Completed) then
			TweenOut:Cancel()
		end
		
		TweenIn:Play()
	end)
	
	ImageLabel.MouseLeave:Connect(function()
		if not (TweenIn.PlaybackState == Enum.PlaybackState.Completed) then
			TweenIn:Cancel()
		end

		TweenOut:Play()
	end)
end

for _, Object in pairs(CollectionService:GetTagged(Tag)) do
	HoverEffect(Object:WaitForChild("Container"):WaitForChild("ArtImage"))
end


