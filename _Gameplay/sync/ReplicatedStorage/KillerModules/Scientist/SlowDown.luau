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
	Key = "Interact2";
	ActionName = "Slow Down";
	Priority = -2; -- scale of 1-5
	ActionInfo = {},
	Debounces = {
		InputEnter = tick();
		Deploying = false;
		Exiting = false;
	},
}

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local currentValues = actionList.ValueList
	
	-- We want to allow usage whenever you feel like it

	--[[if (KillerAction.Value ~= "Nothing") then return false end
	if (Player.Character:GetAttribute("Carry")) then return false end
	if (Player.Character:GetAttribute("Swing")) then return false end]]
	
	--if ((os.time() - Player.PlayerValues:GetAttribute("ScaleTick") < 0.5)) then return false end
	if (not Player.PlayerValues:GetAttribute("ScaleMode")) then return false end

	return true
end

function Action:Start(...) : "Start Action?"
	
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Deploying = true
	Action.Debounces.Holding = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	
	local Character = Player.Character
	TimeDilation.PowerValues.PowerRemote:FireServer("Speed-")
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
