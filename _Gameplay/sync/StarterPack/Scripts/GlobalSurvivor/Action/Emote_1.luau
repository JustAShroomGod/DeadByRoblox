local RunService = game:GetService("RunService")

local Game_Assets = game.ReplicatedStorage:WaitForChild('Game_Assets')

local Player = game.Players.LocalPlayer
local Defaults = 1;

local Action = {
	Key = "Interact6";
	ActionName = "#Emote_One";
	Priority = 1; -- scale of 1-5
	Debounces = {
		Emoting = false;
		InputEnter = tick();
		InputExit = tick();
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local State = Player.Character.Humanoid:GetState()

	local Hiding_Spot : Model = actionList.Hiding_Spot
	local Vault : Model = actionList.Vault
	local Pallet : Model = actionList.Pallet
	
	if currentValues.HealthState.Value > 0
		and currentValues.Action.Value == "Nothing"
		and not currentValues.Hooked.Value
		and not currentValues.Holded.Value
		and State ~= Enum.HumanoidStateType.Freefall
		and Player.Character:GetAttribute("IntroDone") then

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
		
		CanRun = true
	elseif Action.Debounces.Emoting then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or Action.Debounces.Emoting then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Emoting = true
	
	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	
	obfuscate("String", currentValues.Action, "Emoting")
	
	actionList.MovementScript.MainScript.Disabled = true
	Character.PrimaryPart.Anchored = true
	
	local emoteTrack = Character.Humanoid:LoadAnimation(Game_Assets:WaitForChild('Animations'):WaitForChild('Emotes'):WaitForChild(actionList.Data_Storage_Clone.Loadout.Emotes.One))
	emoteTrack:Play()
	
	local Connections = {}
	
	local function disconnect()
		if emoteTrack then emoteTrack:Stop() emoteTrack = nil end

		actionList.MovementScript.MainScript.Disabled = false
		Character.PrimaryPart.Anchored = false
		
		obfuscate("String", currentValues.Action, "Nothing")
		
		if Connections.Action then Connections.Action:Disconnect() end
		if Connections.TrackEnded then Connections.TrackEnded:Disconnect() end
		if Connections.Action then Connections.Action:Disconnect() end
		if Connections.Sprint then Connections.Sprint:Disconnect() end

		Action.Debounces.Emoting = false
		Action.Priority = Defaults
	end
	
	Connections.Hit = Character:GetAttributeChangedSignal("LastHit"):Connect(function(test)
		disconnect()
	end)
	
	Connections.TrackEnded = emoteTrack.Stopped:Connect(function()
		disconnect()
	end)
	
	Connections.Action = currentValues.Action.Changed:Connect(function()
		if not (currentValues.Action.Value == "Emoting") then
			disconnect()
		end
	end)
	
	script.Parent.Parent.Parent.values.HealthState.Changed:Connect(function()
		disconnect()
	end)
	
	Connections.Sprint = actionList.MovementScript.Shift.Changed:Connect(function()
		disconnect()
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
