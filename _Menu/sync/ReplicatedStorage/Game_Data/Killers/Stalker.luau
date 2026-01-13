local Addon_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer')
local Offering_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Offerings'):WaitForChild('Killer')

local Killer = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = true; -- if this killer should be unlocked for free at this moment if ever

	Killer_Name = "Stalker";
	Killer_Image = "rbxassetid://136024258126709"; -- image id

	Power_Name = "Stalk";
	Power_Image = "rbxassetid://72592676566403"; -- image id
	Power_Color = Color3.fromRGB(56, 46, 43); -- color associated with images

	Description = "";

	Addons = {};
	Offerings = {};

	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this killer automatically

	-- GAMEPLAY --

	Stalk_Settings = {
		Capacity = {
			Level = 400; -- needed to level up (1->2)
			Exposed = 800 -- need to regain t3 (2 -> 3)
		};
		Gain_Rate = 200; -- 5.25 seconds till fully stalked
		Drain_Rate = 14.28; -- 70 seconds drain rate
		Accuracy = 0.8; -- accuracy of stalking
		Range = 140; -- Studs to stalk a victim

	},

	Stalk_Boost = {
		Speed = 6.5;
		Pallet = 10;
		Door = 15;
		Vault = 15;
	},
	
	Terror_Radius = 50 --studs
}

function GrabAddons() : "Attach our addons"

	for _, addon_module in pairs(Addon_Storage:GetChildren()) do
		if not addon_module:IsA('ModuleScript') then continue end -- not a module?
		addon_module = require(addon_module)

		for _, addon_killer in pairs(addon_module.Killers) do -- if it's a addon for our killer we attach it

			if addon_killer == script then
				table.insert(Killer.Addons, addon_module) -- attach to us
				break -- close thinking early
			end
		end
	end
end

function GrabOfferings() : "Attach our offerings"

	for _, offering_module in pairs(Offering_Storage:GetChildren()) do
		if not offering_module:IsA('ModuleScript') then continue end
		offering_module = require(offering_module)

		for _, offering_killer in pairs(offering_module.Killers) do

			if offering_killer == script then
				table.insert(Killer.Offerings, offering_module)
				break
			end
		end
	end
end

local StalkLimits = {}
local MAXLIMIT = 3000
local AllowedToTierUp = true

