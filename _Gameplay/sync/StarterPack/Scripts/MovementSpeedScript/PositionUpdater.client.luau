local MovementUpdate = game.ReplicatedStorage.RemoteEvents.MovementUpdate
local LocalPlayer = game.Players.LocalPlayer
local RunService = game["Run Service"]

function onMovementReceive(Player: Player , Position: CFrame)
	if (Player.Backpack:WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Holded').Value)
		or not Player.Character or not Player.Character.PrimaryPart then
		return
	end
	
	Player.Character.PrimaryPart.CFrame = Position
end

function onRenderStepped()

	if (not LocalPlayer.Character) then
		return
	end
	
	if (not LocalPlayer.Character.PrimaryPart) then
		return
	end
	
	if (not LocalPlayer.Character:GetAttribute("IntroDone")) then
		return
	end
		
	MovementUpdate:FireServer(LocalPlayer.Character.PrimaryPart.CFrame)
end

RunService.Heartbeat:Connect(onRenderStepped)
MovementUpdate.OnClientEvent:Connect(onMovementReceive)