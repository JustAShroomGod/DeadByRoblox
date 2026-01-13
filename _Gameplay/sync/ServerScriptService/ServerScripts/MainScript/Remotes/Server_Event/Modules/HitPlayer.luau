local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local ServerStorage = game:GetService("ServerStorage")

local Events = require(game.ServerScriptService["Event System"].Events)
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local BadgeManger = require(ServerStorage:FindFirstChild("Modules"):FindFirstChild("BadgeManager"))
local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Perks')

local Guard_Data = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('Guardian'))
local Save_Data = require(Perk_Data:WaitForChild('Killer'):WaitForChild('SaveTheBestForLast'))

local Killer_Modules = {
	Reaper = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild('Reaper'));
}

local Sounds = script.Parent.Parent:WaitForChild("Sounds")

local module = {
	DistanceValidation = {
		Basic = 16;
		Chainsaw = 22;
	},
	PerkSettings = {

	},
}

local killer_data = {}

--hit sound 

local function PlayHitSound(Parent : Player)
	local Sound : Sound = Sounds:WaitForChild("Attack_Hit"):Clone()
	Sound.Parent = Parent.Character.PrimaryPart

	Sound.Ended:Once(function() --:Once doesn't require manially dcing the event, it does it for us after it plays one time
		Sound:Destroy()
	end)

	Sound:Play()
end


-- short hand important function --
function applyhitboost(player : Player) : "Applys hit speed boost"
	player.Character:SetAttribute("LastHit", workspace:GetServerTimeNow() + 1.7)
	code_module.Speeds:addMultiplier(player, "Hitboost", 1.0, 1.7)
end

function IsExposed(Killer : Player, Survivor : Player) : boolean | "Returns if this hit will 1 shot survivor"
	local Exposed = code_module:GetEffect("Exposed", Survivor)

	return (Exposed and Exposed.Active)
end

local isFirstHitForReaper = true

function IsBound(Killer : Player, Survivor : Player, IgnoreCharge : boolean) : "If soul-bound will hit others that are bound as well" | "If not soul-bound will reward a charge"
	local Bound = false

	if (data_module:GetCharacter(Killer) ~= "Reaper") then
		return warn ("not reaper")
	end

	local function CurrentlyBound(Character : Model) : boolean | "Returns if soul-bound for reaper"
		local bound_attribute = Character:GetAttribute("Soul_Bound")

		if bound_attribute then
			local bound_table = string.split(bound_attribute, ":")
			local TimeElapsed, TotalTime = workspace:GetServerTimeNow() - tonumber(bound_table[2]), tonumber(bound_table[1])
			local TimeLeft = 100 - math.clamp(TimeElapsed, 0, TotalTime)/TotalTime * 100

			if TimeLeft > 0 then
				return true
			else
				return false
			end
		end

		return false, 0
	end

	Bound = CurrentlyBound(Survivor.Character)

	if Bound then
		Survivor.Character:SetAttribute("Soul_Bound", nil)

		for _, OtherSurvivor : Player in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do
			local victim = game.ReplicatedStorage:WaitForChild('Match'):WaitForChild('Players'):FindFirstChild(OtherSurvivor.Name)

			if not victim or OtherSurvivor.Name == Survivor.Name or victim:GetAttribute("Dead") then continue end
			--

			if OtherSurvivor then

				if CurrentlyBound(OtherSurvivor.Character) then

					if OtherSurvivor:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value ~= "InLocker" then
						OtherSurvivor.Character:SetAttribute("Soul_Bound", nil)
					end

					BasicAttack(Killer, OtherSurvivor, true)
				end
			end
		end
	elseif not IgnoreCharge then -- give a charge if hit a non-bound person and isn't bounding shot
		local Charges = Killer.Character:GetAttribute("Power")

		if not Charges then
			return warn('no charges!')
		else
			Charges = string.split(Charges, ':')
		end

		print("Reaper Stuff")

		if isFirstHitForReaper then
			isFirstHitForReaper = false
			Killer.Character:SetAttribute("Power", math.clamp(Killer_Modules.Reaper.Charges.Base + Killer_Modules.Reaper.Charges.Gain, 0, Killer_Modules.Reaper.Charges.Max)..':'..Killer_Modules.Reaper.Charges.Max)
		else
			Killer.Character:SetAttribute("Power", math.clamp(tonumber(Charges[1]) + Killer_Modules.Reaper.Charges.Gain, 0, tonumber(Charges[2]))..':'..Charges[2])
		end
	end
