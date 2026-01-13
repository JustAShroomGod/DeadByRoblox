local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local Badge_Manager = require(ServerStorage:WaitForChild("Modules"):WaitForChild("BadgeManager"))

local Killer_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild('Hillbilly'))

local module = {}


function module:Fire(Player : Player, Arguments : "table")
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')
	local Command : boolean = Arguments[2]
	local Power_State = Player.Character:GetAttribute("Power_State")

	--	print(Player, 'has attempted to use power of hillbilly')

	if Command == "Start_Saw" then
		_G.GetValue(Player.Name, "DisruptiveActions"):Add("Ability", 1, nil)
		Player.Character:SetAttribute("Power_State", "Charging_Up") -- charge up mode

		playerValues:WaitForChild('KillerAction').Value = "Charging"
		playerValues:WaitForChild('Action').Value = "Charging"

		local ADDONS = data_module:GetAddon("Killer",Player,"Rocket Fuel")
		if ADDONS == true then
			if (Player.Character.Chainsaw['BodyParts'].Blade:FindFirstChild('Flame') ~= nil) then
				Player.Character.Chainsaw['BodyParts'].Blade:FindFirstChild('Flame').Enabled = true
			else
				local V = script.Flame:Clone()
				V.Parent = Player.Character.Chainsaw['BodyParts'].Blade
				V.Enabled = true
			end
		end
	elseif Command == "Stunned_Saw" then
		spawn(function()
			if (Player.Character.Chainsaw['BodyParts'].Blade:FindFirstChild('Flame') ~= nil) then
				Player.Character.Chainsaw['BodyParts'].Blade:FindFirstChild('Flame').Enabled = false
			end
		end)
		_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")
		if Power_State == "Charging_Up" then
			Player.Character:SetAttribute("Power_State", "Stun_Animation")
			task.wait(1)
			Player.Character:SetAttribute("Power_State", "Animation")
		elseif Power_State == "Using" then
			task.wait()
			Player.Character:SetAttribute("Power_State", "Animation")
		else
			warn(Power_State)
		end
	elseif Command == "Stop_Saw" then
		spawn(function()
			if (Player.Character.Chainsaw['BodyParts'].Blade:FindFirstChild('Flame') ~= nil) then
				Player.Character.Chainsaw['BodyParts'].Blade:FindFirstChild('Flame').Enabled = false
			end
		end)
		_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")
		if Power_State == "Charging_Up" then
			Player.Character:SetAttribute("Power_State", "Charging_Down") -- charge up mode

		elseif Power_State == "Using" then
			Player.Character:SetAttribute("Power_State", "Animation")
			playerValues:WaitForChild('KillerAction').Value = "Stop"
			playerValues:WaitForChild('Action').Value = "Stop"
		else
			warn(Power_State)
		end
	elseif Command == "Finished_Saw" then -- complete exit of sawing
		spawn(function()
			if (Player.Character.Chainsaw['BodyParts'].Blade:FindFirstChild('Flame') ~= nil) then
				Player.Character.Chainsaw['BodyParts'].Blade:FindFirstChild('Flame').Enabled = false
			end
		end)
		_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")
		playerValues:WaitForChild('KillerAction').Value = "Stop"
		playerValues:WaitForChild('Action').Value = "Stop"
		Player.Character:SetAttribute("Power_State", "Idle")
		playerValues:WaitForChild('KillerAction').Value = "Nothing"
		playerValues:WaitForChild('Action').Value = "Nothing"
	elseif Command == "Hit_Object" then
		spawn(function()
			if (Player.Character.Chainsaw['BodyParts'].Blade:FindFirstChild('Flame') ~= nil) then
				Player.Character.Chainsaw['BodyParts'].Blade:FindFirstChild('Flame').Enabled = false
			end
		end)
		playerValues:WaitForChild('KillerAction').Value = "Hit"
		playerValues:WaitForChild('Action').Value = "Hit"
		local current_rage = string.split(Player.Character:GetAttribute("Power"), ':')
		local object = Arguments[3]

		_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")

		if string.match(string.lower(object.Name), 'pallet') then
			object:WaitForChild('Panel'):WaitForChild('State').Value = 2
			Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('PerksBase'):WaitForChild('SpiritFury'):WaitForChild('Pallets').Value += 1
			spawn(function()
				Player.Character:SetAttribute("Power",  math.clamp(tonumber(current_rage[1]) - Killer_Module.Rage_Loss.Break, 0, tonumber(current_rage[2]))..':'..tonumber(current_rage[2]))
			end)
			data_module:GiveBlood(Player, 500, "Brutality", "DESTRUCTION!")
		elseif string.match(string.lower(object.Name), 'breakablewall') then
			object:WaitForChild('Panel'):WaitForChild('Broken').Value = true
			spawn(function()
				Player.Character:SetAttribute("Power",  math.clamp(tonumber(current_rage[1]) - Killer_Module.Rage_Loss.Break, 0, tonumber(current_rage[2]))..':'..tonumber(current_rage[2]))
			end)
			data_module:GiveBlood(Player, 500, "Brutality", "DESTRUCTION!")
		elseif game.Players:FindFirstChild(object.Name) then
			object = game.Players:WaitForChild(object.Name)

			require(script.Parent:WaitForChild('HitPlayer')):Fire("Hit", Player, object, "Chainsaw")
		end

		print('Hit', object)
	else
		warn(Command, 'not supported!')
	end
end

return module
