local RunService = game:GetService("RunService")
local TweenService = game:GetService('TweenService')

local Data = require(game.ReplicatedStorage.Modules:WaitForChild("Data"))
local Code = require(game.ReplicatedStorage.Modules:WaitForChild("Code"))
local SpeedsModule = require(game.ReplicatedStorage.Modules:WaitForChild("Code"):WaitForChild("Speeds"))

local Player = game.Players.LocalPlayer

local Hit_Module = require(script:WaitForChild('Hit_Detection'))

local Animation_Assets = game:GetService('ReplicatedStorage'):WaitForChild('Game_Assets'):WaitForChild('Animations')

local Perk_Settings = {
	Power_Swing = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Power Swing'));
}

local ModulesV2 = {
	Data = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'));
	Code = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Code'));
}

local Connections = {}

local Swing_Settings = {
	Hitboxes = {
		Normal = {
			Size = Vector3.new(3, 3, 5);
			Radius = 0.6,
			Range = 5;
			Angle_Booster = -0.5;
		},
		Noob = {
			Radius = 1,
			Range = 1.5,
		},
	},
	Swing_Max_Time = 0.6;
	Swing_Min_Time = 0.15;
}

local EventRemotes = game.ReplicatedStorage.RemoteEvents.EventRemotes

local Action = {
	Key = "Interact2";
	ActionName = "#Swing";
	Priority = 4; -- scale of 1-5
	ActionInfo = {
		Modifier = 0;
	},
	Connections = {},
	Tracks = {}, -- storing tracks should be better for optimizing
	Debounces = {
		Holding = false;
		Swinging = false;
		Starting = false;
		AppliedBackground = false;
		InputEnter = tick()
	},
	Timer = 0;
	CanPass = false;
	ActiveSwing = false;
}

local Global_Ignore = {Player.Character}

function Init()

	local Killer = Data:GetCharacter()
	local Animation_Names = {
		"Swing";
		"Lunge";
		"Hit_Player";
		"Hit_Object";
	}

	for _, animation_name in pairs(Animation_Names) do

		if Animation_Assets:WaitForChild('Attack_Animations'):FindFirstChild(Killer..'_'..animation_name) then
			Action.Tracks[animation_name] = Player.Character:WaitForChild('Humanoid'):LoadAnimation(Animation_Assets:WaitForChild('Attack_Animations'):WaitForChild(Killer..'_'..animation_name))

			coroutine.wrap(function()
				game:GetService("ContentProvider"):PreloadAsync({Animation_Assets:WaitForChild('Attack_Animations'):WaitForChild(Killer..'_'..animation_name)})
			end)()

		elseif Animation_Assets:WaitForChild('Attack_Animations'):FindFirstChild('Default_'..animation_name) then

			coroutine.wrap(function()
				game:GetService("ContentProvider"):PreloadAsync({Animation_Assets:WaitForChild('Attack_Animations'):WaitForChild('Default_'..animation_name)})
			end)()

			Action.Tracks[animation_name] = Player.Character:WaitForChild('Humanoid'):LoadAnimation(Animation_Assets:WaitForChild('Attack_Animations'):WaitForChild('Default_'..animation_name))
		end
	end
end
Init()

local function lerp(a, b, x)
	return (a + ((b - a) * x))
end

function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList

	if not actionList.BasicAttack.Prevent
		and not actionList.BasicAttack.Using
		and (currentValues:WaitForChild('KillerAction').Value == 'Nothing' or currentValues:WaitForChild('KillerAction').Value == 'BlinkAction')
		and (Player.Character:GetAttribute("IntroDone") ~= nil and Player.Character:GetAttribute("IntroDone") == true)
		and KillerConstraints(modules) == true then

		CanRun = true
	elseif Action.Debounces.Swinging then
		Action.Priority = 0
		CanRun = true
	else
		Action.ActionInfo.Survivor = nil
		Action.ActionInfo.Settings = nil
	end

	return CanRun
end

