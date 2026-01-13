local Player = game.Players.LocalPlayer
local Defaults = 5;

local shoveRange = 5

local Action = {
	Key = "Interact10";
	ActionName = "TOGGLE CLOAK";
	Priority = 4; -- scale of 1-5
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
	
	local HasPerk, PerkTier = modules.Data:GetPerk("ExperimentalTech")
	local Perk = Player:WaitForChild("Backpack"):WaitForChild("Scripts").PerksBase.ExperimentalTech
	local HasEffect = modules.Code:GetEffect("Cloaked", Player)
	
	local Cooldown = Perk:GetAttribute("Cooldown")
	local MaxCooldown = Perk:GetAttribute("MaxCooldown")
	
	if currentValues.Action.Value == "Nothing"
		and not currentValues.Hooked.Value
		and not currentValues.Holded.Value
		and Cooldown >= MaxCooldown
		and HasPerk 
		and not HasEffect 
		and not Player.Character:GetAttribute("Chased")
		and not modules.Code:IsExhausted(Player)
		and currentValues.HealthState.Value > 0 then
		
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
	
	local Cloaked = Character:GetAttribute("Cloaked_ExperimentalTech") ~= nil
	remoteList.Perk:FireServer("ExperimentalTech", not Cloaked)
	
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
