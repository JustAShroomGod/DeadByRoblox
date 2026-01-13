local Player = game.Players.LocalPlayer
local Default = 3

local d = false
local Item = {
	Connections = {};
	CurrentUse = nil;
	InteractDistance = 4;
	Debounces = {
		InputEnter = tick();
		InputExit = tick();
	},
}

local AnimList = {}
AnimList.Missed = nil

function Item:Constraints(actionList, modules, Action) : boolean | "Return true if can do action"
	local CanRun = false
	local currentValues = actionList.ValueList
	local CurrentItem = actionList.CharacterItem
	local HumanoidState = Player.Character.Humanoid:GetState()

	local Generator = actionList.Generator
	local Hook = actionList.Hook

	Action.ActionName = "USE TOOLBOX"

	if not AnimList.Missed then
		AnimList.Missed = Player.Character:WaitForChild('Humanoid'):LoadAnimation(script:WaitForChild('Skill_Miss'))
	end

	if not Action.ActionInfo["Toolbox"] then
		Action.ActionInfo["Toolbox"] = {}
	end

	if not Action.Debounces["Toolbox"] then
		Action.Debounces["Toolbox"] = {
			startingUse = false; -- only turns on while turning device on and off once it completes
			beingUsed = false; -- stays on throughout entire use
		}
	end

	if not Action.Debounces.Toolbox.beingUsed then -- if we are not in use check to see best use for toolbox

		if Generator and Hook then
			local Our = Player.Character:GetPivot().Position

			if (Generator:GetPivot().Position - Our).Magnitude <= (Hook:GetPivot().Position - Our).Magnitude then
				Item.CurrentUse = "Generator"
			else -- hook is closer
				Item.CurrentUse = "Hook"
			end
		elseif Generator and not Hook then
			Item.CurrentUse = "Generator"
		elseif Hook and not Generator then
			Item.CurrentUse = "Hook"
		end
	end

	if not currentValues.Hooked.Value
		and CurrentItem:GetAttribute("Progress") > 0
		--and CurrentItem:WaitForChild('UseProgress').Value > 0
		and HumanoidState ~= Enum.HumanoidStateType.FallingDown
		and HumanoidState ~= Enum.HumanoidStateType.Landed
		and Player.Character.Humanoid.WalkSpeed > 0
		and currentValues.Action.Value == "Nothing"
		and currentValues.HealthState.Value > 0
		and not Player.Character.PrimaryPart.Anchored
		and Item.CurrentUse
		and not currentValues.Holded.Value then -- WE CAN USE TOOLBOX IN GENERAL

		if Item.CurrentUse == "Generator" then -- BEST USE IS GENERATOR CHECK IF WE CAN USE
			local generatorPort = nil

			for _, port in pairs(Generator:WaitForChild('Workspots'):GetChildren()) do

				if generatorPort and generatorPort ~= port and port:IsA("Part") then

					if (generatorPort.Position - Player.Character:GetPivot().Position).Magnitude > (port.Position - Player.Character:GetPivot().Position).Magnitude then
						generatorPort = port
					end
				elseif not generatorPort then
					generatorPort = port
				end
			end

			if Generator.Panel.Progress.Value < 1000
				and not generatorPort.Ocuped.Deactivated.Value
				and not generatorPort.Ocuped.Value
				and not Generator:GetAttribute("Blocked") -- not blocked
				and (generatorPort.Position - Player.Character:GetPivot().Position).Magnitude <= Item.InteractDistance then

				CanRun = true
				Action.ActionInfo.Toolbox = {
					Item = CurrentItem;
					Generator = Generator;
					Port = generatorPort;
				}
			end
		elseif Item.CurrentUse == "Hook" -- BEST USE IS HOOK CHECK IF WE CAN USE
			and not Hook.Panel.Sabotaging.Value
			and not Hook.Panel.Ocuped.Value
			and not Hook.Panel.Used.Value
			and not Hook.Panel.Basement.Value
			and ((Hook.Trigger.CFrame * CFrame.new(0,0, -3)).Position - Player.Character:GetPivot().Position).Magnitude <= Item.InteractDistance then -- check against hook

			CanRun = true
			Action.ActionInfo.Toolbox = {
				Item = CurrentItem;
				Hook = Hook;
			}
		end
	elseif Action.Debounces.Toolbox.beingUsed then
		Action.Priority = 0
		CanRun = true
	else
		Action.ActionInfo.Toolbox = {}
	end

	return CanRun
