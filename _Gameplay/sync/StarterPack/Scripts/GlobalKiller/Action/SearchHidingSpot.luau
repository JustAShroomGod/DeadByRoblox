local Player = game.Players.LocalPlayer

local Action = {
	Key = "Interact";
	ActionName = "SEARCH LOCKER";
	InteractDistance = 4.5;
	Priority = 4; -- scale of 1-5
	ActionInfo = {
		Connections = {};
	},
	Debounces = {
		InputEnter = tick()
	},
}

for i, b in pairs(script:GetChildren()) do
	if b and b:IsA("Animation") then
		game:GetService("ContentProvider"):PreloadAsync({b})
	end
end

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Hiding_Spot : Model = actionList.Hiding_Spot

	if not Hiding_Spot then return false end
	local Direction = ((Hiding_Spot:WaitForChild('RootPart').CFrame * CFrame.new(0,0,2)).Position - Player.Character:GetPivot().Position).Unit


	if Player.Character:GetPivot().LookVector:Dot(Direction) >= 0.65
		and not actionList.BasicAttack.Using
		and KillerConstraints(modules)
		and not Player.Character:GetAttribute("Carry") -- no carry attribute set so not carrying a person
		and (Hiding_Spot:WaitForChild('Prompt').Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance
		and (not Hiding_Spot:GetAttribute("Searching") or Hiding_Spot:GetAttribute("Searching") == "") -- another killer or player isn't searching it
		and not Hiding_Spot:GetAttribute("Blocked") -- not entombed/blocked in
		and currentValues:WaitForChild('KillerAction').Value == 'Nothing' then

		CanRun = true
	end

	return CanRun
end

function KillerConstraints(modules)

	if (modules.Data:GetCharacter() == "Psychopath") then
		return not (Player.Character.BloodRage:GetAttribute("State") == 2)
	end

	if (modules.Data:GetCharacter() == "Nurse") then
		return not (Player.Character:WaitForChild("Blink"):GetAttribute("BlinkAttack") or Player.Character:WaitForChild("Blink"):GetAttribute("State") > 0)
	end

	return true
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	local Hiding_Spot = actionList.Hiding_Spot

	local prior_speed = Character.Humanoid.WalkSpeed

	Character.Humanoid.WalkSpeed = 0
	actionList.PreventHeadTilt = true
	modules.Camera.Camera.HeadLocked = true
	modules.UI:Hide(true)

	-- fire remote here
	-- values are handled on server (we just need to enact our animation) --

	remoteList.Server:FireServer('Locker', "Killer_Search", Hiding_Spot) -- Fire off to Server

	if Action.ActionInfo.Connections.Animation then
		Action.ActionInfo.Connections.Animation:Disconnect()
	end

	Action.ActionInfo.Connections.Animation = Hiding_Spot:GetAttributeChangedSignal("Animation"):Connect(function()
		local Animation = Hiding_Spot:GetAttribute("Animation")

		if Animation and Animation ~= "" and script:FindFirstChild(Animation) then
			Action.ActionInfo.Connections.Animation:Disconnect() -- remove doing animation when it's not our turn and do not force overload of signals
			Action.ActionInfo.Connections.Animation = nil -- remove variables do not force overuse of memory/ram

			if not Action.ActionInfo.Connections[Animation] then -- build and store animation
				Action.ActionInfo.Connections[Animation] = Player.Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(script:FindFirstChild(Animation))
			end

			local A_Length = if Action.ActionInfo.Connections[Animation].Length < 0.1 then 10 else Action.ActionInfo.Connections[Animation].Length
			local True_Length : number = 0 - (workspace:GetServerTimeNow() - Hiding_Spot:GetAttribute("Animation_Time"))

			Action.ActionInfo.Connections[Animation]:Play() -- play animation
			Action.ActionInfo.Connections[Animation]:AdjustSpeed(A_Length/True_Length) -- both animations should end at same time/sync

			if Animation == "Locker_Reload" and modules.Data:GetCharacter() == "Huntress" then -- if huntress refill Hatchets
				--Character.Hatchet.Amount.Value = Character.Hatchet:GetAttribute("MaxAmount") -- DO NOT REFILL FROM CLIENT END -> SERVER-SIDED REFILL
			elseif Animation == "Locker_Grab" and game.Players:FindFirstChild(Hiding_Spot:GetAttribute("Hiding")) then
				actionList.InteractingSurvivor = game.Players:WaitForChild(Hiding_Spot:GetAttribute("Hiding")) -- overwrite the survivor we are picking up
			end
			
			Action.ActionInfo.Connections.Stunned = currentValues.KillerAction.Changed:Connect(function()

				if currentValues.KillerAction.Value == "Stun" then
					actionList.Player = nil
					actionList.InteractingSurvivor = nil
					
					Action.ActionInfo.Connections.Stunned:Disconnect()
					Action.ActionInfo.Connections.Stunned = nil
				end
			end)

			Action.ActionInfo.Connections[Animation].Stopped:Wait() -- wait for finish

			Character.Humanoid.WalkSpeed = prior_speed
			--Character.Humanoid.AutoRotate = true
			modules.Camera.Camera.HeadLocked = false
			actionList.PreventHeadTilt = false

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
