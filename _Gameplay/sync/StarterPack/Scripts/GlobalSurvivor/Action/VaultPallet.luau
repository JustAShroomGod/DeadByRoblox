local Player = game.Players.LocalPlayer
remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")

local Action = {
	Key = "Interact";
	ActionName = "VAULT PALLET";
	InteractDistance = 3; -- was 4.2 before
	Priority = 2; -- scale of 1-5
	ActionInfo = {
		Settings = nil;
		Pallet = nil;
		Ports = {
			Close = nil;
			Far = nil;
		};
	},
	Debounces = {
		InProgress = false;
		InputEnter = tick();
	},
}

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Pallet : Model = actionList.Pallet
	local Trap : Model = actionList.KillerInteractable.Trap

	if not Pallet then return false end

	local palletSettings = Pallet:WaitForChild('Panel')
	local Port1, Port2 = nil, nil

	if (Pallet:WaitForChild('FirstPort').Position - Player.Character:GetPivot().Position).Magnitude > (Pallet:WaitForChild('SecondPort').Position - Player.Character:GetPivot().Position).Magnitude then
		Port1, Port2 = Pallet:WaitForChild('SecondPort'), Pallet:WaitForChild('FirstPort')
	else
		Port1, Port2 = Pallet:WaitForChild('FirstPort'), Pallet:WaitForChild('SecondPort')
	end

	if palletSettings:WaitForChild('Vaulter').Value == ""
		and (palletSettings:WaitForChild('Dropper').Value == "" or palletSettings:WaitForChild('Dropper').Value == Player.Name) -- if nobody is dropping or we are the ones who dropped it we gain pallet priority
		and palletSettings:WaitForChild('State').Value == 1
		and (Port1.Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance
		and (not Trap or (Trap and (Trap:WaitForChild('Panel').State.Value ~= "Armed" or (Port1.Position - Trap:WaitForChild('HumanoidRootPart').Position).Magnitude > 4.8)))
		and not currentValues.Holded.Value
		and not currentValues.Hooked.Value
		and currentValues.HealthState.Value > 0
		and Player.Character.HumanoidRootPart.Anchored == false
		and currentValues.Action.Value == 'Nothing' then

		Action.ActionInfo.Settings = palletSettings
		Action.ActionInfo.Pallet = Pallet
		Action.ActionInfo.Ports = {
			Close = Port1;
			Far = Port2;
		}

		CanRun = true
	else
		Action.ActionInfo.Settings = nil
		Action.ActionInfo.Pallet = nil
		Action.ActionInfo.Ports = {
			Close = nil;
			Far = nil;
		};
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.25 or Action.Debounces.InProgress or not Action.ActionInfo.Ports.Close or not Action.ActionInfo.Settings then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local palletPorts, Pallet = Action.ActionInfo.Ports, Action.ActionInfo.Pallet
	local palletSettings = Action.ActionInfo.Settings
	local HasLithe, LitheTier = modules.Data:GetPerk("Lithe")

	local Character = Player.Character

	modules.UI:Hide(true)

	remoteList.Pallet:FireServer(Pallet, palletPorts.Close, "Vault", actionList.MovementScript.Shift.Value)
	remoteEvents.EventRemotes.ActionEvent:FireServer("Survivor_Vault", "Pallet")

	if not modules.Code:IsExhausted()
		and actionList.MovementScript.Shift.Value and HasLithe then

		remoteList.Perk:FireServer("VaultNGo")
	end

	repeat task.wait(.2)
	until currentValues.Action.Value == "Nothing"

	modules.UI:Hide(false)
	Action.Debounces.InProgress = false
end

function Action:Process(...) : boolean | "Returns true if this action can be ran"
	local args = {...}
	local actionList, remoteList = args[1], args[2]

	if Constraints(actionList) then
		return true
	end

	return false
end

return Action