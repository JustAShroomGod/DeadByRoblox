local Player = game.Players.LocalPlayer
local Defaults = 1;

local Action = {
	Key = "Interact";
	ActionName = "STRUGGLE (SPAM)";
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		IsShowing = false; -- if we are showing this progress bar or not
	},
	Debounces = {
		InputEnter = tick();
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false

	if actionList.ValueList.Holded.Value then -- is held

		CanRun = true
	end

	if CanRun then
		modules.UI:Progress(actionList.ValueList.WiggleProgress, "STRUGGLING")
		Action.ActionInfo.IsShowing = true
	elseif not CanRun and Action.ActionInfo.IsShowing then
		modules.UI:Progress()
		Action.ActionInfo.IsShowing = false
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 0.1 then return --[[warn("Anti-Spam")]] end --from 0.05 -> 0.1
	Action.Debounces.InputEnter = tick()

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]

	remoteList.Server:FireServer("Wiggle", actionList.KillerPlayer)
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
