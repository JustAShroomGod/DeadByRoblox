local ReplicatedStorage = game:GetService('ReplicatedStorage')
local MarketPlace = game:GetService('MarketplaceService')

local ProductsModule = require(script:WaitForChild("Products"))

local Game_Data = ReplicatedStorage:WaitForChild('Game_Data')

local Emulate_User = false --1003985601 -- use to emulate the buying power of someone else / false when done testing

local Store = {
	Outdated_Passes = { -- Flytrap Passes | Not for Sale
		118389731,
		197783753,
		258123138,
		262708845,
		262708425,
	},
	Products = { -- blood point buying
		1689353515;
		1689353074;
		1689349990;
	},
	Purchase_Cache = {};
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

function Store:HasPass(Player : Player, Module_Data : "Data", Store_Data) : "Returns true if we own at least 1 pass in this module"
	local Keyword = if Module_Data.Name then Module_Data.Name elseif Module_Data.Killer_Name then Module_Data.Killer_Name else error(Module_Data..' has not valid names')
	
	if not Store.Purchase_Cache[Player.Name] then
		Store.Purchase_Cache[Player.Name] = {}
	end
	
	if not Store.Purchase_Cache[Player.Name][Keyword] then
		Store.Purchase_Cache[Player.Name][Keyword] = false
		
		if table.find(Module_Data.Gamepasses, Store_Data.Purchased) then
			Store.Purchase_Cache[Player.Name][Keyword] = true
			return Store.Purchase_Cache[Player.Name][Keyword] -- we have purchased this confirmed
		end
		
		for _, gamepass_id in pairs(Module_Data.Gamepasses) do
			if table.find(Store_Data.Unpurchased, gamepass_id) then continue end
			
			if table.find(Store_Data.Purchased, gamepass_id) then
				Store.Purchase_Cache[Player.Name][Keyword] = true
				return Store.Purchase_Cache[Player.Name][Keyword] -- we have purchased this confirmed
			elseif (Emulate_User and MarketPlace:UserOwnsGamePassAsync(Emulate_User, gamepass_id)) or MarketPlace:UserOwnsGamePassAsync(Player.UserId, gamepass_id) then
				Store.Purchase_Cache[Player.Name][Keyword] = true
				return Store.Purchase_Cache[Player.Name][Keyword] -- we have purchased this confirmed
			end
		end
	end
	
	return Store.Purchase_Cache[Player.Name][Module_Data.Name] -- have 0 purchases
end

function Store:Get(Player : Player) : "Return Store"
	local Purchases = {
		Killers = {}; -- recognize by being in killer
		DLC = {}; -- recognize by being in perk
		Bundle = {}; -- recognize by being both perk/killer
		Cosmetics = {}; -- recognize by being in cosmetic
		Emotes = {}; -- recognize by being in cosmetic
		Currency = {};
		Other = {}; -- extra stuff
	}
	
	
	-- Fill in with Game_Data/Exclude the Old Versions --
	for _, killer_module in pairs(Game_Data:WaitForChild('Killers'):GetChildren()) do
		if not killer_module:IsA('ModuleScript') then continue end
		killer_module = require(killer_module)
		
		if not killer_module.Active then continue end -- not active
		if #killer_module.Gamepasses <= 0 then continue end -- no gamepasses
		
		Purchases.Killers[killer_module.Killer_Name] = {}
		
		for _, gamepass_id in pairs(killer_module.Gamepasses) do
			if table.find(Store.Outdated_Passes, gamepass_id) then continue end
			table.insert(Purchases.Killers[killer_module.Killer_Name], gamepass_id)
		end
	end
	
	for _, perk_module in pairs(Game_Data:WaitForChild('Perks'):WaitForChild('Killer'):GetChildren()) do
		if not perk_module:IsA('ModuleScript') then continue end
		perk_module = require(perk_module)

		if not perk_module.Active then continue end -- not active
		if #perk_module.Gamepasses <= 0 then continue end -- no gamepasses

		Purchases.DLC[perk_module.Name] = {}

		for _, gamepass_id in pairs(perk_module.Gamepasses) do
			if table.find(Store.Outdated_Passes, gamepass_id) then continue end
			table.insert(Purchases.DLC[perk_module.Name], gamepass_id)
		end
	end
	
	for _, perk_module in pairs(Game_Data:WaitForChild('Perks'):WaitForChild('Survivor'):GetChildren()) do
		if not perk_module:IsA('ModuleScript') then continue end
		perk_module = require(perk_module)

		if not perk_module.Active then continue end -- not active
		if #perk_module.Gamepasses <= 0 then continue end -- no gamepasses
		
		Purchases.DLC[perk_module.Name] = {}

		for _, gamepass_id in pairs(perk_module.Gamepasses) do
			if table.find(Store.Outdated_Passes, gamepass_id) then continue end
			table.insert(Purchases.DLC[perk_module.Name], gamepass_id)
		end
	end
	
	for _, emote_module in pairs(Game_Data:WaitForChild('Emotes'):GetChildren()) do
		if not emote_module:IsA('ModuleScript') then continue end
		emote_module = require(emote_module)

		if not emote_module.Active then continue end -- not active
		if emote_module.Unlocked then continue end -- it is free/given already

		Purchases.Emotes[emote_module.Data_Name] = {} -- create cosmetic entry

		if emote_module.Cost then
			Purchases.Emotes[emote_module.Data_Name].Store = emote_module.Cost
		end

		Purchases.Emotes[emote_module.Data_Name].Information = {
			Description = emote_module.Description;
			Team = 'Survivor';
			Asset = emote_module.Emote_Asset;
			Purchased = false;
		}
	end
	
	for _, cosmetic_module in pairs(Game_Data:WaitForChild('Cosmetics'):WaitForChild('Survivor'):GetChildren()) do
		if not cosmetic_module:IsA('ModuleScript') then continue end
		cosmetic_module = require(cosmetic_module)
		
		if not cosmetic_module.Active then continue end -- not active
		if cosmetic_module.Unlocked then continue end -- it is free/given already
		if #cosmetic_module.Gamepasses <= 0 and GetDictAmount(cosmetic_module.Cost) <= 0 then continue end -- can not be purchased [quest item probably]
		
		Purchases.Cosmetics[cosmetic_module.Set_Name] = {} -- create cosmetic entry
		
		if #cosmetic_module.Gamepasses > 0 then
			Purchases.Cosmetics[cosmetic_module.Set_Name].Gamepass = {} -- create entry for pass
			
			for _, gamepass_id in pairs(cosmetic_module.Gamepasses) do
				if table.find(Store.Outdated_Passes, gamepass_id) then continue end
				table.insert(Purchases.Cosmetics[cosmetic_module.Set_Name].Gamepass, gamepass_id)
			end
		end
		
		if GetDictAmount(cosmetic_module.Cost) > 0 then
			Purchases.Cosmetics[cosmetic_module.Set_Name].Store = {} -- create entry for normal buying

			for body_part, amount in pairs(cosmetic_module.Cost) do
				Purchases.Cosmetics[cosmetic_module.Set_Name].Store[body_part] = amount
			end
		end
		
		Purchases.Cosmetics[cosmetic_module.Set_Name].Information = {
			Description = cosmetic_module.Description;
			Team = 'Survivor';
			Asset = cosmetic_module.Set_Asset;
			Purchased = {};
		}
		
		for _, body_part in pairs(cosmetic_module.Content) do
			Purchases.Cosmetics[cosmetic_module.Set_Name].Information.Purchased[body_part] = false
		end
	end
	
	for _, cosmetic_module in pairs(Game_Data:WaitForChild('Cosmetics'):WaitForChild('Killer'):GetChildren()) do
		if not cosmetic_module:IsA('ModuleScript') then continue end
		cosmetic_module = require(cosmetic_module)

		if not cosmetic_module.Active then continue end -- not active
		if cosmetic_module.Unlocked then continue end -- it is free/given already
		if #cosmetic_module.Gamepasses <= 0 and GetDictAmount(cosmetic_module.Cost) <= 0 then continue end -- can not be purchased [quest item probably]

		Purchases.Cosmetics[cosmetic_module.Set_Name] = {} -- create cosmetic entry

		if #cosmetic_module.Gamepasses > 0 then
			Purchases.Cosmetics[cosmetic_module.Set_Name].Gamepass = {} -- create entry for pass

			for _, gamepass_id in pairs(cosmetic_module.Gamepasses) do
				if table.find(Store.Outdated_Passes, gamepass_id) then continue end
				table.insert(Purchases.Cosmetics[cosmetic_module.Set_Name].Gamepass, gamepass_id)
			end
		end

		if GetDictAmount(cosmetic_module.Cost) > 0 then
			Purchases.Cosmetics[cosmetic_module.Set_Name].Store = {} -- create entry for normal buying

			for body_part, amount in pairs(cosmetic_module.Cost) do
				Purchases.Cosmetics[cosmetic_module.Set_Name].Store[body_part] = amount
			end
		end

		Purchases.Cosmetics[cosmetic_module.Set_Name].Information = {
			Description = cosmetic_module.Description;
			Team = 'Killer';
			Asset = cosmetic_module.Set_Asset;
			Character = if #cosmetic_module.Killers == 1 then cosmetic_module.Killers[1] else cosmetic_module.Killers;
			Purchased = {};
		}

		for _, body_part in pairs(cosmetic_module.Content) do
			Purchases.Cosmetics[cosmetic_module.Set_Name].Information.Purchased[body_part] = false
		end
	end
	
	-- Recognize Bundle Passes --
	local Bundles = {}
	
	for Perk_DLC, Gamepasses in pairs(Purchases.DLC) do
		
		for _, gamepass_id in pairs(Gamepasses) do
			if table.find(Bundles, gamepass_id) then continue end -- skip over if recognized
			
			for Killer_DLC, K_Gamepasses in pairs(Purchases.Killers) do

				for _, k_gamepass_id in pairs(K_Gamepasses) do
					
					if k_gamepass_id == gamepass_id then
						table.insert(Bundles, gamepass_id)
					end
				end
			end
		end
	end
	
	-- Correct by removing bundles from DLC and Killer --

	for Perk_DLC, Gamepasses in pairs(Purchases.DLC) do

		for _, gamepass_id in pairs(Gamepasses) do
			if not table.find(Bundles, gamepass_id) then continue end -- skip over if recognized
			table.remove(Gamepasses, table.find(Gamepasses, gamepass_id))
		end
	end

	for Killer_DLC, Gamepasses in pairs(Purchases.Killers) do

		for _, gamepass_id in pairs(Gamepasses) do
			if not table.find(Bundles, gamepass_id) then continue end -- skip over if recognized
			table.remove(Gamepasses, table.find(Gamepasses, gamepass_id))
			
			Purchases.Bundle[Killer_DLC..' Bundle'] = gamepass_id
		end
	end

	-- Recognize Perk DLCs --
	local DLCS = {}

	for Perk_DLC, Gamepasses in pairs(Purchases.DLC) do

		for _, gamepass_id in pairs(Gamepasses) do
			if table.find(DLCS, gamepass_id) then continue end -- skip over if recognized

			for Perk_DLC_CLONE, C_Gamepasses in pairs(Purchases.DLC) do
				if Perk_DLC_CLONE == Perk_DLC then continue end -- skip over self
				if table.find(DLCS, gamepass_id) then break end -- leave loop if we gained dlc
				
				for _, c_gamepass_id in pairs(C_Gamepasses) do

					if c_gamepass_id == gamepass_id then
						table.insert(DLCS, gamepass_id)
					end
				end
			end
		end
	end

	-- Correct by removing clones from DLC --
	for Perk_DLC, Gamepasses in pairs(Purchases.DLC) do

		for _, gamepass_id in pairs(Gamepasses) do
			
			if table.find(DLCS, gamepass_id) then
				Purchases.DLC[Perk_DLC] = nil -- remove this
			end
		end
	end
	
	for i, gamepass_id in pairs(DLCS) do
		Purchases.DLC["PERK PACK "..i] = gamepass_id
	end
	
	-- Correct/Re-Format Store --
	for purchase_type, purchases in pairs(Purchases) do
		if purchases == Purchases.Cosmetics then continue end -- special case
		if purchases == Purchases.Emotes then continue end -- special case
		
		for purchase, gamepass in pairs(purchases) do
			
			if typeof(gamepass) == "table" then
				
				if #gamepass > 1 then
					warn("may be a error with: "..purchase..'/'..purchase_type)
					Purchases[purchase_type][purchase] = gamepass[1]
				elseif #gamepass <= 0 then
					error("invalid purchase "..purchase..'/'..purchase_type)
				else
					Purchases[purchase_type][purchase] = gamepass[1]
				end
			else
				continue -- skip over
			end
		end
	end

	-- Over-Write with roblox data-base --

	for purchase_type, purchases in pairs(Purchases) do
		if purchases == Purchases.Cosmetics then continue end -- special case
		if purchases == Purchases.Emotes then continue end -- special case
		local Replacement = {}
		
		for purchase, gamepass in pairs(purchases) do
			local Market_Info = MarketPlace:GetProductInfoAsync(gamepass, Enum.InfoType.GamePass)
			
			if Player then
				
				Replacement[Market_Info.Name] = {
					Purchased = false;
					GamepassID = gamepass;
					Cost = Market_Info.PriceInRobux;
					Description = Market_Info.Description;
					Image = Market_Info.IconImageAssetId;
				}
				
				if Emulate_User then
					Replacement[Market_Info.Name].Purchased = MarketPlace:UserOwnsGamePassAsync(Emulate_User, gamepass)
				else
					Replacement[Market_Info.Name].Purchased = MarketPlace:UserOwnsGamePassAsync(Player.UserId, gamepass)
				end
			else
				Replacement[Market_Info.Name] = gamepass -- back-fill with roblox store
			end
		end
		
		Purchases[purchase_type] = Replacement
	end
	
	if Player then
		local S_Inventory = require(script.Parent):GetInventory("Survivor", Player)
		local K_Inventory = require(script.Parent):GetInventory("Killer", Player)

		for Cosmetic, Cosmetic_Data in pairs(Purchases.Cosmetics) do
			local hasEntry = S_Inventory.Cosmetics[Cosmetic]
			if not hasEntry then continue end -- not in survivor inventory
			for bodyPart, bool in pairs(hasEntry) do

				if Cosmetic_Data.Information.Purchased[bodyPart] ~= nil then
					Cosmetic_Data.Information.Purchased[bodyPart] = bool
				else
					warn(bodyPart, 'does not exist in set...')
				end
			end
		end

		for Cosmetic, Cosmetic_Data in pairs(Purchases.Cosmetics) do
			local hasEntry = K_Inventory.Cosmetics[Cosmetic]
			if not hasEntry then continue end -- not in killer inventory
			for bodyPart, bool in pairs(hasEntry) do

				if Cosmetic_Data.Information.Purchased[bodyPart] ~= nil then
					Cosmetic_Data.Information.Purchased[bodyPart] = bool
				else
					warn(bodyPart, 'does not exist in set...')
				end
			end
		end

		for Emote, Emote_Data in pairs(Purchases.Emotes) do
			local hasEntry = S_Inventory.Emotes[Emote]
			if not hasEntry then continue end -- not in survivor inventory

			if Emote_Data.Information.Purchased ~= nil then
				Emote_Data.Information.Purchased = S_Inventory.Emotes[Emote]
			end
		end
	end
	
	for _, product_id in pairs(Store.Products) do
		local info = MarketPlace:GetProductInfoAsync(product_id, Enum.InfoType.Product)
		
		Purchases.Currency[info.Name] = {
			Price = info.PriceInRobux;
			ProductID = product_id;
		}
	end
	
--	warn(Purchases)
	
	return Purchases
end


function Store:ProcessGamepass(Player : Player, productId : number, purchased : boolean)

	if purchased then
		
		for _, killer_module in pairs(Game_Data:WaitForChild('Killers'):GetChildren()) do
			if not killer_module:IsA('ModuleScript') then continue end
			killer_module = require(killer_module)

			if not killer_module.Active then continue end -- not active
			if #killer_module.Gamepasses <= 0 then continue end -- no gamepasses
			
			if table.find(killer_module.Gamepasses, productId) then
				require(script.Parent):UnlockCharacter(killer_module.Killer_Name, Player)
			else
				continue
			end
		end

		for _, perk_module in pairs(Game_Data:WaitForChild('Perks'):WaitForChild('Killer'):GetChildren()) do
			if not perk_module:IsA('ModuleScript') then continue end
			perk_module = require(perk_module)

			if not perk_module.Active then continue end -- not active
			if #perk_module.Gamepasses <= 0 then continue end -- no gamepasses

			if table.find(perk_module.Gamepasses, productId) then
				require(script.Parent):UnlockPerk(perk_module.Name, "Killer", Player)
			else
				continue
			end
		end

		for _, perk_module in pairs(Game_Data:WaitForChild('Perks'):WaitForChild('Survivor'):GetChildren()) do
			if not perk_module:IsA('ModuleScript') then continue end
			perk_module = require(perk_module)

			if not perk_module.Active then continue end -- not active
			if #perk_module.Gamepasses <= 0 then continue end -- no gamepasses

			if table.find(perk_module.Gamepasses, productId) then
				require(script.Parent):UnlockPerk(perk_module.Name, "Survivor", Player)
			else
				continue
			end
		end
	end
end

--[[function Store:ProcessProducts(UserId : number, product_id, purchased : boolean)
	if not purchased then return warn("DID NOT BUY") end
	local Player = game:GetService('Players'):GetPlayerByUserId(UserId)
	
	if not Player then
		error(UserId..' did not get bloodpoints!')
	end
	
	if table.find(Store.Products, product_id) then
		
		if product_id == 1689353515 then
			require(script.Parent):SetCurrency(1500000, Player) -- give 1.5m
		elseif product_id == 1689353074 then
			require(script.Parent):SetCurrency(565000, Player) -- give 565k
		elseif product_id == 1689349990 then
			require(script.Parent):SetCurrency(100000, Player) -- give 100k
		end
	else
		warn(product_id, 'not supported?')
	end
end]]

local function ProcesProducts_Receipt(receiptInfo)
	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId

	local player = game:GetService('Players'):GetPlayerByUserId(userId)
	if player then
		local handler = ProductsModule[productId]
		local success, result = pcall(handler, receiptInfo, player)
		if success then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			warn("Failed to process receipt:", receiptInfo, result)
		end
	end

	--print(receiptInfo)

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

MarketPlace.ProcessReceipt = ProcesProducts_Receipt

return Store