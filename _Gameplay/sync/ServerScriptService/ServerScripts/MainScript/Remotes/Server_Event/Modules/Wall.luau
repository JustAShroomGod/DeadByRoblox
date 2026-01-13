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

	local Command, Wall : boolean = Arguments[2], Arguments[3]
	print(Player, Arguments)

	if not Wall then return end
	local Wall_Settings = Wall:WaitForChild('Panel')
	local Port_Close : "Side/Prompt Block of Pallet we are closest to", Port_Far = nil, nil

	if (Wall.FirstPort.Position - Character:GetPivot().Position).Magnitude > (Wall.SecondPort.Position - Character:GetPivot().Position).Magnitude then
		Port_Close, Port_Far = Wall.SecondPort, Wall.FirstPort
	else
		Port_Close, Port_Far = Wall.FirstPort, Wall.SecondPort
	end

	-- Reset Animation --
	Wall:SetAttribute("Animation", "")

	task.wait(0.1)

	if Command == "Killer_Kick" and Wall then
		local Length = Settings.Base_Length / code_module:GetPlayerValue(Player, "WallBreakSpeed")
		Length *= Player.Backpack.Scripts.PerksBase["Rigged Game"]:GetAttribute("Percentage")
		code_module:SetEffect("Motion_Locked", Player, true)

		Character.PrimaryPart.Anchored = true
		Character:PivotTo(Port_Close.CFrame * CFrame.new(0, Character:GetPivot().Position.Y - Port_Close.Position.Y, 0))

		playerValues:WaitForChild('KillerAction').Value = "BreakingWall"
		playerValues:WaitForChild('Action').Value = "BreakingWall"

		Wall:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length)
		Wall:SetAttribute("Animation", "Pallet_Kick")

		code_module:SetEffect("AFrame", Player, true) -- killer become stun immune

		task.wait(Length * Animation_Stamps.Pallet_Kick.First) -- wait till first event
		-- first event
		Wall:WaitForChild('Collision'):WaitForChild('FirstKickSound'):Play()
		Wall:WaitForChild('Collision'):WaitForChild('FirstKickBackground'):Play()
		task.wait((Length * Animation_Stamps.Pallet_Kick.Break) - (Length * Animation_Stamps.Pallet_Kick.First)) -- wait till second event
		-- second event
		Wall_Settings:WaitForChild('Broken').Value = true
		task.wait(Length - ((Length * Animation_Stamps.Pallet_Kick.Break) + (Length * Animation_Stamps.Pallet_Kick.First))) -- wait for the end now
		-- end of animation --

		Character.PrimaryPart.Anchored = false
		code_module:SetEffect("AFrame", Player, false)

		playerValues:WaitForChild('KillerAction').Value = "Nothing"
		playerValues:WaitForChild('Action').Value = "Nothing"

		code_module:SetEffect("Motion_Locked", Player, false)

		data_module:GiveBlood(Player, 500, "Brutality", "DESTRUCTION!")
		Events.Killer.onBreak:Fire(Player, "Wall", Wall)
	end
end

return module