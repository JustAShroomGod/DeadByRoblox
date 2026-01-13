local Players : Players, RunService = game:GetService("Players"), game:GetService("RunService")

local Player = Players.LocalPlayer
local Killer_Module = require(game:GetService("ReplicatedStorage"):WaitForChild("Game_Data"):WaitForChild("Killers"):WaitForChild("Nurse"))

local DefaultPriority = 3

local Action = {
	Key = "Interact3";
	ActionName = "BLINK";
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

function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList

	local Power_State = Player.Character:GetAttribute("Power_State")
	local Blink_Count = Player.Character:GetAttribute("Blink_Count")

	if not Power_State or not Blink_Count then return false end

	if not Killer_Module.Client_Power_Boot and Killer_Module.Power_Client then -- Used to make trapping variables global across power modules
		Killer_Module.Client_Power_Boot = true
		Killer_Module:Power_Client(game.Players.LocalPlayer)
	end

	if currentValues.KillerAction.Value == "Nothing" -- doing nothing
		and not Player.Character:GetAttribute("Swing") -- not swinging currently
		and Blink_Count > 0
		and Power_State == "Idle" 
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
	if (workspace:GetServerTimeNow() - Action.Debounces.InputEnter) < 0.25 or Action.Debounces.Deploying  then return warn("Anti-Spam") end
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

	if not Tracks.Charge then
		Tracks.Charge = Character:WaitForChild('Humanoid'):LoadAnimation(game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Nurse'):WaitForChild('Charge'))
		Tracks.Hold = Character:WaitForChild('Humanoid'):LoadAnimation(game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Nurse'):WaitForChild('Hold'))
	end

	local function Disconnect(force)
		if Action.ActionInfo.Disconnect then Action.ActionInfo.Disconnect = nil end
		if Connections.Stunned then Connections.Stunned:Disconnect() Connections.Stunned = nil end
		if Connections.Change then Connections.Change:Disconnect() Connections.Change = nil end
		--if Action.Connections.Chain_Window then Action.Connections.Chain_Window:Disconnect() end
		
		--warn('here')

		if force then
			--print('send to cancel')
			remoteList.Server:FireServer("Blink", 'Stop_Charge', false)
		else
			remoteList.Server:FireServer("Blink", 'Stop_Charge', true)
		end

		if Action.Connections.Charge and Action.Connections.Charge.IsPlaying then Action.Connections.Charge:Stop() end -- stop the start charge track --
		Tracks.Charge:Stop() -- stop the charging track

		if Tracks.Hold.IsPlaying then Tracks.Hold:Stop() end

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

		if Animation and Animation ~= "" and game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Nurse'):FindFirstChild(Animation) then

			if not Action.Connections[Animation] then -- build and store animation
				Action.Connections[Animation] = Player.Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Nurse'):FindFirstChild(Animation))
			end

			local A_Length = if Action.Connections[Animation].Length < 0.1 then 10 else Action.Connections[Animation].Length
			local True_Length : number = 0 - (workspace:GetServerTimeNow() - Character:GetAttribute("Animation_Time"))

			if Animation == "Charge" then -- pre animation
				Action.ActionInfo.Disconnect = Disconnect

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
				
				
				if not Action.Connections.Chain_Window then
					Action.Connections.Chain_Window = Character:GetAttributeChangedSignal("Power"):Connect(function()
						if Character:GetAttribute("Power_State") == "Chain_Window" then
							local current_power = string.split(Player.Character:GetAttribute("Power"), ':')

							if current_power[1] >= current_power[2] then
								if Character:GetAttribute("Power_State") ~= "Chain_Window" then
									if Action.Connections.Chain_Window then Action.Connections.Chain_Window:Disconnect() end
								else
									Disconnect(true)
								end 
							end
						end
					end)
				end
			end

			Action.Connections[Animation]:Play() -- play animation
			Action.Connections[Animation]:AdjustSpeed(A_Length/True_Length) -- both animations should end at same time/sync
			Action.Connections[Animation].Stopped:Wait() -- wait for finish

			if Animation == "Charge" then -- post animation
				if Action.Connections.Charge and Action.Connections.Charge.IsPlaying then Action.Connections.Charge:Stop() end -- stop the start charge track --
			
				Tracks.Charge:Stop()
				
				Tracks.Hold:Play() -- play the aiming track
			end
		end
	end)

	remoteList.Server:FireServer("Blink", 'Start_Charge')
end

function Action:Stop(...)
	if not Action.ActionInfo.Disconnect or Action.Debounces.Exiting then return warn('Anti-Spam Exit') end
	Action.Debounces.Exiting = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList

	if currentValues.KillerAction.Value ~= "Charging_Blink" then
		repeat task.wait()
		until currentValues.KillerAction.Value ~= "Charging_Blink"
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
