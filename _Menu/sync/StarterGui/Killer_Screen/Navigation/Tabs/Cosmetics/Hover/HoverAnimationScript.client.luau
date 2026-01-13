tweenService = game:GetService("TweenService")
runService = game:GetService("RunService")

plr = game.Players.LocalPlayer
Mouse = plr:GetMouse()

PlayerGui = plr:WaitForChild("PlayerGui")

screenGui = PlayerGui:WaitForChild("Survivor_Screen")
container = script.Parent.Parent
guiObject = script.Parent

topLeftSideLine = guiObject:WaitForChild("TopLeftSideLine")
topRightSideLine = guiObject:WaitForChild("TopRightSideLine")
bottomLeftSideLine = guiObject:WaitForChild("BottomLeftSideLine")
bottomRightSideLine = guiObject:WaitForChild("BottomRightSideLine") 
downLeftSideLine = guiObject:WaitForChild("DownLeftSideLine")
downRightSideLine = guiObject:WaitForChild("DownRightSideLine")

globalMargin = 0.032

topLeftSideLine.Size = UDim2.new(0,0,globalMargin,0)
topLeftSideLine.Position = UDim2.new(0,0,-globalMargin,0)
topRightSideLine.Size = UDim2.new(0,0,globalMargin,0)
topRightSideLine.Position = UDim2.new(1 + globalMargin,0,-globalMargin,0)
bottomLeftSideLine.Size = UDim2.new(globalMargin,0,0,0)
bottomLeftSideLine.Position = UDim2.new(-globalMargin,0,1 + globalMargin,0)
bottomRightSideLine.Size = UDim2.new(globalMargin,0,0,0)
bottomRightSideLine.Position = UDim2.new(1 + globalMargin,0,1 + globalMargin,0)
downLeftSideLine.Size = UDim2.new(0,0,globalMargin,0)
downLeftSideLine.Position = UDim2.new(0,0,1,0)
downRightSideLine.Size = UDim2.new(0,0,globalMargin,0)
downRightSideLine.Position = UDim2.new(1 + globalMargin,0,1,0)

originalTopLeftSideLine = UDim2.new(0,0,globalMargin,0)
originalTopRightSideLine = UDim2.new(0,0,globalMargin,0)
originalBottomLeftSideLine = UDim2.new(globalMargin,0,0,0)
originalBottomRightSideLine = UDim2.new(globalMargin,0,0,0)
originalDownLeftSideLine = UDim2.new(0,0,globalMargin,0)
originalDownRightSideLine = UDim2.new(0,0,globalMargin,0)

tsTopLeftSideLine = UDim2.new((1 + globalMargin)/2,0,globalMargin,0)
tsTopRightSideLine = UDim2.new((1 + globalMargin)/2,0,globalMargin,0)
tsBottomLeftSideLine = UDim2.new(globalMargin,0,1 + globalMargin * 2,0)
tsBottomRightSideLine = UDim2.new(globalMargin,0,1 + globalMargin * 2,0)
tsDownLeftSideLine = UDim2.new((1 + globalMargin)/2,0,globalMargin,0)
tsDownRightSideLine = UDim2.new((1 + globalMargin)/2,0,globalMargin,0)

tweenTargetLeftBottom = nil
tweenTargetLeftTop = nil

tweenTargetRightBottom = nil
tweenTargetRightTop = nil

tweenOriginLeftBottom = nil
tweenOriginLeftTop = nil

tweenOriginRightBottom = nil
tweenOriginRightTop = nil

tweenTargetRightDown = nil
tweenTargetLeftDown = nil

tweenOriginRightDown = nil
tweenOriginLeftDown = nil

tweenSpeed = TweenInfo.new(0.15)

mouseIn = false

