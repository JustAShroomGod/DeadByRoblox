local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Game_Data = ReplicatedStorage:WaitForChild('Game_Data')
local data_module = require(script.Parent)
local Permission_module = require(script.Parent:WaitForChild('Permissions'))

--do not ask me anything.
local Fixer = {
	["Brown Battery"] = "Battery";
	["Yellow Battery"] = "Heavy Duty Battery";
	["Yellow Batter "] = "Heavy Duty Battery";
	["Green Battery"] = "Long Life Battery"
}


local Store = {
	Row_Settings = { -- DO NOT CHANGE --
		Row_Slots = {
			Row1 = 5;
			Row2 = 5;
			Row3 = 4;
			Row4 = 3;
			Row5 = 3;
		},
		Row_Purchase_Amount = 2;
		Boost_Per_Row = 20;
	},
	Catagory_Rarities = {
		Addons = 500; -- out of 1000
		Offerings = 250; -- offerings/ out of 1000
		Items = 1000; -- out of 1000
	},
	Store_Options = {}
}

--
function GetDictAmount(Dictionary : "table") : number
	local Amount = 0
	
	for _, v in pairs(Dictionary) do
		Amount += 1
	end
	
	return Amount
end

--

function Store:GetListings(Player : Player) : "Return Options for this player"
	if Store.Store_Options[Player.Name] then return Store.Store_Options[Player.Name] end
	Store.Store_Options[Player.Name] = {}

	-- create survivor listings --
	Store.Store_Options[Player.Name]['Survivor'] = {}

	-- Item --
	Store.Store_Options[Player.Name].Survivor.Items = {}
	
	for _, item_module in pairs(Game_Data:WaitForChild('Items'):GetChildren()) do
		if not item_module:IsA('ModuleScript') then continue end
		item_module = require(item_module)

		if not item_module.Active then continue end -- inactive item
		if not item_module.Cost or not item_module.Shop_Chance or item_module.Cost <= 0 or item_module.Shop_Chance <= 0 then continue end -- not for sale or no values to determine
		if item_module.Testing and not Permission_module:GetPerms(Player, "Testing") then continue end -- Testers only
		
		table.insert(Store.Store_Options[Player.Name].Survivor.Items, {
			item_module.Data_Name, item_module.Shop_Chance
		})
	end
	
	-- Perk --
	Store.Store_Options[Player.Name].Survivor.Perks = {}

	for _, perk_module in pairs(Game_Data:WaitForChild('Perks'):WaitForChild('Survivor'):GetChildren()) do
		if not perk_module:IsA('ModuleScript') then continue end
		perk_module = require(perk_module)

		if not perk_module.Active then continue end -- inactive item
		if perk_module.Testing and not Permission_module:GetPerms(Player, "Testing") then continue end -- Testers only
		-- ignore unlock value we will remove that later --
		
		table.insert(Store.Store_Options[Player.Name].Survivor.Perks, perk_module.Data_Name)
	end
	
	-- Offering --
	Store.Store_Options[Player.Name].Survivor.Offerings = {}

	for _, offering_module in pairs(Game_Data:WaitForChild('Offerings'):WaitForChild('Survivor'):GetChildren()) do
		if not offering_module:IsA('ModuleScript') then continue end
		offering_module = require(offering_module)

		if not offering_module.Active then continue end -- inactive item
		if not offering_module.Cost or not offering_module.Shop_Chance or offering_module.Cost <= 0 or offering_module.Shop_Chance <= 0 then continue end -- not for sale or no values to determine
		if offering_module.Testing and not Permission_module:GetPerms(Player, "Testing") then continue end -- Testers only

		table.insert(Store.Store_Options[Player.Name].Survivor.Offerings, {
			offering_module.Data_Name, offering_module.Shop_Chance
		})
	end
	
	-- TODO: Add Addons --
	Store.Store_Options[Player.Name].Survivor.Addons = {}

	for _, addon_module in pairs(Game_Data:WaitForChild('Addons'):WaitForChild('Survivor'):GetChildren()) do
		if Fixer[addon_module.Name] then
			addon_module = Fixer[addon_module.Name]
		end
		
		if not addon_module:IsA('ModuleScript') then continue end
		addon_module = require(addon_module)

		if not addon_module.Active then continue end -- inactive item
		if not addon_module.Cost or not addon_module.Shop_Chance or addon_module.Cost <= 0 or addon_module.Shop_Chance <= 0 then continue end -- not for sale or no values to determine
		if addon_module.Testing and not Permission_module:GetPerms(Player, "Testing") then continue end -- Testers only

		table.insert(Store.Store_Options[Player.Name].Survivor.Addons, {
			addon_module.Data_Name, addon_module.Shop_Chance
		})
	end
	
	-- create killer listings --
	
	-- create perk repo --
	local Killer_Perk_Repository = {}

	for _, perk_module in pairs(Game_Data:WaitForChild('Perks'):WaitForChild('Killer'):GetChildren()) do
		if not perk_module:IsA('ModuleScript') then continue end
		perk_module = require(perk_module)

		if not perk_module.Active then continue end -- inactive perk
		if perk_module.Testing and not Permission_module:GetPerms(Player, "Testing") then continue end -- Testers only
		-- ignore unlock value we will remove that later --

		table.insert(Killer_Perk_Repository, perk_module.Data_Name)
	end
	
	for killer, _ in pairs(data_module:GetRaw(Player)) do
		if killer == "Main" then continue end -- skip over this entry
		Store.Store_Options[Player.Name][killer] = {}
		
		Store.Store_Options[Player.Name][killer].Perks = Killer_Perk_Repository
		Store.Store_Options[Player.Name][killer].Addons = {}
		Store.Store_Options[Player.Name][killer].Offerings = {}
		
		local killer_module = Game_Data:WaitForChild('Killers'):FindFirstChild(killer:gsub("^%l", string.upper))
		
		if killer_module then
			killer_module = require(killer_module)
			
			for _, addon_module in pairs(killer_module.Addons) do
				if not addon_module.Active then continue end -- inactive addon
				if addon_module.Testing and not Permission_module:GetPerms(Player, "Testing") then continue end -- Testers only
				
				table.insert(Store.Store_Options[Player.Name][killer].Addons, {
					addon_module.Data_Name, addon_module.Shop_Chance
				})
			end

			for _, offering_module in pairs(killer_module.Offerings) do
				if not offering_module.Active then continue end -- inactive addon
				if offering_module.Testing and not Permission_module:GetPerms(Player, "Testing") then continue end -- Testers only

				table.insert(Store.Store_Options[Player.Name][killer].Offerings, {
					offering_module.Data_Name, offering_module.Shop_Chance
				})
			end
		else
			warn(killer, 'does not have module support in Game_Data')
		end
	end
	
	return Store.Store_Options[Player.Name]
