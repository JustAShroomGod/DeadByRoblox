local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local Badge_Manager = require(ServerStorage:WaitForChild("Modules"):WaitForChild("BadgeManager"))

local Killer_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild('Architect'))

local module = {}


function module:Fire(Player : Player, Arguments : "table")
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')
	local Command : boolean = Arguments[2]

	print(Player, 'has attempted to use power of architect')

	if Command == "Start_Rage" then
		local Length = (Killer_Module.Timings.Scream + 0)
		Player.Character:SetAttribute("Animation", "")
		Length -= 0.1
		task.wait(0.1)
		
		_G.GetValue(Player.Name, "DisruptiveActions"):Add("Ability", 1, nil)

		Player.Character:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length)
		Player.Character:SetAttribute("Animation", "Scream")
		Player.Character:SetAttribute("Power_State", "Animation")

		playerValues:WaitForChild('KillerAction').Value = "Rush_Charge"
		playerValues:WaitForChild('Action').Value = "Rush_Charge"

		task.wait(Length * 0.45)
		Length -= (Length * 0.45)

		local s = script.Parent.Parent:WaitForChild('Sounds'):WaitForChild('Roar'):Clone()
		s.Parent = Player.Character.PrimaryPart
		s:Remove()

		task.wait(Length - 0.1)
		Length = (Killer_Module.Timings.Wind + 0)

		Player.Character:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length)
		Player.Character:SetAttribute("Animation", "Wind")

		task.wait(Length)

		local s = Player.Character.PrimaryPart:FindFirstChild("STOMP")

		if s then
			s:Remove()
		end

		s = script.Parent.Parent:WaitForChild('Sounds'):WaitForChild('Stomp'):Clone()
		s.Parent = Player.Character.PrimaryPart
		s:Play()

		Player.Character:SetAttribute("Power_State", "PowerUsage")
		data_module:GiveBlood(Player, 100, "Deviousness", "RAGE RUSH")
	elseif Command == "End_Rage" then
		local Length = (Killer_Module.Timings.Exhaust + 0)

		Player.Character:SetAttribute("Animation", "")
		Length -= 0.1
		task.wait(0.1)

		if Player.Character.PrimaryPart:FindFirstChild("Stomp") then Player.Character.PrimaryPart:WaitForChild("Stomp"):Remove() end

		_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")

		Player.Character:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length)
		Player.Character:SetAttribute("Animation", "Slam")
		Player.Character:SetAttribute("Power_State", "Animation")

		task.wait(Length * 0.25)
		Length -= (Length * 0.25)

		local s = script.Parent.Parent:WaitForChild('Sounds'):WaitForChild('Hammer_Slam'):Clone()
		s.Parent = Player.Character.PrimaryPart
		s:Remove()

		task.wait(Length)
		Player.Character:SetAttribute("Power_State", "Idle")

		playerValues:WaitForChild('KillerAction').Value = "Nothing"
		playerValues:WaitForChild('Action').Value = "Nothing"
	elseif Command == "Hit_Object" then
		local current_rage = string.split(Player.Character:GetAttribute("Power"), ':')
		local object = Arguments[3]
		
		_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")

		if string.match(string.lower(object.Name), 'pallet') then
			object:WaitForChild('Panel'):WaitForChild('State').Value = 2
			Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('PerksBase'):WaitForChild('SpiritFury'):WaitForChild('Pallets').Value += 1
			if Player.Character:GetAttribute("Power_State") == "Idle" then
				Player.Character:SetAttribute("Power",  math.clamp(tonumber(current_rage[1]) - Killer_Module.Rage_Loss.Break + 80, 0, tonumber(current_rage[2]))..':'..tonumber(current_rage[2]))
			else
				Player.Character:SetAttribute("Power",  math.clamp(tonumber(current_rage[1]) - Killer_Module.Rage_Loss.Break, 0, tonumber(current_rage[2]))..':'..tonumber(current_rage[2]))
			end
			data_module:GiveBlood(Player, 500, "Brutality", "DESTRUCTION!")
		elseif string.match(string.lower(object.Name), 'breakablewall') then
			object:WaitForChild('Panel'):WaitForChild('Broken').Value = true
			if Player.Character:GetAttribute("Power_State") == "Idle" then
				Player.Character:SetAttribute("Power",  math.clamp(tonumber(current_rage[1]) - Killer_Module.Rage_Loss.Break + 80, 0, tonumber(current_rage[2]))..':'..tonumber(current_rage[2]))
			else
				Player.Character:SetAttribute("Power",  math.clamp(tonumber(current_rage[1]) - Killer_Module.Rage_Loss.Break, 0, tonumber(current_rage[2]))..':'..tonumber(current_rage[2]))
			end
			data_module:GiveBlood(Player, 500, "Brutality", "DESTRUCTION!")
		elseif game.Players:FindFirstChild(object.Name) then
			object = game.Players:WaitForChild(object.Name)
			local Survivor_Backpack = object:WaitForChild('Backpack'):WaitForChild('Scripts')
			local S_perkBase, S_playerValues = Survivor_Backpack:WaitForChild('PerksBase'), Survivor_Backpack:WaitForChild('values')

			if S_playerValues:WaitForChild('HealthState').Value > 0 and S_playerValues.Hooked.Value == false then
				task.spawn(function()
					require(script.Parent:WaitForChild('HitPlayer')):Fire("Hit", Player, object, 'Rage')
				end)
				
				task.delay(1.5,function()
					code_module:SetEffect("Slow", object, {10, 5}, "Architect_Rage_Buff")
				end)
			end


			Player.Character:SetAttribute("Power",  math.clamp(tonumber(current_rage[1]) - Killer_Module.Rage_Loss.Injure, 0, tonumber(current_rage[2]))..':'..tonumber(current_rage[2]))
		end

		print('Hit', object)
	else
		warn(Command, 'not supported!')
	end
end

return module
