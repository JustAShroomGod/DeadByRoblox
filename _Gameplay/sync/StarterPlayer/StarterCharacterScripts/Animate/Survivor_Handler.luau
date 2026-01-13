local Runservice, ReplicatedStorage = game:GetService('RunService'), game:GetService('ReplicatedStorage')

local Assets = ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations')
local SurvivorMovement = Assets:WaitForChild("Movement"):WaitForChild("Survivor")

local Player = game.Players.LocalPlayer
local Character = Player.Character
local G = true

local FadeTimes = 
	{
		Healthy = 
		{
			["Run"] = 0.45,
			["Idle"] = 0.2,
			["Crouch"] = 0.1,
			["CrouchIdle"] = 0.1,
			["Walk"] = 0.35
		},
		Downed = 
		{
			["Crawl"] = 0.15,
			["Idle"] = 0.15
		},
		Injured = 
		{
			["Run"] = 0.5,
			["Idle"] = 0.2,
			["Crouch"] = 0.1,
			["CrouchIdle"] = 0.1,
			["Walk"] = 0.4
		},
	}

--[[if (Player.UserId == ) then 
	--SurvivorMovement = script:WaitForChild("Survivor")
	Assets:WaitForChild("Emotes"):WaitForChild("Point").AnimationId = "rbxassetid://15072022270"
	Assets:WaitForChild("Emotes"):WaitForChild("Follow").AnimationId = "rbxassetid://15072031535"
end]]--

--[[if (Player.UserId == ) then
	Assets:WaitForChild("Movement"):WaitForChild("Survivor"):WaitForChild("Default_Injured_Run").AnimationId = "rbxassetid://128546084753461"
	script.Survivor.Default_Injured_Run:SetAttribute("Speed",0.06)
end]]--

local Killer_Character = Player:WaitForChild('Data'):WaitForChild('Killer')
local Modules = {

}

local Handler = {
	IsRunning = false;
	Connections = {};
	Tracks = {};
	Special_Tracks = {};
	Action_Tracks = {};
}

local PrevTime = 0

local Humanoid, Rootpart = Character:WaitForChild('Humanoid'), Character:WaitForChild('HumanoidRootPart')

function PlayAnimation(Track : Animation, Speed : number) : "Play Animation"

	local Time = 0

	if Track then

		if not Handler.Tracks[Track] then -- Create Track
			Handler.Tracks[Track] = Humanoid:LoadAnimation(Track)
		end

		if (string.match(Track.Name, "Default") or string.match(Track.Name, "Medkit")) and not string.match(Track.Name, "Crawl") and not string.match(Track.Name, "Injured") then
			local Times = FadeTimes.Healthy
			if string.match(Track.Name, "Run") then
				Time = Times.Run
			elseif string.match(Track.Name, "Walk") then
				if not string.match(Track.Name, "Crouch") then
					Time = Times.Walk
				else
					Time = Times.Crouch
				end
			elseif string.match(Track.Name, "Idle") then
				if string.match(Track.Name, "Crouch") then
					Time = Times.CrouchIdle
				else
					Time = Times.Idle
				end
			end
		elseif string.match(Track.Name, "Injured") then
			local Times = FadeTimes.Injured
			if string.match(Track.Name, "Run") then
				Time = Times.Run
			elseif string.match(Track.Name, "Walk") then
				if not string.match(Track.Name, "Crouch") then
					Time = Times.Walk
				else
					Time = Times.Crouch
				end
			elseif string.match(Track.Name, "Idle") then
				if string.match(Track.Name, "Crouch") then
					Time = Times.CrouchIdle
				else
					Time = Times.Idle
				end
			end
		else
			if string.match(Track.Name, "Walk") then
				Time = FadeTimes.Downed.Crawl
			else
				Time = FadeTimes.Downed.Idle
			end
		end

		if not Handler.Tracks[Track].IsPlaying then
			Handler.Tracks[Track]:Play(Time)
			Handler.Tracks[Track]:AdjustSpeed(Speed)
		else
			Time = PrevTime
			Handler.Tracks[Track]:AdjustSpeed(Speed)
		end
	end

	for _, animation in pairs(Handler.Tracks) do -- close animations
		if animation == Handler.Tracks[Track] then continue end
		if not animation.IsPlaying then continue end
		animation:Stop(PrevTime)
	end
	PrevTime = Time
