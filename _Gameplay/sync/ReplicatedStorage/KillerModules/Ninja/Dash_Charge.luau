local Player = game.Players.LocalPlayer
local DefaultPriority = 3
local CooldownValue = false
local game_data = game.ReplicatedStorage:WaitForChild('Game_Data')
local Killer_Module = require(game_data:WaitForChild('Killers'):WaitForChild('Ninja'))


local Action = {
	Key = "Interact3";
	ActionName = "Dash";
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		Connections = {};
	},
	Debounces = {
		InputEnter = tick();
		Deploying = false;
		Exiting = false;
	}
}

local Tracks = {}
local Hit_Module = require(script:WaitForChild('Hit_Dection'))
local ShouldVisualize = nil

function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList

	local Power_State = Player.Character:GetAttribute("Power_State")

	local LastSwing = (Player.Character:GetAttribute("SwingEnd") or 0)

	if not Power_State then return false end

	if not Killer_Module.Client_Power_Boot and Killer_Module.Power_Client then
		Killer_Module.Client_Power_Boot = true -- booted values from client side
		Killer_Module:Power_Client(game.Players.LocalPlayer)
	end

	if currentValues.KillerAction.Value == "Nothing"
		and not Player.Character:GetAttribute("Swing")
		and Power_State == "Idle" -- we are idled out
		and (currentValues.Parent:WaitForChild("BLOODPOINT"):FindFirstChild("REMOVE") ~= nil)
		and not currentValues.Stunned.Value
		and not Player.Character:GetAttribute("Carry")
		and CooldownValue == false then

		CanRun = true
	elseif Action.Debounces.Deploying then -- if in progress do not let go of this interaction

		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
end

local func = nil

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1 or Action.Debounces.Deploying then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Deploying = true
	coroutine.resume(coroutine.create(function()
		if not func then
			func = script:WaitForChild("CoolDownUI").Changed:Connect(function()
				Player.Character:SetAttribute("Power", tostring(script:WaitForChild("CoolDownUI").Value)..":1000")
			end)
		end
	end))
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character, Hit_State = Player.Character, false

	modules.UI:Hide(true)

	local Connections = {}

	if not Tracks.Dash then
		Tracks.Dash = Character:WaitForChild('Humanoid'):LoadAnimation(game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Ninja'):WaitForChild('Dash'))
	end
	
	if ShouldVisualize == nil then
		ShouldVisualize = modules.Data:GetSettings().VISUALIZE_ATTACKS or false
	end

	local function Dash()
		remoteList.Server:FireServer("Swift Charge", 'Stop_Charge')

		repeat task.wait()
		until currentValues.Action.Value == "Dashing"

		Tracks.Dash:Play()
		Tracks.Aim:Stop()

		local Current_Charge = string.split(Player.Character:GetAttribute("Power"), ':')
		local Dash_Time = (Current_Charge[1] * Killer_Module.Dash_Per_Charge)

		if Dash_Time < (Killer_Module.Dash_Min_Charge * Killer_Module.Dash_Per_Charge) then
			Dash_Time = (Killer_Module.Dash_Min_Charge * Killer_Module.Dash_Per_Charge)
		end
		

		local bp, start_time = Instance.new('BodyPosition'), workspace:GetServerTimeNow()
		bp.Parent = Player.Character.PrimaryPart
		bp.MaxForce = Vector3.new(math.huge, 0, math.huge)

		-- dunno --
		--bp.D = 0
		bp.P = 50000
		---------
		local didhit = false
		local Hit_List, Object_List = {Character}, {Character}
		
		local StartTime = workspace:GetServerTimeNow()
		local Collision_IFrames = Killer_Module.Collision_IFrames
		
		Connections.Dash_Beat = game:GetService('RunService').Heartbeat:Connect(function(step)
			local Camera_Frame, Colliding = workspace.CurrentCamera.CFrame.LookVector, false

			-- Do Client Hit Detection Here or Stuff --
			local ray_cast, collision_cast = Hit_Module:Cast(Hit_List, Killer_Module.Hitboxes.Attack), Hit_Module:Cast(Object_List, Killer_Module.Hitboxes.Dash,"Attack", ShouldVisualize)

			if ray_cast then 
				local typeofhit : "Player" | "Breakable" | "Object" | nil, source : Instance = Hit_Module:Type(ray_cast, Killer_Module.Hitboxes.Attack)

				if typeofhit == "Player" then
					Hit_State = true
					Colliding = true
					remoteList.Server:FireServer("Swift Charge", 'Hit_Object', source) --Fire to start state changes
					table.insert(Hit_List, source)
					table.insert(Object_List, source)
				elseif typeofhit == "Object" then
					--Colliding = true
					table.insert(Hit_List, source) -- ADD TO IGNORES
				end
			end

			if collision_cast and (workspace:GetServerTimeNow() - StartTime) >= Collision_IFrames then
				local typeofhit : "Player" | "Breakable" | "Object" | nil, source : Instance = Hit_Module:Type(collision_cast, Killer_Module.Hitboxes.Dash,"Collision", ShouldVisualize)

				if typeofhit == "Object" then
					Colliding = true
					--table.insert(Hit_List, source) -- ADD TO IGNORES
				else
					table.isfrozen(Object_List, source)
				end
			end


			if not Colliding then
				bp.Position = (workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -Killer_Module.Speeds.Dash - (workspace:GetServerTimeNow() - start_time))).Position -->> get faster near end
			else
				bp.Position = (workspace.CurrentCamera.CFrame * CFrame.new(0, 0, 1.5)).Position -->> get super slow <<-- doesn't fullly fix fling issue, but helps
				bp:Destroy()
				didhit = true
				Connections.Dash_Beat:Disconnect()
				Player.Character.PrimaryPart.Anchored = true
			end
		end)

		--bp.Position = (Player.Character:GetPivot() * CFrame.new(0, 0, -Distance)).Position

		repeat task.wait()
		until (workspace:GetServerTimeNow() - start_time) >= Dash_Time or didhit == true

