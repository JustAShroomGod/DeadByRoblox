local Player = game.Players.LocalPlayer
local DefaultPriority = 3

local Action = {
	Key = "Interact3";
	ActionName = "Stalk";
	Priority = 3; -- scale of 1-5
	ActionInfo = {},
	Debounces = {
		InputEnter = tick();
		Deploying = false;
		Exiting = false;
	}
}

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList

	local Power = Player.Character:GetAttribute("Power_Progress")
	local Power_Tier = Player.Character:GetAttribute("Power_Tier")
	local Power_State = Player.Character:GetAttribute("Power_State")

	local LastSwing = (Player.Character:GetAttribute("SwingEnd") or 0)

	if not Power_Tier or not Power or not Power_State then return false end
	Power = string.split(Power, ':')

	if currentValues.KillerAction.Value == "Nothing"
		and not Player.Character:GetAttribute("Swing")
		and (currentValues.Parent:WaitForChild("BLOODPOINT"):FindFirstChild("REMOVE") ~= nil)
		and not currentValues.Stunned.Value
		and not Player.Character:GetAttribute("Carry")
		and Power_Tier < 3
		and tonumber(Power[1]) < tonumber(Power[2]) then

		CanRun = true
	elseif Action.Debounces.Deploying then -- if in progress do not let go of this interaction

		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
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

	local Connections = {}

	-- Let Server Know we want to Stalk --
	remoteList.Server:FireServer("Stalk", true)
	script:WaitForChild('Stalking'):Play() -- Play local stalking sound


	local function Disconnect()
		if Action.ActionInfo.Disconnect then Action.ActionInfo.Disconnect = nil end
		if Connections.Evil then Connections.Evil:Disconnect() Connections.Evil = nil end
		if Connections.Change then Connections.Change:Disconnect() Connections.Change = nil end
		if Connections.Stunned then Connections.Stunned:Disconnect() Connections.Stunned = nil end

		-- Let Server Know we want to stop stalking
		remoteList.Server:FireServer("Stalk", false)
		script:WaitForChild('Stalking'):Stop()

		repeat task.wait()
		until currentValues.KillerAction.Value == "Nothing"


		Action.Debounces.Exiting = false
		Action.Debounces.Deploying = false
		Action.Priority = DefaultPriority
		modules.UI:Hide(false)
	end

	Connections.Change = currentValues.KillerAction.Changed:Connect(function()

		if currentValues.KillerAction.Value == "Nothing" then
			Disconnect()
		end
	end)

	-- if we get stunned disconnect us
	Connections.Stunned = currentValues.KillerAction.Changed:Connect(function()

		if currentValues.KillerAction.Value == 'Stun' then
			Disconnect()
		end
	end)

	-- if we reach t3 disconnect us
	Connections.Evil = Player.Character:GetAttributeChangedSignal("Power_Tier"):Connect(function()

		if Player.Character:GetAttribute("Power_Tier") >= 3 then
			Disconnect()
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

	if currentValues.KillerAction.Value ~= "Stalking" then
		repeat task.wait()
		until currentValues.KillerAction.Value == "Stalking"
	end

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
