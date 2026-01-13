local Player = game.Players.LocalPlayer
local EventRemotes = game.ReplicatedStorage.RemoteEvents.EventRemotes

local Action = {
	Key = "Interact5";
	ActionName = "DROP";
	Priority = 1; -- scale of 1-5
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

	if not actionList.BasicAttack.Using
		and Player.Character:GetAttribute("Carry") -- no carry attribute set so not carrying a person
		and KillerConstraints(modules)
		and currentValues:WaitForChild('KillerAction').Value == 'Nothing' then

		CanRun = true
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

	Character.Humanoid.AutoRotate = false
	Character.Humanoid.WalkSpeed = 0

	remoteList.Server:FireServer("Carry", "Drop_Default", Action.ActionInfo.Survivor)

	local Connections = {}

	local function disconnect(stun : boolean)
		modules.Camera.Camera.HeadLocked = false
		actionList.PreventHeadTilt = false

		Character.Humanoid.AutoRotate = true
		workspace.Camera.CameraSubject = Character.Humanoid
		workspace.Camera.CameraType = Enum.CameraType.Custom

		actionList.InteractingSurvivor = nil -- overwrite the survivor we are picking up

		if actionList.Cross_Connections.Stunned then
			actionList.Cross_Connections.Stunned:Disconnect()
			actionList.Cross_Connections.Stunned = nil
		end
		
		Character.Humanoid.WalkSpeed = modules.Code:GetPlayerValue(Player, "Speed") * modules.Code:GetPlayerValue(Player, "SpeedMultiplier")
	end

	if Action.ActionInfo.Connections.Animation then
		Action.ActionInfo.Connections.Animation:Disconnect()
	end

	Action.ActionInfo.Connections.Animation = Player.Character:GetAttributeChangedSignal("Action_Animation"):Connect(function()
		local Length, Anim = Player.Character:GetAttribute("Animation_Time"), Player.Character:GetAttribute("Action_Animation")
		local Animation = game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Drop'):WaitForChild('Killer'):FindFirstChild(Anim)

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

			Action.ActionInfo.Connections[Animation].Stopped:Wait() -- wait for finish

			disconnect()
		elseif Anim == "Soft_Reset" then
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
