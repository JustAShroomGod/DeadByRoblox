local Player = game.Players.LocalPlayer
local Defaults = 1;

local Action = {
	Key = "Interact9";
	ActionName = "#Crouch";
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

	if actionList.Mobile.Crouch then
		actionList.Mobile.Crouch = false
		actionList.ValueList:WaitForChild('Crouching').Value = false
		obfuscate("bool", actionList.ValueList.Crouching, false)
		Player.Character:SetAttribute("Crouch", false)
		--modules.Code.Speeds:removeMultiplier(Player, 'Crouch')
	elseif not actionList.Mobile.Crouch and actionList.ValueList.HealthState.Value > 0 then -- trying to sprint
		actionList.Mobile.Crouch = true
		actionList.ValueList:WaitForChild('Crouching').Value = true
		obfuscate("bool", actionList.ValueList.Crouching, true)
		Player.Character:SetAttribute("Crouch", true)
		-- modules.Code.Speeds:removeMultiplier(Player, 'Crouch')
		--module.Code.Speeds:addMultiplier(Player, 'Crouch', modules.Code.Speeds.Survivor.Crouching, -1)
		
		if actionList.MovementScript:WaitForChild('Shift').Value then
			actionList.Mobile.Sprint = false
			actionList.MovementScript:WaitForChild('Shift').Value = false
			obfuscate("bool", actionList.MovementScript.Shift, false)
			Player.Character:SetAttribute("Sprint", false)
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
