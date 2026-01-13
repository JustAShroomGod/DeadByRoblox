local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local Badge_Manager = require(ServerStorage:WaitForChild("Modules"):WaitForChild("BadgeManager"))

local Killer_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild('Doctor'))



local Addon_Modules = {
}

local module = {
	Ignore_List = {}
}

function module:Fire(Player : Player, Arguments : "table")
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')
	local Command : boolean = Arguments[2]

	print(Player, 'has attempted to use power of doctor :', Command)

	if Command == "Start_Charge" then
		local Length = (Killer_Module.Timing_Settings.Wind_Up + 0)
		print('AIM START')

		Player.Character:SetAttribute("Animation", "")
		Length -= 0.1
		task.wait(0.1)

		_G.GetValue(Player.Name, "DisruptiveActions"):Add("Ability", 1, nil)
		code_module:SetEffect("Slow", Player, {-1, (Killer_Module.Speed_Settings.Charging * 100)}, 'Doctor_Charge') -->> apply slowness

		Player.Character:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length)
		Player.Character:SetAttribute("Animation", "Charge")
		Player.Character:SetAttribute("Power_State", "Animation")

		task.wait(Length - 0.1)

		playerValues.Action.Value = "Charging_Shock"
		playerValues.KillerAction.Value = "Charging_Shock"

		if playerValues.Action.Value == "Charging_Shock" then

			Player.Character:SetAttribute("Power_State", "Charging") -- knock us back to idle
			playerValues.Action.Value = "Holding_Shock"
			playerValues.KillerAction.Value = "Holding_Shock"
		else
			warn('bypassed')
		end

		print('AIM END')
	elseif Command == "Stop_Charge" then -- finish charge gonna do charge client-side due to camera/directional dash

		print('remove the slowness')

		_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")
		Player.Character:SetAttribute("Power_State", "Idle") -- knock us back to idle
		code_module:SetEffect("Slow", Player, nil, 'Doctor_Charge')

		playerValues.Action.Value = "Nothing"
		playerValues.KillerAction.Value = "Nothing"
	elseif Command == "Cancel_Charge" then
		print('CANCEL START')

		_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")
		Player.Character:SetAttribute("Power_State", "Idle") -- knock us back to idle
		code_module:SetEffect("Slow", Player, nil, 'Doctor_Charge') -->> remove slowness

		print('CANCEL END')
	else
		warn(Command, 'not supported!')
	end
end

return module
