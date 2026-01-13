local Player = game.Players.LocalPlayer
local Defaults = 1;

local Action = {
	Key = "Interact4";
	ActionName = "CRAFT SHARD";
	InteractDistance = 4;
	Priority = 1; -- scale of 1-5
	ActionInfo = {
		Totem = nil;
		Disconnect = nil;
	},
	Debounces = {
		InProgress = false;
		InputEnter = tick();
		InputExit = tick();
	}
}


local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Totem : Model = actionList.Totem
	local CurrentItem = actionList.CharacterItem

	if not Totem or CurrentItem then return false end -- we don't have totem or we have a item (so we can't gain a item)
	local HasPerk, PerkTier = modules.Data:GetPerk("Scrapper")


	if (Totem:WaitForChild("Root").Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance -- Distance Check
		and currentValues.HealthState.Value > 0
		and currentValues.Action.Value == "Nothing"
		and Totem:WaitForChild('Panel').State.Value == 0
		and Totem:WaitForChild('Panel').Player.Value == ""
		and Totem:WaitForChild('Panel').Effect.Value ~= "Blessing"
		and HasPerk -- we have the perk
		and Totem:WaitForChild('Panel').Progress.Value < 1000 then

		Action.ActionInfo.Totem = Totem
		CanRun = true
	elseif Action.Debounces.InProgress then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	else
		Action.ActionInfo.Totem = nil
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or not Action.ActionInfo.Totem or Action.Debounces.InProgress then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	local totem = Action.ActionInfo.Totem

	modules.UI:Hide(true)
	modules.UI:Progress(totem.Panel.Progress, "CRAFTING") -- bind to progress, should show up and be binded

	obfuscate("String", currentValues.Action, "CraftingShard")
	obfuscate("String", totem.Panel.Player, Player.Name)

	if Player.Character:GetAttribute("Perk_Defense_Time") then
		remoteList.Perk:FireServer("Self Defense", false) -- de-activate our perk
	end

	local Tween = game:GetService('TweenService'):Create(Character.PrimaryPart, TweenInfo.new(.65), {
		CFrame = CFrame.new(Character:GetPivot().Position, Vector3.new(totem.Root.Position.X, Character:GetPivot().Position.Y, totem.Root.Position.Z)) * CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(-15), 0, 0);
	})

	actionList.MovementScript.Disabled = true
	Character.PrimaryPart.Anchored = true
	Tween:Play()

	local TotemTrack = Character.Humanoid:LoadAnimation(script:WaitForChild('Animation'))
	TotemTrack:Play()
	TotemTrack:AdjustSpeed(.7)

	local Connections = {}

	local function disconnect()
		actionList.MovementScript.Disabled = false
		Character.PrimaryPart.Anchored = false

		obfuscate("String", currentValues.Action, "Nothing")
		obfuscate("String", totem.Panel.Player, "")

		if TotemTrack then TotemTrack:Stop() TotemTrack = nil end
		if Connections.Progress then Connections.Progress:Disconnect() end
		if Connections.Hit then Connections.Hit:Disconnect() end
		if Connections.Action then Connections.Action:Disconnect() end
		if Connections.Blessed then Connections.Blessed:Disconnect() end

		Action.Debounces.InProgress = false
		Action.Priority = Defaults
		modules.UI:Hide(false)
		modules.UI:Progress() -- bind to nothing, should become unbinded and remove self from sight
	end

	Connections.Progress = totem.Panel.Progress.Changed:Connect(function()

		if totem.Panel.Progress.Value >= 1000 then
			disconnect()
		end
	end)

	Connections.Hit = Character:GetAttributeChangedSignal("LastHit"):Connect(function(test)
		disconnect()
	end)

	Connections.Action = currentValues.Action.Changed:Connect(function()

		if not (currentValues.Action.Value == "CraftingShard") then
			disconnect() 
		end
	end)

	Connections.Blessed = totem:WaitForChild('Panel'):WaitForChild("Effect").Changed:Connect(function()
		if totem:WaitForChild('Panel').Effect.Value == "Blessing" then
			disconnect()
		end
	end)

	Action.ActionInfo.Disconnect = disconnect

	if totem:WaitForChild('Panel').Effect.Value == "Blessing" then
		disconnect()
	end
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
	local actionList, remoteList, modules = args[1], args[2], args[3]

	if Constraints(actionList, modules) then
		return true
	end

	return false
end

return Action