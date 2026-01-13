local Player = game.Players.LocalPlayer
local EventRemotes = game.ReplicatedStorage.RemoteEvents.EventRemotes

coroutine.resume(coroutine.create(function()
	game:GetService("ContentProvider"):PreloadAsync({script:WaitForChild("Pallet_Kick")})
end))

local Action = {
	Key = "Interact";
	ActionName = "DESTROY PALLET";
	InteractDistance = 5;
	Priority = 1; -- scale of 1-5
	ActionInfo = {
		Pallet = nil;
		Connections = {};
	},
	Debounces = {
		InputEnter = tick()
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Pallet : Model = actionList.Pallet

	if not Pallet then return false end

	local palletSettings = Pallet:WaitForChild('Panel')

	if palletSettings:WaitForChild('Vaulter').Value == ""
		and not actionList.BasicAttack.Using
		and palletSettings:WaitForChild('Dropper').Value == ""
		and palletSettings:WaitForChild('State').Value == 1
		and not Player.Character:GetAttribute("Carry") -- no carry attribute set so not carrying a person
		and ((Pallet:WaitForChild('FirstPort').Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance and (Pallet.FirstPort.CFrame.LookVector - game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame.LookVector).magnitude <= 1.2 or (Pallet:WaitForChild('SecondPort').Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance and (Pallet.SecondPort.CFrame.LookVector - game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame.LookVector).magnitude <= 1.2)
		and currentValues:WaitForChild('KillerAction').Value == 'Nothing'
		and KillerConstraints(modules)
		and not currentValues:WaitForChild("Stunned").Value then

		Action.ActionInfo.Pallet = Pallet
		CanRun = true
	else
		Action.ActionInfo.Pallet = nil
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

	local Prior_Speed, Pallet = Character.Humanoid.WalkSpeed, Action.ActionInfo.Pallet

	actionList.PreventHeadTilt = true
	Character.Humanoid.WalkSpeed = 0
	modules.Camera.Camera.HeadLocked = true
	modules.UI:Hide(true)

	remoteList.Server:FireServer('Pallet', "Killer_Kick", Pallet) -- Fire off to Server

	if Action.ActionInfo.Connections.Animation then
		Action.ActionInfo.Connections.Animation:Disconnect()
	end

	Action.ActionInfo.Connections.Animation = Pallet:GetAttributeChangedSignal("Animation"):Connect(function()
		local Animation = Pallet:GetAttribute("Animation")

		if Animation and Animation ~= "" and script:FindFirstChild(Animation) then
			Action.ActionInfo.Connections.Animation:Disconnect() -- remove doing animation when it's not our turn and do not force overload of signals
			Action.ActionInfo.Connections.Animation = nil -- remove variables do not force overuse of memory/ram

			if not Action.ActionInfo.Connections[Animation] then -- build and store animation
				Action.ActionInfo.Connections[Animation] = Player.Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(script:FindFirstChild(Animation))
			end

			local A_Length = if Action.ActionInfo.Connections[Animation].Length < 0.1 then 5.6 else Action.ActionInfo.Connections[Animation].Length
			local True_Length : number = 0 - (workspace:GetServerTimeNow() - Pallet:GetAttribute("Animation_Time"))
			Action.ActionInfo.Connections[Animation]:Play() -- play animation
			Action.ActionInfo.Connections[Animation]:AdjustSpeed(A_Length/True_Length) -- both animations should end at same time/sync

			repeat task.wait() until Action.ActionInfo.Connections[Animation].IsPlaying == false

			EventRemotes.ActionEvent:FireServer("Break", "Pallet")

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