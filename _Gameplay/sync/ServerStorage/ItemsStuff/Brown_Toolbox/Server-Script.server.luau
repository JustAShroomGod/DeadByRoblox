local RunService : RunService = game:GetService("RunService")

local Character : Model = script.Parent.Parent
local Tool : Model = script.Parent

local Item_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Items')
local Item_Module = require(Item_Data:WaitForChild(Tool.Name))

local Player : Player = game:GetService('Players'):GetPlayerFromCharacter(Character)
local Using : BoolValue = Tool:WaitForChild('Using')

local DefaultCFrame : CFrame = CFrame.new(0, -0.5, 0) * CFrame.Angles(0, math.rad(90), 0)

Tool:WaitForChild("Handle").CFrame = Character:WaitForChild("RightHand").CFrame * DefaultCFrame

local Weld : Weld = Instance.new("WeldConstraint", Tool)
Weld.Name = "Weld"
Weld.Part0 = Character:WaitForChild("RightHand")
Weld.Part1 = Tool:WaitForChild("Handle")

local playerValues = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')
local LoopConnection = nil

function WhichUse() : string | "Returns what we are using toolbox on"
	
	if playerValues.Action.Value == "ToolBoxRepair" then
		return "Repair"
	elseif playerValues.Action.Value == "Sabotaging" then
		return "Sabotage"
	end
	
	return "Nothing"
end

function CalculateUse() : number | "Returns use speed"
	local CurrentUse = WhichUse()
	
	if CurrentUse == "Nothing" then return 0 end
	
	local Calculation = 0
	local ChargeSubtract = 0
	
	if CurrentUse == "Repair" then
		ChargeSubtract = (Item_Module.Repair_Drain/script.Charges.Value) * 1000
		Calculation = ChargeSubtract
	elseif CurrentUse == "Sabotage" then
		ChargeSubtract = (Item_Module.Sabatage_Drain/script.Charges.Value) * 1000
		Calculation = ChargeSubtract
	end

	return Calculation
end

function CanUse() : boolean | "Returns true if action can be done"
	local State = Character.Humanoid:GetState()

	if playerValues.Hooked.Value
		or Tool:GetAttribute("Progress") <= 0
		or State == Enum.HumanoidStateType.FallingDown
		or State == Enum.HumanoidStateType.Landed
		or playerValues.HealthState.Value <= 0
		or playerValues.Holded.Value
		or not Using.Value then

		return false
	end
	
	if playerValues.Action.Value == "Nothing"
		or playerValues.Action.Value == "Sabotaging"
		or playerValues.Action.Value == "ToolBoxRepair" then
		
		return true
	end
	
	return false
end

function Update(t, step)
	local FrameSubtract, Current_Progress = (CalculateUse() * step), Tool:GetAttribute("Progress")
	
	if CanUse() then
		Tool:SetAttribute('Progress', math.clamp(Current_Progress - FrameSubtract, 0, 1000))
	else
		if LoopConnection then LoopConnection:Disconnect() LoopConnection = nil end
	end
end
local HasDone = false
Using.Changed:Connect(function()

	if Using.Value then
		if HasDone == false then HasDone = true
			local Flashlight = script.Parent
			local Total_Charges = Item_Module.Charges
			local Total_SSpeed = Item_Module.Sabatage_Speed_Multiplier
			local Total_RSpeed = Item_Module.Repair_Speed_Multiplier
			local Addon_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Survivor')
			local addon_1, addon_2 = Flashlight:GetAttribute("Addon_1"), Flashlight:GetAttribute("Addon_2")
			if addon_1 and addon_1 ~= "" then
				addon_1 = Addon_Data:FindFirstChild(addon_1)

				if addon_1 then
					addon_1 = require(addon_1)

					if addon_1.Charges then
						Total_Charges += addon_1.Charges
					end

					if addon_1.RSpeed then
						Total_RSpeed += addon_1.RSpeed
					end

					if addon_1.SSpeed then
						Total_SSpeed += addon_1.SSpeed
					end

				end
			end

			if addon_2 and addon_2 ~= "" then
				addon_2 = Addon_Data:FindFirstChild(addon_2)

				if addon_2 then
					addon_2 = require(addon_2)

					if addon_2.Charges then
						Total_Charges += addon_2.Charges
					end

					if addon_2.RSpeed then
						Total_RSpeed += addon_2.RSpeed
					end

					if addon_2.SSpeed then
						Total_SSpeed += addon_2.SSpeed
					end

				end
			end
			Flashlight['Server-Script'].Charges.Value = Total_Charges
			Flashlight['Server-Script'].Speed.Value = Total_SSpeed
			Flashlight['Server-Script'].RepairSpeed.Value = Total_RSpeed
		end
		
		if LoopConnection then LoopConnection:Disconnect() LoopConnection = nil end
		LoopConnection = RunService.Stepped:Connect(Update)
	else
		if LoopConnection then LoopConnection:Disconnect() LoopConnection = nil end
	end
end)


wait(1)
local Flashlight = script.Parent
local Total_Charges = Item_Module.Charges
local Total_SSpeed = Item_Module.Sabatage_Speed_Multiplier
local Total_RSpeed = Item_Module.Repair_Speed_Multiplier
local Addon_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Survivor')
local addon_1, addon_2 = Flashlight:GetAttribute("Addon_1"), Flashlight:GetAttribute("Addon_2")
if addon_1 and addon_1 ~= "" then
	addon_1 = Addon_Data:FindFirstChild(addon_1)

	if addon_1 then
		addon_1 = require(addon_1)

		if addon_1.Charges then
			Total_Charges += addon_1.Charges
		end

		if addon_1.RSpeed then
			Total_RSpeed += addon_1.RSpeed
		end

		if addon_1.SSpeed then
			Total_SSpeed += addon_1.SSpeed
		end

	end
end

if addon_2 and addon_2 ~= "" then
	addon_2 = Addon_Data:FindFirstChild(addon_2)

	if addon_2 then
		addon_2 = require(addon_2)

		if addon_2.Charges then
			Total_Charges += addon_2.Charges
		end

		if addon_2.RSpeed then
			Total_RSpeed += addon_2.RSpeed
		end

		if addon_2.SSpeed then
			Total_SSpeed += addon_2.SSpeed
		end

	end
end
Flashlight['Server-Script'].Charges.Value = Total_Charges
Flashlight['Server-Script'].Speed.Value = Total_SSpeed
Flashlight['Server-Script'].RepairSpeed.Value = Total_RSpeed
