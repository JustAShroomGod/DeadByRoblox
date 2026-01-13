
player = game.Players.LocalPlayer
player:WaitForChild("PlayerGui")
killer = player:WaitForChild('Data').Loadout:WaitForChild('Killer')
stats_ = player.Data:WaitForChild('Stats')

game:GetService("RunService").Heartbeat:Connect(function()
	local SPrestige = stats_:WaitForChild('Prestige'):WaitForChild('Survivor').Value
	local KPrestige = stats_.Prestige[(killer.Value)].Value
	
	script.Parent.PrestigeIcon.Visible = (player.PlayerGui.Killer_Screen.Enabled and KPrestige > 0) or (player.PlayerGui.PreMS.Enabled and SPrestige > 0)
	
	local iconhandler =  script.Parent.PrestigeIcon
	local icon = iconhandler
	local goalPrestige do
		if player.PlayerGui.PreMS.Enabled then
			goalPrestige = SPrestige
		elseif player.PlayerGui.Killer_Screen.Enabled then
			goalPrestige = KPrestige
		end
	end
	local PREFIX = "rbxassetid://"
	if goalPrestige == 1 then
		icon.Image = PREFIX.. tostring(iconhandler:GetAttribute("prestige1id"))
	elseif goalPrestige == 2 then
		icon.Image = PREFIX.. tostring(iconhandler:GetAttribute("prestige2id"))
	elseif goalPrestige == 3 then
		icon.Image = PREFIX.. tostring(iconhandler:GetAttribute("prestige3id"))
	else
		icon.Image = ""
	end
end)