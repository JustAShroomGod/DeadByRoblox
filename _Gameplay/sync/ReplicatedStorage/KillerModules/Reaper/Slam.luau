local Player = game.Players.LocalPlayer
local DefaultPriority = 3

local Killer_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild('Reaper'))

local Action = {
	Key = "Interact3";
	ActionName = "Slam";
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

function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	
	local Charges = Player.Character:GetAttribute("Power")
	
	if not Charges then return false end
	Charges = string.split(Charges, ':')
	
	if not Killer_Module.Client_Power_Boot and Killer_Module.Power_Client then
		Killer_Module.Client_Power_Boot = true -- booted values from client side
		Killer_Module:Power_Client(game.Players.LocalPlayer)
	end
	
	if currentValues.KillerAction.Value == "Nothing"
		and not Player.Character:GetAttribute("Swing")
		and (currentValues.Parent:WaitForChild("BLOODPOINT"):FindFirstChild("REMOVE") ~= nil)
		and not currentValues.Stunned.Value
		and not Player.Character:GetAttribute("Carry")
		and tonumber(Charges[1]) > 0 then
		
		CanRun = true
	elseif Action.Debounces.Deploying then -- if in progress do not let go of this interaction
		
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1 or Action.Debounces.Deploying then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Deploying = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	modules.UI:Hide(true)
	
	actionList.PreventHeadTilt = true
	modules.Camera.Camera.HeadLocked = true
	
	local function Disconnect(finished : boolean)
		if Action.ActionInfo.Disconnect then Action.ActionInfo.Disconnect = nil end
		if Action.ActionInfo.Change then Action.ActionInfo.Change:Disconnect() Action.ActionInfo.Change = nil end
		if Action.ActionInfo.Stunned then Action.ActionInfo.Stunned:Disconnect() Action.ActionInfo.Stunned = nil end

		if finished then -- ACTUAL SLAM CODE --
			remoteList.Server:FireServer("Slam", 'Finish_Slam')
		else
			remoteList.Server:FireServer("Slam", 'Cancel_Slam')
		end

		repeat task.wait()
		until currentValues.KillerAction.Value == "Nothing"

		if Action.ActionInfo.Connections.Animation then Action.ActionInfo.Connections.Animation:Disconnect() Action.ActionInfo.Connections.Animation = nil end

		actionList.PreventHeadTilt = false
		modules.Camera.Camera.HeadLocked = false
		
		Action.Debounces.Exiting = false
		Action.Debounces.Deploying = false
		Action.Priority = DefaultPriority
		
		modules.UI:Hide(false)
	end
	
	if Action.ActionInfo.Connections.Animation then Action.ActionInfo.Connections.Animation:Disconnect() Action.ActionInfo.Connections.Animation = nil end

	Action.ActionInfo.Connections.Animation = Character:GetAttributeChangedSignal("Animation"):Connect(function()
		local Animation = Character:GetAttribute("Animation")

		warn(Animation)

		if Animation and Animation ~= "" and game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Reaper'):FindFirstChild(Animation) then
			print('Found', Animation)

			if not Action.ActionInfo.Connections[Animation] then -- build and store animation
				Action.ActionInfo.Connections[Animation] = Player.Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Reaper'):FindFirstChild(Animation))
			end

			local A_Length = if Action.ActionInfo.Connections[Animation].Length < 0.1 then 10 else Action.ActionInfo.Connections[Animation].Length
			local True_Length : number = 0 - (workspace:GetServerTimeNow() - Character:GetAttribute("Animation_Time"))

			print('Playing:', True_Length)

			Action.ActionInfo.Connections[Animation]:Play() -- play animation
			Action.ActionInfo.Connections[Animation]:AdjustSpeed(A_Length/True_Length) -- both animations should end at same time/sync
			
			if Animation == "Slam" then

				Action.ActionInfo.Change = currentValues.KillerAction.Changed:Connect(function()

					if currentValues.KillerAction.Value == "Nothing" then
						Disconnect()
					end
				end)

				-- if we get stunned disconnect us
				Action.ActionInfo.Stunned = currentValues.KillerAction.Changed:Connect(function()

					if currentValues.KillerAction.Value == 'Stun' then
						Disconnect()
					end
				end)

				Action.ActionInfo.Disconnect = Disconnect
			end
			
			Action.ActionInfo.Connections[Animation].Stopped:Wait() -- wait for finish

			print(Animation)

			if Animation == "Slam" then
				Disconnect(true)
			end
		end
	end)
	
	remoteList.Server:FireServer("Slam", "Start_Slam")
end

function Action:Stop(...)
	if not Action.ActionInfo.Disconnect or Action.Debounces.Exiting then return warn('Anti-Spam Exit') end
	--[[Action.Debounces.Exiting = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	
	if currentValues.KillerAction.Value ~= "Slamming" then
		repeat task.wait()
		until currentValues.KillerAction.Value == "Slamming"
	end
	
	Action.ActionInfo.Disconnect()
	Action.ActionInfo.Disconnect = nil]]--
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
