local Events = require(script.Parent:WaitForChild("Events"))
local Code = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local RunService = game:GetService("RunService")

RunService.Heartbeat:Connect(function(delta)
	Events.Server.Heartbeat:Fire(delta)
end)

RunService.Stepped:Connect(function()
	Events.Server.Stepped:Fire()
end)

Events.Remotes.ClientAttack.OnServerEvent:Connect(function(Player, State, ObjectName)
	Events.Killer.onAttack:Fire(State, ObjectName)
end)

Events.Remotes.ActionEvent.OnServerEvent:Connect(function(Player, Action, Type, ...)
	local Args = {...}
	
	if (Action == "Stun") then
		Events.Killer.onStun:Fire(Type, Player)
	end
	
	if (Action == "Survivor_Vault") then
		Events.Survivor.onVault:Fire(Player, Type)
		
		if Args == true then
			for i, plr in pairs(game.Teams.Killer:GetPlayers()) do
				Code:AddNotification(Player.PrimaryPart.CFrame, 5, "Default", plr) -->> notify killers
			end
		end
	end
	
	if (Action == "Killer_Vault") then
		Events.Killer.onVault:Fire(Type)
	end
end)

Events.Remotes.MouseEvent.OnServerEvent:Connect(function(Player, Key, Down)
	Events.Gameplay.onMouseEvent:Fire(Player, Key, Down)
end)

Events.Remotes.InputEvent.OnServerEvent:Connect(function(Player, KeyCode, Down)
	Events.Gameplay.onInputEvent:Fire(Player, KeyCode, Down)
end)

game.Workspace.MatchValues.GeneratorsRepaired.Changed:Connect(function(value)
	if (value >= 5) then
		print("Fire Exit")
		Events.Gameplay.onExitPowered:Fire()
	end
end)