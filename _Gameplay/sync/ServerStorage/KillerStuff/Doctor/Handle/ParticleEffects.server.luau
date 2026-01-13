local tweenService = game:GetService("TweenService")
local particlesFolder = Instance.new("Folder", workspace)
local basePart = script.Parent
local i = false repeat
	wait(0.3)
	for i = 1, 5 do
		spawn(function()   
			local part = Instance.new("Part", particlesFolder) part.Anchored = false part.CanCollide = false
			part.Color = Color3.fromRGB(178, 232, 255) part.Material = Enum.Material.Neon part.Transparency = 1
			part.CFrame = basePart.CFrame * CFrame.new(-0.4,0,0) * CFrame.Angles(math.rad(math.random(-180, 180)),0,0)
			* CFrame.new(math.random(-150,150)/100, 0, math.random(3, 10)/10) * CFrame.Angles(math.rad(90),math.rad(math.random(-45,45)),0)
			part.Size = Vector3.new(0.05, 0.05, 0.05) local weld = Instance.new("WeldConstraint", part)
			weld.Part0 = basePart weld.Part1 = part
			local goal = {} goal.Size = Vector3.new(0.05, 0.05, 0.7) goal.Transparency = 0
			local tween = tweenService:Create(part, TweenInfo.new(0.28), goal) tween:Play()
			wait(0.5) part:Destroy()
		end)
	end
		
until i == true