local Game_Assets = game.ReplicatedStorage:WaitForChild('Game_Assets')
local Game_Data = game.ReplicatedStorage:WaitForChild('Game_Data')

local Sound_Service, Teams = game:GetService('SoundService'), game:GetService('Teams')

local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Temp_Healing = { --TODO: Make Healing Sounds Custom/Default
	Game_Assets:WaitForChild('Sounds'):WaitForChild('Healing'):WaitForChild('Default_L');
	Game_Assets:WaitForChild('Sounds'):WaitForChild('Healing'):WaitForChild('Default_R');
}

local Downed = Game_Assets:WaitForChild("Sounds"):WaitForChild("OnHit"):WaitForChild("Default_Down")
local Injured = Game_Assets:WaitForChild("Sounds"):WaitForChild("OnHit"):WaitForChild("Default")

local LayerAssets = Game_Assets:WaitForChild("Sounds"):WaitForChild("Chase_Music"):WaitForChild("Layers")

local Sound_Handler = {
	Terror_Data = {
		Team = nil; -- our team for terror data
		Killer = nil; -- killer selected for chase music
		Dist = 1000; -- store distance
	},
	Heart_Module = require(script:WaitForChild('Heartbeat_Revamp'));
	Chase_Module = require(script:WaitForChild('Chase_Music'));
	TerrorRadius_Module = require(script:WaitForChild('Terror_Radius'));
	Sound_Balancing = nil,
	Sound_Processing = nil;
	Users = {}; -- users in sound storage
}

local function DetectKillerCharacter(Killer)
	return Killer:WaitForChild('Data'):WaitForChild('Killer').Value
end

function BalanceAudio(Balance : "SFX" | "MUSIC", Audio : Sound)
	local Current_Volume = Audio:GetAttribute("Volume")

	if Sound_Handler.Sound_Balancing then

		if Balance == 'SFX' then
			Current_Volume = (Sound_Handler.Sound_Balancing.Master/10) * (Sound_Handler.Sound_Balancing.SFX/10) * Current_Volume
		elseif Balance == 'MUSIC' then
			Current_Volume = (Sound_Handler.Sound_Balancing.Master/10) * (Sound_Handler.Sound_Balancing.Music/10) * Current_Volume
		end
	end

	Audio.Volume = Current_Volume
end

function Sound_Handler:PlaySFX(Audio : Sound) : "Single Play SFX with Audio Balancing"
	BalanceAudio('SFX', Audio)
	Audio:Play()
end

