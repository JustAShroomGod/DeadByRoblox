script.Parent:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
	script.Parent.LocalTransparencyModifier = 1
end)

script.Parent:GetPropertyChangedSignal("Transparency"):Connect(function()
	script.Parent.LocalTransparencyModifier = 1
	script.Parent.Transparency = 1
end)

script.Parent.Transparency = 1