local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local Badge_Manager = require(ServerStorage:WaitForChild("Modules"):WaitForChild("BadgeManager"))

local Killer_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild('Huntress'))
local Hit_Module = require(script:WaitForChild('Hit_Dection'))

local hatchet_model = ReplicatedStorage:WaitForChild('KillerStuff'):WaitForChild('Current_Throw')

local Addon_Modules = {
	Multi = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild('Multi-Shot'));
}

local module = {
	Ignore_List = {}
}

function deepCopy(original)
	local copy = {}

	for k, v in pairs(original) do

		if type(v) == "table" then
			v = deepCopy(v)
		end

		copy[k] = v
	end

	return copy
end

function Throw_Hatchet(Player, Power, Origin)
	--[[local Hatchet_Vector = ((Origin.Position - Origin.LookVector) - Origin.Position).Unit

	--warn(Hatchet_Vector * -Power * workspace.Gravity)

	local Test_Hatchet = hatchet_model:Clone()
	Test_Hatchet.Parent = workspace
	Test_Hatchet:WaitForChild('Root').CFrame = Origin -- * CFrame.Angles(0, math.rad(180), 0)
	Test_Hatchet:WaitForChild('Root'):ApplyImpulse(Hatchet_Vector * -Power * workspace.Gravity)

	local Player_List, Object_List = {Player.Character}, deepCopy(module.Ignore_List)
	table.insert(Object_List, Player.Character)

	local Hatchet_Step = nil
	Hatchet_Step = game:GetService('RunService').Heartbeat:Connect(function(step)
		local Hatchet_Root = Test_Hatchet:FindFirstChild('Root')

		if not Test_Hatchet or not Hatchet_Root or not Hatchet_Root.Parent or not Test_Hatchet.Parent then
			Hatchet_Step:Disconnect() Hatchet_Step = nil
			if Test_Hatchet then Test_Hatchet:Remove() end
		end

		local hitbox_offset, Hatchet_Velocity = Hatchet_Root.CFrame * CFrame.new(0, 0, -1.325), Hatchet_Root.AssemblyLinearVelocity

		--warn(Hatchet_Velocity.Magnitude)

		Hatchet_Root:WaitForChild('Current_Throw').C0 *= CFrame.Angles(0, math.rad((Hatchet_Velocity.Magnitude/10)), 0)

		local object_box, player_box = {
			Origin = hitbox_offset;
			Radius = Killer_Module.Hitbox_Settings.Object.Radius;
			Range = Killer_Module.Hitbox_Settings.Object.Range;
		}, {
			Origin = hitbox_offset;
			Radius = Killer_Module.Hitbox_Settings.Player.Radius;
			Range = Killer_Module.Hitbox_Settings.Player.Range;
		}

		local object_cast, player_cast = Hit_Module:Cast(Object_List, object_box), Hit_Module:Cast(Player_List, player_box)
		local got_hit = false

		--warn('Running', hitbox_offset)

		if player_cast then
			local typeofhit : "Player" | "Object" | nil, source : Instance = Hit_Module:Type(player_cast, player_box, false)

			if typeofhit == "Player" then
				got_hit = true
				game.ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Event'):Fire("Hit", Player, game.Players:GetPlayerFromCharacter(source), "Hatchet")
				print('HIT PLAYER:', source)
			elseif typeofhit == "Object" then
				--table.insert(Player_List, source) -- do not ignore, but do not count
			else
				table.insert(Player_List, source) -->> ignore object
				--	table.isfrozen(Player_List, module.Ignore_List) -->> ignore this object
			end
		end

		if object_cast and not got_hit then
			local typeofhit : "Player" | "Breakable" | "Object" | nil, source : Instance = Hit_Module:Type(object_cast, object_box, false)

			if typeofhit == "Player" then
				-- do nothing
			elseif typeofhit == "Object" then
				got_hit = true
				print('HIT OBJECT:', source)
			else
				table.insert(Object_List, source)
				table.insert(module.Ignore_List, source) -->> add to all future ignores
			end
		end

		if got_hit then
			Hatchet_Step:Disconnect() Hatchet_Step = nil
			Test_Hatchet:Remove()
		end
	end)]]
end

function module:Fire(Player : Player, Arguments : "table")
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')
	local Command : boolean = Arguments[2]
	local Hatchet_Count = Player.Character:GetAttribute("Hatchet_Count")

