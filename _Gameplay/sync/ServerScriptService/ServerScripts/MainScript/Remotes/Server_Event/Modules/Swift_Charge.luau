local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local Badge_Manager = require(ServerStorage:WaitForChild("Modules"):WaitForChild("BadgeManager"))

local Killer_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild('Ninja'))

local module = {}


function module:Fire(Player : Player, Arguments : "table")
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')
	local Command : boolean = Arguments[2]

--	print(Player, 'has attempted to use power of ninja')

	if Command == "Start_Charge" then
		local Length = (Killer_Module.Timings.Aim + 0)
		Player.Character:SetAttribute("Animation", "")
		Length -= 0.1
		task.wait(0.1)

		_G.GetValue(Player.Name, "DisruptiveActions"):Add("Ability", 1, nil)
		code_module:SetEffect("Slow", Player, {-1, (Killer_Module.Speeds.Aim * 100)}, 'Ninja_Aim') -->> apply slowness

		Player.Character:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length)
		Player.Character:SetAttribute("Animation", "Wind_Up")
		Player.Character:SetAttribute("Power_State", "Animation")

		playerValues.Action.Value = "Start_Aiming"
		playerValues.KillerAction.Value = "Start_Aiming"

		local s = Player.Character.PrimaryPart:FindFirstChild("Sword Unsheath")

		if s then
			s:Remove()
		end

		s = script.Parent.Parent:WaitForChild('Sounds'):WaitForChild('Sword Unsheath'):Clone()
		s.Parent = Player.Character.PrimaryPart
		s:Play()

		task.wait(Length - 0.1)

		Player.Character:SetAttribute("Power_State", "Charging") -- knock us back to idle
		playerValues.Action.Value = "Aiming"
		playerValues.KillerAction.Value = "Aiming"

	elseif Command == "Finished_Charge" then -- finish charge gonna do charge client-side due to camera/directional dash

		code_module:SetEffect("Slow", Player, nil, 'Ninja_Aim') -->> remove slowness
		code_module:SetEffect("Slow", Player, {-1, (Killer_Module.Speeds.Slash * 100)}, 'Ninja_Aim') -->> apply slowness

		if not Arguments[3] then
			local Length = (Killer_Module.Timings.Slash + 0)

			Player.Character:SetAttribute("Animation", "")
			Length -= 0.1
			task.wait(0.1)

			Player.Character:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length)
			Player.Character:SetAttribute("Animation", "Finish")
			Player.Character:SetAttribute("Power_State", "Animation")

			task.wait(Length)
		else -- normal cd
			local Length = (Killer_Module.Timings.Wipe + 0)

			Player.Character:SetAttribute("Animation", "")
			Length -= 0.1
			task.wait(0.1)

			Player.Character:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length)
			Player.Character:SetAttribute("Animation", "Wipe")
			Player.Character:SetAttribute("Power_State", "Animation")

			task.wait(Length)
		end

--		print('remove the slowness')

		code_module:SetEffect("Slow", Player, nil, 'Ninja_Aim') -->> remove slowness

		_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")
		Player.Character:SetAttribute("Power_State", "Idle") -- knock us back to idle

		playerValues.Action.Value = "Nothing"
		playerValues.KillerAction.Value = "Nothing"
	elseif Command == "Stop_Charge" then
		--print('Stop Charge')

		code_module:SetEffect("Slow", Player, nil, 'Ninja_Aim') -->> remove slowness
		code_module:SetEffect("Slow", Player, {-1, 100}, 'Ninja_Aim') -->> apply full slowness

		_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")
		Player.Character:SetAttribute("Power_State", "Animation") -- knock us back to idle

		playerValues.Action.Value = "Dashing"
		playerValues.KillerAction.Value = "Dashing"

		-- Sound Design --
		local s = Player.Character.PrimaryPart:FindFirstChild("Sword Dash")

		if s then
			s:Remove()
		end

		s = script.Parent.Parent:WaitForChild('Sounds'):WaitForChild('Sword Dash'):Clone()
		s.Parent = Player.Character.PrimaryPart
		s:Play()

		s = Player.Character.PrimaryPart:FindFirstChild("Sword Swing")

		if s then
			s:Remove()
		end

		s = script.Parent.Parent:WaitForChild('Sounds'):WaitForChild('Sword Swing'):Clone()
		s.Parent = Player.Character.PrimaryPart
		s:Play()
	elseif Command == "Cancel_Charge" then
		--print('Cancel Charge')

		_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")
		Player.Character:SetAttribute("Power_State", "Idle") -- knock us back to idle
		code_module:SetEffect("Slow", Player, nil, 'Ninja_Aim') -->> remove slowness

		--playerValues.Action.Value = "Nothing"
		--playerValues.KillerAction.Value = "Nothing"
	elseif Command == "Hit_Object" then
		local current_rage = string.split(Player.Character:GetAttribute("Power"), ':')
		local object = Arguments[3]

		if game.Players:FindFirstChild(object.Name) then
			object = game.Players:WaitForChild(object.Name)
			local Survivor_Backpack = object:WaitForChild('Backpack'):WaitForChild('Scripts')
			local S_perkBase, S_playerValues = Survivor_Backpack:WaitForChild('PerksBase'), Survivor_Backpack:WaitForChild('values')

			if S_playerValues:WaitForChild('HealthState').Value > 0 then
				require(script.Parent:WaitForChild('HitPlayer')):Fire("Hit", Player, object, 'SwiftCharge')
			end
		end

		--print('Hit', object)
	elseif Command == "Switch_Stance" then
		local current_state = Player.Character:GetAttribute("Power_State")

		--print('code recieved')

		if current_state == "Idle" then
			code_module:SetEffect("Slow", Player, nil, 'Ninja_Crouch') -->> remove slowness
			code_module:SetEffect("Slow", Player, {-1, (Killer_Module.Speeds.Crouch * 100)}, 'Ninja_Crouch') -->> apply full slowness

			Player.Character:SetAttribute("Power_State", 'Hidden')

			code_module:SetEffect("Hidden", Player, -1, "Ninja_Stealth")

			playerValues.Action.Value = "Hiding"
			playerValues.KillerAction.Value = "Hiding"
		else -- switch back
			code_module:SetEffect("Hidden", Player, nil, "Ninja_Stealth")
			code_module:SetEffect("Slow", Player, nil, 'Ninja_Crouch') -->> remove slowness

			playerValues.KillerAction.Value = "Nothing"
			playerValues.Action.Value = "Nothing"
			Player.Character:SetAttribute("Power_State", 'Idle')
		end
	else
		warn(Command, 'not supported!')
	end
end

return module