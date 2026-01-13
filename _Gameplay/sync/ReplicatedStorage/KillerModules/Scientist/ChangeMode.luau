local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = game.Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid

local Scripts = Player.Backpack.Scripts
local KillerAction = Scripts.values.KillerAction

local DefaultPriority = 3

local Action = {
	Key = "Secondary_Power";
	ActionName = "Manipulate Time";
	Priority = -1; -- scale of 1-5
	ActionInfo = {},
	Debounces = {
		InputEnter = tick();
		Deploying = false;
		Exiting = false;
	},
}

function CreateAttributes()
	Player.PlayerValues:SetAttribute("ScaleMode", false)
	Player.PlayerValues:SetAttribute("ScaleTick", os.time())
end

CreateAttributes()

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local currentValues = actionList.ValueList
	
	-- We want to allow usage whenever you feel like it

	--[[if (KillerAction.Value ~= "Nothing") then return false end
	if (Player.Character:GetAttribute("Carry")) then return false end
	if (Player.Character:GetAttribute("Swing")) then return false end]]

	if Action.Debounces.Deploying then -- if in progress do not let go of this interaction
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
	
	modules.UI:HideSpecific(Action.ActionName, true)
	Player.PlayerValues:SetAttribute("ScaleTick", os.time())
	Player.PlayerValues:SetAttribute("ScaleMode", true)
end

function Action:Stop(...) : "Stop Action?"
	--if not Action.ActionInfo.Disconnect or Action.Debounces.Exiting then return warn('Anti-Spam Exit') end -- if we don't have disconnect do not trigger
	Action.Debounces.Exiting = true
	Action.Debounces.Holding = false
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	
	Player.PlayerValues:SetAttribute("ScaleMode", false)
	modules.UI:HideSpecific(Action.ActionName, false)
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
