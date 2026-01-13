local Player = game.Players.LocalPlayer
local DefaultPriority = 3

local game_data = game.ReplicatedStorage:WaitForChild('Game_Data')
local Killer_Module = require(game_data:WaitForChild('Killers'):WaitForChild('Ninja'))

local Action = {
	Key = "Secondary_Power";
	ActionName = "Switch Stance (Crouch)";
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

--local Tracks = {}

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	
	local Power_State = Player.Character:GetAttribute("Power_State")
	
	local LastSwing = (Player.Character:GetAttribute("SwingEnd") or 0)
	
	if not Power_State then return false end
	
	if (currentValues.KillerAction.Value == "Nothing" or currentValues.KillerAction.Value == "Hiding")
		and not Player.Character:GetAttribute("Swing")
		and (Power_State == "Idle" or Power_State == "Hidden") -- we are idled out
		and not currentValues.Stunned.Value
		and (currentValues.Parent:WaitForChild("BLOODPOINT"):FindFirstChild("REMOVE") ~= nil)
		and not Player.Character:GetAttribute("Carry") then
		
		CanRun = true
	elseif Action.Debounces.Deploying then -- if in progress do not let go of this interaction
		
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 0.15 or Action.Debounces.Deploying then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Deploying = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	--modules.UI:Hide(true)
	
	--[[if not Tracks.Hidden then
		Tracks.Hidden = Character:WaitForChild('Humanoid'):LoadAnimation(game.ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations'):WaitForChild('Ninja'):WaitForChild('Crouch'))
	end]]
	
	local Current_Action = currentValues.Action.Value
	
	remoteList.Server:FireServer("Swift Charge", 'Switch_Stance')
	
	repeat task.wait()
	until currentValues.Action.Value ~= Current_Action
	
	if not Action.ActionInfo.Connections.Stunned then
		Action.ActionInfo.Connections.Stunned = currentValues.KillerAction.Changed:Connect(function()

			if currentValues.KillerAction.Value == 'Stunned' then
				remoteList.Server:FireServer("Swift Charge", 'Switch_Stance')
			end
		end)
	end
	--[[if currentValues.Action.Value == "Hiding" then
		Tracks.Hidden:Play()
	else
		Tracks.Hidden:Stop()
	end]]--
	
	if Player.Character:GetAttribute("Power_State") == "Idle" then
		modules.UI:ChangeName(Action.ActionName, "Switch Stance (Crouch)")
	else
		modules.UI:ChangeName(Action.ActionName, "Switch Stance (Stand)")
	end
	--modules.UI:Hide(false)
	
	Action.Debounces.Deploying = false
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
