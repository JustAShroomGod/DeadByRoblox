local Player = game.Players.LocalPlayer
local DefaultPriority = 3

local Action = {
	Key = "Interact";
	ActionName = "EXIT LOCKER";
	Priority = 1; -- scale of 1-5
	ActionInfo = {
		Connections = {}
	},
	Debounces = {
		InputEnter = tick()
	},
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Hiding_Spot : Model = actionList.Hiding_Spot

	if not Hiding_Spot then return false end
	local Direction = ((Hiding_Spot:WaitForChild('RootPart').CFrame * CFrame.new(0,0,2)).Position - Player.Character:GetPivot().Position).Unit

	if currentValues.HealthState.Value > 0
		and (Hiding_Spot:GetAttribute("Hiding") == Player.Name) -- we are the one in locker
		and (not Hiding_Spot:GetAttribute("Searching") or Hiding_Spot:GetAttribute("Searching") == "")
		and not Hiding_Spot:GetAttribute("Blocked") -- not entombed/blocked in
		and not currentValues.Holded.Value
		and not currentValues.Hooked.Value
		and modules.Code:GetEffect("Hidden") then -- considers us in locker
		
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or Action.ActionInfo.UsingSpot then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	local Hiding_Spot = actionList.Hiding_Spot

	modules.UI:Hide(true)

	if Character:GetAttribute("Sprint") then
		remoteList.Server:FireServer('Locker', "Survivor_Fast_Exit", Hiding_Spot) -- Fire off to Server
	else
		remoteList.Server:FireServer('Locker', "Survivor_Slow_Exit", Hiding_Spot) -- Fire off to Server
	end

	if Action.ActionInfo.Connections.Animation then
		Action.ActionInfo.Connections.Animation:Disconnect() -- remove dual listening (for performance)
	end
	
	Action.ActionInfo.Connections.Animation = Hiding_Spot:GetAttributeChangedSignal("Animation"):Connect(function()
		local Animation = Hiding_Spot:GetAttribute("Animation")
		
		if Animation and Animation ~= "" and script:FindFirstChild(Animation) then
			Action.ActionInfo.Connections.Animation:Disconnect() -- remove doing animation when it's not our turn and do not force overload of signals
			Action.ActionInfo.Connections.Animation = nil -- remove variables do not force overuse of memory/ram

			if not Action.ActionInfo.Connections[Animation] then -- build and store animation
				Action.ActionInfo.Connections[Animation] = Player.Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(script:FindFirstChild(Animation))
			end
			
			local A_Length = if Action.ActionInfo.Connections[Animation].Length < 0.1 then 1 else Action.ActionInfo.Connections[Animation].Length
			local True_Length : number = 0 - (workspace:GetServerTimeNow() - Hiding_Spot:GetAttribute("Animation_Time"))
			
			Action.ActionInfo.Connections[Animation]:Play() -- play animation
			Action.ActionInfo.Connections[Animation]:AdjustSpeed(A_Length/True_Length) -- both animations should end at same time/sync
			
			Action.ActionInfo.Connections[Animation].Stopped:Wait() -- wait for finish
			
			modules.UI:Hide(false)
		end
	end)
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
