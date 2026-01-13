local RunService = game:GetService('RunService')
local HTTPService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Modules = ReplicatedStorage:WaitForChild('Modules')
local Data = require(Modules:WaitForChild('Data'))
local Code = require(Modules:WaitForChild("Code"))
local BaseValues = require(Modules:WaitForChild("BaseValues"))
local Events = require(game.ServerScriptService["Event System"].Events)
local Item_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Items'):WaitForChild(script.Parent.Name))

local Character : Model = script.Parent.Parent
local Tool : Model = script.Parent
local Player : Player = game.Players:GetPlayerFromCharacter(Character)
local playerValues = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')

local SendSkillCheck = ReplicatedStorage.RemoteEvents:WaitForChild("SendSkillCheck")
local DefaultCFrame : CFrame = CFrame.new(0, -0.7, 0) * CFrame.Angles(0, math.rad(-90), 0)

local Using = Tool:WaitForChild('Using')
local LastSkillCheck = workspace:GetServerTimeNow()
local Stuttering = workspace:GetServerTimeNow()
local SkillChecks = {}

Tool:WaitForChild("Handle").CFrame = Character:WaitForChild("RightHand").CFrame * DefaultCFrame

local Weld : Weld = Instance.new("WeldConstraint", Tool)
Weld.Part0 = Character:WaitForChild("RightHand")
Weld.Part1 = Tool:WaitForChild("Handle")
Weld.Name = "Weld"

local Perk_Data = ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks')

local Botany_Module = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('BotanyKnowledge'))
local Resilience_Module = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('Resilience'))
local BirdWatcher_Module = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('Bird Watcher'))

function Initialize()
	SendSkillCheck.OnServerEvent:Connect(SkillCheckReceived)
end

function CalculateUse() : number | "Returns consumption speed"
	local HasBotany, BotanyTier = Data:GetPerk("BotanyKnowledge", Player)
	local HasResilience, ResilienceTier = Data:GetPerk("Resilience", Player)
	local HasBirdWatcher, BirdWatcherTier = Data:GetPerk("Bird Watcher", Player)

	local ChargeSubtract = ((script.Drain.Value/script.Charges.Value) * script.Speed.Value) * 1000
	local Calulation = ChargeSubtract

	if HasResilience and playerValues.HealthState.Value <= 1 then
		Calulation += (ChargeSubtract/100) * Resilience_Module.Tiers[ResilienceTier]
	end

	if HasBotany then
		Calulation -= (ChargeSubtract/100) * Botany_Module.Tiers[BotanyTier]
	end

	if HasBirdWatcher then
		Calulation -= (ChargeSubtract/100) * BirdWatcher_Module.Tiers[BirdWatcherTier]
	end

	return Calulation
end

function CalculateSpeed() : number | "Returns use speed"
	local HasBotany, BotanyTier = Data:GetPerk("BotanyKnowledge", Player)
	local HasResilience, ResilienceTier = Data:GetPerk("Resilience", Player)

	local HEAL_SPEED, MULTIPLIER = (Item_Module.Heal_Rate/16) * 1000, 0 -- divided by 16 since that's the amount i should take to heal

	if HasResilience and playerValues.HealthState.Value <= 1 then
		MULTIPLIER += Resilience_Module.Tiers[ResilienceTier]
	end

	if HasBotany then
		MULTIPLIER += Botany_Module.Tiers[BotanyTier]
	end

	HEAL_SPEED += (HEAL_SPEED/100) * MULTIPLIER

	return HEAL_SPEED
end

local RunLoop = nil

local function CanHeal() : boolean | "If we can continue healing"
	local State = Character.Humanoid:GetState()

	if playerValues.Hooked.Value
		or Tool:GetAttribute("Progress") <= 0
		or State == Enum.HumanoidStateType.FallingDown
		or State == Enum.HumanoidStateType.Landed
		or playerValues.HealthState.Value ~= 1
		or playerValues.Holded.Value
		or not Using.Value then

		return false
	end

	if playerValues.Action.Value == "MedkitHeal"
		or playerValues.Action.Value == "Nothing" then
		return true
	end

	return false -- wasn't either action means we are doing something else
end


