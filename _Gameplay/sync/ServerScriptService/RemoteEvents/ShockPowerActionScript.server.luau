local remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
local remoteEvent = Instance.new("RemoteEvent", remoteEvents) remoteEvent.Name = string.gsub(script.Name,"Script","")
local ObjValue = Instance.new("ObjectValue", game.ReplicatedStorage)
ObjValue.Name = "DoctorStuffYes"
ObjValue.Value = remoteEvent
local tweenService = game:GetService("TweenService")

remoteEvent.OnServerEvent:Connect(function(plr, rootPart)
	local function createParticle (basePart, particlesFolder, number, maxParticles, zIndex, dirIndex, connectionValue) 
		local maxDistace = 30

		local part = Instance.new("Part", particlesFolder)
		part.Anchored = true
		part.CanCollide = false
		part.Color = Color3.fromRGB(178, 232, 255) 
		part.Material = Enum.Material.Neon 
		part.Transparency = 1

		local thisNumber = 1
		if maxParticles > 2 then
			local function negativeAlgorithm (maximum, runNumber)
				if runNumber < maximum then
					thisNumber = thisNumber * -1
					runNumber = runNumber  + 1
					negativeAlgorithm(maximum, runNumber)
				else
					--print(thisNumber)
				end
			end

			negativeAlgorithm(number,0)
		else 
			thisNumber = 0
		end

		local thisNegativeness 
		local thisNRange = math.random(1,2) 
		local newRotY

		if thisNRange == 1 then 
			thisNegativeness = 1 
		else 
			thisNegativeness = -1 
		end

		if thisNumber > 0 then
			newRotY = math.random(45,70) * (thisNumber * thisNegativeness)
		else
			newRotY = math.random(45,70)
		end

		if number < 1 then
			--print("set")
			if dirIndex > 2 and dirIndex < 8 then
				part.CFrame = (basePart.CFrame * CFrame.new(math.random(-2,2),0,-(maxDistace/5) * zIndex))
			else
				part.CFrame = (basePart.CFrame * CFrame.new(math.random(-0.8,0.8),0,-(maxDistace/5) * zIndex))
			end
		else
			part.CFrame = basePart.CFrame
		end  


		local function shockPlayer ()
			local shock_distance = 8
			for v0, player in pairs (game.Players:GetChildren()) do
				local playerCharacter = player.Character
				if playerCharacter and player.Name ~= plr.Name then
					local playerRootPart = playerCharacter:FindFirstChild("HumanoidRootPart")
					if playerRootPart then
						local pointCFrame = part.CFrame * CFrame.new(0, 0, -1.5) 
						local distance = (pointCFrame.Position - playerRootPart.CFrame.Position).magnitude --print(distance)
						if distance < shock_distance then 
							local continue = true

							local playerStuff = {}
							playerStuff["Backpack"] = player:FindFirstChild("Backpack")
							playerStuff["Humanoid"] = playerCharacter:FindFirstChild("Humanoid")
							if playerStuff["Backpack"] then 
								playerStuff["Scripts"] = playerStuff["Backpack"]:FindFirstChild("Scripts")

								if playerStuff["Scripts"] then 
									playerStuff["values"] = playerStuff["Scripts"]:FindFirstChild("values")

									if playerStuff["values"] then  
										playerStuff["HealthState"] = playerStuff["values"]:FindFirstChild("HealthState")
										playerStuff["Action"] = playerStuff["values"]:FindFirstChild("Action")
										playerStuff["Hooked"] = playerStuff["values"]:FindFirstChild("Hooked")

										if playerStuff["HealthState"] then 
											playerStuff["GotHit"] = playerStuff["HealthState"]:FindFirstChild("GotHit")  
										end
									end
								end 
							end

							if continue == true then
								if playerStuff["HealthState"].Value > 0 
									and playerStuff["Hooked"].Value == false 
									and playerStuff["GotHit"].Value == false then
									if playerStuff["Action"].Value ~= "DeadHard" then  
										playerStuff["GotHit"].Value = true
										playerStuff["Action"].Value = "Shocked"
										local shockAnimation = Instance.new("Animation", playerStuff["Humanoid"]) 
										shockAnimation.AnimationId = "rbxassetid://".. tostring(3084587541)

										local shockAnimTrack = playerStuff["Humanoid"]:LoadAnimation(shockAnimation)
										shockAnimTrack:Play()
										shockAnimTrack:AdjustSpeed(2)

										local stopCon stopCon = shockAnimTrack.Stopped:Connect(function() 
											stopCon:Disconnect()
											shockAnimation:Destroy()

											if playerStuff["GotHit"] then 
												playerStuff["GotHit"].Value = false
											end

											task.wait(1.5)

											if playerStuff["Action"] then 
												playerStuff["Action"].Value = "Nothing"
											end 
										end) 
									end
								end
							end
						end
					end
				end
			end 
		end

		shockPlayer()

		part.CFrame = part.CFrame * CFrame.new(0,0,-basePart.Size.Z/2) * CFrame.Angles(0, math.rad(newRotY),math.rad(math.random(0,180))) 
		part.Size = Vector3.new(0.01,0.01, 0)

		local goal = {}
		goal.CFrame = part.CFrame  * CFrame.new(0,0,-basePart.Size.Z/2)
		goal.Size = Vector3.new(0.01,0.01, (0.55))
		goal.Transparency = 0 --goal.CFrame = part.CFrame * CFrame.new(0,0,-1)

		local tween = tweenService:Create(part, TweenInfo.new(0.05), goal)
		tween:Play()

		local tweenCon
		tweenCon = tween.Completed:Connect(function() 
			if number < maxParticles then
				number = number + 1

				createParticle(part, particlesFolder, number, maxParticles, zIndex, nil, connectionValue)

				local goal = {}
				goal.Transparency = 1

				local tween2 = tweenService:Create(part, TweenInfo.new(1), goal)
				tween2:Play()

				local tweenCon2
				tweenCon2 = tween2.Completed:Connect(function()
					part:Destroy()
					tweenCon2:Disconnect()
					tweenCon:Disconnect()	
				end)
			else
				connectionValue.Value = true
				local goal = {}
				goal.Transparency = 1

				local tween2 = tweenService:Create(part, TweenInfo.new(1), goal)
				tween2:Play()

				local tweenCon2 tweenCon2 = tween2.Completed:Connect(function()
					part:Destroy()
					tweenCon2:Disconnect()
					tweenCon:Disconnect()	
				end)
			end
		end)
	end

	local function createParticleArea ()
		local maxAreaRange = 70
		local maxDirections = 9

		local particlesFolder = Instance.new("Folder", workspace)
		local basePart = Instance.new("Part", particlesFolder) 
		basePart.Anchored = true 
		basePart.CanCollide = false 
		basePart.Transparency = 1

		local baseCFrame = rootPart.CFrame * (CFrame.new(0,-2,0)) * CFrame.Angles(0,math.rad(-(maxAreaRange/maxDirections)*(math.floor(maxDirections/2)+1)),0)
		basePart.CFrame = baseCFrame 
		basePart.Size = Vector3.new(0.5,0.5,0.5)

		local thisIndex = 0
		local maxThisIndex = 5
		local function indexEvent ()
			local connectionValue = Instance.new("BoolValue", script)
			for rI = 1, maxDirections do
				--if rI == 1 or rI == (math.floor(maxDirections/2)) + 1 or rI == maxDirections then
				--print(rI)
				baseCFrame = rootPart.CFrame * (CFrame.new(0,-2,0)) * CFrame.Angles(0,math.rad(-(maxAreaRange/maxDirections)*(math.floor(maxDirections/2)+1)),0)
				basePart.CFrame = baseCFrame * CFrame.Angles(0,math.rad((maxAreaRange/maxDirections) * (rI)),0)
				local maxParticles = math.random(2,3)
				createParticle(basePart, particlesFolder, 0, maxParticles, thisIndex, rI, connectionValue)
				--end
			end

			if thisIndex < maxThisIndex then
				local con
				con = connectionValue.Changed:Connect(function()
					indexEvent()
					connectionValue:Destroy()
					con:Disconnect()
				end)

				thisIndex = thisIndex + 1
			end
		end
		indexEvent()

		task.wait(3)
		particlesFolder:Destroy()
	end

	createParticleArea()
end)