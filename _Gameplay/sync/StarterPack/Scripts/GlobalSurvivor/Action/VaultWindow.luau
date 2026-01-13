local Code = require(game.ReplicatedStorage.Modules.Code)
local Player = game.Players.LocalPlayer

local ControlScript = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()


local TweenService = game:GetService('TweenService')
remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")

local Action = {
	Key = "Interact";
	ActionName = "VAULT WINDOW";
	InteractDistance = 4;
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		Settings = nil;
		Window = nil;
		Ports = {
			Close = nil;
			Far = nil;
		};
	},
	Debounces = {
		InProgress = false;
		InputEnter = tick();
	},
	WindowList = {};
	ActiveWindows = {};
}

local Settings = {
	Base = {
		Vaults = 3; -- amount of times to vault b4 reset
		Reset = 35; -- time till window count resets
		Priority = .65; -- window of time this survivor has priority to re-vault
		Speeds = {
			["Slow"] = 2,
			["Medium"] = 1.0,
			["Fast"] = 0.7;
		}
	}
}

local I_COUNT = 0

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Vault : Model = actionList.Vault
	local Trap : Model = actionList.KillerInteractable.Trap
	local Hiding_Spot : Model = actionList.Hiding_Spot

	if not Vault or not Player or not Player.Character or not Player.Character.PrimaryPart then return false end

	if Hiding_Spot then
		if (Hiding_Spot:WaitForChild('Prompt').Position - Player.Character:GetPivot().Position).Magnitude <= 6 then
			return	
		end
	end

	local vaultSettings = Vault:WaitForChild('Panel')
	local Port1, Port2 = nil, nil

	local Front = Vault:WaitForChild("FrontPort")
	local Back = Vault:WaitForChild('BackPort')

	local FrontPos = Front.CFrame.Position
	local FrontXZ = Vector3.new(FrontPos.X, 0, FrontPos.Z)

	local BackPos = Back.CFrame.Position
	local BackXZ = Vector3.new(BackPos.X, 0, BackPos.Z)

	local PlayerPos = Player.Character.PrimaryPart.CFrame.Position
	local PlayerXZ = Vector3.new(PlayerPos.X, 0, PlayerPos.Z)

	local DistXZFront = (PlayerXZ - FrontXZ).Magnitude
	local DistXZBack = (PlayerXZ - BackXZ).Magnitude

	if (DistXZBack > 8 and DistXZFront > 8) then
		return false
	end

	if (DistXZBack > DistXZFront) then

		if (DistXZFront > 8.5) then
			return false
		else
			Port1, Port2 = Front, Back
		end
	else

		if (DistXZBack > 8.5) then
			return false
		else
			Port1, Port2 = Back, Front
		end
	end

	if not table.find(Action.WindowList, Vault) then
		table.insert(Action.WindowList, Vault)

		local m = require(vaultSettings:WaitForChild('BlockLogic'))

		vaultSettings:WaitForChild('shadowvault').Changed:Connect(function()

			if vaultSettings.shadowvault.Value then
				m:Shadow(true)
			else
				m:Shadow(false)
			end
		end)
	end

	if (vaultSettings:WaitForChild('Vaulter').Value == "" or vaultSettings:WaitForChild('Vaulter').Value == Player.Name)
		and not vaultSettings:WaitForChild('shadowvault').Value
		and not vaultSettings:WaitForChild('Blocked').Value
		and not Port1:FindFirstChild('Deactivated')
		and not currentValues.Holded.Value
		and not currentValues.Hooked.Value
		and not currentValues.Vaulting.Value
		and currentValues.HealthState.Value > 0
		and (Port1.Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance
		and (not Trap or (Trap and (Port1.Position - Trap:WaitForChild('HumanoidRootPart').Position).Magnitude > 4.35 or Trap.Panel.State ~= "Armed"))
		and currentValues:WaitForChild('Action').Value == 'Nothing' then

		Action.ActionInfo.Window = Vault
		Action.ActionInfo.Settings = vaultSettings
		Action.ActionInfo.Ports = {
			Close = Port1;
			Far = Port2;
		}

		CanRun = true
	else
		Action.ActionInfo.Window = nil
		Action.ActionInfo.Settings = nil
		Action.ActionInfo.Ports = {
			Close = nil;
			Far = nil;
		}
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or Action.Debounces.InProgress or not Action.ActionInfo.Ports.Close or not Action.ActionInfo.Settings then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local windowSettings, Window = Action.ActionInfo.Settings, Action.ActionInfo.Window
	local Ports = Action.ActionInfo.Ports
	local inChase = Player.Character:GetAttribute("Chased")
	local HasLithe, LitheTier = modules.Data:GetPerk("Lithe")

	Player = game.Players.LocalPlayer
	local Character = Player.Character
	local PrimaryPart = Character.PrimaryPart
	local PlayerPos = PrimaryPart.CFrame.Position
	local DestinationPos = Ports.Far.CFrame.Position
	local VaultPointPos = Window.LowCollision.CFrame.Position
	local StartPos = Ports.Close.CFrame.Position

	local Test_Frame = Instance.new('CFrameValue')

	--warn(`Start: {Ports.Close} | Dest: {Ports.Far}`)

	local x,y,z = Ports.Far.CFrame.Rotation:ToOrientation()
	local Dist = (Vector3.new(PlayerPos.X, 0, PlayerPos.Z) - Vector3.new(VaultPointPos.X, 0, VaultPointPos.Z)).Magnitude
	local Direction = CFrame.new(PrimaryPart.CFrame.Position, DestinationPos).LookVector
	local Angle = (Direction - PrimaryPart.CFrame.LookVector).Magnitude
	local isMoving = math.abs(Player.Character.Humanoid.MoveDirection.X) > 0 or math.abs(Player.Character.Humanoid.MoveDirection.Z) > 0

	modules.UI:Hide(true)

	I_COUNT += 1

	currentValues.Vaulting.Value = true
	remoteEvents.EventRemotes.ActionEvent:FireServer("Survivor_Vault", "Window", actionList.MovementScript.Shift.Value)
	obfuscate("String", currentValues.Action, "VaultingWindow")
	obfuscate("String", windowSettings.Vaulter, Player.Name)

	local Animation = script:WaitForChild('Slow')

	if actionList.MovementScript.Shift.Value then
		local Direction = CFrame.new(Character:GetPivot().Position, Action.ActionInfo.Ports.Far.Position)
		local Difference = (Direction.LookVector - Character:GetPivot().LookVector).Magnitude

		if (Angle <= 0.61 and isMoving and Dist > 2.2)  then
			Animation = script:WaitForChild('Fast')
		else
			Animation = script:WaitForChild('Medium')
		end

		if not modules.Code:IsExhausted() and HasLithe then
			remoteList.Perk:FireServer("VaultNGo")
		end
	end
	
	local Connections = {}
	
	local VaultSpeed = Code:GetPlayerValue(Player, "WindowVaultSpeed")
	local VaultAnimation = Character.Humanoid:LoadAnimation(Animation)
	VaultAnimation:Play(0, 1, Animation:GetAttribute("Speed") / VaultSpeed)
	
	Test_Frame.Value = Character:GetPivot() -- set value first

	Connections.Test = Test_Frame.Changed:Connect(function() -->> overwrite cframe when changed
		Character:PivotTo(Test_Frame.Value)
	end)

	if Animation.Name == "Fast" or Animation.Name == "Medium" then
		remoteList.Sound:FireServer(Window.LowCollision.WindowVaultSound, 'Playing', true)
		Window.LowCollision.WindowVaultSound.Playing = true
	end

	local Offset = if Animation.Name == "Fast" then -0.25 else 1.25
	local Time = Settings.Base.Speeds[Animation.Name] * VaultSpeed
	Time -= 0.1

	local StartVec = Vector3.new(PlayerPos.X, PlayerPos.Y, StartPos.Z)
	local StartCFrame = CFrame.new(StartVec) * CFrame.Angles(0, y, 0) * CFrame.Angles(0, math.rad(180), 0)

	local VaultPointVec = Vector3.new(VaultPointPos.X, PlayerPos.Y + Offset, VaultPointPos.Z)
	local VaultPointCFrame = CFrame.new(VaultPointVec) * CFrame.Angles(0, y, 0)  * CFrame.Angles(0, math.rad(180), 0)

	local DestinationVec = Vector3.new(DestinationPos.X, PlayerPos.Y, DestinationPos.Z)
	local DestinationCFrame = CFrame.new(DestinationVec) * CFrame.Angles(0, y, 0)  * CFrame.Angles(0, math.rad(180), 0)

	--ControlScript:Disable() -- removes inputs from us

	-- Calculate rotation based on vault direction
	local vaultDirection = (DestinationCFrame.Position - StartCFrame.Position).Unit
	local flatVaultDirection = Vector3.new(vaultDirection.X, 0, vaultDirection.Z)

	-- Use this as the new rotation-facing CFrame
	local rotationCFrame = CFrame.new(StartCFrame.Position, StartCFrame.Position + flatVaultDirection)

	-- Apply rotation to Test_Frame from the beginning
	Test_Frame.Value = rotationCFrame

	-- Tween to the correct start position (same orientation)
	local Reposition = TweenService:Create(Test_Frame, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Value = StartCFrame})
	Reposition:Play()

	Window.LowCollision.CanCollide = false
	Window.UpperCollision.CanCollide = false

	Window.LowCollision.CollisionGroup = "NoCollision"
	Window.UpperCollision.CollisionGroup = "NoCollision"

	Player.Character.PrimaryPart.Anchored = true

	--print(Time)

	local VaultTween = TweenService:Create(Test_Frame, TweenInfo.new(Time, Enum.EasingStyle.Linear), {Value = DestinationCFrame})
	VaultTween:Play()

	VaultTween.Completed:Connect(function()
		Window.LowCollision.CanCollide = true
		Window.UpperCollision.CanCollide = true
		Window.LowCollision.CollisionGroup = "Default"
		Window.UpperCollision.CollisionGroup = "Default"
		Player.Character.PrimaryPart.Anchored = false

		--task.wait(0.05)
		--ControlScript:Enable()

		task.wait(0.05)
		obfuscate("String", currentValues.Action, "Nothing")
		currentValues.Vaulting.Value = false
	end)

	--obfuscate("String", currentValues.Action, "Nothing")
	--currentValues.Vaulting.Value = false

	if not Action.ActiveWindows[Window] then
		Action.ActiveWindows[Window] = {
			lastVault = tick(); -- set time on last Vault
		}

		windowSettings.Vaults.Value = 1 -- first vault
	else -- we do have a active slot

		if (tick() - Action.ActiveWindows[Window].lastVault) >= Settings.Base.Reset then -- if time elapsed
			windowSettings.Vaults.Value = math.clamp(0, 0, Settings.Base.Vaults) -- reset window count
		end

		if (inChase) then
			-- no work i remove
			if Animation.Name == "Slow" then
				windowSettings.Vaults.Value = math.clamp(windowSettings.Vaults.Value + 1, 0, Settings.Base.Vaults)
			end
			
			if Animation.Name == "Fast" or Animation.Name == "Medium" then
				windowSettings.Vaults.Value = math.clamp(windowSettings.Vaults.Value + 1, 0, Settings.Base.Vaults) -- add a vault
			end
		end
		
		Action.ActiveWindows[Window].lastVault = tick() -- reset time
	end

	if windowSettings.Vaults.Value >= Settings.Base.Vaults then
		coroutine.wrap(require(windowSettings:WaitForChild('BlockLogic')).BlockWindow)() -- should block?
	end


	coroutine.wrap(function()
		local oldValue = I_COUNT

		task.wait(Settings.Base.Priority)

		if oldValue == I_COUNT then
			obfuscate("String", windowSettings.Vaulter, "")
		end
	end)()

	modules.UI:Hide(false)
	Action.Debounces.InProgress = false
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
