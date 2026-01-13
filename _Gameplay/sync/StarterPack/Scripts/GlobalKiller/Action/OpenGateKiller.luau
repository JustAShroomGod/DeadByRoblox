local Player = game.Players.LocalPlayer
local Defaults = 3;

local Action = {
	Key = "Interact2";
	ActionName = "OPEN EXIT";
	InteractDistance = 4.7;
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		Gate = nil;
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
	local Gate : Model = actionList.Gate

	if not Gate then return false end
	local generatorRepaired = workspace:WaitForChild("MatchValues"):WaitForChild("GeneratorsRepaired")

	if (Gate:WaitForChild("Port").Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance -- Distance Check
		and currentValues.HealthState.Value > 0
		and currentValues.Action.Value == "Nothing"
		and KillerConstraints(modules)
		and generatorRepaired.Value >= 5 -- Generator Count Reached
		and Gate:WaitForChild('Panel'):WaitForChild('Using').Value == "NoUsing"
		and Gate:WaitForChild('Panel'):WaitForChild('Progress').Value < 1000 then

		Action.ActionInfo.Gate = Gate
		CanRun = true
	elseif Action.Debounces.InProgress then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	else
		Action.ActionInfo.Gate = nil
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
	if (tick() - Action.Debounces.InputEnter) < 1.5 or not Action.ActionInfo.Gate or Action.Debounces.InProgress then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	local gate = Action.ActionInfo.Gate

	gate:WaitForChild("Panel"):WaitForChild("Exit_Gate"):FireServer("KillerOpen")

	local function disconnect()
		Action.Debounces.InProgress = false
		Action.ActionInfo.Disconnect = nil
	end

	disconnect()
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
