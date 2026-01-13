local Teams = game:GetService("Teams")

local Player = game.Players.LocalPlayer
local Defaults = 5;

local Perk_Module = require(game:GetService("ReplicatedStorage"):WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Tic Tac'))

local Action = {
	Key = "Interact4";
	ActionName = "STUN KILLER (TIC TAC)";
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
	local Tic_Attribute = game.Players.LocalPlayer.Character:GetAttribute("Tic_Tac")
	local HasPerk, PerkTier = modules.Data:GetPerk("Tic Tac")
	
	if not Tic_Attribute then return false end
	Tic_Attribute = string.split(Tic_Attribute, ':')
	
	if not (Player.Team == Teams.Survivor) then return end
	
	if currentValues.Action.Value == "Nothing"
		and currentValues.Hooked.Value
		and not currentValues.Holded.Value
		and tonumber(Tic_Attribute[2]) >= tonumber(Tic_Attribute[1])
		and HasPerk -- has to have dead hard
		and actionList.KillerPlayer  -- killer does exist
		and Player:DistanceFromCharacter(actionList.KillerPlayer.Character:GetPivot().Position) <= Perk_Module.Radius then
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
	
	remoteList.Perk:FireServer("Tic Tac")
	
	local fs = workspace:GetServerTimeNow()
	
	repeat task.wait()
	until (currentValues.Action.Value == 'Throwing' or (workspace:GetServerTimeNow() - fs) >= 3) -- wait for shoving to take effect
	
	repeat task.wait()
	until currentValues.Action.Value == 'Nothing'
	
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
