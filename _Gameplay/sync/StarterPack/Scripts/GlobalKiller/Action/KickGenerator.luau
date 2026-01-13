local ReplicatedStorage : ReplicatedStorage, Players : Players = game:GetService("ReplicatedStorage"), game:GetService("Players")

local Player = Players.LocalPlayer

local Game_Assets = ReplicatedStorage:WaitForChild("Game_Assets"):WaitForChild("Animations"):WaitForChild("Generator"):WaitForChild("Killer")
local Kick_Animation = Game_Assets:WaitForChild("Kick_Default")

local Action = {
	Key = "Interact";
	ActionName = "DAMAGE GENERATOR";
	InteractDistance = 4;
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		Generator = nil;
		Port = nil;
		Connections = {}
	},
	Debounces = {
		InputEnter = tick(),
		InputExit = tick(),
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Generator : Model = actionList.Generator

	if not Generator then return false end

	local generatorSettings = Generator:WaitForChild('Panel')
	local generatorPort = nil

	local SurvivorUsing = false

	for _, port in pairs(Generator:WaitForChild('Workspots'):GetChildren()) do
		if not port:IsA('BasePart') then continue end

		if port:WaitForChild('Ocuped').Value and not port.Ocuped:WaitForChild('Deactivated').Value then
			SurvivorUsing = true
		end

		if generatorPort and generatorPort ~= port then

			if (generatorPort.Position - Player.Character:GetPivot().Position).Magnitude > (port.Position - Player.Character:GetPivot().Position).Magnitude then
				generatorPort = port
			end
		elseif not generatorPort then

			generatorPort = port
		end
	end

	if not generatorSettings:WaitForChild('Broke').Value
		and not actionList.BasicAttack.Using
		and KillerConstraints(modules)
		and (generatorSettings:WaitForChild('Progress').Value > 0 and generatorSettings:WaitForChild('Progress').Value < 1000)
		and not SurvivorUsing -- all ports are unused no survivor on the gen
		and not Player.Character:GetAttribute("Carry") -- no carry attribute set so not carrying a person
		and not generatorPort:WaitForChild('Ocuped'):WaitForChild('Deactivated').Value
		and not generatorPort:WaitForChild('Deactivated').Value
		and not Generator:GetAttribute("Blocked") -- not blocked
		and not generatorPort:WaitForChild('Ocuped').Value
		and (generatorPort.Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance
		and currentValues:WaitForChild('KillerAction').Value == 'Nothing' then

		Action.ActionInfo.Port = generatorPort
		Action.ActionInfo.Generator = Generator
		CanRun = true
	else
		Action.ActionInfo.Generator = nil
		Action.ActionInfo.Port = nil
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

	local Prior_Speed, Generator = Character.Humanoid.WalkSpeed, Action.ActionInfo.Generator

	Character.Humanoid.WalkSpeed = 0
	actionList.PreventHeadTilt = true
	modules.Camera.Camera.HeadLocked = true

	remoteList.Server:FireServer('Generator', "Killer_Kick", Generator, Action.ActionInfo.Port) -- Fire off to Server

	modules.UI:Hide(true)

	if Action.ActionInfo.Connections.Animation then
		Action.ActionInfo.Connections.Animation:Disconnect()
	end

	Action.ActionInfo.Connections.Animation = Generator:GetAttributeChangedSignal("Animation"):Connect(function()
		local Animation = Generator:GetAttribute("Animation")

		if Animation and Animation ~= "" and Kick_Animation then
			Action.ActionInfo.Connections.Animation:Disconnect() -- remove doing animation when it's not our turn and do not force overload of signals
			Action.ActionInfo.Connections.Animation = nil -- remove variables do not force overuse of memory/ram

			if not Action.ActionInfo.Connections[Animation] then -- build and store animation
				Action.ActionInfo.Connections[Animation] = Player.Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(Kick_Animation)
			end

			local A_Length = if Action.ActionInfo.Connections[Animation].Length < 0.1 then 5.6 else Action.ActionInfo.Connections[Animation].Length
			local True_Length : number = 0 - (workspace:GetServerTimeNow() - Generator:GetAttribute("Animation_Time"))
			Action.ActionInfo.Connections[Animation]:Play() -- play animation
			Action.ActionInfo.Connections[Animation]:AdjustSpeed(A_Length/True_Length) -- both animations should end at same time/sync

			Action.ActionInfo.Connections[Animation].Stopped:Wait() -- wait for finish

			--EventRemotes.ActionEvent:FireServer("Break", "Pallet")

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

	--[[Connections.Stun = currentValues.KillerAction.Changed:Connect(function()
		
		if currentValues.KillerAction.Value == 'Stun' then
			disconnect()
		end
	end)]]--
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