local RunService : RunService = game:GetService("RunService")

local Character : Model = script.Parent.Parent
local Tool : Model = script.Parent

local Player : Player = game:GetService('Players'):GetPlayerFromCharacter(Character)

local DefaultCFrame : CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(0), 0)

Tool:WaitForChild("Handle").CFrame = Character:WaitForChild("RightHand").CFrame * DefaultCFrame

local Weld : Weld = Instance.new("WeldConstraint", Tool)
Weld.Name = "Weld"
Weld.Part0 = Character:WaitForChild("RightHand")
Weld.Part1 = Tool:WaitForChild("Handle")
