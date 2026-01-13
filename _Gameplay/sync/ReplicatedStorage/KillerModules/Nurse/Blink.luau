local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = game.Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid
local Blink = Character.Blink

local Scripts = Player.Backpack.Scripts
local KillerAction = Scripts.values.KillerAction

local Code = require(game.ReplicatedStorage.Modules.Code)

local DefaultPriority = 3

local Action = {
	Key = "Interact3";
	ActionName = "Blink";
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		PortOffset = 6;
		TravelTime = 0.7;
		CollisionRadius = 0.75;
	},
	Debounces = {
		InputEnter = tick();
		Deploying = false;
		Exiting = false;
		CanBlink = true;
		Holding = false;
	},
	States = {
		["Idle"] = 0;
		["Charging"] = 1;
		["Teleporting"] = 2;
		["Fatigue"] = 3;
		["ChainCharge"] = 4;
		["PostBlink"] = 5;
	},
	Power = {},
	Limits = {},
	Connections = {},
	CollisionMap = {},
	PositionOrb = nil,
	Visual = require(script.Visual),
	ValidActions = {"Nothing", "BlinkAction", "Fatigue"}
}

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	
	if not actionList.KillerInfo then
		
		actionList.KillerInfo = {
			LastSwing = (Player.Character:GetAttribute("SwingEnd") or 0);
		}
	end
	
	updateAttributes(currentValues)
	
	if (KillerAction.Value == "Nothing" or KillerAction.Value == "BlinkAction")
		and not Player.Character:GetAttribute("Carry")
		and not Player.Character:GetAttribute("Swing")
		and (currentValues.Parent:WaitForChild("BLOODPOINT"):FindFirstChild("REMOVE") ~= nil)
		and not currentValues.Stunned.Value
		and (Action.Power.State == Action.States.Idle 
			or Action.Power.State == Action.States.PostBlink
			or Action.Power.State == Action.States.Teleporting
			or Action.Power.State == Action.States.Charging)
		and (Action.Power.Blinks > 0)
		and not Action.Power.BlinkAttack then
		
		CanRun = true
	elseif Action.Debounces.Deploying then -- if in progress do not let go of this interaction
		
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

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
	local Blink = Character.Blink

	repeat task.wait()
	until (Action.PositionOrb == nil and (Action.Connections["Charge"] == nil or not Action.Debounces.Deploying))
	
	repeat task.wait()
	until ((Action.Power.State == Action.States.Idle or Action.Power.State == Action.States.PostBlink) and Action.Debounces.CanBlink)
	
	if (not Action.Debounces.Holding) then
		return
	end
	
	modules.UI:Hide(true)
	
	if (Action.Connections["Charge"] == nil) then
		SetState(Action.States.Charging)
		SetAction("BlinkAction")
		CreateOrb()
		
		Action.Power.ChargedDistance = 0
		Action.Visual.StartCharge()
		game.ReplicatedStorage.RemoteEvents.ChaseUpdater:FireServer("Disrupt", true)
		Action.Connections["Charge"] = RunService.Heartbeat:Connect(ChargeBlink)
	end
	
end

function Action:Stop(...) : "Stop Action?"
	--if not Action.ActionInfo.Disconnect or Action.Debounces.Exiting then return warn('Anti-Spam Exit') end -- if we don't have disconnect do not trigger
	Action.Debounces.Exiting = true
	Action.Debounces.Holding = false
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	
	local Character = Player.Character
	local Blink = Character.Blink

	repeat task.wait()
	until (Action.Power.State == Action.States.Charging or Action.Power.State == Action.States.PostBlink) and Action.Debounces.CanBlink and Action.Connections["Charge"] ~= nil
	
	repeat task.wait()
	until not Action.Debounces.Holding
	
	if (Action.Connections["Charge"] ~= nil) then
		Action.Connections["Charge"]:Disconnect()
		Action.Connections["Charge"] = nil
		Action.Visual.StopCharge()
		
		Teleport(modules)
	end

	Action.Debounces.Exiting = false
	Action.Debounces.Deploying = false
	Action.Priority = DefaultPriority
	modules.UI:Hide(false)
	
end

function Action:Process(...) : boolean | "Returns true if this action can be ran"
	local args = {...}
	local actionList, remoteList = args[1], args[2]

	if Constraints(actionList) then
		return true
	end

	return false
end

function Update(delta)
	
	if (Action.Power.Blinks < Action.Limits.MaxBlinks) then

		if (Action.Power.State ~= Action.States.Idle) then
			return
		end

		Action.Power.Recharge += (Action.Limits.Charge_Rate * delta)
		SetValue("Recharge", Action.Power.Recharge)

		if (Action.Power.Recharge >= 100) then
			Action.Power.Recharge = 0
			SetValue("Recharge", Action.Power.Recharge)

			Action.Power.Blinks = math.clamp(Action.Power.Blinks + 1, 0, Action.Limits.MaxBlinks)
			SetValue("Blinks", Action.Power.Blinks)
		end
	else
		Action.Power.Recharge = 0
	end

