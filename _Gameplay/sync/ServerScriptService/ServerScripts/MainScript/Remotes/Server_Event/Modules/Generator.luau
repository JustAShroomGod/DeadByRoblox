local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local ServerStorage = game:GetService("ServerStorage")

local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local Events = require(ServerScripts:WaitForChild("Event System"):WaitForChild("Events"))
local BadgeManager = require(ServerStorage:WaitForChild("Modules"):WaitForChild("BadgeManager")) 

local module = {}

local Settings = {
	Base_Length = 1.8;
}

local Animation_Stamps = { -- store pallet_kick events through time
	Gen_Kick = {
		First = 0.522;
		Break = 0.78;
	},
}

function GetSabotaged(Player)
	local generator = nil

	for _, model in pairs(workspace:GetChildren()) do
		if not model:IsA('Model') or not model:GetAttribute("IsInteractable") then continue end

		if string.match(model.Name:lower(), 'generator') and model:GetAttribute("Sabotaged") == Player.Name then
			generator = model
			break
		end
	end

	return generator
end

function module:Fire(Player : Player, Arguments : "table")
	local Character = Player.Character
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')

	local Command, Generator, Port = Arguments[2], Arguments[3], Arguments[4]
	print(Player, Arguments)

	if not Generator then return end
	local Generator_Settings = Generator:WaitForChild('Panel')

	-- Reset Animation --
	Generator:SetAttribute("Animation", "")

	task.wait(0.1)

	if Command == "Killer_Kick" and Generator then
		local HasSabotage, SabotageTier = data_module:GetPerk("Sabotage", Player)

		local Length = Settings.Base_Length / code_module:GetPlayerValue(Player, "GeneratorBreakSpeed")
		if (Character:GetAttribute("Cloaked") and Character:GetAttribute("Cloaked") == true) then
			Length = Length - (Settings.Base_Length * 0.05)
		end
		Length *= Player.Backpack.Scripts.PerksBase["Rigged Game"]:GetAttribute("Percentage")
		code_module:SetEffect("Motion_Locked", Player, true)

		Character.PrimaryPart.Anchored = true
		Character:PivotTo(CFrame.new(Port.Position)
			* CFrame.Angles(0, math.rad(Port.Orientation.Y), 0)
			* CFrame.new(0, 0, 0.5)
		)

		Port:WaitForChild('Ocuped').Value = true
		Port:WaitForChild('Ocupant').Value = Player.Name

		playerValues:WaitForChild('KillerAction').Value = "KickingGenerator"
		playerValues:WaitForChild('Action').Value = "KickingGenerator"

		Generator:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length)
		Generator:SetAttribute("Animation", "Generator_Kick")

		code_module:SetEffect("AFrame", Player, true) -- killer become stun immune

		task.wait(Length * Animation_Stamps.Gen_Kick.First) -- wait till first event
		-- first event
		Generator:WaitForChild('RootPart'):WaitForChild('FirstKickSound'):Play()
		task.wait((Length * Animation_Stamps.Gen_Kick.Break) - (Length * Animation_Stamps.Gen_Kick.First)) -- wait till second event
		-- break event

		Generator_Settings:WaitForChild('Broke').Value = true
		Generator:WaitForChild('RootPart'):WaitForChild('SecondKickSound'):Play()
		data_module:GiveBlood(Player, 500, "Brutality", "DAMAGED GENERATOR!")
		task.wait(Length - ((Length * Animation_Stamps.Gen_Kick.Break) + (Length * Animation_Stamps.Gen_Kick.First))) -- wait for the end now
		-- end of animation --

		Character.PrimaryPart.Anchored = false
		code_module:SetEffect("AFrame", Player, false)

		playerValues:WaitForChild('KillerAction').Value = "Nothing"
		playerValues:WaitForChild('Action').Value = "Nothing"

		Port:WaitForChild('Ocuped').Value = false
		Port:WaitForChild('Ocupant').Value = "Nobody"

		code_module:SetEffect("Motion_Locked", Player, false)
		BadgeManager.Award("Run It Back",Player.UserId)
		Events.Killer.onBreak:Fire(Player, "Generator", Generator)

		-- APPLY PERKS --
		if HasSabotage then
			local Last_Sabo, Current_CD = GetSabotaged(Player), Player.Character:GetAttribute("Sabotage_Cooldown")

			if not Current_CD or (Current_CD - workspace:GetServerTimeNow()) <= 0 then

				if Last_Sabo and Last_Sabo ~= Generator then -->> differnt gen
					Last_Sabo:SetAttribute("Sabotaged", nil)
					Generator:SetAttribute("Sabotaged", Player.Name)
				elseif not Last_Sabo then -->> no sabo gen
					Generator:SetAttribute("Sabotaged", Player.Name)
				end
			end
		end
	end
end

return module