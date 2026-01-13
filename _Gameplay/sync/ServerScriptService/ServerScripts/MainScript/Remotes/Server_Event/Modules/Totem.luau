local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local ServerStorage = game:GetService("ServerStorage")

local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local BadgeManager = require(ServerStorage:WaitForChild("Modules"):WaitForChild("BadgeManager")) 
local Events = require(ServerScripts:WaitForChild("Event System"):WaitForChild("Events"))

local module = {}

function module:Fire(Player : Player, Arguments : "table")
	local Character = Player.Character
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')

	local Command, Totem = Arguments[2], Arguments[3]
	--print(Player, Arguments)
	
	if not Totem then return end
	local Totem_Settings = Totem:WaitForChild('Panel')

	-- Reset Animation --
	
	if Command == "Bless" then
		
		for i, v in pairs(workspace:GetChildren()) do
			if (string.find(v.Name, "Totem")) then
				local Totem_Effect = v.Panel.Effect
				local Totem_Holder = Totem_Effect.Holder
				
				if (Totem_Holder.Value == Player.Name) then
					Totem_Effect.Value = "Dull"
					Totem_Holder.Value = ""
				end
			end
		end
		
		Totem_Settings:WaitForChild('Effect').Value = "Blessing"
		Totem_Settings:WaitForChild('Effect'):WaitForChild("Holder").Value = Player.Name -- it's now blessed
		
		Events.Survivor.onTotemBlessed:Fire(Player, Totem)
		
	elseif Command == "Crush" then -- killer getting rid of totem
		--Totem_Settings:WaitForChild('Player').Value = Player.Name

		task.wait(0.5)
		--print('Remove Totem')
		
		if Totem_Settings:WaitForChild("TimesCrushed").Value >= 1 then
			Totem_Settings:WaitForChild('State').Value = 1
		else
			Totem_Settings:WaitForChild("TimesCrushed").Value += 1
		end

		Totem_Settings:WaitForChild('Effect').Value = 'Dull' -- it's now unblessed
		Totem_Settings:WaitForChild('Effect'):WaitForChild("Holder").Value = ""
		
		Events.Killer.onTotemCrushed:Fire(Player, Totem)
		--Totem_Settings:WaitForChild('Player').Value = ""
	elseif Command == "CraftShard" then
		
	end
end

return module
