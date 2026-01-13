script.Parent.Parent.Parent:GetAttributeChangedSignal("IntroDone"):Once(function()
	script.Parent.LocalTransparencyModifier = 1
	script.Parent.Transparency = 1
	script:Destroy()
end)