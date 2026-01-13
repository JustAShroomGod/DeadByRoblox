local Player = game.Players.LocalPlayer
local Defaults = 5;

local Perk_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('DeadHard'))

local ControlScript = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()

local Action = {
	Key = "Interact4";
	ActionName = "DODGE";
	Priority = 1; -- scale of 1-5
	ActionInfo = {},
	Debounces = {
		Active = false;
		InputEnter = tick();
		InputExit = tick();
	},
	Animation = nil
}

coroutine.resume(coroutine.create(function()
	local Animation = game.ReplicatedStorage:WaitForChild("Game_Assets"):WaitForChild("Animations"):WaitForChild("Perks"):WaitForChild("Survivor"):WaitForChild("Dodge"):WaitForChild("Dash")
	local Anim = Instance.new("Animation", script)
	Anim.AnimationId = Animation.AnimationId
	game:GetService("ContentProvider"):PreloadAsync({script:WaitForChild("Animation")})
end))

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList

	local HasPerk, PerkTier = modules.Data:GetPerk("DeadHard")

	if currentValues.HealthState.Value == 1
		and currentValues.Action.Value == "Nothing"
		and not currentValues.Hooked.Value
		and not currentValues.Holded.Value
		and Player.Character:GetAttribute("Sprint")
		and HasPerk -- has to have dead hard
		and not modules.Code:IsExhausted() then

		CanRun = true
	elseif Action.Debounces.Active then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or Action.Debounces.Active then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Active = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character


	if Action.Animation then
	else
		Action.Animation = Character.Humanoid.Animator:LoadAnimation(script.Animation)
	end

	ControlScript:Disable() 
	actionList.MovementScript.MainScript.Disabled = true

	script.Parent.Parent.Parent:WaitForChild("BLOODPOINT"):WaitForChild("RemoteEvent"):FireServer(currentValues.HealProgress.Value)
	local HasPerk, PerkTier = modules.Data:GetPerk("DeadHard")

	remoteList.Perk:FireServer("Dodge")

	local TimesTicked = 0
	currentValues.Action.Value = "DeadHard"
	repeat task.wait()
		TimesTicked += 0.01
	until currentValues.Action.Value == "DeadHard" or TimesTicked > 4

	if TimesTicked > 4 then
		Action.Debounces.Active = false
		Action.Priority = Defaults
		ControlScript:Enable() 
		modules.UI:Hide(false)
		actionList.MovementScript.MainScript.Disabled = false
		return
	end

	Action.Animation:Play()
	Action.Animation:AdjustSpeed(Action.Animation.Length/(Perk_Module.IFrame_Duration+0.06))

	ControlScript:Disable() -- removes inputs from us
	Character.Humanoid.WalkSpeed = 300 * (Player.Character.PrimaryPart.AssemblyLinearVelocity.Magnitude*-1+17/17)
	repeat task.wait()
		actionList.MovementScript.MainScript.Disabled = true
		Character.Humanoid:Move(Character:GetPivot().LookVector, false)
		Character.Humanoid.WalkSpeed = Perk_Module.Speed
		currentValues.Action.Value = "DeadHard"
		Character.Humanoid.WalkSpeed = Perk_Module.Speed + 0.01
	until Action.Animation.IsPlaying == false
	ControlScript:Enable() -- removes inputs from us
	actionList.MovementScript.MainScript.Disabled = false
	currentValues.Action.Value = "Nothing"
	Action.Debounces.Active = false
	Action.Priority = Defaults
	modules.UI:Hide(false)
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