script.Parent.Changed:Connect(function()
	if script.Parent.Value == true then
		script.Parent.Parent.Parent.Playing.Value = false
		task.wait(45)
		script.Parent.Value = false
	end
end)