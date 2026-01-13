local Player = game.Players.LocalPlayer
local Defaults = 3;

local Action = {
	Key = "Interact";
	ActionName = "CRUSH TOTEM";
	InteractDistance = 6;
	Priority = 1; -- scale of 1-5
	ActionInfo = {
		Totem = nil;
		Disconnect = nil;
	},
	Debounces = {
		InProgress = false;
		InputEnter = tick();
		InputExit = tick();
	}
}

local Track = nil

function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Totem : Model = actionList.Totem

	if not Totem then return false end
	
	if (Totem:WaitForChild("Root").Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance -- Distance Check
		and currentValues.Action.Value == "Nothing"
		and currentValues:WaitForChild('KillerAction').Value == 'Nothing' 
		and KillerConstraints(modules)
		and Totem:WaitForChild('Panel').Effect.Value == "Blessing" -- is a blessing
		and not Player.Character:GetAttribute("Carry") -- no carry attribute set so not carrying a person
		and Totem:WaitForChild('Panel').State.Value == 0 -- still up
		and Totem:WaitForChild('Panel').Player.Value == "" then -- only dull totems
		
		Action.ActionInfo.Totem = Totem
		CanRun = true
	elseif Action.Debounces.InProgress then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	else
		Action.ActionInfo.Totem = nil
	end

	return CanRun
end

function KillerConstraints(modules)

	if (modules.Data:GetCharacter() == "Psychopath") then
		return not (Player.Character.BloodRage:GetAttribute("State") == 2)
	end

	if (modules.Data:GetCharacter() == "Nurse") then
		return not (Player.Character:WaitForChild("Blink"):GetAttribute("BlinkAttack") or Player.Character:WaitForChild("Blink"):GetAttribute("State") > 0)
	end

	return true
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or not Action.ActionInfo.Totem or Action.Debounces.InProgress then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true
	
	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	
	modules.UI:Hide(true)
	
	if not Track then
		Track = Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(script:WaitForChild('Animation'))
	end
	
	Character.Humanoid.WalkSpeed = 0
	
	Track:Play()
	remoteList.Server:FireServer("Totem", 'Crush', Action.ActionInfo.Totem)

	Track.Stopped:Wait()

	Character.Humanoid.WalkSpeed = modules.Code:GetPlayerValue(Player, "Speed") * modules.Code:GetPlayerValue(Player, "SpeedMultiplier")
	
	Action.Debounces.InProgress = false
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
