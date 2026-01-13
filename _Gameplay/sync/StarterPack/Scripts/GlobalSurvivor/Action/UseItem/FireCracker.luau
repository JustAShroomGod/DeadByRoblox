local Player = game.Players.LocalPlayer
local Default = 3

local Item = {
	CurrentUse = nil;
	Connections = {};
	Debounces = {
		InputEnter = tick();
		InputExit = tick();
	},
}

function Item:Constraints(actionList, modules, Action) : boolean | "Return true if can do action"
	local CanRun = false
	local currentValues = actionList.ValueList
	local CurrentItem = actionList.CharacterItem
	local HumanoidState = Player.Character.Humanoid:GetState()
	
	Action.ActionName = "THROW FIRECRACKER"

	if not Action.ActionInfo["FireCracker"] then
		Action.ActionInfo["FireCracker"] = {}
	end

	if not Action.Debounces["FireCracker"] then
		Action.Debounces["FireCracker"] = {
			startingUse = false; -- only turns on while turning device on and off once it completes
			beingUsed = false; -- stays on throughout entire use
		}
	end
	
	if not currentValues.Hooked.Value
		and currentValues.Action.Value == "Nothing"
		and currentValues.HealthState.Value > 0
		and not Player.Character.PrimaryPart.Anchored
		and not currentValues.Holded.Value then

		CanRun = true
		Action.ActionInfo.FireCracker = {}
	elseif Action.Debounces.FireCracker.beingUsed then
		Action.Priority = 0
		CanRun = true
	else
		Action.ActionInfo.FireCracker = {}
	end

	return CanRun
end

function Item:Start(Action, ...) : "Start Using"
	if (tick() - Item.Debounces.InputEnter) < 1 or Action.Debounces.FireCracker.beingUsed or Action.Debounces.FireCracker.startingUse then return --[[warn("Anti-Spam")]] end
	Item.Debounces.InputEnter = tick()
	Action.Debounces.FireCracker.beingUsed = true
	Action.Debounces.FireCracker.startingUse = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	
	local FireCracker = Action.ActionInfo.FireCracker.Item

	modules.UI:Hide(true)
	
	remoteList.FireCracker:FireServer()

	local fs = workspace:GetServerTimeNow()

	repeat task.wait()
	until currentValues.Action.Value == 'ThrowingFirecracker' -- wait for shoving to take effect

	repeat task.wait()
	until currentValues.Action.Value == 'Nothing'

	Action.Debounces.Active = false
	Action.Priority = Default
	modules.UI:Hide(false)

	Action.Debounces.FireCracker.startingUse = false
	Action.Debounces.FireCracker.beingUsed = false
end

function Item:Stop(Action, ...) : "Stop Using"
	if (tick() - Item.Debounces.InputExit) < 1 or not Item.Connections.Disconnect then return warn('Anti-Spam exit') end
	Item.Debounces.InputExit = tick()

	local args = {...}

	Item.Connections.Disconnect()
	Item.Connections.Disconnect = nil
end

return Item
