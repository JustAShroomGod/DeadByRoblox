local Players = game.Players
local Timestamp, Shut = 0, false

local Up_Time = 30

local placeId = game.PlaceId
local TeleportService = game:GetService('TeleportService')

Players.PlayerAdded:Connect(function(player)
	if Timestamp == 0 then Timestamp = workspace:GetServerTimeNow() end
	
	if Shut then
		player:Kick('Server has shutdown. Please rejoin.')
	end
end)

while task.wait(5) do
	
	if Timestamp ~= 0 and (workspace:GetServerTimeNow() - Timestamp) >= (Up_Time * 60) then
		local reservedServer = TeleportService:ReserveServerAsync(placeId)
		
		Shut = true
		
		TeleportService:TeleportToPrivateServer(placeId, reservedServer, game.Players:GetPlayers())
		
		task.wait(10)
		
		for _, p in pairs(Players:GetChildren()) do
			p:Kick('Server has shutdown. Please rejoin.')
		end
	end
end