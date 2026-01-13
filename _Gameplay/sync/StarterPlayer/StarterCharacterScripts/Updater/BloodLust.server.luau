local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage.Modules.Code)
local Data_Module = require(game.ReplicatedStorage.Modules.Data)

local ChaseUpdater = game.ReplicatedStorage.RemoteEvents.ChaseUpdater
local Match_Started  = game.ReplicatedStorage.Match.Started

local Match_Players = game.ReplicatedStorage.Match.Players

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Teams = game:GetService('Teams')

local Survivor_Team = Teams:WaitForChild('Survivor')
local Server_Player: Player = game.Players:WaitForChild(script.Parent.Parent.Name)

local lastScan = 0
local NonChase = {"Hiding","InLocker"}
local NonChaseKiller = {"GraspBegin", "Dropping"}

local Settings = {
	AttackRefresh = 6,
	ChaseRefresh = 7.5,
	TierThreshold = 16,
}

local KillerStats = {
	CurrentTier = 0;
	CurrentTierTimer = 0;
}

local ChaseTimer = {}
local PointTimer = {}

Match_Started.Changed:Connect(function(value)
	if (Match_Started.Value == true) then
		for i, v in pairs(Players:GetPlayers()) do
			ChaseTimer[v.Name] = 0
			PointTimer[v.Name] = 0

			if (Server_Player.Team ~= Teams.Killer) then
				script:Destroy()
			end
		end
	end
end)

function OnUpdate(delta)
	
	if (not Match_Started.Value) then
		return
	end

	if (not CanChaseKiller()) then
		EndBloodLust()
	end

	ScanLOS()
	SetAllChase()
	DecreaseTimers(delta)
	UpdateBloodlust(delta)
	UpdateChasePoints(delta)

	script:SetAttribute("Tier", KillerStats.CurrentTier)
	script:SetAttribute("Timer", KillerStats.CurrentTierTimer)

	Code_Module:SetEffect("BloodLust", Server_Player, `{KillerStats.CurrentTier}:{KillerStats.CurrentTierTimer}`)
end

