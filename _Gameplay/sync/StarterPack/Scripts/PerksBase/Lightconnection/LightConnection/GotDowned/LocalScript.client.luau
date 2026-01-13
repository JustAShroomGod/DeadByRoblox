script.Parent.Changed:Connect(function()
	if script.Parent.Value == true then
		script.Parent.Parent.RemoteEvent:FireServer("CodeTestLightIsConnectiondfsdfhdshjfdshjdsdsffdsfs", {A = script.Parent.Parent.Parent.HealEffect, B = true})
		task.wait(15)
		script.Parent.Value = false
		script.Parent.Parent.Disablede.Value = true
		script.Parent.Parent.Using.Value = false
		script.Parent.Parent.Parent.Playing.Value = false
		script.Parent.Parent.RemoteEvent:FireServer("CodeTestLightIsConnectiondfsdfhdshjfdshjdsdsffdsfs", {A = script.Parent.Parent.Parent.HealEffect, B = false})
	end
end)