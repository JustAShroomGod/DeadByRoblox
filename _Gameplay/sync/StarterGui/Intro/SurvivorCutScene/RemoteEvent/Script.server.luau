script.Parent.OnServerEvent:Connect(function(Survivor)
	Survivor.Character:SetAttribute("IntroDoneS", true)
	if (Survivor.Backpack.Scripts.BLOODPOINT:FindFirstChild('REMOVE') ~= nil) then 
	else
		Instance.new("BoolValue", Survivor.Backpack.Scripts.BLOODPOINT).Name = "REMOVE"
	end
end)
