local Player = game.Players.LocalPlayer
local Default = 3

local Item = {
	CurrentUse = nil;
	Range = 5;
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

	Action.ActionName = "STAB"

	if not Action.ActionInfo["Knife"] then
		Action.ActionInfo["Knife"] = {}
	end

	if not Action.Debounces["Knife"] then
		Action.Debounces["Knife"] = {
			startingUse = false; -- only turns on while turning device on and off once it completes
			beingUsed = false; -- stays on throughout entire use
		}
	end

	if (Player.Character:GetAttribute("ShoveGlobalCD") == nil) then
		Player.Character:SetAttribute("ShoveGlobalCD", workspace:GetServerTimeNow())
	end

	if not currentValues.Hooked.Value
		and currentValues.Action.Value == "Nothing"
		and currentValues.HealthState.Value > 0
		and (actionList.KillerPlayer and Player:DistanceFromCharacter(actionList.KillerPlayer.Character:GetPivot().Position) <= Item.Range) -- killer is close to us
		and (workspace:GetServerTimeNow() - Player.Character:GetAttribute("ShoveGlobalCD")) >= 10
		and not Player.Character.PrimaryPart.Anchored
		and not currentValues.Holded.Value then

		CanRun = true
		Action.ActionInfo.Knife = {}
	elseif Action.Debounces.Knife.beingUsed then
		Action.Priority = 0
		CanRun = true
	else
		Action.ActionInfo.Knife = {}
	end

	return CanRun
end

function Item:Start(Action, ...) : "Start Using"
	if (tick() - Item.Debounces.InputEnter) < 1 or Action.Debounces.Knife.beingUsed or Action.Debounces.Knife.startingUse then return --[[warn("Anti-Spam")]] end
	Item.Debounces.InputEnter = tick()
	Action.Debounces.Knife.beingUsed = true
	Action.Debounces.Knife.startingUse = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	local Bone_Knife = Action.ActionInfo.Knife.Item

	Player.Character:SetAttribute("ShoveGlobalCD", workspace:GetServerTimeNow())

	modules.UI:Hide(true)

	remoteList.Knife:FireServer()

	local fs = workspace:GetServerTimeNow()
	actionList.MovementScript.MainScript.Disabled = true
	Character.Humanoid.WalkSpeed = 0
	Character.PrimaryPart.Anchored = true

	local ticks = 0

	repeat task.wait()
		ticks += 0.001
	until currentValues.Action.Value == 'Stabbing' or ticks < 2 -- wait for shoving to take effect

	local ticks = 0

	repeat task.wait()
		ticks += 0.001
	until currentValues.Action.Value == 'Nothing' or ticks < 2 
	actionList.MovementScript.MainScript.Disabled = false
	Character.PrimaryPart.Anchored = false

	Action.Debounces.Active = false
	Action.Priority = Default
	modules.UI:Hide(false)

	Action.Debounces.Knife.startingUse = false
	Action.Debounces.Knife.beingUsed = false
end

function Item:Stop(Action, ...) : "Stop Using"
	if (tick() - Item.Debounces.InputExit) < 1 or not Item.Connections.Disconnect then return warn('Anti-Spam exit') end
	Item.Debounces.InputExit = tick()

	local args = {...}

	Item.Connections.Disconnect()
	Item.Connections.Disconnect = nil
end

return Item	