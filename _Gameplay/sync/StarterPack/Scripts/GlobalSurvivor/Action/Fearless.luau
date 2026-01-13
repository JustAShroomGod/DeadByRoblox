local Player = game.Players.LocalPlayer
local Defaults = 5;

local shoveRange = 5

local Action = {
	Key = "Interact4";
	ActionName = "SHOVE (FEARLESS)";
	Priority = 3; -- scale of 1-5
	ActionInfo = {},
	Debounces = {
		Active = false;
		InputEnter = tick();
		InputExit = tick();
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList

	local HasPerk, PerkTier = modules.Data:GetPerk("Fearless")

	if (Player.Character:GetAttribute("ShoveGlobalCD") == nil) then
		Player.Character:SetAttribute("ShoveGlobalCD", workspace:GetServerTimeNow())
	end

	if currentValues.HealthState.Value >= 2
		and currentValues.Action.Value == "Nothing"
		and not currentValues.Hooked.Value
		and not currentValues.Holded.Value
		and actionList.MovementScript.Shift.Value
		and not modules.Code:IsExhausted()
		and HasPerk -- has to have dead hard
		and (actionList.KillerPlayer and Player:DistanceFromCharacter(actionList.KillerPlayer.Character:GetPivot().Position) <= shoveRange)
		and (workspace:GetServerTimeNow() - Player.Character:GetAttribute("ShoveGlobalCD")) >= 10
		and Player.Character.Humanoid.MoveDirection.magnitude ~= 0 then

		CanRun = true
	elseif Action.Debounces.Active then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or Action.Debounces.Active then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Active = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	Player.Character:SetAttribute("ShoveGlobalCD", workspace:GetServerTimeNow())

	modules.UI:Hide(true)

	remoteList.Fearless:FireServer()

	local fs = workspace:GetServerTimeNow()

	actionList.MovementScript.MainScript.Disabled = true
	Character.Humanoid.WalkSpeed = 0
	Character.PrimaryPart.Anchored = true

	repeat task.wait()
	until (currentValues.Action.Value == 'Shoving' or (workspace:GetServerTimeNow() - fs) >= 3) -- wait for shoving to take effect

	repeat task.wait()
	until currentValues.Action.Value == 'Nothing'
	actionList.MovementScript.MainScript.Disabled = false
	Character.PrimaryPart.Anchored = false
	Action.Debounces.Active = false
	Action.Priority = Defaults
	modules.UI:Hide(false)
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