end

function IsGuarded(Survivor : Player) : Player | "Returns if there is a player to tank their hit"
	local hasGuard, GTier = data_module:GetPerk("Guardian", Survivor)

	if not hasGuard then

		for _, Shield_Player : Player in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do
			if Shield_Player.Name == Survivor.Name then continue end

			local protector = game.ReplicatedStorage:WaitForChild('Match'):WaitForChild('Players'):FindFirstChild(Shield_Player.Name)
			if not protector or protector:GetAttribute("Dead") or protector:GetAttribute("Escaped") then continue end
			--
			if not Shield_Player.Character or not Survivor.Character or not Shield_Player.Character.PrimaryPart then continue end
			local CanGuard, GuardTier = data_module:GetPerk("Guardian", Shield_Player)
			local Timer, Health = Shield_Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('PerksBase'):WaitForChild('Guardian'):WaitForChild('COOLDOWN'), Shield_Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState')

			if Health.Value ~= 2 or (workspace:GetServerTimeNow() - tonumber(Timer.Value)) < Guard_Data.Cooldown then
				continue
			end

			if (Survivor.Character.PrimaryPart.Position - Shield_Player.Character.PrimaryPart.Position).Magnitude <= Guard_Data.Tiers[GuardTier or 1]
				and CanGuard then
				return Shield_Player
			end
		end
	end

	return nil
end

--

function FixState(Survivor)
	Survivor.Character:SetAttribute("Invisible", false) -- remove hidden

	if Survivor.Character:GetAttribute("Motion_Locked") then
		Survivor.Character.PrimaryPart.Anchored = false -- defreeze in place for animations
		Survivor.Character:SetAttribute('Motion_Locked', false)
	end
end

function ApplyMend(Survivor, Survivor_Values, Survivor_Perks) : "Short Hand for Mending"
	code_module:SetEffect("Gash", Survivor, 20)
	applyhitboost(Survivor)
end

function ApplyDown(Survivor : Player) : "Short Hand for Down"
	local Survivor_Pack = Survivor:WaitForChild('Backpack'):WaitForChild('Scripts')
	local Survivor_Values = Survivor_Pack:WaitForChild('values')
	local Health = Survivor_Values.HealthState

	Survivor_Values.WiggleProgress.Value = 0
	Survivor_Values.HealProgress.Value = 0
	Health.Value = 0

	Events.Killer.onAttack:Fire("Hit", Survivor.Name)
	code_module:SetCollision(Survivor, 'Downed')

	coroutine.wrap(function()
		PlayHitSound()
	end)
end

function ApplyInjure(Survivor : Player) : "Short Hand for Injuring"
	local Survivor_Pack = Survivor:WaitForChild('Backpack'):WaitForChild('Scripts')
	local Survivor_Values = Survivor_Pack:WaitForChild('values')
	local Health = Survivor_Values.HealthState

	Survivor_Values.HealProgress.Value = 0
	Health.Value = 1
	applyhitboost(Survivor)

	Events.Killer.onAttack:Fire("Hit", Survivor.Name)

	coroutine.wrap(function()
		PlayHitSound()
	end)
end

