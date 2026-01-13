script.Parent.Parent.Using.Changed:Connect(function()
	if script.Parent.Parent.Using.Value == true then
		if script.Parent.Value then
			local HighLightAura = Instance.new("Highlight", script.Parent.Value.Character)
			HighLightAura.OutlineColor = Color3.fromRGB(150,90,255)
			HighLightAura.FillColor = Color3.fromRGB(150,90,255)
			HighLightAura.Enabled = true
			HighLightAura.FillTransparency = 0
			HighLightAura.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			print(HighLightAura.Parent, "Enabled")
			task.wait(7)
			print("Destroy New Aura")
			HighLightAura:Destroy()
		end
	end
end)