function Sound_Handler:ConnectUser(Player : Player) : "Connect a Character's Sounds"
	if Sound_Handler.Users[Player.Name] then return end -- already in
	local Character = Player.Character
	local Sound_Pack, Team = Data_Module:GetSoundPack(Player), Player.Team.Name
	local Sound_Box = Character:WaitForChild('Head')

	Sound_Pack = Game_Data:WaitForChild('Sounds'):WaitForChild(Team):FindFirstChild(Sound_Pack)

	if Sound_Pack then
		Sound_Pack = require(Sound_Pack)

		Sound_Handler.Users[Player.Name] = {
			Pack = Sound_Pack;
			Player = Player;
			Character = Character;
			Sound_Box = Sound_Box;
			Meta_Data = {};
		}

		if Team == 'Survivor' then
			local Player_Values = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')
			local Health_State, Last_State = Player_Values:WaitForChild('HealthState'), Player_Values:WaitForChild('HealthState').Value
			local Hooked_State, Action = Player_Values:WaitForChild('Hooked'), Player_Values:WaitForChild('Action')

			Sound_Handler.Users[Player.Name].Injured = false;
			Sound_Handler.Users[Player.Name].Healing = false;
			Sound_Handler.Users[Player.Name].Meta_Data.Last_Heal_Sound = nil
			Sound_Handler.Users[Player.Name].Meta_Data.Downed = false
			Sound_Handler.Users[Player.Name].Meta_Data.Movement = {
				Running = false;
				Crouching = false;
			}
			Sound_Handler.Users[Player.Name].Meta_Data.Injured = {
				Last_Moan_Stamp = nil;
				Time = 0;
			}

			-- Pre-Fabricate the Sounds --
			local Walking_Audio = Sound_Box:FindFirstChild('Walk')

			if not Walking_Audio then
				Walking_Audio = Sound_Pack.Walk_Step_Sound:Clone()
				Walking_Audio.Name = "Walk"
				Walking_Audio.Parent = Sound_Box
			end

			local Run_Audio = Sound_Box:FindFirstChild('Run')

			if not Run_Audio then
				Run_Audio = Sound_Pack.Run_Step_Sound:Clone()
				Run_Audio.Name = "Run"
				Run_Audio.Parent = Sound_Box
			end

			local Healing_Right = Sound_Box:FindFirstChild('Heal_R')

			if not Healing_Right then
				Healing_Right = Temp_Healing[1]:Clone()
				Healing_Right.Name = 'Heal_R'
				Healing_Right:SetAttribute('Volume', Healing_Right.Volume) -- Input Default Vol Attribute
				Healing_Right.Parent = Sound_Box
			end

			local Healing_Left = Sound_Box:FindFirstChild('Heal_L')

			if not Healing_Left then
				Healing_Left = Temp_Healing[2]:Clone()
				Healing_Left.Name = 'Heal_L'
				Healing_Left:SetAttribute('Volume', Healing_Left.Volume) -- Input Default Vol Attribute
				Healing_Left.Parent = Sound_Box
			end
			--
			local Injured_Audio = Sound_Box:FindFirstChild('Injured')

			if not Injured_Audio then
				Injured_Audio = Sound_Pack.Injured:Clone()
				Injured_Audio.Name = "Injured"
				Injured_Audio:SetAttribute('Volume', Injured_Audio.Volume) -- Input Default Vol Attribute
				Injured_Audio.Parent = Sound_Box
			end
			--

			-- Done Generating Sounds --

			Sound_Handler.Users[Player.Name].IsSurvivor = true

			Character.AttributeChanged:Connect(function(Attribute)
				if not string.match(Attribute, 'Sound_') then return end -- not a sound attribute!
				local Play_Sound : boolean = Character:GetAttribute(Attribute)

				if Play_Sound then
					Attribute = string.gsub(Attribute, 'Sound_', "")

					if Attribute == 'Flashlight_On' then
						local Toggle_Audio = Sound_Box:FindFirstChild("Flashlight_On")

						if not Toggle_Audio then
							Toggle_Audio = Sound_Pack.Flashlight.On:Clone()
							Toggle_Audio.Name = "Flashlight_On"
							Toggle_Audio:SetAttribute("Volume", Toggle_Audio.Volume)
							Toggle_Audio.Parent = Sound_Box
						end

						Sound_Handler:PlaySFX(Toggle_Audio)
					elseif Attribute == "Flashlight_Off" then
						local Toggle_Audio = Sound_Box:FindFirstChild("Flashlight_Off")

						if not Toggle_Audio then
							Toggle_Audio = Sound_Pack.Flashlight.Off:Clone()
							Toggle_Audio.Name = "Flashlight_Off"
							Toggle_Audio:SetAttribute("Volume", Toggle_Audio.Volume)
							Toggle_Audio.Parent = Sound_Box
						end

						Sound_Handler:PlaySFX(Toggle_Audio)
					else
						error(Attribute.. ' is a unsupported remote sound!')
					end
				else
					-- do nothing
				end
			end)

			Character:GetAttributeChangedSignal("Sprint"):Connect(function()
				local Sprint = Character:GetAttribute("Sprint")

				Sound_Handler.Users[Player.Name].Meta_Data.Movement.Running = if Sprint then true else false
			end)

			Action.Changed:Connect(function()
				local Curr_Action = Action.Value
				local Healing_Actions = {
					'SelfHealing',
					'MedkitHeal',
					'GettingHealing',
					'Mending',
				}

				if table.find(Healing_Actions, Curr_Action) then
					Sound_Handler.Users[Player.Name].Healing = true
				else
					Sound_Handler.Users[Player.Name].Healing = false
				end
			end)

			Hooked_State.Changed:Connect(function()

				if Hooked_State.Value then
					local OnHook_Sound = Sound_Box:FindFirstChild('OnHook')

					if not OnHook_Sound then
						OnHook_Sound = Sound_Pack.Hook_Scream:Clone()
						OnHook_Sound.Name = "OnHook"
						OnHook_Sound:SetAttribute('Volume', OnHook_Sound.Volume) -- Input Default Vol Attribute
						OnHook_Sound.Parent = Sound_Box
					end

					Sound_Handler:PlaySFX(OnHook_Sound)
				end
			end)

			Health_State.Changed:Connect(function()

				if Health_State.Value < Last_State then
					local OnHit_Sound = Sound_Box:FindFirstChild('OnHit')
					local Hit_Sound = Sound_Box:FindFirstChild('Hit_Sound')
					local DownOnHit_Sound = Sound_Box:FindFirstChild("DownOnHit_Sound")

					if not DownOnHit_Sound then
						DownOnHit_Sound = Sound_Pack.DownOnHit_Sound:Clone()
						DownOnHit_Sound.Name = "Default_Down"
						DownOnHit_Sound:SetAttribute('Volume', DownOnHit_Sound.Volume)
						DownOnHit_Sound.Parent = Sound_Box
					end
					if not OnHit_Sound then
						OnHit_Sound = Sound_Pack.Hit_Scream:Clone()
						OnHit_Sound.Name = "OnHit"
						OnHit_Sound:SetAttribute('Volume', OnHit_Sound.Volume) -- Input Default Vol Attribute
						OnHit_Sound.Parent = Sound_Box
					end
					if not Hit_Sound then
						Hit_Sound = Sound_Pack.Hit_Sound:Clone()
						Hit_Sound.Name = "Survivor"
						Hit_Sound:SetAttribute('Volume', Hit_Sound.Volume)
						Hit_Sound.Parent = Sound_Box
					end

					Sound_Handler:PlaySFX(Hit_Sound)

					Sound_Handler.Users[Player.Name].Injured = true

					if Health_State.Value <= 0 then
						Sound_Handler:PlaySFX(DownOnHit_Sound)
						Sound_Handler.Users[Player.Name].Meta_Data.Downed = true
					else
						Sound_Handler:PlaySFX(OnHit_Sound)
						Sound_Handler.Users[Player.Name].Meta_Data.Downed = false
					end
				elseif Health_State.Value >= 2 then
					Sound_Handler.Users[Player.Name].Injured = false
					Sound_Handler.Users[Player.Name].Meta_Data.Downed = false
				end

				Last_State = Health_State.Value
			end)
		elseif Team == 'Killer' then
			--print('Set up Killer Sounds:', Player)
			--warn(Sound_Pack)

			Sound_Handler.Users[Player.Name].IsKiller = true
			Sound_Handler.Users[Player.Name].Meta_Data.Hidden = false

			local BasicAttack = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild("GlobalKiller"):WaitForChild("Action"):WaitForChild("BasicAttack")
			local Player_Values = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')
			local Stunned_State, Action = Player_Values:WaitForChild('Stunned'), Player_Values:WaitForChild('Action')

			-- Pre-Fabricate the Sounds --
			local Stunned_Noise = Sound_Box:FindFirstChild('Stun_Scream')
			local Swing = Sound_Box:FindFirstChild("Swing")
			local Attack = Sound_Box:FindFirstChild("Attack")

			if not Stunned_Noise then
				Stunned_Noise = Sound_Pack.Stunned:Clone()
				Stunned_Noise.Name = 'Stun_Scream'
				Stunned_Noise:SetAttribute('Volume', Stunned_Noise.Volume) -- Input Default Vol Attribute
				Stunned_Noise.Parent = Sound_Box
			end

			if (not Swing) then
				Swing = Sound_Pack.Swing:Clone()
				Swing.Name = "Lunge"
				Swing:SetAttribute('Volume', Swing.Volume)
				Swing.Parent = Sound_Box
			end

			if (not Attack) then
				Attack = Sound_Pack.Attack:Clone()
				Attack.Name = "Swing"
				Attack:SetAttribute('Volume', Attack.Volume)
				Attack.Parent = Sound_Box
			end
			-- Done Generating Sounds --

			Stunned_State.Changed:Connect(function()

				if Stunned_State.Value then
					Sound_Handler:PlaySFX(Stunned_Noise)
				end
			end)
		end
	else
		error(Data_Module:GetSoundPack(Player)..' does not exist for: '..Team)
	end