function RewardBadges(Killer : Player, Survivor_Values) : "Short Hand for giving badges"
	--TODO: when blood lust gets finishes pull up tunnel vision badge

	if Killer:WaitForChild('Backpack'):WaitForChild('Scripts').BlindScript.Blinded.Value then
		BadgeManger.Award("No Need For Sight",Killer.UserId)
	end

	if Survivor_Values.FallingFromHeight.Value then
		BadgeManger.Award("Acrophobia",Killer.UserId)
	end

	if killer_data[Killer.Name] then

		if (workspace:GetServerTimeNow() - killer_data[Killer.Name].lastAttack) < 10 then
			BadgeManger.Award("Combo",Killer.UserId)
		end

		killer_data[Killer.Name].lastAttack = workspace:GetServerTimeNow();
	else
		killer_data[Killer.Name] = {
			lastAttack = workspace:GetServerTimeNow();
		}
	end
end
-- Main Functions --

local NOED_Module = require(game.ReplicatedStorage.Game_Data.Perks.Killer["Hex: No One Escapes Death"])

function BasicAttack(Killer : Player, Survivor : Player, IgnoreValidation : boolean) : "Performs Basic Attack Damage"
	if not Killer.Character or not Survivor.Character then return warn("Avoiding Character Issues") end
	if (Killer.Character:GetPivot().Position - Survivor.Character:GetPivot().Position).Magnitude > module.DistanceValidation.Basic and not IgnoreValidation then return warn("Server-Validated - Basic Attack") end

	--print("Basic Attack")

	local Survivor_Pack = Survivor:WaitForChild('Backpack'):WaitForChild('Scripts')
	local Survivor_Values = Survivor_Pack:WaitForChild('values')
	local Survivor_Perks = Survivor_Pack:WaitForChild('PerksBase')
	local Health, Action = Survivor_Values.HealthState, Survivor_Values.Action
	local IsObsession : boolean = code_module:IsObsession(Survivor)

	local IFrame, AFrame = code_module:GetEffect("IFrame", Survivor), code_module:GetEffect("AFrame", Survivor)

	if IgnoreValidation and Action.Value == "InLocker" then
		return warn("Locker-Protected")
	elseif (AFrame and AFrame.Active) or (IFrame and IFrame.Active) then
		return warn("Protected by A/I Frames")
	elseif Survivor_Values:WaitForChild('Hooked').Value then
		return warn("Player is hooked...")
	else -- did not have dead hard or did not succeed we are gonna be hit
		if Survivor:GetAttribute('Hit') then return end


		Survivor:SetAttribute("Hit", true)
		FixState(Survivor)

		code_module:SetEffect("Haste", Killer, nil, "Hit Player")

		data_module:GiveBlood(Killer, 1000, "Brutality", "SUCCESSFUL ATTACK")

		coroutine.resume(coroutine.create(function()
			task.wait(.85)
			Survivor:SetAttribute("Hit", false)
		end))

		-- add killer prgoress stuff here
		local Shield = code_module:GetEffect("Shield", Survivor)

		if Shield and Shield.Active then -- protect through mending
			code_module:SetEffect("Shield", Survivor) -- no 3rd argument so should remove shield
			ApplyMend(Survivor, Survivor_Values, Survivor_Perks)
		else
			local IsExposed = IsExposed(Killer, Survivor)

			if IsExposed or Health.Value == 1 then -- they will die
				local Guarded : Player = IsGuarded(Survivor)

				if Guarded then
					Guarded:WaitForChild('Backpack'):WaitForChild('Scripts').PerksBase.Guardian.COOLDOWN.Value = tostring(workspace:GetServerTimeNow())
					IsBound(Killer, Guarded, IgnoreValidation)
					ApplyInjure(Guarded)
				else
					IsBound(Killer, Survivor, IgnoreValidation)
					ApplyDown(Survivor)
				end
			elseif Health.Value == 2 then -- normal m1 that will not down
				IsBound(Killer, Survivor, IgnoreValidation)
				ApplyInjure(Survivor)
			else -- some unknown health state or 0
				return warn("Unknown health state!")
			end
		end

		-- badges --
		RewardBadges(Killer, Survivor_Values)
	end
end