function KillerConstraints(modules)
	
	if (modules.Data:GetCharacter() == "Scientist") then
		return (workspace.MatchValues.TimeScale.Value == 1)
	end

	if (modules.Data:GetCharacter() == "Psychopath") then
		return not (Player.Character:GetAttribute("Power_State") == 2)
	end

	if (modules.Data:GetCharacter() == "Nurse") then
		return not (Player.Character:WaitForChild("Blink"):GetAttribute("BlinkAttack") and Player.Character:WaitForChild("Blink"):GetAttribute("State") > 0)
	end

	if (modules.Data:GetCharacter() == "Wraith") then
		return not (Player.Character:GetAttribute("Cloaked"))
	end
	
	if (modules.Data:GetCharacter() == "Phantasm") then
		return not (Player.Character:GetAttribute("PostTP"))
	end

	return true
end

function OnKillerAttack()

	if (Data:GetCharacter() == "Nurse") then

		local BlinkModel = Player.Character:WaitForChild("Blink")

		if (BlinkModel:GetAttribute("State") ~= 5) then
			return
		end

		BlinkModel.PowerValues.PowerRemote:FireServer("SetValue", "BlinkAttack", true)
		BlinkModel:SetAttribute("BlinkAttack", true)
	end
end

local HasDone = false
local BloodRage = {
	Power = nil;
	Progress = nil;
	State = nil;
}

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1 or Action.Debounces.Starting or Action.Debounces.Swinging then return --[[warn("Anti-Spam")]] end
	if Player.Backpack.Scripts.values.Stunned.Value == true then return warn('STUNNED') end

	Action.Debounces.Holding = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character, Hit = Player.Character, {
		Status = "None"; -- what we hit
		Target = nil;
		Forgiveness = nil; -- no hit forgiveness yet
		Ignore = Global_Ignore; -- things to ignore
		Timestamp = workspace:GetServerTimeNow();
		CurrentSpeed = Player.Character:WaitForChild('Humanoid').WalkSpeed
	}

	if (modules.Data:GetCharacter() == "Nurse") then
		repeat task.wait()
		until (Player.Character:WaitForChild("Blink"):GetAttribute("State") == 0 or Player.Character:WaitForChild("Blink"):GetAttribute("State") == 5)
	end

	if (not Action.Debounces.Holding) then
		return
	end

	Action.Debounces.Swinging = true
	Action.Debounces.Starting = true
	Action.ActionInfo.LastHit = nil

	Action.Debounces.InputEnter = tick()

	local BaseSpeed = Code:GetPlayerValue(Player, "LungeSpeed")
	BaseSpeed *= if (Player.Character:GetAttribute("Carry")) then 0.85 else 1

	Character:SetAttribute("Swing", true)
	remoteList.Swing:FireServer("Start_Hit")

	Action.Tracks.Lunge:Play()
	Action.Tracks.Swing:AdjustSpeed(2)

	PlayAudio()

	-----------------------------------------------------------

	Action.Connections.Disconnect = function(info)
		if Action.Connections.Disconnect then Action.Connections.Disconnect = nil end
		--if Action.Connections.Action then Action.Connections.Action:Disconnect() Action.Connections.Action = nil end
		if Action.Connections.Swinging then Action.Connections.Swinging:Disconnect() Action.Connections.Swinging = nil end
		Action.Debounces.Holding = false

		if ((currentValues.KillerAction.Value ~= "Attacking" and currentValues.KillerAction.Value ~= "Nothing") or currentValues.Stunned.Value) then
			if Action.Tracks.Lunge then Action.Tracks.Lunge:AdjustSpeed(0) end
			if Action.Tracks.Lunge then Action.Tracks.Lunge:Stop() end
			remoteList.Swing:FireServer("Stop_Hit")
	
			repeat task.wait()
			until (currentValues.KillerAction.Value == "Nothing" or currentValues.KillerAction.Value == "PlayerGrasp")

			Action.Priority = 4
			Action.Debounces.Swinging = false

			task.delay(.5, function() -- give cd enough time
				actionList.BasicAttack.Using = false
				Character:SetAttribute("SwingEnd", tostring(workspace:GetServerTimeNow()))
				Character:SetAttribute("Swing", false)
			end)
			return ""
		end

		-- ^^ Wait for us to hit something or Min Swing Time to End ^^ --

		if Action.Tracks.Lunge then Action.Tracks.Lunge:AdjustSpeed(0) end

		script.RemoteEvent:FireServer(Player.Character:WaitForChild(modules.Data:GetCharacter()).Handle:WaitForChild("SwingSound"))

		coroutine.wrap(function()
			if (Hit.Status == "None") then
				Hit.Status, Hit.Target = Swing(-1, workspace:GetServerTimeNow())

				for count = 0, 10, 1 do
					if (Hit.Status ~= "None") then return end
					task.wait(0.035)
					Hit.Status, Hit.Target = Swing(-1, workspace:GetServerTimeNow())
				end
			end
		end)()

		Action.Tracks.Swing:Play()
		Action.Tracks.Swing:AdjustSpeed(Action.Tracks.Swing.Length/1)

		OnKillerAttack()

		Action.CanPass = false
		Action.Timer = 0

		Action.Tracks.Swing.KeyframeReached:Once(function(frame)
			Action.CanPass = true
		end)

		if (Action.Tracks.Lunge.IsPlaying) then Action.Tracks.Lunge:Stop() end

		Action.CanPass = false

		if Hit.Status == "None" then
			EnterSlowdown(nil)
			local v = Code:GetPlayerValue(Player, "MissCooldown")
			if ModulesV2.Data:GetCharacter() == "Psychopath" then
				local char = Character
				if char:GetAttribute("Power_State") == "Using" then
					script.RemoteEvent:FireServer("nil","Psychopath")
					v *= 0.85
				end
			end
			task.wait(v)
			EventRemotes.ClientAttack:FireServer("Nothing")
		elseif Hit.Status == 'Player' then
			remoteList.Swing:FireServer("Hit", Hit.Target.Character.PrimaryPart)

			Action.Tracks.Swing:Stop()
			Action.Tracks.Hit_Player:Play()

			EnterSlowdown(Action.Tracks.Hit_Player, currentValues)

			local wipeSpeed = Code:GetPlayerValue(Player, "WipeSpeed")
			wipeSpeed *= if (Player.Character:GetAttribute("Carry")) then 2 else 1

			wipeSpeed = math.clamp(wipeSpeed, 0.1, 10)

			Action.Tracks.Hit_Player:AdjustSpeed((Action.Tracks.Hit_Player.Length/3) * wipeSpeed)
			Action.Tracks.Hit_Player.Stopped:Wait()

		end

		Action.CanPass = true

		repeat task.wait() until Action.Connections.SlowTween == nil

		local t = TweenService:Create(Character.Humanoid, TweenInfo.new(1), {WalkSpeed = modules.Code:GetPlayerValue(Player, "Speed") * modules.Code:GetPlayerValue(Player, "SpeedMultiplier")})
		t:Play()

		t.Completed:Wait()

		ToggleCollision(false)
		remoteList.Swing:FireServer("Stop_Hit")

		repeat task.wait()
		until (currentValues.KillerAction.Value == "Nothing" or currentValues.KillerAction.Value == "PlayerGrasp")

		Action.Priority = 4
		Action.Debounces.Swinging = false

		task.delay(.5, function() -- give cd enough time
			actionList.BasicAttack.Using = false
			Character:SetAttribute("SwingEnd", tostring(workspace:GetServerTimeNow()))
			Character:SetAttribute("Swing", false)
			
			local Animator: Animator = Character.Humanoid.Animator
		end)
	end

	--[[Action.Connections.Action = currentValues.KillerAction.Changed:Connect(function()

		if currentValues.KillerAction.Value == "Nothing" then
			Action.Connections.Disconnect() -- disconnect by action change
		end
	end)]]

	-- ACTUAL SWINGING FUNCTIONALITY --
	Action.CanPass = false
	actionList.BasicAttack.Using = true
	Hit.CurrentSpeed = BaseSpeed
	Hit.Timestamp = workspace:GetServerTimeNow()
	Action.Timer = 0
	
	Swing_Settings.Swing_Max_Time = Code:GetPlayerValue(Player, "LungeDuration")

	ToggleCollision(true)

	local lungeTween = TweenService:Create(Character.Humanoid, TweenInfo.new(0.35), {WalkSpeed = BaseSpeed})
	lungeTween:Play()

	Action.Connections.Swinging = game["Run Service"].Heartbeat:Connect(function(delta)

		if ((workspace:GetServerTimeNow() - Hit.Timestamp) < (Swing_Settings.Swing_Max_Time) and Hit.Status ~= 'Player') then
			Hit.Status, Hit.Target = Swing(delta, Hit.Timestamp)
			return
		end

		if (Action.Debounces.Swinging and actionList.BasicAttack.Using and Action.Connections.Disconnect) then
			Action.Connections.Disconnect()
		end
	end)

	Action.Debounces.Starting = false

	if (Player.Character:GetAttribute("Carry")) then
		Action.Connections.Disconnect(true)
	end
