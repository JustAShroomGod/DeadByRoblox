local Player = game.Players.LocalPlayer
local Defaults = 1;

local Action = {
	Key = "Interact8";
	ActionName = "#Sprint";
	Priority = 1; -- scale of 1-5
	ActionInfo = {},
	Debounces = {
		InputEnter = tick();
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = true -- by default false

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < .1 then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	
	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	
	if actionList.Mobile.Sprint then
		actionList.Mobile.Sprint = false
		actionList.MovementScript:WaitForChild('Shift').Value = false
		obfuscate("bool", actionList.MovementScript.Shift, false)
		Player.Character:SetAttribute("Sprint", false)
		--modules.Code.Speeds:removeMultiplier(Player, 'Sprint')
	elseif not actionList.Mobile.Sprint and actionList.ValueList.HealthState.Value > 0 then -- trying to sprint
		actionList.Mobile.Sprint = true
		actionList.MovementScript:WaitForChild('Shift').Value = true
		obfuscate("bool", actionList.MovementScript.Shift, true)
		Player.Character:SetAttribute("Sprint", true)
		-- modules.Code.Speeds:removeMultiplier(Player, 'Sprint') TODO: Moved to updater, because this doesn't account for healthstates/going down (also this only works 4 mobile)
		--module.Code.Speeds:addMultiplier(Player, 'Sprint', modules.Code.Speeds.Survivor.Running, -1)
		
		if actionList.ValueList.Crouching.Value then
			actionList.Mobile.Crouch = false
			actionList.ValueList:WaitForChild('Crouching').Value = false
			obfuscate("bool", actionList.ValueList.Crouching, false)
			Player.Character:SetAttribute("Crouch", false)
		end
	end
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
