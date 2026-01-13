local Code = nil

local Handler = {}

function Handler:SetCodeModule(module)
	Code = module
end

function Handler:GetAll(Character : Model) : "Return Status Effect in tabled format of booleans"
	local Effects = {
		Haste = false; -- there are alt names, but haste just feels right (open to suggestions though)
		IFrame = false; -- no mending on hit, but can still be hit
		AFrame = false; -- like iframes, but will not make killer have a false/fake hit and wipe animation (complete ignore 4 lockers)
		Slow = false; -- slowed down
		Deaf = false; -- no audio
		Blind = false; -- no auras (not flashlight)
		Hidden = false; -- no scratch marks or terror radius/aura (for perk I'm making) and grunt reduction for survivor
		
		-- KILLER ONLY --
		BloodLust = false;
		
		-- SURVIVOR ONLY --
		Broken = false; -- broken
		Flashed = false; -- visual blinding (SURVIVOR ONLY)
		Rejuvenation = false; -- faster exhaustion cooldowns
		Quiet = false; -- less noise generation
		Invisible = false; -- actually invisible (will change rendering on clients)
		Shield = false; -- endurance
		Exhausted = false; -- not real good alternative name it stays as exhaustion
		Exposed = false;
		Blessed = false;
		Cloaked = false;
		Ghost = false; -- anti tunnel. prevents stains/scratch marks from showing
		Darkness = false;
		Gash = false --deep wound
	}

	if not Character then
		error('Status Effects Failed: no character provided')
		return Effects
	end -- cancel searching character did not exist!

	local function Exhausted(exhaustion) : boolean
		exhaustion = string.split(exhaustion, ':')

		if tonumber(exhaustion[1]) > 0 then -- we have exhaustion
			return true
		end

		return false
	end
	
	local function Gash(gash) : boolean
		gash = string.split(gash, ':')

		if tonumber(gash[1]) > 0 then -- we have exhaustion
			return true
		end

		return false
	end

	local Attributes = Character:GetAttributes()

	for Attribute, Value in pairs(Attributes) do
		if string.match(Attribute, "Perk") then continue end -- skip over these values | FAILSAFE |

		if Attribute == "Exhausted" then
			Effects.Exhausted = Exhausted(Value)

		elseif Attribute == "Darkness" then
			Effects.Darkness = (workspace:GetServerTimeNow() < Value)
		
		elseif Attribute == "Shield" then
			local current_shield = string.split(Value, ':')

			Effects.Shield = {
				Active = ((tonumber(current_shield[1]) - workspace:GetServerTimeNow()) > 0); -- if shield has more than 0 left
				Time = (tonumber(current_shield[1]) - workspace:GetServerTimeNow());
				Total = tonumber(current_shield[2]);
			}
		elseif string.match(Attribute, "Rejuvenation") then
			local current_rej = string.split(Value, ':') -- should be split into 3 values = HASTE_AMOUNT | HASTE_TIMESTAMP | HASTE_LENGTH

			if (tonumber(current_rej[2]) - workspace:GetServerTimeNow()) <= 0 and tonumber(current_rej[3]) >= 0 then
				Character:SetAttribute(Attribute, nil) -- remove this attribute to not loop over (save memory/time)
				continue -- skip over this haste has ran out and/or isn't inf haste either
			end

			-- All haste at this point has been verified and must be applied in 1 form or another --

			if Effects.Rejuvenation then -- adding to other haste

				-- add the total amount --
				Effects.Rejuvenation.Value += tonumber(current_rej[1]) -- now it is stacked 0.1 + 0.1 = 0.2 (haste currently)
				Effects.Rejuvenation.Total = -1 -- change to act as inf haste since it's stacked and can not display proper timers (will instead display haste icon until inf runs out or we are down to 1)

				continue -- skip over rest
			end

			-- overwriting rejuvination since we have none
			Effects.Rejuvenation = {
				Value = tonumber(current_rej[1]); -- apply amount here
				Time = (tonumber(current_rej[2]) - workspace:GetServerTimeNow()); -- time remaining on this rejuvination
				Total = tonumber(current_rej[2])
			}
		elseif Attribute == "Broken" then
			local current_break = string.split(Value, ':')

			Effects.Broken = {
				Active = ((tonumber(current_break[2]) == -1) or ((tonumber(current_break[1]) - workspace:GetServerTimeNow()) > 0)); -- if shield has more than 0 left
				Time = (tonumber(current_break[1]) - workspace:GetServerTimeNow());
				Total = tonumber(current_break[2]);
			}
		elseif Attribute == "Gash" then
			Effects.Gash = Gash(Value)
		elseif string.match(Attribute, 'Hidden') then
			local current_effect = string.split(Value, ':')

			if (tonumber(current_effect[1]) - workspace:GetServerTimeNow()) <= 0 and tonumber(current_effect[2]) >= 0 then
				Character:SetAttribute(Attribute, nil) -- erase from memory if time ran out and it isn't inf
				continue
			end

			if Effects.Hidden then
				Effects.Total = -1 -- read as inf since we have stacked effects
				continue
			end

			Effects.Hidden = {
				Active = true; -- if shield has more than 0 left
				Time = (tonumber(current_effect[1]) - workspace:GetServerTimeNow());
				Total = tonumber(current_effect[2]);
			}
		elseif string.match(Attribute, 'Flashed') then
			local current_blind = string.split(Value, ':')

			if Effects.Flashed then

				if Effects.Flashed.Total < 0 then -- current blind is inf
					continue -- do not overwrite inf
				elseif tonumber(current_blind[2]) < 0 then -- wants to set to inf
					-- do nothing
				elseif Effects.Flashed.Time > (tonumber(current_blind[1]) - workspace:GetServerTimeNow()) then -- neither is inf and new time is worse
					continue -- do not overwrite w/ shorter time
				end
			end

			Effects.Flashed = {
				Active = ((tonumber(current_blind[1]) - workspace:GetServerTimeNow()) > 0); -- if shield has more than 0 left
				Time = (tonumber(current_blind[1]) - workspace:GetServerTimeNow());
				Total = tonumber(current_blind[2]);
			}
		elseif string.match(Attribute, 'Blind') then
			local current_blind = string.split(Value, ':')

			if Effects.Blind then

				if Effects.Blind.Total < 0 then -- current blind is inf
					continue -- do not overwrite inf
				elseif tonumber(current_blind[2]) < 0 then -- wants to set to inf
					-- do nothing
				elseif Effects.Blind.Time > (tonumber(current_blind[1]) - workspace:GetServerTimeNow()) then -- neither is inf and new time is worse
					continue -- do not overwrite w/ shorter time
				end
			end

			Effects.Blind = {
				Active = ((tonumber(current_blind[1]) - workspace:GetServerTimeNow()) > 0); -- if shield has more than 0 left
				Time = (tonumber(current_blind[1]) - workspace:GetServerTimeNow());
				Total = tonumber(current_blind[2]);
			}
		elseif Attribute == "IFrame" then
			local current_frame = string.split(Value, ':')

			Effects.IFrame = {
				Active = ((tonumber(current_frame[1]) - workspace:GetServerTimeNow()) > 0); -- if shield has more than 0 left
				Time = (tonumber(current_frame[1]) - workspace:GetServerTimeNow());
				Total = tonumber(current_frame[2]);
			}
		elseif Attribute == "AFrame" then

			Effects.AFrame = {
				Active = Value;
			}
		elseif string.match(Attribute, "Blessed") then
			
			Effects.Blessed = {
				Active = Value;
			}
		
		elseif string.match(Attribute, "Exposed") then
			local current_effect = string.split(Value, ':')
			
			if (tonumber(current_effect[1]) - workspace:GetServerTimeNow()) <= 0 and tonumber(current_effect[2]) >= 0 then
				Character:SetAttribute(Attribute, nil) -- erase from memory if time ran out and it isn't inf
				continue
			end

			if Effects.Exposed then
				Effects.Exposed.Total = -1 -- read as inf since we have stacked effects
				continue
			end

			Effects.Exposed = {
				Active = true; --((tonumber(current_effect[1]) - workspace:GetServerTimeNow()) > 0) or (tonumber(current_effect[2]) == -1);
				Time = (tonumber(current_effect[1]) - workspace:GetServerTimeNow());
				Total = tonumber(current_effect[2]);
			}
			
		elseif string.match(Attribute, "Cloaked") then

			Effects.Cloaked = {
				Active = Value;
			}
			
		elseif string.match(Attribute, "Haste") then
			local current_haste = string.split(Value, ':') -- should be split into 3 values = HASTE_AMOUNT | HASTE_TIMESTAMP | HASTE_LENGTH
			-- Haste/Haste-Stack Plan -
			--Haste_(Haste_Name) = "haste_amount:haste_time:haste_timestamp"

			if (tonumber(current_haste[2]) - workspace:GetServerTimeNow()) <= 0 and tonumber(current_haste[3]) >= 0 then
				Character:SetAttribute(Attribute, nil) -- remove this attribute to not loop over (save memory/time)
				continue -- skip over this haste has ran out and/or isn't inf haste either
			end

			-- All haste at this point has been verified and must be applied in 1 form or another --

			if Effects.Haste then -- adding to other haste

				-- add the total amount --
				Effects.Haste.Value += tonumber(current_haste[1]) -- now it is stacked 0.1 + 0.1 = 0.2 (haste currently)
				Effects.Haste.Total = -1 -- change to act as inf haste since it's stacked and can not display proper timers (will instead display haste icon until inf runs out or we are down to 1)

				continue -- skip over rest
			end

			-- overwriting haste since we have none
			Effects.Haste = {
				Value = tonumber(current_haste[1]); -- apply amount here
				Time = (tonumber(current_haste[2]) - workspace:GetServerTimeNow()); -- time remaining on this haste
				Total = tonumber(current_haste[3])
			}
		elseif string.match(Attribute, 'Slow') then
			local current_slow = string.split(Value, ':') -- should be split into 3 values = AMOUNT | TIMESTAMP | LENGTH

			if (tonumber(current_slow[2]) - workspace:GetServerTimeNow()) <= 0 and tonumber(current_slow[3]) >= 0 then
				Character:SetAttribute(Attribute, nil) -- remove this attribute to not loop over (save memory/time)
				continue -- skip over this effect has ran out and/or isn't inf haste either
			end

			-- All haste at this point has been verified and must be applied in 1 form or another --

			if Effects.Slow then -- adding to other haste

				-- add the total amount --
				Effects.Slow.Value += tonumber(current_slow[1]) -- now it is stacked 0.1 + 0.1 = 0.2 (haste currently)
				Effects.Slow.Total = -1 -- change to act as inf haste since it's stacked and can not display proper timers (will instead display haste icon until inf runs out or we are down to 1)

				continue -- skip over rest
			end

			-- overwriting haste since we have none
			Effects.Slow = {
				Value = tonumber(current_slow[1]); -- apply amount here
				Time = (tonumber(current_slow[2]) - workspace:GetServerTimeNow()); -- time remaining on this haste
				Total = tonumber(current_slow[3])
			}
			
		elseif (string.match(Attribute, "BloodLust")) then
			
			local args = string.split(Value, ":")
			
			Effects.BloodLust = {
				Tier = args[1],
				Timer = args[2]
			}
			
		elseif (string.match(Attribute, "Ghost")) then

			Effects.Ghost = Value
			
		elseif string.match(Attribute, 'Quiet') then
			local current_effect = string.split(Value, ':') -- should be split into 3 values = AMOUNT | TIMESTAMP | LENGTH

			if (tonumber(current_effect[2]) - workspace:GetServerTimeNow()) <= 0 and tonumber(current_effect[3]) >= 0 then
				Character:SetAttribute(Attribute, nil) -- remove this attribute to not loop over (save memory/time)
				continue -- skip over this effect has ran out and/or isn't inf haste either
			end

			-- All haste at this point has been verified and must be applied in 1 form or another --

			if Effects.Quiet then -- adding to other haste

				-- add the total amount --
				Effects.Quiet.Value += tonumber(current_effect[1]) -- now it is stacked 0.1 + 0.1 = 0.2 (haste currently)
				Effects.Quiet.Total = -1 -- change to act as inf haste since it's stacked and can not display proper timers (will instead display haste icon until inf runs out or we are down to 1)

				continue -- skip over rest
			end

			-- overwriting haste since we have none
			Effects.Quiet = {
				Value = tonumber(current_effect[1]); -- apply amount here
				Time = (tonumber(current_effect[2]) - workspace:GetServerTimeNow()); -- time remaining on this haste
				Total = tonumber(current_effect[2])
			}
		else
			continue
		end
	end

	return Effects
end

function Handler:Get(Character : Model, Effect : string) : "Return Single Effect"
	if not Character then return false end
	local Effects = Handler:GetAll(Character)

	return Effects[Effect]
end

function Handler:Set(Character : Model, Effect : string, Value : any, Custom : string) : "Set the effect"
	if not Character or not Character.Parent then
		return warn(Character, Effect, Value, Custom, "No Character given for status effect")
	end

	--print(Value, Effect, Character:GetAttribute(Effect))

	if Effect == "Broken" then
		local current_break = Handler:Get(Character, "Broken")

		if current_break and tonumber(current_break.Total) < 0 then
			-- inf broken do nothing to change this
		else -- NOT BROKEN PRIOR ATTEMPTING TO ADD TIMED BROKEN OR NORMAL BROKEN

			if Value then

				if Value < 0 then -- ATTEMPTING TO GIVE INF BROKEN
					Character:SetAttribute("Broken", '0:-1')
				else -- trying to set normal broken effect

					if current_break and current_break.Time <= Value then -- if this makes shield last longer apply
						Character:SetAttribute("Broken", (workspace:GetServerTimeNow() + Value)..':'..Value) -- shield last till this long, total time
					else
						Character:SetAttribute("Broken", (workspace:GetServerTimeNow() + Value)..':'..Value) -- shield last till this long, total time
					end
				end
			else
				Character:SetAttribute("Broken", nil)
			end
		end
	elseif Effect == "Gash" then
		if not Value then Value = 20 end
		
		if Value then
			Character:SetAttribute("Gash", Value..':'..Value) -- set new gash
		else -- attempting to remove shield
			Character:SetAttribute("Gash", nil)
		end
	elseif Effect == "AFrame" then
		Character:SetAttribute("AFrame", Value)
	elseif Effect == "Ghost" then
		Character:SetAttribute("Ghost", Value)
	elseif Effect == "IFrame" then

		if Value then
			local current_frames = Handler:Get(Character, 'IFrame')
			
			if not current_frames or (current_frames and current_frames.Time <= Value) then -- if this makes shield last longer apply
				Character:SetAttribute("IFrame", (workspace:GetServerTimeNow() + Value)..':'..Value) -- shield last till this long, total time
			end
		else -- attempting to remove shield
			Character:SetAttribute("IFrame", nil)
		end
	elseif Effect == "Shield" then -- Apply Endurance/Shield

		if Value then
			local current_shield = Handler:Get(Character, 'Shield')
			
			if not current_shield or (current_shield and current_shield.Time <= Value) then -- if this makes shield last longer apply
				Character:SetAttribute("Shield", (workspace:GetServerTimeNow() + Value)..':'..Value) -- shield last till this long, total time
			end
		else -- attempting to remove shield
			Character:SetAttribute("Shield", nil)
		end
	elseif Effect == "Blind" then

		if Custom then
			local current_blind = if Character:GetAttribute("Blind_"..Custom) then string.split(Character:GetAttribute("Blind_"..Custom), ':') else {0, 0}

			if Value then

				if (tonumber(current_blind[1]) - workspace:GetServerTimeNow()) <= Value and tonumber(current_blind[2]) >= 0 then -- if this makes shield last longer apply
					Character:SetAttribute("Blind_"..Custom, (workspace:GetServerTimeNow() + Value)..':'..Value) -- shield last till this long, total time
				elseif Value < 0 then
					Character:SetAttribute("Blind_"..Custom, '0:-1')
				end
			else -- attempting to remove shield
				Character:SetAttribute("Blind_"..Custom, nil)
			end
		else -- Not A Custom Branch -- Use Blind Logic
			local current_blind = if Character:GetAttribute("Blind") then string.split(Character:GetAttribute("Blind"), ':') else {0, 0}

			if Value then

				if (tonumber(current_blind[1]) - workspace:GetServerTimeNow()) <= Value and tonumber(current_blind[2]) >= 0 then -- if this makes shield last longer apply
					Character:SetAttribute("Blind", (workspace:GetServerTimeNow() + Value)..':'..Value) -- shield last till this long, total time
				elseif Value < 0 then
					Character:SetAttribute("Blind", '0:-1')
				end
			else -- attempting to remove shield

				if tonumber(current_blind[2]) >= 0 then
					Character:SetAttribute("Blind", nil)
				end
			end
		end
	elseif Effect == "Flashed" then

		if Custom then
			local current_blind = if Character:GetAttribute("Flashed_"..Custom) then string.split(Character:GetAttribute("Flashed_"..Custom), ':') else {0, 0}

			if Value then

				if (tonumber(current_blind[1]) - workspace:GetServerTimeNow()) <= Value and tonumber(current_blind[2]) >= 0 then -- if this makes shield last longer apply
					Character:SetAttribute("Flashed_"..Custom, (workspace:GetServerTimeNow() + Value)..':'..Value) -- shield last till this long, total time
				elseif Value < 0 then
					Character:SetAttribute("Flashed_"..Custom, '0:-1')
				end
			else -- attempting to remove shield
				Character:SetAttribute("Flashed_"..Custom, nil)
			end
		else -- Not A Custom Branch -- Use Blind Logic
			local current_blind = if Character:GetAttribute("Blind") then string.split(Character:GetAttribute("Flashed"), ':') else {0, 0}

			if Value then

				if (tonumber(current_blind[1]) - workspace:GetServerTimeNow()) <= Value and tonumber(current_blind[2]) >= 0 then -- if this makes shield last longer apply
					Character:SetAttribute("Flashed", (workspace:GetServerTimeNow() + Value)..':'..Value) -- shield last till this long, total time
				elseif Value < 0 then
					Character:SetAttribute("Flashed", '0:-1')
				end
			else -- attempting to remove shield

				if tonumber(current_blind[2]) >= 0 then
					Character:SetAttribute("Flashed", nil)
				end
			end
		end
	elseif Effect == "Exposed" then
		
		if (Custom) then
			
			local current_exposed = if Character:GetAttribute("Exposed_"..Custom) then string.split(Character:GetAttribute("Exposed_"..Custom), ':') else {0, 0}
			
			if (Value) then

				if (tonumber(current_exposed[1]) - workspace:GetServerTimeNow()) <= Value and tonumber(current_exposed[2]) >= 0 then
					Character:SetAttribute("Exposed_"..Custom, (workspace:GetServerTimeNow() + Value)..':'..Value) -- shield last till this long, total time
				end
				if (Value < 0) then
					Character:SetAttribute("Exposed_"..Custom, "0:-1")
				end
			else
				Character:SetAttribute("Exposed_"..Custom, nil)
			end
		else
			local current_exposed = if Character:GetAttribute("Exposed") then string.split(Character:GetAttribute("Exposed"), ':') else {0, 0}
			
			if (Value) then

				if (tonumber(current_exposed[1]) - workspace:GetServerTimeNow()) <= Value and tonumber(current_exposed[2]) >= 0 then
					Character:SetAttribute("Exposed", (workspace:GetServerTimeNow() + Value)..':'..Value) -- shield last till this long, total time
				end
				if (Value < 0) then
					Character:SetAttribute("Exposed", "0:-1")
				end
			else
				Character:SetAttribute("Exposed", nil)
			end
		end
		
	elseif Effect == "Cloaked" then
		
		if (Custom) then
			local Exists = Character:GetAttribute("Cloaked_"..Custom) ~= nil
			Character:SetAttribute("Cloaked_"..Custom, Value)
			
			if (Exists) then
				if (Value == nil) then
					Code:Uncloak_Survivor(game.Players[Character.Name])
				end
			end
			
			if (not Exists) then
				if (Value) then
					Code:Cloak_Survivor(game.Players[Character.Name], 0.98)
				end
			end
			
		else
			local Exists = Character:GetAttribute("Cloaked") ~= nil
			Character:SetAttribute("Cloaked", Value)
			
			if (Exists) then
				if (Value == nil) then
					Code:Uncloak_Survivor(game.Players[Character.Name])
				end
			end

			if (not Exists) then
				if (Value) then
					Code:Cloak_Survivor(game.Players[Character.Name], 0.98)
				end
			end
			
		end
		
	elseif Effect == "BloodLust" then
		
		Code.Speeds:removeMultiplier(game.Players:GetPlayerFromCharacter(Character), `BloodLust`)

		if (Value) then
			local current_effect = if Character:GetAttribute(`BloodLust`) then string.split(Character:GetAttribute(`BloodLust`), ':') else {0, 0}
			local args = string.split(Value, ":")
			local tier, timer = tonumber(args[1]), tonumber(args[2])

			if (tier > 0) then
				Code.Speeds:addMultiplier(game.Players:GetPlayerFromCharacter(Character), `BloodLust`, (0.08 * tier), -1)
			end

			Character:SetAttribute(`BloodLust`, Value)
			return
		end
		
	elseif (Effect == "Blessed") then
		
		if (Custom) then
			if (Value) then
				Character:SetAttribute(`Blessed_{Custom}`, Value)
			else
				Character:SetAttribute(`Blessed_{Custom}`, nil)
			end
		else
			if (Value) then
				Character:SetAttribute(`Blessed`, Value)
			else
				Character:SetAttribute(`Blessed`, nil)
			end
		end
		
	elseif Effect == "Darkness" then
		
		if (Value) then
			
			Character:SetAttribute("Darkness", Value)
			
			if (Character.PrimaryPart:FindFirstChild("DarknessTrail") ~= nil) then
				return
			end
			
			local newEmitter = game.ReplicatedStorage.KillerStuff.Phantasm.DarknessTrail:Clone()
			newEmitter.Parent = Character.PrimaryPart
			
			local TrailMotor = Instance.new("Motor6D")
			TrailMotor.Name = "TrailMotor"
			TrailMotor.Parent = Character.PrimaryPart
			TrailMotor.Part0 = Character.PrimaryPart
			TrailMotor.Part1 = newEmitter
			TrailMotor.C1 = CFrame.new(0, 5, 0.25)
			
			newEmitter.TrailAppearance.Enabled = true
		else
			Character:SetAttribute("Darkness", nil)
		end

	elseif Effect == "Hidden" then

		if Custom then
			local current_effect = if Character:GetAttribute("Hidden_"..Custom) then string.split(Character:GetAttribute("Hidden_"..Custom), ':') else {0, 0}

			if Value then

				if (tonumber(current_effect[1]) - workspace:GetServerTimeNow()) <= Value and tonumber(current_effect[2]) >= 0 then -- if this makes shield last longer apply
					Character:SetAttribute("Hidden_"..Custom, (workspace:GetServerTimeNow() + Value)..':'..Value) -- shield last till this long, total time
				elseif Value < 0 then
					Character:SetAttribute("Hidden_"..Custom, '0:-1')
				end
			else -- attempting to remove shield
				Character:SetAttribute("Hidden_"..Custom, nil)
			end
		else -- Not A Custom Branch -- Use Blind Logic
			local current_effect = if Character:GetAttribute("Hidden") then string.split(Character:GetAttribute("Hidden"), ':') else {0, 0}

			if Value then

				if (tonumber(current_effect[1]) - workspace:GetServerTimeNow()) <= Value and tonumber(current_effect[2]) >= 0 then -- if this makes shield last longer apply
					Character:SetAttribute("Hidden", (workspace:GetServerTimeNow() + Value)..':'..Value) -- shield last till this long, total time
				elseif Value < 0 then
					Character:SetAttribute("Hidden", '0:-1')
				end
			else -- attempting to remove shield

				if tonumber(current_effect[2]) >= 0 then
					Character:SetAttribute("Hidden", nil)
				end
			end
		end
	elseif Effect == "Rejuvenation" or Effect == "Quick_Recover" or Effect == "Anti-Exhaust" then
		
		if Custom then
			local current_Rejuvenation = if Character:GetAttribute("Rejuvenation_"..Custom) then string.split(Character:GetAttribute("Rejuvenation_"..Custom), ':') else {0, 0, 0}

			if Value and tonumber(current_Rejuvenation[3]) >= 0 then

				if typeof(Value) == "number" then
					Value = {Value, 5} -- we only recieved a length of haste (auto set haste amount to 5/5%)
				end

				if Value[2] <= 0 then -- attempting to set haste to 0 or below 0 **IMPOSSIBLE/IMPROPER** remove it instead
					Character:SetAttribute("Rejuvenation_"..Custom, nil) -- effect last till this long, total time
				elseif (tonumber(current_Rejuvenation[2]) - workspace:GetServerTimeNow()) <= Value[1] then -- if this makes shield last longer apply
					Character:SetAttribute("Rejuvenation_"..Custom, Value[2]..':'..(workspace:GetServerTimeNow() + Value[1])..':'..Value[1]) -- shield last till this long, total time
				elseif Value[1] < 0 then
					Character:SetAttribute("Rejuvenation_"..Custom, '0:-1')
				end
			else -- attempting to remove shield
				Character:SetAttribute("Rejuvenation_"..Custom, nil)
			end
		else -- Not A Custom Branch -- Use Base Logic
			local current_Rejuvenation = if Character:GetAttribute("Rejuvenation") then string.split(Character:GetAttribute("Rejuvenation"), ':') else {0, 0, 0}

			if Value and tonumber(current_Rejuvenation[3]) >= 0 then

				if typeof(Value) == "number" then
					Value = {Value, 5} -- we only recieved a length of haste (auto set haste amount to 5/5%)
				end

				if Value[2] <= 0 then -- attempting to set haste to 0 or below 0 **IMPOSSIBLE/IMPROPER** remove it instead
					Character:SetAttribute("Rejuvenation", nil) -- effect last till this long, total time
				elseif (tonumber(current_Rejuvenation[2]) - workspace:GetServerTimeNow()) <= Value[1] then -- if this makes effect last longer apply
					Character:SetAttribute("Rejuvenation", Value[2]..':'..(workspace:GetServerTimeNow() + Value[1])..':'..Value[1]) -- effect last till this long, total time
				elseif Value[1] < 0 then
					Character:SetAttribute("Rejuvenation", Value[2]..':0:-1') -- perma haste at this speed
				end
			else -- attempting to remove shield

				if tonumber(current_Rejuvenation[3]) >= 0 then
					Character:SetAttribute("Rejuvenation", nil)
				end
			end
		end
	elseif Effect == "Haste" then
		
		local player = game.Players:GetPlayerFromCharacter(Character)

		if Custom then
			local current_haste = if Character:GetAttribute("Haste_"..Custom) then string.split(Character:GetAttribute("Haste_"..Custom), ':') else {0, 0, 0}

			if Value and tonumber(current_haste[3]) >= 0 then

				if typeof(Value) == "number" then
					Value = {Value, 5} -- we only recieved a length of haste (auto set haste amount to 5/5%)
				end

				if Value[2] <= 0 then -- attempting to set haste to 0 or below 0 **IMPOSSIBLE/IMPROPER** remove it instead
					Character:SetAttribute("Haste_"..Custom, nil) -- effect last till this long, total time
					_G.GetValue(player, "SpeedMultiplier"):Remove("Haste_"..Custom)
				elseif (tonumber(current_haste[2]) - workspace:GetServerTimeNow()) <= Value[1] then -- if this makes shield last longer apply
					Character:SetAttribute("Haste_"..Custom, Value[2]..':'..(workspace:GetServerTimeNow() + Value[1])..':'..Value[1]) -- shield last till this long, total time
					_G.GetValue(player, "SpeedMultiplier"):Add("Haste_"..Custom, (Value[2] / 100), Value[1])
				elseif Value[1] < 0 then
					Character:SetAttribute("Haste_"..Custom, '0:-1')
					_G.GetValue(player, "SpeedMultiplier"):Add("Haste_"..Custom, (Value[2] / 100), -1)
				end
			else -- attempting to remove shield
				Character:SetAttribute("Haste_"..Custom, nil)
				_G.GetValue(player, "SpeedMultiplier"):Remove("Haste_"..Custom)
			end
		else -- Not A Custom Branch -- Use Base Logic
			local current_haste = if Character:GetAttribute("Haste") then string.split(Character:GetAttribute("Haste"), ':') else {0, 0, 0}

			if Value and tonumber(current_haste[3]) >= 0 then

				if typeof(Value) == "number" then
					Value = {Value, 5} -- we only recieved a length of haste (auto set haste amount to 5/5%)
				end

				if Value[2] <= 0 then -- attempting to set haste to 0 or below 0 **IMPOSSIBLE/IMPROPER** remove it instead
					Character:SetAttribute("Haste", nil) -- effect last till this long, total time
					_G.GetValue(player, "SpeedMultiplier"):Remove("Haste")
				elseif (tonumber(current_haste[2]) - workspace:GetServerTimeNow()) <= Value[1] then -- if this makes effect last longer apply
					Character:SetAttribute("Haste", Value[2]..':'..(workspace:GetServerTimeNow() + Value[1])..':'..Value[1]) -- effect last till this long, total time
					_G.GetValue(player, "SpeedMultiplier"):Add("Haste", (Value[2] / 100), Value[1])
				elseif Value[1] < 0 then
					Character:SetAttribute("Haste", Value[2]..':0:-1') -- perma haste at this speed
					_G.GetValue(player, "SpeedMultiplier"):Add("Haste", (Value[2] / 100), -1)
				end
			else -- attempting to remove shield

				if tonumber(current_haste[3]) >= 0 then
					Character:SetAttribute("Haste", nil)
					_G.GetValue(player, "SpeedMultiplier"):Remove("Haste")
				end
			end
		end
	elseif Effect == "Slow" then
		
		local player = game.Players:GetPlayerFromCharacter(Character)

		if Custom then
			local current_slow = if Character:GetAttribute("Slow_"..Custom) then string.split(Character:GetAttribute("Slow_"..Custom), ':') else {0, 0, 0}

			if Value and tonumber(current_slow[3]) >= 0 then

				if typeof(Value) == "number" then
					Value = {Value, 5} -- we only recieved a length of haste (auto set haste amount to 5/5%)
				end

				if Value[2] <= 0 then -- attempting to set haste to 0 or below 0 **IMPOSSIBLE/IMPROPER** remove it instead
					Character:SetAttribute("Slow_"..Custom, nil) -- effect last till this long, total time
					_G.GetValue(player, "SpeedMultiplier"):Remove("Slow_"..Custom)
				elseif (tonumber(current_slow[2]) - workspace:GetServerTimeNow()) <= Value[1] then -- if this makes shield last longer apply
					Character:SetAttribute("Slow_"..Custom, Value[2]..':'..(workspace:GetServerTimeNow() + Value[1])..':'..Value[1]) -- shield last till this long, total time
					_G.GetValue(player, "SpeedMultiplier"):Add("Slow_"..Custom, -(Value[2] / 100), Value[1])
				elseif Value[1] < 0 then
					Character:SetAttribute("Slow_"..Custom, '0:-1')
					_G.GetValue(player, "SpeedMultiplier"):Add("Slow_"..Custom, -(Value[2] / 100), -1)
				end
			else -- attempting to remove shield
				Character:SetAttribute("Slow_"..Custom, nil)
				_G.GetValue(player, "SpeedMultiplier"):Remove("Slow_"..Custom)
			end
		else -- Not A Custom Branch -- Use Base Logic
			local current_slow = if Character:GetAttribute("Slow") then string.split(Character:GetAttribute("Slow"), ':') else {0, 0, 0}

			if Value and tonumber(current_slow[3]) >= 0 then

				if typeof(Value) == "number" then
					Value = {Value, 5} -- we only recieved a length of haste (auto set haste amount to 5/5%)
				end

				if Value[2] <= 0 then -- attempting to set haste to 0 or below 0 **IMPOSSIBLE/IMPROPER** remove it instead
					Character:SetAttribute("Slow", nil) -- effect last till this long, total time
					_G.GetValue(player, "SpeedMultiplier"):Remove("Slow")
				elseif (tonumber(current_slow[2]) - workspace:GetServerTimeNow()) <= Value[1] then -- if this makes effect last longer apply
					Character:SetAttribute("Slow", Value[2]..':'..(workspace:GetServerTimeNow() + Value[1])..':'..Value[1]) -- effect last till this long, total time
					_G.GetValue(player, "SpeedMultiplier"):Add("Slow", -(Value[2] / 100), Value[1])	
				elseif Value[1] < 0 then
					Character:SetAttribute("Slow", Value[2]..':0:-1') -- perma haste at this speed
					_G.GetValue(player, "SpeedMultiplier"):Add("Slow", -(Value[2] / 100), -1)
				end
			else -- attempting to remove shield

				if tonumber(current_slow[3]) >= 0 then
					Character:SetAttribute("Slow", nil)
					_G.GetValue(player, "SpeedMultiplier"):Remove("Slow")
				end
			end
		end
	elseif Effect == "Quiet" then

		if Custom then
			local current_effect = if Character:GetAttribute("Quiet_"..Custom) then string.split(Character:GetAttribute("Quiet_"..Custom), ':') else {0, 0, 0}

			if Value and tonumber(current_effect[3]) >= 0 then

				if typeof(Value) == "number" then
					Value = {Value, 5} -- we only recieved a length of haste (auto set haste amount to 5/5%)
				end

				if Value[2] <= 0 then -- attempting to set haste to 0 or below 0 **IMPOSSIBLE/IMPROPER** remove it instead
					Character:SetAttribute("Quiet_"..Custom, nil) -- effect last till this long, total time
				elseif (tonumber(current_effect[2]) - workspace:GetServerTimeNow()) <= Value[1] then -- if this makes shield last longer apply
					Character:SetAttribute("Quiet_"..Custom, Value[2]..':'..(workspace:GetServerTimeNow() + Value[1])..':'..Value[1]) -- shield last till this long, total time
				elseif Value[1] < 0 then
					Character:SetAttribute("Quiet_"..Custom, '0:-1')
				end
			else -- attempting to remove shield
				Character:SetAttribute("Quiet_"..Custom, nil)
			end
		else -- Not A Custom Branch -- Use Base Logic
			local current_effect = if Character:GetAttribute("Quiet") then string.split(Character:GetAttribute("Quiet"), ':') else {0, 0, 0}

			if Value and tonumber(current_effect[3]) >= 0 then

				if typeof(Value) == "number" then
					Value = {Value, 5} -- we only recieved a length of haste (auto set haste amount to 5/5%)
				end

				if Value[2] <= 0 then -- attempting to set haste to 0 or below 0 **IMPOSSIBLE/IMPROPER** remove it instead
					Character:SetAttribute("Quiet", nil) -- effect last till this long, total time
				elseif (tonumber(current_effect[2]) - workspace:GetServerTimeNow()) <= Value[1] then -- if this makes effect last longer apply
					Character:SetAttribute("Quiet", Value[2]..':'..(workspace:GetServerTimeNow() + Value[1])..':'..Value[1]) -- effect last till this long, total time
				elseif Value[1] < 0 then
					Character:SetAttribute("Quiet", Value[2]..':0:-1') -- perma haste at this speed
				end
			else -- attempting to remove shield

				if tonumber(current_effect[3]) >= 0 then
					Character:SetAttribute("Quiet", nil)
				end
			end
		end
	else
		--warn(Effect, 'unsupported!')
	end
end

return Handler