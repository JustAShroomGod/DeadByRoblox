local Player = game.Players.LocalPlayer
local Defaults = 2;

local Action = {
	Key = "Interact4";
	ActionName = "BLESS TOTEM";
	InteractDistance = 4;
	Priority = 2; -- scale of 1-5
	ActionInfo = {
		BlessData = nil;
		Totem = nil;
		Disconnect = nil;
	},
	Debounces = {
		InProgress = false;
		InputEnter = tick();
		InputExit = tick();
	}
}

function GetDictAmount(dict)
	local i = 0

	for _, _ in pairs(dict) do
		i += 1
	end

	return i
end

local Types = {}

function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Totem : Model = actionList.Totem

	if not Totem then return false end

	if not Action.ActionInfo.BlessData then
		Action.ActionInfo.BlessData = modules.Data:GetBlessings()
	end

	if actionList.Blessing and actionList.Blessing:WaitForChild('Panel').State.Value == 1 then
		actionList.Blessing = nil
	end

	if (Totem:WaitForChild("Root").Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance -- Distance Check
		and currentValues.HealthState.Value > 0
		and currentValues.Action.Value == "Nothing"
		--and not actionList.Blessing -- no totem blessed in our name!
		and GetDictAmount(Action.ActionInfo.BlessData) > 0 -- has blessing to use
		and Totem:WaitForChild('Panel').State.Value == 0 -- still up
		and Totem:WaitForChild('Panel').Player.Value == "" -- no player on it
		and Totem:WaitForChild('Panel').Effect.Value == "Dull" then -- only dull totems

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

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or not Action.ActionInfo.Totem or Action.Debounces.InProgress then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	if Player.Character:GetAttribute("Perk_Defense_Time") then
		remoteList.Perk:FireServer("Self Defense", false) -- de-activate our perk
	end

	local has, tier = modules.Data:GetPerk("Blessing: Fresh Air")
	local has2, tier = modules.Data:GetPerk("Blessing: Healing Aid")
	local has3, tier = modules.Data:GetPerk("Blessing: In The Shadows")

	local Types = {}

	if has then
		table.insert(Types, "FreshAir")
	end
	if has2 then
		table.insert(Types, "HealingAid")
	end
	if has3 then
		table.insert(Types, "InTheShadows")
	end

	actionList.Blessing = Action.ActionInfo.Totem
	remoteList.Server:FireServer("Totem", 'Bless', Action.ActionInfo.Totem)

	game.ReplicatedStorage["-LockerAuras"]['Boon_Handler']:FireServer(Action.ActionInfo.Totem, Types, "Connect")

	Action.Debounces.InProgress = false
	Action.Priority = Defaults
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
