local ReplicatedStorage, Players, TweenService, RunService = game:GetService('ReplicatedStorage'), game:GetService('Players'), game:GetService('TweenService'), game:GetService('RunService')

local moduleStorage : Folder, remoteStorage : Folder = ReplicatedStorage:WaitForChild('Modules'), ReplicatedStorage:WaitForChild('RemoteEvents')

local Player : Player = Players.LocalPlayer
local Character : Model = Player.Character or Player.CharacterAdded:Wait()

local Perk_Data = ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks')

local Humanoid : Humanoid = Character:WaitForChild('Humanoid')
local Animator : Animator = Humanoid:WaitForChild("Animator")

local Camera : Camera = workspace.CurrentCamera

local PlayerGui : PlayerGui = Player:WaitForChild('PlayerGui')

local Scripts : Model = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
local playerValues : Folder, playerPerks :Folder = Scripts:WaitForChild('values'), Scripts:WaitForChild('PerksBase')

local Modules = {
	Data = require(moduleStorage:WaitForChild('Data'));
	Code = require(moduleStorage:WaitForChild('Code'));
	Control = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls();
}

local Remotes = {
	Property = remoteStorage:WaitForChild('NewPropertie');
	Perk = remoteStorage:WaitForChild('Perk_Event');
}

local HasFixated, FixatedTier = Modules.Data:GetPerk("Fixated")
local HasUrban, UrbanTier = Modules.Data:GetPerk("UrbanEvasion")
local HasTenacity, TenacityTier = Modules.Data:GetPerk("Tenacity")
local HasBalanced, BalancedTier = Modules.Data:GetPerk("BalancedLanding")

local PerkSettings = {
	Fixated = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('Fixated')).Tiers;
	Urban = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('UrbanEvasion')).Tiers;
	Tenacity = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('Tenacity')).Tiers;
}

local Animations = {
	Landed = Animator:LoadAnimation(script:WaitForChild('Landed'))
}
--

local hooked = playerValues:WaitForChild("Hooked")
local action = playerValues:WaitForChild("Action")
local killer = Scripts:WaitForChild("Killer")
local shift = script.Parent:WaitForChild("Shift")
local crouching = playerValues:WaitForChild("Crouching")
local healthState = playerValues:WaitForChild("HealthState")
local holded = playerValues:WaitForChild("Holded")

local speed_values = {
	walk_speed = {
		default = 6.5;
	};
	crawl_speed = {
		default = 3.5
	};
	stagger_speed = {
		default = 0.5;
	};
}

local crawlSpeed = speed_values.crawl_speed.default

if HasTenacity then
	crawlSpeed *= PerkSettings.Tenacity[TenacityTier]
end

local tweenTime
local goalRad
local calc
local rotTween
local rootC0Tween
local tDELTA_GRADIENT =  1.6216
local sDELTA_GRADIENT = 0.002
local tBASE_TWEEN_TIME = 0.1486

local lastick, land, fall = nil, nil, nil
local land_min, land_max = 0.085, 0.6
local land_dur = 1.8
local land_took
local land_take_lapsed

local STAGGER_ENABLED = true
local fallingFromHeight = false

local c = 0

function land_event(balanced : boolean) : "Sets a timer?"
	local lastick = tick()
	local newgoal : number = math.clamp((land_took - land_min)/(land_max - land_min), land_dur * .25, land_dur) -- Set minimum landing time

	if balanced then
		newgoal *= require(Perk_Data:WaitForChild('Survivor'):WaitForChild('BalancedLanding')).Reduction -- reduce the stagger
	end

	local ToDivide = Animations.Landed.Length/newgoal


	task.spawn(function()
		c += 1

		while task.wait() do
			local lapsed = math.clamp(tick() - lastick, 0, newgoal)

			land_take_lapsed = lapsed

			if lapsed >= newgoal then
				break
			end


			if hooked.Value then
				if Animations.Landed.IsPlaying then
					Animations.Landed.IsPlaying:Stop()
				end

				fall = nil
				land = nil
				break
			end
		end

		land_take_lapsed = nil
	end)

	Animations.Landed:Play(0.1, 1, Animations.Landed.Length/newgoal)
