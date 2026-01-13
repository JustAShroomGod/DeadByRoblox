local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerSettings : GameSettings = UserSettings().GameSettings
local Default = 3

local Game_Assets = game:GetService('ReplicatedStorage'):WaitForChild('Game_Assets')
local Item_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Items')

local Settings = {
	DefaultCFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(-70));
}

local testing_stablizers : boolean = true

local Animations = {
	Stable_Stand = nil;
	Stable_Crouch = nil;
	Unstable = nil;
}

local Sensitivity = {
	X = PlayerSettings.MouseSensitivity;
	Y = PlayerSettings.MouseSensitivity;
	GAMEPAD = 100; -- gamepad multiplier/boost
	MOBILE = 20; -- mobile boost
}

local Item = {
	BLIND_STATUS = "NOT_BLINDING";
	Connections = {
		Disconnect = nil;
	},
	Debounces = {
		FlashReplicated = tick();
		InputEnter = tick();
		InputExit = tick();
	},
	Global_IgnoreList = { -- will get more accurate between beamers over time
		Player.Character or Player.CharacterAdded:Wait(),
	}
}

function Item:Constraints(actionList, modules, Action) : boolean | "Return true if can do action"
	local CanRun = false
	local currentValues = actionList.ValueList
	local CurrentItem = actionList.CharacterItem
	local HumanoidState = Player.Character.Humanoid:GetState()

	Action.ActionName = "#USE FLASHLIGHT"

	if not Action.ActionInfo["Flashlight"] then
		Action.ActionInfo["Flashlight"] = {}
	end

	if not Action.Debounces["Flashlight"] then
		Action.Debounces["Flashlight"] = {
			startingUse = false; -- only turns on while turning device on and off once it completes
			beingUsed = false; -- stays on throughout entire use
		}
	end

	if not currentValues.Hooked.Value
		and CurrentItem:GetAttribute("Progress") > 0
		--and CurrentItem:WaitForChild('UseProgress').Value > 0
		and HumanoidState ~= Enum.HumanoidStateType.FallingDown
		and HumanoidState ~= Enum.HumanoidStateType.Landed
		and Player.Character.Humanoid.WalkSpeed > 0
		and currentValues.Action.Value == "Nothing"
		and currentValues.HealthState.Value > 0
		and not Player.Character.PrimaryPart.Anchored
		and not currentValues.Holded.Value then

		CanRun = true
		Action.ActionInfo.Flashlight = {
			Item = CurrentItem;
		}
	elseif Action.Debounces.Flashlight.beingUsed then
		Action.Priority = 0
		CanRun = true
	else
		Action.ActionInfo.Flashlight = {}
	end

	return CanRun
end

