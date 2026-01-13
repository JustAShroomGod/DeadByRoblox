local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')

local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local stalker_module = require(script:WaitForChild('Stalker'))

local module = {
	Settings = {},
	Saved = {}
}

-- Killer Functions

function Stalk(Killer : Player, Backpack, perkBase, playerValues) : "Start Stalk"
	local Connections = {}
	local Cancelled = false

	Connections.Cancel = playerValues.KillerAction.Changed:Connect(function()

		if playerValues.KillerAction.Value == "Cancel Stalk" then
			Cancelled = true
		end
	end)

	Connections.Stun = playerValues.Stunned.Changed:Connect(function()

		if playerValues.Stunned.Value then
			Cancelled = true
		end
	end)

	playerValues.KillerAction.Value = "Stalking"

	stalker_module:Stalk(Killer.Character)

	repeat task.wait()
	until Cancelled

	Connections.Cancel:Disconnect()
	Connections.Stun:Disconnect()

	if Cancelled then
		stalker_module:Stop(Killer.Character)
	end

	playerValues.KillerAction.Value = "Nothing"
	Killer.Character.Humanoid.WalkSpeed = code_module:GetSpeed("Movement", Killer) -- set our speed properly according to lust/tier
end

--

function module:Fire(Player : Player, Arguments : "table")
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')

	if Arguments[1] == "Stalk" and Player.Character:GetAttribute("Power_State") then
		local tier = Player.Character:GetAttribute("Power_Tier")
		local progress = string.split(Player.Character:GetAttribute("Power_Progress"), ':')

		if Arguments[2] and tonumber(progress[1]) < tonumber(progress[2]) and tier < 3 then -- neeeds progress and trying to gain
			Stalk(Player, Backpack, perkBase, playerValues)
			_G.GetValue(Player.Name, "DisruptiveActions"):Add("Ability", 1, nil)
		elseif playerValues.KillerAction.Value == "Stalking" then
			playerValues.KillerAction.Value = "Cancel Stalk"
			_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")
		end
	end
end

return module
