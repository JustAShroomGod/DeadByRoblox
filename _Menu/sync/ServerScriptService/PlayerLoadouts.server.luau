local Data = require(game.ReplicatedStorage.Modules.Data)
local LoadoutsRemote = game.ReplicatedStorage.RemoteEvents.PlayerLoadouts

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local LoadoutStore = DataStoreService:GetDataStore("Player_Loadouts")

local Cache = {}

function PlayerJoined(Player: Player)
	coroutine.wrap(function()
		repeat task.wait()
		until Player:FindFirstChild("Data") ~= nil
		
		Cache[Player.Name] = {}
		
		local success, result = pcall(function()
			return LoadoutStore:GetAsync(`Player_{Player.UserId}`)
		end)
		
		if (not success) then
			Player:Kick("Couldn't Load Player Loadouts. Please try again!")
			return
		end
		
		if (result == nil) then
			result = {}
		end
		
		Cache[Player.Name] = result
	end)()
end

function PlayerLeft(Player: Player)
	
	if (Cache[Player.Name] == nil) then
		return
	end
	
	SaveLoadouts(Player)
end

function RemoteReceived(Player: Player, Command: string, ...)
	
	local args = {...}
	
	if (Command == "Request") then
		return Cache[Player.Name][GetCharacter(Player, args[1])] or {}
	end
	
	if (Command == "Save") then
		
		local data = table.clone(Data:GetRaw(Player))
		local character = GetCharacter(Player, args[1])
		local loadout = data[character].Loadout
		
		local newLoadout = {
			Offering = loadout.Offering;
			Perks = {
				Slot01 = loadout.Perks.Slot1;
				Slot02 = loadout.Perks.Slot2;
				Slot03 = loadout.Perks.Slot3;
				Slot04 = loadout.Perks.Slot4;
			}
		}
		
		if (args[1]) then
			newLoadout.Addons = {
				Slot01 = loadout.Addons.Slot1;
				Slot02 = loadout.Addons.Slot2;
			}
		else
			newLoadout.Item = {
				Class = loadout.Item.Class;
				Variant = loadout.Item.Name;
			}
			newLoadout.Addons = {
				Slot01 = loadout.Item.Addons.Slot1;
				Slot02 = loadout.Item.Addons.Slot2;
			}
		end
		
		SetLoadout(Player, character, args[2], newLoadout)
		return Cache[Player.Name][character] or {}
	end
	
	if (Command == "Delete") then
		SetLoadout(Player, GetCharacter(Player, args[1]), args[2], nil)
		return Cache[Player.Name][GetCharacter(Player, args[1])] or {}
	end
	
	if (Command == "Load") then
		
		if (args[1]) then
			LoadKillerLoadout(Player, args[2])
			return true
		else
			LoadSurvivorLoadout(Player, args[2])
			return true
		end
	end
	
end

function LoadKillerLoadout(Player: Player, LoadoutName: string)
	
	local character = GetCharacter(Player, true)
	local loadout = Cache[Player.Name][character][LoadoutName]
	
	Data:EquipOffering("Killer", loadout.Offering, Player, true)
	Data:EquipPerk("Killer", loadout.Perks.Slot01, 1, Player, true)
	Data:EquipPerk("Killer", loadout.Perks.Slot02, 2, Player, true)
	Data:EquipPerk("Killer", loadout.Perks.Slot03, 3, Player, true)
	Data:EquipPerk("Killer", loadout.Perks.Slot04, 4, Player, true)
	Data:EquipAddon("Killer", loadout.Addons.Slot01, 1, Player, true)
	Data:EquipAddon("Killer", loadout.Addons.Slot02, 2, Player, true)
	
end

function LoadSurvivorLoadout(Player: Player, LoadoutName: string)
	
	local character = "Main"
	local loadout = Cache[Player.Name][character][LoadoutName]

	local item_string = ""

	if (loadout.Item.Variant ~= nil and loadout.Item.Class ~= nil) then
		item_string = loadout.Item.Variant .. "_" .. loadout.Item.Class
	end

	Data:EquipOffering("Survivor", loadout.Offering, Player, true)
	Data:EquipPerk("Survivor", loadout.Perks.Slot01, 1, Player, true)
	Data:EquipPerk("Survivor", loadout.Perks.Slot02, 2, Player, true)
	Data:EquipPerk("Survivor", loadout.Perks.Slot03, 3, Player, true)
	Data:EquipPerk("Survivor", loadout.Perks.Slot04, 4, Player, true)

	Data:EquipItem(item_string, Player, true)

	if (loadout.Addons.Slot01 ~= nil and loadout.Addons.Slot01 ~= "") then
		Data:EquipAddon("Survivor", loadout.Addons.Slot01, 1, Player, true)
	end

	if (loadout.Addons.Slot02 ~= nil and loadout.Addons.Slot02 ~= "") then
		Data:EquipAddon("Survivor", loadout.Addons.Slot02, 2, Player, true)
	end
	
end

function SetLoadout(Player: Player, Character: string, LoadoutName: string, LoadoutData: table)
	
	if (Cache[Player.Name][Character] == nil) then
		Cache[Player.Name][Character] = {}
	end
	
	Cache[Player.Name][Character][LoadoutName] = LoadoutData
end

function SaveLoadouts(Player: Player)
	
	local success, _ = pcall(function()
		LoadoutStore:SetAsync(`Player_{Player.UserId}`, Cache[Player.Name])
	end)
	
	if (success) then
		print("Successfully saved loadouts from:", Player.Name)
	end
	
end

function GetCharacter(Player: Player, isKiller: boolean)
	
	local data = Data:GetRaw(Player)
	local isKiller = isKiller
	local character = if (isKiller) then string.lower(data.Main.Other.Killer) else "Main"
	
	return character
end

Players.PlayerAdded:Connect(PlayerJoined)
Players.PlayerRemoving:Connect(PlayerLeft)
LoadoutsRemote.OnServerInvoke = RemoteReceived