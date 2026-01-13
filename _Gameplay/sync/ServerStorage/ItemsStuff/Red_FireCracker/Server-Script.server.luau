local RunService : RunService,TweenService : TweenService ,Loop = game:GetService("RunService"),game:GetService("TweenService") ,nil

local Tool : Model = script.Parent
local Character : Model = script.Parent.Parent

local DefaultCFrame = CFrame.new(0, -0.3, 0) * CFrame.Angles(math.rad(0), math.rad(0), 0);


Tool.PrimaryPart.Anchored = false

local Weld = Instance.new('Weld', Tool)
Weld.Part0 = Character:WaitForChild('RightHand')
Weld.Part1 = Tool.PrimaryPart
Weld.C0 = DefaultCFrame
