local Players = game.Players

local PowerModel = script.Parent
--local Addons = PowerModel.Addons
local PowerValues = PowerModel.PowerValues
local PowerRemote = PowerValues.PowerRemote
local PowerEvent = PowerValues.PowerEvent

local Player: Player = Players:GetPlayerFromCharacter(PowerModel.Parent)
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character.Humanoid
local RootPart = Character.HumanoidRootPart

local KillerData = require(game.ReplicatedStorage.Game_Data.Killers.Phantasm)
local AddonData = game.ReplicatedStorage.Game_Data.Addons.Killer
local Code = require(game.ReplicatedStorage.Modules:WaitForChild("Code"))
local Data = require(game.ReplicatedStorage.Modules:WaitForChild("Data"))

local validActions = {"Nothing", "SendWave", "SpawnAfterImage"}
local Wave = game.ReplicatedStorage.KillerStuff.Phantasm.Phantasm_Wave
local PhantomModel = PowerModel:WaitForChild("PhantomModel")
local PhantomAnim = nil

local Params = RaycastParams.new()

local timer = {}
local phantasmList = {}
local count = 0

local initialized = false

function initialize()
	
	SetPowerValues()
	CreatePhantoms()
	PrepareParams()
	LinkPlayerEvents()
	ApplyAddons()
	
	PhantomAnim = Instance.new("Animation")
	PhantomAnim.AnimationId = "rbxassetid://113250413358320"
	PhantomAnim.Parent = script
	
	initialized = true
	PowerModel:SetAttribute("Initialized", true)

	game["Run Service"].Heartbeat:Connect(Update)
end

function LinkPlayerEvents()
	for i, plr: Player in pairs(game.Teams.Survivor:GetPlayers()) do
		plr.CharacterRemoving:Once(CharacterRemoved)
	end
end

function PrepareParams()
	
	Params.FilterType = Enum.RaycastFilterType.Exclude
	
	local filter = {}
	
	for i, plr: Player in pairs(game.Players:GetPlayers()) do
		local char = plr.Character or plr.CharacterAdded:Wait()
		table.insert(filter, char)
	end
	
	Params.FilterDescendantsInstances = filter
end

function CreatePhantoms()
	
	repeat task.wait()
	until game.ReplicatedStorage.Match.Started.Value
	
	task.wait(5)
	
	PhantomModel.Parent = workspace
	
	for i, plr: Player in pairs(game.Players:GetPlayers()) do
		
		timer[plr.Name] = PowerValues:GetAttribute("Phantasm_Frequency")
		phantasmList[plr.Name] = {}
		
		local desc = Character.Humanoid:GetAppliedDescription()
		local phantom : Model = game.StarterPlayer.StarterCharacter:Clone()
		phantom.Name = `{plr.Name}_Phantom`
		phantom.Parent = PowerModel.Phantoms
		
		phantom.PrimaryPart.Anchored = true
		phantom.PrimaryPart.CFrame = CFrame.new(Vector3.new(0, 500, 0))
		
		phantom.Humanoid:ApplyDescription(desc)
		phantom:SetAttribute("Owner", plr.Name)
		
		local particles = game.ReplicatedStorage.KillerStuff.Phantasm.PhantasmParticles:Clone()
		particles.Parent = phantom.PrimaryPart
		
		local BodyMotor = Instance.new("Motor6D")
		BodyMotor.Name = "BodyMotor"
		BodyMotor.Parent = phantom.PrimaryPart
		BodyMotor.Part0 = phantom.PrimaryPart
		BodyMotor.Part1 = particles
		BodyMotor.C1 = CFrame.new(0, 8, 0.25)
		
		for _, v in pairs(phantom:GetDescendants()) do
			
			if (v:IsA("Decal") or v:IsA("LocalScript") or v:IsA("Script") or v:IsA("Folder")) then
				v:Destroy()
			end
			
			if (v:IsA("BasePart")) then
				v.Transparency = 1
			end
		end
		
		phantom.PrimaryPart.Hitbox:Destroy()
		
		phantom["Body Colors"].HeadColor3 = Color3.fromRGB(0, 0 ,0)
		phantom["Body Colors"].LeftArmColor3 = Color3.fromRGB(0, 0 ,0)
		phantom["Body Colors"].RightArmColor3 = Color3.fromRGB(0, 0 ,0)
		phantom["Body Colors"].LeftLegColor3 = Color3.fromRGB(0, 0 ,0)
		phantom["Body Colors"].RightLegColor3 = Color3.fromRGB(0, 0 ,0)
		phantom["Body Colors"].TorsoColor3 = Color3.fromRGB(0, 0 ,0)
		phantom.Neck.Handle.Color = Color3.fromRGB(0, 0, 0)
	end
	
