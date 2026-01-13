local Player = game.Players.LocalPlayer
local Defaults = 1;

local Action = {
	Key = "Interact2";
	ActionName = "SNAP OUT OF IT";
	Priority = 1; -- scale of 1-5
	ActionInfo = {
		Gate = nil;
		Disconnect = nil;
	},
	Debounces = {
		Snapping = false;
		InputEnter = tick();
		InputExit = tick();
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	
	if 1 == 1 then
		return
	end
	
	if currentValues.HealthState.Value > 0
		and currentValues.Action.Value == "Nothing"
		and not currentValues.Hooked.Value
		and not currentValues.Holded.Value
		--and currentValues.MadnessTier.Value >= 3
		and (Player.Character.Humanoid.MoveDirection.magnitude == 0) then
		
		CanRun = true
	elseif Action.Debounces.Snapping then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or Action.Debounces.Snapping then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Snapping = true
	
	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	
	modules.UI:Hide(true)
	actionList.MovementScript.MainScript.Disabled = true
	Character.Humanoid.WalkSpeed = 0
	Character.PrimaryPart.Anchored = true
	
	--script.Parent.Parent:WaitForChild('Madness').LocalScript.Value.Value = true
	
	obfuscate("Bool", currentValues.Crouching, false)
	obfuscate("String", currentValues.Action, "SnappingOut")
	
	local TrackA, TrackB = Character.Humanoid:LoadAnimation(script:WaitForChild('Animation1')), Character.Humanoid:LoadAnimation(script:WaitForChild('Animation2'))
	TrackA:Play()
	TrackB:Play()
	
	local Connections = {}
	
	local function disconnect()
		if TrackA then TrackA:Stop() TrackA = nil end
		if TrackB then TrackB:Stop() TrackB = nil end
		
		obfuscate("String", currentValues.Action, "Nothing")
		--script.Parent.Parent:WaitForChild('Madness').LocalScript.Value.Value = false
		
		Character.PrimaryPart.Anchored = false
		actionList.MovementScript.MainScript.Disabled = false
		
		if Connections.Hit then Connections.Hit:Disconnect() end
		if Connections.Progress then Connections.Progress:Disconnect() end
		
		Action.Debounces.Snapping = false
		Action.Priority = Defaults
		modules.UI:Hide(false)
	end
	
	Connections.Hit = Character:GetAttributeChangedSignal("LastHit"):Connect(function(test)
		disconnect()
	end)
	
	--[[Connections.Progress = script.Parent.Parent:WaitForChild('Madness').Changed:Connect(function()
		if script.Parent.Parent:WaitForChild('Madness').Value >= 100 then
			--obfuscate("Number", currentValues.MadnessTier, 1)
			script.Parent.Parent:WaitForChild('Madness').Value = 0
			disconnect()
		end
	end)]]
	
	Action.ActionInfo.Disconnect = disconnect
end

function Action:Stop(...)
	if (tick() - Action.Debounces.InputExit) < 1.5 or not Action.ActionInfo.Disconnect then return warn('Anti-Spam exit') end
	Action.Debounces.InputExit = tick()

	local args = {...}

	Action.ActionInfo.Disconnect()
	Action.ActionInfo.Disconnect = nil
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
