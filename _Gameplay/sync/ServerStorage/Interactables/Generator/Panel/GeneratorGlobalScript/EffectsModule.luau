local module = {}

	local tweenService = game:GetService("TweenService")
	
	function module:Sparkles()
		
		local generator = script.Parent.Parent.Parent
		local generatorBody = generator:WaitForChild("Mass")
		
		local function createParticle (basePart, particlesFolder, number, maxParticles)
			local maxDistace = 27
			local part = Instance.new("Part", particlesFolder) part.Anchored = true part.CanCollide = false
			part.Color = Color3.fromRGB(178, 232, 255) part.Material = Enum.Material.Neon part.Transparency = 1
			local thisNumber = 1
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

			local thisNegativeness local thisNRange = math.random(1,2) if thisNRange == 1 then thisNegativeness = 1 else thisNegativeness = -1 end
			local newRotY
			if thisNumber > 0 then
				 newRotY = math.random(45,70) * (thisNumber * thisNegativeness)
			else
				newRotY = math.random(45,70)
			end
			
			part.CFrame = basePart.CFrame

			part.CFrame = part.CFrame * CFrame.new(0,0,-basePart.Size.Z/2) * CFrame.Angles(0, math.rad(newRotY),math.rad(math.random(0,180))) 
			part.Size = Vector3.new(0.01,0.01, 0) 
			local goal = {} goal.CFrame = part.CFrame  * CFrame.new(0,0,-basePart.Size.Z/2)
			goal.Size = Vector3.new(0.01,0.01, (0.55))
			goal.Transparency = 0
			local tween = tweenService:Create(part, TweenInfo.new(0.05), goal) tween:Play()
			local tweenCon tweenCon = tween.Completed:Connect(function()
				if number < maxParticles then
					number = number + 1		
					createParticle(part, particlesFolder, number, maxParticles)
					
					local goal = {} goal.Transparency = 1
					local tween2 = tweenService:Create(part, TweenInfo.new(1), goal) tween2:Play()
					local tweenCon2 tweenCon2 = tween2.Completed:Connect(function()
						part:Destroy()
						tweenCon2:Disconnect()
						tweenCon:Disconnect()	
					end)
				else
					particlesFolder:Destroy()
				end
			end)
		end
		
		local function createParticleArea ()
			local particlesFolder = Instance.new("Folder", workspace)
			local basePart = Instance.new("Part", particlesFolder) basePart.Anchored = true basePart.CanCollide = false basePart.Transparency = 1
			local maxAreaRange = 70
			local maxDirections = 7
			basePart.CFrame = generatorBody.CFrame * CFrame.Angles(0,math.rad(-(maxAreaRange/maxDirections)*(math.floor(maxDirections/2)+1)),0) 
			local baseCFrame = basePart.CFrame * CFrame.new(-basePart.Size.X/2,0,0)
			basePart.Size = Vector3.new(0.5,0.5,0.5)
			
			local thisIndex = 0
			local maxThisIndex = 5
			
			createParticle(basePart, particlesFolder, 0, math.random(3,5))

		end
		
		createParticleArea()
		
	end

return module
