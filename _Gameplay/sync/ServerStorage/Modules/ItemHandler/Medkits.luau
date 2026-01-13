--[[local RunService : RunService, ReplicatedStorage : ReplicatedStorage = game:GetService('RunService'), game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')

local Data = require(Modules:WaitForChild('Data'))
local Item_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Items'):WaitForChild(script.Parent.Name))

local Character : Model = script.Parent.Parent
local Tool : Model = script.Parent
local Player : Player = game.Players:GetPlayerFromCharacter(Character)

local playerValues = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')

local Using = Tool:WaitForChild('Using')

local Perk_Data = ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks')

local Botany_Module = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('BotanyKnowledge'))
local Resilience_Module = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('Resilience'))
local BirdWatcher_Module = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('Bird Watcher'))




function Update(t, step)

	if CanHeal() then
		local FrameAmount : number, SPEED : number = (CalculateUse() * step), (CalculateSpeed() * step)
		local current_progress = Tool:GetAttribute("Progress")

		Tool:SetAttribute("Progress", math.clamp(current_progress - FrameAmount, 0, 1000))

		if (tonumber(playerValues.HealProgress.Value) + SPEED) >= 1000 then
			playerValues.HealProgress.Value = "0"
			playerValues.HealthState.Value += 1
			require(Modules:WaitForChild('Code')):SetCollision(Player, 'Survivor')
		else
			playerValues.HealProgress.Value = tostring(tonumber(playerValues.HealProgress.Value) + SPEED)
		end
	else
		if RunLoop then RunLoop:Disconnect() RunLoop = nil end
	end
end

local HasDone = false
local GameKnowsSelfCare = false

Using.Changed:Connect(function()

	if Using.Value then
		if HasDone == false then HasDone = true
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
			print(HasSC, SCTier)
			if GameKnowsSelfCare == false then
				print("got perks")
				if HasSC == true then
					print("has sc")
					GameKnowsSelfCare = true
					local Tiers = require(game.ReplicatedStorage.Game_Data.Perks.Survivor.SelfCare).EffectMedkit
					script.Drain.Value *= Tiers[SCTier]
				end
			end
		end

		if RunLoop then RunLoop:Disconnect() RunLoop = nil end
		RunLoop = RunService.Stepped:Connect(Update)
	else
		if RunLoop then RunLoop:Disconnect() RunLoop = nil end
	end
end)

local module = {
	
}

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

function module.ConnectItem()
	
end


function module.DisconnectItem()

end

return module
]]