function Update(t, step)

	if (CanHeal()) then
		local FrameAmount : number, SPEED : number = (CalculateUse() * step), (CalculateSpeed() * step)
		local current_progress = Tool:GetAttribute("Progress")
		
		if ((workspace:GetServerTimeNow() - Stuttering) < 3) then
			return
		end
		
		SpawnSkillCheck()
		Tool:SetAttribute("Progress", math.clamp(current_progress - FrameAmount, 0, 1000))

		if (tonumber(playerValues.HealProgress.Value) + SPEED) >= 1000 then
			playerValues.HealProgress.Value = 0
			playerValues.HealthState.Value += 1
			require(Modules:WaitForChild('Code')):SetCollision(Player, 'Survivor')
			Events.Survivor.onHealingFinished:Fire(Player.Name, Player.Name)
		else
			playerValues.HealProgress.Value = playerValues.HealProgress.Value + SPEED
		end
	else
		if RunLoop then RunLoop:Disconnect() RunLoop = nil end
	end
end

function SpawnSkillCheck()

	if (playerValues.HealProgress.Value >= 900
		or (workspace:GetServerTimeNow() - LastSkillCheck) < 1.1) then
		return
	end

	LastSkillCheck = workspace:GetServerTimeNow()

	if (math.random(1, 100) > BaseValues.Gameplay.SkillCheckChances.Medkit) then
		return
	end

	local randomID = HTTPService:GenerateGUID(false)

	local SkillCheckConfig = {
		Sizes = {4, 12}
	}

	SkillChecks[randomID] = 1
	SendSkillCheck:FireClient(Player, randomID, SkillCheckConfig, "Heal")

end

function SkillCheckReceived(Player: Player, ID, Result)

	if (SkillChecks[ID] == nil) then
		return-- warn(Player.Name, "tried sending an unknown SkillCheck ID")
	end

	SkillChecks[ID] = nil

	if (Result == "Fail" or Result == "Miss") then
		playerValues.HealProgress.Value = math.clamp(playerValues.HealProgress.Value - 50, 0, 1000)
		Stuttering = workspace:GetServerTimeNow()
		
		for i, plr in pairs(game.Teams.Killer:GetPlayers()) do
			Code:AddNotification(Player.PrimaryPart.CFrame, 5, "Default", plr) -->> notify killers
		end
	end

	if (Result == "Good") then
		Data:GiveBlood(Player, 50, "Altruism", "GOOD SKILL CHECK")
	end

	if (Result == "Great") then
		playerValues.HealProgress.Value = math.clamp(playerValues.HealProgress.Value + 25, 0, 1000)
		Data:GiveBlood(Player, 300, "Altruism", "GREAT SKILL CHECK")
	end

end

local HasDone = false
local GameKnowsSelfCare = false

Using.Changed:Connect(function()

	if Using.Value then
		Character:SetAttribute("CurrentInteractable", Character.Name)
		if HasDone == false then 
			HasDone = true
			local Flashlight = script.Parent
			Flashlight['Server-Script'].Drain.Value = Item_Module.Drain
			local Total_Charges = Item_Module.Charges
			local Total_Speed = Item_Module.Heal_Rate
			local Addon_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Survivor')
			local addon_1, addon_2 = Flashlight:GetAttribute("Addon_1"), Flashlight:GetAttribute("Addon_2")

			if addon_1 and addon_1 ~= "" then
				addon_1 = Addon_Data:FindFirstChild(addon_1)

				if addon_1 then
					addon_1 = require(addon_1)

					if addon_1.Charges then
						Total_Charges += addon_1.Charges
					end

					if addon_1.Speed then
						Total_Speed += addon_1.Speed
					end

				end
			end

			if addon_2 and addon_2 ~= "" then
				addon_2 = Addon_Data:FindFirstChild(addon_2)

				if addon_2 then
					addon_2 = require(addon_2)

					if addon_2.Charges then
						Total_Charges += addon_2.Charges
					end

					if addon_2.Speed then
						Total_Speed += addon_2.Speed
					end

				end
			end
			Flashlight['Server-Script'].Charges.Value = Total_Charges
			Flashlight['Server-Script'].Speed.Value = Total_Speed

			local HasSC, SCTier = Data:GetPerk("SelfCare", game.Players:GetPlayerFromCharacter(script.Parent.Parent))

			if HasSC == true then
				local Tiers = require(game.ReplicatedStorage.Game_Data.Perks.Survivor.SelfCare).EffectMedkit
				script.Drain.Value *= Tiers[SCTier]
			end
		end

		if RunLoop then RunLoop:Disconnect() RunLoop = nil end
		RunLoop = RunService.Stepped:Connect(Update)
	else
		Character:SetAttribute("CurrentInteractable", "")
		if RunLoop then RunLoop:Disconnect() RunLoop = nil end
	end
end)

Initialize()