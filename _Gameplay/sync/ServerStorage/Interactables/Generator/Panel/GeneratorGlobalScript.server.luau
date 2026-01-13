self = require(script.Utilty)
local effectsModule = require(script:WaitForChild("EffectsModule"))

local Item_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Items')
local HTTPService = game:GetService("HttpService")

local Events = require(game.ServerScriptService["Event System"].Events)
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Remotes = ReplicatedStorage:WaitForChild('RemoteEvents')
local Modules = ReplicatedStorage:WaitForChild("Modules")

local BaseValues = require(Modules:WaitForChild("BaseValues"))
local Code = require(Modules:WaitForChild("Code"))
local Data = require(Modules:WaitForChild("Data"))

local generator = script.Parent.Parent
local rootPart = generator:WaitForChild("RootPart")
local panel = generator:WaitForChild("Panel")
local Popped = panel:WaitForChild('Popped')
local progress = panel:WaitForChild("Progress") 

local broke = panel:WaitForChild("Broke")
local exploded = panel:WaitForChild("Exploded")
local beingWorked = panel:WaitForChild("BeingWorked")
local skillChecks = panel:WaitForChild("SkillChecks")
local regressionspeed = panel:WaitForChild("RegressionSpeed")
local currentPlayersRepairing = script.Parent:WaitForChild("CurrentPlayersRepairing")

local Regress_Effect = rootPart:WaitForChild('Attachment')

local GeneratorsRepaired = workspace:WaitForChild("MatchValues"):WaitForChild("GeneratorsRepaired")
local SendSkillCheck = ReplicatedStorage.RemoteEvents:WaitForChild("SendSkillCheck")

local GeneratorSettings = {
	Speeds = {
		Repair = 12;
		Regress = 3.5;
		Stack_Decrease = 0.4; -- amount lossed when stacked
	},
	PreviousBlocked = false;
	LastSkillCheck = workspace:GetServerTimeNow();
	SkillChecks = {};
	Workers = {};
}

local gettingRepaired, stuttering, notified = false, tick(), false

local portsTable = {"Front", "Right", "Left", "Back"} 

local WorkerList = {}
local Connections = {}

local Perks = {
	["Quick Fix"] = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('QuickFix'));
	["Sabotage"] = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Sabotage'));
}

local ValuesToCreate = {
	["Blocked"] = function(...) SetBlocked(...) end
}

function Initialize()
	CreateValues()
	
	for _, port in pairs(generator.Workspots:GetChildren()) do

		if port then
			local occupied = port:WaitForChild("Ocuped")
			local occupant = port:WaitForChild("Ocupant")
			local deactivated = occupied:WaitForChild("Deactivated")
			local player : Player = game.Players:FindFirstChild(occupant.Value)

			occupant.Changed:Connect(function()
				PortUpdated(port)
			end)
		end
	end
	
	SendSkillCheck.OnServerEvent:Connect(SkillCheckReceived)
end

function CreateValues()
	_G.ObjectValues[generator.Name] = {}

	for key, value in (ValuesToCreate) do
		CreateValue(key, value)
	end
end

function CreateValue(name, func)
	local clonedModule = game.ServerStorage.Modules.ValueTemplateObject:Clone()
	local valueMod = require(clonedModule)
	valueMod.New(function(...) func(...) end)

	_G.ObjectValues[generator.Name][name] = valueMod
end

function SetBlocked(Duration)

	local toBlock = Duration > 0

	if (GeneratorSettings.PreviousBlocked ~= toBlock) then
		generator:SetAttribute("Blocked", toBlock)
		GeneratorSettings.PreviousBlocked = toBlock
	end
end

function Particles(bool)
	if bool then
		for _,p in pairs(Regress_Effect:GetChildren())do
			if p:IsA('ParticleEmitter') then
				if not p.Enabled then
					p.Enabled = true
				end
			end
		end
	else
		for _,p in pairs(Regress_Effect:GetChildren())do
			if p:IsA('ParticleEmitter') then
				if p.Enabled then
					p.Enabled = false
				end
			end
		end
	end
end

function PortUpdated(Port)
	CacheWorkers()
end

function notify_nearby()
	local players = game.Players:GetChildren()

	for _,SelectedPlayer in pairs(players)do -- loop through all players
		local C = SelectedPlayer.Character

		if C and C:FindFirstChild('HumanoidRootPart') then

			if (C.HumanoidRootPart.Position - rootPart.Position).magnitude <= 6 then -- if they are closer then 6 studs
				C:SetAttribute("Curse_Reverse", true) -- notify through attributes
			end
		end
	end
end