end

function Swing(delta: number, timestamp: number)

	if (delta == -1) then
		return Hit_Module.Cast(Swing_Settings)
	end

	if (Action.CanPass or (workspace:GetServerTimeNow() - timestamp) >= 5) then
		return "None", nil
	end

	if (Action.Timer > 0) then
		Action.Timer -= delta
		return "None", nil
	end

	Action.Timer = 0.035

	return Hit_Module.Cast(Swing_Settings)
end

function ToggleCollision(bool)
	script.CollisionEvent:FireServer(bool)

	local targetCollision = if (bool) then "Killer" else "Player"
	local survCollision = if (bool) then "Survivor" else "Player"

	Code:SetCollision(Player, targetCollision)

	for i, v in pairs(game.Teams.Survivor:GetPlayers()) do

		if (Code:GetHealthState(v) <= 0) then
			return
		end

		Code:SetCollision(v, survCollision)
	end
end

function EnterSlowdown(animationToWait: AnimationTrack, currentValues)
	if (Action.Connections.SlowTween ~= nil) then
		Action.Connections.SlowTween:Cancel()
		Action.Connections.SlowTween = nil
	end

	local Speed = if (Player.Character:GetAttribute("Carry")) then 2 else 4
	
	Action.Connections.SlowTween = TweenService:Create(Player.Character.Humanoid, TweenInfo.new(0.35), {WalkSpeed = Speed})
	Action.Connections.SlowTween:Play()	

	local completed
	completed = Action.Connections.SlowTween.Completed:Connect(function()
		Player.Character.Humanoid.WalkSpeed = Speed
		
		Action.Connections.SlowTween:Cancel()
		Action.Connections.SlowTween = nil

		if (Connections["SlowCap"] ~= nil) then
			Connections["SlowCap"]:Disconnect()
			Connections["SlowCap"] = nil
		end

		completed = nil

		Connections["SlowCap"] = RunService.Heartbeat:Connect(function()
			Player.Character.Humanoid.WalkSpeed = Speed

			--[[if (Connections["SlowCap"] ~= nil) then
				Connections["SlowCap"]:Disconnect()
				Connections["SlowCap"] = nil
			end]]
		end)

		if (animationToWait == nil) then
			coroutine.wrap(function()
				task.wait(Code:GetPlayerValue(Player, "MissCooldown"))

				if (Connections["SlowCap"] ~= nil) then
					Connections["SlowCap"]:Disconnect()
					Connections["SlowCap"] = nil
				end

			end)()
		else
			animationToWait.Stopped:Connect(function()

				if (Connections["SlowCap"] ~= nil) then
					Connections["SlowCap"]:Disconnect()
					Connections["SlowCap"] = nil
				end

			end)
		end
	end)
end

function PlayAudio()
	coroutine.wrap(function()
		local ID = Player.Character.Head.Swing.SoundId
		local V = Player.Character.Head.Swing.Volume

		script.RemoteEvent2:FireServer(ID, "Swing",V)

		local ID = Player.Character.Head.Lunge.SoundId 
		local V = Player.Character.Head.Lunge.Volume

		script.RemoteEvent2:FireServer(ID,"Lunge",V)

		repeat task.wait() until (Player.Character.Head:FindFirstChild("Lunge") ~= nil)
		script.RemoteEvent:FireServer(Player.Character:WaitForChild(Data:GetCharacter()).Handle:WaitForChild("LungeSound"))
	end)()
end

function Action:Stop(...) : "End Action"
	if not Action.Debounces.Swinging or Action.Debounces.Starting or not Action.Connections.Disconnect then
		Action.Debounces.Holding = false
		return 
	end

	Action.Connections.Disconnect()
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
