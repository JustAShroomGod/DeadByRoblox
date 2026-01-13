local Player = game.Players.LocalPlayer

local DefaultPriority = 3

local Action = {
	Key = "Interact3";
	ActionName = "Uncloak";
	Priority = 3; -- scale of 1-5
	ActionInfo = {},
	Debounces = {
		InputEnter = tick();
		Deploying = false;
		Exiting = false;
	}
}

local V = false
local mods = {UI = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Gui"))}

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList

	if not actionList.KillerInfo then
		local rawBell = Player.Character:WaitForChild('Bell')

		actionList.KillerInfo = {
			LastSwing = (Player.Character:GetAttribute("SwingEnd") or 0);
			Bell = rawBell;
		}
	end
	mods.UI:ChangeName(Action.ActionName, if Player.Character:GetAttribute("Cloaked") then "Uncloak" else "Cloak")
	if currentValues.KillerAction.Value == "Nothing"
		and not Player.Character:GetAttribute("Carry")
		and not Player.Character:GetAttribute("Swing")
		and (currentValues.Parent:WaitForChild("BLOODPOINT"):FindFirstChild("REMOVE") ~= nil)
		and not currentValues.Stunned.Value then
		if V == false then V = true game.ReplicatedStorage:WaitForChild("-LockerAuras"):WaitForChild("ForceCloak"):FireServer() end
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

	actionList.PreventHeadTilt = true

	local Connections = {}

	remoteList.Server:FireServer("Cloak", true)

	local function Disconnect()
		if Action.ActionInfo.Disconnect then Action.ActionInfo.Disconnect = nil end
		if Connections.Change then Connections.Change:Disconnect() Connections.Change = nil end

		remoteList.Server:FireServer("Cloak", false)

		repeat task.wait()
		until currentValues.KillerAction.Value == "Nothing"

		actionList.PreventHeadTilt = false

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

	Action.ActionInfo.Disconnect = Disconnect
end

function Action:Stop(...)
	if not Action.ActionInfo.Disconnect or Action.Debounces.Exiting then return warn('Anti-Spam Exit') end
	Action.Debounces.Exiting = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList

	if currentValues.KillerAction.Value ~= "Bell Use" then
		repeat task.wait()
		until currentValues.KillerAction.Value == "Bell Use"
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