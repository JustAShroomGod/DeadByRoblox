script:GetPropertyChangedSignal("Enabled"):Connect(function()
	
	if (not script.Enabled) then
		return
	end

	local Character = script.Parent
	local Humanoid = Character:WaitForChild("Humanoid")

	Character:WaitForChild("TrailParticleEmitter").TrailEmitter.Enabled = false

	game["Run Service"].Heartbeat:Connect(function()
		Character.TrailParticleEmitter.TrailEmitter.Enabled = Humanoid.MoveDirection.Magnitude > 0.01
	end)
end)

