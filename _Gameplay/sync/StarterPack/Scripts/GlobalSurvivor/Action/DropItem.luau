local Player = game.Players.LocalPlayer
local Defaults = 5;

local Action = {
	Key = "Interact5";
	ActionName = "#DROP ITEM";
	Priority = 5; -- scale of 1-5
	ActionInfo = {
		Item = nil;
	},
	Debounces = {
		Dropping = false;
		InputEnter = tick();
		InputExit = tick();
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local CurrentItem = actionList.CharacterItem
	local State = Player.Character.Humanoid:GetState()
	local Hiding_Spot : Model = actionList.Hiding_Spot
	local Vault : Model = actionList.Vault
	local Pallet : Model = actionList.Pallet
	
	if Hiding_Spot then
		if (Hiding_Spot:WaitForChild('Prompt').Position - Player.Character:GetPivot().Position).Magnitude <= 9 then
			return	
		end
	end
	
	if Vault then
		local Front = Vault:WaitForChild("FrontPort")
		local Back = Vault:WaitForChild('BackPort')
		
		if (Front.Position - Player.Character:GetPivot().Position).Magnitude <= 7 then
			return	
		end
		
		if (Back.Position - Player.Character:GetPivot().Position).Magnitude <= 7 then
			return	
		end
	end
	
	if Pallet then
		local Front = Pallet:WaitForChild("FirstPort")
		local Back = Pallet:WaitForChild('SecondPort')

		if (Front.Position - Player.Character:GetPivot().Position).Magnitude <= 7 then
			return	
		end

		if (Back.Position - Player.Character:GetPivot().Position).Magnitude <= 7 then
			return	
		end
	end
	
	if currentValues.HealthState.Value > 0
		and currentValues.Action.Value == "Nothing"
		and not currentValues.Hooked.Value
		and not currentValues.Holded.Value
		and not currentValues.Vaulting.Value
		and CurrentItem
		and State ~= Enum.HumanoidStateType.Freefall then
		
		Action.ActionInfo.Item = CurrentItem
		CanRun = true
	elseif Action.Debounces.Dropping then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	else
		Action.ActionInfo.Item = nil
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 2 or Action.Debounces.Dropping or not Action.ActionInfo.Item then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Dropping = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	
	modules.UI:Hide(true)
	actionList.MovementScript.MainScript.Disabled = true
	Character.Humanoid.WalkSpeed = 0

	remoteList.Item:FireServer("DROP", Action.ActionInfo.Item)
	
	local Connections = {}
	
	local function disconnect()
		actionList.MovementScript.MainScript.Disabled = false
		
		if Connections.Action then Connections.Action:Disconnect() end
		
		Action.Debounces.Dropping = false
		Action.Priority = Defaults
		modules.UI:Hide(false)
	end
	
	Connections.Action = currentValues.Action.Changed:Connect(function()
		if currentValues.Action.Value == "Nothing" then
			disconnect()
		end
	end)
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
