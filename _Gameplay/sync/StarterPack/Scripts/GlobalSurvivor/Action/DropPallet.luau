local Player = game.Players.LocalPlayer

local Action = {
	Key = "Interact";
	ActionName = "DROP PALLET";
	InteractDistance = 4.5;
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

	if not Pallet then return false end

	local palletSettings = Pallet:WaitForChild('Panel')
	local Port1, Port2 = nil, nil

	if (Pallet:WaitForChild('FirstPort').Position - Player.Character:GetPivot().Position).Magnitude > (Pallet:WaitForChild('SecondPort').Position - Player.Character:GetPivot().Position).Magnitude then
		Port1, Port2 = Pallet:WaitForChild('SecondPort'), Pallet:WaitForChild('FirstPort')
	else
		Port1, Port2 = Pallet:WaitForChild('FirstPort'), Pallet:WaitForChild('SecondPort')
	end

	if palletSettings:WaitForChild('Vaulter').Value == ""
		and palletSettings:WaitForChild('Dropper').Value == ""
		and palletSettings:WaitForChild('State').Value == 0
		and (Port1.Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance
		and not currentValues.Holded.Value
		and not currentValues.Hooked.Value
		and Player.Character.HumanoidRootPart.Anchored == false
		and currentValues.HealthState.Value > 0
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
	if (tick() - Action.Debounces.InputEnter) < .25 or Action.Debounces.InProgress or not Action.ActionInfo.Ports.Close or not Action.ActionInfo.Settings then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local palletPorts, Pallet = Action.ActionInfo.Ports, Action.ActionInfo.Pallet
	local palletSettings = Action.ActionInfo.Settings

	local Character = Player.Character

	modules.UI:Hide(true)

	if Character.Humanoid.MoveDirection.Magnitude == 0 then -- we are not moving default to closest port
		remoteList.Pallet:FireServer(Pallet, palletPorts.Close, "Drop")
	else
		local Direction = CFrame.new(Character:GetPivot().Position, palletPorts.Far.Position).LookVector
		local Difference = (Direction - Character:GetPivot().LookVector).Magnitude

		local D = (Character:GetPivot().Position - palletPorts.Far.Position).Magnitude

		--warn("DIFFRENCE: " .. D)
		if actionList.MovementScript.Shift.Value and D <= 5 and Difference <= .5 then -- if we are running, looking in the right direction, and close enough to far one then pallet vacuum
			remoteList.Pallet:FireServer(Pallet, palletPorts.Far, "Drop")
		else -- deny pallet vacuum and drop
			remoteList.Pallet:FireServer(Pallet, palletPorts.Close, "Drop")
		end
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