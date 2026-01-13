script.Parent.OnServerEvent:Connect(function(Survivor)
	if (Survivor.Backpack.Scripts.BLOODPOINT:FindFirstChild('REMOVE') ~= nil) then
		Survivor.Backpack.Scripts.BLOODPOINT.REMOVE:DESTROY()
		Survivor.Backpack.Scripts.BLOODPOINT.Enabled = false
		Survivor.Backpack.Scripts.BLOODPOINT.Enabled = true
	end
end)