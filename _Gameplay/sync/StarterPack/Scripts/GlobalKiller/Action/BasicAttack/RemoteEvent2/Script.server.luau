script.Parent.OnServerEvent:Connect(function(P,A,N,V)
	if (P.Character.Head:FindFirstChild(N) == nil) then
		local Audio = Instance.new("Sound", P.Character.Head)
		Audio.Name = N
		Audio.SoundId = A
		Audio.Volume = V
		Audio.RollOffMaxDistance = 60
		Audio.RollOffMinDistance = 30
	end
end)