function Item:Start(Action, ...) : "Start Using"
	if (tick() - Item.Debounces.InputEnter) < 1 or Action.Debounces.Flashlight.beingUsed or Action.Debounces.Flashlight.startingUse then return --[[warn("Anti-Spam")]] end
	Item.Debounces.InputEnter = tick()
	Action.Debounces.Flashlight.beingUsed = true
	Action.Debounces.Flashlight.startingUse = true

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	local EventRemote = script:WaitForChild('Flashlight')
	local Beamer = Action.ActionInfo.Flashlight.Item
	local Weld, Cone = Beamer:WaitForChild('Weld'), Beamer.Cone
	local Use = Beamer.bool

	local Flashlight_Module = require(Item_Data:WaitForChild(Beamer.Name))
	local RawKiller = nil

	modules.UI:Hide(true)

	obfuscate("string", currentValues.Action, "UsingFlashlight")
	obfuscate("bool", Use, true)

	local Connections = {}

	if not Animations.Unstable then
		Animations.Unstable = Character.Humanoid:LoadAnimation(Game_Assets:WaitForChild('Animations'):WaitForChild('Items'):WaitForChild('Flashlight_Default'))
	end

	if not Animations.Stable_Stand then
		Animations.Stable_Stand = Character.Humanoid:LoadAnimation(Game_Assets:WaitForChild('Animations'):WaitForChild('Items'):WaitForChild('Flashlight_Stable_Stand'))
	end

	if not Animations.Stable_Crouch then
		Animations.Stable_Crouch = Character.Humanoid:LoadAnimation(Game_Assets:WaitForChild('Animations'):WaitForChild('Items'):WaitForChild('Flashlight_Stable_Crouch'))
	end

	local function playAnim(animation)

		for _, anim in pairs(Animations) do

			if anim.IsPlaying then

				if anim ~= animation then
					anim:Stop()
				end
			else

				if anim == animation then
					anim:Play()
				end
			end
		end
	end

	local function disconnect(reason)
		if Connections.Hit then Connections.Hit:Disconnect() end
		if Connections.Progress then Connections.Progress:Disconnect() end
		if Connections.Bool then Connections.Bool:Disconnect() end
		if Connections.State then Connections.State:Disconnect() end

		if Connections.Render then Connections.Render:Disconnect() Connections.Render = nil end

		playAnim() -- stop all animations

		obfuscate("String", currentValues.Action, "Nothing")
		obfuscate("bool", Use, false)

		Camera.CameraType = Enum.CameraType.Custom

		if Item.BLIND_STATUS == "BLINDING" then
			Item.BLIND_STATUS = "NOT_BLINDING"
			EventRemote:FireServer("StopBlinding")
		end

		Weld.C0 = Settings.DefaultCFrame * CFrame.Angles(0, 0, math.rad(90))
		remoteList.FlashReplicate:FireServer("Flashlight_Reset", Beamer)
		-- fire replication remote to reset on other clients

		Action.Debounces.Flashlight.beingUsed = false
		Action.Priority = Default
		modules.UI:Hide(false)
	end

	-- Wait until value is switched and angle character --
	repeat task.wait()
	until Use.Value

	local _, Y_Angle, _ = Camera.CFrame:ToOrientation()
	Character:PivotTo(CFrame.new(Character:GetPivot().Position) * CFrame.Angles(0, Y_Angle, 0))
	-- Wait until value is switched and angle character --

	local rayParams = RaycastParams.new()
	rayParams.IgnoreWater = true
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local startBlind = nil
	local Current_Blinding = nil;

	Connections.Render = game:GetService('RunService').Heartbeat:Connect(function(step)
		local Vector = Vector2.new(0, 0)

		if game:GetService('UserInputService').GamepadEnabled then
			local GAMEPAD_INPUTS = game:GetService('UserInputService'):GetGamepadState(Enum.UserInputType.Gamepad1)

			for _,input in pairs(GAMEPAD_INPUTS) do

				if input.KeyCode == Enum.KeyCode.Thumbstick2 then
					Vector = Vector2.new(input.Position.X * Sensitivity.GAMEPAD * step, -input.Position.Y * Sensitivity.GAMEPAD * step)
					break
				end
			end
		else
			Vector = game:GetService('UserInputService'):GetMouseDelta()/5 -- reduce that speed boi

			if actionList.Control_Scheme == "Mobile" then
				Vector *= Sensitivity.MOBILE
			end
		end

		local X_ANGLE, Y_ANGLE, _ = Camera.CFrame:ToOrientation()

		Camera.CameraType = Enum.CameraType.Scriptable
		Character:PivotTo(Character:GetPivot() * CFrame.Angles(0, -math.rad(Vector.X) * Sensitivity.X, 0))
		Camera.CFrame = Character:GetPivot()
			* CFrame.new(2.5, 2.5, 3)
			* CFrame.Angles(math.clamp(X_ANGLE + (-math.rad(Vector.Y) * Sensitivity.Y), math.rad(-45), math.rad(45)), 0, 0)

		Weld.C0 = Settings.DefaultCFrame * CFrame.Angles(0, 0, X_ANGLE)

		-- Animation Controller --
		if testing_stablizers then
			if Character:GetAttribute("Crouch") then
				playAnim(Animations.Stable_Crouch)
			else
				playAnim(Animations.Stable_Stand)
			end
		else
			playAnim(Animations.Unstable)
		end

		Item.Global_IgnoreList = {Player.Character or Player.CharacterAdded:Wait()}

		for i, G in pairs(game.Players:GetPlayers()) do
			if G then
				if G.Backpack:WaitForChild("Scripts"):WaitForChild("values"):WaitForChild("HealthState").Value == 0 then
					local c = G.Character or G.CharacterAdded:Wait()
					table.insert(Item.Global_IgnoreList,c)
				end
			end
		end

		-- Raycasting Part --
		local Flashlight_Distance, Flashlight_Width, ObjectWeHit : BasePart, HitMarker : Vector3, HitFront = Flashlight_Module.Range, Flashlight_Module.Spread, nil, nil, false
		local ValidHitting, FinishedCasting = false, false
		Flashlight_Distance = Beamer['Flashlight-Script'].Range.Value

		local StartPosition = Beamer.LightStart.CFrame * CFrame.new(0, 0, Cone.Size.Y/2 - 1)

		local function repeatRay(toadd : BasePart | Model) : "Penetrating Raycast"
			if toadd then table.insert(Item.Global_IgnoreList, toadd) end

			rayParams.FilterDescendantsInstances = Item.Global_IgnoreList

			local Cast = workspace:Raycast(StartPosition.Position, StartPosition.LookVector * Flashlight_Distance, rayParams)

			if Cast then

				if Cast.Instance.Parent.ClassName == "Accessory" or (Cast.Instance.Transparency >= 0.25 and Cast.Instance.Name ~= "Flash_Zone") then
					return false, Cast.Instance, nil, false
				else
					return true, Cast.Instance, Cast.Position, (Cast.Instance.CFrame.LookVector == Cast.Normal)
				end
			else
				return true, nil, nil, false
			end
		end

		repeat FinishedCasting, ObjectWeHit, HitMarker, HitFront = repeatRay(ObjectWeHit)
		until FinishedCasting
		-- Done w/ Raycasting --

		local function removeBlind()
			if Item.BLIND_STATUS == "NOT_BLINDING" then return end
			Item.BLIND_STATUS = "NOT_BLINDING"
			startBlind = nil
			EventRemote:FireServer("StopBlinding", Current_Blinding)
		end

		if ObjectWeHit then
			Flashlight_Distance = (StartPosition.Position - HitMarker).Magnitude
			if (ObjectWeHit.Name == "Flash_Zone") and HitFront then
				if (game.Players:FindFirstChild(ObjectWeHit.Parent.Name) ~= nil) then
					local IsKiller = game.Players:FindFirstChild(ObjectWeHit.Parent.Name)
					if IsKiller then
						local Character = IsKiller.Character
						local Root = Character:WaitForChild("HumanoidRootPart").CFrame
						local CameraCFrame = CFrame.new(workspace.CurrentCamera.CFrame.X,workspace.CurrentCamera.CFrame.Y,workspace.CurrentCamera.CFrame.Z) * CFrame.Angles(0,workspace.CurrentCamera.CFrame.Rotation.Y,0)
						if (CFrame.new(Root.p, CameraCFrame.Position).LookVector - Root.LookVector).magnitude < math.rad(60) then
							if Item.BLIND_STATUS == "NOT_BLINDING" then
								Item.BLIND_STATUS = "BLINDING"
								EventRemote:FireServer("StartBlinding", ObjectWeHit)
							end
							-- Adjust killer hitbox for spread of this beamer
							if game.Players:FindFirstChild(ObjectWeHit.Parent.Name) then
								local Zone, Base = ObjectWeHit.Parent.Flash_Zone, (Flashlight_Module.Spread * 2.8)
								Zone.Size = Vector3.new(Base * 1.15, Base, .25) -- the bigger the spread the bigger the area to hit
								RawKiller = game.Players:FindFirstChild(ObjectWeHit.Parent.Name)
							end

							if RawKiller then
								local BlindSource = RawKiller.Backpack.Scripts.BlindScript

								if not startBlind and not BlindSource.Blinded.Value then
									startBlind = tick()
								end

								if BlindSource.Blinded.Value and startBlind and (tick() - startBlind) >= 0.1 then
									removeBlind() -- should reset our blind for chain
								else
									Flashlight_Width *= 1 + (4.65 * (tonumber(BlindSource.Brightness.Value)/(200 - BlindSource.Brightness.Value)))
								end
							end
						end
					end
				end
			else
				removeBlind()
			end
		else
			removeBlind()
		end

		Flashlight_Width = Flashlight_Distance/(3.5 * Flashlight_Width)

		Cone.Size = Vector3.new(Flashlight_Width, Flashlight_Distance, Flashlight_Width)
		Cone:WaitForChild('Pivot').C1 = CFrame.new(0, -Cone.Size.Y/2 + 1, 0)

		if (tick() - Item.Debounces.FlashReplicated) >= .5 then -- 1/2 second delay
			Item.Debounces.FlashReplicated = tick()
			remoteList.FlashReplicate:FireServer("Flashlight_Angle", Beamer, X_ANGLE, Cone.Size)
		end
	end)

	Connections.Hit = Character:GetAttributeChangedSignal("LastHit"):Connect(function(test)
		disconnect('hit')
	end)

	Connections.Bool = Use.Changed:Connect(function()
		if not Use.Value then
			disconnect('bool')
		end
	end)

	Connections.Progress = Beamer:GetAttributeChangedSignal("Progress"):Connect(function()
		local Progress = Beamer:GetAttribute("Progress")

		if Progress <= 0 then
			disconnect('progress')
		end
	end)

	Connections.State = Character.Humanoid.StateChanged:Connect(function()
		local State = Character.Humanoid:GetState()

		if State == Enum.HumanoidStateType.FallingDown or State == Enum.HumanoidStateType.Landed then
			disconnect('state')
		end
	end)

	Item.Connections.Disconnect = disconnect
	Action.Debounces.Flashlight.startingUse = false
end

function Item:Stop(Action, ...) : "Stop Using"
	if (tick() - Item.Debounces.InputExit) < 1 or not Item.Connections.Disconnect then return warn('Anti-Spam exit') end
	Item.Debounces.InputExit = tick()

	local args = {...}

	Item.Connections.Disconnect('m2')
	Item.Connections.Disconnect = nil
end

return Item