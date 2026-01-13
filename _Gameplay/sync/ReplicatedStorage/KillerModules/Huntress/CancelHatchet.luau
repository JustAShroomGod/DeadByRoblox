local Player = game.Players.LocalPlayer
local Killer_Module = require(game:GetService("ReplicatedStorage"):WaitForChild("Game_Data"):WaitForChild("Killers"):WaitForChild("Huntress"))

local DefaultPriority = 3

local Action = {
	Key = "Interact2";
	ActionName = "CANCEL THROW";
	Priority = 3; -- scale of 1-5
	InteractDistance = 6.5;
	ActionInfo = {},
	Connections = {};
	Debounces = {
		InputEnter = workspace:GetServerTimeNow();
		Deploying = false;
		Exiting = false;
	}
}

local Tracks = {};

signal = {}
var = {
	cg_time = 1/2
	,min_charge = 1/3
}


function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList

	if script:WaitForChild("Value").Value == true -- doing nothing
		and not Player.Character:GetAttribute("Carry") then -- if already revving bypass all of it

		CanRun = true
	elseif Action.Debounces.Deploying then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (workspace:GetServerTimeNow() - Action.Debounces.InputEnter) < 0.25 or Action.Debounces.Deploying  then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = workspace:GetServerTimeNow()
	Action.Debounces.Deploying = true

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Info = actionList.KillerInfo
	local Character = Player.Character

	game.ReplicatedStorage:WaitForChild("-LockerAuras"):WaitForChild("HatchetSoundEvent"):FireServer("Cancel")

	script:WaitForChild("Value").Value = false
	Action.Debounces.Deploying = false
end

function Action:Stop(...)
	if not Action.ActionInfo.Disconnect or Action.Debounces.Exiting then return warn('Anti-Spam Exit') end
	Action.Debounces.Exiting = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList

	Action.ActionInfo.Disconnect()
	Action.ActionInfo.Disconnect = nil

	Action.Debounces.Exiting = false
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