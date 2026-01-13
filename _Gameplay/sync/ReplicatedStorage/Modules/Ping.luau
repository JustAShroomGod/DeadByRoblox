local ReplicatedStorage, RunService, Players = game:GetService("ReplicatedStorage"), game:GetService("RunService"), game:GetService("Players")
local Event = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PingTimes")

local module = {}

local UPDATE_FREQ = 4

if RunService:IsServer() then
	local Thread = coroutine.create(function()
		while task.wait(UPDATE_FREQ) do
			for _, Player in pairs(Players:GetPlayers()) do
				if not module[Player.Name] then
					module[Player.Name] = 0
				end

				task.spawn(function()
					local Success, Error = pcall(function()
						module[Player.Name] = Event:InvokeClient(Player)
					end)
					
					if Error then
						module[Player.Name] = 0
					end
				end)
			end
		end
	end)
	
	coroutine.resume(Thread)
else
	Event.OnClientInvoke = function()
		return Players.LocalPlayer:GetNetworkPing()
	end
end

return module
