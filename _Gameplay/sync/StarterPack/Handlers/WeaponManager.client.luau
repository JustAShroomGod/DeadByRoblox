localPlayer = game:GetService("Players").LocalPlayer
localCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
localPlayer:WaitForChild("Backpack"):WaitForChild("Scripts"):WaitForChild("values")
localPlayer.Backpack.Scripts:WaitForChild("Killer")
if localPlayer.Backpack.Scripts.Killer.Value == false then
	localPlayer.Backpack.Scripts.Killer.Changed:Wait() --- wait until Killer value is set to true
end
game:GetService("TestService"):Done("Backpack>Handlers>WeaponManager:Working")
tween = nil
tweenL = nil


local arm = nil --localPlayer.Character:WaitForChild("RightUpperArm")
local shoulder = nil --arm:WaitForChild("RightShoulder")
local starterC0 = nil --shoulder.C0

local armL = nil --localPlayer.Character:WaitForChild("LeftUpperArm")
local shoulderL = nil --arm:WaitForChild("LeftShoulder")
local starterC0L = nil


local function SetChasePose()
	local tweenInfo = TweenInfo.new(script:GetAttribute("ChaseposeTime"), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	tween = game:GetService("TweenService"):Create(shoulder, tweenInfo, {C0 = starterC0})
	tween:Play()
	
	tweenL = game:GetService("TweenService"):Create(shoulderL, tweenInfo, {C0 = starterC0L})
	tweenL:Play()
end

local function SetPhantasmPose()
	local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local angleOffset = Vector3.new(75, -5, 20)
	
	local metaOffset = CFrame.new(Vector3.new(-0.25, 0, -0.25))*CFrame.Angles(math.rad(angleOffset.X), math.rad(angleOffset.Y), math.rad(angleOffset.Z))
	tween = game:GetService("TweenService"):Create(shoulder, tweenInfo, {C0 = starterC0 * metaOffset})
	tween:Play()
	
	local positionOffsetL = Vector3.new(0, -0.25, -0.55)
	local metaOffsetL = CFrame.new(positionOffsetL)*CFrame.Angles(math.rad(angleOffset.X), math.rad(angleOffset.Y), math.rad(angleOffset.Z))
	tweenL = game:GetService("TweenService"):Create(shoulderL, tweenInfo, {C0 = starterC0L * metaOffsetL})
	tweenL:Play()
end

local function SetRestPose()
	local tweenInfo = TweenInfo.new(script:GetAttribute("RestposeTime"), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	tween = game:GetService("TweenService"):Create(shoulder, tweenInfo, {C0 = starterC0})
	tween:Play()
	--if tween then tween:Cancel() end
	--tween = nil
end

local function SetArchiPose()
	local tweenInfo = TweenInfo.new(script:GetAttribute("RestposeTime"), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	tween = game:GetService("TweenService"):Create(shoulder, tweenInfo, {C0 = starterC0*CFrame.Angles(-12,0,0)})
	tween:Play()
end

--[[local function SetStalkerPose()
	local tweenInfo = TweenInfo.new(script:GetAttribute("RestposeTime"), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	tween = game:GetService("TweenService"):Create(shoulder, tweenInfo, {C0 =starterC0*CFrame.Angles(math.rad(7),0,0)*CFrame.new(0.5,1.5,-1)})
	tween:Play()
end

local function SetStalkerPose2()
	local tweenInfo = TweenInfo.new(script:GetAttribute("RestposeTime"), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	tween = game:GetService("TweenService"):Create(shoulder, tweenInfo, {C0 =starterC0*CFrame.Angles(math.rad(7),0,0)*CFrame.new(0.5,2,-0.2)})
	tween:Play()
end]]--

local function SetSecondStalkerPose()
	local tweenInfo = TweenInfo.new(script:GetAttribute("RestposeTime"), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	tween = game:GetService("TweenService"):Create(shoulder, tweenInfo, {C0 =starterC0*CFrame.Angles(math.rad(24),0,0)*CFrame.new(0.5,2,-0.2)})
	tween:Play()
end

isPlayingCutscene = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Intro").KillerCutScene

customBadCase = function ()
	return not isPlayingCutscene.Disabled
end

local prevstate = true
local wasmyers = false
local swunginpower = false

local function UpdatePose()
	if (localPlayer.Character:FindFirstChild("Stalker") ~= nil) or (localPlayer.Character:FindFirstChild("Psychopath") ~= nil) then
		
		local value = localPlayer.Backpack.Scripts.values.KillerAction.Value
		local Player = localPlayer
		local IsPower = false
		
		if Player.Character:GetAttribute("Power_Tier") then
			local tier = Player.Character:GetAttribute("Power_Tier")
			if tier >= 3 then
				IsPower = true
			end
		end
		if (localPlayer.Character:FindFirstChild('Psychopath') ~= nil) then
			if Player.Character:GetAttribute("Power_State") == "Using" then
				IsPower = true
			end
		end
		if value ~= "Nothing" or customBadCase() or IsPower then
			if value ~= "Nothing" or customBadCase() then
				SetRestPose()
				prevstate = false
				wasmyers = false
				if IsPower then
					swunginpower = true
				end
			else
				if not swunginpower then
					if (localPlayer.Character:FindFirstChild('Psychopath') ~= nil) then
						--SetStalkerPose()
					else
						--SetStalkerPose2()
					end
				else
					if (localPlayer.Character:FindFirstChild('Psychopath') ~= nil) then
						SetSecondStalkerPose()
					else
						--SetStalkerPose2()
					end
				end
			end
		else
			SetChasePose()
			swunginpower = false
		end
		wasmyers = IsPower
		return
	end
	
	if localPlayer.Character:GetAttribute("Power_State") ~= "Idle" then
		if (localPlayer.Character:FindFirstChild("Architect") ~= nil) then
			local value = localPlayer.Backpack.Scripts.values.KillerAction.Value
			if value ~= "Nothing" or customBadCase() or localPlayer.Character:GetAttribute("Power_State") ~= "Idle" then		--		reset arm C0 to default C0 while any  gameplay Interaction or Action is playing
				if prevstate == false then
					prevstate = true
				end
				SetArchiPose()
			else
				if prevstate == true then
					prevstate = false
					SetChasePose()
				end
			end
		end
		
		if (localPlayer.Character:FindFirstChild("Phantasm") ~= nil) then
			local value = localPlayer.Backpack.Scripts.values.KillerAction.Value
			if value == "Nothing" then		--		reset arm C0 to default C0 while any  gameplay Interaction or Action is playing
				if prevstate == false then
					prevstate = true
				end
				SetPhantasmPose()
			else
				if prevstate == true then
					prevstate = false
					SetChasePose()
				end
			end
		end
		
	else
		local value = localPlayer.Backpack.Scripts.values.KillerAction.Value
		if value ~= "Nothing" or customBadCase() then		--		reset arm C0 to default C0 while any  gameplay Interaction or Action is playing
			SetRestPose()
			prevstate = true
		else
			SetChasePose()
			prevstate = false
		end
	end
end

script:GetAttributeChangedSignal("AngleOffset"):Connect(function ()
	UpdatePose()
end)
script:GetAttributeChangedSignal("PositionOffset"):Connect(function ()
	UpdatePose()
end)
script:GetAttributeChangedSignal("PositionOffset2"):Connect(function ()
	UpdatePose()
end)
localPlayer.Backpack.Scripts.values.KillerAction.Changed:Connect(function (value)
	UpdatePose()
end)

rbxconAfterCutscene = nil
rbxconAfterCutscene = isPlayingCutscene.Changed:Connect(function ()
	if isPlayingCutscene.Disabled then
		rbxconAfterCutscene:Disconnect()
		
		arm = localPlayer.Character:WaitForChild("RightUpperArm")
		shoulder = arm:WaitForChild("RightShoulder")
		
		armL = localPlayer.Character:WaitForChild("LeftUpperArm")
		shoulderL = armL:WaitForChild("LeftShoulder")
		
		starterC0 = shoulder.C0
		starterC0L = shoulderL.C0
		
		UpdatePose()
	end
end)

--[[function CheckForStalkpower(child)
	if child.Name == "Stalk" then
		if rbxconStalkpowerAdded then rbxconStalkpowerAdded:Disconnect() rbxconStalkpowerAdded = nil end
		
		local stalkPower = child
		
		stalkPower:WaitForChild("PowerStuff").EvilWithin.Changed:Connect(function (value)
			if value == 3 then
				UpdatePose()
			else
				UpdatePose()
			end
		end)
		
		customBadCase = function ()
			return not isPlayingCutscene.Disabled or stalkPower.PowerStuff.EvilWithin.Value == 3
		end
	end
end

for _, child in pairs(localPlayer.Character:GetChildren()) do
	CheckForStalkpower(child)
end

rbxconStalkpowerAdded = localPlayer.Character.ChildAdded:Connect(function (child)
	CheckForStalkpower(child)
end)]]--
