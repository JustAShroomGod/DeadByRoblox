local char = workspace:WaitForChild(script.Parent.Parent.Name)
local humanoid = char:WaitForChild("Humanoid")
local weapon = char:FindFirstChild(script.Parent.Name)

script.Parent:WaitForChild("Handle").CFrame = char:WaitForChild("LeftHand").CFrame
	* CFrame.new(0,-0.5,0)
	* CFrame.Angles(math.rad(0),math.rad(0),math.rad(90))

local weld = Instance.new("WeldConstraint",script.Parent)
weld.Name = "HandleWeld"
weld.Part0 = char:WaitForChild("LeftHand")
weld.Part1 = script.Parent:WaitForChild("Handle")