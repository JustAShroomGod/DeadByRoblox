tweenService = game:GetService("TweenService")

local blackParticle = script.Parent:WaitForChild("BlackParticle")
local orangeParticle = script.Parent:WaitForChild("OrangeParticle")

local collision = script.Parent.Parent

local maxParts = 10
local maxSizeX = 0.13
maxSizeY = 6

for i = 1, maxParts do
	
	local part = Instance.new("Part")
	part.Parent = collision
	
	part.Anchored = true
	part.CanCollide = false
	part.Color = Color3.fromRGB(255, 86, 1)
	part.Material = Enum.Material.Neon
	
	local originSizeX = maxSizeX * (math.random(10,19)/10)
	local originSizeY = 0 + originSizeX 
	
	part.Size = Vector3.new(originSizeX * 3,0,originSizeY * 3)
	 
	part.CFrame = script.Parent.CFrame * CFrame.new(7/2 - (7/maxParts * i),0,0)
	part.CFrame = part.CFrame * CFrame.Angles(math.rad(math.random(-10,10)),0,math.rad(math.random(-10,10)))
	
	local goal = {}
	goal.Size = Vector3.new(originSizeX,maxSizeY,originSizeY)
	goal.CFrame = part.CFrame * CFrame.new(0,maxSizeY/2,0)
	
	local tween = tweenService:Create(part, TweenInfo.new(0.24),goal)
	tween:Play()
	
	local connection1 = nil
	connection1 = tween.Completed:Connect(function()
		
		local goal2 = {}
		goal2.Color = Color3.fromRGB(29, 12, 0)
		
		local tween2 = tweenService:Create(part, TweenInfo.new(1),goal2)
		tween2:Play()
		
		local connection3 = nil
		connection3 = tween2.Completed:Connect(function()
			
			part.Material = Enum.Material.Slate
			
			connection3:Disconnect()
			
		end)
		
		task.wait(0.9)
		
		local goal = {}
		goal.Size = Vector3.new(originSizeX,0,originSizeY)
		goal.CFrame = part.CFrame * CFrame.new(0,-maxSizeY/2,0)
		
		local tween2 = tweenService:Create(part, TweenInfo.new(0.52),goal)
		tween2:Play()
		
		local connection2 = nil
		connection2 = tween2.Completed:Connect(function()
			
			part:Destroy()
			
			connection1:Disconnect()
			connection2:Disconnect()
			
		end) 
		
	end) 
	
end

task.wait(1.5)

blackParticle.Enabled = false
orangeParticle.Enabled = false

task.wait(5)

script.Parent:Destroy()

return
