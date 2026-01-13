remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
objectAppUpdater = remoteEvents:WaitForChild("ObjectAppUpdater")

objectAppUpdater.OnServerEvent:Connect(function(plr,targetObject,targetPropertie,newPropertie) 
	
	if targetObject then
		
		if targetPropertie == "Playing" then  --for sound (DONT TOUCH)
			targetObject.Playing = newPropertie
		elseif targetPropertie == "TimePosition" then --for sound (DONT TOUCH)
			targetObject.TimePosition = newPropertie
		end
	end
end)