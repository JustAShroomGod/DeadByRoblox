local Player = game.Players.LocalPlayer
local Default = 3;

local Survivor_Animations = game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild("Hook"):WaitForChild("Survivor")

local Action = {
	Key = "Interact2";
	ActionName = "RESCUE";
	InteractDistance = 4;
	Priority = 2; -- scale of 1-5
	ActionInfo = {
		Hook = nil;
		Survivor = nil;
		Disconnect = nil;
		Connections = {
			Tracks = {};
		};
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
	local Hook : Model = actionList.Hook

	if not Hook then return false end
	local hookSettings = Hook.Panel

	if (Hook:WaitForChild("Trigger").Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance -- Distance Check
		and currentValues.HealthState.Value > 0
		and not currentValues.Holded.Value
		and not currentValues.Hooked.Value
		and currentValues.Action.Value == "Nothing"
		and hookSettings.Ocuped.Value
		and hookSettings.Player.Value ~= "Nobody" then

		Action.ActionInfo.Hook = Hook
		Action.ActionInfo.Survivor = game.Players:FindFirstChild(hookSettings.Player.Value)

		CanRun = true
	elseif Action.Debounces.InProgress then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	else
		Action.ActionInfo.Hook = nil
	end

	return CanRun
end

local t = nil
local Rescuing = 1.5

local Perk_Modules = 
	{
		Savier = require(game.ReplicatedStorage:WaitForChild("Game_Data"):WaitForChild("Perks"):WaitForChild("Survivor"):WaitForChild("The Savier"))
	}

local Animation = "Rescue"

coroutine.resume(coroutine.create(function()
	game:GetService("ContentProvider"):PreloadAsync({Survivor_Animations:FindFirstChild(Animation)})
end))

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or not Action.ActionInfo.Survivor or Action.Debounces.InProgress then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	local Hook = Action.ActionInfo.Hook
	script.V_Prog.Value = 0
	local isunhooking = true
	--modules.UI:Hide(true)
	currentValues.Action.Value = "Unhooking"
	modules.UI:Progress(script.V_Prog, "RESCUING")
	Player.Character:SetAttribute('Motion_Locked', true)
	Character.PrimaryPart.Anchored = true

	script.RemoteEvent:FireServer(true)

	if Action.ActionInfo.Connections.Animation then
		Action.ActionInfo.Connections.Animation:Disconnect() -- remove dual listening (for perforamnce)
	end

	local hasSave, Save_Tier = modules.Data:GetPerk("The Savier", Player)
	local Hook_Rescue_Time = Rescuing

	if hasSave and Player.Character:GetAttribute("Savier_Tokens") then
		Hook_Rescue_Time -= (Hook_Rescue_Time * ((Perk_Modules.Savier.Tiers[Save_Tier] * tonumber(Player.Character:GetAttribute("Savier_Tokens"))))/100)/2
	end

	local g = false

	local function disconnect(info)
		if g then return end
		if info then
			print('Fired Disconnect - Warning')
			if Action.ActionInfo.Connections.Health then Action.ActionInfo.Connections.Health:Disconnect() Action.ActionInfo.Connections.Health = nil end
			if Action.ActionInfo.Connections.Action then Action.ActionInfo.Connections.Action:Disconnect() Action.ActionInfo.Connections.Action = nil end
			if Action.ActionInfo.CanceUnHook then Action.ActionInfo.CanceUnHook:Disconnect() end
			for _, track in pairs(Action.ActionInfo.Connections.Tracks) do
				if track.IsPlaying then track:Stop() end
			end

			modules.UI:Hide(false)
			modules.UI:Progress()
			if t then t:Pause() t = nil end
			Player.Character:SetAttribute('Motion_Locked', false)
			Character.PrimaryPart.Anchored = false
			Action.Priority = Default -- set Priority to 0 to override any possible incoming interaction
			Action.Debounces.InProgress = false
		else
			print('Fired Disconnect - Warning')
			if Action.ActionInfo.Connections.Health then Action.ActionInfo.Connections.Health:Disconnect() Action.ActionInfo.Connections.Health = nil end
			if Action.ActionInfo.Connections.Action then Action.ActionInfo.Connections.Action:Disconnect() Action.ActionInfo.Connections.Action = nil end
			if Action.ActionInfo.CanceUnHook then Action.ActionInfo.CanceUnHook:Disconnect() end
			for _, track in pairs(Action.ActionInfo.Connections.Tracks) do
				if track.IsPlaying then track:Stop() end
			end
			isunhooking = false
			currentValues.Action.Value = "Nothing"
			script.RemoteEvent:FireServer(false)
			Player.Character:SetAttribute('Motion_Locked', false)
			Character.PrimaryPart.Anchored = false
			modules.UI:Hide(false)
			modules.UI:Progress()
			if t then t:Pause() t = nil end
			Action.Priority = Default -- set Priority to 0 to override any possible incoming interaction
			Action.Debounces.InProgress = false
		end
	end

	coroutine.resume(coroutine.create(function()
		game:GetService("ContentProvider"):PreloadAsync({Survivor_Animations:FindFirstChild(Animation)})
	end))

	Action.ActionInfo.Connections.Health = currentValues.HealthState.Changed:Connect(function()
		disconnect()
	end)

	Action.ActionInfo.Connections.Action = currentValues.Action.Changed:Connect(function()

		if not (currentValues.Action.Value == "Unhooking") then
			disconnect()
		end
	end)

	Action.ActionInfo.Disconnect = disconnect

	if not Action.ActionInfo.Connections.Tracks[Animation] then
		Action.ActionInfo.Connections.Tracks[Animation] = Player.Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(Survivor_Animations:FindFirstChild(Animation))
	end

	local v = Hook_Rescue_Time * 0.65

	Action.ActionInfo.Connections.Tracks[Animation]:Play()
	Action.ActionInfo.Connections.Tracks[Animation]:AdjustSpeed(Action.ActionInfo.Connections.Tracks[Animation].Length/Hook_Rescue_Time)
	t = game:GetService("TweenService"):Create(script.V_Prog, TweenInfo.new(v, Enum.EasingStyle.Linear), {Value = 1000})
	t:Play()
	repeat task.wait() until Action.ActionInfo.Connections.Tracks[Animation].IsPlaying == false or (script.V_Prog.Value == 1000) or isunhooking == false
	if isunhooking == true then
		g = true
		remoteList.Server:FireServer("Hook", "Unhook", Action.ActionInfo.Survivor.Character, Hook)
		task.wait(Hook_Rescue_Time - v)
		currentValues.Action.Value = "Nothing"
		g = false
		disconnect(true)
	end
end

function Action:Stop(...)
	if not Action.ActionInfo.Disconnect then return warn('Anti-Spam exit') end
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