function HatchetAttack(Killer : Player, Survivor : Player)
	if not Killer.Character or not Survivor.Character then return warn("Avoiding Character Issues") end

	local Survivor_Pack = Survivor:WaitForChild('Backpack'):WaitForChild('Scripts')
	local Survivor_Values = Survivor_Pack:WaitForChild('values')
	local Survivor_Perks = Survivor_Pack:WaitForChild('PerksBase')
	local Health, Action = Survivor_Values.HealthState, Survivor_Values.Action

	local IFrame, AFrame = code_module:GetEffect("IFrame", Survivor), code_module:GetEffect("AFrame", Survivor)
	local InstaDownAddon = data_module:GetAddon("Killer", Killer, "Multi-Shot")
	if (AFrame and AFrame.Active) or (IFrame and IFrame.Active) then
		return warn("Protected by A/I Frames")
	elseif Survivor_Values:WaitForChild('Hooked').Value then
		return warn("Player is hooked...")
	else
		if Survivor:GetAttribute("Hit") then return end
		Survivor:SetAttribute("Hit", true)
		FixState(Survivor)

		data_module:GiveBlood(Killer, 2500, "Deviousness", "HATCHET ATTACK")
		Killer.Character:SetAttribute("HatchetHits", if not Killer.Character:GetAttribute("HatchetHits") then 1 else (Killer.Character:GetAttribute("HatchetHits") + 1))

		if Killer.Character:GetAttribute("HatchetHits") == 3 then
			BadgeManger.Award("Bloody Hatchet", Killer.UserId)
		end

		coroutine.resume(coroutine.create(function()
			task.wait(.85)
			Survivor:SetAttribute("Hit", false)
		end))


		local Shield = code_module:GetEffect("Shield", Survivor)
		if Shield and Shield.Active then -- protect through mending
			code_module:SetEffect("Shield", Survivor) -- no 3rd argument so should remove shield
			ApplyMend(Survivor, Survivor_Values, Survivor_Perks)
		else

			if Health.Value == 1 then -- they will die
				local Guarded : Player = IsGuarded(Survivor)

				if Guarded then
					Guarded:WaitForChild('Backpack'):WaitForChild('Scripts').PerksBase.Guardian.COOLDOWN.Value = tostring(workspace:GetServerTimeNow())
					ApplyInjure(Guarded)
				else
					ApplyDown(Survivor)
					Killer.Character:SetAttribute("HatchetDowns", if not Killer.Character:GetAttribute("HatchetDowns") then 1 else (Killer.Character:GetAttribute("HatchetDowns") + 1))

					if Killer.Character:GetAttribute("HatchetDowns") == 3 then
						BadgeManger.Award("Russian Winter", Killer.UserId)
					end
				end
			elseif Health.Value == 2 then -- normal m1 that will not down
				if InstaDownAddon then
					ApplyDown(Survivor)
					
					Killer.Character:SetAttribute("HatchetDowns", if not Killer.Character:GetAttribute("HatchetDowns") then 1 else (Killer.Character:GetAttribute("HatchetDowns") + 1))

					if Killer.Character:GetAttribute("HatchetDowns") == 3 then
						BadgeManger.Award("Russian Winter", Killer.UserId)
					end
				else
					ApplyInjure(Survivor)
				end
			else -- some unknown health state or 0
				return warn("Unknown health state!")
			end
		end

		-- badges --
		RewardBadges(Killer, Survivor_Values)
	end
end

