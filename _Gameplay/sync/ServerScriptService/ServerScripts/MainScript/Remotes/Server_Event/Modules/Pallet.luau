local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')

local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local Events = require(ServerScripts:WaitForChild("Event System"):WaitForChild("Events"))

local module = {}

local Settings = {
	Base_Length = 3.6
}

local Animation_Stamps = { -- store pallet_kick events through time
	Pallet_Kick = {
		First = 0.31;
		Break = 0.68;
	},
}

function module:Fire(Player : Player, Arguments : "table")
	local Character = Player.Character
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')
	local SpiritFury = perkBase:WaitForChild("SpiritFury")

	local Command, Pallet : boolean = Arguments[2], Arguments[3]
	print(Player, Arguments)

	if not Pallet then return end
	local Pallet_Settings = Pallet:WaitForChild('Panel')
	local Port_Close : "Side/Prompt Block of Pallet we are closest to", Port_Far = nil, nil

	if (Pallet.FirstPort.Position - Character:GetPivot().Position).Magnitude > (Pallet.SecondPort.Position - Character:GetPivot().Position).Magnitude then
		Port_Close, Port_Far = Pallet.SecondPort, Pallet.FirstPort
	else
		Port_Close, Port_Far = Pallet.FirstPort, Pallet.SecondPort
	end

	-- Reset Animation --
	Pallet:SetAttribute("Animation", "")

	task.wait(0.1)

	if Command == "Killer_Kick" and Pallet and Pallet_Settings:WaitForChild('Vaulter').Value == "" then
		local Length = Settings.Base_Length / code_module:GetPlayerValue(Player, "PalletBreakSpeed")
		if (Character:GetAttribute("Cloaked") and Character:GetAttribute("Cloaked") == true) then
			Length = Length - (Settings.Base_Length * 0.05)
		end
		Length *= Player.Backpack.Scripts.PerksBase["Rigged Game"]:GetAttribute("Percentage")
		code_module:SetEffect("Motion_Locked", Player, true)

		Character.PrimaryPart.Anchored = true
		Character:PivotTo(Port_Close.CFrame * CFrame.new(0, Character:GetPivot().Position.Y - Port_Close.Position.Y, 0))

		playerValues:WaitForChild('KillerAction').Value = "BreakingPallet"
		playerValues:WaitForChild('Action').Value = "BreakingPallet"

		Pallet:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length)
		Pallet:SetAttribute("Animation", "Pallet_Kick")

		coroutine.resume(coroutine.create(function()
			repeat task.wait()
				code_module:SetEffect("Motion_Locked", Player, true)
				Character.PrimaryPart.Anchored = true
				Character:PivotTo(Port_Close.CFrame * CFrame.new(0, Character:GetPivot().Position.Y - Port_Close.Position.Y, 0))
			until playerValues.Action.Value == "Nothing"
		end))

		Pallet_Settings:WaitForChild('Vaulter').Value = "Blocked" -- prevent vaulting

		code_module:SetEffect("AFrame", Player, true) -- killer become stun immune

		task.wait(Length * Animation_Stamps.Pallet_Kick.First) -- wait till first event
		-- first event
		Pallet_Settings:WaitForChild('Collision'):WaitForChild('FirstKickSound'):Play()
		Pallet_Settings:WaitForChild('Collision'):WaitForChild('FirstKickBackground'):Play()
		task.wait((Length * Animation_Stamps.Pallet_Kick.Break) - (Length * Animation_Stamps.Pallet_Kick.First)) -- wait till second event
		-- second event
		Pallet_Settings:WaitForChild('State').Value = 2
		task.wait(Length - ((Length * Animation_Stamps.Pallet_Kick.Break) + (Length * Animation_Stamps.Pallet_Kick.First))) -- wait for the end now
		-- end of animation --

		playerValues:WaitForChild('KillerAction').Value = "Nothing"
		playerValues:WaitForChild('Action').Value = "Nothing"

		data_module:GiveBlood(Player, 500, "Brutality", "DESTRUCTION!")

		SpiritFury:WaitForChild("Pallets").Value += 1
		Events.Killer.onBreak:Fire(Player, "Pallet", Pallet)

		task.wait(0.04)

		code_module:SetEffect("Motion_Locked", Player, false)
		Character.PrimaryPart.Anchored = false
		code_module:SetEffect("AFrame", Player, false)
	end
end

return module
