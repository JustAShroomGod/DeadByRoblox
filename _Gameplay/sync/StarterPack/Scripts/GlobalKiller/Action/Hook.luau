local Player = game.Players.LocalPlayer

local Action = {
	Key = "Interact";
	ActionName = "HANG";
	InteractDistance = 4.2;
	Priority = 1; -- scale of 1-5
	ActionInfo = {
		Survivor = nil;
		Hook = nil;
		Connections = {
			Tracks = {};
		}
	},
	Debounces = {
		InputEnter = tick()
	}
}

local anim = nil

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Hook : Model = actionList.Hook
	local Survivor : Model = actionList.InteractingSurvivor

	if not Survivor or not Hook then return false end

	local hookSettings = Hook:WaitForChild('Panel')

	if not hookSettings:WaitForChild('Ocuped').Value
		and KillerConstraints(modules)
		and not hookSettings:WaitForChild('Used').Value
		and not hookSettings:WaitForChild('Blocked').Value
		and script.Parent.Parent.Parent.Parent:WaitForChild("Scripts"):WaitForChild("values"):WaitForChild("KillerAction").Value == "Nothing"
		and not hookSettings:WaitForChild('Sabotaging').Value
		and (Hook:WaitForChild("Trigger").CFrame.LookVector - game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame.LookVector).magnitude <= 0.9
		and Player.Character:GetAttribute("Carry") -- no carry attribute set so not carrying a person
		and (Hook:WaitForChild('Trigger').Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance then

		Action.ActionInfo.Survivor = Survivor
		Action.ActionInfo.Hook = Hook
		CanRun = true
	else
		Action.ActionInfo.Survivor = nil
		Action.ActionInfo.Hook = nil
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
	if (tick() - Action.Debounces.InputEnter) < 3 or not Action.ActionInfo.Survivor or not Action.ActionInfo.Hook then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	local Hook = Action.ActionInfo.Hook
	currentValues.Action.Value = "Hooking"

	if (actionList.BasicAttack.Using or not Character:GetAttribute("Carry")) then
		return
	end

	if not anim then
		anim = Character.Humanoid.Animator:LoadAnimation(script:WaitForChild("Hooking"))
	end

	actionList.MovementScript:Disable()
	Character.Humanoid.WalkSpeed = 0
	Character.HumanoidRootPart.Anchored = true
	local Position = Character.HumanoidRootPart.CFrame
	actionList.PreventHeadTilt = true
	modules.Camera.Camera.HeadLocked = true

	modules.UI:Hide(true)
	local cons = {}
	remoteList.Server:FireServer("Hook", "Hook", Action.ActionInfo.Survivor.Character, Hook)
	local n = Action.ActionInfo.Survivor.Character.Name
	if Action.ActionInfo.Connections.Animation then
		Action.ActionInfo.Connections.Animation:Disconnect() -- remove dual listening (for perforamnce)
	end

	local function disconnect()

		for _, track in pairs(Action.ActionInfo.Connections.Tracks) do
			if track.IsPlaying then track:Stop() end
		end

		if cons.Disconnect2 then cons.Disconnect2:Disconnect() end

		actionList.MovementScript:Enable()

		modules.Camera.Camera.HeadLocked = false
		actionList.PreventHeadTilt = false
		Character.Humanoid.WalkSpeed = modules.Code:GetPlayerValue(Player, "Speed") * modules.Code:GetPlayerValue(Player, "SpeedMultiplier")

		actionList.InteractingSurvivor = nil -- overwrite the survivor we are picking up

		if actionList.Cross_Connections.Stunned then
			actionList.Cross_Connections.Stunned:Disconnect()
			actionList.Cross_Connections.Stunned = nil
		end

		modules.UI:Hide(false)
	end

	cons.Disconnect2 = game.Players.PlayerRemoving:Connect(function(P)
		if P.Name == n then
			disconnect()
		end
	end)

	Character.HumanoidRootPart.CFrame = Position
	local A_Length = if anim.Length <0.1 then 2 else anim.Length
	local True_Length : number = 1.5

	anim:Play()
	anim:AdjustSpeed(A_Length/True_Length)
	Character.HumanoidRootPart.CFrame = Position
	anim.Stopped:Wait()

	disconnect()
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