end

local function RayCastDown() : IntValue
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Character}

	local rayCast = workspace:Raycast(Character:GetPivot().Position, Vector3.new(0, -1, 0) * 100, params)

	if rayCast then
		return (rayCast.Position - Character:GetPivot().Position).Magnitude
	end

	return 0 -- means it so far away we couldn't hit it or it bugged out
end

local function CheckState(Prior_State : Enum.HumanoidStateType, Current_State : Enum.HumanoidStateType) : "Generates our fall stagger"
	if not STAGGER_ENABLED then return end
	local rayDown : IntValue = RayCastDown()

	if Current_State == Enum.HumanoidStateType.Freefall and rayDown >= 5 then -- we are falling from valid height
		if not lastick then lastick = tick() end
		if not fall then fall = true end

		if rayDown >= 6.8 then
			fallingFromHeight = true -- falling from high enough height to stagger hard.
		end
	elseif Current_State == Enum.HumanoidStateType.Landed then -- we have landed
		if fall then fall = nil end

		if lastick then
			local lapsed = math.clamp(tick() - lastick, 0, land_max)

			if lapsed >= land_min then
				land_took = lapsed
				land = true

				if HasBalanced
					and fallingFromHeight
					and not Modules.Code:IsExhausted()
					and not Scripts.Killer.Value then

					Remotes.Perk:FireServer("Feather Fall")
					land_event(true)
				else
					land_event()
				end

				task.wait(.2)

				land = false
			end

			lastick = nil
		end


		fallingFromHeight = false
	end
end

Humanoid.StateChanged:Connect(CheckState)
Humanoid.AutoRotate = false

local flashing = false
local runCon

local function adjustCharRotation(finalWalkSpeed : number, step : number) : "Rotate us"

	if action.Value == "DeadHard" then
		if rotTween then
			rotTween:Pause()
		end
	elseif action.Value == "UsingFlashlight" then
		if rotTween then rotTween:Cancel() rotTween = nil end
		if rootC0Tween then rootC0Tween:Cancel() rootC0Tween = nil end

		Humanoid.AutoRotate = false
		--Humanoid.WalkSpeed = 9
	else -- run normally
		local moveVector : Vector3 = Modules.Control:GetMoveVector()
		local rotGoal : "Table" = {}
		local _, camRotX :number, _  = Camera.CFrame:ToOrientation() -- grab our current camera rotation

		local angle : number = (math.atan2(moveVector.X, moveVector.Z) + (math.pi)) % (math.pi * 2) 
		-- calculate where we want to turn go based off movement ^^ --

		Humanoid.AutoRotate = false

		if moveVector ~= Vector3.zero then -- we are moving
			local mag : number = (Humanoid.MoveDirection - Character:GetPivot().LookVector).Magnitude
			local moonwalk : boolean = false

			rotGoal.CFrame = CFrame.new(Character.PrimaryPart.Position) * CFrame.Angles(0, (angle + camRotX), 0)
			goalRad = angle + camRotX

			-- Calculate walkspeed and tween time
			local calcRad = math.abs(goalRad - math.rad(Character.PrimaryPart.Orientation.Y)) -- calculates how far to turn?

			if calcRad > math.pi or calcRad < -math.pi then -- if we want to turn a full circle i think? | Readjust calcRad to be correct
				calcRad = math.abs(math.pi*2 - calcRad)
			end

			tweenTime = tBASE_TWEEN_TIME * calcRad
			Humanoid.WalkSpeed = finalWalkSpeed - (calcRad*tDELTA_GRADIENT)


			if mag >= 1.5 and mag < 2 then -- difference in the direction we are moving + looking | if the difference is in a certain threshold we are trying to moon walk
				moonwalk = true
			end

			if moonwalk then -- if we are moonwalking readjust the speed to be normal
				Humanoid.WalkSpeed = finalWalkSpeed
			end

			-- landed code --
			if land and land_take_lapsed then
				local result = (land_take_lapsed/land_dur) * finalWalkSpeed
				Humanoid.WalkSpeed = result * 0.2
			end

			if fall or land then -- if we have fallen or landed do not rotate us
				return
			end

			-- Apply the turn tween --
			rotTween = TweenService:Create(Character.PrimaryPart, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), rotGoal)
			rotTween:Play()
		elseif rotTween then
			rotTween:Pause()
		end
	end