exploded.Changed:Connect(function()

	if exploded.Value then
		exploded.Value = false

		for i, plr in pairs(game.Teams.Killer:GetPlayers()) do
			Code:AddNotification(generator.PrimaryPart.CFrame, 5, "Generator_Miss", plr) -->> notify killers
		end


		local explosionSound = game.ServerStorage.ExplosionSound:Clone()
		explosionSound.Parent = generator.PrimaryPart

		explosionSound:Play()

		local pointLight = Instance.new("PointLight")
		pointLight.Brightness = 30
		pointLight.Color = Color3.fromRGB(255,222,137)
		pointLight.Enabled = true
		pointLight.Range = 0
		pointLight.Shadows = true
		pointLight.Name = "ExplosionLight"
		pointLight.Parent = generator.PrimaryPart

		local goal = {}
		goal.Range = 9

		local tween = self.Services.TS:Create(pointLight,TweenInfo.new(0.6),goal) tween:Play()
		local tweenCon1 tweenCon1 = tween.Completed:Connect(function()
			local goal = {}
			goal.Range = 0

			local tween = self.Services.TS:Create(pointLight,TweenInfo.new(0.6),goal) tween:Play()
			local tweenCon2 tweenCon2 = tween.Completed:Connect(function()
				pointLight:Destroy()
				explosionSound:Destroy()
				tweenCon1:Disconnect()
				tweenCon2:Disconnect()
			end)
		end)	

		local smokeParticle1 = generator.FuelEscape1.Smoke
		local smokeParticle2 = generator.FuelEscape2.Smoke
		smokeParticle1.Enabled = true
		smokeParticle2.Enabled = true
		wait(2)
		smokeParticle1.Enabled = false
		smokeParticle2.Enabled = false
	end
end)

local Entity = generator:WaitForChild('Entity')
local Entity_Tracks = {
	Idle = Entity:WaitForChild('AnimationController'):WaitForChild('Animator'):LoadAnimation(script:WaitForChild('Entity_Idle'));
	Blocked = Entity:WaitForChild('AnimationController'):WaitForChild('Animator'):LoadAnimation(script:WaitForChild('Entity_Blocked'));
}

Entity_Tracks.Idle:Play()

pumpsTracks = {}
pumpsTable = {}
pumpsSounds = {}

script.Parent.Parent:WaitForChild("Pumps")
for _, this in pairs(script.Parent.Parent.Pumps:GetChildren()) do

	local index = string.gsub(string.lower(this.Name), "pump", "", 1)
	index = tonumber(index)

	pumpsTable[index] = this

	local pumpAnimationController = this:WaitForChild("AnimationController")
	pumpsTracks[index] = pumpAnimationController:LoadAnimation(script.Moving)
	pumpsTracks[index]:Play(0, 1, 0)
	if index <= 4 then
		pumpsTracks[index].TimePosition = 1/8*(index-1)
	elseif index >= 5 then
		pumpsTracks[index].TimePosition = 1/8*((index-4)-1)
	end

	pumpsTracks[index].DidLoop:Connect(function()
		pumpsSounds[index].TimePosition = 0
		pumpsSounds[index].PlaybackSpeed = 1
		pumpsSounds[index].Playing = true
	end)
end

cclaimedPumpSoundId = 3389093396

for index, pump in pairs(pumpsTable) do
	local thisSound = Instance.new("Sound", pump.RootPart)
	thisSound.Name = "PumpSound"
	--thisSound.EmitterSize = 2
	thisSound.RollOffMaxDistance = 60
	thisSound.Volume = 0.35 -- was 1.95
	thisSound.SoundId = "rbxassetid://".. tostring(3389093396)
	pumpsSounds[index] = thisSound
end

local StoredProgress = 0

function AddProgress(V)
	V += StoredProgress -- add our old values first

	local D = math.floor(V) -- gets v lowered to a whole number
	StoredProgress = V - D

	return D
end

function GetToolBonus(Character : Model) : "Return Toolbox Bonus Repair Speed"
	local tool = nil

	for _, model in pairs(Character:GetChildren()) do

		if model:GetAttribute("Tool") and model:GetAttribute("Class") == "Toolbox" then
			tool = model
			break
		end
	end

	if tool then
		local Tool_Module = Item_Data:FindFirstChild(tool.Name)

		if Tool_Module then
			Tool_Module = require(Tool_Module)
		else
			Tool_Module = require(Item_Data:WaitForChild('Brown_Toolbox'))
		end

		return tool['Server-Script'].RepairSpeed.Value
	end

	return 0
end

