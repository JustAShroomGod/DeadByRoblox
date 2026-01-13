local Player = game.Players.LocalPlayer

local Action = {
	Key = "Interact";
	ActionName = "CLOSE HATCH";
	InteractDistance = 5.85;
	Priority = 3; -- scale of 1-5
	Debounces = {
		InputEnter = tick()
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Hatch : Model = actionList.Hatch

	if not Hatch then return false end

	if (Hatch:WaitForChild("HumanoidRootPart").CFrame.Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance -- Distance Check
		and currentValues:WaitForChild('KillerAction').Value == "Nothing"
		and not Player.Character:GetAttribute("Carry") -- no carry attribute set so not carrying a person
		and not actionList.BasicAttack.Using
		and not Hatch:GetAttribute("User")
		and KillerConstraints(modules)
		and Hatch:GetAttribute('State') == "Open" then

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

	return true
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	local Prior_Speed = Character.Humanoid.WalkSpeed

	Character.Humanoid.AutoRotate = false
	Character.Humanoid.WalkSpeed = 0
	Character.PrimaryPart.Anchored = true

	actionList.PreventHeadTilt = true

	modules.Camera.Camera.HeadLocked = true

	local Connections = {}

	local HatchTrack = Character.Humanoid:LoadAnimation(script:WaitForChild('Animation'))
	HatchTrack:Play(0.9)

	remoteList.Hatch:FireServer("Start_Close")

	Connections.TrackEnded = HatchTrack.Stopped:Connect(function()
		if HatchTrack then HatchTrack:Stop() HatchTrack = nil end

		if Connections.TrackEnded then Connections.TrackEnded:Disconnect() end

		remoteList.Hatch:FireServer("Close")

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

		Character.Humanoid.AutoRotate = false
		Character.PrimaryPart.Anchored = false

		actionList.PreventHeadTilt = false
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