local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = game.Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid

local Scripts = Player.Backpack.Scripts
local KillerAction = Scripts.values.KillerAction

local TimeDilation = Player.Character:WaitForChild("Time Dilation")
local DefaultPriority = 3

local Action = {
	Key = "Interact3";
	ActionName = "Temporal Reversion";
	Priority = 3; -- scale of 1-5
	ActionInfo = {},
	Debounces = {
		InputEnter = tick();
		Deploying = false;
		Exiting = false;
	},
}

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local currentValues = actionList.ValueList

	if (KillerAction.Value ~= "Nothing") then return false end
	if (Player.Character:GetAttribute("Carry")) then return false end
	if (Player.Character:GetAttribute("Swing")) then return false end
	if (Player.PlayerValues:GetAttribute("ScaleMode")) then return false end
	if (workspace.MatchValues:WaitForChild("TimeScale").Value >= 1) then return false end
	if (Character["Time Dilation"].PowerValues:GetAttribute("Current") < 100) then return false end

	if Action.Debounces.Deploying then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		return true
	end

	return true
end

function Action:Start(...) : "Start Action?"
	--if (tick() - Action.Debounces.InputEnter) < 1 or Action.Debounces.Deploying then return warn("Anti-Spam") end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Deploying = true
	Action.Debounces.Holding = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	
	local Character = Player.Character
	TimeDilation.PowerValues.PowerRemote:FireServer("Reverse")
end

function Action:Stop(...) : "Stop Action?"
	--if not Action.ActionInfo.Disconnect or Action.Debounces.Exiting then return warn('Anti-Spam Exit') end -- if we don't have disconnect do not trigger
	Action.Debounces.Exiting = true
	Action.Debounces.Holding = false
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
end

function Action:Process(...) : boolean | "Returns true if this action can be ran"
	local args = {...}
	local actionList, remoteList = args[1], args[2]

	if Constraints(actionList) then
		return true
	end

	return false
end

return Action
