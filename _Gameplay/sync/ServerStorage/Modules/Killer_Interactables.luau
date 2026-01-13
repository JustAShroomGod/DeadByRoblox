local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Game_Data = ReplicatedStorage:WaitForChild("Game_Data")

local Perk_Data = Game_Data:WaitForChild('Perks'):WaitForChild('Killer')
local Addon_Data = Game_Data:WaitForChild("Addons"):WaitForChild("Killer")

local bearTrapModel = ReplicatedStorage:WaitForChild('KillerStuff'):WaitForChild("Trap")
local bearTrapsPlaces = ReplicatedStorage:WaitForChild('Game_Spawns')

local TrapperSettings = {
	Default = 8; -- amount he can store by basekit
	Starting = 8; -- amount he starts with

	MaxTraps = 8; -- traps in the map

	Addons = {
		TrapperBag = require(Addon_Data:WaitForChild("TrapperBag")).Trap_Boost; -- how much it effects backpack storage
		TrapperSack = require(Addon_Data:WaitForChild("TrapperSack")).Trap_Boost; -- how much it effects backpack storage
	}
}

local skipped, total = 0, 0
local data_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local code_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Interaction = {}

Interaction.__index = Interaction

function Interaction:SetValues(Killer : Player, Character : string) : "Attach Values"
	
	if Game_Data:WaitForChild('Killers'):FindFirstChild(Character) then
		local Killer_Module = require(Game_Data:WaitForChild('Killers'):WaitForChild(Character))
		
		if Killer_Module.Power then
			Killer_Module:Power(Killer)
		end
	end
end

function Interaction:SetTraps(Killer : Player) : "Sets up bear traps"
	bearTrapsPlaces = if bearTrapsPlaces:WaitForChild("TrapSpawns", 5) then bearTrapsPlaces.TrapSpawns else nil

	if not bearTrapsPlaces then return error("Traps could not spawn in map") end

	total = #bearTrapsPlaces:GetChildren()

	local AmountOfTraps = TrapperSettings.Default

	local Addons_Data = data_module:GetAddons("Killer", Killer)

	for _,Addon in pairs(Addons_Data) do
		if TrapperSettings.Addons[Addon] then
			AmountOfTraps += TrapperSettings.Addons[Addon]
			TrapperSettings.Default += TrapperSettings.Addons[Addon]
			TrapperSettings.Starting += TrapperSettings.Addons[Addon]
		end
	end

	Killer.Character:SetAttribute("Traps", TrapperSettings.Starting..':'..AmountOfTraps)
	
	local Trap = bearTrapModel:Clone()
	Trap:PivotTo(CFrame.new(Vector3.zero) * CFrame.new(0,-1,0))
	Trap.Name = Trap.Name
	Trap.Parent = workspace
end

function Interaction:SetPerks(player : Player) : "Sets up start perks"
	local hasLoot, LootTier = data_module:GetPerk("Loot Goblin", player)

	if hasLoot then
		workspace:SetAttribute("Loot_Goblin", LootTier)
	end
end

function Interaction:SetHexes(player : Player) : "Sets up hexes"
	local Perk_Loadout : Folder = player:WaitForChild('Data'):WaitForChild('Perks'):WaitForChild('Killer')

	local Totems = {}
	local Curses = {}

	---- Requirements
	for _, perk : StringValue in pairs(Perk_Loadout:GetChildren()) do
		
		if string.match(string.lower(perk.Name), 'hex') or string.match(string.lower(perk.Name), 'curse') then

			if string.match(string.lower(perk.Name), 'hex:') then
				Curses[string.gsub(perk.Name, 'Hex: ', "")] = perk.Value
			elseif string.match(string.lower(perk.Name), 'curse:') then
				Curses[string.gsub(perk.Name, 'Curse: ', "")] = perk.Value
			else
				warn(perk.Name, 'is a incorrectly named hex/curse')
			end
		end
	end

	for _, Totem : Model in pairs(workspace:GetChildren()) do
		if not Totem:IsA('Model') or not Totem:GetAttribute("IsInteractable") then continue end

		if string.match(string.lower(Totem.Name),'totem') and Totem:FindFirstChild('Panel') then
			table.insert(Totems, Totem)
		end
	end
	----

	for curse, curse_Tier in pairs(Curses) do

		if curse == 'No One Escapes Death' then
			local Generators_Repaired, Activated = workspace:WaitForChild('MatchValues'):WaitForChild('GeneratorsRepaired'), false
			
			Generators_Repaired.Changed:Connect(function() -- make it a function so it's not constantly checking and updates every time gen update

				if Generators_Repaired.Value >= 5 and not Activated then
					Activated = true

					local ValidTotem, totem = false, nil

					repeat task.wait()
						totem = Totems[math.random(1, #Totems)]

						if totem.Panel.Effect.Value == 'Dull' and totem.Panel.State.Value == 0 then
							ValidTotem = true
						else
							table.remove(Totems, table.find(Totems, totem))
						end
					until #Totems <= 0 or ValidTotem

					if ValidTotem then
						totem.Panel.Effect.Value = tostring(curse)
						totem.Panel.Effect.Tier.Value = curse_Tier
						table.remove(Totems, table.find(Totems, totem))
					end
				end
			end)
		elseif #Totems > 1 then
			local totem = Totems[math.random(1, #Totems)]

			totem.Panel.Effect.Value = tostring(curse)
			totem.Panel.Effect.Tier.Value = curse_Tier
			table.remove(Totems, table.find(Totems, totem))
		else
			warn('No Totems!')
			break
		end
	end
end

return Interaction

