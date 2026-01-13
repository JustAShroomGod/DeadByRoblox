local game_data = game.ReplicatedStorage:WaitForChild('Game_Data')
local Killer_Module = require(game_data:WaitForChild('Killers'):WaitForChild('Hillbilly'))
local Player = game.Players.LocalPlayer
local DefaultPriority = 3

local Action = {
	Key = "Interact3";
	ActionName = "Charge";
	Priority = 3; -- scale of 1-5
	InteractDistance = 6.5;
	ActionInfo = {
		POWER_BUTTON = "UP";
		Connections = {};
		Base_Controls = require(game.Players.LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('PlayerModule')):GetControls();
	},
	Debounces = {
		InputEnter = tick();
		InProgress = false;
	}
}

local Tracks = {}
local Hit_Module = require(script:WaitForChild('Hit_Dection'))

function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Power = Player.Character:GetAttribute("Power")
	local Saw_Cooldown = Player.Character:GetAttribute("Power_Cooldown")
	local Power_State = Player.Character:GetAttribute("Power_State")

	if not Power or not Power_State or not Saw_Cooldown then return false end
	Power = string.split(Power, ':')
	Saw_Cooldown = string.split(Saw_Cooldown, ':')

	if not Killer_Module.Client_Power_Boot and Killer_Module.Power_Client then
		Killer_Module.Client_Power_Boot = true -- booted values from client side
		Killer_Module:Power_Client(game.Players.LocalPlayer)
	end

	if currentValues.Action.Value == "Nothing" and currentValues.KillerAction.Value == "Nothing"
		and not Player.Character:GetAttribute("Carry") -- not allowed while carrying
		and (Power_State == "Idle") -- current not using power or in animation
		and tonumber(Saw_Cooldown[1]) >= tonumber(Saw_Cooldown[2]) -- at max capacity to start using power
		and not Player.Character:GetAttribute("Swing") -- not swinging currently
		and Action.ActionInfo.POWER_BUTTON == "UP" -- power button not held
		and (currentValues.Parent:WaitForChild("BLOODPOINT"):FindFirstChild("REMOVE") ~= nil)
		--and (workspace:GetServerTimeNow() - actionList.KillerInfo.Stagger) >= actionList.KillerInfo.StaggerSettings.Time
		and not actionList.BasicAttack.Prevent then

		CanRun = true
	elseif Action.Debounces.InProgress then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 0.15 or Action.ActionInfo.POWER_BUTTON == "DOWN" or (Player.Character:GetAttribute("Power_State") == "Animation") then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character, Final_Hit, Raw_Saw = Player.Character, "None", nil
	Character.Humanoid.WalkSpeed = Killer_Module.Speeds.Charging
	Raw_Saw = Character:WaitForChild('Chainsaw')

	actionList.BasicAttack.Prevent = true
	modules.UI:Hide(true)

	Action.ActionInfo.POWER_BUTTON = "DOWN" -- BEGIN REVVING DOWN

	-- Assemble Tracks --
	if not Tracks.Sprint then --TODO: CREATE ANIMATION TRACKS --
		Tracks.Sprint = Character:WaitForChild('Humanoid'):LoadAnimation(script:WaitForChild('Sprint'))
		Tracks.Stop = Character:WaitForChild('Humanoid'):LoadAnimation(script:WaitForChild('Stop'))
		Tracks.Crash = Character:WaitForChild('Humanoid'):LoadAnimation(script:WaitForChild('Crash'))
		Tracks.Hit = Character:WaitForChild('Humanoid'):LoadAnimation(script:WaitForChild('Hit'))
		Tracks.Rev = Character:WaitForChild('Humanoid'):LoadAnimation(script:WaitForChild('Rev'))
	end

	local function finalize() : "Finish disconnect sequence"
		if Action.ActionInfo.Connections.Charge then Action.ActionInfo.Connections.Charge:Disconnect() Action.ActionInfo.Connections.Charge = nil end
		if Tracks.Rev.IsPlaying then Tracks.Rev:Stop() end

		Action.Priority = DefaultPriority
		modules.UI:Hide(false)
		Action.ActionInfo.Base_Controls:Enable()

		remoteList.ObjectUpdater:FireServer(Raw_Saw:WaitForChild('Handle'):WaitForChild('Rev'), 'Playing', false)
		modules.UI:Progress() -- disable rev progress
		
		Character.Humanoid.WalkSpeed = modules.Code.Speeds.Global_Settings.Base_Speed * (1 + modules.Code:GetSpeed("Movement"))

		remoteList.Server:FireServer("Chainsaw", "Finished_Saw") --Fire to start state changes

		Action.Debounces.InProgress = false

		if Killer_Module.Chainsaw_Settings.Mouse_Debounce then
			print(Killer_Module.Chainsaw_Settings.Mouse_Debounce)
		else
			print("doesnt exist: Killer_Module.Chainsaw_Settings.Mouse_Debounce")
		end
		if not Killer_Module.Chainsaw_Settings.Mouse_Debounce then
			if Final_Hit == "None" then
				task.wait(math.clamp(3/0, 0, 0))
				actionList.BasicAttack.Prevent = false
			else
				task.wait(math.clamp(3, 0, 0))
				actionList.BasicAttack.Prevent = false
			end
		else
			if Final_Hit == "None" then
				task.wait(math.clamp(Killer_Module.Chainsaw_Settings.Mouse_Debounce/0, 0, 0))
				actionList.BasicAttack.Prevent = false
			else
				task.wait(math.clamp(Killer_Module.Chainsaw_Settings.Mouse_Debounce, 0, 0))
				actionList.BasicAttack.Prevent = false
			end
		end
	end

	local function disconnect(stunned : boolean) -- End Charging
		if Action.ActionInfo.POWER_BUTTON == "UP" then return end
		if Action.ActionInfo.Disconnect then Action.ActionInfo.Disconnect = nil end
		if Action.ActionInfo.Connections.Charge then Action.ActionInfo.Connections.Charge:Disconnect() Action.ActionInfo.Connections.Charge = nil end
		if Action.ActionInfo.Connections.Stunned then Action.ActionInfo.Connections.Stunned:Disconnect() Action.ActionInfo.Connections.Stunned = nil end
		--if Tracks.Dash.IsPlaying then Tracks.Dash:Stop() end
	
		Action.ActionInfo.POWER_BUTTON = "UP"
		Character.Humanoid.WalkSpeed = Killer_Module.Speeds.Charging

		remoteList.ObjectUpdater:FireServer(Raw_Saw:WaitForChild('Handle'):WaitForChild('Sprint'), 'Playing', false)

		if Player.Character:GetAttribute("Power_State") == "Using" then
			if Action.ActionInfo.Connections.Power_State then Action.ActionInfo.Connections.Power_State:Disconnect() Action.ActionInfo.Connections.Power_State = nil end

			remoteList.Server:FireServer("Chainsaw", "Stop_Saw") --Fire to start state changes

			if Tracks.Sprint.IsPlaying then
				Tracks.Sprint:Stop()
			end

			modules.Camera.Sensitivity.Modification = nil

			Character.Humanoid:Move(Vector3.new(0,0,0), true) -- force us to have foward movement

			actionList.PreventHeadTilt = true
			modules.Camera.Camera.HeadLocked = true

			--warn(Final_Hit)

			if Final_Hit == "None" then
				local A_Length = if Tracks.Stop.Length < 0.1 then 3 else Tracks.Stop.Length

				Character.Humanoid.WalkSpeed = Killer_Module.Speeds.Stagger
				Action.ActionInfo.Base_Controls:Enable()

				remoteList.ObjectUpdater:FireServer(Raw_Saw:WaitForChild('Handle'):WaitForChild('Stop'), 'TimePosition', 0)
				remoteList.ObjectUpdater:FireServer(Raw_Saw:WaitForChild('Handle'):WaitForChild('Stop'), 'Playing', true)

				Tracks.Stop:Play()
				Tracks.Stop:AdjustSpeed(A_Length/Killer_Module.Animation_Timing.None)
				Tracks.Stop.Stopped:Wait()
			elseif Final_Hit == "Breakable" or Final_Hit == "Player" then
				local A_Length = if Tracks.Hit.Length < 0.1 then 3 else Tracks.Hit.Length

				remoteList.ObjectUpdater:FireServer(Raw_Saw:WaitForChild('Handle'):WaitForChild('Stop'), 'TimePosition', 0)
				remoteList.ObjectUpdater:FireServer(Raw_Saw:WaitForChild('Handle'):WaitForChild('Stop'), 'Playing', true)

				Tracks.Hit:Play()
				Tracks.Hit:AdjustSpeed(A_Length/Killer_Module.Animation_Timing.Hit)
				Tracks.Hit.Stopped:Wait()
			elseif Final_Hit == "Object" then
				local A_Length = if Tracks.Crash.Length < 0.1 then 3 else Tracks.Crash.Length

				remoteList.ObjectUpdater:FireServer(Raw_Saw:WaitForChild('Handle'):WaitForChild('Crash'), 'TimePosition', 0)
				remoteList.ObjectUpdater:FireServer(Raw_Saw:WaitForChild('Handle'):WaitForChild('Crash'), 'Playing', true)

				Tracks.Crash:Play()
				Tracks.Crash:AdjustSpeed(A_Length/Killer_Module.Animation_Timing.Crash)
				Tracks.Crash.Stopped:Wait()
			else
				error(Final_Hit, 'Unsupported!')
			end

			actionList.PreventHeadTilt = false
			modules.Camera.Camera.HeadLocked = false

			finalize()
		elseif stunned then
			remoteList.Server:FireServer("Chainsaw", "Stunned_Saw") --Fire to start state changes

			actionList.PreventHeadTilt = false
			modules.Camera.Camera.HeadLocked = false

			repeat task.wait()
			until Player.Character:GetAttribute("Power_State") == "Animation"

			if Player.Character:GetAttribute("Power_State") == "Animation" then -- This is In-case the idiot using this character soft-locks --
				if Tracks.Sprint.IsPlaying then
					Tracks.Sprint:Stop()
				end

				modules.Camera.Sensitivity.Modification = nil

				Character.Humanoid:Move(Vector3.new(0,0,0), true) -- force us to have foward movement

				actionList.PreventHeadTilt = false
				modules.Camera.Camera.HeadLocked = false

				finalize()
			end
		elseif Player.Character:GetAttribute("Power_State") == "Charging_Up" then
			
			remoteList.Server:FireServer("Chainsaw", "Stop_Saw") --Fire to start state changes

			actionList.PreventHeadTilt = false
			modules.Camera.Camera.HeadLocked = false

			repeat task.wait()
			until Player.Character:GetAttribute("Power_State") == "Charging_Down" or Player.Character:GetAttribute("Power_State") == "Animation"

			if Player.Character:GetAttribute("Power_State") == "Animation" then -- This is In-case the idiot using this character soft-locks --
				if Tracks.Sprint.IsPlaying then
					Tracks.Sprint:Stop()
				end

				modules.Camera.Sensitivity.Modification = nil

				Character.Humanoid:Move(Vector3.new(0,0,0), true) -- force us to have foward movement

				actionList.PreventHeadTilt = true
				modules.Camera.Camera.HeadLocked = true

				local A_Length = if Tracks.Stop.Length < 0.1 then 3 else Tracks.Stop.Length

				Character.Humanoid.WalkSpeed = Killer_Module.Speeds.Stagger
				Action.ActionInfo.Base_Controls:Enable()

				remoteList.ObjectUpdater:FireServer(Raw_Saw:WaitForChild('Handle'):WaitForChild('Stop'), 'TimePosition', 0)
				remoteList.ObjectUpdater:FireServer(Raw_Saw:WaitForChild('Handle'):WaitForChild('Stop'), 'Playing', false)

				Tracks.Stop:Play()
				Tracks.Stop:AdjustSpeed(A_Length/Killer_Module.Animation_Timing.None)
				Tracks.Stop.Stopped:Wait()

				actionList.PreventHeadTilt = false
				modules.Camera.Camera.HeadLocked = false

				finalize()
			end
		else
			error('DID NOT GET EITHER BUGGED LANE!')
			--finalize()
		end
	end

	local function beginpower() -- Begin Charging
		
		Action.ActionInfo.Connections.Power_State:Disconnect() -- remove doing animation when it's not our turn and do not force overload of signals
		Action.ActionInfo.Connections.Power_State = nil -- remove variables do not force overuse of memory/ram
		
		if Action.ActionInfo.Connections.Charge then
			Character.Humanoid.WalkSpeed = Killer_Module.Speeds.Charging
			Action.ActionInfo.Connections.Charge:Disconnect()
		end

		local Current_Speed, Hit_List, Start_Time = Killer_Module.Speeds.Sprinting, {Character}, workspace:GetServerTimeNow()
		local Sprint_Cam_Settings, Flick_Cam_Settings = {
			Multiplier = Killer_Module.Camera.Sprint.Sensitivity;
			Clamp = Killer_Module.Camera.Sprint.Limits;
		},{
			Multiplier = Killer_Module.Camera.Flick.Sensitivity;
			Clamp = Killer_Module.Camera.Flick.Limits;
		}

		modules.Camera.Sensitivity.Modification = Flick_Cam_Settings

		modules.UI:Progress() -- disable rev progress
		Action.ActionInfo.Base_Controls:Disable() -- no movement

		if Tracks.Rev.IsPlaying then
			Tracks.Rev:Stop()
		end

		Tracks.Sprint:Play() -- Play Charging Animations
		

		remoteList.ObjectUpdater:FireServer(Raw_Saw:WaitForChild('Handle'):WaitForChild('Rev'), 'Playing', false)
		remoteList.ObjectUpdater:FireServer(Raw_Saw:WaitForChild('Handle'):WaitForChild('Sprint'), 'Playing', true)

		Action.ActionInfo.Connections.Charge = game["Run Service"].Heartbeat:Connect(function(step)
			Character.Humanoid:Move(Vector3.new(0,0,-1), true) -- force us to have foward movement
			Character.Humanoid.WalkSpeed = Current_Speed
			--Tracks.Dash:AdjustSpeed(Character.Humanoid.WalkSpeed/18)
			local T = 0.65

			if Killer_Module.Chainsaw_Settings.Flick then
				T = Killer_Module.Chainsaw_Settings.Flick 
			else
				print("No Flick Time")
			end
			if (workspace:GetServerTimeNow() - Start_Time) >= T then
				modules.Camera.Sensitivity.Modification = Sprint_Cam_Settings
			end

			-- Do Client Hit Detection Here or Stuff --
			if Killer_Module.Hitbox.Hit.Radius > 0 then
				local ray_cast, object_cast = Hit_Module:Cast(Hit_List, Killer_Module.Hitbox.Hit), Hit_Module:Cast(Hit_List, Killer_Module.Hitbox.Crash)

				if object_cast then -- prioritize messing up
					local typeofhit : "Player" | "Ignore"  | "Breakable" | "Object" | nil, source : Instance = Hit_Module:Type(object_cast, Killer_Module.Hitbox.Crash, false)

					--warn(typeofhit)

					if typeofhit == "Player" then
						Final_Hit = typeofhit
						remoteList.Server:FireServer("Chainsaw", "Hit_Object", source) --Fire to start state changes
						disconnect()
					elseif typeofhit == "Breakable" then
						Final_Hit = typeofhit
						remoteList.Server:FireServer("Chainsaw", "Hit_Object", source) --Fire to start state changes
						disconnect()
					elseif typeofhit == "Object" then

						if 1 == 1 then -- ran out of hit immunity
							Final_Hit = typeofhit
							disconnect()
						else
							-- start immunity timer, but do not ignore object
						end
					elseif typeofhit == "Ignore" then
						table.insert(Hit_List, source)
					end
				elseif ray_cast then
					local typeofhit : "Player" | "Ignore" | "Breakable" | "Object" | nil, source : Instance = Hit_Module:Type(ray_cast, Killer_Module.Hitbox.Hit)

					-- only listens for hitting objects --

					if typeofhit == "Player" then
						Final_Hit = typeofhit
						remoteList.Server:FireServer("Chainsaw", "Hit_Object", source) --Fire to start state changes
						disconnect()
					elseif typeofhit == "Breakable" then
						Final_Hit = typeofhit
						remoteList.Server:FireServer("Chainsaw", "Hit_Object", source) --Fire to start state changes
						disconnect()
					elseif typeofhit == "Ignore" then
						table.insert(Hit_List, source)
					end
				end
			end
		end)
		task.wait(0.1)
		if Tracks.Stop.IsPlaying then
			task.wait()actionList.PreventHeadTilt = false
			modules.Camera.Camera.HeadLocked = false
			Character.Chainsaw.Handle.Sprint:Stop()
			finalize()
		end
	end

	if Action.ActionInfo.Connections.Power_State then
		Action.ActionInfo.Connections.Power_State:Disconnect()
	end

	remoteList.Server:FireServer("Chainsaw", "Start_Saw") --Fire to start revving

	-- Track Rev Progress --
	modules.UI:Progress({ -- binds our progress
		raw = Player.Character;
		Value = "Power"
	}, 'REVVING')

	Tracks.Rev:Play()
	remoteList.ObjectUpdater:FireServer(Raw_Saw:WaitForChild('Handle'):WaitForChild('Rev'), 'Playing', true)

	repeat task.wait()
	until Player.Character:GetAttribute("Power_State") == "Charging_Up"

	Action.ActionInfo.Disconnect = disconnect

	Action.ActionInfo.Connections.Stunned = currentValues.Stunned:GetPropertyChangedSignal("Value"):Connect(function()

		if currentValues.Stunned.Value then
			disconnect(true)
		end
	end)

	Action.ActionInfo.Connections.Power_State = Player.Character:GetAttributeChangedSignal('Power_State'):Connect(function()

		if Player.Character:GetAttribute("Power_State") == "Using" then
			beginpower()
		elseif Player.Character:GetAttribute("Power_State") == "Idle" then
			finalize()
		end
	end)
end

function Action:Stop(...)
	if not Action.ActionInfo.Disconnect then return --[[warn('Anti-Spam Exit')]] end

	Action.ActionInfo.Disconnect()
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
