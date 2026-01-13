char = workspace:WaitForChild(script.Parent.Parent.Name)

script.Parent:WaitForChild("Handle").CFrame = char:WaitForChild("RightHand").CFrame *CFrame.new(0,-0.7,0) * CFrame.Angles(math.rad(0),math.rad(-90),math.rad(0))

local weld = Instance.new("WeldConstraint",script.Parent)
weld.Name = "HandleWeld"
weld.Part0 = char:WaitForChild("RightHand")
weld.Part1 = script.Parent:WaitForChild("Handle")