end

function Store:Generate(Player : Player, Type : "Survivor" | "Killer") : "Return a new Store for Survivor"
	local Item_Listing, Addon_Listing, Perk_Listing, Offering_Listing = Store.Store_Options[Player.Name], Store.Store_Options[Player.Name], Store.Store_Options[Player.Name], Store.Store_Options[Player.Name]
	local Gamepass_Store, GamePasses = require(script.Parent):GetStore(Player), {}
	local Current_Shop = {
		Data = {};
		Row = 1;
	}
	
	-- Keep only ids that are verified as purchased
	GamePasses.Purchased = {}
	GamePasses.Unpurchased = {}
	
	for _, dlc_info in pairs(Gamepass_Store.DLC) do
		
		if dlc_info.Purchased then
			table.insert(GamePasses.Purchased, dlc_info.GamepassID)
		else
			table.insert(GamePasses.Unpurchased, dlc_info.GamepassID)
		end
	end
	
	--
	
	if Type == "Killer" then
		Item_Listing, Addon_Listing, Perk_Listing, Offering_Listing = Item_Listing[data_module:GetKiller(Player)].Items, Addon_Listing[data_module:GetKiller(Player)].Addons, Perk_Listing[data_module:GetKiller(Player)].Perks, Offering_Listing[data_module:GetKiller(Player)].Offerings
	else
		Item_Listing, Addon_Listing, Perk_Listing, Offering_Listing = Item_Listing[Type].Items, Addon_Listing[Type].Addons, Perk_Listing[Type].Perks, Offering_Listing[Type].Offerings
	end
	
	if Item_Listing then
			
		table.sort(Item_Listing, function(item_1, item_2) -- makes item listing go from lower-rarity to higher-rarity
			return (item_1[2]) < (item_2[2]) -- if item2 has a higher rarity then item1
		end)
	end
	
	if Addon_Listing then

		table.sort(Addon_Listing, function(addon_1, addon_2) -- makes addon listing go from lower-rarity to higher-rarity
			return (addon_1[2]) < (addon_2[2]) -- if addon_2 has a higher rarity then item1
		end)
	end
	
	if Offering_Listing then
		
		table.sort(Offering_Listing, function(offering_1, offering_2)
			return (offering_1[2] < offering_2[2])
		end)
	end
	
	if not Perk_Listing then
		Perk_Listing = {}
	end
	
	-- Remove Perks that we already have or do not have purchased --
	local Player_Inventory = data_module:GetInventory(Type, Player)
	local New_Perk_Repository = {}
	local Perk_For_Shop = {}
	
	local function RetrievePass(Perk_Module : ModuleScript) : boolean

		if Permission_module:GetPerms(Player, "Content") -- developer or someone we give free stuff to
			or require(script.Parent:WaitForChild('Store_Registry')):HasPass(Player, Perk_Module, GamePasses) then -- actually has/owns gamepass
			return true
		end
		
		return false
	end
	
	for _, Perk_Name : string in pairs(Perk_Listing) do
		
		if Player_Inventory.Perks[Perk_Name] and Player_Inventory.Perks[Perk_Name] >= 0 and Player_Inventory.Perks[Perk_Name] <= 2 then -- Can be upgraded/unlocked --
			local perk_module = require(Game_Data:WaitForChild('Perks'):WaitForChild(Type):WaitForChild(Perk_Name))
			
			if perk_module.Unlocked then -- Perk is Free or We have the Gamepass --
				table.insert(New_Perk_Repository, Perk_Name)
				table.insert(Perk_For_Shop, Perk_Name)
			else
				
				if RetrievePass(perk_module) then
					table.insert(New_Perk_Repository, Perk_Name)
					table.insert(Perk_For_Shop, Perk_Name)
				end
			end
		end
	end
	
	if Type == "Killer" then
		Store.Store_Options[Player.Name][data_module:GetKiller(Player)].Perks = New_Perk_Repository
	else
		Store.Store_Options[Player.Name]['Survivor'].Perks = New_Perk_Repository
	end
	
	-- Create Functions to Randomize --
	local function GiveItem(ODDS_INCREASE : number) : "Give item w/ Odds boost per row"
		if not Item_Listing or #Item_Listing <= 0 then return error("Not enough items to generate a table") end
		local NAT = math.random(1, 1000)
		
		for index, item in pairs(Item_Listing) do
			
			if NAT <= (item[2] + ODDS_INCREASE) then
				return item[1]
			elseif index >= #Item_Listing then
				return item[1]
			end
		end
		
		return error("Grabbed no item!")
	end
	
	local function GiveAddon(ODDS_INCREASE : number) : "Give Addon w/ Odds boost per row"
		if not Addon_Listing or #Addon_Listing <= 0 then return error("Not enough addons to generate a table for killer : "..data_module:GetKiller(Player)) end
		local NAT = math.random(1, 1000)
		
		for index, addon in pairs(Addon_Listing) do

			if NAT <= (addon[2] + ODDS_INCREASE) then
				return addon[1]
			elseif index >= #Addon_Listing then
				return addon[1]
			end
		end

		return error("Grabbed no addon!")
	end
	
	local function GiveOffering(ODDS_INCREASE : number) : "Give Offering w/ Odds boost per row"
		if not Offering_Listing or #Offering_Listing <= 0 then return error("Not enough addons to generate a table for killer : "..data_module:GetKiller(Player)) end
		local NAT = math.random(1, 1000)

		for index, addon in pairs(Offering_Listing) do

			if NAT <= (addon[2] + ODDS_INCREASE) then
				return addon[1]
			elseif index >= #Offering_Listing then
				return addon[1]
			end
		end

		return error("Grabbed no offering!")
	end
	
	local function AssignRandom(ROW : number) : "Gives Addon or Item"
		local Generic_Slot = {
			Catagory = "Missing";
			Name = "Missing";
			Purchased = false;
		}

		local NAT = math.random(1, 1000)
		
		for catagory, rarity in pairs(Store.Catagory_Rarities) do
			
			if NAT <= rarity and (not Store.Catagory_Rarities[Generic_Slot.Catagory] or (Store.Catagory_Rarities[Generic_Slot.Catagory] and Store.Catagory_Rarities[Generic_Slot.Catagory] > rarity)) then
				Generic_Slot.Catagory = catagory
			end
		end

		if Generic_Slot.Catagory == "Offerings" and #Offering_Listing <= 0 then
			print('Changing Catagory Offering:', Generic_Slot)
			Generic_Slot.Catagory = "Items" -- no offerings fix it
		end
		
		if Type == 'Killer' and Generic_Slot.Catagory == 'Items' then
			Generic_Slot.Catagory = 'Addons' -- over-ride for killer
		end
		
		if Generic_Slot.Catagory == "Items" then
			Generic_Slot.Name = GiveItem(ROW * Store.Row_Settings.Boost_Per_Row)
		elseif Generic_Slot.Catagory == "Addons" then
			Generic_Slot.Name = GiveAddon(ROW * Store.Row_Settings.Boost_Per_Row)
		elseif Generic_Slot.Catagory == "Offerings" then
			Generic_Slot.Name = GiveOffering(ROW * Store.Row_Settings.Boost_Per_Row)
		else
			warn('Have no support for slot catagory of :', Generic_Slot.Catagory)
		end
		
		return Generic_Slot
	end
	
	local function AssignPerk() : "Assign any Perks we can if we can"
		local Generic_Slot = {
			Catagory = "Perks";
			Name = "Missing";
			Purchased = false;
		}
		
		if #Perk_For_Shop > 0 then
			Generic_Slot.Name = Perk_For_Shop[math.random(1, #Perk_For_Shop)]
			table.remove(Perk_For_Shop, table.find(Perk_For_Shop, Generic_Slot.Name))
		else
			Generic_Slot = AssignRandom(20)
		end
		
		return Generic_Slot
	end
	
	-- Generate Data --
	for i = 1, 5, 1 do
		local Row_Name = 'Row'..i
		
		Current_Shop.Data[Row_Name] = {}
		
		for x = 1, Store.Row_Settings.Row_Slots[Row_Name], 1 do
			
			if i >= 5 then
				Current_Shop.Data[Row_Name]['Slot'..x] = AssignPerk()
			else
				Current_Shop.Data[Row_Name]['Slot'..x] = AssignRandom(math.clamp(i - 2.2, -1, 5))
			end
		end
	end
	
	return Current_Shop
end

function Store:Get(Shop_Data : "table", Player : Player, Type : "Survivor" | "Killer") : "Return Store"
	local Current_Shop = Shop_Data
	
	if not Store.Store_Options[Player.Name] then
		Store:GetListings(Player) -- generate updated-shop possibilities --
	end
	
	if not Current_Shop or not Current_Shop.Row then
		Current_Shop = Store:Generate(Player, Type) -- create a new one
	elseif Current_Shop.Row > 5 then -- exceeded the rows means we finished and bugged out or prestiged
		Current_Shop = Store:Generate(Player, Type) -- create a new one
		data_module:Level(Type, Player) -- Level up
	end
	
	-- correct row --
	--local row_to_check = Current_Shop.Data['Row'..Current_Shop.Row]
	
	for row_to_check = Current_Shop.Row, 5, 1 do
		local Purchases = 0

		for slot, slot_data in pairs(Current_Shop.Data['Row'..row_to_check]) do
			if Purchases >= 2 then break end

			if slot_data.Purchased then
				Purchases += 1
			end
		end
		
		if Purchases >= 2 then
			Current_Shop.Row += 1
		else
			break -- end we could cycle upwards
		end
	end
	
	--[[local Purchases = 0
	
	for slot, slot_data in pairs(row_to_check) do
		if Purchases >= 2 then break end
		
		if slot_data.Purchased then
			Purchases += 1
		end
	end
	
	if Purchases >= 2 then
		Current_Shop.Row += 1
	end]]--
	
	-- correct web --
	if Current_Shop.Row > 5 then -- exceeded the rows means we finished
		Current_Shop = Store:Generate(Player, Type) -- create a new one
		data_module:Level(Type, Player) -- Level up
	end
	
	-- TODO: Make alterations/corrections [if item is disabled remove/replace from shop] 
	-- THIS IS IN HERE BECAUSE SOME OF YOU ARE NOT CAREFUL WHEN ADDING STUFF TO DATA --
	
	if Type == "Survivor" then
		for row_to_check = Current_Shop.Row, 5, 1 do
			for slot, slot_data in pairs(Current_Shop.Data['Row'..row_to_check]) do
				if slot_data.Catagory ~= "Addons" then continue end
			
				if not Game_Data:FindFirstChild("Addons"):FindFirstChild(Type):FindFirstChild(slot_data.Name) then
					slot_data.Name = "Battery" --band-aid fix ngl
				end
			end
		end
	else
		for row_to_check = Current_Shop.Row, 5, 1 do
			for slot, slot_data in pairs(Current_Shop.Data['Row'..row_to_check]) do
				if slot_data.Catagory ~= "Addons" then continue end			
				if not Game_Data:FindFirstChild("Perks"):FindFirstChild(Type):FindFirstChild(slot_data.Name) and slot_data.Name == "Temp_Phantasm" then
					slot_data.Name = "Dark Orb" --band-aid fix ngl
				end
				
				if not Game_Data:FindFirstChild("Perks"):FindFirstChild(Type):FindFirstChild(slot_data.Name) and slot_data.Name == "Soul Fue" then
					slot_data.Name = "Dark Orb" --band-aid fix ngl
				end
			end
		end
	end
	-- Perk Correction/Fixer --
	for slot, slot_data in pairs(Current_Shop.Data.Row5) do -- loop through last row
		if slot_data.Catagory ~= "Perks" then continue end
		
		if data_module:GetInventory(Type, Player).Perks[slot_data.Name] >= 3 then
			slot_data.Purchased = true -- black it out
		end
	end
	
	--print('Correct', Current_Shop)
	
	
	return Current_Shop
end


return Store