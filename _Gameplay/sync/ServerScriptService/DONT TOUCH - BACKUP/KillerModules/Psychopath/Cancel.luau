local Player = game.Players.LocalPlayer
local DefaultPriority = 3

local Action = {
	Key = "Interact3";
	ActionName = "End Rage";
	Priority = 3; -- scale of 1-5
	ActionInfo = {},
	Debounces = {
		InputEnter = tick();
		Deploying = false;
		Exiting = false;
	},
	States = {
		["Idle"] = 0;
		["Rage"] = 1;
		["Fatigue"] = 2;
	},
	Power = {}
}

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	
	if not actionList.KillerInfo then
		
		actionList.KillerInfo = {
			LastSwing = (Player.Character:GetAttribute("SwingEnd") or 0);
		}
	end
	
	updateAttributes(actionList)
	
	if currentValues.KillerAction.Value == "Nothing"
		and not Player.Character:GetAttribute("Carry")
		and not Player.Character:GetAttribute("Swing")
		and not currentValues.Stunned.Value
		and (Action.Power.State == Action.States.Rage) then
		
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
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	
	local Character = Player.Character
	local BloodRage = Character.BloodRage

	modules.UI:Hide(true)
	
	local Connections = {}
	
	BloodRage.PowerValues.PowerRemote:FireServer("Input", true)
end

function Action:Stop(...) : "Stop Action?"
	--if not Action.ActionInfo.Disconnect or Action.Debounces.Exiting then return warn('Anti-Spam Exit') end -- if we don't have disconnect do not trigger
	Action.Debounces.Exiting = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	
	local Character = Player.Character
	local BloodRage = Character.BloodRage
	
	BloodRage.PowerValues.PowerRemote:FireServer("Input", false)

	Action.Debounces.Exiting = false
	Action.Debounces.Deploying = false
	Action.Priority = DefaultPriority
	modules.UI:Hide(false)
	
end

function Action:Process(...) : boolean | "Returns true if this action can be ran"
	local args = {...}
	local actionList, remoteList = args[1], args[2]

	if Constraints(actionList) then
		return true
	end

	return false
end

function updateAttributes(actionList)
	
	local Character = Player.Character
	local BloodRage = Character.BloodRage
	
	Action.Power = {
		["State"] = BloodRage:GetAttribute("State"),
		["Progress"] = BloodRage:GetAttribute("Progress")
	}

end

return Action
