local Player = game.Players.LocalPlayer
local EventRemotes = game.ReplicatedStorage.RemoteEvents.EventRemotes

local Action = {
	Key = "Interact";
	ActionName = "PICK UP";
	InteractDistance = 4.5;
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		Survivor = nil;
		Connections = {}
	},
	Debounces = {
		InputEnter = tick()
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Survivor : Model = actionList.Player

	if game.Players.LocalPlayer.Character:GetAttribute("Cloaked") == true or not Survivor or not Survivor.Character then return false end
	local survivorSettings = Survivor:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')

	local isdead = game.ReplicatedStorage:WaitForChild('Match'):WaitForChild('Players'):WaitForChild(Survivor.Name):GetAttribute('Dead')
	local Power_State = Player.Character:GetAttribute("Power_State")
	if survivorSettings:WaitForChild('HealthState').Value == 0
		and not isdead
		and not survivorSettings:WaitForChild('Holded').Value
		and not actionList.BasicAttack.Using
		and KillerConstraints(modules)
		and (Power_State ~= "PowerUsage")
		and not Player.Character:GetAttribute("Carry") -- no carry attribute set so not carrying a person
		and (Survivor.Character:GetPivot().Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance
		and currentValues:WaitForChild('KillerAction').Value == 'Nothing' then

		Action.ActionInfo.Survivor = Survivor
		CanRun = true
	else
		Action.ActionInfo.Survivor = nil
		Action.ActionInfo.Settings = nil
	end

	return CanRun
end

function KillerConstraints(modules)

	if (modules.Data:GetCharacter() == "Psychopath") then
		return not (Player.Character.BloodRage:GetAttribute("State") == 2)
	end

	if (modules.Data:GetCharacter() == "Nurse") then
		return not (Player.Character:WaitForChild("Blink"):GetAttribute("BlinkAttack") or Player.Character:WaitForChild("Blink"):GetAttribute("State") > 0)
	end

	if (modules.Data:GetCharacter() == "Wraith") then
		return not (Player.Character:GetAttribute("Cloaked"))
	end

	return true
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	actionList.PreventHeadTilt = true
	actionList.InteractingSurvivor =  Action.ActionInfo.Survivor -- overwrite the survivor we are picking up

	Character.Humanoid.WalkSpeed = 0

	remoteList.Server:FireServer("Carry", "Pickup_Default", Action.ActionInfo.Survivor)
	local v = Action.ActionInfo.Survivor.Name

	modules.UI:Hide(true)

	local InCarry = true
	local Connections = {}

	local function disconnect(stun : boolean)
		modules.Camera.Camera.HeadLocked = false
		actionList.PreventHeadTilt = false
		InCarry = false

		if Connections.V then Connections.V:Disconnect() end

		if stun then
			if Connections.Tween then Connections.Tween:Cancel() end
			if Connections.TweenConnection then Connections.TweenConnection:Disconnect() end
			if Connections.Update then Connections.Update:Disconnect() end
			if Connections.Stunned then Connections.Stunned:Disconnect() end

			actionList.InteractingSurvivor = nil
		else
			Connections.Tween = game:GetService('TweenService'):Create(Character.Humanoid, TweenInfo.new(1), {WalkSpeed = modules.Code:GetSpeed("Carry")})
			Connections.Tween:Play()

			Connections.TweenConnection = Connections.Tween.Completed:Connect(function()
				if Connections.TweenConnection then Connections.TweenConnection:Disconnect() end
				if Connections.Update then Connections.Update:Disconnect() end
				if Connections.Stunned then Connections.Stunned:Disconnect() end

				Character.Humanoid.WalkSpeed = modules.Code:GetSpeed("Carry")
			end)
		end

		modules.UI:Hide(false)
	end

	Connections.V = game.Players.PlayerRemoving:Connect(function(P)
		if P.Name == v then
			disconnect(true)
		end
	end)

	if Action.ActionInfo.Connections.Animation then
		Action.ActionInfo.Connections.Animation:Disconnect()
	end

	Action.ActionInfo.Connections.Animation = Player.Character:GetAttributeChangedSignal("Action_Animation"):Connect(function()
		local Length, Anim = Player.Character:GetAttribute("Animation_Time"), Player.Character:GetAttribute("Action_Animation")
		local Animation = game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Pickup'):WaitForChild('Killer'):FindFirstChild(Anim)

		if Animation then
			Action.ActionInfo.Connections.Animation:Disconnect() -- remove doing animation when it's not our turn and do not force overload of signals
			Action.ActionInfo.Connections.Animation = nil -- remove variables do not force overuse of memory/ram

			if not Action.ActionInfo.Connections[Animation] then -- build and store animation
				Action.ActionInfo.Connections[Animation] = Player.Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(Animation)
			end

			local A_Length = if Action.ActionInfo.Connections[Animation].Length < 0.1 then 1 else Action.ActionInfo.Connections[Animation].Length
			Length = 0 - (workspace:GetServerTimeNow() - Length)

			Action.ActionInfo.Connections[Animation]:Play() -- play animation
			Action.ActionInfo.Connections[Animation]:AdjustSpeed(A_Length/Length) -- both animations should end at same time/sync

			if actionList.Cross_Connections.Stunned then
				actionList.Cross_Connections.Stunned:Disconnect()
				actionList.Cross_Connections.Stunned = nil
			end

			actionList.Cross_Connections.Stunned = currentValues.KillerAction.Changed:Connect(function()

				if currentValues.KillerAction.Value == "Stun" then
					actionList.Player = nil
					actionList.InteractingSurvivor = nil
				end
			end)

			Action.ActionInfo.Connections[Animation].Stopped:Wait() -- wait for finish


			disconnect()
		end
	end)


	modules.Camera.Camera.HeadLocked = true
end

function Action:Process(...) : boolean | "Returns true if this action can be ran"
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]

	if Constraints(actionList, modules) then
		return true
	end

	return false
end

return Action
