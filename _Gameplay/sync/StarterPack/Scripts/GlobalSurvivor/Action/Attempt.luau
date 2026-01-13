local Player = game.Players.LocalPlayer
local Default = 1;

coroutine.resume(coroutine.create(function()
	game:GetService("ContentProvider"):PreloadAsync({script:WaitForChild("Attempt"),script:WaitForChild("Success")})
end))

local InAnimation = false
local Survivor_Animations = game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild("Hook"):WaitForChild("Survivor")

local DefaultDamage, DefaultLuck = 15, 4

--local Perk_Data = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'))

local Action = {
	Key = "Interact2";
	ActionName = "ATTEMPT TO UNHOOK YOURSELF";
	Priority = 1; -- scale of 1-5
	ActionInfo = {
		Hook = nil;
		Attempt = false;
		Disconnect = nil;
		Connections = {
			Tracks = {};
		}
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

	local Character = game.Players.LocalPlayer.Character

	if not Hook then return false end
	if not Character then return false end
	if Character:GetAttribute("Hook_Blood") == nil or Character:GetAttribute("Hook_Stage") == nil then return false end

	local hookSettings = Hook.Panel
	local hookBlood = string.split(Character:GetAttribute("Hook_Blood"), ':')
	local hookStage = string.split(Character:GetAttribute("Hook_Stage"), ':')

	if Hook and currentValues.Hooked.Value -- we have hook closest to us and are hooked
		and not currentValues.Holded.Value
		and ((tonumber(hookBlood[1])/tonumber(hookBlood[2])) * 100) >= 53 and tonumber(hookStage[1]) <= 1
		and currentValues.Action.Value == "Nothing"
		and hookSettings.Ocuped.Value
		and hookSettings.Player.Value == tostring(Player) then -- we are the ones on this hook

		Action.ActionInfo.Hook = Hook
		CanRun = true
	elseif Action.Debounces.InProgress then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	else
		Action.ActionInfo.LocalProgress = 0
		Action.ActionInfo.Hook = nil
	end

	return CanRun
end

local tween: Tween = nil
local v_prog = script:WaitForChild("V_Prog")

function Action:Start(...) : "Start Action?"
	if InAnimation == true then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true
	Action.ActionInfo.LocalProgress = 0

	--print('Playing')

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	local Perk_Data = actionList.PerkValues

	local Hook = Action.ActionInfo.Hook
	--modules.UI:Hide(true)

	InAnimation = true 
	--print(InAnimation)

	if Action.ActionInfo.Connections.Animation then
		Action.ActionInfo.Connections.Animation:Disconnect() -- remove dual listening (for perforamnce)
	end

	if Action.ActionInfo.Connections.Tracks.Attempt then
	else
		Action.ActionInfo.Connections.Tracks.Attempt = Character.Humanoid.Animator:LoadAnimation(script.Attempt)
	end

	Action.ActionInfo.Connections.Tracks.Attempt.Priority = Enum.AnimationPriority.Action4
	Action.ActionInfo.Connections.Tracks.Attempt:Play()
	Action.ActionInfo.Connections.Tracks.Attempt:AdjustSpeed(Action.ActionInfo.Connections.Tracks.Attempt.Length/1.3)
	tween = game:GetService("TweenService"):Create(v_prog, TweenInfo.new(1.3, Enum.EasingStyle.Linear), {Value = 1000})
	tween:Play()
	modules.UI:Progress(v_prog, "ATTEMPTING")

	local function disconnect(Argument,Argument2)
		if Argument and Argument2 then else return end
		--print('Disconnect fired')
		if Action.ActionInfo.Connections.Health then Action.ActionInfo.Connections.Health:Disconnect() Action.ActionInfo.Connections.Health = nil end
		if Action.ActionInfo.Connections.Action then Action.ActionInfo.Connections.Action:Disconnect() Action.ActionInfo.Connections.Action = nil end
		
		if tween then
			if tween.PlaybackState ~= Enum.PlaybackState.Completed then
				tween:Pause()
			end
		end
		
		--tween:Pause()
		tween = nil
		
		modules.UI:Progress()
		v_prog.Value = 0
		InAnimation = false

		for _, track in pairs(Action.ActionInfo.Connections.Tracks) do
			if track.IsPlaying then if track.Name == "Attempt" then track:Stop() end end
		end

		modules.UI:Hide(false)

		Action.Priority = Default -- set Priority to 0 to override any possible incoming interaction
		Action.Debounces.InProgress = false
	end

	Action.ActionInfo.Connections.Action = currentValues.Hooked.Changed:Connect(function()

		if not (currentValues.Hooked.Value == true) then
			tween:Pause()
			tween = nil
			modules.UI:Progress()
			v_prog.Value = 0
			disconnect(true,true)
		end
	end)

	coroutine.resume(coroutine.create(function()
		repeat task.wait() until Action.ActionInfo.Connections.Tracks.Attempt.IsPlaying == false or InAnimation == false
		if InAnimation == false then
		else
			if Action.ActionInfo.Connections.Health then Action.ActionInfo.Connections.Health:Disconnect() Action.ActionInfo.Connections.Health = nil end
			if Action.ActionInfo.Connections.Action then Action.ActionInfo.Connections.Action:Disconnect() Action.ActionInfo.Connections.Action = nil end
			Action.Debounces.InProgress = false
			InAnimation = false
			remoteList.Server:FireServer("Hook", "ChanceTaken", Character, Hook)
			tween:Pause()
			tween = nil
			modules.UI:Progress()
			v_prog.Value = 0
			disconnect(true,true)
		end
	end))

	Action.ActionInfo.Disconnect = disconnect
end

function Action:Stop(...)
	if not Action.ActionInfo.Disconnect then return warn('Anti-Spam exit') end
	Action.Debounces.InputExit = tick()
	print('stopping - regular')
	local args = {...}

	Action.ActionInfo.Disconnect(true,true)
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