function Killer:Power(Player : Player) : "Boot up / configure power"
	local Data_Module, Code_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data')), require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Code'))

	-- Apply Addons Here | Camera Changes will not work [made dual power booting] | No Speed Changes --

	for _, Addon in pairs(Killer.Addons) do -- cycle through all addons

		if Data_Module:GetAddon("Killer", Player, Addon.Data_Name) then -- have this addon equipped currently

			if Addon.Duration_Increase then -- increase duration of rage
				Killer.Stalk_Settings.Capacity.Exposed = math.clamp(Killer.Stalk_Settings.Capacity.Exposed + (Killer.Stalk_Settings.Capacity.Exposed * Addon.Duration_Increase), 1, 999999)
			end

			if Addon.Stalk_Gain then
				Killer.Stalk_Settings.Gain_Rate = math.clamp(Killer.Stalk_Settings.Gain_Rate + (Killer.Stalk_Settings.Gain_Rate * Addon.Stalk_Gain), 1, 999999)
			end

			if Addon.Stalk_Loss then
				Killer.Stalk_Settings.Drain_Rate = math.clamp(Killer.Stalk_Settings.Drain_Rate + (Killer.Stalk_Settings.Drain_Rate * Addon.Stalk_Loss), 0, 999999)
			end

			if Addon.Stalk_Range then
				Killer.Stalk_Settings.Range = math.clamp(Killer.Stalk_Settings.Range + (Killer.Stalk_Settings.Range * Addon.Stalk_Range), 30, 999999)
			end
		end
	end

	Player.Character:SetAttribute("Power_Tier", 1) -- start in tier 1
	Player.Character:SetAttribute("Power_Progress", tostring(0)..':'..Killer.Stalk_Settings.Capacity.Level) -- start w/ 0 progress against level up capacity
	Player.Character:SetAttribute("Power_State", "Idle") -- manipulate power

	-- Stalk Logic --
	local Ignore_List = {}

	local Param = RaycastParams.new()
	Param.FilterDescendantsInstances = Ignore_List
	Param.FilterType = Enum.RaycastFilterType.Exclude

	local function Cast(origin : Model, goal : Model) : 'raycasting'
		local OurIgnore = Ignore_List

		table.insert(OurIgnore, origin)
		Param.FilterDescendantsInstances = OurIgnore

		local function repeatRay(localAdd, globalAdd)
			if localAdd then table.insert(OurIgnore, localAdd) end
			if globalAdd then table.insert(Ignore_List, localAdd) end

			Param.FilterDescendantsInstances = OurIgnore

			local Casting = workspace:Raycast(origin:GetPivot().Position, (goal:GetPivot().Position - origin:GetPivot().Position).Unit * (goal:GetPivot().Position - origin:GetPivot().Position).Magnitude, Param)

			if Casting then

				if Casting.Instance == goal or Casting.Instance:IsDescendantOf(goal) then
					return true, Casting.Instance, false
				elseif Casting.Instance.Transparency > 0.25 then
					return false, Casting.Instance, true
				else
					return true, nil, false
				end
			else
				return true, nil, false
			end
		end

		local Finished, object, block = nil, nil, nil

		repeat Finished, object, block = repeatRay(object, block)
			task.wait()
		until Finished

		if object and (object == goal or object:IsDescendantOf(goal)) then
			return true
		else
			return false
		end
	end

	local connection connection = game:GetService('RunService').Heartbeat:Connect(function(delta)
		if not Player.Character then return end
		local current_stalk = string.split(Player.Character:GetAttribute("Power_Progress"), ':')
		local current_power_state = Player.Character:GetAttribute("Power_State")

		if current_power_state == "Idle" then -- fill it they are idle
			-- DO NOTHING
		elseif current_power_state == "Stalking" then
			if tonumber(current_stalk[1]) < tonumber(current_stalk[2]) then
				local gained = false
				for _, Survivor : Player in pairs(game:GetService('Teams'):WaitForChild('Survivor'):GetPlayers()) do
					if tonumber(current_stalk[1]) > tonumber(current_stalk[2]) then break end
					if Code_Module:IsDown(Survivor) or Code_Module:IsHooked(Survivor) then continue end
					if Survivor:WaitForChild("Backpack"):WaitForChild("Scripts"):WaitForChild("values"):WaitForChild("Action").Value == "Hiding" then continue end

					local Direction = (Survivor.Character:GetPivot().Position - Player.Character:WaitForChild('Head').Position).Unit
					local Dot = Direction:Dot(Player.Character:WaitForChild('Head').CFrame.LookVector)
					local Distance = (Survivor.Character:GetPivot().Position - Player.Character:GetPivot().Position).Magnitude

					if Dot > Killer.Stalk_Settings.Accuracy and Distance <= Killer.Stalk_Settings.Range then -- looking in right direction and within range
						local Range_Falloff_Bracket = (math.clamp(Distance - 10, 0, 9999999999999) / (Killer.Stalk_Settings.Range - 10))
						local CanSee = Cast(Player.Character, Survivor.Character)
						--[[local LIMIT = nil

						for i, b in pairs(StalkLimits) do
							if b then
								if b.Name == Survivor.Name then
									LIMIT = b
								end
							end
						end

						if LIMIT == nil then
							LIMIT = {Name = Survivor.Name, Limit = 0}
							table.insert(StalkLimits,LIMIT)
						end]]

						if CanSee --[[and LIMIT.Limit < MAXLIMIT]] then
							--LIMIT.Limit += (delta * (Killer.Stalk_Settings.Gain_Rate - (Range_Falloff_Bracket * Killer.Stalk_Settings.Gain_Rate))) * 0.8
							Player.Character:SetAttribute("Power_Progress", math.clamp(tonumber(current_stalk[1]) + (delta * (Killer.Stalk_Settings.Gain_Rate - (Range_Falloff_Bracket * Killer.Stalk_Settings.Gain_Rate))), 0, tonumber(current_stalk[2]))..':'..current_stalk[2])
						end
					end
				end
			else -- level up stalk
				if AllowedToTierUp then
					if Player.Character:GetAttribute("Power_Tier") == 1 and AllowedToTierUp == true then
					--	warn("TIERED UP!")
						AllowedToTierUp = false
						Player.Character:SetAttribute("Power_Progress", tostring(0)..':'..Killer.Stalk_Settings.Capacity.Exposed)
						Player.Character:SetAttribute("Power_Tier", 2) -- level up
						Data_Module:GiveBlood(Player, 500, "Deviousness", "STALKED")
						
						task.delay(2,function()
							AllowedToTierUp = true
						end)

						Player.Character:SetAttribute("Power_Progress", tostring(0)..':'..Killer.Stalk_Settings.Capacity.Exposed)
					elseif AllowedToTierUp == true then 
						AllowedToTierUp = false -- into tier 3
						Player.Character:SetAttribute("Power_State", "Idle")
						Player.Character:SetAttribute("Power_Tier", 3) -- level up
						Data_Module:GiveBlood(Player, 500, "Deviousness", "STALKED")
						
						task.delay(2,function()
							AllowedToTierUp = true
						end)
					end
				end
			end
		elseif current_power_state == "Draining" then -- drain it they are using it
			if tonumber(current_stalk[1]) > 0 then
				Player.Character:SetAttribute("Power_Progress", math.clamp(tonumber(current_stalk[1]) - (delta * Killer.Stalk_Settings.Drain_Rate), 0, tonumber(current_stalk[2]))..':'..current_stalk[2])
			else
				Player.Character:SetAttribute("Power_State", "Idle")
				Player.Character:SetAttribute("Power_Progress", tostring(0)..':'..current_stalk[2])
				Player.Character:SetAttribute("Power_Tier", 2)
			end
		end
	end)

	return Killer
end

function Killer.Configure()
	Killer.Description = [[
<b>STALK</b>
By pressing and holding the <i>Power Button</i> you start <i>Stalking</i>.
<i>Stalking</i> a survivor gives you stalking power which fills up until the next tier.
The Stalker requires clear line of sight with the Survivors to be able to stalk, stalking survivors give the following effects:

<b>TIER I</b>
The Stalker starts in <b>Tier I</b>
Grants the <i>Hidden</i> status effect.
Movement speed is decreased.

<b>TIER II</b>
Removes the <i>Hidden</i> status effect.
Movement speed is increased.
Terror radius is slightly increased.

<b>TIER III</b>
Grants the <i>Exposed</i> status effect to all survivors.
Terror radius is greatly increased.
Vaulting speed is increased.
Movement speed is increased.

<i>TIER III</i> last for 70 seconds, after it expires The Stalker goes back to <i>Tier II</i>.
]]

	GrabAddons()
	GrabOfferings()

	return Killer
end

return Killer.Configure()
