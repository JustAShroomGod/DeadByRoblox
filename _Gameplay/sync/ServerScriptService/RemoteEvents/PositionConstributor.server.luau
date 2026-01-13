local MovementUpdate = game.ReplicatedStorage.RemoteEvents.MovementUpdate
local Players = game.Players

function onMovementReceive(Player: Player , Position: CFrame)
	for i, v in pairs(Players:GetPlayers()) do
		if (v.Name ~= Player.Name) then
			MovementUpdate:FireClient(v, Player, Position)
		end
	end
end

MovementUpdate.OnServerEvent:Connect(onMovementReceive)

