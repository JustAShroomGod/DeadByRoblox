local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = game.Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid
local Blink = Character.Blink

local Scripts = Player.Backpack.Scripts
local KillerAction = Scripts.values.KillerAction

local DefaultPriority = 3

local Action = {
	Key = "Interact3";
	ActionName = "Swap";
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		PortOffset = 6;
		TravelTime = 0.7;
		CollisionRadius = 0.25;
	},
	Debounces = {
		InputEnter = tick();
		Deploying = false;
		Exiting = false;
		CanBlink = true;
		Holding = false;
	},
	States = {
		["Idle"] = 0;
		["Charging"] = 1;
		["Teleporting"] = 2;
		["Fatigue"] = 3;
		["ChainCharge"] = 4;
		["PostBlink"] = 5;
	},
	Power = {},
	Limits = {},
	Connections = {},
	CollisionMap = {},
	PositionOrb = nil,
	ValidActions = {"Nothing", "BlinkAction", "Fatigue"}
}

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	
	if not actionList.KillerInfo then
		
		actionList.KillerInfo = {
			LastSwing = (Player.Character:GetAttribute("SwingEnd") or 0);
		}
	end
	
	if (KillerAction.Value == "Nothing" or KillerAction.Value == "BlinkAction")
		and not Player.Character:GetAttribute("Carry")
		and not Player.Character:GetAttribute("Swing")
		and (currentValues.Parent:WaitForChild("BLOODPOINT"):FindFirstChild("REMOVE") ~= nil)
		and not currentValues.Stunned.Value then
		
		CanRun = true
	elseif Action.Debounces.Deploying then -- if in progress do not let go of this interaction
		
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
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
	local Blink = Character.Blink
	
	--modules.UI:Hide(true)
	
	Blink.PowerValues.PowerRemote:FireServer("Swap")
	
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
