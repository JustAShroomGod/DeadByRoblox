coroutine.resume(coroutine.create(function()
	repeat task.wait() until game.ReplicatedStorage:FindFirstChild("RemoteEvents"):FindFirstChild("ForceCamera")

	game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ForceCamera").OnClientEvent:Connect(function(Humanoid)
		workspace.CurrentCamera.CameraSubject = Humanoid
	end)
end))

local VaultinWindow = false

game:GetService("RunService").RenderStepped:Connect(function()
	task.spawn(function()
		for _, V in pairs(game.Players:GetPlayers()) do
			if V and V.Character then
			else return
			end
			if (V.Character:FindFirstChild('Legacy_Older') ~= nil) then
				for i, b in pairs(V.Character['Legacy_Older']:GetDescendants()) do
					if b.Name == "Handler" and b:IsA("Part") then
						b.Transparency = 1
					end
				end
			end
			if V.Name ~= game.Players.LocalPlayer.Name then
				if (V.Character:FindFirstChild("CustomCollision") ~= nil) then
					V.Character.CustomCollision.Transparency = 1
				else
					local Part = Instance.new("Part", V.Character)
					Part.Size = Vector3.new(V.Character.UpperTorso.Size.X * 1.5,V.Character.UpperTorso.Size.Y * 3,V.Character.UpperTorso.Size.Z * 2.5)
					Part.CFrame = V.Character:WaitForChild("HumanoidRootPart").CFrame
					Part.Name = "CustomCollision"
					Part.Anchored = false
					local Weld = Instance.new("WeldConstraint", Part)
					Weld.Part0 = Part
					Part.CanTouch = false
					Weld.Part1 = V.Character.HumanoidRootPart
					Part.Transparency = 1
					Part.Massless = true
				end
				if game.Players.LocalPlayer.Backpack.Scripts.values.HealthState.Value == 0 or game.Players.LocalPlayer.Backpack.Scripts.values.Hooked.Value == true then
					for C, D in pairs(V.Character:GetChildren()) do
						if D:IsA("BasePart") or D.Name == "CustomCollision" then
							D.CanCollide = false
							D.CanTouch = false
						end
					end
					if (V.Character:FindFirstChild("CollisionSurvivorEx") ~= nil) then
						for i, CollisionParts in pairs(V.Character.CollisionSurvivorEx:GetChildren()) do
							CollisionParts.CanCollide = false
						end
					elseif (V.Character:FindFirstChild("CollisionExtra") ~= nil) then
						for i, CollisionParts in pairs(V.Character.CollisionExtra:GetChildren()) do
							CollisionParts.CanCollide = false
						end
					end
				else
					if VaultinWindow == false then
						if V.Backpack.Scripts.values.Action.Value ~= "Hiding" and V.Backpack.Scripts.values.HealthState.Value ~= 0 and V.Backpack.Scripts.values.Hooked.Value == false then
							for C, D in pairs(V.Character:GetChildren()) do
								if (D:IsA("BasePart") or D.Name == "CustomCollision") and (D.Name ~= "BodyParticleEmitter" and D.Name ~= "TrailParticleEmitter") then
									
									if (D.Name == "BodyParticleEmitter" or D.Name == "TrailParticleEmitter") then
										continue
									end
									
									D.CanCollide = true
									D.CanTouch = false
								end
							end
							if (V.Character:FindFirstChild("CollisionSurvivorEx") ~= nil) then
								for i, CollisionParts in pairs(V.Character.CollisionSurvivorEx:GetChildren()) do
									CollisionParts.CanCollide = true
								end
							elseif (V.Character:FindFirstChild("CollisionExtra") ~= nil) then
								for i, CollisionParts in pairs(V.Character.CollisionExtra:GetChildren()) do
									CollisionParts.CanCollide = true
								end
							end
						else
							for C, D in pairs(V.Character:GetChildren()) do
								if D:IsA("BasePart") or D.Name == "CustomCollision" then
									D.CanCollide = false
								end
							end
							if (V.Character:FindFirstChild("CollisionSurvivorEx") ~= nil) then
								for i, CollisionParts in pairs(V.Character.CollisionSurvivorEx:GetChildren()) do
									CollisionParts.CanCollide = false
								end
							elseif (V.Character:FindFirstChild("CollisionExtra") ~= nil) then
								for i, CollisionParts in pairs(V.Character.CollisionExtra:GetChildren()) do
									CollisionParts.CanCollide = false
								end
							end
						end
					end
				end
			else
				if V.Backpack.Scripts.values.Action.Value ~= "Hiding" and V.Backpack.Scripts.values.HealthState.Value ~= 0 and V.Backpack.Scripts.values.Hooked.Value == false then
					for C, D in pairs(V.Character:GetChildren()) do
						if D.Name == "Head" or D:IsA("BasePart") or D.Name == "CustomCollision" then
							if not string.match(D.Name, "Arm") and not string.match(D.Name, "Hand") and not string.match(D.Name, "Leg") and not string.match(D.Name, "Foot") then if game.Players.LocalPlayer.Backpack.Scripts.Killer.Value == true then if D.Name == "Head" then else D.CanCollide = true end else if D.Name ~= "Shotgun" then D.CanCollide = true  end end end
						end
					end
				else
					for C, D in pairs(V.Character:GetChildren()) do
						if (D:IsA("Part") and (D.Parent:IsA("Hat") or D.Parent:IsA("Accessory")) or D.Name == "Head" or D:IsA("BasePart") or D.Name == "CustomCollision") then
							if D.Name == "HumanoidRootPart" or (D.Name == "LowerTorso") and V.Backpack.Scripts.values.Action.Value == "Hiding" then
								if D.Name ~= "Shotgun" and D.Name ~= "BodyParticleEmitter" and D.Name ~= "TrailParticleEmitter" then
									
									D.CanCollide = true
								end
							else
								D.CanCollide = false
							end
						end
					end
				end
			end
		end
	end)
end)