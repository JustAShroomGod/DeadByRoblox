local ReplicatedStorage = game:GetService('ReplicatedStorage')

local ModuleStorage, Game_Data = ReplicatedStorage:WaitForChild('Modules'), ReplicatedStorage:WaitForChild('Game_Data')

local Player = game.Players.LocalPlayer

local Loadout_Frame = script.Parent.Parent:WaitForChild('Content'):WaitForChild('Loadout')

local Modules = {
	Data = require(ModuleStorage:WaitForChild('Data'));
	Hover = require(Player:WaitForChild('PlayerGui'):WaitForChild('HUD'):WaitForChild('Hover_Module'));
}

repeat task.wait() until Player:FindFirstChild("Data")

local UI = {
	Perk_Loadout = Loadout_Frame:WaitForChild('Perk_Frame');
	Item_Loadout = Loadout_Frame:WaitForChild('Item_Frame');
	Offering_Loadout = Loadout_Frame:WaitForChild('Offering_Frame');
	Inventory_Frames = Loadout_Frame:WaitForChild('Inventory');
	Information_Frame = Loadout_Frame:WaitForChild('Information')
}


local Settings = {
	Perks_Per_Page = 0;
	Items_Per_Page = 0;
	Addons_Per_Page = 0;
	Offerings_Per_Page = 0;
	Inactive_Color = Color3.fromRGB(76, 76, 76)
}

local Handler = {
	Data_Folder = Player:WaitForChild('Data');
	Data_Template = Modules.Data:GetRaw();
	Loadout_Storage = {
		Perk_Slot = 1;
		Addon_Slot = 1;
		Current_Selection = "Perk";
	},
	Inventory_Storage = {
		Perks = {
			Current_Page = 1;
			Max_Pages = 1;
			Current_Perks = {};
			UI_Contents = {};
		},
		Addons = {
			Current_Page = 1;
			Max_Pages = 1;
			Current_Addons = {};
			UI_Contents = {};
		},
		Items = {
			Current_Page = 1;
			Max_Pages = 1;
			Current_Items = {};
			UI_Contents = {};
		},
		Offerings = {
			Current_Page = 1;
			Max_Pages = 1;
			Current_Offerings = {};
			UI_Contents = {};
		},
	},
	Connections = {
		Changed = {};
		Perk_Loadout = {};
		Perk_Inventory = {};
		Addon_Inventory = {};
		Offering_Inventory = {};
		Item_Inventory = {};
		Addon_Loadout = {};
		Hover = {
			Enter = {};
			Leave = {};
		};
	}
}

function Update_Information_Frame()
	local Level = Handler.Data_Folder:WaitForChild('Stats'):WaitForChild('Levels'):WaitForChild('Survivor').Value
	local PrestigeLevel = Handler.Data_Folder:WaitForChild('Stats'):WaitForChild('Prestige'):WaitForChild('Survivor').Value

	if PrestigeLevel > 0 then
		UI.Information_Frame:WaitForChild("Prestige"):WaitForChild("PrestigeLevel").Text = if PrestigeLevel == 3 then "III" elseif PrestigeLevel == 2 then "II" else "II"
		UI.Information_Frame:WaitForChild("Prestige").Visible = true
	else
		UI.Information_Frame:WaitForChild("Prestige").Visible = false
	end

	UI.Information_Frame:WaitForChild("Level").Text = "LEVEL: " .. Level
	UI.Information_Frame:WaitForChild("Character").Text = "RBX SURVIVOR"
end

function Set_Perk_Ticks(CurrentTier, TierFrame)

	for _, Tier in pairs(TierFrame:GetChildren()) do

		if tonumber(Tier.Name) <= CurrentTier then
			Tier.Visible = true
		else
			Tier.Visible = false
		end
	end
end