function SawAttack(Killer : Player, Survivor : Player)
	if not Killer.Character or not Survivor.Character then return warn("Avoiding Character Issues") end
	if (Killer.Character:GetPivot().Position - Survivor.Character:GetPivot().Position).Magnitude > module.DistanceValidation.Chainsaw then return warn('Server-Validated - Chainsaw') end

	local Survivor_Pack = Survivor:WaitForChild('Backpack'):WaitForChild('Scripts')
	local Survivor_Values = Survivor_Pack:WaitForChild('values')
	local Survivor_Perks = Survivor_Pack:WaitForChild('PerksBase')
	local Health, Action = Survivor_Values.HealthState, Survivor_Values.Action

	local IFrame, AFrame = code_module:GetEffect("IFrame", Survivor), code_module:GetEffect("AFrame", Survivor)

	if (AFrame and AFrame.Active) or (IFrame and IFrame.Active) then
		return warn("Protected by A/I Frames")
	elseif Survivor_Values:WaitForChild('Hooked').Value then
		return warn("Player is hooked...")
	else
		if Survivor:GetAttribute("Hit") then return end
		Survivor:SetAttribute("Hit", true)
		FixState(Survivor)

		data_module:GiveBlood(Killer, 2500, "Deviousness", "SUCCESSFUL CHAINSAW")

		coroutine.resume(coroutine.create(function()
			task.wait(.85)
			Survivor:SetAttribute("Hit", false)
		end))

		local Shield = code_module:GetEffect("Shield", Survivor)

		if Shield and Shield.Active then -- protect through mending
			code_module:SetEffect("Shield", Survivor) -- no 3rd argument so should remove shield
			ApplyMend(Survivor, Survivor_Values, Survivor_Perks)
		else
			local Guarded : Player = IsGuarded(Survivor)

			if Guarded then
				Guarded:WaitForChild('Backpack'):WaitForChild('Scripts').PerksBase.Guardian.COOLDOWN.Value = tostring(workspace:GetServerTimeNow())
				ApplyInjure(Guarded)
			else
				ApplyDown(Survivor)
			end
		end

		-- badges --
		RewardBadges(Killer, Survivor_Values)
	end
end

function RageAttack(Killer : Player, Survivor : Player)
	if not Killer.Character or not Survivor.Character then return warn("Avoiding Character Issues") end
	if (Killer.Character:GetPivot().Position - Survivor.Character:GetPivot().Position).Magnitude > module.DistanceValidation.Chainsaw then return warn('Server-Validated - Rage') end

	print("Rage Attack")

	local Architect_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild('Architect'))
	local Survivor_Pack = Survivor:WaitForChild('Backpack'):WaitForChild('Scripts')
	local Survivor_Values = Survivor_Pack:WaitForChild('values')
	local Survivor_Perks = Survivor_Pack:WaitForChild('PerksBase')
	local Health, Action = Survivor_Values.HealthState, Survivor_Values.Action

	local IFrame, AFrame = code_module:GetEffect("IFrame", Survivor), code_module:GetEffect("AFrame", Survivor)

	if (AFrame and AFrame.Active) or (IFrame and IFrame.Active) then
		return warn("Protected by A/I Frames")
	elseif Survivor_Values:WaitForChild('Hooked').Value then
		return warn("Player is hooked...")
	else
		if Survivor:GetAttribute("Hit") then return end
		Survivor:SetAttribute("Hit", true)
		FixState(Survivor)

		print('Knock down', Survivor)

		coroutine.wrap(function()
			Action.Value = "Knocked"

			Survivor.Character:SetAttribute('Motion_Locked', true)
			Survivor.Character:SetAttribute("Action_Animation", "")

			task.wait(0.1)

			Survivor.Character:SetAttribute("Action_Animation_Time", workspace:GetServerTimeNow() + (Architect_Module.Knockdown_Time - 0.1))
			Survivor.Character:SetAttribute("Action_Animation", "Knockdown")

			task.wait(Architect_Module.Knockdown_Time - 0.1)

			--if Action.Value == "Knocked" then
			Action.Value = "Nothing"
			Survivor.Character:SetAttribute('Motion_Locked', false)

			--end
		end)()

		data_module:GiveBlood(Killer, 1000, "Deviousness", "SUCCESSFUL KNOCKDOWN")

		coroutine.resume(coroutine.create(function()
			task.wait(.75)
			Survivor:SetAttribute("Hit", false)
		end))

		local Shield = code_module:GetEffect("Shield", Survivor)
		if Health.Value >= 2 then
			ApplyInjure(Survivor)
		else -- down them
			local Guarded : Player = IsGuarded(Survivor)

			if Guarded then
				Guarded:WaitForChild('Backpack'):WaitForChild('Scripts').PerksBase.Guardian.COOLDOWN.Value = tostring(workspace:GetServerTimeNow())
				ApplyInjure(Guarded)
			else
				if Shield and Shield.Active then
					code_module:SetEffect("Shield", Survivor)
					ApplyMend(Survivor, Survivor_Values, Survivor_Perks)
				else
					ApplyDown(Survivor)
				end
			end
		end

		-- badges --
		RewardBadges(Killer, Survivor_Values)
	end
