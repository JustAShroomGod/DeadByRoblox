local Player = game.Players.LocalPlayer
local FakeTrap = game:GetService('ReplicatedStorage'):WaitForChild('KillerStuff'):WaitForChild('HoverBearTrap')

local DefaultPriority = 3

local Action = {
	Key = "Interact3";
	ActionName = "Place Trap";
	Priority = 3; -- scale of 1-5
	InteractDistance = 10; -- how far apart traps must be from objectives and each other
	ActionInfo = {},
	Debounces = {
		InputEnter = tick();
		Deploying = false;
		Exiting = false;
	}
}

local RayParms = RaycastParams.new()
RayParms.FilterDescendantsInstances = {workspace.CurrentCamera}
RayParms.FilterType = Enum.RaycastFilterType.Exclude

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Trap : Model = actionList.KillerInteractable.Trap
	local Hook : Model = actionList.Hook
	local Generator : Model = actionList.Generator
	local Hiding_Spot : Model = actionList.Hiding_Spot
	local TrapAmount = game.Players.LocalPlayer.Character:GetAttribute("Traps")
	
	if not Trap or not TrapAmount or not Hook or not Generator or not Hiding_Spot then return false end
	TrapAmount = string.split(TrapAmount, ':')
	TrapAmount = TrapAmount[1]
	
	if not actionList.KillerInfo then
		actionList.KillerInfo = {}
	end
	
	if not actionList.KillerInfo.FakeTrap then
		actionList.KillerInfo.FakeTrap = FakeTrap:Clone()
	end
	
	if (Trap:GetPivot().Position - Player.Character:GetPivot().Position).Magnitude >= Action.InteractDistance -- Distance Check
		and (Hook:GetPivot().Position - Player.Character:GetPivot().Position).Magnitude >= Action.InteractDistance + 2
		and (Generator:GetPivot().Position - Player.Character:GetPivot().Position).Magnitude >= Action.InteractDistance
		and (Hiding_Spot:GetPivot().Position - Player.Character:GetPivot().Position).Magnitude >= Action.InteractDistance
		and tonumber(TrapAmount) > 0
		and not Player.Character:GetAttribute("Carry") -- not allowed while carrying
		and (currentValues.Parent:WaitForChild("BLOODPOINT"):FindFirstChild("REMOVE") ~= nil)
		and currentValues.KillerAction.Value == "Nothing" then

		if Player.Character.Humanoid.MoveDirection == Vector3.zero then
			local Origin, Goal = Player.Character:GetPivot() * CFrame.new(0, -4, 0), Player.Character:GetPivot() * CFrame.new(0, -4, -2.4)
			local Cast = workspace:Raycast(Origin.Position, (Goal.Position - Origin.Position).Unit * (Goal.Position - Origin.Position).Magnitude, RayParms)

			if Cast then
				actionList.KillerInfo.FakeTrap:PivotTo(Player.Character:GetPivot() * CFrame.new(0, -4, -Cast.Distance + 1.15))
			else
				actionList.KillerInfo.FakeTrap:PivotTo(Goal)
			end

			actionList.KillerInfo.FakeTrap.Parent = workspace.Camera
		else
			actionList.KillerInfo.FakeTrap.Parent = nil
		end
		
		Action.ActionInfo.Trap = Trap
		CanRun = true
	elseif Action.Debounces.Deploying then -- if in progress do not let go of this interaction
		
		actionList.KillerInfo.FakeTrap.Parent = nil
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	else
		
		actionList.KillerInfo.FakeTrap.Parent = nil
		Action.ActionInfo.Trap = nil
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1 or Action.Debounces.Deploying then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Deploying = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	modules.UI:Hide(true)
	
	actionList.PreventHeadTilt = true
	modules.Camera.Camera.HeadLocked = true

	Character.Humanoid.AutoRotate = false

	local Connections = {}
	
	remoteList.Server:FireServer("Trap", "Place", true, actionList.KillerInfo.FakeTrap:GetPivot())
	
	local function Disconnect(reason)
		if Action.ActionInfo.Disconnect then Action.ActionInfo.Disconnect = nil end
		if Connections.Change then Connections.Change:Disconnect() Connections.Change = nil end
		
		remoteList.Server:FireServer("Trap", "Place", false)
		
		repeat task.wait()
		until currentValues.KillerAction.Value == "Nothing"

		modules.Camera.Camera.HeadLocked = false
		Character.Humanoid.AutoRotate = false

		Action.Debounces.Exiting = false
		Action.Debounces.Deploying = false
		Action.Priority = DefaultPriority
		modules.UI:Hide(false)
	end
	
	Connections.Change = currentValues.KillerAction.Changed:Connect(function()
		
		if currentValues.KillerAction.Value == "Nothing" then
			Disconnect("Action")
		end
	end)
	
	Action.ActionInfo.Disconnect = Disconnect
end

function Action:Stop(...)
	if not Action.ActionInfo.Disconnect or Action.Debounces.Exiting then return warn('Anti-Spam Exit') end
	Action.Debounces.Exiting = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	
	if currentValues.KillerAction.Value ~= "Trapping" then
		repeat task.wait()
		until currentValues.KillerAction.Value == "Trapping"
	end
	
	Action.ActionInfo.Disconnect("Mouse")
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