function getRepairSpeed(Player, delta, StackCount) --TODO: store players in {} for performance reasons
	local occupantChar = workspace:FindFirstChild(Player)
	local FinalAdjustment = 0

	if (occupantChar ~= nil) then
		local BaseRepairSpeed = Code:GetPlayerValue(Player, "RepairSpeed")
		FinalAdjustment = BaseRepairSpeed

		local currentPlayer = game.Players[occupantChar.Name]
		local Scripts = currentPlayer:WaitForChild('Backpack'):WaitForChild('Scripts')
		local values = Scripts:WaitForChild('values')
		local perkbase = Scripts:WaitForChild('PerksBase')
		local playerData = currentPlayer:WaitForChild('Data')

		local equippedData = playerData:WaitForChild('Perks'):WaitForChild('Survivor')
		local hasFix = false 

		for _, perkslot in pairs(equippedData:GetChildren()) do

			if perkslot.Name == 'QuickFix' then
				hasFix = true
			end
		end

		if values.Action.Value == "ToolBoxRepair" then -- has a toolbox
			FinalAdjustment += math.clamp((BaseRepairSpeed * GetToolBonus(occupantChar)) - BaseRepairSpeed, 0, 80)
		end

		if tonumber(perkbase.QuickFix.Charge.Value) < 100 and hasFix then
			perkbase.QuickFix.Charge.Value = tostring(tonumber(perkbase.QuickFix.Charge.Value) + ((100/Perks["Quick Fix"].Charge_Time) * delta))
		end
	end

	FinalAdjustment = math.clamp(FinalAdjustment, 0, 100)

	return FinalAdjustment
end