end

function SetPowerValues()
	PowerValues:SetAttribute("Current", KillerData.Wave_Start_Percentage)
	PowerValues:SetAttribute("Wave_Recharge_Rate", KillerData.Wave_Recharge)
	PowerValues:SetAttribute("Wave_Distance", KillerData.Wave_Distance)
	PowerValues:SetAttribute("Wave_Travel_Time", KillerData.Wave_Travel_Time)
	
	PowerValues:SetAttribute("Phantasm_Frequency", KillerData.Phantasm_Frequency)
	PowerValues:SetAttribute("Phantasm_Lifetime", KillerData.Phantasm_Lifetime)
	PowerValues:SetAttribute("Phantasm_Maximum", KillerData.Phantasm_Maximum)
	
	PowerValues:SetAttribute("Teleport_Curve", KillerData.Teleport_Curve)
	PowerValues:SetAttribute("Teleport_Boost_Duration", KillerData.Teleport_Boost_Duration)
	PowerValues:SetAttribute("Teleport_Boost_Percentage", KillerData.Teleport_Boost_Percentage)
	PowerValues:SetAttribute("Teleport_Slow_Duration", KillerData.Teleport_Slow_Duration)
	PowerValues:SetAttribute("Teleport_Slow_Percentage", KillerData.Teleport_Slow_Percentage)
	
	Wave:SetAttribute("Duration", KillerData.Darkness_Duration)
end

function ApplyAddons()
	local Addons_Data = Data:GetAddons("Killer", game.Players[Player.Name])

	for _,Addon in pairs(Addons_Data) do
		if (script.Addons:FindFirstChild(Addon) ~= nil) then
			require(script.Addons:FindFirstChild(Addon)).Init(SpawnPhantasm, Player)
		end
	end
end

function Update(delta)
	
	for i, v in pairs(game.Teams.Survivor:GetPlayers()) do
		TickCooldown(v, delta)
	end
	
	if (PowerValues:GetAttribute("Current") >= 100) then
		return
	end
	
	local current = PowerValues:GetAttribute("Current")
	local rate = PowerValues:GetAttribute("Wave_Recharge_Rate")
	current += (rate * delta)
	
	PowerValues:SetAttribute("Current", current)
end

function TickCooldown(Plr: Player, delta)

	if (not Code:GetEffect("Darkness", Plr)) then
		timer[Plr.Name] = PowerValues:GetAttribute("Phantasm_Frequency")
		return
	end
	
	if (Plr.Character == nil) then
		timer[Plr.Name] = PowerValues:GetAttribute("Phantasm_Frequency")
		return
	end
	
	if (Code:GetHealthState(Plr) < 1) then
		timer[Plr.Name] = PowerValues:GetAttribute("Phantasm_Frequency")
		return
	end
	
	if (Code:IsHooked(Plr)) then
		timer[Plr.Name] = PowerValues:GetAttribute("Phantasm_Frequency")
		return
	end

	if (timer[Plr.Name] > 0) then
		timer[Plr.Name] -= delta
		return
	end
	
	timer[Plr.Name] = PowerValues:GetAttribute("Phantasm_Frequency")
	SpawnPhantasm(Plr.Character)
end

