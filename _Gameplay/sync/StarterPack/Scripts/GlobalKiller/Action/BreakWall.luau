local Player = game.Players.LocalPlayer
local EventRemotes = game.ReplicatedStorage.RemoteEvents.EventRemotes

local Action = {
	Key = "Interact";
	ActionName = "DESTROY WALL";
	InteractDistance = 4.2;
	Priority = 1; -- scale of 1-5
	ActionInfo = {
		Wall = nil;
		Connections = {};
	},
	Debounces = {
		InputEnter = tick()
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Wall : Model = actionList.BreakWall

	if not Wall then return false end

	local wallSettings = Wall:WaitForChild('Panel')

	if not wallSettings:WaitForChild('Broken').Value
		and not actionList.BasicAttack.Using
		and not Player.Character:GetAttribute("Carry") -- no carry attribute set so not carrying a person
		and (Wall:GetPivot().Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance
		and KillerConstraints(modules)
		and currentValues:WaitForChild('KillerAction').Value == 'Nothing' then

		Action.ActionInfo.Wall = Wall
		CanRun = true
	else
		Action.ActionInfo.Wall = nil
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


	return true
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	local Wall = Action.ActionInfo.Wall
	local Prior_Speed = Character.Humanoid.WalkSpeed

	actionList.PreventHeadTilt = true
	Character.Humanoid.WalkSpeed = 0
	modules.Camera.Camera.HeadLocked = true

	modules.UI:Hide(true)

	remoteList.Server:FireServer('Wall', "Killer_Kick", Wall) -- Fire off to Server

	if Action.ActionInfo.Connections.Animation then
		Action.ActionInfo.Connections.Animation:Disconnect()
	end

	Action.ActionInfo.Connections.Animation = Wall:GetAttributeChangedSignal("Animation"):Connect(function()
		local Animation = Wall:GetAttribute("Animation")

		if Animation and Animation ~= "" and script:FindFirstChild(Animation) then
			Action.ActionInfo.Connections.Animation:Disconnect() -- remove doing animation when it's not our turn and do not force overload of signals
			Action.ActionInfo.Connections.Animation = nil -- remove variables do not force overuse of memory/ram

			if not Action.ActionInfo.Connections[Animation] then -- build and store animation
				Action.ActionInfo.Connections[Animation] = Player.Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(script:FindFirstChild(Animation))
			end

			local A_Length = if Action.ActionInfo.Connections[Animation].Length < 0.1 then 5.6 else Action.ActionInfo.Connections[Animation].Length
			local True_Length : number = 0 - (workspace:GetServerTimeNow() - Wall:GetAttribute("Animation_Time"))
			Action.ActionInfo.Connections[Animation]:Play() -- play animation
			Action.ActionInfo.Connections[Animation]:AdjustSpeed(A_Length/True_Length) -- both animations should end at same time/sync

			Action.ActionInfo.Connections[Animation].Stopped:Wait() -- wait for finish

			EventRemotes.ActionEvent:FireServer("Break", "Wall")

			if modules.Data:GetCharacter() == 'Wraith' then

				if (Character:WaitForChild("Bell"):WaitForChild("State").Value == "Invisible") then
					Character.Humanoid.WalkSpeed = Prior_Speed
				else
					Character.Humanoid.WalkSpeed = modules.Code:GetPlayerValue(Player, "Speed") * modules.Code:GetPlayerValue(Player, "SpeedMultiplier")
				end
			else
				Character.Humanoid.WalkSpeed = modules.Code:GetPlayerValue(Player, "Speed") * modules.Code:GetPlayerValue(Player, "SpeedMultiplier")
			end

			modules.Camera.Camera.HeadLocked = false
			actionList.PreventHeadTilt = false

			modules.UI:Hide(false)
		end
	end)
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
