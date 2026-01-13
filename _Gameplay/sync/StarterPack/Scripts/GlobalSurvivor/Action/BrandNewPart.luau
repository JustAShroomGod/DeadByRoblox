local Player = game.Players.LocalPlayer
local Defaults = 1;

local Action = {
	Key = "Secondary_Power";
	ActionName = "USE BRAND NEW PART";
	Priority = 1; -- scale of 1-5
	ActionInfo = {
		Item = nil;
	},
	Debounces = {
		Dropping = false;
		InputEnter = tick();
		InputExit = tick();
	}
}


local Data = require(game.ReplicatedStorage.Modules.Data)
local Keybinds = Data:GetKeybinds()

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local CurrentItem = actionList.CharacterItem
	local State = Player.Character.Humanoid:GetState()
	
	if currentValues.HealthState.Value >= 1
		and currentValues.Action.Value == "ToolBoxRepair"
		and not currentValues.Hooked.Value
		and not currentValues.Holded.Value
		and CurrentItem
		and (CurrentItem:GetAttribute("Addon_1") == "Brand New Part" or CurrentItem:GetAttribute("Addon_2") == "Brand New Part")
		and State ~= Enum.HumanoidStateType.Freefall then
		
		Action.ActionInfo.Item = CurrentItem
		CanRun = true
		
		modules.UI:AlwaysShowSpecific(Action.ActionName, true)
	else
		Action.ActionInfo.Item = nil
		modules.UI:AlwaysShowSpecific(Action.ActionName, false)
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 2 or Action.Debounces.Dropping or not Action.ActionInfo.Item then return --[[warn("Anti-Spam")]] end
	script.Parent.UseItem.Toolbox.Value.Value = true
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
