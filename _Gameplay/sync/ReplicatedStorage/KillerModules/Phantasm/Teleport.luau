local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = game.Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid
local Camera = workspace.CurrentCamera

local PowerModel = Character:WaitForChild("Dark Presence")
local PowerValues = PowerModel:WaitForChild("PowerValues")
local PhantomModel = nil
local Arrow = game.ReplicatedStorage.KillerStuff.Phantasm.Arrow

local Scripts = Player.Backpack.Scripts
local KillerAction = Scripts.values.KillerAction

local Code = require(game.ReplicatedStorage.Modules.Code)

local DefaultPriority = 3

local Action = {
	Key = "Secondary_Power";
	ActionName = "Teleport";
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		CurrentTarget = nil;
		TargetDistance = 0;
		BaseSize = Vector3.zero;
	},
	Debounces = {
		LastTeleport = workspace:GetServerTimeNow();
		LastUpdate = workspace:GetServerTimeNow();
		InputEnter = tick();
		Deploying = false;
		Exiting = false;
		Holding = false;
	},
	Connections = {},
}

function Init()
	Action.ActionInfo.BaseSize = Arrow.Size
	RunService.Heartbeat:Connect(UpdateArrow)
	Arrow.Parent = workspace
end

function UpdateTarget()
	if not PhantomModel then
		PhantomModel = workspace:WaitForChild("PhantomModel")
	end
	
	if (Action.Debounces.LastUpdate > workspace:GetServerTimeNow()) then
		return
	end
	
	Action.Debounces.LastUpdate = workspace:GetServerTimeNow() + 0.05
	
	local dist = 9999
	
	for _, Phantom in pairs(PhantomModel:GetChildren()) do
		
		if (not Phantom:IsA("Model")) then
			continue
		end
		
		if (GetAngleDiff(Phantom) > dist) then
			continue
		end
		
		if (not Phantom:GetAttribute("Deployed")) then
			continue
		end
		
		dist = GetAngleDiff(Phantom)
		
		Action.ActionInfo.CurrentTarget = Phantom
		Action.ActionInfo.TargetDistance = GetDistanceXZ(Phantom)
	end
	
end

function UpdateArrow()
	
	UpdateTarget()
	
	if (Action.ActionInfo.CurrentTarget == nil) then
		Arrow.Transparency = 1
		return
	end
	
	if (Action.ActionInfo.CurrentTarget.Parent == nil) then
		Action.ActionInfo.CurrentTarget = nil
		Action.ActionInfo.TargetDistance = 0
		Arrow.Transparency = 1
		return
	end
	
	Action.ActionInfo.TargetDistance = GetDistanceXZ(Action.ActionInfo.CurrentTarget)
	
	local Offset = 5.5 / 30 * Action.ActionInfo.TargetDistance
	Offset = math.clamp(Offset, 5.5, 12)
	
	local position: Vector3 = Action.ActionInfo.CurrentTarget.PrimaryPart.CFrame.Position
	position = Vector3.new(position.X, position.Y + Offset, position.Z)
	
	local direction = (position - Character.PrimaryPart.CFrame.Position)
	direction = Vector3.new(direction.X, 0, direction.Z)
	direction *= 5
	
	Arrow.Transparency = 0
	Arrow.Size = Action.ActionInfo.BaseSize / 40 * Action.ActionInfo.TargetDistance
	Arrow.CFrame = CFrame.new(position, (position + direction))
end

function GetDistanceXZ(OtherCharacter: Model)

	if (OtherCharacter == nil) then
		return 999
	end

	local PositionLocal = Character.PrimaryPart.CFrame.Position
	PositionLocal = Vector3.new(PositionLocal.X, 0, PositionLocal.Z)

	local PositionTarget = OtherCharacter.PrimaryPart.CFrame.Position
	PositionTarget = Vector3.new(PositionTarget.X, 0, PositionTarget.Z)

	return (PositionLocal - PositionTarget).Magnitude
end

function GetAngleDiff(OtherCharacter: Model)
	local Direction = CFrame.new(Character.PrimaryPart.CFrame.Position, OtherCharacter.PrimaryPart.CFrame.Position).LookVector
	local Angle = (Direction - Camera.CFrame.LookVector).Magnitude
	
	return Angle
