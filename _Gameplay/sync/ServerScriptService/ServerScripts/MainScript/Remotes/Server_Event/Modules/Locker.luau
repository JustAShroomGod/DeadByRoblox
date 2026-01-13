local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local carry_module = require(script.Parent:WaitForChild('Carry'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local Badge_Manager = require(ServerStorage:WaitForChild("Modules"):WaitForChild("BadgeManager"))
local Events = require(ServerScripts["Event System"].Events)

local Killer_Modules = {
	Huntress = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild('Huntress'));
}

local Perk_Modules = {
	Hidden_Tactics = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('HeadOn'));
}

local Addon_Modules = {
	Itchy_Hands = require(ReplicatedStorage:WaitForChild("Game_Data"):WaitForChild("Addons"):WaitForChild("Killer"):WaitForChild("ItchyHands"))
}

local module = {}

local Hiding_Settings = { -- control length/speed of animation
	Length = {
		Fast = {
			Enter = 1.1;
			Exit = 0.9;
		},
		Slow = {
			Enter = 2;
			Exit = 2;
		},
		Search = {
			Grab = 4.2;
			None = 3.1;
		},
		Reload = 
			{
				Grab = 4.2;
				None = 3.1;
			},
	},
	Offset = {
		Survivor_Prompt = CFrame.new(0, 1.5, 0);
		Killer_Prompt = CFrame.new(0, 2.5, 0);
		Carry = CFrame.new(-2.5, -1, 0);
	}
}

function WeldTogether(p1, p2, offset)
	local W = nil

	repeat task.wait()
		W = p1:FindFirstChild('GraspWeld')
		if W then W:Destroy() end
	until not W

	W = Instance.new('Weld', p1)
	W.Name = "GraspWeld"
	W.Part0 = p1
	W.Part1 = p2

	W.C0 = offset
	W.C1 = CFrame.new(0,0,0)

	return W
end

