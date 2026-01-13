local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local Badge_Manager = require(ServerStorage:WaitForChild("Modules"):WaitForChild("BadgeManager"))

local Killer_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild('Nurse'))

local module = {}

function module:Fire(Player : Player, Arguments : "table")
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')
	local Command : boolean = Arguments[2]
	
	print(Player, 'has attempted to use power of nurse')
	
	if Command == "Start_Charge" then
		local Length = (Killer_Module.Timing_Settings.Wind_Up + 0)

		print('CHARGE START')

		Player.Character:SetAttribute("Animation", "")
		Length -= 0.1
		task.wait(0.1)

		code_module:SetEffect("Slow", Player, {-1, (Killer_Module.Speed_Settings.Charging * 100)}, 'Nurse_Charge') -->> apply slowness

		Player.Character:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length)
		Player.Character:SetAttribute("Animation", "Charge")
		Player.Character:SetAttribute("Power_State", "Animation")

		playerValues.Action.Value = "Charging_Blink"
		playerValues.KillerAction.Value = "Charging_Blink"

		task.wait(Length - 0.1)

		if playerValues.Action.Value == "Charging_Blink" then
			Player.Character:SetAttribute("Power_State", "Charging") -- knock us back to idle
			
			playerValues.Action.Value = "Holding_Blink"
			playerValues.KillerAction.Value = "Holding_Blink"
		else
			warn('bypassed')
		end
	elseif Command == "Hold_Charge" then
		
	elseif Command == "Stop_Charge" then
		local IsBlinking = if Arguments[3] then Arguments[3] else false

		Player.Character:SetAttribute("Power_State", "Animation") -- knock us back to idle
		playerValues.Action.Value = "Blinking"
		playerValues.KillerAction.Value = "Blinking"

		local Blink_Power = string.split(Player.Character:GetAttribute("Power"), ':')[1]
		Blink_Power = math.clamp(tonumber(Blink_Power), Killer_Module.Blink_Settings.Min_Distance, math.clamp(tonumber(Blink_Power), Killer_Module.Blink_Settings.Min_Distance, 100000)) * Killer_Module.Blink_Settings.Blink_Distance_Per_Charge

		code_module:SetEffect("Slow", Player, nil, 'Nurse_Charge') -->> remove slowness

		if IsBlinking then
			--local Length = (Killer_Module.Timing_Settings.Mouse_Debounce + 0)

			Player.Character:SetAttribute("Power_State", "Animation") -- knock us back to idle

			print('Blinking w/ power at:', Blink_Power)

			Player.Character:SetAttribute("Blink_Count", math.clamp(tonumber(Player.Character:GetAttribute("Blink_Count")) - 1, 0, 100))

			if Player.Character:GetAttribute("Blink_Count") > 0 then
				Player.Character:SetAttribute("Power_State","Chain_Window")
			end
			--Throw_Hatchet(Player, Hatchet_Power, Arguments[4] * Killer_Module.Camera_Offset)

			--task.wait(Length)
		else
			Player.Character:SetAttribute("Power_State", "Idle") -- knock us back to idle
			warn('Do not blink, retreat')
			--task.wait(Killer_Module.Timing_Settings.Wind_Down)

		end

		print('remove the slowness')

		playerValues.Action.Value = "Nothing"
		playerValues.KillerAction.Value = "Nothing"
	else
		warn(Command, 'not supported!')
	end
end

return module