function Hover()
	mouseIn = true
	if screenGui.Enabled == true then
		local sound = PlayerGui:WaitForChild("ScreenSS")
		local soundclone = sound:Clone()
		soundclone.Parent = PlayerGui
		soundclone.Playing = true
		soundclone.Ended:Connect(function()
			soundclone:Destroy()
		end)
	end

	local targetBottomLeftGoal = {}
	targetBottomLeftGoal.Size = tsBottomLeftSideLine

	tweenTargetLeftBottom = tweenService:Create(bottomLeftSideLine,tweenSpeed,targetBottomLeftGoal)
	tweenTargetLeftBottom:Play()

	local targetTopLeftGoal = {}
	targetTopLeftGoal.Size = tsTopLeftSideLine

	tweenTargetLeftTop = tweenService:Create(topLeftSideLine,tweenSpeed,targetTopLeftGoal)
	tweenTargetLeftTop:Play()

	local targetBottomRightGoal = {}
	targetBottomRightGoal.Size = tsBottomRightSideLine

	tweenTargetRightBottom = tweenService:Create(bottomRightSideLine,tweenSpeed,targetBottomRightGoal)
	tweenTargetRightBottom:Play()

	local targetTopRightGoal = {}
	targetTopRightGoal.Size = tsTopRightSideLine

	tweenTargetRightTop = tweenService:Create(topRightSideLine,tweenSpeed,targetTopRightGoal)
	tweenTargetRightTop:Play()

	local targetDownRightGoal = {}
	targetDownRightGoal.Size = tsDownRightSideLine

	tweenTargetRightDown = tweenService:Create(downRightSideLine,tweenSpeed,targetDownRightGoal)
	tweenTargetRightDown:Play()

	local targetDownLeftGoal = {}
	targetDownLeftGoal.Size = tsDownLeftSideLine

	tweenTargetLeftDown = tweenService:Create(downLeftSideLine,tweenSpeed,targetDownLeftGoal)
	tweenTargetLeftDown:Play()
end

function UnHover()
	mouseIn = false
	if tweenTargetLeftBottom then
		tweenTargetLeftBottom:Cancel()
	end

	if tweenTargetLeftTop then
		tweenTargetLeftTop:Cancel()
	end

	if tweenTargetRightBottom then
		tweenTargetRightBottom:Cancel()
	end

	if tweenTargetRightTop then
		tweenTargetRightTop:Cancel()
	end

	if tweenTargetRightDown then
		tweenTargetRightDown:Cancel()
	end

	if tweenTargetLeftDown then
		tweenTargetLeftDown:Cancel()
	end

	local originTopLeftGoal = {}
	originTopLeftGoal.Size = originalTopLeftSideLine

	tweenOriginLeftTop = tweenService:Create(topLeftSideLine,tweenSpeed,originTopLeftGoal)
	tweenOriginLeftTop:Play()

	local originBottomLeftGoal = {}
	originBottomLeftGoal.Size = originalBottomLeftSideLine

	tweenOriginLeftBottom = tweenService:Create(bottomLeftSideLine,tweenSpeed,originBottomLeftGoal)
	tweenOriginLeftBottom:Play()

	local originTopRightGoal = {}
	originTopRightGoal.Size = originalTopRightSideLine

	tweenOriginRightTop = tweenService:Create(topRightSideLine,tweenSpeed,originTopRightGoal)
	tweenOriginRightTop:Play()

	local originBottomRightGoal = {}
	originBottomRightGoal.Size = originalBottomRightSideLine

	tweenOriginRightBottom = tweenService:Create(bottomRightSideLine,tweenSpeed,originBottomRightGoal)
	tweenOriginRightBottom:Play()

	local originDownRightGoal = {}
	originDownRightGoal.Size = originalDownRightSideLine

	tweenOriginRightDown = tweenService:Create(downRightSideLine,tweenSpeed,originDownRightGoal)
	tweenOriginRightDown:Play()

	local originDownLeftGoal = {}
	originDownLeftGoal.Size = originalDownLeftSideLine

	tweenOriginLeftDown = tweenService:Create(downLeftSideLine,tweenSpeed,originDownLeftGoal)
	tweenOriginLeftDown:Play()
end

container.MouseEnter:Connect(Hover)
container.MouseLeave:Connect(UnHover)
