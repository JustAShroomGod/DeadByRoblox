local ServerStorage = game:GetService('ServerStorage')
local tanglesPrefab = ServerStorage:WaitForChild('Dependicies'):WaitForChild('Tangles')
local objectSpawnCFrame = tanglesPrefab.PrimaryPart.CFrame:ToObjectSpace(tanglesPrefab.SpawnLocation.CFrame)

local module = {}

function module.KillCharacter(character)
	local characterAngles = CFrame.Angles(character.PrimaryPart.CFrame:ToOrientation())
	local metaCFrame = CFrame.new(character.PrimaryPart.CFrame.p)*CFrame.new(0, -script:GetAttribute("RootSize"), 0)
		*characterAngles
	local starterCFrame = metaCFrame*CFrame.new(0, script:GetAttribute("TanglesOffset"), 0)

	local tangles = tanglesPrefab:Clone()
	tangles.Parent = workspace
	tangles.PrimaryPart.CFrame = starterCFrame
	character.PrimaryPart.CFrame = metaCFrame*objectSpawnCFrame

	local anchor = Instance.new("Part", tangles)
	anchor.CFrame = starterCFrame
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.Transparency = 1

	local weld = Instance.new("WeldConstraint", tangles)		--		already child of tangles
	weld.Part0 = anchor
	weld.Part1 = character.PrimaryPart

	task.spawn(function ()
		local tanglesAnimtrack = tangles.AnimationController.Animator:LoadAnimation(script.TanglesKill)
		tanglesAnimtrack:Play(0)
		tanglesAnimtrack.Stopped:Wait()
		tanglesAnimtrack:Play(0, 1, 0)
		tanglesAnimtrack.TimePosition = tanglesAnimtrack.Length-1/100
	end)

	task.spawn(function ()
		local tweenInfo = TweenInfo.new(script:GetAttribute("Time"), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		local tween = game:GetService("TweenService"):Create(tangles.PrimaryPart, tweenInfo, {CFrame = metaCFrame})
		tween:Play()
		tween.Completed:Wait()
	end)
	
	local survivorAnimtrack = character.Humanoid:LoadAnimation(script.SurvivorTanglesDeath)
	survivorAnimtrack:Play(0)
	survivorAnimtrack.Stopped:Wait()
	survivorAnimtrack:Play(0, 1, 0)
	survivorAnimtrack.TimePosition = survivorAnimtrack.Length-1/100

	return tangles
end

return module