local Player = game.Players.LocalPlayer
local Defaults = 5;

local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Resourceful'))

local Range = 5

local Action = {
	Key = "Interact4";
	ActionName = "GRAB PART (RESOURCEFUL)";
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
	local Pallet : Model = actionList.Pallet
	
	local HasPerk, PerkTier = modules.Data:GetPerk("Resourceful")
	
	if HasPerk and not Player.Character:GetAttribute("Resourceful") then
		Player.Character:SetAttribute("Resourceful", 0) -- set a place holder
	end

	if not Pallet then return false end
	local Charges = Player.Character:GetAttribute("Resourceful")
	local Port1, Port2 = nil, nil

	if (Pallet:WaitForChild('FirstPort').Position - Player.Character:GetPivot().Position).Magnitude > (Pallet:WaitForChild('SecondPort').Position - Player.Character:GetPivot().Position).Magnitude then
		Port1, Port2 = Pallet:WaitForChild('SecondPort'), Pallet:WaitForChild('FirstPort')
	else
		Port1, Port2 = Pallet:WaitForChild('FirstPort'), Pallet:WaitForChild('SecondPort')
	end
	
	if currentValues.HealthState.Value > 0
		and currentValues.Action.Value == "Nothing"
		and not currentValues.Hooked.Value
		and not currentValues.Holded.Value
		and (HasPerk and Charges < Perk_Module.Tiers[PerkTier])
		and (Pallet and Player:DistanceFromCharacter(Port1.Position) <= Range) 
		and Pallet.Panel.State.Value == 2 and not Pallet:GetAttribute("Resource") then

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
	local Charges = Player.Character:GetAttribute("Resourceful")

	modules.UI:Hide(true)

	remoteList.Perk:FireServer("Resourceful", true, actionList.Pallet) -- de-activate our perk
	
	local fs = workspace:GetServerTimeNow()

	repeat task.wait()
	until (actionList.Pallet:GetAttribute("Resource") or (workspace:GetServerTimeNow() - fs) >= 3) -- wait for pallet to be taken to take effect

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
