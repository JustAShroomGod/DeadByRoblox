local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local Game_Data = ReplicatedStorage:WaitForChild('Game_Data')
local Events = require(ServerScripts:WaitForChild("Event System"):WaitForChild("Events"))

local Modules = {
	Data = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'));
	Code = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'));
}

local Perk_Modules = {
	Savier = require(Game_Data:WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('The Savier'));
	SecondChance = require(Game_Data:WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('BorrowedTime'));
	BBQ = require(Game_Data:WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('BarbecueAndChilli'));
	Warden = require(Game_Data:WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Blood Warden'));
	Salvation = require(Game_Data:WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Deliverance'));
	Pressure = require(Game_Data:WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Pressured'));
	Ninja_Tactics = require(Game_Data:WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Ninja Tactics'));
	Fugitive = require(Game_Data:WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Fugitive'));
}

local Settings = {
	Speed = {
		Hooking = 1.5;
		Attempting = 1;
		Attempting_Success = 1.5;
		Rescuing = 1.5;
	},
	Attempts = {
		Chance = 5;
		Cost = (1000/2) / 3.8; -- #of hook chances is 3 so 3 is at the end (gave a bit more to allow for hesitation)
	},
	Hook_IFrames = 5;
}


local module = {
	Connections = {}
}

coroutine.resume(coroutine.create(function()
	game:GetService("ContentProvider"):PreloadAsync({script.Success})
end))

script.Success.AnimationId = "rbxassetid://114168889839059"

function module:Fire(Player : Player, Arguments : "table")
	local command : string = Arguments[2]

	if not module.Connections[Player] then module.Connections[Player] = 0 end
	module.Connections[Player] += 1

	if command == "ChanceTaken" then
		local stored_connection_count = (module.Connections[Player] + 0)
		local Survivor_Character = Arguments[3]
		local Hook = Arguments[4] -- TODO: Get rid of this and find it from player
		local Survivor_Player = game.Players:FindFirstChild(Survivor_Character.Name) -- TODO: Get rid of this and make character only

		print('Began Unhook Operation')

		if not Survivor_Player then return warn(Survivor_Player, 'not found and character only is not supported!') end
		local hookBlood = string.split(Survivor_Character:GetAttribute("Hook_Blood"), ':')
		local hookStage = string.split(Survivor_Character:GetAttribute("Hook_Stage"), ':')
		local stored_connection_count = (module.Connections[Player] + 0)
		local Odds = (Settings.Attempts.Chance + 0)
		local hasBT, BT_Tier = Modules.Data:GetPerk("BorrowedTime", Survivor_Player)
		local HasSalvation, Salvation_Tier = Modules.Data:GetPerk("Deliverance", Survivor_Player)
		local HasRakish, Rakish_Tier = Modules.Data:GetPerk("Rakish", Survivor_Player)
		local HasFugitive,Fugitive_Tier = Modules.Data:GetPerk("Fugitive", Survivor_Player)

		if HasSalvation and Survivor_Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('PerksBase'):WaitForChild('Deliverance'):WaitForChild('Active').Value and not Survivor_Character:GetAttribute("Salvation") then
			Survivor_Character:SetAttribute("Salvation", true)
			Odds += 100
		end

		if HasRakish and not Survivor_Character:GetAttribute("Rakish") and Hook.Panel.Basement.Value then
			Survivor_Character:SetAttribute("Rakish", true)
			Odds += 100			
		end

		if Random.new():NextInteger(1, 100) <= Odds then
			-- attach iframes here before giving health --
			Modules.Code:SetEffect("IFrame", Survivor_Player, Settings.Hook_IFrames) -- last for duration

			-- Unhook Them/Self --
			Hook.Panel.Ocuped.Value = false
			Hook.Panel.Player.Value = "Nobody"
			Hook.Panel.Icy.Value = false

			Hook:SetAttribute("Action_Animation", "")
			script.Success.AnimationId = "rbxassetid://114168889839059"
			local AnimationCopy = script.Success:Clone()
			local B = Survivor_Character.Humanoid.Animator:LoadAnimation(AnimationCopy)
			B.Priority = Enum.AnimationPriority.Action4
			B:Play()
			B:AdjustSpeed(B.Length/2)

			Hook:SetAttribute("Action_Animation", "Attempt_Success")

			Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Nothing"
			Survivor_Character.PrimaryPart.Anchored = true
			Survivor_Character:PivotTo(Hook:GetPivot() * CFrame.new(4.5, 7.5, 0) * CFrame.Angles(0, math.rad(-90), 0))
			task.wait(0.1)
			Survivor_Character.PrimaryPart.Anchored = true
			Survivor_Character:PivotTo(Hook:GetPivot() * CFrame.new(4.5, 7.5, 0) * CFrame.Angles(0, math.rad(-90), 0))
			task.wait(1.9)
			B:Stop()
			B = nil

			Survivor_Player.Backpack:WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Hooked').Value = false
			Survivor_Player.Backpack:WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState').Value = 1
			AnimationCopy:Destroy()
			Survivor_Character:SetAttribute("Motion_Locked", false)
			Survivor_Character.PrimaryPart.Anchored = false

			Modules.Data:GiveBlood(Player, 5000, 'Survival', 'HOOK ESCAPE')
			Events.Survivor.onHookRescue:Fire(Survivor_Player, Survivor_Player)

			-- Apply AntiTunnel
			coroutine.wrap(function()
				Modules.Code:SetEffect("Ghost", Survivor_Player, true)
				Modules.Code:SetEffect("Haste", Survivor_Player, {10, 15}, "AntiTunnel")
				
				if hasBT then
					Modules.Code:SetEffect("Shield", Survivor_Player, Perk_Modules.SecondChance.Tiers[BT_Tier]) -- shield effect, on this player, for this length/duration
				else
					Modules.Code:SetEffect("Shield", Survivor_Player, 10)
				end

				task.wait(5)

				Modules.Code:SetEffect("Ghost", Survivor_Player, nil)
			end)()

			for i, plr in pairs(game.Teams.Killer:GetPlayers()) do
				Modules.Code:AddNotification(Hook:GetPivot(), 5, "Hook", plr)
			end

			-- Apply Perks Here --
			if HasSalvation and Odds >= 100 then -- they used it and didn't kobe
				Modules.Code:SetEffect("Broken", Player, Perk_Modules.Salvation.Tiers[Salvation_Tier])
			end

			if HasFugitive then
				Hook:SetAttribute("CustomSaboTime",Perk_Modules.Fugitive.Hook_Tiers[Fugitive_Tier])

				Hook.Panel.Progress.Value = 1000
				Hook.Panel.Sabotaging.Value = Survivor_Player
				Hook.Panel.Used.Value = true
			end
		else -- failed to unhook
			Survivor_Character:SetAttribute("Hook_Blood", (tonumber(hookBlood[1]) - Settings.Attempts.Cost)..':'..hookBlood[2])

			Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Nothing"
		end
	end

	if command == "Unhook" and Arguments[3].Parent == workspace then
		if Player.Team ~= game.Teams:WaitForChild('Survivor') then return error(Player..' is cheating!') end -- team check
		local Survivor_Character = Arguments[3]
		local Hook = Arguments[4] -- TODO: Get rid of this and find it from player
		local Survivor_Player = game.Players:FindFirstChild(Survivor_Character.Name) -- TODO: Get rid of this and make character only

		print('Began Unhook Operation')

		if not Survivor_Player then return warn(Survivor_Player, 'not found and character only is not supported!') end
		local hookBlood = string.split(Survivor_Character:GetAttribute("Hook_Blood"), ':')
		local hookStage = string.split(Survivor_Character:GetAttribute("Hook_Stage"), ':')

		if (Survivor_Character == Player.Character) then -- self unhook
			local Attempt_Time = (Settings.Speed.Attempting + 0)
			local AttemptSuccess_Time = (Settings.Speed.Attempting_Success + 0)

			local stored_connection_count = (module.Connections[Player] + 0)
			local Odds = (Settings.Attempts.Chance + 0)

			-- Grab Perks Here --


			Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Attempting"
			Hook:SetAttribute("Action_Animation", "")

			Attempt_Time -= 0.1
			task.wait(0.1)

			Hook:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Attempt_Time)
			Hook:SetAttribute("Action_Animation", "Attempt")

			task.wait(Attempt_Time) -- wait for animation to catchup

		else -- Unhooking another player
			local scrapped = false
			-- Gather unhooker Perks Here --
			local hasBT, BT_Tier = Modules.Data:GetPerk("BorrowedTime", Player)
			--local hasWMI, WMI_Tier = Modules.Data:GetPerk("WellMakeIt", Player)
			local hasSalv, Salv_Tier = Modules.Data:GetPerk("Deliverance", Player)
			local hasSave, Save_Tier = Modules.Data:GetPerk("The Savier", Player)
			local HasFugitive,Fugitive_Tier = Modules.Data:GetPerk("Fugitive", Survivor_Player)

			Player.Character.PrimaryPart.Anchored = false -- freeze in place for animations
			Player.Character:SetAttribute('Motion_Locked', true)
			Player.Character:SetAttribute('Motion_Locked', false)

			Modules.Data:GiveBlood(Player, 1500, 'Altruism', 'HOOK RESCUE')
			Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Nothing"

			print('Apply our hook perks!')

			-- attach iframes here before giving health --
			Modules.Code:SetEffect("IFrame", Survivor_Player, Settings.Hook_IFrames) -- last for duration

			-- Unhook Them --
			Hook.Panel.Ocuped.Value = false
			Hook.Panel.Icy.Value = false
			Hook.Panel.Player.Value = "Nobody"

			Survivor_Character:SetAttribute("Motion_Locked", false)
			Survivor_Character.PrimaryPart.Anchored = false

			Survivor_Player.Backpack:WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Hooked').Value = false
			Survivor_Player.Backpack:WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState').Value = 1

			-- Apply AntiTunnel
			coroutine.wrap(function()
				Modules.Code:SetEffect("Ghost", Survivor_Player, true)
				Modules.Code:SetEffect("Haste", Survivor_Player, {10, 15}, "AntiTunnel")
				
				if hasBT then
					Modules.Code:SetEffect("Shield", Survivor_Player, Perk_Modules.SecondChance.Tiers[BT_Tier]) -- shield effect, on this player, for this length/duration
				else
					Modules.Code:SetEffect("Shield", Survivor_Player, 10)
				end

				task.wait(5)

				Modules.Code:SetEffect("Ghost", Survivor_Player, nil)
			end)()

			--print('Applying perks now!')

			-- Apply Perks Here --
			Events.Survivor.onHookRescue:Fire(Player, Survivor_Player) -->> let quest know and verox's code work

			for i, plr in pairs(game.Teams.Killer:GetPlayers()) do
				Modules.Code:AddNotification(Hook:GetPivot(), 5, "Hook", plr)
			end

			if HasFugitive then
				Hook:SetAttribute("CustomSaboTime",Perk_Modules.Fugitive.Hook_Tiers[Fugitive_Tier])

				Hook.Panel.Progress.Value = 1000
				Hook.Panel.Sabotaging.Value = Survivor_Player
				Hook.Panel.Used.Value = true
			end
			
			--[[if hasWMI then --TODO: Code in effect for extra speed
				print('TODO: Apply Together Effect!')
			end]]--

			if hasSalv then
				Player.Backpack:WaitForChild('Scripts'):WaitForChild('PerksBase'):WaitForChild('Deliverance'):WaitForChild('Active').Value = true
			end

			if hasSave then
				local increase = if Player.Character:GetAttribute("Savier_Tokens") then tonumber(Player.Character:GetAttribute("Savier_Tokens")) else 0

				Player.Character:SetAttribute("Savier_Tokens", math.clamp(increase + 1, 0, Perk_Modules.Savier.Token_Limit))
			end

			print('Done')
		end
	elseif command == "Hook" and Arguments[3].Parent == workspace then -- gonna go off character from now on to support bots/dummies
		if Player.Team ~= game.Teams:WaitForChild('Killer') then return error(Player..' is cheating!') end -- team check
		local Survivor_Character = Arguments[3]
		local Hook = Arguments[4] -- TODO: Get rid of this and find it from player
		local Survivor_Player = game.Players:FindFirstChild(Survivor_Character.Name) -- TODO: Get rid of this and make character only

		if not Survivor_Player then return warn(Survivor_Player, 'not found and character only is not supported!') end
		local hookBlood = string.split(Survivor_Character:GetAttribute("Hook_Blood"), ':')
		local hookStage = string.split(Survivor_Character:GetAttribute("Hook_Stage"), ':')

		-- Gather killer Perks Here --
		local hasBBQ, BBQ_Tier = Modules.Data:GetPerk("BarbecueAndChilli", Player)
		local hasWarden, Warden_Tier = Modules.Data:GetPerk("Blood Warden", Player)
		local hasPressure, Pressure_Tier = Modules.Data:GetPerk("Pressured", Player)
		local hasTactics, Tactics_Tier = Modules.Data:GetPerk("Ninja Tactics", Player)

		local Hooking_Time = (Settings.Speed.Hooking + 0)

		--Player.Character:SetAttribute('Motion_Locked', true)
		Player.Character.PrimaryPart.Anchored = true
		Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('KillerAction').Value = "Hooking"
		Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Hooking"
		require(script.Parent:WaitForChild('Carry')):Fire(Player, {"Carry", "Hooked", Survivor_Player})
		coroutine.resume(coroutine.create(function()
			repeat task.wait() 
				Survivor_Player.Backpack.Scripts.values.HealthState.Value = 0
				Survivor_Character.PrimaryPart.Anchored = true
				Survivor_Character.PrimaryPart.CFrame = Player.Character.PrimaryPart.CFrame * CFrame.new(-2.5, 3, 0)
			until Player.Character.PrimaryPart.Anchored == false
			Survivor_Player.Backpack.Scripts.values.HealthState.Value = 1
			Survivor_Character:PivotTo(Hook:GetPivot() * CFrame.new(4.5, 7.5, 0) * CFrame.Angles(0, math.rad(-90), 0))
		end))
		Hook:SetAttribute("Action_Animation", "")

		print('Hook starting', Hooking_Time)

		Hooking_Time -= 0.1
		task.wait(0.1)


		Hook:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Hooking_Time)
		Hook:SetAttribute("Action_Animation", "Hooking")

		task.wait(Hooking_Time) -- wait for animation to catchup
		--Player.Character:SetAttribute('Motion_Locked', false)
		Player.Character.PrimaryPart.Anchored = false

		if Survivor_Character then
			coroutine.resume(coroutine.create(function()
				Hook.Panel.Player.Value = Survivor_Player.Name
				Hook.Panel.Ocuped.Value = true
				Survivor_Character:SetAttribute("Motion_Locked", true)

				Survivor_Character:PivotTo(Hook:GetPivot() * CFrame.new(4.5, 7.5, 0) * CFrame.Angles(0, math.rad(-90), 0))
				Survivor_Character.PrimaryPart.Anchored = true

				Survivor_Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Hooked').Value = true
				Survivor_Character:SetAttribute("Hook_Stage", (tonumber(hookStage[1]) + 1)..':'..hookStage[2])
			end))
		end

		coroutine.resume(coroutine.create(function()
			if Survivor_Character then
				Survivor_Character['HOOK_FIX'].RemoteEvent:FireClient(Survivor_Player,Hook,Survivor_Character,Survivor_Player)
			end
		end))

		Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('KillerAction').Value = "Nothing"
		Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Nothing"

		if not workspace:GetAttribute("Endgame") then
			Modules.Data:GiveBlood(Player, 1000, 'Sacrifice', 'HOOKED')
		else
			Modules.Data:GiveBlood(Player, 1500, 'Sacrifice', 'LATE HOOK')
		end

		for i, plr in pairs(game.Teams.Survivor:GetPlayers()) do
			Modules.Code:AddNotification(Hook:GetPivot(), 5, "Hook", plr)
		end

		-- Apply Perks Here --

		Events.Killer.onHook:Fire(Player, Survivor_Player, Hook)

		if hasTactics then
			--print('Getting hidden effect!', Perk_Modules.Ninja_Tactics.Tiers[Tactics_Tier])
			Modules.Code:SetEffect("Hidden", Player, Perk_Modules.Ninja_Tactics.Tiers[Tactics_Tier], "Ninja_Tactics") -->> should apply ninja tactics to us
		end

		if hasWarden and workspace:GetAttribute("Endgame") and not Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('PerksBase'):WaitForChild('Blood Warden'):WaitForChild('Activated').Value then
			Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('PerksBase'):WaitForChild('Blood Warden'):WaitForChild('Activated').Value = true
			local toset = tostring(Perk_Modules.Warden.Tiers[Warden_Tier]) .. ':' .. tostring(workspace:GetServerTimeNow())
			workspace:SetAttribute("No_Escape", toset)
		end
	else
		warn(command, 'not supported!')
	end
end

return module