end

function Item:Start(Action, ...) : "Start Using"
	if (tick() - Item.Debounces.InputEnter) < 1 or Action.Debounces.Toolbox.beingUsed or Action.Debounces.Toolbox.startingUse then return --[[warn("Anti-Spam")]] end
	Item.Debounces.InputEnter = tick()
	Action.Debounces.Toolbox.beingUsed = true
	Action.Debounces.Toolbox.startingUse = true

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	local Toolbox = Action.ActionInfo.Toolbox.Item
	local Use = Toolbox.Using

	modules.UI:Hide(true)

	local ChosenAnimation = nil
	local Connections = {}

	actionList.MovementScript.MainScript.Disabled = true
	Character.Humanoid.WalkSpeed = 0
	local Generator = nil
	local Port = nil

	if Item.CurrentUse == "Generator" then
		Character.PrimaryPart.Anchored = true
		Generator = Action.ActionInfo.Toolbox.Generator
		local Panel = Generator.Panel
		Port = Action.ActionInfo.Toolbox.Port

		modules.UI:Progress(Generator.Panel.Progress, "REPAIRING")

		obfuscate("string", currentValues.Action, "ToolBoxRepair")
		obfuscate("bool", Port.Ocuped, true)
		obfuscate("String", Port.Ocupant, Player.Name)

		ChosenAnimation = script:WaitForChild('Animation')

		actionList.MovementScript.MainScript.Disabled = true
		coroutine.resume(coroutine.create(function()
			repeat task.wait() 
				Character.PrimaryPart:PivotTo(Port.CFrame * CFrame.new(0, 0.35, 0))
			until actionList.MovementScript.MainScript.Disabled == false
		end))
		Character.Humanoid.WalkSpeed = 0
		Character.PrimaryPart.Anchored = true

		Character.PrimaryPart.Anchored = false
		Character.PrimaryPart:PivotTo(Port.CFrame * CFrame.new(0, 0.35, 0))
		Character.PrimaryPart.Anchored = true

		Connections.Generator = Generator.Panel.Progress.Changed:Connect(function()
			if Toolbox and Action and Action.ActionInfo and Action.ActionInfo.Toolbox and Generator then
				if Panel:WaitForChild('Progress').Value >= 1000 and Item.Connections.Disconnect then
					Item.Connections:Disconnect("Progress Change")

					modules.UI:Hide(false)
					modules.UI:Progress()
				end
			end
		end)

		Connections.Blocked = Generator:GetAttributeChangedSignal("Blocked"):Connect(function()

			if Generator:GetAttribute("Blocked") then
				Item.Connections:Disconnect("Blocked")
			end
		end)
	elseif Item.CurrentUse == "Hook" then
		modules.UI:Progress(Action.ActionInfo.Toolbox.Hook.Panel.Progress, 'SABOTAGING')

		obfuscate("string", currentValues.Action, "Sabotaging")
		obfuscate("Object", Action.ActionInfo.Toolbox.Hook.Panel.Sabotaging, Player)
		ChosenAnimation = script:WaitForChild('Animation2')

		local StandingPosition : Vector3 = Character:GetPivot().Position
		Character:PivotTo(CFrame.new(Vector3.new(StandingPosition.X, StandingPosition.Y - 1.65, StandingPosition.Z), Vector3.new(Action.ActionInfo.Toolbox.Hook.Collision.Position.X, StandingPosition.Y - 1.65, Action.ActionInfo.Toolbox.Hook.Collision.Position.Z)))
		Character.PrimaryPart.Anchored = true

		--Connections.Transition = Action.ActionInfo.

		Connections.Hook = Action.ActionInfo.Toolbox.Hook.Panel.Progress.Changed:Connect(function()
			if Action.ActionInfo.Toolbox.Hook.Panel.Progress.Value >= 1000 and Item.Connections.Disconnect then
				Item.Connections.Disconnect() -- binding it like this since it happens before function and i bind this after function | m1 let go function
			end
		end)
	end

	obfuscate("bool", Use, true)

	local ToolboxTrack = Character.Humanoid:LoadAnimation(ChosenAnimation)
	ToolboxTrack:Play()

	local function disconnect(reason)
		if ToolboxTrack then ToolboxTrack:Stop() ToolboxTrack = nil end

		obfuscate("String", currentValues.Action, "Nothing")
		obfuscate("bool", Use, false)

		task.spawn(function()
			if Connections.HealthStateChanged then Connections.HealthStateChanged:Disconnect() end
			if Connections.UseItem then Connections.UseItem:Disconnect() end
			if Connections.Generator then Connections.Generator:Disconnect() end
			if Connections.Hook then Connections.Hook:Disconnect() end
			if Connections.Hit then Connections.Hit:Disconnect() end
			if Connections.Progress then Connections.Progress:Disconnect() end
			if Connections.Bool then Connections.Bool:Disconnect() end
			if Connections.State then Connections.State:Disconnect() end
			if Connections.Health then Connections.Health:Disconnect() end
			if Connections.Action then Connections.Action:Disconnect() end
			if Connections.Blocked then Connections.Blocked:Disconnect() end
		end)

		if Item.CurrentUse == "Generator" then
			obfuscate("bool", Port.Ocuped, false)
			obfuscate("String", Port.Ocupant, "Nobody")

		elseif Item.CurrentUse == "Hook" then
			obfuscate("Object", Action.ActionInfo.Toolbox.Hook.Panel.Sabotaging, nil)
		end

		if Connections.HealthStateChanged then Connections.HealthStateChanged:Disconnect() end
		if Connections.UseItem then Connections.UseItem:Disconnect() end
		if Connections.Generator then Connections.Generator:Disconnect() end
		if Connections.Hook then Connections.Hook:Disconnect() end
		if Connections.Hit then Connections.Hit:Disconnect() end
		if Connections.Progress then Connections.Progress:Disconnect() end
		if Connections.Bool then Connections.Bool:Disconnect() end
		if Connections.State then Connections.State:Disconnect() end
		if Connections.Health then Connections.Health:Disconnect() end
		if Connections.Action then Connections.Action:Disconnect() end
		if Connections.Blocked then Connections.Blocked:Disconnect() end

		Character.PrimaryPart.Anchored = false
		actionList.MovementScript.MainScript.Disabled = false

		Action.Debounces.Toolbox.beingUsed = false
		Action.Priority = Default
		modules.UI:Hide(false)
		modules.UI:Progress()
	end

	-- Wait until value is switched and angle character --
	repeat task.wait()
	until Use.Value

	Connections.UseItem = script.Value.Changed:Connect(function()
		if script.Value.Value == true then
			script.Value.Value = false
			local gen = Generator.Panel.Progress
			disconnect()
			script.RemoteEvent:FireServer(gen, Toolbox)
		end
	end)

	Connections.Health = currentValues.HealthState.Changed:Connect(function()
		if currentValues.HealthState.Value ~= 1 then
			disconnect()
		end
	end)

	Connections.Hit = Character:GetAttributeChangedSignal("LastHit"):Connect(function(test)
		disconnect()
	end)

	Connections.Bool = Use.Changed:Connect(function()
		if not Use.Value then
			disconnect("bool")
		end
	end)

	Connections.Progress = Toolbox:GetAttributeChangedSignal("Progress"):Connect(function()
		local Progress = Toolbox:GetAttribute("Progress")

		if Progress <= 0 then

			if Item.CurrentUse == "Generator" then
				if Connections.Progress then Connections.Progress:Disconnect() end
				obfuscate("String", currentValues.Action, "Repairing")
			else
				disconnect("progress")
			end
		end
	end)

	Connections.State = Character.Humanoid.StateChanged:Connect(function()
		local State = Character.Humanoid:GetState()

		if State == Enum.HumanoidStateType.FallingDown or State == Enum.HumanoidStateType.Landed then
			disconnect("state")
		end
	end)

	Connections.Action = currentValues.Action.Changed:Connect(function()

		if currentValues.Action.Value ~= "Sabotaging" and currentValues.Action.Value ~= "Repairing" and currentValues.Action.Value ~= "ToolBoxRepair" then
			Item.Connections.Disconnect()
		end
	end)

	Connections.HealthStateChanged = currentValues.HealthState.Changed:Connect(function()
		disconnect()
	end)

	Item.Connections.Disconnect = disconnect
	Action.Debounces.Toolbox.startingUse = false
end

function Item:Stop(Action, ...) : "Stop Using"
	if (tick() - Item.Debounces.InputExit) < 1 or not Item.Connections.Disconnect then return warn('Anti-Spam exit') end
	Item.Debounces.InputExit = tick()

	local args = {...}

	Item.Connections.Disconnect()
	Item.Connections.Disconnect = nil
end

return Item