function SpawnPhantasm(plr: Model, desiredCFrame : CFrame)

	count += 1

	local desiredCFrame = desiredCFrame or plr.PrimaryPart.CFrame
	desiredCFrame = GroundCheck(desiredCFrame)

	local phantom : Model = PowerModel.Phantoms[`{plr.Name}_Phantom`]:Clone()
	phantom.Name = `{phantom.Name}_{count}`
	phantom.Parent = workspace.PhantomModel
	phantom.PrimaryPart.CFrame = desiredCFrame

	coroutine.wrap(function()
		task.wait(PowerValues:GetAttribute("Phantasm_Lifetime") + 1)

		RemovePhantasm(plr, phantom)
	end)()

	for i, v in pairs(phantom:GetDescendants()) do
		if (v:IsA("BasePart")) then

			v.CanCollide = false
			v.CollisionGroup = "NoCollision"

			if (v.Name == "HumanoidRootPart" or v.Name == "PhantasmParticles") then
				continue
			end

			local tween = game.TweenService:Create(v, TweenInfo.new(1.4), {Transparency = 0})
			tween:Play()
			
			tween.Completed:Connect(function()
				phantom:SetAttribute("Deployed", true)
			end)
		end
	end

	if (#phantasmList[plr.Name] >= PowerValues:GetAttribute("Phantasm_Maximum")) then
		RemovePhantasm(plr, phantom)
	end
	
	local animTemp = phantom.Humanoid.Animator:LoadAnimation(PhantomAnim)
	animTemp:Play()

	table.insert(phantasmList[plr.Name], phantom)

	Data:GiveBlood(Player, 350, "Deviousness", "SPAWNED PHANTASM")
end

function GroundCheck(targetCFrame: CFrame)
	
	local position = targetCFrame.Position
	local raycast = workspace:Raycast(position, (-Vector3.yAxis * 50), Params)
	local rx, ry, rz = targetCFrame:ToEulerAnglesXYZ()
	
	if (raycast) then
		local intersectionPoint = raycast.Position
		intersectionPoint = Vector3.new(intersectionPoint.X, intersectionPoint.Y + 3.5, intersectionPoint.Z)
		
		targetCFrame = CFrame.new(intersectionPoint) * CFrame.Angles(0, ry, 0)
		return targetCFrame
	end
	
	return targetCFrame
end

function RemovePhantasm(player: Player, phantom: Model)
	
	if (phantom.Parent == nil) then
		return
	end

	local toDelete = table.find(phantasmList[player.Name], phantom)

	if (toDelete == nil) then
		return
	end

	table.remove(phantasmList[player.Name], toDelete)
	phantom:SetAttribute("Deployed", false)

	for i, v in pairs(phantom:GetDescendants()) do

		if (v:IsA("BasePart") and v.Name ~= "UpperTorso" and v.Name ~= "HumanoidRootPart") then
			local tween = game.TweenService:Create(v, TweenInfo.new(1), {Transparency = 1})
			tween:Play()
		end

		local tween = game.TweenService:Create(phantom.UpperTorso, TweenInfo.new(1), {Transparency = 1})
		tween:Play()

		tween.Completed:Once(function()
			phantom:Destroy()
		end)
	end
end

function PlayerJoined(Plr: Player)
	Plr.CharacterRemoving:Connect(function()
		CharacterRemoved(Plr)
	end)
	
	Plr.Destroying:Connect(function()
		CharacterRemoved(Plr)
	end)
end

function CharacterRemoved(Plr: Player)
	for count = 1, #phantasmList[Plr.Name] do
		RemovePhantasm(Plr, phantasmList[Plr.Name][count])
	end
end

function OnCollision(Wave, collidedPart)
	local Collision = Wave.default

	if (not Wave:GetAttribute("Active")) then
		return
	end

	if PowerValues:GetAttribute("Interactable_Block_Duration") then
		if string.match(collidedPart.Parent.Name, "Window") and collidedPart.Parent:GetAttribute("IsInteractable") then
			coroutine.wrap(function()
				if collidedPart.Parent:FindFirstChild("Panel"):FindFirstChild("Blocked").Value then 
					return
				end
				
				local BlockLogic = require(collidedPart.Parent:FindFirstChild("Panel"):FindFirstChild("BlockLogic"))
				
				BlockLogic:BlockWindow(PowerValues:GetAttribute("Interactable_Block_Duration"))
			end)()
		end
	end

	local Player: Player = game.Players:FindFirstChild(collidedPart.Parent.Name)
	local Player2: Player = game.Players:FindFirstChild(collidedPart.Parent.Parent.Name)

	if (Player == nil and Player2 == nil) then
		return
	end

	Player = Player or Player2

	if (Player.Team ~= game.Teams.Survivor) then
		return
	end
	
	if (Code:GetHealthState(Player) < 1 or Code:IsHooked(Player)) then
		return
	end

	if PowerValues:GetAttribute("InstantlySpawn") then --prevents stacking, idk if stacking is even intended but alr
		if not (#phantasmList[Player.Name] > PowerValues:GetAttribute("Phantasm_Maximum"))  then 
			SpawnPhantasm(Player.Character)
			return
		end
		
		return
	end

	Code:SetEffect("Darkness", Player, workspace:GetServerTimeNow() + Wave:GetAttribute("Duration"))
	Player.Character:SetAttribute("DarknessTimer", Wave:GetAttribute("Duration") .. ":" ..  workspace:GetServerTimeNow())
	
	Data:GiveBlood(Player, 100, "Deviousness", "INFECTED!")
end


function CommandReceived(Player, Command, ...)
	
	local args = {...}
	
	if (Command == "SetValue") then
		SetValue(args[1], args[2])
	end
	
	if (Command == "Action") then
		SetAction(args[1])
	end
	
	if (Command == "SendWave") then
		
		if (PowerValues:GetAttribute("Current") < 100) then
			return
		end
		
		_G.GetValue(Player.Name, "DisruptiveActions"):Add("Ability_Phantasm", 1, nil)
		
		coroutine.wrap(function()
			local Connection = nil
			
			local pos  = Character.PrimaryPart.CFrame.Position
			local direction = Character.PrimaryPart.CFrame.LookVector
			direction = Vector3.new(direction.X, 0, direction.Z)
			
			local x, y, z = CFrame.new(pos, pos + (direction * 6)):ToEulerAnglesXYZ()
			y = math.rad(math.deg(y) + 180)
			Wave.PrimaryPart.CFrame = CFrame.new(pos + (direction * 5)) * CFrame.Angles(x, y, z)
			Wave.Parent = workspace
			
			Wave.default.BodyEmitter.Enabled = true
			Wave:SetAttribute("Active", true)
			
			Connection = game:GetService("RunService").Heartbeat:Connect(function() --actually allows us to detect objects such as windows
				for _,collidedPart in pairs(workspace:GetPartsInPart(Wave.default)) do
					OnCollision(Wave, collidedPart)
				end
			end)
			
			pos  = Character.PrimaryPart.CFrame.Position
			direction = Character.PrimaryPart.CFrame.LookVector
			direction = Vector3.new(direction.X, 0, direction.Z)

			x, y, z = CFrame.new(pos , pos + (direction * 6)):ToEulerAnglesXYZ()
			y = math.rad(math.deg(y) + 180)
			
			local travelTime = (PowerValues:GetAttribute("Wave_Travel_Time") * PowerValues:GetAttribute("Wave_Distance"))
			local tween = game.TweenService:Create(
				Wave.PrimaryPart, TweenInfo.new(travelTime), 
				{CFrame = CFrame.new(pos + (direction * PowerValues:GetAttribute("Wave_Distance"))) * CFrame.Angles(x, y, z)}
			)
			tween:Play()
			
			tween.Completed:Connect(function()
				if Connection then
					Connection:Disconnect()
					Connection = nil
				end
				
				Wave:SetAttribute("Active", false)
				Wave.default.BodyEmitter.Enabled = false
				_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability_Phantasm")
				Data:GiveBlood(Player, 75, "Deviousness", "SENT WAVE")
			end)
		end)()
		
		PowerValues:SetAttribute("Current", 0)
	end
	
	if (Command == "SpawnAfterImage") then

		if (PowerValues:GetAttribute("Current") < 100) then
			return
		end

		_G.GetValue(Player.Name, "DisruptiveActions"):Add("Ability_Phantasm", 1, nil)

		coroutine.wrap(function()
			SpawnPhantasm(Player.Character)
			
			_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability_Phantasm")
		end)()

		PowerValues:SetAttribute("Current", 0)
	end
	
	if (Command == "Teleport") then

		local phantom = args[1]

		if (phantom.Parent == nil) then
			return
		end

		local soundPart = PowerValues.SoundPart:Clone()
		soundPart.Parent = workspace
		local sound: Sound = soundPart.TPSound

		soundPart.CFrame = phantom.PrimaryPart.CFrame
		sound.TimePosition = 0.8

		sound:Play()

		_G.GetValue(Player.Name, "DisruptiveActions"):Add("Ability", 1, nil)
		
		local cframe = phantom.PrimaryPart.CFrame
		local position: Vector3 = cframe.Position
		position = Vector3.new(position.X, position.Y + 1.25, position.Z)
		
		local direction = cframe.LookVector
		direction = Vector3.new(direction.X, 0, direction.Z)

		local x, y, z = Player.Character.PrimaryPart.CFrame.Rotation:ToOrientation()
		local rx, ry, rz = CFrame.lookAt(position, position + (direction * 5)):ToOrientation()
		Character.PrimaryPart.CFrame = CFrame.new(position) * CFrame.Angles(x, y, z)

		--TODO: figure out this rotation thing, it simply DOES NOT WORK. i think something else is controlling this rotation thing

		if PowerValues:GetAttribute("Undetectable_Duration") then
			Code:SetEffect("Hidden", Player, PowerValues:GetAttribute("Undetectable_Duration"), "Addon_NightmareFuel")
		end

		sound.Ended:Once(function()
			_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")
			soundPart:Destroy()
		end)

		RemovePhantasm(game.Players[phantom:GetAttribute("Owner")], phantom)
		Data:GiveBlood(Player, 200, "Deviousness", "TELEPORTED")
	end
	
end

function SetAction(Action)
	
	local killerAction = Player.Backpack.Scripts.values.KillerAction
		
	if (table.find(validActions, killerAction.Value) ~= nil or Action == nil) then
		return
	end
		
	if (table.find(validActions, Action) == nil) then
		return
	end
		
	killerAction.Value = Action
end

function SetValue(Attribute, Value)
	PowerModel:SetAttribute(Attribute, Value)
end

initialize()

PowerRemote.OnServerEvent:Connect(CommandReceived)
Players.PlayerAdded:Connect(PlayerJoined)