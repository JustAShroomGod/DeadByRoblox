local char = script.Parent.Parent
local lowerTorso = char:WaitForChild("LowerTorso")
local rootPart = script.Parent:WaitForChild("RootPart")
lowerTorso.CFrame = rootPart.CFrame
local rootPartWeld = Instance.new("WeldConstraint", rootPart)
rootPartWeld.Name = "RootPartWeld" rootPartWeld.Part0 = lowerTorso rootPartWeld.Part1 = rootPart