end

function updateEvent(step : number) : "Main Run Service Loop"
	if hooked.Value then return end -- cancel the movement
	
	if (Player:FindFirstChild("PlayerValues") == nil) then
		return
	end
	
	local finalWalkSpeed : number = Modules.Code:GetPlayerValue(Player, "Speed") * Modules.Code:GetPlayerValue(Player, "SpeedMultiplier")

	if Character:GetAttribute("Motion_Locked") then
		finalWalkSpeed = 0 -- do nothing
		--print('--')
	elseif (healthState.Value > 0) then

		if not Character:GetAttribute("Sprint") and not Character:GetAttribute("Crouch") then
			-->> must be walking apply fixated buff << --
			if (HasFixated) then
				finalWalkSpeed *= PerkSettings.Fixated[FixatedTier]
			end
		end

		if (action.Value == "UsingFlashlight") then
			finalWalkSpeed = speed_values.walk_speed.default -- normal walk speed
		end

		if (string.find(action.Value, "Heal")) then
			finalWalkSpeed = 0
		end

		if Animations.Landed.IsPlaying then
			finalWalkSpeed = speed_values.stagger_speed.default
		end

		adjustCharRotation(finalWalkSpeed, step)
	else
		finalWalkSpeed = crawlSpeed

		if (holded.Value) then
			finalWalkSpeed = 0
		end

		--warn(Humanoid.WalkSpeed .. ':' .. finalWalkSpeed)

		Humanoid.AutoRotate = true
	end


	--print('Desired:', finalWalkSpeed)
	--warn('Human:', Humanoid.WalkSpeed)

	--warn(finalWalkSpeed)

	if action.Value ~= "DeadHard" then
		Humanoid.WalkSpeed = finalWalkSpeed
	end
end

playerValues:WaitForChild('Vaulting').Changed:Connect(function()
	if playerValues.Vaulting.Value then
		STAGGER_ENABLED = false
	else
		STAGGER_ENABLED = true
		CheckState(nil, Humanoid:GetState()) -- gives us window stagger
	end
end)

action.Changed:Connect(function()

	if action.Value == "Nothing"
		or action.Value == "Shocked"
		or action.Value == "UsingFlashlight" then

		if not runCon and not killer.Value then -- reboot main loop
			runCon = game:GetService("RunService").Heartbeat:Connect(updateEvent)
		end
	else
		if rootC0Tween then rootC0Tween:Cancel() rootC0Tween = nil end
		if rotTween then rotTween:Cancel() rotTween = nil end
		if runCon then runCon:Disconnect() runCon = nil end
	end
end)

hooked.Changed:Connect(function()
	if hooked.Value then
		STAGGER_ENABLED = false
	else
		task.delay(.2, function()
			STAGGER_ENABLED = true
		end)
	end
end)

--[[]]--

--[[shift.Changed:Connect(function()
	
	if (shift.Value) then
		Modules.Code.Speeds:addMultiplier(Player, "Sprint", Modules.Code.Speeds.Survivor.Running, -1)
		Modules.Code.Speeds:removeMultiplier(Player, "Crouch")
	else
		Modules.Code.Speeds:removeMultiplier(Player, "Sprint")
	end
end)

crouching.Changed:Connect(function()
	
	if (crouching.Value) then
		Modules.Code.Speeds:addMultiplier(Player, "Crouch", Modules.Code.Speeds.Survivor.Crouching, -1)
		Modules.Code.Speeds:removeMultiplier(Player, "Sprint")
	else
		Modules.Code.Speeds:removeMultiplier(Player, "Crouch")
	end
end)]]--

if not runCon and not killer.Value then
	runCon = game:GetService("RunService").Heartbeat:Connect(updateEvent)
end
