local TweenService = game:GetService('TweenService')
local Remotes = game.ReplicatedStorage.RemoteEvents
local Player = game.Players.LocalPlayer
local Defaults = 3;

local Action = {
	Key = "Interact2";
	ActionName = "REPAIR";
	InteractDistance = 4;
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		Generator = nil;
		Port = nil;
		Disconnect = nil;
	},
	AnimationTracks = {};
	Debounces = {
		InProgress = false;
		InputEnter = tick();
		InputExit = tick();
	}
}

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Generator : Model = actionList.Generator

	if not Generator then return false end

	if not Action.AnimationTracks.Missed then
		Action.AnimationTracks.Missed = Player.Character:WaitForChild('Humanoid'):LoadAnimation(script:WaitForChild('Skill_Miss'))
	end

	if not Action.AnimationTracks.Repair then
		Action.AnimationTracks.Repair = Player.Character:WaitForChild('Humanoid'):LoadAnimation(script:WaitForChild('Repair'))
	end

	local generatorSettings = Generator:WaitForChild('Panel')
	local generatorPort = nil

	for _, port in pairs(Generator:WaitForChild('Workspots'):GetChildren()) do
		if not port:IsA('BasePart') then continue end

		if generatorPort and generatorPort ~= port then

			if (generatorPort.Position - Player.Character:GetPivot().Position).Magnitude > (port.Position - Player.Character:GetPivot().Position).Magnitude then
				generatorPort = port
			end
		else
			generatorPort = port
		end
	end

	if generatorSettings:WaitForChild('Progress').Value < 1000
		and not generatorPort:WaitForChild('Ocuped'):WaitForChild('Deactivated').Value
		and not generatorPort:WaitForChild('Deactivated').Value
		and not generatorPort:WaitForChild('Ocuped').Value
		and not Generator:GetAttribute("Blocked") -- not blocked
		and (generatorPort.Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance
		and not actionList.ModuleList.Code:GetEffect("Cloaked")
		and currentValues:WaitForChild('HealthState').Value > 0
		and currentValues:WaitForChild('Action').Value == 'Nothing' then



		Action.ActionInfo.GeneratorSettings = generatorSettings
		Action.ActionInfo.Port = generatorPort
		Action.ActionInfo.Generator = Generator

		CanRun = true
	elseif Action.Debounces.InProgress then
		Action.Priority = 0
		CanRun = true
	else
		Action.ActionInfo.Generator = nil
		Action.ActionInfo.GeneratorSettings = nil
		Action.ActionInfo.Port = nil
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or not Action.ActionInfo.Generator or Action.Debounces.InProgress then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	local generator = Action.ActionInfo.Generator
	local Port = Action.ActionInfo.Port

	modules.UI:Hide(true)
	modules.UI:Progress(Action.ActionInfo.Generator.Panel.Progress, "REPAIRING", "RepairSpeed", modules.Code.BaseValues.Survivor.Action.RepairSpeed)

	local Tween = TweenService:Create(Character.PrimaryPart, TweenInfo.new(1/10), {
		CFrame = Action.ActionInfo.Port.CFrame
	})

	actionList.MovementScript.MainScript.Disabled = true
	Character.Humanoid.WalkSpeed = 0

	Character.PrimaryPart.Anchored = true

	Tween:Play()
	Tween.Completed:Wait()

	Action.AnimationTracks.Repair:Play()

	Character.PrimaryPart.Anchored = false
	Character.PrimaryPart:PivotTo(Port.CFrame * CFrame.new(0, 0.35, 0))
	Character.PrimaryPart.Anchored = true

	local gen = Port.Parent.Parent
	local panel = gen:WaitForChild('Panel')

	obfuscate("Bool", currentValues.Crouching, false)
	obfuscate("Bool", Port.Ocuped, true)
	obfuscate("String", Port.Ocupant, Player.Name)
	obfuscate("String", currentValues.Action, "Repairing")

	if Player.Character:GetAttribute("Perk_Defense_Time") then
		remoteList.Perk:FireServer("Self Defense", false) -- de-activate our perk
	end

	local Connections = {}

	local function disconnect()

		Action.AnimationTracks.Repair:Stop()

		Character.PrimaryPart.Anchored = false
		actionList.MovementScript.MainScript.Disabled = false
		Character.Humanoid.WalkSpeed = 10

		obfuscate("Bool", Port.Ocuped, false)
		obfuscate("String", Port.Ocupant, "Nobody")
		obfuscate("String", currentValues.Action, "Nothing")

		Action.ActionInfo.Disconnect = nil

		if Connections.HealthStateChanged then Connections.HealthStateChanged:Disconnect() end
		if Connections.Hit then Connections.Hit:Disconnect() end
		if Connections.Progress then Connections.Progress:Disconnect() end
		if Connections.Action then Connections.Action:Disconnect() end
		if Connections.Blocked then Connections.Blocked:Disconnect() end
		if Connections.Miss then Connections.Miss:Disconnect() end

		Action.Debounces.InProgress = false
		Action.Priority = Defaults
		modules.UI:Hide(false)
		modules.UI:Progress()
	end
	
	Connections.Miss = Remotes.SkillCheckResult.Event:Connect(function(Context, Result)

		if (Context ~= "Repair" or (Result ~= "Fail" and Result ~= "Miss")) then
			return
		end

		Action.AnimationTracks.Missed:Play()
	end)

	Connections.Hit = Character:GetAttributeChangedSignal("LastHit"):Connect(function(test)
		disconnect()
	end)

	Connections.Progress = panel.Progress.Changed:Connect(function()
		if panel.Progress.Value >= 1000 then
			disconnect()

		end
	end)

	Connections.Blocked = gen:GetAttributeChangedSignal("Blocked"):Connect(function()

		if gen:GetAttribute("Blocked") then
			disconnect()
		end
	end)

	Connections.Action = currentValues.Action.Changed:Connect(function()

		if not (currentValues.Action.Value == "Repairing") then
			disconnect()
		end
	end)

	Connections.HealthStateChanged = currentValues.HealthState.Changed:Connect(function()
		disconnect()
	end)

	Action.ActionInfo.Disconnect = disconnect
end

function Action:Stop(...)
	if (tick() - Action.Debounces.InputExit) < 1.5 or not Action.ActionInfo.Disconnect then return warn('Anti-Spam exit') end
	Action.Debounces.InputExit = tick()

	local args = {...}

	Action.ActionInfo.Disconnect()
	Action.ActionInfo.Disconnect = nil
end

function Action:Process(...) : boolean | "Returns true if this action can be ran"
	local args = {...}
	local actionList, remoteList = args[1], args[2]

	if Constraints(actionList) then
		return true
	end

	return false
end

return Action