end

function Sound_Handler:Connect() : "Set Up Remote Connections"
	if Sound_Handler.Sound_Processing then return end
	local Base_Player : Player = game.Players.LocalPlayer
	local Base_Character : Model = Base_Player.Character
	local Base_Values : Folder = Base_Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')

	Sound_Handler.Sound_Processing = game:GetService('RunService').Heartbeat:Connect(function(step)

		-- CLEAR OUT CHASE SOUNDS AS WE ARE NO LONGER A SURVIVOR --
		if Teams:WaitForChild('Survivor') ~= Sound_Handler.Terror_Data.Team then

			if Sound_Service:FindFirstChild('Chase_Music') then
				Sound_Service:WaitForChild('Chase_Music'):Remove()
			end

			if Sound_Service:FindFirstChild('Heart_Beat') then
				Sound_Service:WaitForChild('Heart_Beat'):Remove()
			end
		end

		-- PROCESS USERS AND UPDATE CHASE MUSIC/BEAT --
		local Base_Pivot = Base_Character:GetPivot()

		for _, Sound_Group in pairs(Sound_Handler.Users) do

			if Sound_Group.IsSurvivor then
				local Quiet_Effect = Code_Module:GetEffect("Quiet", game.Players:GetPlayerFromCharacter(Sound_Group.Character))

				if Sound_Group.Sound_Box:FindFirstChild('Walk') then
					local IsDown, Walking_Audio, Run_Audio = Sound_Group.Meta_Data.Downed, Sound_Group.Sound_Box:WaitForChild('Walk'), Sound_Group.Sound_Box:WaitForChild('Run')

					if Sound_Group.Character:WaitForChild('Humanoid').MoveDirection.Magnitude > 0.15 then

						if not IsDown then
							local Speed = Sound_Group.Character.Humanoid.WalkSpeed

							if Sound_Group.Meta_Data.Movement.Running then --WE ARE RUNNING
								local Target_Volume = Sound_Group.Character.Humanoid.WalkSpeed / Run_Audio:GetAttribute("Volume_Ratio")

								if Sound_Handler.Sound_Balancing then
									Target_Volume = (Sound_Handler.Sound_Balancing.Master/10) * (Sound_Handler.Sound_Balancing.SFX/10) * Target_Volume
								end

								Run_Audio.Volume = Target_Volume
								Run_Audio.PlaybackSpeed = Sound_Group.Character.Humanoid.WalkSpeed / Run_Audio:GetAttribute("Speed_Ratio")

								Walking_Audio.Playing = false
								Run_Audio.Playing = true
							else -- WE ARE WALKING
								local Target_Volume = Sound_Group.Character.Humanoid.WalkSpeed / Walking_Audio:GetAttribute("Volume_Ratio")

								if Sound_Handler.Sound_Balancing then
									Target_Volume = (Sound_Handler.Sound_Balancing.Master/10) * (Sound_Handler.Sound_Balancing.SFX/10) * Target_Volume
								end

								Walking_Audio.Volume = Target_Volume
								Walking_Audio.PlaybackSpeed = Sound_Group.Character.Humanoid.WalkSpeed / Walking_Audio:GetAttribute("Speed_Ratio")

								Run_Audio.Playing = false
								Walking_Audio.Playing = true
							end
						else
							Run_Audio.Playing = false
							Walking_Audio.Playing = false
						end
					else
						Run_Audio.Playing = false
						Walking_Audio.Playing = false
					end
				end

				if Sound_Group.Sound_Box:FindFirstChild('Injured') then
					local Injured_Audio : Sound = Sound_Group.Sound_Box:WaitForChild('Injured')

					if Sound_Group.Injured then
						local Current_Volume = Injured_Audio:GetAttribute("Volume")

						if Sound_Handler.Sound_Balancing then
							Current_Volume = (Sound_Handler.Sound_Balancing.Master/10) * (Sound_Handler.Sound_Balancing.SFX/10) * Current_Volume
						end

						if Quiet_Effect then
							Current_Volume = (Current_Volume * math.clamp(100 - Quiet_Effect.Value, 0, 100)/100)
						end
	
						if script:GetAttribute("Perseverance") then
							Current_Volume = (Current_Volume * math.clamp(100 - script:GetAttribute("Perseverance"), 0, 100)/100)
						end

						Injured_Audio.Volume = Current_Volume

						if not Sound_Group.Meta_Data.Injured.Last_Moan_Stamp or (workspace:GetServerTimeNow() - Sound_Group.Meta_Data.Injured.Last_Moan_Stamp) >= Sound_Group.Meta_Data.Injured.Time then
							Sound_Group.Meta_Data.Injured.Last_Moan_Stamp = workspace:GetServerTimeNow()
							Sound_Group.Meta_Data.Injured.Time = math.random(0.5, 1.5) + Injured_Audio.TimeLength
							Injured_Audio:Play()
						end
					else
						Injured_Audio:Stop()
						Sound_Group.Meta_Data.Injured.Last_Moan_Stamp = nil
					end
				end

				if Sound_Group.Sound_Box:FindFirstChild('Heal_L') and Sound_Group.Sound_Box:FindFirstChild('Heal_R') then -- TODO: MIGRATE HEALING INTO 1 SOUND
					local Heal_Audio_1 : Sound, Heal_Audio_2 : Sound = Sound_Group.Sound_Box:WaitForChild('Heal_L'), Sound_Group.Sound_Box:WaitForChild('Heal_R')
					local Current_Volume = Heal_Audio_1:GetAttribute("Volume")

					if Sound_Handler.Sound_Balancing then
						Current_Volume = (Sound_Handler.Sound_Balancing.Master/10) * (Sound_Handler.Sound_Balancing.SFX/10) * Current_Volume
					end

					Heal_Audio_1.Volume = Current_Volume

					if Sound_Group.Healing then
						if not Sound_Group.Meta_Data.Last_Heal_Sound then Sound_Group.Meta_Data.Last_Heal_Sound = Heal_Audio_2 end

						if Sound_Group.Meta_Data.Last_Heal_Sound == Heal_Audio_2 then -- play track 1

							if not Heal_Audio_2.IsPlaying then
								Heal_Audio_1:Play()
								Sound_Group.Meta_Data.Last_Heal_Sound = Heal_Audio_1
							end
						elseif Sound_Group.Meta_Data.Last_Heal_Sound == Heal_Audio_1 then -- play track 2

							if not Heal_Audio_1.IsPlaying then
								Heal_Audio_2:Play()
								Sound_Group.Meta_Data.Last_Heal_Sound = Heal_Audio_2
							end
						end
					else
						Heal_Audio_1:Stop()
						Heal_Audio_2:Stop()
						Sound_Group.Meta_Data.Last_Heal_Sound = nil
					end
				end
			elseif Sound_Group.IsKiller then -- TODO: PROGRAM KILLER STUFF HERE

				if Sound_Handler.Terror_Data.Team == Teams:WaitForChild('Survivor') and Sound_Group.Player.Character then
					local Hidden_Effect = Code_Module:GetEffect("Hidden", Sound_Group.Player)

					if Sound_Group.Character:FindFirstChild('Bell') and Sound_Group.Character:WaitForChild('Bell'):WaitForChild('State').Value == "Invisible" then
						Hidden_Effect = true
					elseif Sound_Group.Player:WaitForChild('Data'):WaitForChild('Killer').Value == "Stalker" and Sound_Group.Character:GetAttribute("Power_Tier") == 1 then
						Hidden_Effect = true
					end

					Sound_Group.Meta_Data.Hidden = Hidden_Effect

					if Sound_Handler.Terror_Data.Killer == Sound_Group then
						Sound_Handler.Terror_Data.Dist = (Base_Pivot.Position - Sound_Group.Character:GetPivot().Position).Magnitude
					else -- different killer
						if not Sound_Group.Meta_Data.Hidden then -- not hidden
							local new_dist = (Base_Pivot.Position - Sound_Group.Character:GetPivot().Position).Magnitude

							if not Sound_Handler.Terror_Data.Killer then
								Sound_Handler.Terror_Data.Dist = new_dist
								Sound_Handler.Terror_Data.Killer = Sound_Group
							else

								if Sound_Handler.Terror_Data.Killer.Meta_Data.Hidden or new_dist < Sound_Handler.Terror_Data.Dist then -- was closer switch sound data or the other killer is hidden
									Sound_Handler.Terror_Data.Dist = new_dist
									Sound_Handler.Terror_Data.Killer = Sound_Group
								end
							end
						end
					end
				end
			end
		end

		-- Check Killer

		local AudioId = nil
		local IDs = 
			{
				["Hillbilly"] = "rbxassetid://137081097829697",
				["Architect"] = "rbxassetid://88830245623918",
				["Ninja"] = "rbxassetid://106168990095480",
				["Wraith"] = "rbxassetid://87247698744420",
				["Huntress"] = "rbxassetid://87377382954403",
				["Psychopath"] = "rbxassetid://132289554939965",
				["Stalker"] = "rbxassetid://83091160256215",
				["Nurse"] = "rbxassetid://75825671519868",
				["Reaper"] = "rbxassetid://119495809382493",
				["Trapper"] = "rbxassetid://71352618118165",
				["Doctor"] = "rbxassetid://88830245623918", -- This Is Default [TODO: REPLACE]
				["Phantasm"] = "rbxassetid://88830245623918", -- This Is Default [TODO: REPLACE]
				["Scientist"] = "rbxassetid://88830245623918", -- This Is Default [TODO: REPLACE]
			}

		-- APPLY CHASE MUSIC / HEART BEAT --
		if Teams:WaitForChild('Survivor') == Sound_Handler.Terror_Data.Team and Sound_Handler.Terror_Data.Killer then
			local IsChased : boolean = Base_Character:GetAttribute("Chased")
			local Killer_Character : Model = Sound_Handler.Terror_Data.Killer.Character
			task.spawn(function()
				local Killer_Weapon = nil
				for I, Parts in pairs(Killer_Character:GetChildren()) do
					if Parts then
						if (Parts:FindFirstChild("Handle") ~= nil) then
							if (Parts:IsA("Model") and Parts:FindFirstChild("SettupScript") ~= nil) then
								Killer_Weapon = Parts
							end
						end
					end
				end
				if Killer_Weapon then
					AudioId = IDs[Killer_Weapon.Name]
					Sound_Handler.Chase_Module:ChangeMusic(AudioId)
				end
			end)
			if Sound_Handler.Terror_Data.Killer.Pack.Chase then -->> got chase music sample << --
				if IsChased then -- being chased play chase music
					Sound_Handler.Chase_Module:Play(Sound_Handler.Terror_Data.Killer.Pack.Chase, Sound_Handler.Sound_Balancing, step, AudioId)
				else -- Not Being Chased turn chase music off
					Sound_Handler.Chase_Module:Stop(step)
				end
			end

			if Sound_Handler.Terror_Data.Killer.Pack.Heartbeat then
				local Killer_Character : Model = Sound_Handler.Terror_Data.Killer.Character

				if Killer_Character and Killer_Character.Parent and Base_Player.Character and Base_Player.Character.Parent then
					local Health_State : number = Base_Values:WaitForChild('HealthState').Value
					local TerrorRadiusMax = require(Game_Data:WaitForChild("Killers"):WaitForChild(DetectKillerCharacter(Sound_Handler.Terror_Data.Killer.Player))).Terror_Radius

					if not Sound_Handler.Terror_Data.Killer.Meta_Data.Hidden and Health_State > 0 then -- not insidious and we are not downed
						
						-- Heart Beat Sort --
						if Sound_Handler.Terror_Data.Killer.Pack.Heartbeat:GetAttribute("Type") == "Classic" then
							Sound_Handler.Heart_Module:Pump_Classic(Sound_Handler.Terror_Data.Dist, Sound_Handler.Terror_Data.Killer.Pack.Heartbeat, Sound_Handler.Sound_Balancing, step, IsChased, TerrorRadiusMax)
						else
							error(Sound_Handler.Terror_Data.Heart:GetAttribute("Type"), 'is a unknown hb type!')
						end
					else -- >> shut off heart
						Sound_Handler.Heart_Module:Stop(step)
					end
				else -->> shut off heart
					Sound_Handler.Heart_Module:Stop(step)
				end
			end

			--terror
			if Sound_Handler.Terror_Data.Killer.Character and Sound_Handler.Terror_Data.Killer.Character.Parent and Base_Player.Character and Base_Player.Character.Parent then
				local Health_State : number = Base_Values:WaitForChild('HealthState').Value
				local SelectedKiller_Name = DetectKillerCharacter(Sound_Handler.Terror_Data.Killer.Player)
				local TerrorRadiusMax = require(Game_Data:WaitForChild("Killers"):WaitForChild(SelectedKiller_Name)).Terror_Radius
				local LayerAssets_Killer = if LayerAssets:FindFirstChild(SelectedKiller_Name) then LayerAssets:FindFirstChild(SelectedKiller_Name) else LayerAssets:WaitForChild("Default")
				
				if not Sound_Handler.Terror_Data.Killer.Meta_Data.Hidden and not Base_Character:GetAttribute("Chased") and Health_State > 0 then -- not insidious and we are not downed and not in chase
					local Delta_Dist = math.clamp(Sound_Handler.Terror_Data.Dist, 0, TerrorRadiusMax)
					Delta_Dist = math.clamp(Delta_Dist, 0, TerrorRadiusMax)/(TerrorRadiusMax)
					
					if Delta_Dist < 1 then
						if Delta_Dist >= 0.6 then
							Sound_Handler.TerrorRadius_Module:Play(LayerAssets_Killer:WaitForChild("Layer1"), Sound_Handler.Sound_Balancing, step)
						elseif Delta_Dist >= 0.3 then
							Sound_Handler.TerrorRadius_Module:Play(LayerAssets_Killer:WaitForChild("Layer2"), Sound_Handler.Sound_Balancing, step)
						else
							Sound_Handler.TerrorRadius_Module:Play(LayerAssets_Killer:WaitForChild("Layer3"), Sound_Handler.Sound_Balancing, step)
						end
					else
						Sound_Handler.TerrorRadius_Module:Stop(step)
					end
				else -- >> shut off terror
					Sound_Handler.TerrorRadius_Module:Stop(step)
				end
			else -->> shut off heart
				Sound_Handler.TerrorRadius_Module:Stop(step)
			end
		elseif Teams:WaitForChild('Killer') == Sound_Handler.Terror_Data.Team then

			if Sound_Handler.Users[Base_Player.Name] and Sound_Handler.Users[Base_Player.Name].Pack.Chase then
				local IsChasing = Base_Character:GetAttribute("Chased")
				task.spawn(function()
					local Killer_Weapon = nil
					for I, Parts in pairs(script.Parent.Parent:GetChildren()) do
						if Parts then
							if (Parts:FindFirstChild("Handle") ~= nil) then
								if (Parts:IsA("Model") and Parts:FindFirstChild("SettupScript") ~= nil) then
									Killer_Weapon = Parts
								end
							end
						end
					end
					if Killer_Weapon then
						AudioId = IDs[Killer_Weapon.Name]
						Sound_Handler.Chase_Module:ChangeMusic(AudioId)
					end
				end)
				if IsChasing then
					Sound_Handler.Chase_Module:Play(Sound_Handler.Users[Base_Player.Name].Pack.Chase, Sound_Handler.Sound_Balancing, step, AudioId)
				else
					Sound_Handler.Chase_Module:Stop(step)
				end
			end
		end
	end)

	Sound_Handler.Sound_Balancing = Data_Module:GetSoundSettings()
	Sound_Handler.Client_Sounds = Instance.new('BindableEvent', game.ReplicatedStorage:WaitForChild('RemoteEvents'))
	Sound_Handler.Client_Sounds.Name = 'Sound_Event'
	Sound_Handler.Terror_Data.Team = Base_Player.Team

	--[[
	Might use this as a remote system to switch out some main sounds
	Ex: Chase Music (dependent on which killer is chasing you ig)
	]]--