end

function ActionChanged()
	if (Action.Power.BlinkAttack) then
		
		if (Action.Power.State ~= Action.States.PostBlink) then
			return
		end
		
		if (Action.Connections["PostBlink"] ~= nil) then
			Action.Connections["PostBlink"]:Disconnect()
			Action.Connections["PostBlink"] = nil
		end

		if (Action.PositionOrb ~= nil) then
			Action.PositionOrb:Destroy()
			Action.PositionOrb = nil
		end

		if (Action.Connections["Charge"] ~= nil) then
			Action.Connections["Charge"]:Disconnect()
			Action.Connections["Charge"] = nil
		end

		Action.Debounces.CanBlink = false
		EnterFatigue()
	end
end

function CreateOrb()
	task.wait()
	Action.PositionOrb = Instance.new("Part")
	Action.PositionOrb.Name = "BLINK"
	Action.PositionOrb.Size = Vector3.new(0.65, 0.65, 0.65)
	Action.PositionOrb.Shape = Enum.PartType.Ball
	Action.PositionOrb.Parent = workspace
	
	Action.PositionOrb.Transparency = 1
	Action.PositionOrb.Anchored = true
	Action.PositionOrb.CanCollide = false
	Action.PositionOrb.CanTouch = false
	Action.PositionOrb.CanQuery = false

	local highlight = Instance.new("Highlight")
	highlight.Parent = Action.PositionOrb
end

function ChargeBlink(delta)
	
	if (Action.PositionOrb == nil) then
		return
	end
	
	local direction = workspace.CurrentCamera.CFrame.LookVector
	local position = game.Players.LocalPlayer.Character.PrimaryPart.CFrame.Position
	local distance = Action.Power.ChargedDistance
	
	distance += (Action.Limits.Distance_Rate * delta)
	distance = math.clamp(distance, 1, Action.Limits.Distance_Max)
	
	Action.Power.ChargedDistance = distance

	local orbPosition = position + (direction * distance)
	orbPosition = Vector3.new(orbPosition.X, math.clamp(orbPosition.Y, position.Y - 50, position.Y + Action.Limits.HeightDifference), orbPosition.Z)
	
	Action.PositionOrb.CFrame = CFrame.new(orbPosition)
end