end

Init()

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	
	if not actionList.KillerInfo then
		
		actionList.KillerInfo = {
			LastSwing = (Player.Character:GetAttribute("SwingEnd") or 0);
		}
	end
	
	if (not Player.Character:GetAttribute("IntroDone")) then
		return false
	end
	
	if (KillerAction.Value == "Nothing")
		and not Player.Character:GetAttribute("Carry")
		and not Player.Character:GetAttribute("Swing")
		and (currentValues.Parent:WaitForChild("BLOODPOINT"):FindFirstChild("REMOVE") ~= nil)
		and not currentValues.Stunned.Value
		and Action.Debounces.LastTeleport < workspace:GetServerTimeNow()
		and Action.ActionInfo.CurrentTarget ~= nil then
		
		CanRun = true
	elseif Action.Debounces.Deploying then -- if in progress do not let go of this interaction
		
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	Arrow.Transparency = if (CanRun) then 0 else 1

	return CanRun
end

function Action:Start(...) : "Start Action?"
	--if (tick() - Action.Debounces.InputEnter) < 1 or Action.Debounces.Deploying then return warn("Anti-Spam") end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Deploying = true
	Action.Debounces.Holding = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	
	local Character = Player.Character
	
	Action.Debounces.LastTeleport = workspace:GetServerTimeNow() + 10
	
	PowerValues.PowerRemote:FireServer("Teleport", Action.ActionInfo.CurrentTarget)
	
	coroutine.wrap(function()
		TweenSpeed(((PowerValues:GetAttribute("Teleport_Boost_Percentage") / 100) + 1), PowerValues:GetAttribute("Teleport_Curve"))
		task.wait((PowerValues:GetAttribute("Teleport_Curve") + PowerValues:GetAttribute("Teleport_Boost_Duration")))
		
		Character:SetAttribute("PostTP", true)
		TweenSpeed((PowerValues:GetAttribute("Teleport_Slow_Percentage") / 100), 1)
		task.wait(PowerValues:GetAttribute("Teleport_Slow_Duration"))
		
		TweenSpeed(1, 0.5)
		Character:SetAttribute("PostTP", false)
	end)()
	
end

function Action:Stop(...) : "Stop Action?"
	--if not Action.ActionInfo.Disconnect or Action.Debounces.Exiting then return warn('Anti-Spam Exit') end -- if we don't have disconnect do not trigger
	Action.Debounces.Exiting = true
	Action.Debounces.Holding = false
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	
	local Character = Player.Character
	
	Action.Debounces.Exiting = false
	Action.Debounces.Deploying = false
	Action.Priority = DefaultPriority
	--modules.UI:Hide(false)
	
end

function Action:Process(...) : boolean | "Returns true if this action can be ran"
	local args = {...}
	local actionList, remoteList = args[1], args[2]

	if Constraints(actionList) then
		return true
	end

	return false
end

function TweenSpeed(Percentage, TweenDuration)
	
	if (Action.Connections["SpeedTween"] ~= nil) then
		Action.Connections["SpeedTween"]:Cancel()
		Action.Connections["SpeedTween"] = nil
	end
	
	local Speed = Code:GetPlayerValue(Player, "Speed") * Code:GetPlayerValue(Player, "SpeedMultiplier")
	Speed *= Percentage
	
	Action.Connections["SpeedTween"] = TweenService:Create(Player.Character.Humanoid, TweenInfo.new(TweenDuration), {WalkSpeed = Speed})
	Action.Connections["SpeedTween"]:Play()
	
	local completed
	completed = Action.Connections["SpeedTween"].Completed:Connect(function()
		completed:Disconnect()
		completed = nil
		Action.Connections["SpeedTween"] = nil
	end)
	
end

function SetAction(action)
	
	if (table.find(Action.ValidActions, KillerAction.Value) == nil) then
		return
	end
	
	PowerValues.PowerRemote:FireServer("Action", action)
end

function SetValue(Attribute, Value)
	PowerValues.PowerRemote:FireServer("SetValue", Attribute, Value)
end

function updateAttributes(currentValues)
	
	local Character = Player.Character

end

return Action
