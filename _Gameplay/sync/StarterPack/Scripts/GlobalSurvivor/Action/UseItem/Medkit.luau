local Remotes = game.ReplicatedStorage.RemoteEvents
local Code = require(game.ReplicatedStorage.Modules:WaitForChild("Code"))

local Player = game.Players.LocalPlayer
local Default = 3

local Item = {
	Connections = {};
	AnimationTracks = nil;
	Debounces = {
		InputEnter = tick();
		InputExit = tick();
	},
	Global_IgnoreList = { -- will get more accurate between beamers over time
		Player.Character or Player.CharacterAdded:Wait(),
	}
}

function Item:Constraints(actionList, modules, Action) : boolean | "Return true if can do action"
	local CanRun = false
	local currentValues = actionList.ValueList
	local CurrentItem = actionList.CharacterItem
	local HumanoidState = Player.Character.Humanoid:GetState()

	Action.ActionName = "SELF-HEAL (MEDKIT)"

	if not Action.ActionInfo["Medkit"] then
		Action.ActionInfo["Medkit"] = {}
	end

	if not Action.Debounces["Medkit"] then
		Action.Debounces["Medkit"] = {
			startingUse = false; -- only turns on while turning device on and off once it completes
			beingUsed = false; -- stays on throughout entire use
		}
	end

	local Broken = modules.Code:GetEffect("Broken")
	
	if not currentValues.Hooked.Value
		and CurrentItem:GetAttribute("Progress") > 0
		--and CurrentItem:WaitForChild('UseProgress').Value > 0
		and HumanoidState ~= Enum.HumanoidStateType.FallingDown
		and HumanoidState ~= Enum.HumanoidStateType.Landed
		and Player.Character.Humanoid.WalkSpeed > 0
		and currentValues.Action.Value == "Nothing"
		and currentValues.HealthState.Value == 1
		and (not Broken or (Broken and not Broken.Active)) -- no broken effects
		and not Player.Character.PrimaryPart.Anchored
		and not Player.Character:GetAttribute("Sprint")
		and not Player.Character:GetAttribute("Gash")
		and not currentValues.Holded.Value
		and Player.Character.Humanoid.MoveDirection.magnitude == 0 then

		CanRun = true
		Action.ActionInfo.Medkit = {
			Item = CurrentItem;
		}
	elseif Action.Debounces.Medkit.beingUsed then
		Action.Priority = 0
		CanRun = true
	else
		Action.ActionInfo.Medkit = {}
	end

	return CanRun
end

local v = false

function Item:Start(Action, ...) : "Start Using"
	if (tick() - Item.Debounces.InputEnter) < 1 or Action.Debounces.Medkit.beingUsed or Action.Debounces.Medkit.startingUse then return --[[warn("Anti-Spam")]] end
	Item.Debounces.InputEnter = tick()
	Action.Debounces.Medkit.beingUsed = true
	Action.Debounces.Medkit.startingUse = true

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	local Medkit = Action.ActionInfo.Medkit.Item
	local Use = Medkit.Using
	
	if Player.Character:GetAttribute("Perk_Defense_Time") then
		remoteList.Perk:FireServer("Self Defense", false) -- de-activate our perk
	end
	
	modules.UI:Hide(true)
	modules.UI:Progress(currentValues.HealProgress, 'HEALING (MEDKIT)')

	actionList.MovementScript.MainScript.Disabled = true
	Character.Humanoid.WalkSpeed = 0
	
	obfuscate("string", currentValues.Action, "MedkitHeal")
	obfuscate("bool", Use, true)

	local Connections = {}
	
	if (Action.AnimationTracks == nil) then
		Action.AnimationTracks = {
			MissTrack = Character.Humanoid:LoadAnimation(script:WaitForChild('MissAnim'));
			HealTrack = Character.Humanoid:LoadAnimation(script:WaitForChild('HealAnim'));
		}
	end
	
	Action.AnimationTracks.HealTrack:Play()
	Code.Speeds:addMultiplier(Player, "MedkitHealing", 0, 0)

	local function disconnect()
		if Action.AnimationTracks.HealTrack then Action.AnimationTracks.HealTrack:Stop() end
		if Action.AnimationTracks.MissTrack then Action.AnimationTracks.MissTrack:Stop() end

		obfuscate("String", currentValues.Action, "Nothing")
		obfuscate("bool", Use, false)
		
		Code.Speeds:removeMultiplier(Player, "MedkitHealing")
		if Connections.UseSyringe then Connections.UseSyringe:Disconnect() end
		if Connections.Hit then Connections.Hit:Disconnect() end
		if Connections.Progress then Connections.Progress:Disconnect() end
		if Connections.Bool then Connections.Bool:Disconnect() end
		if Connections.State then Connections.State:Disconnect() end
		if Connections.Health then Connections.Health:Disconnect() end
		if Connections.Action then Connections.Action:Disconnect() end
		
		actionList.MovementScript.MainScript.Disabled = false
		
		Action.Debounces.Medkit.beingUsed = false
		Action.Priority = Default
		modules.UI:Hide(false)
		modules.UI:Progress()
	end

	-- Wait until value is switched and angle character --
	repeat task.wait()
	until Use.Value

	Connections.Health = currentValues.HealthState.Changed:Connect(function()
		if currentValues.HealthState.Value ~= 1 then
			disconnect()
		end
	end)

	Connections.UseSyringe = script:WaitForChild("Value").Changed:Connect(function()
		if script.Value.Value == true then
			script.Value.Value = false
			if Medkit:GetAttribute("Addon_1") == "Syringe" or Medkit:GetAttribute("Addon_2") == "Syringe" then
				disconnect()
				script.RemoteEvent:FireServer(Medkit)
			end
		end
	end)
	
	Connections.Miss = Remotes.SkillCheckResult.Event:Connect(function(Context, Result)

		if (Context ~= "Heal" or (Result ~= "Fail" and Result ~= "Miss")) then
			return
		end

		Action.AnimationTracks.MissTrack:Play()
	end)
	
	Connections.Hit = Character:GetAttributeChangedSignal("LastHit"):Connect(function(test)
		disconnect()
	end)

	Connections.Bool = Use.Changed:Connect(function()
		if not Use.Value then
			disconnect()
		end
	end)

	Connections.Progress = Medkit:GetAttributeChangedSignal("Progress"):Connect(function()
		local Progress = Medkit:GetAttribute("Progress")
		
		if Progress <= 0 then
			disconnect()
		end
	end)

	Connections.State = Character.Humanoid.StateChanged:Connect(function()
		local State = Character.Humanoid:GetState()

		if State == Enum.HumanoidStateType.FallingDown or State == Enum.HumanoidStateType.Landed then
			disconnect()
		end
	end)
	
	Connections.Action = currentValues.Action.Changed:Connect(function()
		if not (currentValues.Action.Value == "MedkitHeal")  then
			disconnect()
		end
	end)
	
	Item.Connections.Disconnect = disconnect
	Action.Debounces.Medkit.startingUse = false
end

function Item:Stop(Action, ...) : "Stop Using"
	if (tick() - Item.Debounces.InputExit) < 1 or not Item.Connections.Disconnect then return warn('Anti-Spam exit') end
	Item.Debounces.InputExit = tick()

	local args = {...}
	
	Code.Speeds:removeMultiplier(Player, "MedkitHealing")

	Item.Connections.Disconnect()
	Item.Connections.Disconnect = nil
end

function Item:UseSyringe()
	script.Value.Value = true
end

return Item
