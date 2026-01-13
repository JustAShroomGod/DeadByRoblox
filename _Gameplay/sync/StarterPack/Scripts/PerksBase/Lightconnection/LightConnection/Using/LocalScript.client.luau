script.Parent.Changed:Connect(function()
	if script.Parent.Value == true then
		task.wait(10.05)
		if script.Parent.Parent.GotDowned.Value == false then
			script.Parent.Parent.Disablede.Value = true
			script.Parent.Parent.Parent.Playing.Value = false
			script.Parent.Value = false
		end
	end
end)