function CacheWorkers()
	
	-- Remove the Stacking Debuff from everyone
	for i, plr in pairs(GeneratorSettings.Workers) do
		local player : Player = game.Players:FindFirstChild(plr)
		_G.GetValue(player, "RepairSpeed"):Remove("StackDebuff")
	end
	
	GeneratorSettings.Workers = {}

	-- Cache the players working on the generator rn
	for _, port in pairs(generator.Workspots:GetChildren()) do

		if port then
			local occupied = port:WaitForChild("Ocuped")
			local occupant = port:WaitForChild("Ocupant")
			local deactivated = occupied:WaitForChild("Deactivated")
			local player : Player = game.Players:FindFirstChild(occupant.Value)

			if player and player.Team ~= game.Teams:WaitForChild('Killer')
				and occupied.Value and not deactivated.Value then


				player.Character:SetAttribute("CurrentInteractable", generator.Name)
				table.insert(GeneratorSettings.Workers, occupant.Value)
			end
		end
	end
	
	-- Add the Stacking Debuff to everyone on the new list
	
	if (#GeneratorSettings.Workers <= 1) then
		return
	end
	
	local StackDebuff = (Code.BaseValues.Survivor.Action.RepairSpeed * Code.BaseValues.Gameplay.GeneratorStackDecrease) * (#GeneratorSettings.Workers - 1)
	
	for i, plr in pairs(GeneratorSettings.Workers) do
		local player : Player = game.Players:FindFirstChild(plr)
		_G.GetValue(player, "RepairSpeed"):Add("StackDebuff", -StackDebuff, -1)
	end
end

function SpawnSkillCheck()
	
	if (#GeneratorSettings.Workers <= 0
		or progress.Value >= 900
		or (workspace:GetServerTimeNow() - GeneratorSettings.LastSkillCheck) < 4) then
		return
	end
	
	GeneratorSettings.LastSkillCheck = workspace:GetServerTimeNow()
	
	for i, worker in pairs(GeneratorSettings.Workers) do
		local player : Player = game.Players:FindFirstChild(worker)
		
		if (math.random(1, 100) > BaseValues.Gameplay.SkillCheckChances.Generator) then
			continue
		end
		
		local randomID = HTTPService:GenerateGUID(false)
		
		local SkillCheckConfig = {
			Sizes = {4, 12}
		}
		
		GeneratorSettings.SkillChecks[randomID] = 1
		SendSkillCheck:FireClient(player, randomID, SkillCheckConfig, "Repair")
	end
	
end

local function Handle_Pumps()
	local this = (1000/#pumpsTable)
	
	if (this <= 0) then
		for index, thisPump in pairs(pumpsTable) do
			pumpsTracks[index]:AdjustSpeed(0)
			pumpsTracks[index].TimePosition = 0
		end
		return
	end

	for index, thisPump in pairs(pumpsTable) do
		local minimunProgress, maximumProgress = this*(index-1), this*(index)
		local thisProgress = math.clamp((progress.Value - minimunProgress) / this, 0, 1)

		if progress.Value > minimunProgress then
			pumpsTracks[index]:AdjustSpeed(thisProgress)
		else
			pumpsTracks[index]:AdjustSpeed(0)
		end
	end
end

function Blind_Survivors(Killer)
	generator:SetAttribute("Sabotaged", nil)

	Killer = game.Players:WaitForChild(Killer)
	local HasPerk, Perk_Tier = require(Modules.Data):GetPerk("Sabotage", Killer)

	Killer.Character:SetAttribute("Sabotage_Cooldown", workspace:GetServerTimeNow() + Perks.Sabotage.Tiers[Perk_Tier])

	for i, plr in pairs(game.Teams.Killer:GetPlayers()) do
		Code:AddNotification(generator.PrimaryPart.CFrame, 5, "Generator_Miss", plr) -->> notify killers
	end

	for _, Survivor in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do
		if not Survivor.Character then continue end

		if (generator:GetPivot().Position - Survivor.Character:GetPivot().Position).Magnitude <= Perks.Sabotage.Distance then
			Code:SetEffect("Flashed", Survivor, Perks.Sabotage.Blind_Time, 'Sabotage')
		end
	end
end

Connections.Heartbeat = self.Services.RS.Heartbeat:Connect(function(step)
	-- Animation Stuff & Audio Stuff --
	task.spawn(function()
		if progress.Value > 0 then
			Handle_Pumps()
		end
	end)
	-- Generator Code
	local Stack = GeneratorSettings.Workers
	currentPlayersRepairing.Value = #Stack
	local totalIncrease, fadeMultiplayer, beingworked = 0, 0, #Stack > 0
	
	SpawnSkillCheck()

	if (#Stack > 0) then
		for i, v in pairs(Stack) do
			totalIncrease += getRepairSpeed(v, step, #Stack)
		end
	end

	local _working = #Stack > 0 

	if (beingWorked.Value ~= _working) then
		beingWorked.Value = _working
	end

	if totalIncrease > 0 and not generator:GetAttribute("Blocked") then -- somebody is repairing the generator and it is not currently blocked
		beingworked = true
		broke.Value = false

		if notified then -- reset notificationp
			notified = false
		end

		if (tick() - stuttering) < 3 then return end -- if we are stuttering don't add progress

		--if (#Stack > 1) then
		--	totalIncrease = totalIncrease - ((#Stack - 1) * BaseValues.Gameplay.GeneratorStackDecrease)
		--end

		if generator:GetAttribute("Sabotaged") then
			Blind_Survivors(generator:GetAttribute("Sabotaged")) -->> killer sabo perk <<--
		end

		progress.Value += AddProgress(totalIncrease * step)
	end

	if (not beingworked and progress.Value < 1000 and not Popped.Value) then -- generator is not being worked on
		if (broke.Value) then -- generator is broken

			if (progress.Value > 0) then
				progress.Value -= ((GeneratorSettings.Speeds.Regress / 100 * regressionspeed.Value) * step)
			else
				progress.Value = 0
				broke.Value = false
			end
		end
	end

	Particles(broke.Value)

	if progress.Value >= 1000 or GeneratorsRepaired.Value >= 5 then

		if (progress.Value >= 1000) then
			Events.Gameplay.onGeneratorRepaired:Fire(GeneratorSettings.Workers, generator)
		end

		progress.Value = 1000
		Handle_Pumps()

		--Connections.Heartbeat:Disconnect()
		--Connections.Heartbeat = nil
	end
end)

progress.Changed:Connect(function(value)
	Handle_Pumps()
end)

generator:GetAttributeChangedSignal("Blocked"):Connect(function()
	local attribute = generator:GetAttribute('Blocked')

	if attribute then
		generator:SetAttribute("Blocked", true)

		if Entity_Tracks.Idle.IsPlaying then
			Entity_Tracks.Idle:Stop()
		end

		if not Entity_Tracks.Blocked.IsPlaying then
			Entity_Tracks.Blocked:Play()
		end

		game.TweenService:Create(Entity:WaitForChild('Cube'), TweenInfo.new(0.3), {Transparency = 0}):Play()
	else

		if not Entity_Tracks.Idle.IsPlaying then
			Entity_Tracks.Idle:Play()
		end

		if Entity_Tracks.Blocked.IsPlaying then
			Entity_Tracks.Blocked:Stop()
		end

		game.TweenService:Create(Entity:WaitForChild('Cube'), TweenInfo.new(0.3), {Transparency = 1}):Play()
	end
end)

function SkillCheckReceived(Player: Player, ID, Result)
	
	if (GeneratorSettings.SkillChecks[ID] == nil) then
		return-- warn(Player.Name, "tried sending an unknown SkillCheck ID")
	end
	
	GeneratorSettings.SkillChecks[ID] = nil
	
	print(Result)
	
	if (Result == "Fail" or Result == "Miss") then
		exploded.Value = true
		progress.Value = math.clamp(progress.Value - 50, 0, 1000)
		stuttering = tick()
	end
	
	if (Result == "Good") then
		Data:GiveBlood(Player, 50, "Objectives", "GOOD SKILL CHECK")
	end

	if (Result == "Great") then
		progress.Value += 30
		Data:GiveBlood(Player, 300, "Objectives", "GREAT SKILL CHECK")
	end
	
end

Initialize()