local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')

local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)

local addon_module = require(script:WaitForChild('Addon'))

local wraith_module = require(script:WaitForChild('Visual'))
local initialized = false

function initialize()
	local Killer = code_module:getKiller()
	local Match = game.ReplicatedStorage.Match
	local Started = Match.Started.Value

	if not Killer or initialized or (not Started and Killer == nil) then
		return
	end

	initialized = true

	if data_module:GetAddon("Killer", Killer, "Serpent") then
		require(script:WaitForChild("Addons"):WaitForChild("Serpent")).initialize()
	end
end

initialize()

local module = {
	Settings = {
		Speeds = {
			Uncloak = 70; -- x1.6 speed from base correct
			Invisible = 50; -- x1.3 speed from base correct
			Transition = 90; -- x.26 speed from base speed
		},
	},
}

--

function UnCloak(Killer, Backpack, perkBase, playerValues)
	local Cloak_Speed, Transition_Speed, Dash_Speed =module.Settings.Speeds.Invisible, module.Settings.Speeds.Transition, module.Settings.Speeds.Uncloak
	local Addons_Data = data_module:GetAddons("Killer", Killer)
	local Connections = {}
	local Cancelled = false

	Connections.Cancel = playerValues.KillerAction.Changed:Connect(function()

		if playerValues.KillerAction.Value == "Cancel Bell" then
			Cancelled = true
		end
	end)

	-- apply speed addons here --

	for _,Addon in pairs(Addons_Data) do
		if addon_module[Addon] then
			--warn("ADDON;",Addon)
			if string.match(string.lower(addon_module[Addon].Type), "move_speed") then
				if string.match(string.lower(addon_module[Addon].Type), "cloak") then
					Cloak_Speed *= (1 + addon_module[Addon].Value/100)
				--[[elseif string.match(string.lower(addon_module[Addon].Type), "dash") then
					Dash_Speed *= addon_module[Addon].Value
				elseif string.match(string.lower(addon_module[Addon].Type), "transition") then
					Transition_Speed *= addon_module[Addon].Value]]
				end
			end
		end
	end

	--

	playerValues.KillerAction.Value = "Bell Use"

	local timestamp, timer = wraith_module:Uncloak(Killer.Character)

	code_module:SetEffect("Slow", Killer, {-1, Transition_Speed}, 'Wraith_Transition') -->> apply slowness

	--Killer.Character.Humanoid.WalkSpeed = Transition_Speed -- cloak transition speed

	repeat task.wait()
	until Cancelled or (workspace:GetServerTimeNow() - timestamp) > timer

	Connections.Cancel:Disconnect()
	code_module:SetEffect("Haste", Killer, nil, 'Wraith_Invisible') -->> remove cloak speed
	code_module:SetEffect("Slow", Killer, nil, 'Wraith_Transition') -->> remove slowness
	code_module:SetEffect("Hidden", Killer, nil, 'Wraith_Invisible')

	if not Cancelled then
		if not Killer.Character:GetAttribute("Cloak_Count") then
			Killer.Character:SetAttribute("Cloak_Count", 0)
		end

		Killer.Character:SetAttribute("Cloak_Count", Killer.Character:GetAttribute("Cloak_Count") + 1)
		Killer.Character:SetAttribute("Cloaked", false)

		code_module:SetEffect("Haste", Killer, {1.5, Dash_Speed}, 'Wraith_Dash') -->> apply haste/dash

		--code_module.Speeds:addMultiplier(Killer, "Uncloak_Dash", 1.6, 1.5)

		data_module:GiveBlood(game.Players:GetPlayerFromCharacter(Killer.Character), 20, "Deviousness", "UNCLOAKED")

		local Cloak_Stamp = Killer.Character:GetAttribute("Cloak_Count")
	else
		wraith_module:Cancel(Killer.Character)
		code_module:SetEffect("Haste", Killer, {-1, Cloak_Speed}, 'Wraith_Invisible') -->> reapply cloak speed
		code_module:SetEffect("Hidden", Killer, -1, 'Wraith_Invisible')
		--Killer.Character.Humanoid.WalkSpeed = Cloak_Speed -- normal speed again
	end

	playerValues.KillerAction.Value = "Nothing"
end

