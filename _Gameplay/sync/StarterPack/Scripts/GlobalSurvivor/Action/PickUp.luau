local Player = game.Players.LocalPlayer
local Defaults = 3;

local Action = {
	Key = "Interact2";
	ActionName = "PICK UP";
	InteractionDistance = 4;
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		Item = nil;
	},
	Debounces = {
		Lifting = false;
		InputEnter = tick();
		InputExit = tick();
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Item = actionList.Item
	local CurrentItem = actionList.CharacterItem

	if not Item then return false end

	if Item.Name == "Red_FireCracker" then

		if Item:FindFirstChild("Used") then

			if Item:FindFirstChild("Used").Value then
				return
			end
		end
	end

	if currentValues.HealthState.Value > 0
		and currentValues.Action.Value == "Nothing"
		and not currentValues.Hooked.Value
		and not currentValues.Holded.Value
		and Item.Parent == workspace
		--and not CurrentItem -- making the current item check here, because at some point in interaction we will gain current item
		and (Item:GetPivot().Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractionDistance
		and not Item:GetAttribute("Grabbed")
		and (Player.Character.Humanoid.MoveDirection.magnitude == 0)  then


		Action.ActionInfo.Item = Item
		CanRun = true
	elseif Action.Debounces.Lifting then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	else
		Action.ActionInfo.Item = nil
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 2 or Action.Debounces.Lifting or not Action.ActionInfo.Item then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Lifting = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	modules.UI:Hide(true)
	actionList.MovementScript.MainScript.Disabled = true
	Character.Humanoid.WalkSpeed = 0
	local CurrentItem = actionList.CharacterItem
	if CurrentItem then
		remoteList.Item:FireServer("GRAB", Action.ActionInfo.Item, CurrentItem)
	else
		remoteList.Item:FireServer("GRAB", Action.ActionInfo.Item)
	end

	local Connections = {}

	local function disconnect()
		actionList.MovementScript.MainScript.Disabled = false

		if Connections.Action then Connections.Action:Disconnect() end
		if Connections.Hit then Connections.Hit:Disconnect() end

		Action.Debounces.Lifting = false
		Action.Priority = Defaults
		modules.UI:Hide(false)
	end

	Connections.Action = currentValues.Action.Changed:Connect(function()
		if currentValues.Action.Value == "Nothing" then
			disconnect()
		end
	end)

	Connections.Hit = Character:GetAttributeChangedSignal("LastHit"):Connect(function(test)
		disconnect()
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