local remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
local remoteEvent = Instance.new("RemoteEvent", remoteEvents) remoteEvent.Name = string.gsub(script.Name,"Script","")

charactersStuff = game.ServerStorage:WaitForChild("CharactersStuff")
local cont = {}
cont.survivor = charactersStuff:WaitForChild("Survivor")
cont.killer = charactersStuff:WaitForChild("Killer")

remoteEvent.OnServerEvent:Connect(function(plr, skinName, mode)
	local char = plr.Character
	if char then
		local targetSkin = cont[mode]:FindFirstChild(skinName)
		if targetSkin then
			local newSkin = targetSkin:Clone()
			newSkin.Parent = char
			local settupScript = newSkin:FindFirstChildOfClass("Script")
			if settupScript then
				settupScript.Disabled = false
			end
		end
	end
end)