character = script.Parent.Parent

weld = Instance.new("Weld", script.Parent)
weld.Name = "HandleWeld"
weld.Part0 = character:WaitForChild("RightHand")
weld.Part1 = script.Parent:WaitForChild("Handle")

function UpdateWeldOffset()
	weld.C0 = CFrame.new(script.Parent:GetAttribute("PositionOffset")) * CFrame.Angles(
		math.rad(script.Parent:GetAttribute("RotationOffset").X),
		math.rad(script.Parent:GetAttribute("RotationOffset").Y),
		math.rad(script.Parent:GetAttribute("RotationOffset").Z)
		)
end
UpdateWeldOffset()

script.Parent:GetAttributeChangedSignal("PositionOffset"):Connect(function ()
	UpdateWeldOffset()
end)

script.Parent:GetAttributeChangedSignal("RotationOffset"):Connect(function ()
	UpdateWeldOffset()
end)