end

function SwiftChargeAttack(Killer : Player, Survivor : Player)
	if not Killer.Character or not Survivor.Character then return warn("Avoiding Character Issues") end
	if (Killer.Character:GetPivot().Position - Survivor.Character:GetPivot().Position).Magnitude > module.DistanceValidation.Chainsaw then return warn('Server-Validated - Chainsaw') end

	local Survivor_Pack = Survivor:WaitForChild('Backpack'):WaitForChild('Scripts')
	local Survivor_Values = Survivor_Pack:WaitForChild('values')
	local Survivor_Perks = Survivor_Pack:WaitForChild('PerksBase')
	local Health, Action = Survivor_Values.HealthState, Survivor_Values.Action

	local IFrame, AFrame = code_module:GetEffect("IFrame", Survivor), code_module:GetEffect("AFrame", Survivor)

	if (AFrame and AFrame.Active) or (IFrame and IFrame.Active) then
		return warn("Protected by A/I Frames")
	elseif Survivor_Values:WaitForChild('Hooked').Value then
		return warn("Player is hooked...")
	else
		if Survivor:GetAttribute("Hit") then return end
		Survivor:SetAttribute("Hit", true)
		FixState(Survivor)

		coroutine.resume(coroutine.create(function()
			task.wait(.85)
			Survivor:SetAttribute("Hit", false)
		end))

		local Shield = code_module:GetEffect("Shield", Survivor)
		if Health.Value >= 2 then
			ApplyInjure(Survivor)
		else -- down them
			local Guarded : Player = IsGuarded(Survivor)

			if Guarded then
				Guarded:WaitForChild('Backpack'):WaitForChild('Scripts').PerksBase.Guardian.COOLDOWN.Value = tostring(workspace:GetServerTimeNow())
				ApplyInjure(Guarded)
			else
				if Shield and Shield.Active then
					code_module:SetEffect("Shield", Survivor)
					ApplyMend(Survivor, Survivor_Values, Survivor_Perks)
				else
					ApplyDown(Survivor)
				end
			end
		end

		-- badges --
		RewardBadges(Killer, Survivor_Values)
	end
end

coroutine.resume(coroutine.create(function()
	local Remote = game.ReplicatedStorage:WaitForChild("-LockerAuras"):WaitForChild("Hatchet_Event")

	Remote.OnServerEvent:Connect(function(Killer, Survivor)
		HatchetAttack(Killer, Survivor)
	end)
end))

--

function module:Fire(...)
	local args = {...}
	local Killer, Survivor, HitType = args[2], args[3], args[4]

	print(HitType, Killer, Survivor, 'Damage Function!')

	if Survivor.Team ~= game.Teams:WaitForChild('Survivor') then
		return warn('Not a survivor!')
	end

	if HitType == "Basic" then -- normal m1 basic attack
		BasicAttack(Killer, Survivor)
	elseif HitType == "Hatchet" then -- hatchet thrown
		HatchetAttack(Killer, Survivor)
	elseif HitType == "Chainsaw" then -- insta-down attack
		SawAttack(Killer, Survivor)
	elseif HitType == "Rage" then
		RageAttack(Killer, Survivor)
	elseif HitType == "SwiftCharge" then
		SwiftChargeAttack(Killer, Survivor)
	end
end

return module
