script.Parent.OnServerEvent:Connect(function(Player,Medkit)
	if Medkit:GetAttribute("Addon_1") == "Syringe" or Medkit:GetAttribute("Addon_2") == "Syringe" then
		if Player.Backpack.Scripts.values.HealthState.Value == 1 then
			Player.Backpack.Scripts.values.HealthState.Value = 2
			if Medkit then
				Medkit:Destroy()
			end
		end
	end
end)