function GetDestination() : CFrame | number
	
	if (Action.PositionOrb == nil) then
		return nil, 0
	end

	local position = game.Players.LocalPlayer.Character.PrimaryPart.CFrame.Position
	local orbPos = Action.PositionOrb.CFrame.Position
	orbPos = Vector3.new(orbPos.X, math.clamp(orbPos.Y, position.Y - 50, position.Y + Action.Limits.HeightDifference), orbPos.Z)
	
	local oparams = OverlapParams.new()
	oparams.FilterType = Enum.RaycastFilterType.Exclude
	oparams.FilterDescendantsInstances = {Character}
	
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Character}
	params.RespectCanCollide = true
	
	local ray = workspace:Raycast(orbPos, Vector3.new(0, -50, 0), params)
	local collision = workspace:GetPartBoundsInRadius(orbPos, Action.ActionInfo.CollisionRadius, oparams) --workspace:Spherecast(orbPos, 1.5, Vector3.yAxis)

	if (ray and #collision <= 0) then
		local dest = ray.Position + Vector3.new(0, Action.ActionInfo.PortOffset, 0)
		return dest, ray.Distance 
	else
		return GetDestinationBetween()
	end
end

function GetDestinationBetween()

	local position = game.Players.LocalPlayer.Character.PrimaryPart.CFrame.Position
	local direction = workspace.CurrentCamera.CFrame.LookVector

	local orbPos = position
	orbPos = Vector3.new(orbPos.X, math.clamp(orbPos.Y, position.Y - 50, position.Y + Action.Limits.HeightDifference), orbPos.Z)

	for i = Action.Power.ChargedDistance, 0, -0.5 do
		orbPos = position + (direction * i)
		orbPos = Vector3.new(orbPos.X, math.clamp(orbPos.Y, position.Y - 50, position.Y + Action.Limits.HeightDifference), orbPos.Z)
		
		local oparams = OverlapParams.new()
		oparams.FilterType = Enum.RaycastFilterType.Exclude
		oparams.FilterDescendantsInstances = {Character}
		
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {Character}
		params.RespectCanCollide = true

		local ray = workspace:Raycast(orbPos, Vector3.new(0, -50, 0), params)
		local collision = workspace:GetPartBoundsInRadius(orbPos, Action.ActionInfo.CollisionRadius, oparams) --workspace:Spherecast(orbPos, 1.5, Vector3.yAxis)

		if (ray and #collision <= 0) then
			local dest = ray.Position + Vector3.new(0, Action.ActionInfo.PortOffset, 0)
			return dest, ray.Distance 
		else
			continue
		end
	end

	return nil, 0
end

function Teleport(modules)
	
	local destination, distance = GetDestination()

	if (destination == nil) then
		destination, distance = Player.Character.PrimaryPart.CFrame.Position, 0
	end
	
	local rx, ry, rz = Player.Character.PrimaryPart.CFrame.Rotation:ToOrientation()
	local tweenTime = math.clamp((Action.ActionInfo.TravelTime / 15 * distance), Action.ActionInfo.TravelTime, Action.ActionInfo.TravelTime * 3)
	local tween = TweenService:Create(Player.Character.PrimaryPart, TweenInfo.new(tweenTime), {CFrame = CFrame.new(destination) * CFrame.Angles(rx, ry, rz)})
	tween:Play()
	
	Blink.PowerValues.PowerRemote:FireServer("Teleport")
	
	Action.Visual.StopCharge()
	Action.Visual.StartTeleport()
	Action.Power.Blinks -= 1
	
	--Character.PrimaryPart.Anchored = true
	
	local oldGrav = workspace.Gravity
	workspace.Gravity = 0
	
	SetValue("Blinks", Action.Power.Blinks)
	DisableCollision()
	ExitPostBlink()
	
	Action.Power.ChargedDistance = 0
	SetState(Action.States.Teleporting)
	
	Action.PositionOrb:Destroy()
	Action.PositionOrb = nil
	
	local failsafe
	
	local timeout = tweenTime * 1.5
	failsafe = RunService.Heartbeat:Connect(function(delta)
		
		timeout -= delta
		
		if (timeout <= 0) then
			failsafe:Disconnect()
			failsafe = nil

			workspace.Gravity = oldGrav
			
			tween:Cancel()
			Action.Visual.StopTeleport()
			EnableCollision()
			EnterPostBlink()
		end
	end)
	
	local timer = 0
	while (tween.PlaybackState == Enum.PlaybackState.Playing) do
		local delta = RunService.Heartbeat:Wait()
		timer += delta
		
		if (timer >= tweenTime * 0.99) then
			failsafe:Disconnect()
			failsafe = nil
			
			workspace.Gravity = oldGrav
			tween:Cancel()
			Action.Visual.StopTeleport()
			EnableCollision()
			EnterPostBlink()
		end
	end
end

function EnterPostBlink()
	
	if (Action.Connections["PostBlink"] ~= nil) then
		return
	end
	
	local timer = 0
	
	SetState(Action.States.PostBlink)
	Action.Connections["PostBlink"] = RunService.Heartbeat:Connect(function(delta)
		timer += delta
		if (timer >= Action.Limits.Fatigue_Window) then
			
			Action.Connections["PostBlink"]:Disconnect()
			Action.Connections["PostBlink"] = nil
			
			if (Action.PositionOrb ~= nil) then
				Action.PositionOrb:Destroy()
				Action.PositionOrb = nil
			end
			
			if (Action.Connections["Charge"] ~= nil) then
				Action.Connections["Charge"]:Disconnect()
				Action.Connections["Charge"] = nil
			end
			
			Action.Debounces.CanBlink = false
			
			EnterFatigue()
			return
		end
	end)
end

function ExitPostBlink()
	if (Action.Connections["PostBlink"] == nil) then
		return
	end

	Action.Connections["PostBlink"]:Disconnect()
	Action.Connections["PostBlink"] = nil
end

function EnterFatigue()
	
	repeat task.wait()
	until (KillerAction.Value == "Nothing" or KillerAction.Value == "BlinkAction")
	
	SetAction("Fatigue")
	SetState(Action.States.Fatigue)
	Action.Visual.StopCharge()
	
	coroutine.wrap(function()
		local FatigueEffect = game.Lighting.FatigueEffect
		Action.Connections["FatigueTween"] = TweenService:Create(FatigueEffect, TweenInfo.new(1), {Brightness = -0.9})
		Action.Connections["FatigueTween"]:Play()

		local completed
		completed = Action.Connections["FatigueTween"].Completed:Connect(function()
			
			Action.Connections["FatigueTween"] = nil
			completed:Disconnect()
			completed = nil

			task.wait(1)

			Action.Connections["FatigueTween"] = TweenService:Create(FatigueEffect, TweenInfo.new(0.5), {Brightness = 0})
			Action.Connections["FatigueTween"]:Play()

			local completed
			completed = Action.Connections["FatigueTween"].Completed:Connect(function()
				Action.Connections["FatigueTween"] = nil
				completed:Disconnect()
				completed = nil
				
				SetState(Action.States.Idle)
				Action.Debounces.CanBlink = true

				game.ReplicatedStorage.RemoteEvents.ChaseUpdater:FireServer("Disrupt", true)
				Action.Power.BlinkAttack = false
				SetValue("BlinkAttack", false)
				SetAction("Nothing")
			end)
		end)
	end)()
end

function DisableCollision()
	for i, obj in pairs(Player.Character:GetDescendants()) do
		if (not obj:IsA("BasePart")) then
			continue
		end
		
		Action.CollisionMap[obj.Name] = obj.CollisionGroup
		obj.CollisionGroup = "NoCollision"
	end
end

function EnableCollision()
	for i, obj in pairs(Player.Character:GetDescendants()) do
		if (not obj:IsA("BasePart") or Action.CollisionMap[obj.Name] == nil) then
			continue
		end

		obj.CollisionGroup = Action.CollisionMap[obj.Name]
	end
end

function TweenSpeed(Percentage)
	
	if (Action.Connections["SpeedTween"] ~= nil) then
		Action.Connections["SpeedTween"]:Cancel()
		Action.Connections["SpeedTween"] = nil
	end
	
	local Speed = Code:GetPlayerValue(Player, "Speed") * Code:GetPlayerValue(Player, "SpeedMultiplier")
	Speed *= Percentage
	
	Action.Connections["SpeedTween"] = TweenService:Create(Player.Character.Humanoid, TweenInfo.new(0.35), {WalkSpeed = Speed})
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
	
	--KillerAction.Value = action
	Blink.PowerValues.PowerRemote:FireServer("Action", action)
end

function SetValue(Attribute, Value)
	Blink.PowerValues.PowerRemote:FireServer("SetValue", Attribute, Value)
end

function SetState(State)
	Action.Power.State = State
	SetValue("State", State)
	
	if (State == Action.States.Idle) then
		TweenSpeed(1)
	end
	
	if (State == Action.States.Teleporting) then
		TweenSpeed(1)
	end
	
	if (State == Action.States.PostBlink) then
		TweenSpeed(0.65)
	end
	
	if (State == Action.States.Charging) then
		TweenSpeed(0.65)
	end
	
	if (State == Action.States.Fatigue) then
		TweenSpeed(0.3)
	end
	
end

function updateAttributes(currentValues)
	
	local Character = Player.Character
	local Blink = Character.Blink
	
	if (Action.Connections["ActionChange"] == nil) then
		Action.Connections["ActionChange"] = Blink:GetAttributeChangedSignal("BlinkAttack"):Connect(ActionChanged)
	end
	
	if (Action.Connections["Update"] == nil) then
		Action.Connections["Update"] = RunService.Heartbeat:Connect(Update)
	end
	
	Action.Power = {
		["State"] = if (Action.Power.State == nil) then 0 else Action.Power.State,
		["Blinks"] = Blink:GetAttribute("Blinks"),
		["Recharge"] = if (Action.Power.State == nil) then 0 else Action.Power.Recharge,
		["LastBlink"] = Blink:GetAttribute("LastBlink"),
		["Teleporting"] = Blink:GetAttribute("Teleporting"),
		["BlinkAttack"] = if (Action.Power.BlinkAttack == nil) then false else Action.Power.BlinkAttack,
		["FatigueTimer"] = Blink:GetAttribute("FatigueTimer"),
		["ChargedDistance"] = if (Action.Power.ChargedDistance == nil) then 0 else Action.Power.ChargedDistance,
	}

	Action.Limits = {
		["MaxHeight"] = 55;
		["HeightDifference"] = 35;
		["MaxBlinks"] = Blink.PowerValues:GetAttribute("MaxBlinks"),
		["Charge_Rate"] = Blink.PowerValues:GetAttribute("Charge_Rate"),
		["Distance_Max"] = Blink.PowerValues:GetAttribute("Distance_Max"),
		["Distance_Rate"] = Blink.PowerValues:GetAttribute("Distance_Rate"),
		["Fatigue_Window"] = Blink.PowerValues:GetAttribute("Fatigue_Window"),
	}

end

function SpawnDebug(position)
	coroutine.wrap(function()

		local DebugOrb = Instance.new("Part")
		DebugOrb.Name = "DEBUG"
		DebugOrb.Size = Vector3.new(0.65, 0.65, 0.65)
		DebugOrb.CFrame = CFrame.new(position)
		DebugOrb.Shape = Enum.PartType.Ball
		DebugOrb.Parent = workspace
		DebugOrb.Anchored = true
		DebugOrb.CanCollide = false
		DebugOrb.CanTouch = false
		DebugOrb.CanQuery = false

		local highlight = Instance.new("Highlight")
		highlight.Parent = DebugOrb

		task.wait(5)
		DebugOrb:Destroy()
	end)()
end

return Action
