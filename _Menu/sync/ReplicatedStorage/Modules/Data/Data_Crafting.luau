--TODO: IDEA add task.spawn to all big loops to speed loading up?

local Game_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data')
local Market_Place = game:GetService('MarketplaceService')
local Source = script:WaitForChild('Data')
local Handler = {}

function IsPerkPurchase(Perk, Side) : boolean
	local Perk_Configuration = Game_Data:WaitForChild('Perks'):WaitForChild(Side):FindFirstChild(Perk)

	if Perk_Configuration then
		Perk_Configuration = require(Perk_Configuration)

		if Perk_Configuration.Gamepasses and #Perk_Configuration.Gamepasses >= 1 then
			return true
		end
	else
		warn(Perk, 'has no game data file!')
	end

	return false
end

function IsUnlocked(User : Player, Gamepasses : "gp_data", G_Data : string | "module") : "Returns true if any gamepass is bought and doesn't if not"
	local Store_Registry = require(script.Parent:WaitForChild('Store_Registry'))
	local Permission_module = require(script.Parent:WaitForChild('Permissions'))

	if Permission_module:GetPerms(User, 'Content') then -- bypasses since we are dev or content creator auto-rewarded this
		return true
	end

	if G_Data.Content and G_Data.Type == "Killer" then

		if Game_Data:WaitForChild('Killers'):FindFirstChild(G_Data.Content) then

			if Store_Registry:HasPass(User, require(Game_Data:WaitForChild('Killers'):WaitForChild(G_Data.Content)), Gamepasses) then
				return true
			end
		else
			warn(G_Data.Content, 'does not exist in gamedata!')
		end
	elseif G_Data.Content and G_Data.Type == "Perk" then

		if Store_Registry:HasPass(User, require(Game_Data:WaitForChild('Perks'):WaitForChild(G_Data.Side):WaitForChild(G_Data.Content)), Gamepasses) then
			return true
		end
	else
		warn(User, Gamepasses, G_Data)
	end

	return false
end

function UnloadSurvivor(Template : Folder, Data : "table", Player : Player, Gamepasses) : "Unload Survivor Data into Folder"

	-- Write Settings / Global Saves --
	if Data.Other.Ban.Banned then

		if Data.Other.Ban.Reason ~= "" and Data.Other.Ban.Reason ~= " " then
			Player:Kick("Banned:"..Data.Other.Ban.Reason)
		else
			Player:Kick("Banned: Unspecified Reason")
		end
	end

	if typeof(Data.Other.Rank) ~= "number" then
		Data.Other.Rank = 20
		warn("Rank is not a number")
	end

	if typeof(Data.Other.Rank_Settings.Progress) ~= "number" then
		Data.Other.Rank_Settings.Progress = 0
		warn("Rank progress is not a number")
	end
--misc->tutorial->kiler/surv
	Template:WaitForChild('Currency'):WaitForChild('Blood').Value = Data.Other.Blockpoints or 0
	Template:WaitForChild('Loadout'):WaitForChild('Killer').Value = Data.Other.Killer:gsub("^%l", string.upper) or 'Trapper'
	-- Stats --
	Template:WaitForChild('Stats'):WaitForChild('Ranks'):WaitForChild("Survivor").Value = Data.Other.Rank or 20
	Template:WaitForChild('Stats'):WaitForChild('Rank_Progress'):WaitForChild("Survivor").Value = Data.Other.Rank_Settings.Progress or 0
	Template:WaitForChild('Stats'):WaitForChild('Levels'):WaitForChild('Survivor').Value = Data.Other.Level or 1
	Template:WaitForChild('Stats'):WaitForChild('Prestige'):WaitForChild('Survivor').Value = Data.Other.Prestige or 0
	Template:WaitForChild('Stats'):WaitForChild('Tutorial'):WaitForChild('Survivor').Value = Data.Misc.Tutorial.Survivor or false
	Template:WaitForChild('Stats'):WaitForChild('Tutorial'):WaitForChild('Killer').Value = Data.Misc.Tutorial.Killer or false

	-- Loadout --
	local Item = ""