function Update_Perk_Loadout() : "Update Perk Slots"

	for _, Perk_String_Value : StringValue in pairs(Handler.Data_Folder:WaitForChild('Loadout'):WaitForChild('Perks'):WaitForChild('Survivor'):GetChildren()) do
		local Perk_Frame, Perk_Module = UI.Perk_Loadout:FindFirstChild(Perk_String_Value.Name), Game_Data:WaitForChild('Perks'):WaitForChild('Survivor'):FindFirstChild(Perk_String_Value.Value)

		if not Handler.Connections.Changed[Perk_String_Value] then
			Handler.Connections.Changed[Perk_String_Value] = Perk_String_Value.Changed:Connect(Update_Perk_Loadout)
		end

		-- Hover Controls --
		if not Handler.Connections.Hover.Enter[Perk_Frame] then

			Handler.Connections.Hover.Enter[Perk_Frame] = Perk_Frame:WaitForChild('Button').MouseEnter:Connect(function()

				if Game_Data:WaitForChild('Perks'):WaitForChild('Survivor'):FindFirstChild(Perk_String_Value.Value) then
					Modules.Hover:Display("Perk", require(Game_Data:WaitForChild('Perks'):WaitForChild('Survivor'):FindFirstChild(Perk_String_Value.Value)),Handler.Data_Folder:WaitForChild('Inventory'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild(Perk_String_Value.Value):WaitForChild('Tier').Value)
				else
					Modules.Hover:Hide()
				end
			end)
		end

		if not Handler.Connections.Hover.Leave[Perk_Frame] then

			Handler.Connections.Hover.Leave[Perk_Frame] = Perk_Frame:WaitForChild('Button').MouseLeave:Connect(function()
				Modules.Hover:Hide()
			end)
		end

		if not Handler.Connections.Perk_Loadout[Perk_Frame] then

			Handler.Connections.Perk_Loadout[Perk_Frame] = Perk_Frame:WaitForChild('Button').MouseButton1Click:Connect(function()
				local Current_Slot = Perk_String_Value.Name:gsub("[^%-%d]", "")
				Current_Slot = tonumber(Current_Slot)

				Handler.Loadout_Storage.Perk_Slot = Current_Slot

				if Handler.Loadout_Storage.Current_Selection ~= "Perk" then
					Handler.Loadout_Storage.Current_Selection = "Perk"
					Update_Perk_Inventory()
				end
			end)
		end

		if Perk_Frame and Perk_Module then
			local Perk_Tier = Handler.Data_Folder:WaitForChild('Inventory'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild(Perk_String_Value.Value):WaitForChild('Tier').Value

			Perk_Module = require(Perk_Module)

			Set_Perk_Ticks(Perk_Tier, Perk_Frame:WaitForChild('Design'):WaitForChild('Tier'))

			Perk_Frame:WaitForChild('Design'):WaitForChild('Icon').Image = Perk_Module.Image
			Perk_Frame:WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Perk_Module.Colors[Perk_Tier]
		else
			Set_Perk_Ticks(0, Perk_Frame:WaitForChild('Design'):WaitForChild('Tier'))
			Perk_Frame:WaitForChild('Design'):WaitForChild('Icon').Image = ""
			Perk_Frame:WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Settings.Inactive_Color
		end
	end
end

function Update_Addon_Loadout()
	local Current_Item = Handler.Data_Folder:WaitForChild('Loadout'):WaitForChild('Item').Value
	local Source_Module = Game_Data:WaitForChild('Items'):FindFirstChild(Current_Item)

	for _, Addon_String_Value : StringValue in pairs(Handler.Data_Folder:WaitForChild('Loadout'):WaitForChild('Addons'):WaitForChild('Survivor'):GetChildren()) do
		local Addon_Frame, Addon_Module = UI.Item_Loadout:WaitForChild('Addons'):FindFirstChild(Addon_String_Value.Name), Game_Data:WaitForChild('Addons'):WaitForChild('Survivor'):FindFirstChild(Addon_String_Value.Value)

		-- Hover Controls --
		if Addon_Frame and not Handler.Connections.Hover.Enter[Addon_Frame] then

			Handler.Connections.Hover.Enter[Addon_Frame] = Addon_Frame:WaitForChild('Button').MouseEnter:Connect(function()
				local Current_Slot = Addon_String_Value.Name:gsub("[^%-%d]", "")
				Current_Slot = tonumber(Current_Slot)

				Current_Slot = Handler.Data_Folder:WaitForChild('Loadout'):WaitForChild('Addons'):WaitForChild('Survivor'):FindFirstChild('Slot'..Current_Slot)

				if Current_Slot and Game_Data:WaitForChild('Addons'):WaitForChild('Survivor'):FindFirstChild(Current_Slot.Value) then
					Modules.Hover:Display("Addon", require(Game_Data:WaitForChild('Addons'):WaitForChild('Survivor'):FindFirstChild(Current_Slot.Value)))
				else
					Modules.Hover:Hide()
				end
			end)
		end

		if Addon_Frame and not Handler.Connections.Hover.Leave[Addon_Frame] then

			Handler.Connections.Hover.Leave[Addon_Frame] = Addon_Frame:WaitForChild('Button').MouseLeave:Connect(function()
				Modules.Hover:Hide()
			end)
		end


		if not Handler.Connections.Changed[Addon_String_Value] then
			Handler.Connections.Changed[Addon_String_Value] = Addon_String_Value.Changed:Connect(Update_Addon_Loadout)
		end

		if Addon_Frame and not Handler.Connections.Addon_Loadout[Addon_Frame] then

			Handler.Connections.Addon_Loadout[Addon_Frame] = Addon_Frame:WaitForChild('Button').MouseButton1Click:Connect(function()
				local Current_Slot = Addon_String_Value.Name:gsub("[^%-%d]", "")
				Current_Slot = tonumber(Current_Slot)

				Handler.Loadout_Storage.Addon_Slot = Current_Slot

				if Handler.Loadout_Storage.Current_Selection ~= "Addon" then
					Handler.Loadout_Storage.Current_Selection = "Addon"
					Update_Addon_Inventory()
				end
			end)
		end

		if Addon_Frame and Addon_Module and Source_Module then
			local Source_Module = Game_Data:WaitForChild('Items'):FindFirstChild(Current_Item)
			Source_Module = require(Source_Module)
			local Addon_Amount = Handler.Data_Folder:WaitForChild('Inventory'):WaitForChild('Addons'):WaitForChild('Survivor'):WaitForChild(Source_Module.Class):WaitForChild(Addon_String_Value.Value).Value

			Addon_Module = require(Addon_Module)

			Addon_Frame:WaitForChild('Design'):WaitForChild('Amount').Text = Addon_Amount
			Addon_Frame:WaitForChild('Design'):WaitForChild('Amount').Visible = true
			Addon_Frame:WaitForChild('Design'):WaitForChild('Icon').Image = Addon_Module.Image
			Addon_Frame:WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Addon_Module.Color
		else
			Addon_Frame:WaitForChild('Design'):WaitForChild('Amount').Visible = false
			Addon_Frame:WaitForChild('Design'):WaitForChild('Icon').Image = ""
			Addon_Frame:WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Settings.Inactive_Color
		end
	end
end

function Update_Item_Loadout()
	local Item = Handler.Data_Folder:WaitForChild('Loadout'):WaitForChild('Item')
	local Item_Module = Game_Data:WaitForChild('Items'):FindFirstChild(Item.Value)

	if not Handler.Connections.Changed[Item] then
		Handler.Connections.Changed[Item] = Item.Changed:Connect(Update_Item_Loadout)
	end

	-- Hover Controls --
	if not Handler.Connections.Hover.Enter[UI.Item_Loadout:WaitForChild('Item'):WaitForChild('Button')] then

		Handler.Connections.Hover.Enter[UI.Item_Loadout:WaitForChild('Item'):WaitForChild('Button')] = UI.Item_Loadout:WaitForChild('Item'):WaitForChild('Button').MouseEnter:Connect(function()

			if Game_Data:WaitForChild('Items'):FindFirstChild(Item.Value) then
				Modules.Hover:Display("Item", require(Game_Data:WaitForChild('Items'):WaitForChild(Item.Value)))
			else
				Modules.Hover:Hide()
			end
		end)
	end

	if not Handler.Connections.Hover.Leave[UI.Item_Loadout:WaitForChild('Item'):WaitForChild('Button')] then

		Handler.Connections.Hover.Leave[UI.Item_Loadout:WaitForChild('Item'):WaitForChild('Button')] = UI.Item_Loadout:WaitForChild('Item'):WaitForChild('Button').MouseLeave:Connect(function()
			Modules.Hover:Hide()
		end)
	end

	if Item_Module then
		Item_Module = require(Item_Module)

		UI.Item_Loadout:WaitForChild('Item'):WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Item_Module.Color
		UI.Item_Loadout:WaitForChild('Item'):WaitForChild('Design'):WaitForChild('Icon').Image = Item_Module.Image
	else
		UI.Item_Loadout:WaitForChild('Item'):WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Settings.Inactive_Color
		UI.Item_Loadout:WaitForChild('Item'):WaitForChild('Design'):WaitForChild('Icon').Image = ""
	end
end

function Update_Offering_Loadout()
	local Offering_Slot = Handler.Data_Folder:WaitForChild('Loadout'):WaitForChild('Offering'):WaitForChild('Survivor')
	local Offering_Module = Game_Data:WaitForChild('Offerings'):WaitForChild('Survivor'):FindFirstChild(Offering_Slot.Value)

	if not Handler.Connections.Changed[Offering_Slot] then
		Handler.Connections.Changed[Offering_Slot] = Offering_Slot.Changed:Connect(Update_Offering_Loadout)
	end

	-- Hover Controls --
	if not Handler.Connections.Hover.Enter[Offering_Slot] then

		Handler.Connections.Hover.Enter[Offering_Slot] = UI.Offering_Loadout:WaitForChild('Offering'):WaitForChild('Button').MouseEnter:Connect(function()

			if Game_Data:WaitForChild('Offerings'):WaitForChild('Survivor'):FindFirstChild(Offering_Slot.Value) then
				Modules.Hover:Display("Offering", require(Game_Data:WaitForChild('Offerings'):WaitForChild('Survivor'):WaitForChild(Offering_Slot.Value)))
			else
				Modules.Hover:Hide()
			end
		end)
	end

	if not Handler.Connections.Hover.Leave[Offering_Slot] then

		Handler.Connections.Hover.Leave[Offering_Slot] = UI.Offering_Loadout:WaitForChild('Offering'):WaitForChild('Button').MouseLeave:Connect(function()
			Modules.Hover:Hide()
		end)
	end

	if Offering_Module then
		Offering_Module = require(Offering_Module)

		UI.Offering_Loadout:WaitForChild('Offering'):WaitForChild('Design'):WaitForChild('Color').ImageColor3 = Offering_Module.Color
		UI.Offering_Loadout:WaitForChild('Offering'):WaitForChild('Design'):WaitForChild('Icon').Image = Offering_Module.Image
		UI.Offering_Loadout:WaitForChild('Offering'):WaitForChild('Design'):WaitForChild('Amount').Text = Handler.Data_Folder:WaitForChild('Inventory'):WaitForChild('Offerings'):WaitForChild('Survivor'):WaitForChild(Offering_Module.Data_Name).Value
		UI.Offering_Loadout:WaitForChild('Offering'):WaitForChild('Design'):WaitForChild('Amount').Visible = true
	else
		UI.Offering_Loadout:WaitForChild('Offering'):WaitForChild('Design'):WaitForChild('Color').ImageColor3 = Settings.Inactive_Color
		UI.Offering_Loadout:WaitForChild('Offering'):WaitForChild('Design'):WaitForChild('Icon').Image = ""
		UI.Offering_Loadout:WaitForChild('Offering'):WaitForChild('Design'):WaitForChild('Amount').Visible = false
	end
end

function Pull_Perk_Inventory() : "Get Perks that are Currently Active"
	local Perks = {}

	for _, Perk_Boolean in pairs(Handler.Data_Folder:WaitForChild('Inventory'):WaitForChild('Perks'):WaitForChild('Survivor'):GetChildren()) do
		if not Perk_Boolean.Value then continue end -- not unlocked, in testing, or deactivated
		local Perk_Module = Game_Data:WaitForChild('Perks'):WaitForChild('Survivor'):FindFirstChild(Perk_Boolean.Name)

		if Perk_Module then
			Perk_Module = require(Perk_Module)

			if Perk_Module.Active then

				if not Perk_Module.Testing or Modules.Data:GetPermission("Testing") then
					table.insert(Perks, {Perk_Boolean.Name, Perk_Boolean:WaitForChild('Tier').Value, Perk_Module.Name}) -- assign tier to it
				end
			end
		else
			--warn(Perk_Boolean.Name, 'is not a perk in gamedata!')
		end
	end

	-- alphabetize the order --
	table.sort(Perks, function(tbl_1, tbl_2)
		return tbl_1[3]:lower() < tbl_2[3]:lower()
	end)

	return Perks
end

function Pull_Offering_Inventory() : "Get Offerings that are Currently Active"
	local Offerings = {}

	for _, Offering_Number in pairs(Handler.Data_Folder:WaitForChild('Inventory'):WaitForChild('Offerings'):WaitForChild('Survivor'):GetChildren()) do
		local Offering_Module = Game_Data:WaitForChild('Offerings'):WaitForChild('Survivor'):FindFirstChild(Offering_Number.Name)

		if Offering_Module then
			Offering_Module = require(Offering_Module)

			if Offering_Module.Active then

				if not Offering_Module.Testing or Modules.Data:GetPermission("Testing") then
					table.insert(Offerings, {Offering_Number.Name, Offering_Module , Offering_Number.Value}) -- Name / Module / Rarity / Amount
				end
			else
				-- addon was not valid do not add --
			end
		else
			--warn(Offering_Number.Name, 'is missing from game_Data')
		end
	end

	-- alphabetize the order --
	table.sort(Offerings, function(tbl_1, tbl_2)
		return tbl_1[1]:lower() < tbl_2[1]:lower() -- sorts by name

		--[[if tbl_1[2].Shop_Chance and tbl_2[2].Shop_Chance then
			return tbl_1[2].Shop_Chance < tbl_2[2].Shop_Chance -- sorts by rarity
		else -- default to name only no chance on one of them
			return tbl_1[1]:lower() < tbl_2[1]:lower() -- sorts by name
		end]]--
	end)

	return Offerings
end

function Pull_Item_Inventory() : "Get Addons that are Currently Active"
	local Items = {}

	for _, Item_Number in pairs(Handler.Data_Folder:WaitForChild('Inventory'):WaitForChild('Items'):GetChildren()) do
		local Item_Module = Game_Data:WaitForChild('Items'):FindFirstChild(Item_Number.Name)

		if Item_Module then
			Item_Module = require(Item_Module)

			if Item_Module.Active and Item_Module.Equipable then

				if not Item_Module.Testing or Modules.Data:GetPermission("Testing") then
					table.insert(Items, {Item_Number.Name, Item_Module , Item_Number.Value}) -- Name / Module / Rarity / Amount
				end
			else
				-- addon was not valid do not add --
			end
		else
			--warn(Item_Number.Name, 'is missing from game_Data')
		end
	end

	-- alphabetize the order of classes then rarity --
	table.sort(Items, function(tbl_1, tbl_2)

		if tbl_1[2].Class:lower() == tbl_2[2].Class:lower() then -- same class

			return tbl_1[2].Shop_Chance < tbl_2[2].Shop_Chance
		else
			return tbl_1[2].Class:lower() < tbl_2[2].Class:lower()
		end
	end)

	return Items
end

function Pull_Addon_Inventory() : "Get Addons that are Currently Active"
	local Addons = {}

	local Current_Item = Handler.Data_Folder:WaitForChild('Loadout'):WaitForChild('Item').Value
	local Source_Module = require(Game_Data:WaitForChild('Items'):FindFirstChild(Current_Item))

	for _, Addon_Number in pairs(Handler.Data_Folder:WaitForChild('Inventory'):WaitForChild('Addons'):WaitForChild('Survivor'):WaitForChild(Source_Module.Class):GetChildren()) do
		local Addon_Module = Game_Data:WaitForChild('Addons'):WaitForChild('Survivor'):FindFirstChild(Addon_Number.Name)

		if Addon_Module then
			Addon_Module = require(Addon_Module)

			if Addon_Module.Active then

				if not Addon_Module.Testing or Modules.Data:GetPermission("Testing") then
					table.insert(Addons, {Addon_Number.Name, Addon_Module , Addon_Number.Value}) -- Name / Module / Rarity / Amount
				end
			else
				-- addon was not valid do not add --
			end
		else
			--warn(Addon_Number.Name, 'is missing from game_Data')
		end
	end

	-- alphabetize the order --
	table.sort(Addons, function(tbl_1, tbl_2)
		return tbl_1[1]:lower() < tbl_2[1]:lower() -- sorts by name

		--[[if tbl_1[2].Shop_Chance and tbl_2[2].Shop_Chance then
			return tbl_1[2].Shop_Chance < tbl_2[2].Shop_Chance -- sorts by rarity
		else -- default to name only no chance on one of them
			return tbl_1[1]:lower() < tbl_2[1]:lower() -- sorts by name
		end]]--
	end)

	return Addons
end

function Display_Perks()
	local current_perk_index = -Settings.Perks_Per_Page

	current_perk_index += (Handler.Inventory_Storage.Perks.Current_Page * Settings.Perks_Per_Page)

	UI.Inventory_Frames:WaitForChild('PageNum').Text = '<b>' .. Handler.Inventory_Storage.Perks.Current_Page .. ' / </b><font color="#d0d0d0">' .. Handler.Inventory_Storage.Perks.Max_Pages .. '</font>'

	for current_row, row_data in pairs(Handler.Inventory_Storage.Perks.UI_Contents) do

		for current_perk_slot, perk_slot in pairs(row_data) do
			current_perk_index += 1

			if not Handler.Connections.Perk_Inventory[perk_slot] then

				Handler.Connections.Perk_Inventory[perk_slot] = perk_slot:WaitForChild('Button').MouseButton1Click:Connect(function()
					Modules.Data:EquipPerk("Survivor", perk_slot:WaitForChild('Button'):GetAttribute("Perk"), Handler.Loadout_Storage.Perk_Slot)
					--print(perk_slot:WaitForChild('Button'):GetAttribute("Perk"))
				end)
			end

			-- Hover Controls --
			if not Handler.Connections.Hover.Enter[perk_slot] then

				Handler.Connections.Hover.Enter[perk_slot] = perk_slot:WaitForChild('Design'):WaitForChild('Perk').MouseEnter:Connect(function()

					if perk_slot:WaitForChild('Button'):GetAttribute('Perk') and Game_Data:WaitForChild('Perks'):WaitForChild('Survivor'):FindFirstChild(perk_slot:WaitForChild('Button'):GetAttribute('Perk')) then
						Modules.Hover:Display("Perk", require(Game_Data:WaitForChild('Perks'):WaitForChild('Survivor'):FindFirstChild(perk_slot:WaitForChild('Button'):GetAttribute('Perk'))),Handler.Data_Folder:WaitForChild('Inventory'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild(perk_slot:WaitForChild('Button'):GetAttribute('Perk')):WaitForChild('Tier').Value)
					else
						Modules.Hover:Hide()
					end
				end)
			end

			if not Handler.Connections.Hover.Leave[perk_slot] then

				Handler.Connections.Hover.Leave[perk_slot] = perk_slot:WaitForChild('Design'):WaitForChild('Perk').MouseLeave:Connect(function()
					Modules.Hover:Hide()
				end)
			end

			if Handler.Inventory_Storage.Perks.Current_Perks[current_perk_index] then -- we have perk name + tier
				local Perk_Module = Game_Data:WaitForChild('Perks'):WaitForChild('Survivor'):FindFirstChild(Handler.Inventory_Storage.Perks.Current_Perks[current_perk_index][1])

				if Perk_Module then
					Perk_Module = require(Perk_Module)

					Set_Perk_Ticks(Handler.Inventory_Storage.Perks.Current_Perks[current_perk_index][2], perk_slot:WaitForChild('Design'):WaitForChild('Tier'))
					perk_slot:WaitForChild('Design'):WaitForChild('Perk').Image = Perk_Module.Image or ""
					perk_slot:WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Perk_Module.Colors[Handler.Inventory_Storage.Perks.Current_Perks[current_perk_index][2]] or Color3.fromRGB(6, 62, 125)
					perk_slot:WaitForChild('Button'):SetAttribute("Perk", Handler.Inventory_Storage.Perks.Current_Perks[current_perk_index][1])
				else
					warn('Perk Module not found:', Handler.Inventory_Storage.Perks.Current_Perks[current_perk_index][1])

					Set_Perk_Ticks(0, perk_slot:WaitForChild('Design'):WaitForChild('Tier'))
					perk_slot:WaitForChild('Design'):WaitForChild('Perk').Image = ""
					perk_slot:WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Settings.Inactive_Color
					perk_slot:WaitForChild('Button'):SetAttribute("Perk", nil)
				end
			else -- no perk to display here
				Set_Perk_Ticks(0, perk_slot:WaitForChild('Design'):WaitForChild('Tier'))
				perk_slot:WaitForChild('Design'):WaitForChild('Perk').Image = ""
				perk_slot:WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Settings.Inactive_Color
				perk_slot:WaitForChild('Button'):SetAttribute("Perk", nil)
			end
		end
	end
end

function Display_Addons()
	local current_addon_index = -Settings.Addons_Per_Page

	current_addon_index += (Handler.Inventory_Storage.Addons.Current_Page * Settings.Addons_Per_Page)

	UI.Inventory_Frames:WaitForChild('PageNum').Text = '<b>' .. Handler.Inventory_Storage.Addons.Current_Page .. ' / </b><font color="#d0d0d0">' .. Handler.Inventory_Storage.Addons.Max_Pages .. '</font>'

	for current_addon_slot, addon_slot in pairs(Handler.Inventory_Storage.Addons.UI_Contents) do
		current_addon_index += 1

		if not Handler.Connections.Addon_Inventory[addon_slot] then
			Handler.Connections.Addon_Inventory[addon_slot] = addon_slot:WaitForChild('Button').MouseButton1Click:Connect(function()
				Modules.Data:EquipAddon("Survivor", addon_slot:WaitForChild('Button'):GetAttribute("Addon"), Handler.Loadout_Storage.Addon_Slot)
			end)
		end

		-- Hover Controls --
		if not Handler.Connections.Hover.Enter[addon_slot] then

			Handler.Connections.Hover.Enter[addon_slot] =  addon_slot:WaitForChild('Button').MouseEnter:Connect(function()

				if addon_slot:WaitForChild('Button'):GetAttribute('Addon') and Game_Data:WaitForChild('Addons'):WaitForChild('Survivor'):FindFirstChild(addon_slot:WaitForChild('Button'):GetAttribute('Addon')) then
					Modules.Hover:Display("Addon", require(Game_Data:WaitForChild('Addons'):WaitForChild('Survivor'):FindFirstChild(addon_slot:WaitForChild('Button'):GetAttribute("Addon"))))
				else
					Modules.Hover:Hide()
				end
			end)
		end

		if not Handler.Connections.Hover.Leave[addon_slot] then

			Handler.Connections.Hover.Leave[addon_slot] = addon_slot:WaitForChild('Button').MouseLeave:Connect(function()
				Modules.Hover:Hide()
			end)
		end

		if Handler.Inventory_Storage.Addons.Current_Addons[current_addon_index] then -- we have addon, module, + count
			addon_slot:WaitForChild('Design'):WaitForChild('Addon').Image = Handler.Inventory_Storage.Addons.Current_Addons[current_addon_index][2].Image
			addon_slot:WaitForChild('Design'):WaitForChild('Amount').Text = Handler.Inventory_Storage.Addons.Current_Addons[current_addon_index][3]
			addon_slot:WaitForChild('Button'):SetAttribute("Addon", Handler.Inventory_Storage.Addons.Current_Addons[current_addon_index][1])

			if Handler.Inventory_Storage.Addons.Current_Addons[current_addon_index][3] <= 0 then
				addon_slot:WaitForChild('Design'):WaitForChild('Addon').ImageColor3 = Color3.fromRGB(48, 48, 48)
				addon_slot:WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Settings.Inactive_Color
			else
				addon_slot:WaitForChild('Design'):WaitForChild('Addon').ImageColor3 = Color3.fromRGB(255, 255, 255)
				addon_slot:WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Handler.Inventory_Storage.Addons.Current_Addons[current_addon_index][2].Color
			end

			addon_slot.Visible = true -- just turn it off
		else -- no perk to display here
			addon_slot:WaitForChild('Button'):SetAttribute("Addon", nil)
			addon_slot.Visible = false -- just turn it off
		end
	end
end

function Display_Items()
	local current_item_index = -Settings.Items_Per_Page

	current_item_index += (Handler.Inventory_Storage.Items.Current_Page * Settings.Items_Per_Page)

	UI.Inventory_Frames:WaitForChild('PageNum').Text = '<b>' .. Handler.Inventory_Storage.Items.Current_Page .. ' / </b><font color="#d0d0d0">' .. Handler.Inventory_Storage.Items.Max_Pages .. '</font>'

	for current_item_slot, item_slot in pairs(Handler.Inventory_Storage.Items.UI_Contents) do
		current_item_index += 1

		-- Hover Controls --
		if not Handler.Connections.Hover.Enter[item_slot] then

			Handler.Connections.Hover.Enter[item_slot] = item_slot.MouseEnter:Connect(function()

				if Game_Data:WaitForChild('Items'):FindFirstChild(item_slot:WaitForChild('Button'):GetAttribute("Item")) then
					Modules.Hover:Display("Item", require(Game_Data:WaitForChild('Items'):WaitForChild(item_slot:WaitForChild('Button'):GetAttribute("Item"))))
				else
					Modules.Hover:Hide()
				end
			end)
		end

		if not Handler.Connections.Hover.Leave[item_slot] then

			Handler.Connections.Hover.Leave[item_slot] = item_slot:WaitForChild('Button').MouseLeave:Connect(function()
				Modules.Hover:Hide()
			end)
		end

		if not Handler.Connections.Item_Inventory[item_slot] then

			Handler.Connections.Item_Inventory[item_slot] = item_slot:WaitForChild('Button').MouseButton1Click:Connect(function()
				if (game.Players.LocalPlayer:WaitForChild("Data"):WaitForChild("Loadout"):WaitForChild("Item").Value == item_slot:WaitForChild('Button'):GetAttribute("Item")) then
					Modules.Data:EquipItem("")
				else
					Modules.Data:EquipItem(item_slot:WaitForChild('Button'):GetAttribute("Item"))
				end
			end)
		end

		if Handler.Inventory_Storage.Items.Current_Items[current_item_index] then -- we have addon, module, + count
			item_slot:WaitForChild('Design'):WaitForChild('Item').Image = Handler.Inventory_Storage.Items.Current_Items[current_item_index][2].Image
			item_slot:WaitForChild('Design'):WaitForChild('Amount').Text = Handler.Inventory_Storage.Items.Current_Items[current_item_index][3]
			item_slot:WaitForChild('Button'):SetAttribute("Item", Handler.Inventory_Storage.Items.Current_Items[current_item_index][1])

			if Handler.Inventory_Storage.Items.Current_Items[current_item_index][3] <= 0 then
				item_slot:WaitForChild('Design'):WaitForChild('Item').ImageColor3 = Color3.fromRGB(48, 48, 48)
				item_slot:WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Settings.Inactive_Color
			else
				item_slot:WaitForChild('Design'):WaitForChild('Item').ImageColor3 = Color3.fromRGB(255, 255, 255)
				item_slot:WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Handler.Inventory_Storage.Items.Current_Items[current_item_index][2].Color
			end

			item_slot.Visible = true -- just turn it off
		else -- no perk to display here
			item_slot:WaitForChild('Button'):SetAttribute("Item", nil)
			item_slot.Visible = false -- just turn it off
		end
	end
end

function Display_Offerings()
	local current_offering_index = -Settings.Offerings_Per_Page

	current_offering_index += (Handler.Inventory_Storage.Offerings.Current_Page * Settings.Offerings_Per_Page)

	UI.Inventory_Frames:WaitForChild('PageNum').Text = '<b>' .. Handler.Inventory_Storage.Offerings.Current_Page .. ' / </b><font color="#d0d0d0">' .. Handler.Inventory_Storage.Offerings.Max_Pages .. '</font>'

	for current_offering_slot, offering_slot in pairs(Handler.Inventory_Storage.Offerings.UI_Contents) do
		current_offering_index += 1

		if not Handler.Connections.Offering_Inventory[offering_slot] then

			Handler.Connections.Offering_Inventory[offering_slot] = offering_slot:WaitForChild('Button').MouseButton1Click:Connect(function()
				Modules.Data:EquipOffering("Survivor", offering_slot:WaitForChild('Button'):GetAttribute("Offering"))
			end)
		end

		-- Hover Controls --
		if not Handler.Connections.Hover.Enter[offering_slot] then

			Handler.Connections.Hover.Enter[offering_slot] = offering_slot:WaitForChild('Button').MouseEnter:Connect(function()

				if Game_Data:WaitForChild('Offerings'):WaitForChild('Survivor'):FindFirstChild(offering_slot:WaitForChild('Button'):GetAttribute('Offering')) then
					Modules.Hover:Display("Offering", require(Game_Data:WaitForChild('Offerings'):WaitForChild('Survivor'):FindFirstChild(offering_slot:WaitForChild('Button'):GetAttribute('Offering'))))
				else
					Modules.Hover:Hide()
				end
			end)
		end

		if not Handler.Connections.Hover.Leave[offering_slot] then

			Handler.Connections.Hover.Leave[offering_slot] = offering_slot:WaitForChild('Button').MouseLeave:Connect(function()
				Modules.Hover:Hide()
			end)
		end

		if Handler.Inventory_Storage.Offerings.Current_Offerings[current_offering_index] then -- we have addon, module, + count
			offering_slot:WaitForChild('Design'):WaitForChild('Offering').Image = Handler.Inventory_Storage.Offerings.Current_Offerings[current_offering_index][2].Image
			offering_slot:WaitForChild('Design'):WaitForChild('Amount').Text = Handler.Inventory_Storage.Offerings.Current_Offerings[current_offering_index][3]
			offering_slot:WaitForChild('Button'):SetAttribute("Offering", Handler.Inventory_Storage.Offerings.Current_Offerings[current_offering_index][1])

			if Handler.Inventory_Storage.Offerings.Current_Offerings[current_offering_index][3] <= 0 then
				offering_slot:WaitForChild('Design'):WaitForChild('Offering').ImageColor3 = Color3.fromRGB(48, 48, 48)
				offering_slot:WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Settings.Inactive_Color
			else
				offering_slot:WaitForChild('Design'):WaitForChild('Offering').ImageColor3 = Color3.fromRGB(255, 255, 255)
				offering_slot:WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Handler.Inventory_Storage.Offerings.Current_Offerings[current_offering_index][2].Color
			end

			offering_slot.Visible = true -- just turn it off
		else -- no perk to display here
			offering_slot:WaitForChild('Button'):SetAttribute("Offering", nil)
			offering_slot.Visible = false -- just turn it off
		end
	end
end

function Update_Perk_Inventory()
	local Perk_Inventory_Frame = UI.Inventory_Frames:WaitForChild('Perks')

	if Settings.Perks_Per_Page == 0 then -- calculate it


		for _, Perk_Row in pairs(Perk_Inventory_Frame:GetChildren()) do
			if Perk_Row.Name == "Ratio" then continue end
			Handler.Inventory_Storage.Perks.UI_Contents[tonumber(Perk_Row.Name)] = {}

			for _, Perk_Slot in pairs(Perk_Row:GetChildren()) do
				if Perk_Slot.Name == "Grid" then continue end
				Handler.Inventory_Storage.Perks.UI_Contents[tonumber(Perk_Row.Name)][tonumber(Perk_Slot.Name)] = Perk_Slot -- attach to ui
				Settings.Perks_Per_Page += 1
			end
		end
	end

	-- Calculate the pages --
	Handler.Inventory_Storage.Perks.Current_Perks = Pull_Perk_Inventory()
	Handler.Inventory_Storage.Perks.Current_Page = 1
	Handler.Inventory_Storage.Perks.Max_Pages = (math.floor((#Handler.Inventory_Storage.Perks.Current_Perks - 1)/Settings.Perks_Per_Page) + 1)

	-- Display the Page --
	Display_Perks()

	-- Display Page Navigation --
	UI.Inventory_Frames:WaitForChild('Forward').Visible = (Handler.Inventory_Storage.Perks.Max_Pages > 1)
	UI.Inventory_Frames:WaitForChild('Backward').Visible = (Handler.Inventory_Storage.Perks.Max_Pages > 1)

	UI.Inventory_Frames:WaitForChild('PageNum').Text = '<b>' .. Handler.Inventory_Storage.Perks.Current_Page .. ' / </b><font color="#d0d0d0">' .. Handler.Inventory_Storage.Perks.Max_Pages .. '</font>'
	UI.Inventory_Frames:WaitForChild('Title').Text = '<b>INVENTORY</b><font color="#d0d0d0">/PERKS</font>'

	-- Adjust Visibility --
	Perk_Inventory_Frame.Visible = true
	UI.Inventory_Frames:WaitForChild('Items').Visible = false
	UI.Inventory_Frames:WaitForChild('Addons').Visible = false
	UI.Inventory_Frames:WaitForChild('Offerings').Visible = false
end

function Update_Addon_Inventory()
	local Addon_Inventory_Frame = UI.Inventory_Frames:WaitForChild('Addons')

	if Settings.Addons_Per_Page == 0 then -- calculate it

		for _, Addon_Slot in pairs(Addon_Inventory_Frame:GetChildren()) do
			if not Addon_Slot:IsA('Frame') then continue end
			Handler.Inventory_Storage.Addons.UI_Contents[tonumber(Addon_Slot.Name)] = Addon_Slot -- attach to ui
			Settings.Addons_Per_Page += 1
		end
	end

	-- Calculate the pages --
	Handler.Inventory_Storage.Addons.Current_Addons = Pull_Addon_Inventory()
	Handler.Inventory_Storage.Addons.Current_Page = 1
	Handler.Inventory_Storage.Addons.Max_Pages = (math.floor((#Handler.Inventory_Storage.Addons.Current_Addons - 1)/Settings.Addons_Per_Page) + 1)

	-- Display the Page --
	Display_Addons()

	-- Display Page Navigation --
	UI.Inventory_Frames:WaitForChild('Forward').Visible = (Handler.Inventory_Storage.Addons.Max_Pages > 1)
	UI.Inventory_Frames:WaitForChild('Backward').Visible = (Handler.Inventory_Storage.Addons.Max_Pages > 1)

	UI.Inventory_Frames:WaitForChild('PageNum').Text = '<b>' .. Handler.Inventory_Storage.Addons.Current_Page .. ' / </b><font color="#d0d0d0">' .. Handler.Inventory_Storage.Addons.Max_Pages .. '</font>'
	UI.Inventory_Frames:WaitForChild('Title').Text = '<b>INVENTORY</b><font color="#d0d0d0">/ADDONS</font>'

	-- Adjust Visibility --
	Addon_Inventory_Frame.Visible = true
	UI.Inventory_Frames:WaitForChild('Items').Visible = false
	UI.Inventory_Frames:WaitForChild('Perks').Visible = false
	UI.Inventory_Frames:WaitForChild('Offerings').Visible = false
end

function Update_Item_Inventory()
	local Item_Inventory_Frame = UI.Inventory_Frames:WaitForChild('Items')

	if Settings.Items_Per_Page == 0 then -- calculate it

		for _, Item_Slot in pairs(Item_Inventory_Frame:GetChildren()) do
			if not Item_Slot:IsA('Frame') then continue end
			Handler.Inventory_Storage.Items.UI_Contents[tonumber(Item_Slot.Name)] = Item_Slot -- attach to ui
			Settings.Items_Per_Page += 1
		end
	end

	-- Calculate the pages --
	Handler.Inventory_Storage.Items.Current_Items = Pull_Item_Inventory()
	Handler.Inventory_Storage.Items.Current_Page = 1
	Handler.Inventory_Storage.Items.Max_Pages = (math.floor((#Handler.Inventory_Storage.Items.Current_Items - 1)/Settings.Items_Per_Page) + 1)

	-- Display the Page --
	Display_Items()

	-- Display Page Navigation --
	UI.Inventory_Frames:WaitForChild('Forward').Visible = (Handler.Inventory_Storage.Items.Max_Pages > 1)
	UI.Inventory_Frames:WaitForChild('Backward').Visible = (Handler.Inventory_Storage.Items.Max_Pages > 1)

	UI.Inventory_Frames:WaitForChild('PageNum').Text = '<b>' .. Handler.Inventory_Storage.Items.Current_Page .. ' / </b><font color="#d0d0d0">' .. Handler.Inventory_Storage.Items.Max_Pages .. '</font>'
	UI.Inventory_Frames:WaitForChild('Title').Text = '<b>INVENTORY</b><font color="#d0d0d0">/ITEMS</font>'

	-- Adjust Visibility --
	Item_Inventory_Frame.Visible = true
	UI.Inventory_Frames:WaitForChild('Addons').Visible = false
	UI.Inventory_Frames:WaitForChild('Perks').Visible = false
	UI.Inventory_Frames:WaitForChild('Offerings').Visible = false
end

function Update_Offering_Inventory()
	local Offering_Inventory_Frame = UI.Inventory_Frames:WaitForChild('Offerings')

	if Settings.Offerings_Per_Page == 0 then -- calculate it

		for _, Offering_Slot in pairs(Offering_Inventory_Frame:GetChildren()) do
			if not Offering_Slot:IsA('Frame') then continue end
			Handler.Inventory_Storage.Offerings.UI_Contents[tonumber(Offering_Slot.Name)] = Offering_Slot -- attach to ui
			Settings.Offerings_Per_Page += 1
		end
	end

	-- Calculate the pages --
	Handler.Inventory_Storage.Offerings.Current_Offerings = Pull_Offering_Inventory()
	Handler.Inventory_Storage.Offerings.Current_Page = 1
	Handler.Inventory_Storage.Offerings.Max_Pages = (math.floor((#Handler.Inventory_Storage.Offerings.Current_Offerings - 1)/Settings.Offerings_Per_Page) + 1)

	-- Display the Page --
	Display_Offerings()

	-- Display Page Navigation --
	UI.Inventory_Frames:WaitForChild('Forward').Visible = (Handler.Inventory_Storage.Offerings.Max_Pages > 1)
	UI.Inventory_Frames:WaitForChild('Backward').Visible = (Handler.Inventory_Storage.Offerings.Max_Pages > 1)

	UI.Inventory_Frames:WaitForChild('PageNum').Text = '<b>' .. Handler.Inventory_Storage.Offerings.Current_Page .. ' / </b><font color="#d0d0d0">' .. Handler.Inventory_Storage.Offerings.Max_Pages .. '</font>'
	UI.Inventory_Frames:WaitForChild('Title').Text = '<b>INVENTORY</b><font color="#d0d0d0">/OFFERINGS</font>'

	-- Adjust Visibility --
	Offering_Inventory_Frame.Visible = true
	UI.Inventory_Frames:WaitForChild('Items').Visible = false
	UI.Inventory_Frames:WaitForChild('Perks').Visible = false
	UI.Inventory_Frames:WaitForChild('Addons').Visible = false
end

function Increment(Direction : number)

	if Handler.Loadout_Storage.Current_Selection == "Perk" then

		if (Handler.Inventory_Storage.Perks.Current_Page + Direction) <= 0 then
			Handler.Inventory_Storage.Perks.Current_Page = Handler.Inventory_Storage.Perks.Max_Pages
		elseif (Handler.Inventory_Storage.Perks.Current_Page + Direction) > Handler.Inventory_Storage.Perks.Max_Pages then
			Handler.Inventory_Storage.Perks.Current_Page = 1
		else
			Handler.Inventory_Storage.Perks.Current_Page += Direction
		end

		Display_Perks()
	else
		warn(Handler.Loadout_Storage.Current_Selection, 'unsupported!')
	end
end

function Handler:Update()
	Handler.Loadout_Storage.Current_Selection = "Perk"

	Update_Perk_Loadout()

	Update_Item_Loadout()
	Update_Addon_Loadout()
	Update_Offering_Loadout()

	Update_Perk_Inventory() -->> perks boot up first by default

	Update_Information_Frame()

	-- Offering Controls --
	if not Handler.Connections.Offering then

		Handler.Connections.Offering = UI.Offering_Loadout:WaitForChild('Offering'):WaitForChild('Button').MouseButton1Click:Connect(function()

			if Handler.Loadout_Storage.Current_Selection ~= "Offering" then
				Handler.Loadout_Storage.Current_Selection = "Offering"
				Update_Offering_Inventory()
			end
		end)
	end

	-- Item Controls --
	if not Handler.Connections.Item then

		Handler.Connections.Item = UI.Item_Loadout:WaitForChild('Item'):WaitForChild('Button').MouseButton1Click:Connect(function()

			if Handler.Loadout_Storage.Current_Selection ~= "Item" then
				Handler.Loadout_Storage.Current_Selection = "Item"
				Update_Item_Inventory()
			end
		end)
	end


	-- Arrow Controls --
	if not Handler.Connections.Changed["Foward"] then

		Handler.Connections.Changed["Foward"] = UI.Inventory_Frames:WaitForChild('Forward'):WaitForChild('Button').MouseButton1Click:Connect(function()
			Increment(1)
		end)
	end

	if not Handler.Connections.Changed['Backward'] then

		Handler.Connections.Changed["Backward"] = UI.Inventory_Frames:WaitForChild('Backward'):WaitForChild('Button').MouseButton1Click:Connect(function()
			Increment(-1)
		end)
	end
end

return Handler
