local TweenService : TweenService,ReplicatedStorage : ReplicatedStorage = game:GetService("TweenService"), game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Code = require(Modules:WaitForChild("Code"))
local Events = require(game.ServerScriptService["Event System"].Events)

local Generator : Model = script.Parent.Parent
local Panel : Folder = Generator:WaitForChild("Panel")
local Light = Generator:WaitForChild("Headlight"):WaitForChild("PointLight")
local Body = Generator:WaitForChild("RootPart")

local Values = {
	Popped = Panel:WaitForChild("Popped");
	Progress = Panel:WaitForChild("Progress")
}

local GeneratorsRepaired = workspace:WaitForChild("MatchValues").GeneratorsRepaired

local Repaired = false

local Connections = {}

function createFlash()
	local basePart = Generator:WaitForChild("RootPart")
	
	local flashPart = Instance.new("Part")
	flashPart.Name = "FlashPart"
	flashPart.Parent = basePart
	flashPart.Shape = Enum.PartType.Ball
	
	flashPart.Color = Color3.fromRGB(255,255,255)
	flashPart.Transparency = 1
	flashPart.Anchored = true
	flashPart.CanCollide = false
	flashPart.Material = "Neon"
	flashPart.Size = Vector3.new(0,0,0)
	
	flashPart.CFrame = basePart.CFrame
	
	local goal = {}
	goal.Transparency = 0.7
	goal.Size = Vector3.new(12,12,12)
	
	local tween = TweenService:Create(flashPart,TweenInfo.new(0.25),goal)
	tween:Play()
	
	tween.Completed:Connect(function()
		local goal = {
			Transparency = .7;
			Size = Vector3.new(12,12,12)
		}
		
		local tween = TweenService:Create(flashPart,TweenInfo.new(0.7),goal)
		tween:Play()
		
		tween.Completed:Wait()
		task.wait(1)
		
		local goal = {
			Transparency = 1;
			Size = Vector3.new(0,0,0)
		}
		
		local tween = TweenService:Create(flashPart,TweenInfo.new(0.5),goal)
		tween:Play()
		
		tween.Completed:Wait()
		
		flashPart:Destroy()
	end)
end

local function startEffects()
	Repaired = true

	Values.Popped.Value = true

	TweenService:Create(Generator.LightsA, TweenInfo.new(1.2), {Transparency = 0, Color = script:GetAttribute("OnColor3")}):Play()
	TweenService:Create(Generator.LightsB, TweenInfo.new(1.2), {Transparency = 0, Color = script:GetAttribute("OnColor3")}):Play()

	--script.Parent.Parent.Xmas.Lights.Material = Enum.Material.Neon --xmas
	Light.Enabled = true
	createFlash()


	-- Removing this so I can re-activate gens | Verox
	--for _,Connection in pairs(Connections) do
		--Connection:Disconnect()
		--Connection = nil
	--end
end

function RecountCompleteGens()
	
	local complete = 0
	
	for i, obj in pairs(workspace:GetChildren()) do
		if (not string.find(obj.Name, "Generator")) then
			continue
		end
		
		if (obj.Panel.Progress.Value < 1000) then
			continue
		end
		
		complete += 1
	end
	
	GeneratorsRepaired.Value = complete
end
 
Connections.Progress = Values.Progress.Changed:Connect(function()
	if Values.Progress.Value >= 1000 and not Repaired then
		GeneratorsRepaired.Value += 1

		for i, plr in pairs(game.Teams.Killer:GetPlayers()) do
			Code:AddNotification(Generator:WaitForChild("RootPart").CFrame, 5, "Generator", plr) -->> notify killers
		end
		
		startEffects()
		return
	end
	
	if (Values.Progress.Value < 1000 and Repaired) then
		
		Values.Popped.Value = false
		Repaired = false
		
		if (Generator.RootPart:FindFirstChild("FlashPart") ~= nil) then
			Generator.RootPart:FindFirstChild("FlashPart"):Destroy()
		end
		
		TweenService:Create(Generator.LightsA, TweenInfo.new(1.2), {Transparency = 0, Color = script:GetAttribute("OffColor3")}):Play()
		TweenService:Create(Generator.LightsB, TweenInfo.new(1.2), {Transparency = 0, Color = script:GetAttribute("OffColor3")}):Play()
		Light.Enabled = false
		
		RecountCompleteGens()
		return
	end
end)

Connections.GeneratorsRepaired = GeneratorsRepaired:GetPropertyChangedSignal("Value"):Connect(function()
	if GeneratorsRepaired.Value >= 5 then
		startEffects()
	end
end)