local PS = game:GetService("Players")
local Run = game:GetService("RunService")
local Rep = game:GetService("ReplicatedStorage")

local Lighting : Lighting = game:GetService("Lighting")

local y = -200

Lighting.ChildAdded:Once(function() --bandaid fix
	local Spawns = Rep:WaitForChild("Game_Spawns"):WaitForChild("SurvivorSpawns")
	
	Run.Heartbeat:Connect(function() -- this could be terrible on performance, but easier than manual hitboxes on each map. ~ trashcan
		for _, Player in pairs(PS:GetChildren()) do
			local Char = Player.Character

			if Char and Char.Parent ~= nil and Char.Humanoid.Health > 0 then
				local HRP = Char:FindFirstChild("HumanoidRootPart")

				if HRP then
					if HRP.Position.Y <= y then
						local PossibleSpawns = Spawns:GetChildren()
						HRP.CFrame = PossibleSpawns[math.random(1, #PossibleSpawns)].CFrame + Vector3.new(0,50,0)
					end
				end
			end
		end
	end)
end)


-- I'm not sure if it would be better to run this on the client or the server, idk which is more stressed.