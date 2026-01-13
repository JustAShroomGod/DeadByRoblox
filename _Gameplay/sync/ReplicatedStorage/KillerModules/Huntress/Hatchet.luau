local Player = game.Players.LocalPlayer
local Killer_Module = require(game:GetService("ReplicatedStorage"):WaitForChild("Game_Data"):WaitForChild("Killers"):WaitForChild("Huntress"))

local DefaultPriority = 3

local Action = {
	Key = "Interact3";
	ActionName = "AIM HATCHET";
	Priority = 3; -- scale of 1-5
	InteractDistance = 6.5;
	ActionInfo = {},
	Connections = {};
	Debounces = {
		InputEnter = workspace:GetServerTimeNow();
		Deploying = false;
		Exiting = false;
	}
}

local Tracks = {};

signal = {}
var = {
	cg_time = 1/2
	,min_charge = 1/6
}

local obs = require(script:WaitForChild("HiddenHatchetModule"))

local V = Instance.new("Animation", script)
V.AnimationId = "rbxassetid://85010073126920"
V.Name = "LetGoAnim"

coroutine.resume(coroutine.create(function()
	game:GetService("ContentProvider"):PreloadAsync({V})
end))

function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList

	local Power_State = Player.Character:GetAttribute("Power_State")
	local Hatchet_Count = Player.Character:GetAttribute("Hatchet_Count")

	if not Power_State or not Hatchet_Count then return false end

	if not Killer_Module.Client_Power_Boot and Killer_Module.Power_Client then -- Used to make trapping variables global across power modules
		Killer_Module.Client_Power_Boot = true
		Killer_Module:Power_Client(game.Players.LocalPlayer)
	end

	if currentValues.KillerAction.Value == "Nothing" -- doing nothing
		and not Player.Character:GetAttribute("Swing") -- not swinging currently
		and Hatchet_Count > 0
		and Power_State == "Idle"
		and (currentValues.Parent:WaitForChild("BLOODPOINT"):FindFirstChild("REMOVE") ~= nil)
		and not actionList.BasicAttack.Prevent
		and not Player.Character:GetAttribute("Carry") then -- if already revving bypass all of it

		CanRun = true
	elseif Action.Debounces.Deploying then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (workspace:GetServerTimeNow() - Action.Debounces.InputEnter) < 0.25 or Action.Debounces.Deploying  then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = workspace:GetServerTimeNow()
	Action.Debounces.Deploying = true

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Info = actionList.KillerInfo
	local Character = Player.Character

	modules.UI:Hide(true)
	actionList.BasicAttack.Prevent = true

	local Connections = {}

	if not Tracks.Hold then
		Tracks.Hold = Character:WaitForChild('Humanoid'):LoadAnimation(game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Huntress'):WaitForChild('Hold'))
	end

	if not Tracks.LetGo then
		Tracks.LetGo = Character:WaitForChild("Humanoid"):LoadAnimation(V)
	end

	local function Disconnect(force)
		if force then else if not Tracks.Hold.IsPlaying then repeat task.wait() until Tracks.Hold.IsPlaying end end
		if Action.ActionInfo.Disconnect then Action.ActionInfo.Disconnect = nil end
		if Connections.Cancel then Connections.Cancel:Disconnect() Connections.Cancel = nil end
		if Connections.Stunned then Connections.Stunned:Disconnect() Connections.Stunned = nil end
		if Connections.Change then Connections.Change:Disconnect() Connections.Change = nil end
		if Connections.RunCon then Connections.RunCon:Disconnect() Connections.RunCon = nil end
		script.Parent:WaitForChild("CancelHatchet"):WaitForChild("Value").Value = false
		var.maxcharge_tick = tick()

		if force then
			Tracks.Hold:Stop()
			Tracks.LetGo:Play()
			repeat task.wait() until Tracks.LetGo.IsPlaying == false
			task.wait(0.15)
			remoteList.Server:FireServer("Hatchet", 'Cancel_Aim')
		else

			local x = var.min_charge
			local dif = var.cg_time-var.min_charge

			local alpha = math.clamp(var.maxcharge_tick-var.charge_tick, 0, var.cg_time)/var.cg_time
			local charge = var.min_charge+alpha*dif

			local cf = {
				start = Character.Humanoid.Torso.CFrame*CFrame.new(0, 1.1, -1)
				,start_cam = workspace.CurrentCamera.CFrame*CFrame.new(0, 0.1, -10)
			}

			charge *= Killer_Module.SpeedBoost

			local my_tick = workspace.DistributedGameTime
			coroutine.resume(coroutine.create(function()
				remoteList.Server:FireServer("Hatchet", 'Stop_Aim', false, workspace.CurrentCamera.CFrame)
			end))
			obs.run(charge, cf, my_tick)
			game.ReplicatedStorage:WaitForChild("-LockerAuras"):WaitForChild("HuntressPowerAction"):FireServer(charge, cf, my_tick)
		end

		if Action.Connections.Aim and Action.Connections.Aim.IsPlaying then Action.Connections.Aim:Stop() end -- stop the start aim track --
		Tracks.Hold:Stop() -- stop the aiming track

		repeat task.wait()
		until currentValues.KillerAction.Value == "Nothing"

		--print('action got to nothing')

		if Action.Connections.Animation then Action.Connections.Animation:Disconnect() Action.Connections.Animation = nil end

		actionList.BasicAttack.Prevent = false
		Action.Debounces.Deploying = false
		Action.Priority = DefaultPriority
		modules.UI:Hide(false)
	end

	if Action.Connections.Animation then Action.Connections.Animation:Disconnect() Action.Connections.Animation = nil end

	Action.Connections.Animation = Character:GetAttributeChangedSignal("Animation"):Connect(function()
		local Animation = Character:GetAttribute("Animation")

		if Animation and Animation ~= "" and game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Huntress'):FindFirstChild(Animation) then

			if not Action.Connections[Animation] then -- build and store animation
				Action.Connections[Animation] = Player.Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Huntress'):FindFirstChild(Animation))
			end

			local A_Length = if Action.Connections[Animation].Length < 0.1 then 10 else Action.Connections[Animation].Length
			local True_Length : number = 0 - (workspace:GetServerTimeNow() - Character:GetAttribute("Animation_Time"))

			if Animation == "Aim" then -- pre animation
				Action.ActionInfo.Disconnect = Disconnect

				Connections.Cancel = script.Parent:WaitForChild("CancelHatchet"):WaitForChild("Value").Changed:Connect(function()
--					print(script.Parent:WaitForChild("CancelHatchet"):WaitForChild("Value").Value)
					if script.Parent:WaitForChild("CancelHatchet"):WaitForChild("Value").Value == false then
						Disconnect(true)
					end
				end)

				Connections.Change = currentValues.KillerAction.Changed:Connect(function()

					if currentValues.KillerAction.Value == "Nothing" then
						Disconnect()
					end
				end)

				-- if we get stunned disconnect us
				Connections.Stunned = currentValues.KillerAction.Changed:Connect(function()

					if currentValues.KillerAction.Value == 'Stun' then
						--print('got stunned')
						Disconnect(true)
					end
				end)
			end

			Action.Connections[Animation]:Play() -- play animation
			Action.Connections[Animation]:AdjustSpeed(A_Length/(True_Length+0.5)) -- both animations should end at same time/sync
			Action.Connections[Animation].Stopped:Wait() -- wait for finish

			if Animation == "Aim" then -- post animation
				var.charge_tick = tick()
				script.Parent:WaitForChild("CancelHatchet"):WaitForChild("Value").Value = true
				--print("turn true")
				Tracks.Hold:Play() -- play the aiming track
				coroutine.resume(coroutine.create(function()
					local v = function()
						if Connections.RunCon then Connections.RunCon:Disconnect() Connections.RunCon = nil end
					end

					Connections.RunCon = game:GetService("RunService").RenderStepped:Connect(function()
						local time = tick()-var.charge_tick

						if time <= var.cg_time then return end
						game.ReplicatedStorage:WaitForChild("-LockerAuras"):WaitForChild("HatchetSoundEvent"):FireServer("Max")
						v()
					end)
				end))
			end
		end
	end)

	remoteList.Server:FireServer("Hatchet", 'Start_Aim')
end

function Action:Stop(...)
	if not Action.ActionInfo.Disconnect or Action.Debounces.Exiting then return warn('Anti-Spam Exit') end
	Action.Debounces.Exiting = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList

	if (currentValues.KillerAction.Value ~= "Aiming_Hatchet" and currentValues.KillerAction.Value ~= "Charging_Hatchet") then
		repeat task.wait()
		until (currentValues.KillerAction.Value ~= "Aiming_Hatchet" and currentValues.KillerAction.Value ~= "Charging_Hatchet")
	end

	Action.ActionInfo.Disconnect()
	Action.ActionInfo.Disconnect = nil

	Action.Debounces.Exiting = false
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