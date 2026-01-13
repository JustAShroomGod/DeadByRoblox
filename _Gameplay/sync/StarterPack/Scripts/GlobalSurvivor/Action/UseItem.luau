local Player = game.Players.LocalPlayer

local ItemTypes = {}

local Action = {
	Key = "Interact3"; -- mouse 2
	ActionName = "USE ITEM";
	Priority = 3; -- scale of 1-5
	ActionInfo = {};
	Debounces = {};
}

for _,m : ModuleScript in pairs(script:GetChildren()) do
	ItemTypes[m.Name] = require(m)
end

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local CurrentItem = actionList.CharacterItem

	if modules.Code:GetEffect("Cloaked") then return false end
	if not CurrentItem then return false end -- We don't have a item at all
	if not Player.Character:GetAttribute("IntroDone") then return false end
	local Keyword : string = nil
	
	if string.match(string.lower(CurrentItem.Name), "flashlight") then
		Keyword = "Flashlight"
	elseif string.match(string.lower(CurrentItem.Name), "tool") then
		Keyword = "Toolbox"
	elseif string.match(string.lower(CurrentItem.Name), "kit") then
		Keyword = "Medkit"
	elseif string.match(string.lower(CurrentItem.Name), 'key') then
		Keyword = "Key"
	elseif string.match(string.lower(CurrentItem.Name), "firecracker") then
		Keyword = "FireCracker"
	elseif string.match(string.lower(CurrentItem.Name), 'knife') then
		Keyword = 'Knife'
	else
		warn(CurrentItem.Name, "is unknown/unmatched!")
		return false
	end
	
	if not ItemTypes[Keyword] then return warn("Missing Module for", Keyword) end
	
	CanRun = ItemTypes[Keyword]:Constraints(actionList, modules, Action)
	
	if CanRun then
		Action.ActionInfo.Module = ItemTypes[Keyword]
	else
		Action.ActionInfo.Module = nil
	end
	
	return CanRun
end

function Action:Start(...) : "Start Item Use"
	if not Action.ActionInfo.Module then return warn("No Item Module to latch!") end
	Action.ActionInfo.Module:Start(Action, ...)
end

function Action:Stop(...) : "Stop Item Use"
	if not Action.ActionInfo.Module then return warn("No Item Module to latch!") end
	Action.ActionInfo.Module:Stop(Action, ...)
end

function Action:Process(...) : boolean | "Returns true if this action can be ran"
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	
	if Constraints(actionList, modules) then
		return true
	end
end

return Action