--	print(Player, 'has attempted to use power of huntress :', Command)

	if Command == "Start_Aim" and tonumber(Hatchet_Count) > 0 then
		local Length = (Killer_Module.Timing_Settings.Wind_Up + 0)

		--print('AIM START')

		_G.GetValue(Player.Name, "DisruptiveActions"):Add("Ability", 1, nil)
		Player.Character:SetAttribute("Animation", "")
		Length -= 0.1
		task.wait(0.1)

		code_module:SetEffect("Slow", Player, {-1, (Killer_Module.Speed_Settings.Aiming * 100)}, 'Huntress_Aim') -->> apply slowness

		Player.Character:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length)
		Player.Character:SetAttribute("Animation", "Aim")
		Player.Character:SetAttribute("Power_State", "Animation")

		Player.Character:WaitForChild('Hatchet'):SetAttribute('State', 'AIM')
		Player.Character:WaitForChild('Hatchet'):WaitForChild('Handle'):WaitForChild('AIM'):Play()

		playerValues.Action.Value = "Aiming_Hatchet"
		playerValues.KillerAction.Value = "Aiming_Hatchet"

		task.wait(Length - 0.1)

		if playerValues.Action.Value == "Aiming_Hatchet" then
			--Player.Character:WaitForChild('Hatchet'):WaitForChild('Handle'):WaitForChild('MAX'):Play()

			Player.Character:SetAttribute("Power_State", "Aiming") -- knock us back to idle
			playerValues.Action.Value = "Charging_Hatchet"
			playerValues.KillerAction.Value = "Charging_Hatchet"
		else
			--warn('bypassed')
		end

		--print('AIM END')
	elseif Command == "Stop_Aim" and tonumber(Hatchet_Count) > 0 then -- finish charge gonna do charge client-side due to camera/directional dash
		local IsThrowing = if Arguments[3] then false else true

		coroutine.resume(coroutine.create(function()
			_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")
		end))
		Player.Character:SetAttribute("Power_State", "Animation") -- knock us back to idle
		playerValues.Action.Value = "Throwing"
		playerValues.KillerAction.Value = "Throwing"

		coroutine.resume(coroutine.create(function()
			local Hatchet_Power = string.split(Player.Character:GetAttribute("Power"), ':')[1]
			Hatchet_Power = math.clamp(tonumber(Hatchet_Power), Killer_Module.Throw_Settings.Min_Throw_Force, math.clamp(tonumber(Hatchet_Power), Killer_Module.Throw_Settings.Min_Throw_Force, 100000)) * Killer_Module.Throw_Settings.Throw_Force_Per_Charge
		end))

		code_module:SetEffect("Slow", Player, nil, 'Huntress_Aim') -->> remove slowness

		if IsThrowing then
			local Length = (Killer_Module.Timing_Settings.Mouse_Debounce + 0)

			--		warn(Hatchet_Power)

			Player.Character:SetAttribute("Power_State", "Animation") -- knock us back to idle

			--	print('Throw Hatchet w/ power at:', Hatchet_Power)

			Player.Character:WaitForChild('Hatchet'):SetAttribute('State', 'IDLE')

			Player.Character:SetAttribute("Hatchet_Count", math.clamp(tonumber(Hatchet_Count) - 1, 0, 100))

		--[[	if data_module:GetAddon("Killer", Player, "Multi-Shot") then
				coroutine.wrap(Throw_Hatchet)(Player, Hatchet_Power, Arguments[4] * Killer_Module.Camera_Offset * CFrame.Angles(0, math.rad(Addon_Modules.Multi.Hatchet_Angle), 0))
				coroutine.wrap(Throw_Hatchet)(Player, Hatchet_Power, Arguments[4] * Killer_Module.Camera_Offset)
				coroutine.wrap(Throw_Hatchet)(Player, Hatchet_Power, Arguments[4] * Killer_Module.Camera_Offset * CFrame.Angles(0, math.rad(-Addon_Modules.Multi.Hatchet_Angle), 0))
			else
				coroutine.wrap(Throw_Hatchet)(Player, Hatchet_Power, Arguments[4] * Killer_Module.Camera_Offset)
			end]]

			--Throw_Hatchet(Player, Hatchet_Power, Arguments[4] * Killer_Module.Camera_Offset)

			task.wait(Length)
		else
			Player.Character:WaitForChild('Hatchet'):WaitForChild('Handle'):WaitForChild('CANCEL'):Play()
			warn('Do not throw, retreat')
			task.wait(Killer_Module.Timing_Settings.Wind_Down)

			Player.Character:WaitForChild('Hatchet'):SetAttribute('State', 'IDLE')

		end

--		print('remove the slowness')


		Player.Character:SetAttribute("Power_State", "Idle") -- knock us back to idle

		playerValues.Action.Value = "Nothing"
		playerValues.KillerAction.Value = "Nothing"
	elseif Command == "Cancel_Aim" then
		print('CANCEL START')

		_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")
		Player.Character:WaitForChild('Hatchet'):SetAttribute('State', 'IDLE')

		Player.Character:SetAttribute("Power_State", "Idle") -- knock us back to idle
		code_module:SetEffect("Slow", Player, nil, 'Huntress_Aim') -->> remove slowness

		if playerValues.KillerAction.Value == "Stun" then
		else
			playerValues.Action.Value = "Nothing"
			playerValues.KillerAction.Value = "Nothing"
		end

		print('CANCEL END')
	else
		warn(Command, 'not supported!')
	end
end

return module