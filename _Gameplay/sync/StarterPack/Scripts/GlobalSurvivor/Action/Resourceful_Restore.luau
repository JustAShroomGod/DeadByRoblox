local Player = game.Players.LocalPlayer
local Defaults = 5;

local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Resourceful'))

local Range = 4.2

local Action = {
	Key = "Interact4";
	ActionName = "RESTORE (RESOURCEFUL)";
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		Ports = {
			Close = nil;
			Far = nil;
		},
	},
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
	if not Pallet then return false end
	
	local HasPerk, PerkTier = modules.Data:GetPerk("Resourceful")
	local charges = Player.Character:GetAttribute("Resourceful")
	if not charges or not HasPerk then return false end
	
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
		and not actionList.MovementScript.Shift.Value
		and (HasPerk and tonumber(charges) >= Perk_Module.Tiers[PerkTier])
		and (actionList.Pallet and Player:DistanceFromCharacter(Port1.Position) <= Range)
		and actionList.Pallet.Panel.State.Value == 2
		and Player.Character.Humanoid.MoveDirection.magnitude == 0 then
		Action.ActionInfo.Ports = {
			Close = Port1;
			Far = Port2;
		}
		
		CanRun = true
	elseif Action.Debounces.Active then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	else
		Action.ActionInfo.Ports = {
			Close = nil;
			Far = nil;
		}
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
	local palletPorts = Action.ActionInfo.Ports
	local Character = Player.Character
	
	modules.UI:Hide(true)
	
	remoteList.Perk:FireServer("Resourceful", false, actionList.Pallet, palletPorts.Close) -- de-activate our perk
	
	local fs = workspace:GetServerTimeNow()
	
	repeat task.wait()
	until (currentValues.Action.Value == 'Restore' or (workspace:GetServerTimeNow() - fs) >= 3) -- wait for shoving to take effect
	
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