function module:Fire(Player : Player, Arguments : "table")
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')
	local Command, Hiding_Spot : boolean = Arguments[2], Arguments[3]
	local Keyword, Length = "", 0

	if (Player.Character:GetPivot().Position - Hiding_Spot:GetPivot().Position).Magnitude > 8 then
		return
	end
	
	local HasHead, Head_Tier = data_module:GetPerk("HeadOn", Player)

	if string.match(Command, "Survivor") then -- Survivor Pathway
		local IsRunning : boolean, IsEntering : boolean = (string.match(Command, "Fast") ~= nil), (string.match(Command, "Enter") ~= nil)

		-- Process animation type + Length --
		if IsRunning then

			if IsEntering then
				Keyword, Length = "Fast_Enter", Hiding_Settings.Length.Fast.Enter
			else
				Keyword, Length = "Fast_Exit", Hiding_Settings.Length.Fast.Exit
			end
		else -- slow variants

			if IsEntering then
				Keyword, Length = "Slow_Enter", Hiding_Settings.Length.Slow.Enter
			else
				Keyword, Length = "Slow_Exit", Hiding_Settings.Length.Slow.Exit
			end
		end

		-- Reset Animation --
		Hiding_Spot:SetAttribute("Animation", '')
		Length = (Length - 0.1)
		task.wait(0.1)

		if IsEntering then -- Entering Make Invisible at End and Add Frame at Start --
			if Hiding_Spot:GetAttribute("Blocked") or playerValues:WaitForChild('HealthState').Value <= 0 then return end -- Validation from Search (can not leave once begun)
			Player.Character:SetAttribute('Motion_Locked', true)
			local CurrentHealth = Player.Backpack.Scripts.values.HealthState.Value
			playerValues:WaitForChild('Action').Value = "Hiding"

			Player.Character.PrimaryPart.Anchored = true -- freeze in place for animations
			Player.Character:PivotTo(Hiding_Spot:WaitForChild('Prompt'):GetPivot() * Hiding_Settings.Offset.Survivor_Prompt)

			Hiding_Spot:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length) -- should time/sync animations across all clients using math
			Hiding_Spot:SetAttribute("Animation", Keyword)

			Hiding_Spot:SetAttribute("Blocked", true) -- prevent killer from searching while entering and survivor from exiting --
			Hiding_Spot:SetAttribute("Searching", "Animation") -- soft-locks survivor from exiting along w/ block --
			Hiding_Spot:SetAttribute("Hiding", Player.Name) -- inserts survivor into locker --

			task.wait(Length / 2 - 0.1)

			code_module:SetEffect("AFrame", Player, true)

			task.wait(Length / 2 - 0.6) -- wait rest of animation time, but cutoff a fraction early

			Player.Character:PivotTo(Hiding_Spot:WaitForChild('Prompt'):GetPivot() * Hiding_Settings.Offset.Survivor_Prompt) -- fix position if wrong --

			code_module:SetCollision(Player, 'Locker')
			Player.Character:SetAttribute("Invisible", true) -- hidden from eyes

			code_module:SetEffect("Hidden", Player, -1, "Locker")
			code_module:SetEffect("Blind", Player, -1, "Locker")
			code_module:SetEffect("Quiet", Player, {-1, 80}, "Locker")

			Hiding_Spot:SetAttribute("Blocked", false) -- allows to be searched for a moment --

			if HasHead then
				Player.Character:SetAttribute("Perk_Hidden_Tactics", workspace:GetServerTimeNow())
			end

			Events.Survivor.onLockerEnter:Fire(Player, IsRunning, Hiding_Spot)

			spawn(function()
				if CurrentHealth ~= Player.Backpack.Scripts.values.HealthState.Value then
					if Hiding_Spot:GetAttribute("Blocked") then return end -- Validation from Search (can not leave once begun)
					code_module:SetEffect("Hidden", Player, nil, "Locker")

					Hiding_Spot:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length) -- should time/sync animations across all clients using math
					Hiding_Spot:SetAttribute("Animation", Keyword)

					Hiding_Spot:SetAttribute("Blocked", true) -- prevent killer from searching while survivor exiting --
					Hiding_Spot:SetAttribute("Hiding", "") -- removes survivor from locker --

					Length -= 0.1
					task.wait(0.1)

					Player.Character:SetAttribute("Invisible", false) -- unhidden from eyes

					task.spawn(function()
						if IsRunning then
							for i, plr in pairs(game.Teams.Killer:GetPlayers()) do
								code_module:AddNotification(Player.PrimaryPart.CFrame, 5, "Locker", plr) -->> notify killers
							end
						end
					end)
			
					-- apply perks before removing iframes
					if HasHead and IsRunning then -- only trigger head on if fast exit

						if Player.Character:GetAttribute("Perk_Hidden_Tactics") and not code_module:IsExhausted(Player) and (workspace:GetServerTimeNow() - Player.Character:GetAttribute("Perk_Hidden_Tactics")) >= Perk_Modules.Hidden_Tactics.Charge_Duration then
							local Stunned_User = false

							for _, Killer : Player in pairs(game.Teams:WaitForChild('Killer'):GetPlayers()) do
								if not Killer.Character then continue end
								local Stun = Killer:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Stunned')
								local IFrame, AFrame = code_module:GetEffect("IFrame", Killer), code_module:GetEffect("AFrame", Killer)
								local True_Offset = Hiding_Spot:WaitForChild('Prompt'):GetPivot()

								if Stun and (Killer.Character:GetPivot().Position - True_Offset.Position).Magnitude <= Perk_Modules.Hidden_Tactics.Range
									and (not AFrame or (AFrame and not AFrame.Active))
									and (not IFrame or (IFrame and not IFrame.Active)) then
									Stunned_User = true

									code_module:Stun_Killer(Killer, 'HeadOn')
								end
							end

							if Stunned_User then
								code_module:Exhaust(Player, Perk_Modules.Hidden_Tactics.Tiers[Head_Tier])
							end
						end

						Player.Character:SetAttribute("Perk_Hidden_Tactics", nil) -- remove head on tick
					end

					task.wait(Length - 0.1) -- wait rest of animation time, but cutoff a fraction early

					playerValues:WaitForChild('Action').Value = "Nothing"
					code_module:SetCollision(Player, 'Survivor')
					code_module:SetEffect("AFrame", Player)
					Player.Character.PrimaryPart.Anchored = false -- freeze in place for animations
					Player.Character:SetAttribute('Motion_Locked', false)
					code_module:SetEffect("Blind", Player, nil, "Locker")
					code_module:SetEffect("Quiet", Player, nil, "Locker")

					Events.Survivor.onLockerLeave:Fire(Player, IsRunning, Hiding_Spot)

					task.wait(0.1) -- after .1 second allow survivor to exit

					Hiding_Spot:SetAttribute("Blocked", false)
				else
					code_module:SetEffect("AFrame", Player, true)
					if Hiding_Spot:GetAttribute("Searching") == "Animation" then -- killer did not take advantage allow survivor to exit
						Hiding_Spot:SetAttribute("Searching", "") -- allows to be search for a moment (no abusing lockers Frames pretty much) --
					end
				end
			end)

			if Hiding_Spot:GetAttribute("Searching") == "Animation" then -- killer did not take advantage allow survivor to exit
				Hiding_Spot:SetAttribute("Searching", "") -- allows to be search for a moment (no abusing lockers Frames pretty much) --
			end
		else -- Exiting Make Visible at Start and Remove Frame at End
			if Hiding_Spot:GetAttribute("Hiding") ~= Player.Name then return end -- cannot kick others from lockers 
			if Hiding_Spot:GetAttribute("Blocked") then return end -- Validation from Search (can not leave once begun)
			code_module:SetEffect("Hidden", Player, nil, "Locker")

			Hiding_Spot:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length) -- should time/sync animations across all clients using math
			Hiding_Spot:SetAttribute("Animation", Keyword)

			Hiding_Spot:SetAttribute("Blocked", true) -- prevent killer from searching while survivor exiting --
			Hiding_Spot:SetAttribute("Hiding", "") -- removes survivor from locker --

			Length -= 0.1
			task.wait(0.1)

			Player.Character:SetAttribute("Invisible", false) -- unhidden from eyes

			task.spawn(function()
				if IsRunning then
					for i, plr in pairs(game.Teams.Killer:GetPlayers()) do
						code_module:AddNotification(Player.PrimaryPart.CFrame, 5, "Locker", plr) -->> notify killers
					end
				end
			end)

			-- apply perks before removing iframes
			if HasHead and IsRunning then -- only trigger head on if fast exit

				if Player.Character:GetAttribute("Perk_Hidden_Tactics") and not code_module:IsExhausted(Player) and (workspace:GetServerTimeNow() - Player.Character:GetAttribute("Perk_Hidden_Tactics")) >= Perk_Modules.Hidden_Tactics.Charge_Duration then
					local Stunned_User = false

					for _, Killer : Player in pairs(game.Teams:WaitForChild('Killer'):GetPlayers()) do
						if not Killer.Character then continue end
						local Stun = Killer:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Stunned')
						local IFrame, AFrame = code_module:GetEffect("IFrame", Killer), code_module:GetEffect("AFrame", Killer)
						local True_Offset = Hiding_Spot:WaitForChild('Prompt'):GetPivot()

						if Stun and (Killer.Character:GetPivot().Position - True_Offset.Position).Magnitude <= Perk_Modules.Hidden_Tactics.Range
							and (not AFrame or (AFrame and not AFrame.Active))
							and (not IFrame or (IFrame and not IFrame.Active)) then
							Stunned_User = true

							code_module:Stun_Killer(Killer, 'HeadOn')
						end
					end

					if Stunned_User then
						code_module:Exhaust(Player, Perk_Modules.Hidden_Tactics.Tiers[Head_Tier])
					end
				end

				Player.Character:SetAttribute("Perk_Hidden_Tactics", nil) -- remove head on tick
			end

			task.wait(Length - 0.1) -- wait rest of animation time, but cutoff a fraction early

			playerValues:WaitForChild('Action').Value = "Nothing"
			code_module:SetCollision(Player, 'Survivor')
			code_module:SetEffect("AFrame", Player)
			Player.Character.PrimaryPart.Anchored = false -- freeze in place for animations
			Player.Character:SetAttribute('Motion_Locked', false)
			code_module:SetEffect("Blind", Player, nil, "Locker")
			code_module:SetEffect("Quiet", Player, nil, "Locker")

			Events.Survivor.onLockerLeave:Fire(Player, IsRunning, Hiding_Spot)

			task.wait(0.1) -- after .1 second allow survivor to exit

			Hiding_Spot:SetAttribute("Blocked", false)
		end
	elseif string.match(Command, "Killer") then -- "Killer Pathway"
		local Survivor = Hiding_Spot:GetAttribute("Hiding")
		Keyword, Length = "Locker_Search", Hiding_Settings.Length.Search.None

		Hiding_Spot:SetAttribute("Blocked", true) -- lock them inside if someone is inside or outside

		if Survivor and game.Players:FindFirstChild(Survivor) then -- someone is inside grab them
			Keyword, Length, Survivor = "Locker_Grab", Hiding_Settings.Length.Search.Grab, game.Players:FindFirstChild(Survivor)
		end

		if Keyword == "Locker_Search" and (data_module:GetCharacter(Player) == "Huntress") then
			local Hatchet_Count = Player.Character:GetAttribute("Hatchet_Count")

			if Hatchet_Count < Killer_Modules.Huntress.Hatchet_Count then
				warn(Hatchet_Count, ':', Killer_Modules.Huntress.Hatchet_Count)

				Length = Killer_Modules.Huntress.Timing_Settings.Reload

				Keyword = "Locker_Reload"
			end
		end

		-- Reset Animation --
		Hiding_Spot:SetAttribute("Animation", '')
		Length = (Length - 0.1)
		task.wait(0.1)

		if Keyword == "Locker_Grab" and Survivor and Survivor.Parent then -- Grabbing Animation --
			playerValues.Action.Value = "Searching" -- lock killer into action
			playerValues.KillerAction.Value = "Searching"

			Events.Killer.onLockerSearch:Fire(Player, Survivor, Hiding_Spot)

			Survivor:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "GettingGrabbed"

			Player.Character.PrimaryPart.Anchored = true -- freeze in place for animations
			Player.Character:PivotTo(Hiding_Spot:WaitForChild('Prompt'):GetPivot() * Hiding_Settings.Offset.Killer_Prompt)

			Survivor.Character:PivotTo(Player.Character:GetPivot() * Hiding_Settings.Offset.Carry) -- pivot survivor to new animation point

			Length = (Length - 0.1) -- snip off from length
			task.wait(0.1)

			Hiding_Spot:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length) -- should time/sync animations across all clients using math
			Hiding_Spot:SetAttribute("Animation", Keyword)

			if Survivor and Survivor.Parent then
				Survivor.Character:SetAttribute("Action_Animation_Time", Hiding_Spot:GetAttribute("Animation_Time")) -- should time/sync animations across all clients using math
				Survivor.Character:SetAttribute("Action_Animation", Keyword)
			end

			Hiding_Spot:SetAttribute("Searching", Player.Name) -- Killer is searching locker now --
			Hiding_Spot:SetAttribute("Hiding", nil) -- removes survivor from locker --

			Length = (Length - 0.1) -- snip off from length
			task.wait(0.1)

			if Survivor and Survivor.Parent then
				Survivor.Character:SetAttribute("Invisible", false) -- remove invisibility effect

				code_module:SetEffect("Blind", Player, nil, "Locker")
				code_module:SetEffect("Quiet", Survivor, nil, "Locker")

				code_module:SetEffect("Hidden", Survivor, nil, "Locker")
				code_module:SetEffect("AFrame", Survivor)

				code_module:SetCollision(Survivor, 'Carry')
			end

			task.wait(Length - 0.1) -- wait rest of animation time, but cutoff a fraction early

			if Survivor and Survivor.Parent then
				Survivor.Character.Humanoid.PlatformStand = true
				Survivor.Character.PrimaryPart.Anchored = false -- unfreeze in place for animations

				WeldTogether(Player.Character.PrimaryPart, Survivor.Character.PrimaryPart, Hiding_Settings.Offset.Carry)
	
				Survivor:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "InCarry"
				Survivor:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState').Value = 0


				Player.Character:SetAttribute("Carry", Survivor.Name)
			end

			task.spawn(function()
				code_module:SetEffect("Haste", Player, nil , 'Slam_Haste')
			end)

			playerValues.Action.Value = "Nothing"
			playerValues.KillerAction.Value = "Nothing"

			task.wait(0.1) -- after .1 second allow survivor to exit

			Player.Character.PrimaryPart.Anchored = false -- unfreeze in place for animations

			Hiding_Spot:SetAttribute("Hiding", "") -- allows to be hidden inside again
			Hiding_Spot:SetAttribute("Searching", "") -- allows to be search again
			Hiding_Spot:SetAttribute("Blocked", false) -- allows to be used again --

			if Survivor and Survivor.Parent then
				Survivor:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Holded').Value = true
			end
		
			task.delay(0.5,function()
				carry_module:Fire(Player, {"", "Connect", Survivor})
			end)

			Badge_Manager.Award("You Can't Hide",Player.UserId)
			data_module:GiveBlood(Player, 500, "Hunter", "FOUND YOU!")
		elseif Keyword == "Locker_Search" then
			Hiding_Spot:SetAttribute("Blocked", true)

			playerValues.Action.Value = "Searching" -- lock killer into action
			playerValues.KillerAction.Value = "Searching"

			Events.Killer.onLockerSearch:Fire(Player, nil, Hiding_Spot)

			Player.Character.PrimaryPart.Anchored = true -- freeze in place for animations
			Player.Character:PivotTo(Hiding_Spot:WaitForChild('Prompt'):GetPivot() * Hiding_Settings.Offset.Killer_Prompt)

			Length = (Length - 0.1) -- snip off from length
			task.wait(0.1)

			Hiding_Spot:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length) -- should time/sync animations across all clients using math
			Hiding_Spot:SetAttribute("Animation", Keyword)

			Hiding_Spot:SetAttribute("Searching", Player.Name) -- Killer is searching locker now --

			task.wait(Length - 0.1) -- wait rest of animation time, but cutoff a fraction early

			playerValues.Action.Value = "Nothing"
			playerValues.KillerAction.Value = "Nothing"

			task.wait(0.1) -- after .1 second allow survivor to exit

			Player.Character.PrimaryPart.Anchored = false -- unfreeze in place for animations

			Hiding_Spot:SetAttribute("Searching", "") -- allows to be search again
			Hiding_Spot:SetAttribute("Blocked", false) -- allows to be used again --
		elseif Keyword == "Locker_Reload" then
			Hiding_Spot:SetAttribute("Blocked", true)

			playerValues.Action.Value = "Searching" -- lock killer into action
			playerValues.KillerAction.Value = "Searching"

			Events.Killer.onLockerSearch:Fire(Player, nil, Hiding_Spot)

			Player.Character.PrimaryPart.Anchored = true -- freeze in place for animations
			Player.Character:PivotTo(Hiding_Spot:WaitForChild('Prompt'):GetPivot() * Hiding_Settings.Offset.Killer_Prompt)

			Length = (Length - 0.1) -- snip off from length
			task.wait(0.1)

			Hiding_Spot:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length) -- should time/sync animations across all clients using math
			Hiding_Spot:SetAttribute("Animation", "Locker_Reload")

			Hiding_Spot:SetAttribute("Searching", Player.Name) -- Killer is searching locker now --

			task.wait(1.4)
			local char = Player.Character
			local copy = game.ReplicatedStorage.KillerStuff.Hatchet.Handle:Clone()
			copy.Parent = char

			local hand = char:WaitForChild("LeftHand")
			local handle = char.Handle

			handle.CFrame = hand.CFrame
				*CFrame.Angles(0, -math.pi/2, 0)
				*CFrame.Angles(-math.pi/2, 0, 0)
				*CFrame.new(-0.5, 0, -0.5)

			local weld = Instance.new("WeldConstraint", handle)
			weld.Name = "HandleWeld"
			weld.Part0 = hand
			weld.Part1 = handle
			Hiding_Spot.Sounds.Locker_Reload:Play()

			Hiding_Spot.Hatchets[2].Transparency = 1

			task.wait(Length - 1.5) -- wait rest of animation time, but cutoff a fraction early

			Player.Character:SetAttribute('Hatchet_Count', Killer_Modules.Huntress.Hatchet_Count)
			

			playerValues.Action.Value = "Nothing"
			playerValues.KillerAction.Value = "Nothing"

			copy:Destroy()
			Hiding_Spot.Hatchets[2].Transparency = 0

			task.wait(0.1) -- after .1 second allow survivor to exit

			Player.Character.PrimaryPart.Anchored = false -- unfreeze in place for animations

			Hiding_Spot:SetAttribute("Searching", "") -- allows to be search again
			Hiding_Spot:SetAttribute("Blocked", false) -- allows to be used again -
		else -- Exiting Make Visible at Start and Remove Frame at End
			warn(Keyword, 'has not support')

			task.wait(0.1) -- after .1 second allow survivor to exit

			Hiding_Spot:SetAttribute("Blocked", false)
		end
	else
		warn(Command, 'not supported!')
	end
end

return module