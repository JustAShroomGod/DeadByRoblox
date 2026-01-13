local remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
	local remoteEvent = Instance.new("RemoteEvent", remoteEvents) 
	remoteEvent.Name = string.gsub(script.Name,"Script","") 

remoteEvent.OnServerEvent:Connect(function(player, from_cframe, to_cframe, _time)
	remoteEvent:FireAllClients(from_cframe, to_cframe)
end)