function ScanLOS()

	if ((workspace:GetServerTimeNow() - lastScan) < 1 or #Survivor_Team:GetPlayers() < 1) then
		return
	end

	lastScan = workspace:GetServerTimeNow()

	for index, player in pairs(Survivor_Team:GetPlayers()) do

		local killerDirection = Server_Player.Character.PrimaryPart.CFrame.LookVector
		local killerHeadPos = Server_Player.Character.Head.CFrame.Position
		local rawKillerPos = Server_Player.Character.PrimaryPart.Position
		local killerPos = Vector3.new(rawKillerPos.X, 0, rawKillerPos.Z)

		local survivorHeadPos = player.Character.Head.CFrame.Position
		local rawSurvivorPos = player.Character.PrimaryPart.Position
		local survivorPos = Vector3.new(rawSurvivorPos.X, 0, rawSurvivorPos.Z)

		local distance = (survivorPos - killerPos).Magnitude
		local direction = CFrame.new(rawKillerPos, rawSurvivorPos).LookVector
		local angle = (direction - killerDirection).Magnitude

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {Server_Player.Character, workspace.RigStorage}
		params.IgnoreWater = true

		local scanDirectionBody = CFrame.new(killerHeadPos, rawSurvivorPos).LookVector
		local scanDirectionHead = CFrame.new(killerHeadPos, survivorHeadPos).LookVector

		if (angle <= 0.85 and distance < 40) then
			local bodycast = workspace:Raycast(killerHeadPos, scanDirectionBody * (distance + 3), params)
			local headcast = workspace:Raycast(killerHeadPos, scanDirectionHead * (distance + 3), params)

			if (bodycast) then
				
				local playerTry = Players:GetPlayerFromCharacter(bodycast.Instance.Parent) or nil
				playerTry = Players:GetPlayerFromCharacter(bodycast.Instance.Parent.Parent) or nil
				
				if (playerTry ~= nil) then
					ChaseTimer[playerTry.Name] = Settings.ChaseRefresh
					continue
				end
			end

			if (headcast) then
				local playerTry = Players:GetPlayerFromCharacter(bodycast.Instance.Parent) or nil
				playerTry = Players:GetPlayerFromCharacter(bodycast.Instance.Parent.Parent) or nil

				if (playerTry ~= nil) then
					ChaseTimer[playerTry.Name] = Settings.ChaseRefresh
					continue
				end
			end
		end
		
		if (distance < 22 and ChaseTimer[player.Name] > 0) then
			ChaseTimer[player.Name] = Settings.AttackRefresh
			continue
		end
	end
end

function UpdateBloodlust(delta)
	if (IsInChase(Server_Player) and CanChaseKiller() and Code_Module:GetPlayerValue(Server_Player, "DisruptiveActions") <= 0) then
		local timer = KillerStats.CurrentTierTimer
		timer += math.clamp(delta, 0, Settings.TierThreshold)

		if (timer >= 15 and KillerStats.CurrentTier < 3) then
			timer = 0
			KillerStats.CurrentTier += math.clamp(1, 0, 3)
		end
		KillerStats.CurrentTierTimer = timer
	else
		KillerStats.CurrentTier = 0
		KillerStats.CurrentTierTimer = 0
	end
end

function UpdateChasePoints(delta)
	
	for index, player in pairs(Survivor_Team:GetPlayers()) do
		
		if (ChaseTimer[player.Name] == nil or PointTimer[player.Name] == nil) then
			continue
		end
		
		if (ChaseTimer[player.Name] > 0) then
			PointTimer[player.Name] += delta
		else
			if (PointTimer[player.Name] <= 0) then
				continue
			end
			
			local points = PointTimer[player.Name] * 35
			PointTimer[player.Name] = 0
			Data_Module:GiveBlood(player, math.floor(points), "Boldness", "CHASED")
		end
	end
end

function DecreaseTimers(delta)
	for index, player in pairs(Survivor_Team:GetPlayers()) do

		if (player == nil) then
			continue
		end

		if (ChaseTimer[player.Name] == nil) then
			continue
		end

		if (CanChase(player) and CanChaseKiller()) then
			ChaseTimer[player.Name] -= delta
		else
			ChaseTimer[player.Name] = 0
		end
	end
end

function SetAllChase()

	local totalTimer = 0

	for index, player in pairs(Survivor_Team:GetPlayers()) do

		if (player == nil) then
			continue
		end

		if (ChaseTimer[player.Name] == nil) then
			continue
		end

		if Match_Players:FindFirstChild(player.Name):GetAttribute("Escaped") or Match_Players:FindFirstChild(player.Name):GetAttribute("Dead") then
			SetChase(player, false)
		end

		if (CanChase(player) and CanChaseKiller() and ChaseTimer[player.Name] > 0) then
			totalTimer += ChaseTimer[player.Name]
			SetChase(player, ChaseTimer[player.Name] > 0)
		else
			SetChase(player, false)
		end
	end

	if (CanChaseKiller()) then
		SetChase(Server_Player, totalTimer > 0)
	else
		SetChase(Server_Player, false)
	end

end

function ChaseEventReceive(Player: Player, Command: string, ...)
	
	local args = {...}
	if (Player.Team == Survivor_Team) then Player:Kick("4Head") end

	if (Command == "Collect") then
		
		local Survivor: Player = args[1]
		
		if (CanChase(Survivor)) then
			ChaseTimer[Survivor.Name] = Settings.ChaseRefresh
		else
			ChaseTimer[Survivor.Name] = 0
		end
	end
	
	if (Command == "Disrupt") then
		
		local bool = args[1]
		
		if (bool) then
			_G.GetValue(Server_Player.Name, "DisruptiveActions"):Add("Ability", 1, -1)
		else
			_G.GetValue(Server_Player.Name, "DisruptiveActions"):Remove("Ability")
		end
		
	end
end

function CanChase(Survivor: Player)

	local Humanoid = Survivor.Character:FindFirstChild("Humanoid")

	if (Humanoid == nil) then
		return false
	end

	local Scripts = Survivor.Backpack.Scripts
	local values = Scripts.values

	local Cloaked = Code_Module:GetEffect("Cloaked", Survivor)

	if (values.Hooked.Value) then return false end
	if (values.Holded.Value) then return false end
	if (values.HealthState.Value < 1) then return false end
	if (table.find(NonChase, values.Action.Value)  ~= nil) then return false end

	return true
end

function CanChaseKiller()

	local S_Backpack = Server_Player:WaitForChild("Backpack")
	local S_values = S_Backpack:WaitForChild("Scripts"):WaitForChild("values")
	local KillerAction = S_values:WaitForChild("KillerAction")

	if (Server_Player.Character:GetAttribute("Cloaked") == true) then return false end
	if (table.find(NonChaseKiller, KillerAction.Value)) then return false end

	return true
end

function EndBloodLust()
	
	KillerStats = {
		CurrentTier = 0;
		CurrentTierTimer = 0;
	}

	Code_Module.Speeds:removeMultiplier(Server_Player, "BloodLust")
	Code_Module.Status_Module:Set(Server_Player.Character, "BloodLust", nil)
end

function OnAttack(State, ObjectName)
	
	--print("CHASE SCRIPT ATTACK:", State, ObjectName)

	if (State ~= "Hit" or ObjectName == nil) then
		return
	end

	if (Players:FindFirstChild(ObjectName) ~= nil) then
		local timer = ChaseTimer[ObjectName]
		ChaseTimer[ObjectName] = if (timer > Settings.AttackRefresh) then timer + (Settings.AttackRefresh * 0.5) else Settings.AttackRefresh
	end

	EndBloodLust()
end

function OnBreak()
	EndBloodLust()
end

function SetChase(Player: Player, inChase)
	Player.Character:SetAttribute("Chased", inChase)
end

function IsInChase(Player: Player)
	return Player.Character:GetAttribute("Chased")
end

RunService.Heartbeat:Connect(OnUpdate)
Events.Killer.onBreak.Event:Connect(OnBreak)
Events.Killer.onAttack.Event:Connect(OnAttack)
ChaseUpdater.OnServerEvent:Connect(ChaseEventReceive)