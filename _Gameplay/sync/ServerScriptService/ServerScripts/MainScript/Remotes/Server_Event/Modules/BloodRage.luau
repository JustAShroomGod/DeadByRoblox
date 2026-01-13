local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local Badge_Manager = require(ServerStorage:WaitForChild("Modules"):WaitForChild("BadgeManager"))
local Events = require(game:GetService("ServerScriptService"):WaitForChild('Event System'):WaitForChild('Events'));

local Killer_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild('Psychopath'))

local Match_Started  = ReplicatedStorage.Match.Started
local Rage_Animation = script.Parent.Parent:WaitForChild("Animations"):WaitForChild("Psychopath_Walk")

local module = {
	Characters = {},
	Hooked = false
}

function GenerateData(Character : Model)
	if module.Characters[Character] then return end

	module.Characters[Character] = {} -- create character/tween data for this character

	module.Characters[Character].AnimationTrack = Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(Rage_Animation)
	module.Characters[Character].Face_Type = {
		Normal = Character:WaitForChild("Head"):FindFirstChild("Face_Normal");
		Rage = Character:WaitForChild("Head"):FindFirstChild("Face_Rage");
	}

end

function HookEvents()

	local Player = code_module:getKiller()

	if (Player == nil) then
		return
	end

	local Character = Player.Character

	module.BreakEvent = Events.Killer.onBreak.Event:Connect(function(Killer, Type)
		if Character:GetAttribute("Power_State") == "Idle" then

			if not (Character:FindFirstChild("Chainsaw") ~= nil) and not (Character:FindFirstChild("Reaper") ~= nil) then
			else
				return -- Hillbilly/Reaper call Psychopath code which causes issues so to prevent them from breaking we just check if the killer has the weapon model.
			end

			if (Type ~= "Pallet" and Type ~= "Wall") then
				return
			end

			local current_rage = string.split(Character:GetAttribute("Power"), ':')

			Character:SetAttribute("Power", math.clamp(tonumber(current_rage[1]) + Killer_Module.Rage_Gain.Break, 0, tonumber(current_rage[2]))..':'..current_rage[2])
		end
	end)

	module.AttackEvent = Events.Killer.onAttack.Event:Connect(function(State: string, Name)
		if Name and (game.Players:FindFirstChild(Name) ~= nil) then
			if not (Character:FindFirstChild("Chainsaw") ~= nil) and not (Character:FindFirstChild("Reaper") ~= nil) then
			else
				return
			end
			local Survivor = game.Players[Name]
			local Backpack = Survivor.Backpack
			if Backpack.Scripts.values.Hooked.Value == false then
				local AFrame = code_module:GetEffect("AFrame", Survivor)
				local IFrame = code_module:GetEffect("IFrame", Survivor)
				if (AFrame and AFrame.Active) or (IFrame and IFrame.Active) then
					return "IFrame Protection"
				end
				if Character:GetAttribute("Power_State") == "Idle" and State == "Hit" then
					local current_rage = string.split(Character:GetAttribute("Power"), ':')

					Character:SetAttribute("Power", math.clamp(tonumber(current_rage[1]) + Killer_Module.Rage_Gain.Attack, 0, tonumber(current_rage[2]))..':'..current_rage[2])
				end

				if (Character:GetAttribute("Power_State") == "Using" and State == "Hit") then
					local current_rage = string.split(Character:GetAttribute("Power"), ':')

					Player.Character:SetAttribute("Power",  math.clamp(tonumber(current_rage[1]) + Killer_Module.Rage_Loss.Hit, 150, tonumber(current_rage[2]))..':'..tonumber(current_rage[2]))
				end
			end
		end

	end)
end

function module:Fire(Player : Player, Arguments : "table")
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')
	local Command : boolean = Arguments[2]

	local BaseValues = {
		AttackRecovery = code_module:GetPlayerValue(Player, "WipeSpeed");
		PalletBreaking = code_module:GetPlayerValue(Player, "PalletBreakSpeed");
		WallBreaking = code_module:GetPlayerValue(Player, "WallBreakSpeed");
	}

--	print(Player, 'has attempted to use power of psychopath')

	if not module.Characters[Player.Character] then
		GenerateData(Player.Character)
	end

	if Command == "Start_Rage" then
		
		Player.Character:SetAttribute("Power_State", "Using")
		_G.GetValue(Player.Name, "WipeSpeed"):Add("BloodRage", (code_module:GetPlayerValue(Player, "WipeSpeed") * 0.3), nil)
		_G.GetValue(Player.Name, "PalletBreakSpeed"):Add("BloodRage", (code_module:GetPlayerValue(Player, "PalletBreakSpeed") * 0.3), nil)
		_G.GetValue(Player.Name, "WallBreakSpeed"):Add("BloodRage", (code_module:GetPlayerValue(Player, "PalletBreakSpeed") * 0.3), nil)

		data_module:GiveBlood(Player, 100, "Deviousness", "HOTFOOT")

		task.spawn(function()
			module.Characters[Player.Character].Face_Type.Normal.Transparency = 1
			module.Characters[Player.Character].Face_Type.Rage.Transparency = 0
		end)

		_G.GetValue(Player.Name, "DisruptiveActions"):Add("Ability", 1, nil)
		module.Characters[Player.Character].AnimationTrack:Play()
	elseif Command == "End_Rage" then
		playerValues.Action.Value = "BloodRage_Fatigue"
		playerValues.KillerAction.Value = "BloodRage_Fatigue"

		if not Arguments[3] then
			local Length = (Killer_Module.Timings.Fatigue + 0)

			Player.Character:SetAttribute("Animation", "")
			Length -= 0.1
			task.wait(0.1)

			Player.Character:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length)
			Player.Character:SetAttribute("Animation", "Fatigue")
			Player.Character:SetAttribute("Power_State", "Animation")

			task.wait(Length * 0.25)
			Length -= (Length * 0.25)

			task.wait(Length)
		end

		Player.Character:SetAttribute("Power_State", "Idle")

		_G.GetValue(Player.Name, "WipeSpeed"):Remove("BloodRage")
		_G.GetValue(Player.Name, "PalletBreakSpeed"):Remove("BloodRage")
		_G.GetValue(Player.Name, "WallBreakSpeed"):Remove("BloodRage")

		task.spawn(function()
			module.Characters[Player.Character].Face_Type.Normal.Transparency = 0
			module.Characters[Player.Character].Face_Type.Rage.Transparency = 1
		end)

		module.Characters[Player.Character].AnimationTrack:Stop()
		_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")

		playerValues.Action.Value = "Nothing"
		playerValues.KillerAction.Value = "Nothing"
	else
		warn(Command, 'not supported!')
	end
end

Match_Started.Changed:Connect(function(value)

	if (value == true and not module.Hooked) then
		module.Hooked = true
		HookEvents()
	end
end)

return module