function ForceCloak(Killer, playerValues)
	local Cloak_Speed = module.Settings.Speeds.Invisible
	local Addons_Data = data_module:GetAddons("Killer", Killer)
	local Connections = {}
	local Cancelled = false

	wraith_module:Cloak(Killer.Character, true)


	if not Cancelled then
		Killer.Character:SetAttribute("Cloaked", true)
		data_module:GiveBlood(game.Players:GetPlayerFromCharacter(Killer.Character), 20, "Deviousness", "CLOAKED")

		code_module:SetEffect("Haste", Killer, {-1, Cloak_Speed}, 'Wraith_Invisible') -->> apply haste/dash
		code_module:SetEffect("Hidden", Killer, -1, 'Wraith_Invisible')

		wraith_module.Characters[Killer.Character.Name].Stunned = playerValues.Stunned.Changed:Connect(function()

			if playerValues.Stunned.Value then
				wraith_module:ForceUncloak(Killer.Character)
				code_module:SetEffect("Haste", Killer, nil, 'Wraith_Invisible')
				code_module:SetEffect("Hidden",Killer, nil, 'Wraith_Invisible')
				Killer.Character:SetAttribute("Cloaked", false)
			end
		end)

		wraith_module.Characters[Killer.Character.Name].Carrying = Killer.Character:GetAttributeChangedSignal("Carry"):Connect(function()

			if Killer.Character:GetAttribute("Carry") then
				wraith_module:ForceUncloak(Killer.Character)
				code_module:SetEffect("Haste", Killer, nil, 'Wraith_Invisible')
				code_module:SetEffect("Hidden",Killer, nil, 'Wraith_Invisible')
				Killer.Character:SetAttribute("Cloaked", false)
			end
		end)
	else
		wraith_module:Cancel(Killer.Character)
	end

	playerValues.KillerAction.Value = "Nothing"
end


function Cloak(Killer, Backpack, perkBase, playerValues)
	local Cloak_Speed = module.Settings.Speeds.Invisible
	local Addons_Data = data_module:GetAddons("Killer", Killer)
	local Connections = {}
	local Cancelled = false

	Connections.Cancel = playerValues.KillerAction.Changed:Connect(function()

		if playerValues.KillerAction.Value == "Cancel Bell" then
			Cancelled = true
		end
	end)

	Connections.Stun = playerValues.Stunned.Changed:Connect(function()

		if playerValues.Stunned.Value then
			Cancelled = true -- cancel the cloak
		end
	end)

	-- apply speed addons here --

	for _,Addon in pairs(Addons_Data) do
		if addon_module[Addon] then
			--warn("ADDON;",Addon)
			if string.match(string.lower(addon_module[Addon].Type), "movespeed") then

				if string.match(string.lower(addon_module[Addon].Type), "cloak") then
					Cloak_Speed *= (1 + addon_module[Addon].Value/100)
				--[[elseif string.match(string.lower(addon_module[Addon].Type), "dash") then
					Dash_Speed *= addon_module[Addon].Value
				elseif string.match(string.lower(addon_module[Addon].Type), "transition") then
					Transition_Speed *= addon_module[Addon].Value]]
				end
			end
		end
	end

	--

	playerValues.KillerAction.Value = "Bell Use"

	local timestamp, timer = wraith_module:Cloak(Killer.Character)

	repeat task.wait()
	until Cancelled or (workspace:GetServerTimeNow() - timestamp) > timer

	Connections.Cancel:Disconnect()
	Connections.Stun:Disconnect()

	if not Cancelled then
		Killer.Character:SetAttribute("Cloaked", true)
		data_module:GiveBlood(game.Players:GetPlayerFromCharacter(Killer.Character), 20, "Deviousness", "CLOAKED")

		code_module:SetEffect("Haste", Killer, {-1, Cloak_Speed}, 'Wraith_Invisible') -->> apply haste/dash
		code_module:SetEffect("Hidden", Killer, -1, 'Wraith_Invisible')

		wraith_module.Characters[Killer.Character.Name].Stunned = playerValues.Stunned.Changed:Connect(function()

			if playerValues.Stunned.Value then
				wraith_module:ForceUncloak(Killer.Character)
				code_module:SetEffect("Haste", Killer, nil, 'Wraith_Invisible')
				code_module:SetEffect("Hidden",Killer, nil, 'Wraith_Invisible')
				Killer.Character:SetAttribute("Cloaked", false)
			end
		end)

		wraith_module.Characters[Killer.Character.Name].Carrying = Killer.Character:GetAttributeChangedSignal("Carry"):Connect(function()

			if Killer.Character:GetAttribute("Carry") then
				wraith_module:ForceUncloak(Killer.Character)
				code_module:SetEffect("Haste", Killer, nil, 'Wraith_Invisible')
				code_module:SetEffect("Hidden",Killer, nil, 'Wraith_Invisible')
				Killer.Character:SetAttribute("Cloaked", false)
			end
		end)
	else
		wraith_module:Cancel(Killer.Character)
	end

	playerValues.KillerAction.Value = "Nothing"
end

--

function module:StartCloaked(Player)
	initialize(Player)

	ForceCloak(Player, Player:WaitForChild("Backpack"):WaitForChild("Scripts"):WaitForChild("values"))
end

function module:Fire(Player : Player, Arguments : "table")
	local Killer, Using = Player, Arguments[2]
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')

	initialize(Player)

	if Using then
		playerValues.KillerAction.Value = "Bell Use"

		if Killer.Character:GetAttribute("Cloaked") then
			UnCloak(Killer, Backpack, perkBase, playerValues)
		else
			Cloak(Killer, Backpack, perkBase, playerValues)
		end
	elseif playerValues.KillerAction.Value == "Bell Use" then -- released m2 / while still cloaking
		playerValues.KillerAction.Value = "Cancel Bell"
	end
end

return module