end

function StopAnimations()
	for _, animation in pairs(Handler.Tracks) do 
		if animation then
			animation:Stop()
		end
	end
end

function PlaySpecial(Track : Animation, Speed : number) : "Play Secondary Animation"

	if Track then

		if not Handler.Special_Tracks[Track] then -- Create Track
			Handler.Special_Tracks[Track] = Humanoid:LoadAnimation(Track)
		end

		if not Handler.Special_Tracks[Track].IsPlaying then
			Handler.Special_Tracks[Track]:Play()
			Handler.Special_Tracks[Track]:AdjustSpeed(Speed)
		else
			Handler.Special_Tracks[Track]:AdjustSpeed(Speed)
		end
	end

	for _, animation in pairs(Handler.Special_Tracks) do -- close animations
		if animation == Handler.Special_Tracks[Track] then continue end
		if not animation.IsPlaying then continue end
		animation:Stop()
	end
end

local IsHoldingMedkitFunction = function()
	local v = false
	for i, items in pairs(Character:GetChildren()) do
		if items:IsA("Model") and (string.match(items.Name, "Medkit") or string.match(items.Name, "Toolbox")) then
			v = true
		end
	end
	return v
end

function PlayAction() : "Play the action_animations"
	local Action_Animation, Time_Stamp, Track = Character:GetAttribute("Action_Animation"), Character:GetAttribute("Action_Animation_Time"), nil

	if Track then

		if not Handler.Action_Tracks[Track] then -- Create Track
			Handler.Action_Tracks[Track] = Humanoid:LoadAnimation(Track)
		end
	end

	if Action_Animation and Action_Animation ~= "" then
		print(Action_Animation, 'needs to be played')

		if Action_Animation == "Locker_Grab" then
			Track = Assets:WaitForChild('Hiding_Spot'):WaitForChild('Survivor'):FindFirstChild(Action_Animation)
		elseif Action_Animation == "Pickup_Default" then
			Track = Assets:WaitForChild('Pickup'):WaitForChild('Survivor'):FindFirstChild(Action_Animation)
		elseif Action_Animation == "Drop_Default" then
			Track = Assets:WaitForChild('Drop'):WaitForChild('Survivor'):FindFirstChild(Action_Animation)
		elseif Action_Animation == "Knockdown" then
			Track = Assets:WaitForChild('UNSPECIFIED'):WaitForChild('Knockdown')
		else
			warn(Action_Animation, 'is not supported!')
		end

		if Track then

			if not Handler.Action_Tracks[Track] then
				Handler.Action_Tracks[Track] = Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(Track)
			end

			local A_Length = if Handler.Action_Tracks[Track].Length < 0.1 then 3 else Handler.Action_Tracks[Track].Length
			Time_Stamp = 0 - (workspace:GetServerTimeNow() - Time_Stamp)

			Handler.Action_Tracks[Track]:Play() -- play animation
			Handler.Action_Tracks[Track]:AdjustSpeed(A_Length/Time_Stamp) -- both animations should end at same time/sync
		end
	end
end

local Backpack = Player.Backpack

