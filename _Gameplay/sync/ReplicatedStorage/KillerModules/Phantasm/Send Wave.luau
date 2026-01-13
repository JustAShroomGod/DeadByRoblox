local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = game.Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid
local PowerModel = Character:WaitForChild("Dark Presence")

local Scripts = Player.Backpack.Scripts
local KillerAction = Scripts.values.KillerAction

local Code = require(game.ReplicatedStorage.Modules.Code)

local data_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local Addon = data_module:GetAddon("Killer", Player, "Remnant From The Past")

local DefaultPriority = 3

local Action = {
	Key = "Interact3";
	ActionName = "Send Wave";
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		SendAnimation = nil
	},
	Debounces = {
		InputEnter = tick();
		Deploying = false;
		Exiting = false;
		CanBlink = true;
		Holding = false;
	},
	Power = {},
	Limits = {},
	Connections = {},
}

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	
	if Addon then
		return false
	end
	
	if not actionList.KillerInfo then
		
		actionList.KillerInfo = {
			LastSwing = (Player.Character:GetAttribute("SwingEnd") or 0);
		}
	end
	
	if (not Player.Character:GetAttribute("IntroDone")) then
		return false
	end
	
	if (Action.ActionInfo.SendAnimation == nil) then
		if (Player.Character == nil or Player.Character:FindFirstChild("Humanoid") == nil) then
			return false
		end
		
		Action.ActionInfo.SendAnimation = Player.Character.Humanoid:LoadAnimation(script.SendAnimation)
		Action.ActionInfo.SendAnimation.Looped = false
	end
	
	if (KillerAction.Value == "Nothing")
		and not Player.Character:GetAttribute("Carry")
		and not Player.Character:GetAttribute("Swing")
		and (currentValues.Parent:WaitForChild("BLOODPOINT"):FindFirstChild("REMOVE") ~= nil)
		and not currentValues.Stunned.Value
		and PowerModel.PowerValues:GetAttribute("Current") >= 100 then
		
		CanRun = true
	elseif Action.Debounces.Deploying then -- if in progress do not let go of this interaction
		
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	--if (tick() - Action.Debounces.InputEnter) < 1 or Action.Debounces.Deploying then return warn("Anti-Spam") end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Deploying = true
	Action.Debounces.Holding = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	
	local Character = Player.Character
	local SendAnimation: AnimationTrack = Action.ActionInfo.SendAnimation
	
	coroutine.wrap(function()
		KillerAction.Value = "SendWave"
		TweenSpeed(0.5)
		
		SendAnimation:Play()
		SendAnimation.KeyframeReached:Once(function(keyframe)
			
			if (keyframe ~= "Ability_Toss") then
				return
			end
			
			PowerModel.PowerValues.PowerRemote:FireServer("SendWave")
			TweenSpeed(1)
			KillerAction.Value = "Nothing"
		end)
	end)()
	
	modules.UI:Hide(true)
end

function Action:Stop(...) : "Stop Action?"
	--if not Action.ActionInfo.Disconnect or Action.Debounces.Exiting then return warn('Anti-Spam Exit') end -- if we don't have disconnect do not trigger
	Action.Debounces.Exiting = true
	Action.Debounces.Holding = false
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	
	local Character = Player.Character
	
	Action.Debounces.Exiting = false
	Action.Debounces.Deploying = false
	Action.Priority = DefaultPriority
	--modules.UI:Hide(false)
	
end

function Action:Process(...) : boolean | "Returns true if this action can be ran"
	local args = {...}
	local actionList, remoteList = args[1], args[2]

	if Constraints(actionList) then
		return true
	end

	return false
end

function TweenSpeed(Percentage)
	
	if (Action.Connections["SpeedTween"] ~= nil) then
		Action.Connections["SpeedTween"]:Cancel()
		Action.Connections["SpeedTween"] = nil
	end
	
	local Speed = Code:GetPlayerValue(Player, "Speed") * Code:GetPlayerValue(Player, "SpeedMultiplier")
	Speed *= Percentage
	
	Action.Connections["SpeedTween"] = TweenService:Create(Player.Character.Humanoid, TweenInfo.new(0.35), {WalkSpeed = Speed})
	Action.Connections["SpeedTween"]:Play()
	
	local completed
	completed = Action.Connections["SpeedTween"].Completed:Connect(function()
		completed:Disconnect()
		completed = nil
		Action.Connections["SpeedTween"] = nil
	end)
	
end

function SetAction(action)
	
	if (table.find(Action.ValidActions, KillerAction.Value) == nil) then
		return
	end
	
	PowerModel.PowerValues.PowerRemote:FireServer("Action", action)
end

function SetValue(Attribute, Value)
	PowerModel.PowerValues.PowerRemote:FireServer("SetValue", Attribute, Value)
end

function updateAttributes(currentValues)
	
	local Character = Player.Character

end

return Action