--	print(Data)
	if Data.Loadout.Item.Name ~= "" and Data.Loadout.Item.Class ~= "" then
		Item = Data.Loadout.Item.Name..'_'..Data.Loadout.Item.Class
	end
	Template:WaitForChild("Loadout"):WaitForChild("Addons"):WaitForChild("Survivor"):WaitForChild("Slot1").Value = Data.Loadout.Item.Addons.Slot1
	Template:WaitForChild("Loadout"):WaitForChild("Addons"):WaitForChild("Survivor"):WaitForChild("Slot2").Value = Data.Loadout.Item.Addons.Slot2
	Template:WaitForChild('Loadout'):WaitForChild('Item').Value = Item
	Template:WaitForChild('Loadout'):WaitForChild('Offering'):WaitForChild('Survivor').Value = Data.Loadout.Offering

	local Prestige = 0

	for emote_slot, emote_name in pairs(Data.Loadout.Emotes) do
		local Emote = Template:WaitForChild('Loadout'):WaitForChild('Emotes'):FindFirstChild(emote_slot)

		if Emote then
			Emote.Value = emote_name -- over-ride with current emote
		else
			warn(emote_slot, 'does not exist!')
		end
	end

	for body_part, wearing : "Cosmetic Name" in pairs(Data.Loadout.Cosmetic) do
		local Cosmetic = Template:WaitForChild('Loadout'):WaitForChild('Cosmetic'):WaitForChild('Survivor')

		if Cosmetic:FindFirstChild(body_part) then

			if Data.Inventory.Cosmetics[wearing] then

				if not Data.Inventory.Cosmetics[wearing][body_part] then
					wearing = "Default"
				end
			else

				if tostring(wearing) == "Prestige" then

					if (Data.Other.Prestige > Prestige) then
						Prestige += 1
					else
						wearing = "Default"
					end
				else
					wearing = 'Default'
				end
			end

			Cosmetic:WaitForChild(body_part).Value = tostring(wearing)
		end
	end

	for _,perkSlot in pairs(Template:WaitForChild('Loadout'):WaitForChild('Perks'):WaitForChild('Survivor'):GetChildren()) do
		perkSlot.Value = Data.Loadout.Perks[perkSlot.Name]
	end

	-- Inventory --
	for class, classTable in pairs(Data.Inventory.Items) do
		if class == "Firecracker" then continue end

		for item, count in pairs(classTable) do
			local Counter = Instance.new('IntValue', Template:WaitForChild('Inventory'):WaitForChild('Items'))
			Counter.Name = item..'_'..class
			Counter.Value = count
		end
	end

	for Offering, Count in pairs(Data.Inventory.Offerings) do
		local Offering_Counter = Instance.new("NumberValue", Template:WaitForChild('Inventory'):WaitForChild('Offerings'):WaitForChild('Survivor'))
		Offering_Counter.Name = Offering
		Offering_Counter.Value = Count
	end

	for Item, Addons in pairs(Data.Inventory.Addons) do
		local Addon_Folder = Instance.new("Folder", Template:WaitForChild('Inventory'):WaitForChild('Addons'):WaitForChild('Survivor'))
		Addon_Folder.Name = Item

		for Addon, Count in pairs(Addons) do

			local Addon_Counter = Instance.new("NumberValue", Addon_Folder)
			Addon_Counter.Name = Addon
			Addon_Counter.Value = Count
		end
	end

	for perkName, perkTier in pairs(Data.Inventory.Perks) do
		local perkSlot = Template:WaitForChild('Inventory'):WaitForChild('Perks'):WaitForChild('Survivor'):FindFirstChild(perkName)

		if not perkSlot then
			perkSlot = Instance.new('BoolValue', Template:WaitForChild('Inventory'):WaitForChild('Perks'):WaitForChild('Survivor'))
			perkSlot.Name = perkName

			local t = Instance.new('IntValue', perkSlot)
			t.Name = 'Tier'
		end

		-- TODO: Convert this to new system
		if tonumber(perkTier) <= 0 and IsPerkPurchase(perkName, 'Survivor') then -- only bother if the killer is still locked

			if IsUnlocked(Player, Gamepasses, {Content  = perkName, Type = "Perk", Side = "Survivor"}) then -- we have the gamepass
				perkTier = 1 -- automatically go to level 1 on perk
				Data.Inventory.Perks[perkName] = perkTier
			end
		end

		if tonumber(perkTier) > 0 then
			perkSlot.Value = true -- has perk
			perkSlot:WaitForChild('Tier').Value = perkTier
		else
			perkSlot.Value = false -- not obtained
		end
	end

	-----------
	local body_parts = {}

	if Data.Inventory.Cosmetics.Prestige then

		for bodyPart, bool in pairs(Data.Inventory.Cosmetics.Prestige) do

			if not bool then
				table.insert(body_parts, bodyPart)
			end
		end
	end

	if (3 - #body_parts) < Data.Other.Prestige then -- we need more prestige pieces
		repeat task.wait()
			local i = math.random(1, #body_parts)
			Data.Inventory.Cosmetics.Prestige[body_parts[i]] = true
			table.remove(body_parts, i)
		until (3 - #body_parts) >= Data.Other.Prestige
	end
end

function SoftloadKiller(Template : Folder, Data : "table", Player : Player, Gamepasses) : "Bare Essentials"
	local Correct_Name = Data.Other.Character:gsub("^%l", string.upper)
	local Level, Prestige, Addon, Offering, Rank, Rank_Progress = Template:WaitForChild('Stats'):WaitForChild('Levels'):FindFirstChild(Correct_Name), Template:WaitForChild('Stats'):WaitForChild('Prestige'):FindFirstChild(Correct_Name), Template:WaitForChild('Inventory'):WaitForChild('Addons'):WaitForChild('Killer'):FindFirstChild(Correct_Name), Template:WaitForChild('Inventory'):WaitForChild('Offerings'):WaitForChild('Killer'):FindFirstChild(Correct_Name), Template:WaitForChild('Stats'):WaitForChild('Ranks'):FindFirstChild(Correct_Name), Template:WaitForChild('Stats'):WaitForChild('Rank_Progress'):FindFirstChild(Correct_Name)

	if not Level then
		Level = Instance.new("IntValue",  Template:WaitForChild('Stats'):WaitForChild('Levels'))
		Level.Name = Correct_Name
	end

	if not Prestige then
		Prestige =  Instance.new("IntValue", Template:WaitForChild('Stats'):WaitForChild('Prestige'))
		Prestige.Name = Correct_Name
	end
	
	if not Rank then
		Rank =  Instance.new("IntValue", Template:WaitForChild('Stats'):WaitForChild('Ranks'))
		Rank.Name = Correct_Name
	end

	if not Rank_Progress then
		Rank_Progress =  Instance.new("IntValue", Template:WaitForChild('Stats'):WaitForChild('Rank_Progress'))
		Rank_Progress.Name = Correct_Name
	end

	if not Addon then
		Addon = Instance.new('Folder', Template:WaitForChild('Inventory'):WaitForChild('Addons'):WaitForChild('Killer'))
		Addon.Name = Correct_Name
	end

	if not Offering then
		Offering = Instance.new('Folder', Template:WaitForChild('Inventory'):WaitForChild('Offerings'):WaitForChild('Killer'))
		Offering.Name = Correct_Name
	end

	if typeof(Data.Other.Rank) ~= "number" then
		Data.Other.Rank = 20
		warn("Rank is not a number")
	end


	Level.Value = Data.Other.Level
	Prestige.Value = Data.Other.Prestige
	Rank.Value = Data.Other.Rank
	Rank_Progress.Value = if not Data.Other.Rank_Settings then 0 else Data.Other.Rank_Settings.Progress

	for offering, count in pairs(Data.Inventory.Offerings) do
		local f = Instance.new('IntValue', Offering)
		f.Name = offering
		f.Value = count
	end

	for addon, count in pairs(Data.Inventory.Addons) do -- fill in addons

		if not Addon:FindFirstChild(addon) then
			local f = Instance.new('IntValue', Addon)
			f.Name = addon
			f.Value = count
		end
	end

	-- Inventory --
	for perkName, perkTier in pairs(Data.Inventory.Perks) do

		if tonumber(perkTier) <= 0 and IsPerkPurchase(perkName, 'Killer') then -- only bother if the killer is still locked

			if IsUnlocked(Player, Gamepasses, {Content  = perkName, Type = "Perk", Side = "Killer"}) then -- we have the gamepass
				perkTier = 1 -- automatically go to level 1 on perk
				Data.Inventory.Perks[perkName] = perkTier
			end
		end
	end
end

function UnloadKiller(Template : Folder, Data : "table", Player : Player, Gamepasses) : "Unload Killer Data into Folder"

	-- Loadout --
	for Slot, Addon in pairs(Data.Loadout.Addons) do
		Template:WaitForChild('Loadout'):WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild(Slot).Value = Addon
	end

	Template:WaitForChild('Loadout'):WaitForChild('Offering'):WaitForChild('Killer').Value = Data.Loadout.Offering

	for _, Slot in pairs(Template:WaitForChild('Loadout'):WaitForChild('Perks'):WaitForChild('Killer'):GetChildren()) do
		Slot.Value = Data.Loadout.Perks[Slot.Name]
	end

	local Prestige = 0

	for body_part, wearing : "Cosmetic Name" in pairs(Data.Loadout.Cosmetic) do
		local Cosmetic = Template:WaitForChild('Loadout'):WaitForChild('Cosmetic'):WaitForChild('Killer')

		if Cosmetic:FindFirstChild(body_part) then

			if Data.Inventory.Cosmetics[wearing] then

				if not Data.Inventory.Cosmetics[wearing][body_part] then
					wearing = "Default"
				end
			else

				if tostring(wearing) == "Prestige" then

					if (Data.Other.Prestige > Prestige) then
						Prestige += 1
					else
						wearing = "Default"
					end
				else
					wearing = 'Default'
				end
			end

			Cosmetic:WaitForChild(body_part).Value = tostring(wearing)
		end
	end

	-- Inventory --
	for perkName, perkTier in pairs(Data.Inventory.Perks) do
		local perkSlot = Template:WaitForChild('Inventory'):WaitForChild('Perks'):WaitForChild('Killer'):FindFirstChild(perkName)

		if not perkSlot then
			perkSlot = Instance.new('BoolValue', Template:WaitForChild('Inventory'):WaitForChild('Perks'):WaitForChild('Killer'))
			perkSlot.Name = perkName

			local t = Instance.new('IntValue', perkSlot)
			t.Name = 'Tier'
		end

		if tonumber(perkTier) > 0 then
			perkSlot.Value = true -- has perk
			perkSlot:WaitForChild('Tier').Value = perkTier
		else
			perkSlot.Value = false -- not obtained
		end
	end

	-----------
	local body_parts = {}

	if Data.Inventory.Cosmetics.Prestige then

		for bodyPart, bool in pairs(Data.Inventory.Cosmetics.Prestige) do

			if not bool then
				table.insert(body_parts, bodyPart)
			end
		end
	end

	if (3 - #body_parts) < Data.Other.Prestige then -- we need more prestige pieces
		repeat task.wait()
			local i = math.random(1, #body_parts)
			Data.Inventory.Cosmetics.Prestige[body_parts[i]] = true
			table.remove(body_parts, i)
		until (3 - #body_parts) >= Data.Other.Prestige
	end
end

function Handler:Create(Player : Player, Data : "table")
	--print(Player, 'wants data:', Data)

	local Template = Source:Clone()

	-- Generate Gamepass Data --
	local Gamepass_Store, Gamepasses = require(script.Parent):GetStore(Player), {
		Purchased = {};
		Unpurchased = {};
	}

	for _, dlc_info in pairs(Gamepass_Store.DLC) do

		if dlc_info.Purchased then
			table.insert(Gamepasses.Purchased, dlc_info.GamepassID)
		else
			table.insert(Gamepasses.Unpurchased, dlc_info.GamepassID)
		end
	end

	-- Write Killers Data --
	for dataType, data in pairs(Data) do
		if dataType == 'Main' then continue end

		if not data.Other.Unlocked then -- locked killer

			if IsUnlocked(Player, Gamepasses, {Type = "Killer", Content = dataType:gsub("^%l", string.upper)}) then

				data.Other.Unlocked = true
			end
		end

		local slot = if Template:WaitForChild('Inventory'):WaitForChild('Characters'):FindFirstChild(dataType:gsub("^%l", string.upper)) then Template:WaitForChild('Inventory'):WaitForChild('Characters'):FindFirstChild(dataType:gsub("^%l", string.upper)) else Instance.new('BoolValue', Template:WaitForChild('Inventory'):WaitForChild('Characters'))
		slot.Name = dataType:gsub("^%l", string.upper)
		slot.Value = data.Other.Unlocked
		slot:SetAttribute("Kills",data.Misc.Kills)

		SoftloadKiller(Template, data, Player, Gamepasses)
	end

	-- Disable Killer if not Unlocked or disabled etc --
	local Original_Killer_Module = require(Game_Data:WaitForChild('Killers'):WaitForChild(Data.Main.Other.Killer:gsub("^%l", string.upper)))

	if not Data[Data.Main.Other.Killer].Other.Unlocked
		or not Original_Killer_Module.Active
		or (Original_Killer_Module.Testing and not require(script.Parent):GetPermission("Testing", Player)) then -- inactive killer module hard reset

		Data.Main.Other.Killer = "trapper"
	end

	-- Write Survivor Data --
	UnloadSurvivor(Template, Data.Main, Player, Gamepasses)

	-- Write Killer Data --
	UnloadKiller(Template, Data[Data.Main.Other.Killer], Player, Gamepasses)

	Template.Parent = Player
end

return Handler