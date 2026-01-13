local Code = require(game.ReplicatedStorage.Modules.Code)
local Player = game.Players.LocalPlayer
remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")

coroutine.resume(coroutine.create(function()
	game:GetService("ContentProvider"):PreloadAsync({script.Vault})
end))

coroutine.resume(coroutine.create(function()
	game:GetService("ContentProvider"):PreloadAsync({script:WaitForChild("Vault")})
end))

local Shadow_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('ShadowVault'))

local Action = {
	Key = "Interact";
	ActionName = "VAULT WINDOW";
	InteractDistance = 5;
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		Settings = nil;
		Port = nil;
	},
	Debounces = {
		InProgress = false;
		InputEnter = tick();
	},
	WindowList = {}
}

local I_COUNT = 0

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Vault : Model = actionList.Vault

	if not Vault then return false end

	local Character = Player.Character
	local vaultSettings = Vault:WaitForChild('Panel')
	local Port = nil

	if (Vault:WaitForChild('FrontPort').Position - Player.Character:GetPivot().Position).Magnitude > (Vault:WaitForChild('BackPort').Position - Player.Character:GetPivot().Position).Magnitude then
		Port = Vault:WaitForChild('BackPort')
	else
		Port = Vault:WaitForChild('FrontPort')
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

	local Direction = (CFrame.new(Port.Position.X, Character:GetPivot().Position.Y, Port.Position.Z).Position - Character:GetPivot().Position).Unit
	local Difference = Direction:Dot(Character:GetPivot().LookVector)

	if (vaultSettings:WaitForChild('Vaulter').Value == "" or vaultSettings:WaitForChild('Vaulter').Value == Player.Name)
		and not Port:FindFirstChild('Deactivated')
		and Difference >= 0.2 -- if facing window for most part
		and not actionList.BasicAttack.Using
		and KillerConstraints(modules)
		and (Port.Name == "FrontPort" and (Port.CFrame.LookVector - game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame.LookVector).magnitude <= 1.2 or Port.Name == "BackPort" and (Port.CFrame.LookVector - game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame.LookVector).magnitude <= 1.2)
		and not Player.Character:GetAttribute("Carry") -- no carry attribute set so not carrying a person
		and (((Port.CFrame * CFrame.new(0,0,0.5)).p - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance or (Port.Parent.HumanoidRootPart.CFrame.p - Character.HumanoidRootPart.CFrame.p).Magnitude < 5)
		and currentValues:WaitForChild('KillerAction').Value == 'Nothing' then

		Action.ActionInfo.Settings = vaultSettings
		Action.ActionInfo.Port = Port

		CanRun = true
	else
		Action.ActionInfo.Settings = nil
		Action.ActionInfo.Port = nil
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
	if (tick() - Action.Debounces.InputEnter) < 1.5 or Action.Debounces.InProgress or not Action.ActionInfo.Port or not Action.ActionInfo.Settings then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local windowSettings = Action.ActionInfo.Settings

	local Character = Player.Character

	I_COUNT += 1

	local EquippedShadow, ShadowTier = modules.Data:GetPerk("ShadowVault")

	local prior_speed = Character.Humanoid.WalkSpeed

	Character.Humanoid.AutoRotate = false
	Character.Humanoid.WalkSpeed = 0
	actionList.PreventHeadTilt = true
	modules.Camera.Camera.HeadLocked = true

	modules.UI:Hide(true)

	local vaultTrack = Character:WaitForChild('Humanoid'):LoadAnimation(script.Vault)
	local tweenTime = Code:GetPlayerValue(Player, "WindowVaultSpeed")
	local defaultspeed = tweenTime
	
	if Player.Character:GetAttribute("Power_Tier") then
		local tier = Player.Character:GetAttribute("Power_Tier")
		if tier >= 3 then
			tweenTime = tweenTime - (defaultspeed * 0.3)
		end
	end
	if (Player.Character:GetAttribute("Cloaked") and Player.Character:GetChildren("Cloaked") == true) then
		tweenTime = tweenTime - (defaultspeed * 0.05)
	end
	
	if EquippedShadow then
		tweenTime = tweenTime - (defaultspeed * Shadow_Module.VaultSpeeds[ShadowTier])
	end
	tweenTime = tweenTime * Player.Backpack:WaitForChild("Scripts"):WaitForChild("PerksBase"):WaitForChild("Rigged Game"):GetAttribute("Percentage")
	vaultTrack:Play(0, 1, 1)
	vaultTrack:AdjustSpeed(vaultTrack.Length/tweenTime)

	remoteEvents.EventRemotes.ActionEvent:FireServer("Killer_Vault", "Window")
	obfuscate("string", currentValues.KillerAction, "WindowVault")
	obfuscate("string", windowSettings.Vaulter, Player.Name)
	---

	Character:PivotTo(Action.ActionInfo.Port.CFrame * CFrame.new(0, 3.25, -0.05))
	local OriginalPosition : Vector3 = Character:GetPivot().Position

	local metaPart = script:WaitForChild("MetaPart"):Clone()
	metaPart.CFrame = Action.ActionInfo.Port.CFrame * CFrame.new(0, 3.25, -4.85)
	metaPart.Anchored = true
	metaPart.AlignOrientation.Attachment0 = metaPart.Attachment
	metaPart.Parent = Character.PrimaryPart
	metaPart.AlignPosition.Attachment0 = Character.PrimaryPart.RootRigAttachment
	metaPart.AlignPosition.Position = OriginalPosition

	local collisionHistory = modules.Collision.DisableCollisionsInRegion(Character:GetPivot(), Vector3.new(100, 100, 100))

	local vaultTween = game:GetService('TweenService'):Create(metaPart.AlignPosition, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Position = metaPart.Position})
	vaultTween:Play()

	---
	
	coroutine.wrap(function()
		repeat task.wait() until vaultTween.PlaybackState ~= Enum.PlaybackState.Playing

		metaPart:Destroy()

		modules.Camera.Camera.HeadLocked = false
		actionList.PreventHeadTilt = false
		modules.Collision.EnableCollisions(collisionHistory)

		obfuscate("string", currentValues.KillerAction, "Nothing")

		Character.Humanoid.WalkSpeed = modules.Code:GetPlayerValue(Player, "Speed") * modules.Code:GetPlayerValue(Player, "SpeedMultiplier")

		modules.UI:Hide(false)

		if EquippedShadow and not windowSettings.shadowvault.Value then
			local lastShadow = Character:GetAttribute("Shadow_Vaulted")

			if not lastShadow then
				Character:SetAttribute("Shadow_Vaulted", 0)
				lastShadow = Character:GetAttribute("Shadow_Vaulted")
			end

			if (workspace:GetServerTimeNow() - tonumber(lastShadow)) >= Shadow_Module.Tiers[ShadowTier] then
				Character:SetAttribute("Shadow_Vaulted", workspace:GetServerTimeNow())

				coroutine.wrap(function()
					task.wait(0.45)
					obfuscate("bool", windowSettings.shadowvault, true)
					task.wait(Shadow_Module.Block_Length)
					obfuscate("bool", windowSettings.shadowvault, false)
				end)()
			end
		end

		coroutine.wrap(function()
			local oldValue = I_COUNT

			task.wait(.65)

			if oldValue == I_COUNT then
				obfuscate("String", windowSettings.Vaulter, "")
			end
		end)()
		Action.Debounces.InProgress = false
	end)()
	
	
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