--		warn('Should have stopped')

		if Connections.Dash_Beat then
			Connections.Dash_Beat:Disconnect()
		end
		
		if bp then
			bp:Destroy()
		end
		
		Player.Character.PrimaryPart.Anchored = false
		
		remoteList.Server:FireServer("Swift Charge", 'Finished_Charge', Hit_State)

		Tracks.Dash:Stop()
	end

	local function Disconnect(stop_charge : boolean)
		if Action.ActionInfo.Disconnect then Action.ActionInfo.Disconnect = nil end
		if Connections.Change then Connections.Change:Disconnect() Connections.Change = nil end
		if Connections.Stunned then Connections.Stunned:Disconnect() Connections.Stunned = nil end

		-- Let Server Know we want to stop charging up
		if not Tracks.Dash then
			Tracks.Dash = Character:WaitForChild('Humanoid'):LoadAnimation(game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Ninja'):WaitForChild('Dash'))
		end

		if stop_charge then -- ACTUAL DASH CODE --
			Dash()
		else
			remoteList.Server:FireServer("Swift Charge", 'Cancel_Charge')
			Tracks.Aim:Stop()
		end
		--script:WaitForChild('Stalking'):Stop()

		repeat task.wait()
		until currentValues.KillerAction.Value == "Nothing"

		if Action.ActionInfo.Connections.Animation then Action.ActionInfo.Connections.Animation:Disconnect() Action.ActionInfo.Connections.Animation = nil end

		CooldownValue = true
		coroutine.resume(coroutine.create(function()
			local b = game:GetService("TweenService"):Create(script:WaitForChild("CoolDownUI"), TweenInfo.new(Killer_Module.Cool_Down_Time, Enum.EasingStyle.Linear), {Value = 1000})
			b:Play()
			task.wait(Killer_Module.Cool_Down_Time)
			b:Pause()
			script.CoolDownUI.Value = 0
			CooldownValue = false
		end))
		Action.Debounces.Exiting = false
		Action.Debounces.Deploying = false
		Action.Priority = DefaultPriority
		modules.UI:Hide(false)
	end

	if Action.ActionInfo.Connections.Animation then Action.ActionInfo.Connections.Animation:Disconnect() Action.ActionInfo.Connections.Animation = nil end

	Action.ActionInfo.Connections.Animation = Character:GetAttributeChangedSignal("Animation"):Connect(function()
		local Animation = Character:GetAttribute("Animation")

		--warn(Animation)

		if Animation and Animation ~= "" and game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Ninja'):FindFirstChild(Animation) then
			--print('Found', Animation)

			if not Action.ActionInfo.Connections[Animation] then -- build and store animation
				Action.ActionInfo.Connections[Animation] = Player.Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Ninja'):FindFirstChild(Animation))
			end

			local A_Length = if Action.ActionInfo.Connections[Animation].Length < 0.1 then 10 else Action.ActionInfo.Connections[Animation].Length
			local True_Length : number = 0 - (workspace:GetServerTimeNow() - Character:GetAttribute("Animation_Time"))

			--print('Playing:', True_Length)

			Action.ActionInfo.Connections[Animation]:Play() -- play animation
			Action.ActionInfo.Connections[Animation]:AdjustSpeed(A_Length/True_Length) -- both animations should end at same time/sync
			Action.ActionInfo.Connections[Animation].Stopped:Wait() -- wait for finish

--			print(Animation)

			if Animation == "Wind_Up" then

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

				if not Tracks.Aim then
					Tracks.Aim = Character:WaitForChild('Humanoid'):LoadAnimation(game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Ninja'):WaitForChild('Aim'))
				end

				Tracks.Aim:Play() -- play the aim track

				Action.ActionInfo.Disconnect = Disconnect
			end
		end
	end)

	remoteList.Server:FireServer("Swift Charge", 'Start_Charge')
end

function Action:Stop(...)
	if not Action.ActionInfo.Disconnect or Action.Debounces.Exiting then return warn('Anti-Spam Exit') end
	Action.Debounces.Exiting = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList

	if currentValues.KillerAction.Value ~= "Aiming" then
		repeat task.wait()
		until currentValues.KillerAction.Value == "Aiming"
	end

	Action.ActionInfo.Disconnect(true)
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