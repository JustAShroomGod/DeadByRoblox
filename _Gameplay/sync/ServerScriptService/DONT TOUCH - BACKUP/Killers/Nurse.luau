local Addon_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer')
local Offering_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Offerings'):WaitForChild('Killer')

local Killer = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = true; -- if this killer should be unlocked for free at this moment if ever
	
	Killer_Name = "Nurse";
	Killer_Image = "rbxassetid://14240405697"; -- image id
	
	Power_Name = "Blink";
	Power_Image = "rbxassetid://9637320889"; -- image id
	Power_Color = Color3.fromRGB(56, 46, 43); -- color associated with images
	
	Description = "";

	Addons = {};
	Offerings = {};
	
	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this killer automatically

	-- GAMEPLAY --
	
	Max_Blinks = 2;
	
	Speed_Settings = {
		Charging = 0.90; -- slow down by 90% while aiming
	},
	
	Blink_Settings = {
		Charge_Speed = 1000/5;
		Recharge_Speed = 1000/2;
		Chain_Window_Speed = 1000/1.5; --1.5 secs
		Blink_Distance_Per_Charge = 50/1000;
		Min_Distance = 20;
		Max_Distance = 70;
	};
	
	Timing_Settings = {
		Wind_Up = 1;
	};
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

function Killer:Power_Client(Player : Player) : "Adjust Power on Client Side"
	if not game["Run Service"]:IsClient() then return end -- not for server use
	local Data_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))

	-- Apply Addons Here --

	--[[for _, Addon in pairs(Killer.Addons) do -- cycle through all addons

		if Data_Module:GetAddon("Killer", Player, Addon.Data_Name) then -- have this addon equipped currently

			if Addon.Hatchet_Boost then
				Killer.Hatchet_Count = math.clamp(Killer.Hatchet_Count + Addon.Hatchet_Boost, 1, 100)
			end
		end
	end]]
end

--ALL STATES: Idle,Animation,Charging,Chain_Window (after blinking while having atleast 1 more blink)

function Killer:Power(Player : Player) : "Boot up / configure power"
	local Data_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))

	-- Apply Addons Here | Camera Changes will not work [made dual power booting] | No Speed Changes --

	--[[for _, Addon in pairs(Killer.Addons) do -- cycle through all addons

		if Data_Module:GetAddon("Killer", Player, Addon.Data_Name) then -- have this addon equipped currently


		end
	end]]

	Player.Character:SetAttribute("Power", '0:1000')
	Player.Character:SetAttribute("Power_State", "Idle") -- manipulate power
	Player.Character:SetAttribute("Blink_Count", Killer.Max_Blinks) 

	local last_power_state = "Idle"
	local connection connection = game:GetService('RunService').Stepped:Connect(function(t, delta)
		if not Player.Character then return end
		local current_power = string.split(Player.Character:GetAttribute("Power"), ':')

		local current_power_state = Player.Character:GetAttribute("Power_State")
		local current_blink_count = Player.Character:GetAttribute("Blink_Count")

		if not (current_power_state == last_power_state) then
			Player.Character:SetAttribute("Power", '0:1000')
		end

		if current_power_state == "Idle" then -- fill it they are idle
			if current_blink_count < Killer.Max_Blinks then
				
				if tonumber(current_power[1]) < tonumber(current_power[2]) then
					Player.Character:SetAttribute("Power", math.clamp(tonumber(current_power[1]) + (delta * Killer.Blink_Settings.Recharge_Speed), 0, tonumber(current_power[2]))..':'..current_power[2])
				end

				if tonumber(current_power[1]) >= tonumber(current_power[2]) then
					Player.Character:SetAttribute("Blink_Count", Killer.Max_Blinks) 
					Player.Character:SetAttribute("Power", '0:1000')
				end
			end
		elseif current_power_state == "Animation" then
			-- DO NOTHING
		elseif current_power_state == "Chain_Window" then -- fill it they are using it
			if tonumber(current_power[1]) < tonumber(current_power[2]) then
				Player.Character:SetAttribute("Power", math.clamp(tonumber(current_power[1]) + (delta * Killer.Blink_Settings.Chain_Window_Speed), 0, tonumber(current_power[2]))..':'..current_power[2])
			end
		elseif current_power_state == "Charging" then -- fill it they are using it
			if tonumber(current_power[1]) < tonumber(current_power[2]) then
				Player.Character:SetAttribute("Power", math.clamp(tonumber(current_power[1]) + (delta * Killer.Blink_Settings.Charge_Speed), 0, tonumber(current_power[2]))..':'..current_power[2])
			end
		end
		
		last_power_state = current_power_state
	end)

	return Killer
end

function Killer.Configure()
	Killer.Description = [[
<b>BLINK</b>
The Nurse passively recharges her Blink Charges when not in use.

When the <i>Power Gauge</i> is filled, the Nurse gains a Blink Charge.

hold down the <i>Power Button</i> to start charging a Blink:
- Charging a Blink for longer causes the Nurse to teleport further.
- Releasing a Blink consumes a Blink Charge.

Releasing a charged Blink will teleport the Nurse to her destination.

After teleporting the Nurse is given 2 options:
- Charge a Chain Blink (When at least one Blink Charge is left)
- Perform a Blink Attack

When none of those options is chosen the Nurse will enter <i>Fatigue</i>.

The Nurse can hold up to <i>]]..Killer.Max_Blinks ..[[ Blinks<i> .
]]

	GrabAddons()
	GrabOfferings()
	
	return Killer
end

return Killer.Configure()
