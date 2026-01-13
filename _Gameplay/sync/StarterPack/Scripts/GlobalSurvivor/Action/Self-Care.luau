local Remotes = game.ReplicatedStorage.RemoteEvents
local Player = game.Players.LocalPlayer
local Defaults = 5;

local Action = {
	Key = "Interact2";
	ActionName = "SELF-HEAL";
	Priority = 4; -- scale of 1-5
	AnimationTracks = nil;
	ActionInfo = {
		Gate = nil;
		Disconnect = nil;
	},
	Debounces = {
		Healing = false;
		InputEnter = tick();
		InputExit = tick();
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList

	local HasPerk, PerkTier = modules.Data:GetPerk("SelfCare")
	local Broken = modules.Code:GetEffect("Broken")

	if currentValues.HealthState.Value == 1
		and not modules.Code:GetEffect("Cloaked")
		and currentValues.Action.Value == "Nothing"
		and not currentValues.Hooked.Value
		and not currentValues.Holded.Value
		and not Player.Character:GetAttribute("Gash")
		and not Player.Character:GetAttribute("Sprint")
		and (Player.Character:GetAttribute("Healing_Boost") == nil)
		and HasPerk -- has to have self-care
		and (not Broken or (Broken and not Broken.Active)) then

		CanRun = true
	elseif Action.Debounces.Healing then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or Action.Debounces.Healing then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Healing = true

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	modules.UI:Hide(true)
	modules.UI:Progress(currentValues.HealProgress, "HEALING (Self-Heal)", "HealingSpeed", modules.Code.BaseValues.Survivor.Action.HealingSpeed)

	if Player.Character:GetAttribute("Perk_Defense_Time") then
		remoteList.Perk:FireServer("Self Defense", false) -- de-activate our perk
	end

	actionList.MovementScript.MainScript.Disabled = true
	Character.Humanoid.WalkSpeed = 0
	
	local HealingConfig = {
		SelfHealing = true;
		RestrictValues = true;
		IsMending = false;
		SumKeys = {"SelfCare"};
	}

	currentValues.Action.Value = "SelfHealing"
	Remotes.ClientToServer.HealingEvent:FireServer(Player.Name, "Start", HealingConfig)

	if (Action.AnimationTracks == nil) then
		Action.AnimationTracks = {
			MissTrack = Character.Humanoid:LoadAnimation(script:WaitForChild('Skill_Miss'));
			HealTrack = Character.Humanoid:LoadAnimation(script:WaitForChild('Animation'));
		}
	end
	
	Action.AnimationTracks.HealTrack:Play(.2, 4, 1)

	local Connections = {}

	local function disconnect(softdisconnect : boolean)
		if Action.AnimationTracks.HealTrack then Action.AnimationTracks.HealTrack:Stop() end
		if Action.AnimationTracks.MissTrack then Action.AnimationTracks.MissTrack:Stop() end

		if not softdisconnect then
			actionList.MovementScript.MainScript.Disabled = false
		end

		currentValues.Action.Value = "Nothing"
		Remotes.ClientToServer.HealingEvent:FireServer(Player.Name, "Stop")

		if Connections.Hit then Connections.Hit:Disconnect() end
		if Connections.Progress then Connections.Progress:Disconnect() end
		if Connections.Health then Connections.Health:Disconnect() end
		if Connections.Action then Connections.Action:Disconnect() end
		if Connections.Miss then Connections.Miss:Disconnect() end

		Action.Debounces.Healing = false
		Action.Priority = Defaults
		modules.UI:Hide(false)
		modules.UI:Progress()
	end
	
	Connections.Miss = Remotes.SkillCheckResult.Event:Connect(function(Context, Result)

		if (Context ~= "Heal" or (Result ~= "Fail" and Result ~= "Miss")) then
			return
		end

		Action.AnimationTracks.MissTrack:Play()
	end)

	Connections.Action = currentValues.Action.Changed:Connect(function()

		if currentValues.Action.Value ~= "SelfHealing" then
			disconnect(true)
		end
	end)

	Connections.Hit = Character:GetAttributeChangedSignal("LastHit"):Connect(function(test)
		disconnect()
	end)

	Connections.Health = currentValues.HealthState.Changed:Connect(function()
		disconnect()
	end)

	Connections.HealthStateChanged = currentValues.HealthState.Changed:Connect(function()
		disconnect()
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
	local actionList, remoteList, modules = args[1], args[2], args[3]

	if Constraints(actionList, modules) then
		return true
	end

	return false
end

return Action