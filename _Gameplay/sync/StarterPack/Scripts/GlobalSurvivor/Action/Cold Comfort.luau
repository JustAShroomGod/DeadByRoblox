local Player = game.Players.LocalPlayer
local Default = 3;

local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Cold Comfort'))
local PerkBase = Player.Backpack:WaitForChild("Scripts"):WaitForChild("PerksBase"):WaitForChild("Cold Comfort")
local DesiredAnimation = game:GetService("ReplicatedStorage"):WaitForChild("Game_Assets"):WaitForChild("Animations"):WaitForChild("Hook"):WaitForChild("Survivor"):WaitForChild("Icing")


local Action = {
	Key = "Interact2";
	ActionName = "ICE HOOK";
	InteractDistance = 4;
	Priority = 2; -- scale of 1-5
	ActionInfo = {
		Hook = nil;
		Disconnect = nil;
		Connections = {};
	},
	Debounces = {
		InputEnter = tick();
		InputExit = tick();
		InProgress = false
	};
	AnimationTrack = nil
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Hook : Model = actionList.Hook

	if not Hook then return false end
	
	local HasPerk, PerkTier = modules.Data:GetPerk("Cold Comfort")
	
	if not HasPerk then return false end
	
	local hookSettings = Hook.Panel

	if (Hook:WaitForChild("Trigger").Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance -- Distance Check
		and currentValues.HealthState.Value > 0
		and not currentValues.Holded.Value
		and not currentValues.Hooked.Value
		and currentValues.Action.Value == "Nothing"
		and not hookSettings.Ocuped.Value
		and hookSettings.Player.Value == "Nobody" 
		and hookSettings.Icy.Value == false 
		and PerkBase:GetAttribute("Active") then
		
		Action.ActionInfo.Hook = Hook

		CanRun = true
	elseif Action.Debounces.InProgress then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	else
		Action.ActionInfo.Hook = nil
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or Action.Debounces.InProgress then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true
	
	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	
	if not Action.AnimationTrack then
		Action.AnimationTrack = Character.Humanoid.Animator:LoadAnimation(DesiredAnimation)
	end
	
	Action.AnimationTrack:Play()
	
	actionList.MovementScript.MainScript.Disabled = true
	Character.PrimaryPart.Anchored = true
	
	modules.UI:Hide(true)
	modules.UI:Progress(Action.ActionInfo.Hook.Panel.Progress, 'ICING HOOK')

	obfuscate("Object", Action.ActionInfo.Hook.Panel.IcePlayer, Player)
	obfuscate("string", currentValues.Action, "Icing")

	local StandingPosition : Vector3 = Character:GetPivot().Position
	Character:PivotTo(CFrame.new(Vector3.new(StandingPosition.X, StandingPosition.Y - 1.65, StandingPosition.Z), Vector3.new(Action.ActionInfo.Hook.Collision.Position.X, StandingPosition.Y - 1.65, Action.ActionInfo.Hook.Collision.Position.Z)))
	Character.PrimaryPart.Anchored = true

	local function disconnect()
		if Action.AnimationTrack then Action.AnimationTrack:Stop() Action.AnimationTrack = nil end
		
		obfuscate("String", currentValues.Action, "Nothing")
		obfuscate("Object", Action.ActionInfo.Hook.Panel.IcePlayer, nil)
		
		for _, Connection in pairs(Action.ActionInfo.Connections) do
			Connection:Disconnect()
			Connection = nil
		end
		
		Character.PrimaryPart.Anchored = false
		actionList.MovementScript.MainScript.Disabled = false

		Action.Priority = Default
		modules.UI:Hide(false)
		modules.UI:Progress()
		

		Action.Debounces.InProgress = false
	end

	Action.ActionInfo.Connections.Hook = Action.ActionInfo.Hook.Panel.Progress.Changed:Connect(function()
		if Action.ActionInfo.Hook.Panel.Progress.Value >= 1000 then
			disconnect()
		end
	end)
	
	Action.ActionInfo.Connections.Hit = Character:GetAttributeChangedSignal("LastHit"):Connect(function(test)
		disconnect()
	end)

	script.Parent.Parent.Parent.values.HealthState.Changed:Connect(function()
		disconnect()
	end)
	
	Action.ActionInfo.Disconnect = disconnect
end

function Action:Stop(...)
	if Action.Debounces.Exiting or not Action.ActionInfo.Disconnect then return warn('Anti-Spam exit') end

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList

	if currentValues.Action.Value ~= "Icing" then
		repeat task.wait()
		until currentValues.Action.Value == "Icing"
	end

	Action.ActionInfo.Disconnect()
	Action.ActionInfo.Disconnect = nil
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
