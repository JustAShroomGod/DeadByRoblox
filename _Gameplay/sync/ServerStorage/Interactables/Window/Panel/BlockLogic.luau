--TODO: Rework this

local module = {}

tweenService = game:GetService("TweenService")

local window = script.Parent.Parent
local LowCollision = window:WaitForChild("LowCollision")
local panel = window.Panel

blocked = panel:WaitForChild("Blocked")
shadowvault = panel:WaitForChild('shadowvault')
vaults = panel:WaitForChild("Vaults")

local maxParts = 8
local maxSizeX = 0.13
local maxSizeY = 5.3
local areaSizeX = 6
local blockTime = 30

local entitySound = nil

if LowCollision:FindFirstChild("EntitySound") then
	entitySound = LowCollision:FindFirstChild("EntitySound")
else
	entitySound = Instance.new("Sound")
	entitySound.Name = "EntitySound"
	entitySound.Parent = LowCollision
	entitySound.RollOffMaxDistance = 65
	entitySound.RollOffMinDistance = 1
	entitySound.Volume = 2.2
	entitySound.SoundId = "rbxassetid://2820713311"
end

local Tendrils, FinishedInteraction, RAISED = {}, false, false
local defaultCFrame = LowCollision.CFrame * CFrame.new(0, LowCollision.Size.Y/2, 0)
local originSizeX = maxSizeX * (math.random(10,19)/10)
local originSizeY = 0 + originSizeX

local function RaiseEntity()
	if RAISED then return end
	
	--warn('BLOCKING WINDOW')
	
	RAISED = true
	
	for i = 1, maxParts do
		local part = Instance.new("Part")
		part.Parent = LowCollision

		part.Anchored = true
		part.CanCollide = false
		part.Color = Color3.fromRGB(29, 12, 0)
		part.Material = Enum.Material.Slate

		part.Size = Vector3.new(originSizeX * 3,0,originSizeY * 3)

		part.CFrame = defaultCFrame * CFrame.new(areaSizeX/2 - (areaSizeX/maxParts * i),0,0)
		part.CFrame = part.CFrame * CFrame.Angles(math.rad(math.random(-10,10)),0,math.rad(math.random(-10,10)))

		local goal = {}
		goal.Size = Vector3.new(originSizeX,maxSizeY,originSizeY)
		goal.CFrame = part.CFrame * CFrame.new(0,maxSizeY/2,0)

		tweenService:Create(part, TweenInfo.new(0.4),goal):Play()
		
		table.insert(Tendrils, part)
	end
	
	task.wait(.3)
	
	FinishedInteraction = true
end

local function LowerEntity(bamlower : BoolValue)
	
	if not shadowvault.Value and not bamlower or bamlower and not blocked.Value then --if no bamboozle then lower it
		
		for _, part in pairs(Tendrils) do
			local goal = {}
			goal.Size = Vector3.new(originSizeX,0,originSizeY)
			goal.CFrame = part.CFrame * CFrame.new(0,-maxSizeY/2,0)

			local tween2 = tweenService:Create(part, TweenInfo.new(0.52),goal)
			tween2:Play()

			local c c = tween2.Completed:Connect(function()
				part:Destroy()
				c:Disconnect()
			end)
		end

		
		Tendrils = {}

		RAISED = false
		
		task.wait(.3)
	end
	
	FinishedInteraction = true
end

function module:BlockWindow(customBlockedTime)
	blocked.Value = true
	
	task.wait(0.5)
	
	entitySound:Play()
	
	FinishedInteraction = false
	
	RaiseEntity()
	
	repeat task.wait()
	until FinishedInteraction
	
	if not customBlockedTime then 
		task.wait(blockTime) 
	else 
		task.wait(customBlockedTime) 
	end
	
	--task.wait(blockTime)

	FinishedInteraction = false
	
	LowerEntity(false)

	repeat task.wait()
	until FinishedInteraction
	
	vaults.Value = 0
	blocked.Value = false
end

function module:Shadow(toggle : BoolValue)
	
	if toggle then
		RaiseEntity()
	else
		LowerEntity(true)
	end
end

return module
