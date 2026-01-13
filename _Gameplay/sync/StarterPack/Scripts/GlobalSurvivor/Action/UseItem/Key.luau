local Player = game.Players.LocalPlayer
local Default = 3

local Item = {
	CurrentUse = nil;
	InteractDistance = 5;
	Connections = {};
	Debounces = {
		InputEnter = tick();
		InputExit = tick();
	},
}

function Item:Constraints(actionList, modules, Action) : boolean | "Return true if can do action"
	local CanRun = false
	local currentValues = actionList.ValueList
	local CurrentItem = actionList.CharacterItem
	local HumanoidState = Player.Character.Humanoid:GetState()
	local Hatch = actionList.Hatch
	
	Action.ActionName = "USE KEY"

	if not Action.ActionInfo["Key"] then
		Action.ActionInfo["Key"] = {}
	end

	if not Action.Debounces["Key"] then
		Action.Debounces["Key"] = {
			startingUse = false; -- only turns on while turning device on and off once it completes
			beingUsed = false; -- stays on throughout entire use
		}
	end
	
	if not Action.Debounces.Key.beingUsed then
		
		if Hatch then
			
			if Hatch:GetAttribute("State") == "Idle"
				and not Hatch:GetAttribute("User")
				and (Hatch.HumanoidRootPart.CFrame.Position - Player.Character:GetPivot().Position).Magnitude <= Item.InteractDistance then
				Item.CurrentUse = "Hatch"
			else
				Item.CurrentUse = "Aura"
			end
		else
			Item.CurrentUse = "Aura"
		end
	end
	
	if not currentValues.Hooked.Value
		and CurrentItem:WaitForChild('UseProgress').Value > 0
		and currentValues.Action.Value == "Nothing"
		and currentValues.HealthState.Value > 0
		and not Player.Character.PrimaryPart.Anchored
		and not currentValues.Holded.Value then -- can use key in general
		
		if Item.CurrentUse == "Aura" then
			CanRun = false -- not supporting aura atm
		elseif Item.CurrentUse == "Hatch" then
			CanRun = true
			Action.ActionInfo.Key = {
				Item = CurrentItem;
				Hatch = Hatch;
			}
		end
	elseif Action.Debounces.Key.beingUsed then
		Action.Priority = 0
		CanRun = true
	else
		Action.ActionInfo.Key = {}
	end

	return CanRun
end

function Item:Start(Action, ...) : "Start Using"
	if (tick() - Item.Debounces.InputEnter) < 1 or Action.Debounces.Key.beingUsed or Action.Debounces.Key.startingUse then return --[[warn("Anti-Spam")]] end
	Item.Debounces.InputEnter = tick()
	Action.Debounces.Key.beingUsed = true
	Action.Debounces.Key.startingUse = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	
	local Key = Action.ActionInfo.Key.Item

	modules.UI:Hide(true)
	
	if Item.CurrentUse == "Hatch" then
		local Hatch = Action.ActionInfo.Key.Hatch
		local State = Hatch:GetAttribute("State")

		modules.UI:Progress(Hatch:GetAttribute("Progress"), "UNLOCKING")
		
		local function disconnect()
			remoteList.Hatch:FireServer("Stop_Unlock")
		end
		
		if not Item.Connections.Hatch_Unlocking then
			Item.Connections.Hatch_Unlocking = Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(script:WaitForChild('Unlocking'))
		end

		remoteList.Hatch:FireServer("Unlock")
		Item.Connections.Hatch_Unlocking:Play()
		
		repeat task.wait()
			State = Hatch:GetAttribute("State")
		until State == "Open" or State == "Unlocking"
		
		Item.Connections.Disconnect = disconnect

		repeat task.wait()
			modules.UI:Progress(Hatch:GetAttribute("Progress"), "UNLOCKING")
			State = Hatch:GetAttribute("State")
		until State == "Open" or State == "Idle"
		
		Item.Connections.Disconnect = nil

		if Item.Connections.Hatch_Unlocking.IsPlaying then
			Item.Connections.Hatch_Unlocking:Stop()
		end
		
		Action.Debounces.Key.beingUsed = false
		Action.Priority = Default
		modules.UI:Hide(false)
		
		modules.UI:Progress()

		Action.Debounces.Key.startingUse = false
	elseif Item.CurrentUse == "Aura" then
		
	end
end

function Item:Stop(Action, ...) : "Stop Using"
	if (tick() - Item.Debounces.InputExit) < 1 or not Item.Connections.Disconnect then return warn('Anti-Spam exit') end
	Item.Debounces.InputExit = tick()

	local args = {...}

	Item.Connections.Disconnect()
	Item.Connections.Disconnect = nil
end

return Item
