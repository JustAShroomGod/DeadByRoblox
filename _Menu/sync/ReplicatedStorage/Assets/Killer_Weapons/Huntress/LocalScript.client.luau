char = workspace:WaitForChild(script.Parent.Parent.Name)
humanoid = char:WaitForChild("Humanoid")

weld = nil
function UpdateCFrame()
	if weld then weld:Destroy() end
	
	local AngleOffset = script.Parent:GetAttribute("AngleOffset")
	script.Parent:WaitForChild("Handle").CFrame = char:WaitForChild("LeftHand").CFrame
		*CFrame.new(script.Parent:GetAttribute("PositionOffset"))
		*CFrame.Angles(math.rad(AngleOffset.X), math.rad(AngleOffset.Y), math.rad(AngleOffset.Z))
	
	weld = Instance.new("WeldConstraint",script.Parent)
	weld.Name = "HandleWeld"
	weld.Part0 = char:WaitForChild("LeftHand")
	weld.Part1 = script.Parent:WaitForChild("Handle")
end
UpdateCFrame()
script.Parent:GetAttributeChangedSignal("AngleOffset"):Connect(function ()
	UpdateCFrame()
end)
script.Parent:GetAttributeChangedSignal("PositionOffset"):Connect(function ()
	UpdateCFrame()
end)

