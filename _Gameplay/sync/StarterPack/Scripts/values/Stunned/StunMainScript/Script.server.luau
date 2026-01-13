--[[script.Parent:WaitForChild("RemoteEvent").OnServerEvent:Connect(function(Player, Shabam)
	if Shabam then
		local Character = Player.Character

		local current_rage = string.split(Character:GetAttribute("Power"), ':')

		Character:SetAttribute("Power", math.clamp(current_rage[1] - 0, 0, 1000)..':'..current_rage[2])
	else
		local Character = Player.Character

		local current_rage = string.split(Character:GetAttribute("Power"), ':')

		Character:SetAttribute("Power", tostring(0)..':'..current_rage[2])
	end
end)]]--