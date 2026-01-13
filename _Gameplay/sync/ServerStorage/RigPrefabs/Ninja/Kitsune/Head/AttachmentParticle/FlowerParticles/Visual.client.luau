script.Parent.Parent.Parent.Parent:GetAttributeChangedSignal("IntroDone"):Once(function()
	script.Parent.Enabled = false
	script:Destroy()
end)