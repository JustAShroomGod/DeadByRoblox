local Player = game.Players.LocalPlayer

local moriType = "Architect_Mori"

local Action = {
	Key = "Interact2";
	ActionName = "Mori";
	InteractDistance = 4.5;
	Priority = 1; -- scale of 1-5
	ActionInfo = {
		Survivor = nil;
		Settings = nil;
	},
	Debounces = {
		InputEnter = tick()
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Survivor : Model = actionList.Player

	if not Survivor or not Survivor.Character then
		return false
	end

	local survivorSettings = Survivor:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')
	local HookCount = if Survivor.Character:GetAttribute("Hook_Stage") then string.split(Survivor.Character:GetAttribute("Hook_Stage"), ':') else {0, 2}

	if survivorSettings:WaitForChild('HealthState').Value == 0
		and (actionList.Data_Storage_Clone.Loadout.Offering == "Death Card" or actionList.Data_Storage_Clone.Loadout.Offering == "Ultra Death Card") -- mori offering equipped
		and not modules.Code:IsDead(Survivor)
		and not survivorSettings:WaitForChild('Holded').Value
		and not actionList.BasicAttack.Using
		and tonumber(HookCount[1]) >= tonumber(HookCount[2])
		and not workspace:GetAttribute(Player.Name .. '_Mori')
		and (Survivor.Character:GetPivot().Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance
		and currentValues:WaitForChild('KillerAction').Value == 'Nothing'  then

		Action.ActionInfo.Survivor = Survivor
		Action.ActionInfo.Settings = survivorSettings
		CanRun = true
	else
		Action.ActionInfo.Survivor = nil
		Action.ActionInfo.Settings = nil
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 then return warn("Anti-Spam") end
	Action.Debounces.InputEnter = tick()

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	obfuscate("String", currentValues.Action, "Hooking")

	actionList.PreventHeadTilt = true
	actionList.InteractingSurvivor = Action.ActionInfo.Survivor -- overwrite the survivor we are picking up

	Character.Humanoid.AutoRotate = false
	Character.Humanoid.WalkSpeed = 0

	modules.Camera.Camera.HeadLocked = true

	modules.UI:Hide(true)

	remoteList.Mori:FireServer(moriType, actionList.InteractingSurvivor)

	local fs = workspace:GetServerTimeNow()

	repeat task.wait()
	until (currentValues.Action.Value == 'Mori' or (workspace:GetServerTimeNow() - fs) >= 3) -- wait for shoving to take effect

	repeat task.wait()
	until currentValues.Action.Value == 'Nothing'

	modules.Camera.Camera.HeadLocked = false

	Character.Humanoid.AutoRotate = true
	workspace.Camera.CameraSubject = Character.Humanoid
	workspace.Camera.CameraType = Enum.CameraType.Custom

	actionList.PreventHeadTilt = false
	Character.Humanoid.WalkSpeed = modules.Code:GetPlayerValue(Player, "Speed") * modules.Code:GetPlayerValue(Player, "SpeedMultiplier")

	-- prevent pick up after wards i think ? --
	Action.ActionInfo.Survivor = nil
	actionList.InteractingSurvivor = nil
	actionList.Player = nil

	obfuscate("String", currentValues.Action, "Nothing")

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
