local Player = game.Players.LocalPlayer

local ReplicatedStorage : ReplicatedStorage = game:GetService("ReplicatedStorage")

local game_data = ReplicatedStorage:WaitForChild('Game_Data')
local Killer_Module = require(game_data:WaitForChild('Killers'):WaitForChild('Architect'))

local Animations = ReplicatedStorage:WaitForChild("Game_Assets"):WaitForChild("Animations"):WaitForChild("Architect")

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
	local Power_State = Player.Character:GetAttribute("Power_State")

	if not Power or not Power_State then return false end
	Power = string.split(Power, ':')

	if not Killer_Module.Client_Power_Boot and Killer_Module.Power_Client then
		Killer_Module.Client_Power_Boot = true -- booted values from client side
		Killer_Module:Power_Client(game.Players.LocalPlayer)
	end

	if currentValues.KillerAction.Value == "Nothing" and currentValues.Action.Value == "Nothing"
		and not Player.Character:GetAttribute("Carry") -- not allowed while carrying
		and (Power_State == "Idle" or Power_State == "Using" or Power_State == "PowerUsage")-- current not using power or in animation
		and tonumber(Power[1]) >= (tonumber(Power[2]) * Killer_Module.Min_rage)-- at max capacity to start using power
		and not Player.Character:GetAttribute("Swing") -- not swinging currently
		and Action.ActionInfo.POWER_BUTTON == "UP" -- power button not held
		and not actionList.BasicAttack.Prevent
		and (currentValues.Parent:WaitForChild("BLOODPOINT"):FindFirstChild("REMOVE") ~= nil)
		and currentValues.Stunned.Value == false then

		CanRun = true
	elseif Action.Debounces.InProgress then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 2 or Action.Debounces.InProgress then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	actionList.BasicAttack.Prevent = true
	modules.UI:Hide(true)
	modules.UI:ChangeName(Action.ActionName, "End Charge")

	Action.ActionInfo.POWER_BUTTON = "DOWN"

	if not Tracks.BreakObject then
		Tracks.BreakObject = Character:WaitForChild('Humanoid'):LoadAnimation(Animations:WaitForChild('BreakObject'))
	end

	if not Tracks.PlayerHit then
		Tracks.PlayerHit = Character:WaitForChild('Humanoid'):LoadAnimation(Animations:WaitForChild('HitPlayer'))
	end

	if not Tracks.Dash then
		Tracks.Dash = Character:WaitForChild('Humanoid'):LoadAnimation(Animations:WaitForChild('Dash'))
	end

	local function finalize() : "Finish disconnect sequence"
		Action.Priority = DefaultPriority
		modules.UI:Hide(false)
		modules.UI:ChangeName(Action.ActionName, "Charge")
		actionList.MovementScript:Enable()

		actionList.BasicAttack.Prevent = false
		Action.Debounces.InProgress = false
	end

	local function disconnect()
		if Action.ActionInfo.POWER_BUTTON == "UP" then return end
		if Action.ActionInfo.Disconnect then Action.ActionInfo.Disconnect = nil end
		if Action.ActionInfo.Connections.Animation then Action.ActionInfo.Connections.Animation:Disconnect() Action.ActionInfo.Connections.Animation = nil end
		if Action.ActionInfo.Connections.Charge then Action.ActionInfo.Connections.Charge:Disconnect() Action.ActionInfo.Connections.Charge = nil end
		if Action.ActionInfo.Connections.Stun then Action.ActionInfo.Connections.Stun:Disconnect() Action.ActionInfo.Connections.Stun = nil end
		if Tracks.Dash.IsPlaying then Tracks.Dash:Stop() end
		if Tracks.PlayerHit.IsPlaying then Tracks.PlayerHit:Stop() end
		if Tracks.BreakObject.IsPlaying then Tracks.BreakObject:Stop() end

		Action.ActionInfo.POWER_BUTTON = "UP"

		if Player.Character:GetAttribute("Power_State") == "PowerUsage" then
			remoteList.Server:FireServer("Rage", "End_Rage") --Fire to start state changes

			if Action.ActionInfo.Connections.Animation then
				Action.ActionInfo.Connections.Animation:Disconnect()
			end

			modules.Camera.Sensitivity.Modification = nil
			Character.Humanoid:Move(Vector3.new(0,0,0), true) -- force us to have foward movement
			Character.Humanoid.WalkSpeed = modules.Code.Speeds.Global_Settings.Base_Speed * (1 + modules.Code:GetSpeed("Movement"))

			actionList.PreventHeadTilt = true
			modules.Camera.Camera.HeadLocked = true
			modules.UI:Hide(true)


			Action.ActionInfo.Connections.Animation = Character:GetAttributeChangedSignal("Animation"):Connect(function()
				local Animation = Character:GetAttribute("Animation")

				if Animation and Animation ~= "" and Animations:FindFirstChild(Animation) then
					Action.ActionInfo.Connections.Animation:Disconnect() -- remove doing animation when it's not our turn and do not force overload of signals
					Action.ActionInfo.Connections.Animation = nil -- remove variables do not force overuse of memory/ram

					if not Action.ActionInfo.Connections[Animation] then -- build and store animation
						Action.ActionInfo.Connections[Animation] = Player.Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(Animations:FindFirstChild(Animation))
					end

					local A_Length = if Action.ActionInfo.Connections[Animation].Length < 0.1 then 10 else Action.ActionInfo.Connections[Animation].Length
					local True_Length : number = 0 - (workspace:GetServerTimeNow() - Character:GetAttribute("Animation_Time"))

					Action.ActionInfo.Connections[Animation]:Play() -- play animation
					Action.ActionInfo.Connections[Animation]:AdjustSpeed(A_Length/True_Length) -- both animations should end at same time/sync
					Action.ActionInfo.Connections[Animation].Stopped:Wait() -- wait for finish

					actionList.PreventHeadTilt = false
					modules.Camera.Camera.HeadLocked = false
					actionList.MovementScript:Enable()
					finalize()
				end
			end)
		else
			finalize()
		end
	end

	local function beginpower()
		Action.ActionInfo.Connections.Animation:Disconnect() -- remove doing animation when it's not our turn and do not force overload of signals
		Action.ActionInfo.Connections.Animation = nil -- remove variables do not force overuse of memory/ram

		if Action.ActionInfo.Connections.Charge then
			Action.ActionInfo.Connections.Charge:Disconnect()
		end

		if Action.ActionInfo.Connections.Stun then
			Action.ActionInfo.Connections.Stun:Disconnect()
		end

		local Current_Speed, Hit_List = Killer_Module.Rage_Speeds.Base, {Character}
		local Sens, Clamp = (Killer_Module.Camera.Sensitivity), (Killer_Module.Camera.Limits)

		if modules.Data:GetAddon("Killer", nil, "Lighter Sledge") then
			Sens += Vector2.new(Sens.X * require(game_data:WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild('Lighter Sledge')).Turn_Increase, 0)
			Clamp += Vector2.new(Clamp.X * require(game_data:WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild('Lighter Sledge')).Turn_Increase, 0)
		end

		modules.Camera.Sensitivity.Modification = {
			Multiplier = Sens;
			Clamp = Clamp;
		}

		Tracks.Dash:Play()
		Tracks.Dash.Priority = Enum.AnimationPriority.Action3

		actionList.PreventHeadTilt = false
		modules.Camera.Camera.HeadLocked = false
		modules.UI:Hide(false)


		Action.ActionInfo.Connections.Charge = game["Run Service"].Heartbeat:Connect(function(step)
			if currentValues.Stunned.Value  == true then return end
			Character.Humanoid:Move(Vector3.new(0,0,-1), true) -- force us to have foward movement
			Character.Humanoid.WalkSpeed = Current_Speed
			Tracks.Dash:AdjustSpeed(Character.Humanoid.WalkSpeed/18)
			-- Do Client Hit Detection Here or Stuff --
			local ray_cast = Hit_Module:Cast(Hit_List)

			if ray_cast then 
				local typeofhit : "Player" | "Breakable" | "Object" | nil, source : Instance = Hit_Module:Type(ray_cast)

				if typeofhit == "Player" then
					remoteList.Server:FireServer("Rage", "Hit_Object", source) --Fire to start state changes
					table.insert(Hit_List, source)
					task.spawn(function()
						Tracks.PlayerHit:Play()
						Tracks.PlayerHit.Priority = Enum.AnimationPriority.Action4


						local TimeTicked = 0
						while task.wait(1) do
							if TimeTicked == 10 then
								for i, b in pairs(Hit_List) do
									if Hit_List[i] == source then
										table.remove(Hit_List,i)
									end
								end
								break
							else
								TimeTicked += 1
								if Tracks.Dash and Tracks.Dash.IsPlaying then
								else
									break
								end
							end
						end
					end)
				elseif typeofhit == "Breakable" then
					Tracks.BreakObject:Play()
					Tracks.BreakObject.Priority = Enum.AnimationPriority.Action4

					remoteList.Server:FireServer("Rage", "Hit_Object", source) --Fire to start state changes
					Current_Speed += Killer_Module.Rage_Speeds.Gain
					table.insert(Hit_List, source)
				elseif typeofhit == "Object" then
					table.insert(Hit_List, source) -- ADD TO IGNORES
				end
			end

			-- Early Ending --
			local rage_progress = string.split(Character:GetAttribute("Power"), ':')

			if tonumber(rage_progress[1]) <= 0 then
				disconnect()
			end
		end)

		Action.ActionInfo.Disconnect = disconnect -- allow us to m2 off now
	end

	if Action.ActionInfo.Connections.Animation then
		Action.ActionInfo.Connections.Animation:Disconnect()
	end

	actionList.MovementScript:Disable()
	actionList.PreventHeadTilt = true
	modules.Camera.Camera.HeadLocked = true

	remoteList.Server:FireServer("Rage", "Start_Rage") --Fire to start state changes

	Action.ActionInfo.Connections.Animation = Character:GetAttributeChangedSignal("Animation"):Connect(function()
		local Animation = Character:GetAttribute("Animation")

		if Animation and Animation ~= "" and Animations:FindFirstChild(Animation) then

			if not Action.ActionInfo.Connections[Animation] then -- build and store animation
				Action.ActionInfo.Connections[Animation] = Player.Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(Animations:FindFirstChild(Animation))
			end

			local A_Length = if Action.ActionInfo.Connections[Animation].Length < 0.1 then 10 else Action.ActionInfo.Connections[Animation].Length
			local True_Length : number = 0 - (workspace:GetServerTimeNow() - Character:GetAttribute("Animation_Time"))

			Action.ActionInfo.Connections[Animation]:Play() -- play animation
			Action.ActionInfo.Connections[Animation]:AdjustSpeed(A_Length/True_Length) -- both animations should end at same time/sync
			Action.ActionInfo.Connections[Animation].Stopped:Wait() -- wait for finish

			print(Animation)

			if Animation == "Wind" then
				beginpower()
			end
		end
	end)

	Action.ActionInfo.Connections.Stun = currentValues.Stunned:GetPropertyChangedSignal("Value"):Connect(function()
		if currentValues.Stunned.Value then
			--disconnect()
			--warn("STUNNED!")
		end
	end)
end

function Action:Stop(...)
	if not Action.ActionInfo.Disconnect then return warn('Anti-Spam Exit') end

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