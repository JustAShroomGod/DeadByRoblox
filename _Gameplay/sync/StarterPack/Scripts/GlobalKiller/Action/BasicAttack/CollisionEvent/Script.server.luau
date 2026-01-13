local Code = require(game.ReplicatedStorage.Modules:WaitForChild("Code"))

script.Parent.OnServerEvent:Connect(function(Player, bool)
	
	if (Player.Team ~= game.Teams.Killer) then
		return
	end
	
	local targetCollision = if (bool) then "Killer" else "Player"
	local survCollision = if (bool) then "Survivor" else "Player"

	Code:SetCollision(Player, targetCollision)

	for i, v in pairs(game.Teams.Survivor:GetPlayers()) do

		if (Code:GetHealthState(v) <= 0) then
			return
		end

		Code:SetCollision(v, survCollision)
	end
	
end)

