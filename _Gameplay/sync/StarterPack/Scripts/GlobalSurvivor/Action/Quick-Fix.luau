local Player = game.Players.LocalPlayer
local Defaults = 5;


local ControlScript = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()

local Action = {
	Key = "Interact4";
	ActionName = "QUICK FIX";
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
	
	local CurrentItem = actionList.CharacterItem
	local HasPerk, PerkTier = modules.Data:GetPerk("QuickFix")
	
	if not HasPerk or not CurrentItem then return false end
	
	if currentValues.HealthState.Value > 0
		and not string.match(string.lower(CurrentItem.Name), 'key') -- can not charge keys
		and not string.match(string.lower(CurrentItem.Name), 'cracker') -- can not charge keys
		and not CurrentItem:GetAttribute("QuickFixed")
		and not (CurrentItem:GetAttribute("Progress") == 1000) 
		and currentValues.Action.Value == "Nothing"
		and not currentValues.Hooked.Value
		and not currentValues.Holded.Value
		and tonumber(actionList.PerkValues.QuickFix.Charge.Value) >= 100
		and Player.Character.Humanoid.MoveDirection.magnitude == 0 then
		
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
	
	modules.UI:Hide(true)
	
	remoteList.Quick_Fix:FireServer(actionList.CharacterItem)
	
	-- wait until our charge is drained --
	repeat task.wait()
	until tonumber(actionList.PerkValues.QuickFix.Charge.Value) <= 0
	
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
