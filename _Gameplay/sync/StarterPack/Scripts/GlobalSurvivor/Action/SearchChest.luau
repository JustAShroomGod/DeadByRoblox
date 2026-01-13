local TweenService = game:GetService('TweenService')
local Player = game.Players.LocalPlayer
local Defaults = 3;

local Action = {
	Key = "Interact2";
	ActionName = "SEARCH CHEST";
	InteractDistance = 3.2;
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		Chest = nil;
		Disconnect = nil;
	},
	Debounces = {
		InProgress = false;
		InputEnter = tick();
		InputExit = tick();
	}
}

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Chest : Model = actionList.Chest

	if not Chest then return false end
	
	if (Chest:WaitForChild("Pos").Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance -- Distance Check
		and currentValues.HealthState.Value > 0
		and currentValues.Action.Value == "Nothing"
		and Chest:WaitForChild('Panel').State.Value == "Closed"
		and Chest:WaitForChild('Panel').Progress.Value < 1000 then

		Action.ActionInfo.Chest = Chest
		CanRun = true
	elseif Action.Debounces.InProgress then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	else
		Action.ActionInfo.Chest = nil
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or not Action.ActionInfo.Chest or Action.Debounces.InProgress then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true
	
	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	local chest = Action.ActionInfo.Chest
	
	chest.Collision.CanCollide = false
	
	modules.UI:Hide(true)
	
	local Tween = TweenService:Create(Character.PrimaryPart, TweenInfo.new(1/10), {
		CFrame = chest.Pos.CFrame
	})
	
	modules.UI:Progress(chest.Panel.Progress, "SEARCHING", "ActionSpeed", modules.Code.BaseValues.Survivor.Action.ActionSpeed)
	
	Tween:Play()
	Tween.Completed:Wait()
	
	Character.PrimaryPart.Anchored = true
	actionList.MovementScript.Disabled = true
	Character.Humanoid.WalkSpeed = 0
	
	obfuscate("String", currentValues.Action, "ChestSearch")
	obfuscate("String", chest.Panel.Using, Player.Name)
	obfuscate("String", chest.Panel.State, "Opening")
	
	local ChestAnimation = Character.Humanoid:LoadAnimation(script:WaitForChild('Animation'))
	ChestAnimation:Play()
	
	local Connections = {}
	
	local function disconnect()
		actionList.MovementScript.Disabled = false
		Character.PrimaryPart.Anchored = false
		
		obfuscate("String", currentValues.Action, "Nothing")
		obfuscate("String", chest.Panel.Using, "")
		
		if ChestAnimation then ChestAnimation:Stop() ChestAnimation = nil end
		if Connections.Progress then Connections.Progress:Disconnect() end
		if Connections.Hit then Connections.Hit:Disconnect() end
		if Connections.Action then Connections.Action:Disconnect() end

		Action.Debounces.InProgress = false
		Action.Priority = Defaults
		modules.UI:Hide(false)
		modules.UI:Progress()
		
		task.delay(0.05, function()
			chest.Collision.CanCollide = true
		end)
	end
	
	Connections.Progress = chest.Panel.Progress.Changed:Connect(function()
		Character:PivotTo(chest.Pos.CFrame)
		
		if chest.Panel.Progress.Value >= 1000 then
			remoteList.Info:FireServer('Boldness', 1000, 'CHEST SEARCHED')
			disconnect()
		end
	end)

	Connections.Hit = Character:GetAttributeChangedSignal("LastHit"):Connect(function(test)
		disconnect()
	end)
	
	Connections.Action = currentValues.Action.Changed:Connect(function()
		if not (currentValues.Action.Value == "ChestSearch") then
			disconnect() 
		end
	end)	
	
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
	local actionList, remoteList = args[1], args[2]

	if Constraints(actionList) then
		return true
	end

	return false
end

return Action