--	warn('Create Sound Events Here')

	Sound_Handler.Client_Sounds.Event:Connect(function(...)
		local args = {...}

		if args[1] == "Skill_Alert" then
			local Alert_Audio = Sound_Service:FindFirstChild('Skill_Alert')

			if not Alert_Audio then
				Alert_Audio = Sound_Handler.Users[Base_Player.Name].Pack.Skill_Alert:Clone()
				Alert_Audio.Name = 'Skill_Alert'
				Alert_Audio:SetAttribute("Volume", Alert_Audio.Volume)
				Alert_Audio.Parent = Sound_Service
			end

			Sound_Handler:PlaySFX(Alert_Audio)
		elseif args[1] == "Skill_Great" then
			local Great_Audio = Sound_Service:FindFirstChild('Skill_Great')

			if not Great_Audio then
				Great_Audio = Sound_Handler.Users[Base_Player.Name].Pack.Skill_Great:Clone()
				Great_Audio.Name = 'Skill_Great'
				Great_Audio:SetAttribute("Volume", Great_Audio.Volume)
				Great_Audio.Parent = Sound_Service
			end

			Sound_Handler:PlaySFX(Great_Audio)
		elseif args[1] == "Skill_Good" then
			local Good_Audio = Sound_Service:FindFirstChild('Skill_Good')

			if not Good_Audio then
				Good_Audio = Sound_Handler.Users[Base_Player.Name].Pack.Skill_Good:Clone()
				Good_Audio.Name = 'Skill_Good'
				Good_Audio:SetAttribute("Volume", Good_Audio.Volume)
				Good_Audio.Parent = Sound_Service
			end

			Sound_Handler:PlaySFX(Good_Audio)
		elseif args[1] == "Skill_Miss" then
			warn('GET SKILL MISS SOUND')
		elseif args[1] == "Loud_Noise" then
			--warn(args[2])
			if args[2] == "Far" then
				local Far_Audio = Sound_Service:FindFirstChild('Far_Loud_Noise')

				if not Far_Audio then
					Far_Audio = Game_Assets:WaitForChild('Sounds'):WaitForChild('SFX'):WaitForChild('Loud_Noise'):WaitForChild('Default_Far'):Clone()
					Far_Audio.Name = 'Far_Loud_Noise'
					Far_Audio:SetAttribute("Volume", Far_Audio.Volume)
					Far_Audio.Parent = Sound_Service
				end

				Sound_Handler:PlaySFX(Far_Audio)
			elseif args[2] == "Close" then
				local Close_Audio = Sound_Service:FindFirstChild('Close_Loud_Noise')

				if not Close_Audio then
					Close_Audio = Game_Assets:WaitForChild('Sounds'):WaitForChild('SFX'):WaitForChild('Loud_Noise'):WaitForChild('Default_Close'):Clone()
					Close_Audio.Name = 'Close_Loud_Noise'
					Close_Audio:SetAttribute("Volume", Close_Audio.Volume)
					Close_Audio.Parent = Sound_Service
				end

				Sound_Handler:PlaySFX(Close_Audio)
			end
		else
			error(args[1].. ' is not a valid command')
		end
	end)

	-- SERVER -> CLIENT ATTRIBUTES / REMOTES --
	game.ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Server_Sound').OnClientEvent:Connect(function(Sound : string, Origin : Model | Vector3)

		if string.match(Sound, 'Hatch_') and Origin then
			Sound = string.gsub(Sound, 'Hatch_', "")

			if Sound == 'Hint' then
				local Hint_Audio = Origin:WaitForChild('HumanoidRootPart'):FindFirstChild('Hint_Audio')
				local Unlock_Audio = Origin:WaitForChild('HumanoidRootPart'):FindFirstChild('Unlock_Audio')

				if Unlock_Audio then
					Unlock_Audio.Playing = false
				end

				if not Hint_Audio then
					Hint_Audio = Game_Assets:WaitForChild('Sounds'):WaitForChild('SFX'):WaitForChild('Hatch'):WaitForChild('Default_Hint'):Clone()
					Hint_Audio.Name = 'Hint_Audio'
					Hint_Audio:SetAttribute("Volume", Hint_Audio.Volume)
					Hint_Audio.Parent = Origin:WaitForChild('HumanoidRootPart')
				end

				BalanceAudio('SFX', Hint_Audio)
				Hint_Audio.Playing = true
			elseif Sound == 'Unlocking' then
				local Unlock_Audio = Origin:WaitForChild('HumanoidRootPart'):FindFirstChild('Unlock_Audio')
				local Hint_Audio = Origin:WaitForChild('HumanoidRootPart'):FindFirstChild('Hint_Audio')

				if Hint_Audio then
					Hint_Audio.Playing = false
				end

				if not Unlock_Audio then
					Unlock_Audio = Game_Assets:WaitForChild('Sounds'):WaitForChild('SFX'):WaitForChild('Hatch'):WaitForChild('Default_Unlock'):Clone()
					Unlock_Audio.Name = 'Unlock_Audio'
					Unlock_Audio:SetAttribute("Volume", Unlock_Audio.Volume)
					Unlock_Audio.Parent = Origin:WaitForChild('HumanoidRootPart')
				end

				BalanceAudio('SFX', Unlock_Audio)
				Unlock_Audio.Playing = true
			elseif Sound == 'Idle' then
				local Unlock_Audio = Origin:WaitForChild('HumanoidRootPart'):FindFirstChild('Unlock_Audio')
				local Hint_Audio = Origin:WaitForChild('HumanoidRootPart'):FindFirstChild('Hint_Audio')

				if Hint_Audio then
					Hint_Audio.Playing = false
				end

				if Unlock_Audio then
					Unlock_Audio.Playing = false
				end
			elseif Sound == 'Open' then
				local Open_Audio = Origin:WaitForChild('HumanoidRootPart'):FindFirstChild('Open_Audio')

				if not Open_Audio then
					Open_Audio = Game_Assets:WaitForChild('Sounds'):WaitForChild('SFX'):WaitForChild('Hatch'):WaitForChild('Default_Open'):Clone()
					Open_Audio.Name = 'Open_Audio'
					Open_Audio:SetAttribute("Volume", Open_Audio.Volume)
					Open_Audio.Parent = Origin:WaitForChild('HumanoidRootPart')
				end

				Sound_Handler:PlaySFX(Open_Audio)
			end
		else
			error(Sound..' is a unknown sound command from server!')
		end
	end)
end

return Sound_Handler