function AnimationCycle(Step : number)
	if G then else return end
	local IsMoving : boolean = (Humanoid.MoveDirection.Magnitude > 0.1)
	local Action : string, Health : number = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value, Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState').Value
	local IsCrouching : boolean, IsSprinting : boolean, IsHooked, isHolded = Character:GetAttribute("Crouch"), Character:GetAttribute("Sprint"), Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Hooked').Value, Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Holded').Value

	local Animation, Speed = nil, 1
	local Animation_2 : "Action Track", Speed_2 = nil, 1
	local Action = Backpack:WaitForChild("Scripts"):WaitForChild("values"):WaitForChild("Action")

	if IsHooked then
		PlayAnimation(Animation, Speed)
		PlaySpecial(Animation_2, Speed_2)
		return
	end

	if Action == "InCarry" or isHolded then -- carry tracks
		Animation = Assets:WaitForChild('Carry'):WaitForChild('Survivor'):WaitForChild('Carry_Idle_Default')
	elseif (Health == 0) then -- crawl tracks

		if IsMoving then
			Animation = SurvivorMovement:WaitForChild('Default_Crawl_Walk')
		else
			Animation = SurvivorMovement:WaitForChild('Default_Crawl_Idle')
		end

		Speed = Animation:GetAttribute("Speed") * Humanoid.WalkSpeed
	elseif (tostring(Action.Value) ~= "Nothing" and tostring(Action.Value) ~= "Shocked" and not string.match(string.lower(tostring(Action.Value)),"flash")) then

		StopAnimations()
	elseif IsMoving then -- Normal Movement Tracks --

		if (1 == 2) --[[Assets:WaitForChild('Movement'):WaitForChild('Killer'):FindFirstChild(Killer_Character.Value..'_Walk')]] then
			Animation = Assets:WaitForChild('Movement'):WaitForChild('Killer'):WaitForChild(Killer_Character.Value..'_Walk')
		elseif IsSprinting then
			Animation = if (Health == 1) then (if IsHoldingMedkitFunction() then SurvivorMovement:WaitForChild('Medkit_Injured_Run') else SurvivorMovement:WaitForChild('Default_Injured_Run')) else (if IsHoldingMedkitFunction() then SurvivorMovement:WaitForChild('Medkit_Run') else SurvivorMovement:WaitForChild('Default_Run'))
		elseif IsCrouching then
			Animation = if (Health == 1) then SurvivorMovement:WaitForChild('Default_Injured_Crouch_Walk') else SurvivorMovement:WaitForChild('Default_Crouch_Walk')
		else
			Animation = if (Health == 1) then SurvivorMovement:WaitForChild('Default_Injured_Walk') else SurvivorMovement:WaitForChild('Default_Walk')
		end

		Speed = Animation:GetAttribute("Speed") * Humanoid.WalkSpeed
	else

		if (1 == 2)--[[Assets:WaitForChild('Movement'):WaitForChild('Killer'):FindFirstChild(Killer_Character.Value..'_Idle')]] then
			Animation = Assets:WaitForChild('Movement'):WaitForChild('Killer'):WaitForChild(Killer_Character.Value..'_Idle')
		elseif IsCrouching then
			Animation = if (Health == 1) then SurvivorMovement:WaitForChild('Default_Injured_Crouch_Idle') else SurvivorMovement:WaitForChild('Default_Crouch_Idle')
		else
			Animation = if (Health == 1) then SurvivorMovement:WaitForChild('Default_Injured_Idle') else SurvivorMovement:WaitForChild('Default_Idle')
		end

		Speed = Animation:GetAttribute("Speed")
	end

	PlayAnimation(Animation, Speed)
	PlaySpecial(Animation_2, Speed_2)
end

function Handler:Run()
	if Handler.IsRunning then return end
	Handler.IsRunning = true

	for name, connection in pairs(Handler.Connections) do
		if Handler.Connections[name] then Handler.Connections[name]:Disconnect() end
	end

	Handler.Connections.Player = Runservice.Heartbeat:Connect(AnimationCycle) -- bind animation player
	Handler.Connections.Action_Animation = Character:GetAttributeChangedSignal("Action_Animation"):Connect(PlayAction)
end

function Handler:Stop()
	if not Handler.IsRunning then return end
	Handler.IsRunning = false

	for name, connection in pairs(Handler.Connections) do
		if Handler.Connections[name] then
			Handler.Connections[name]:Disconnect()
			Handler.Connections[name] = nil
		end
	end

	PlayAnimation(nil, 0)
	PlaySpecial(nil, 0)
end

return Handler