task.wait(1)
local remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
local betterUpdate = remoteEvents:WaitForChild("NewPropertie") 
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local plr = game.Players.LocalPlayer
local char = workspace:WaitForChild(plr.Name)
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")
local NewBoolValue = Instance.new("BoolValue", script)
NewBoolValue.Name = "DoubleLightConnectionCheckIg"
NewBoolValue.Value = false

local OtherSurvivors = {}

local playerGui = plr:WaitForChild("PlayerGui")
repeat task.wait() until (plr:FindFirstChild("Backpack") ~= nil)
local Backpack = plr:WaitForChild("Backpack")
local Scripts = Backpack:WaitForChild("Scripts")
local killer = Scripts:WaitForChild("Killer")
local values = Scripts:WaitForChild("values")
local action = values:WaitForChild("Action")
local movementSpeedScript = Scripts:WaitForChild("MovementSpeedScript")
local movementSpeedScriptMainScript = movementSpeedScript:WaitForChild("MainScript")
local hooked = values:WaitForChild("Hooked")
local shift = movementSpeedScript:WaitForChild("Shift")

local playerscripts = plr:WaitForChild("PlayerScripts")
local controlscript = playerscripts:WaitForChild("ControlScript")
controlscript = require(controlscript:WaitForChild("MasterControl"))

local perksBaseFolder = Scripts:WaitForChild("PerksBase")
local prePerksBase = {"Light Connection"}
local perksBase = {}

Backpack:WaitForChild("Scripts")

--[[for v0, name in pairs (prePerksBase) do
	local this0 = perksBaseFolder:WaitForChild(name)
	local thisTable = {}

	for v1, this1 in pairs (this0:GetChildren()) do
		thisTable[this1.Name] = this1
	end

	perksBase[name] = thisTable
end--]]

local ignored = {"Broken"}
local statusTable = {}

task.wait(3)

runService.Heartbeat:Connect(function()
	if killer.Value then script.Disabled = true return end

	for _, Players in pairs(game.Players:GetPlayers()) do
		if Players.Name ~= plr.Name then
			if (Players:FindFirstChild("Backpack"):FindFirstChild("Scripts"):FindFirstChild("Killer") ~= nil) then
				if Players.Backpack.Scripts.Killer.Value == false then
					local PlayerCheck = true
					for i, C in pairs(OtherSurvivors) do
						if C then
							if C == Players then
								PlayerCheck = false
							end
						end
					end
					if PlayerCheck == true then
						table.insert(OtherSurvivors, Players)
					end
				else
					local PlayerCheck = true
					for i, C in pairs(OtherSurvivors) do
						if C then
							if C == Players then
								PlayerCheck = false
							end
						end
					end
					if PlayerCheck == false then
						for i = 1,#OtherSurvivors do
							if OtherSurvivors[i] == Players then
								table.remove(OtherSurvivors, i)
							end
						end
					end
				end
			end
		end
	end
end)

local PlayersIsDoing = {}
local IsActive = false

script.Parent.Parent.Parent.values.HealthState.Changed:Connect(function()
	if script.Parent.Playing.Value == true and script.Parent.Parent.Parent.values.HealthState.Value == 0 then
		script.Parent.Playing.Value = false
		script.Using.Value = false
		script.Disabled = true
		script.GotDowned.Value = false
	end
end)

while true do
	
	task.wait(0.5)
	
	if script.Disabled == false and script and script.Parent then
		
		if NewBoolValue.Value then
			
			for i, Survivors in pairs(OtherSurvivors) do
				
				if Survivors then
					local CanDo = true
					
					for _, IsInloop in pairs(PlayersIsDoing) do
						if Survivors == IsInloop then
							CanDo = false
						end
					end
					
					if CanDo then
						table.insert(PlayersIsDoing, Survivors)
						local PlayerPreviousState = 2
						local CurrentHealth = Instance.new("NumberValue",script)
						CurrentHealth.Name = Survivors.Name
						CurrentHealth.Value = 2
						
						local UsingThisMan = false
						Survivors.Backpack.Scripts.values.HealthState.Changed:Connect(function()
							CurrentHealth.Value = Survivors.Backpack.Scripts.values.HealthState.Value
							if script.Parent.Parent.Parent.values.HealthState ~= 0 and script.Parent.Parent.Parent.values.Hooked.Value == false then
								if CurrentHealth.Value == 0 and PlayerPreviousState == 1 then
									if IsActive == false and script.Disablede.Value == false then
										if script.Using.Value == true then
											if UsingThisMan then
												script.GotDowned.Value = true
											end
										end
									end
								end
							end
							
							if script.Parent.Parent.Parent.values.HealthState ~= 0 and script.Parent.Parent.Parent.values.Hooked.Value == false then
								if CurrentHealth.Value == 1 and PlayerPreviousState == 2 then
									if IsActive == false and script.Disablede.Value == false then
										if script.Using.Value == false then
											script.Person.Value = Survivors
											script.Using.Value = true
											script.Parent.Playing.Value = true
											UsingThisMan = true
											script.Parent.Playing.Value = true
										end
									end
								end
							end
							
							PlayerPreviousState = Survivors.Backpack.Scripts.values.HealthState.Value
						end)
					end
				end
			end
		end
	end
end