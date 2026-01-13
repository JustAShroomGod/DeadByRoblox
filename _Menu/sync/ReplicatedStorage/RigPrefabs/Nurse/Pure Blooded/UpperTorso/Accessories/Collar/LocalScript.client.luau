script.Parent:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
	script.Parent.LocalTransparencyModifier = 0
end)

script.Parent:GetPropertyChangedSignal("Transparency"):Connect(function()
	script.Parent.LocalTransparencyModifier = 0
	script.Parent.Transparency = 0
end)

script.Parent.Transparency = 0