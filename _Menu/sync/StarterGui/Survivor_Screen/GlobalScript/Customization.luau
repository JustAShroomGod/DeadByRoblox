local ReplicatedStorage = game:GetService('ReplicatedStorage')

local ModuleStorage, Game_Data = ReplicatedStorage:WaitForChild('Modules'), ReplicatedStorage:WaitForChild('Game_Data')

local Player = game.Players.LocalPlayer

local Custom_Frame = script.Parent.Parent:WaitForChild('Content'):WaitForChild('Customization')
local Modules = {
	Data = require(ModuleStorage:WaitForChild('Data'));
	Hover = require(Player:WaitForChild('PlayerGui'):WaitForChild('HUD'):WaitForChild('Hover_Module'));
}


local UI = {
	Design_Frames = Custom_Frame:WaitForChild('Design');
	Loadout_Frames = Custom_Frame:WaitForChild('Loadout');
	Inventory_Frames = Custom_Frame:WaitForChild('Inventory');
}


local Settings = {
	Pages = {};
	Inactive_Color = Color3.fromRGB(76, 76, 76)
}

local Handler = {
	Data_Folder = Player:WaitForChild('Data');
	Data_Template = Modules.Data:GetRaw().Main;
	Loadout_Storage = {
		Emote_Slot = 'One';
		Current_Selection = "Head";
	},
	Inventory_Storage = {
		Head = {
			Current_Page = 1;
			Max_Pages = 2;
			Current = {};
			UI_Contents = {};
		},
		Torso = {
			Current_Page = 1;
			Max_Pages = 2;
			Current = {};
			UI_Contents = {};
		},
		Legs = {
			Current_Page = 1;
			Max_Pages = 2;
			Current = {};
			UI_Contents = {};
		},
		Emotes = {
			Current_Page = 1;
			Max_Pages = 1;
			Current = {};
			UI_Contents = {};
		},
	},
	Connections = {
		Changed = {};
		Skin_Loadout = {};
		Skin_Inventory = {};
		Emote_Inventory = {};
		Emote_Loadout = {};
		Hover = {
			Enter = {};
			Leave = {};
		};
	}
}


function Update_Skin_Loadout()
	
	for _, Skin_String_Value : StringValue in pairs(Handler.Data_Folder:WaitForChild('Loadout'):WaitForChild('Cosmetic'):WaitForChild('Survivor'):GetChildren()) do
		local Skin_Frame, Skin_Module = UI.Loadout_Frames:WaitForChild('Cosmetic'):FindFirstChild(Skin_String_Value.Name), Game_Data:WaitForChild('Cosmetics'):WaitForChild('Survivor'):FindFirstChild(Skin_String_Value.Value)

		if not Handler.Connections.Changed[Skin_String_Value] then
			Handler.Connections.Changed[Skin_String_Value] = Skin_String_Value.Changed:Connect(Update_Skin_Loadout)
		end
		
		if Skin_Frame and not Handler.Connections.Skin_Loadout[Skin_Frame] then
			
			Handler.Connections.Skin_Loadout[Skin_Frame] = Skin_Frame:WaitForChild('Button').MouseButton1Click:Connect(function()
				
				if Handler.Loadout_Storage.Current_Selection ~= Skin_Frame.Name then
					Handler.Loadout_Storage.Current_Selection = Skin_Frame.Name
					Update_Skin_Inventory(Handler.Loadout_Storage.Current_Selection)
				end
			end)
		end
		
		if Skin_Frame and Skin_Module then
			Skin_Module = require(Skin_Module)

			Skin_Frame:WaitForChild('Inner'):WaitForChild('Name').Text = Skin_String_Value.Value
			Skin_Frame:WaitForChild('Body').ImageColor3 = Skin_Module.Set_Color
			Skin_Frame:WaitForChild('InnerBody').ImageColor3 = Skin_Module.Set_Color
			Skin_Frame:WaitForChild('Outter').ImageColor3 = Skin_Module.Set_Color
		else
			Skin_Frame:WaitForChild('Inner'):WaitForChild('Name').Text = "Unknown"
			Skin_Frame:WaitForChild('Body').ImageColor3 = Settings.Inactive_Color
			Skin_Frame:WaitForChild('InnerBody').ImageColor3 = Settings.Inactive_Color
			Skin_Frame:WaitForChild('Outter').ImageColor3 = Settings.Inactive_Color
		end
	end
end

function Update_Emote_Loadout()

	for _, Emote_String_Value : StringValue in pairs(Handler.Data_Folder:WaitForChild('Loadout'):WaitForChild('Emotes'):GetChildren()) do
		local Emote_Frame, Emote_Module = UI.Loadout_Frames:WaitForChild('Emote'):FindFirstChild(Emote_String_Value.Name), Game_Data:WaitForChild('Emotes'):FindFirstChild(Emote_String_Value.Value)

		if not Handler.Connections.Changed[Emote_String_Value] then
			Handler.Connections.Changed[Emote_String_Value] = Emote_String_Value.Changed:Connect(Update_Emote_Loadout)
		end

		if Emote_Frame and not Handler.Connections.Skin_Loadout[Emote_Frame] then

			Handler.Connections.Skin_Loadout[Emote_Frame] = Emote_Frame:WaitForChild('Button').MouseButton1Click:Connect(function()
				
				Handler.Loadout_Storage.Emote_Slot = Emote_Frame.Name
				
				if Handler.Loadout_Storage.Current_Selection ~= "Emote" then
					Handler.Loadout_Storage.Current_Selection = "Emote"
					Update_Emote_Inventory()
				end
			end)
		end

		if Emote_Frame and Emote_Module then
			Emote_Module = require(Emote_Module)

			Emote_Frame:WaitForChild('Inner'):WaitForChild('Name').Text = Emote_Module.Emote_Name
			Emote_Frame:WaitForChild('Body').ImageColor3 = Emote_Module.Emote_Color
			Emote_Frame:WaitForChild('InnerBody').ImageColor3 = Emote_Module.Emote_Color
			Emote_Frame:WaitForChild('Outter').ImageColor3 = Emote_Module.Emote_Color
		else
			Emote_Frame:WaitForChild('Inner'):WaitForChild('Name').Text = "Unknown"
			Emote_Frame:WaitForChild('Body').ImageColor3 = Settings.Inactive_Color
			Emote_Frame:WaitForChild('InnerBody').ImageColor3 = Settings.Inactive_Color
			Emote_Frame:WaitForChild('Outter').ImageColor3 = Settings.Inactive_Color
		end
	end
end

function Pull_Skin_Inventory(Skin_Type : "Head" | "Legs" | "Torso") : "Get Catagory::Type that are Currently Active"
	local Skins = {}

	for Skin_Name, Skin_Content in pairs(Handler.Data_Template.Inventory.Cosmetics) do 
		
		
		if Skin_Content[Skin_Type] and Game_Data:WaitForChild('Cosmetics'):WaitForChild('Survivor'):FindFirstChild(Skin_Name) then -- has the body part and it is unlocked
			table.insert(Skins, Skin_Name) -- assign tier to it
		end
	end

	-- alphabetize the order --
	table.sort(Skins, function(skin_one, skin_two)
		return skin_one:lower() < skin_two:lower()
	end)

	return Skins
end

function Pull_Emote_Inventory() : "Get Emotes we have unlocked"
	local Emotes = {}

	for Emote_Name, Unlocked in pairs(Handler.Data_Template.Inventory.Emotes) do
		if not Unlocked then continue end
		
		if Game_Data:WaitForChild('Emotes'):FindFirstChild(Emote_Name) then -- do not use out-dated stuff
			table.insert(Emotes, Emote_Name) -- assign tier to it
		end
	end
	
	-- alphabetize the order --
	table.sort(Emotes, function(emote_one, emote_two)
		return emote_one:lower() < emote_two:lower()
	end)

	return Emotes
end

function Display_Skin(Skin : "Head" | "Legs" | "Torso")
	local current_index = -Settings[Skin..'_Per_Page']

	current_index += (Handler.Inventory_Storage[Skin].Current_Page * Settings[Skin..'_Per_Page'])

	--UI.Inventory_Frames:WaitForChild('PageNum').Text = '<b>' .. Handler.Inventory_Storage[Skin].Current_Page .. ' / </b><font color="#d0d0d0">' .. Handler.Inventory_Storage.Addons.Max_Pages .. '</font>'

	for current_slot, slot in pairs(Handler.Inventory_Storage[Skin].UI_Contents) do
		current_index += 1

		if not Handler.Connections.Skin_Inventory[slot] then
			Handler.Connections.Skin_Inventory[slot] = slot:WaitForChild('Button').MouseButton1Click:Connect(function()
				Modules.Data:EquipCosmetic("Survivor", slot:GetAttribute(Skin), {
					Skin
				})
			end)
		end
		
		if Handler.Inventory_Storage[Skin].Current[current_index] then
			--slot:WaitForChild('Inner'):WaitForChild('Name').Text = Handler.Inventory_Storage[Skin].Current[current_index]

			slot:SetAttribute(Skin, Handler.Inventory_Storage[Skin].Current[current_index])
			slot.Visible = true -- just turn it off
		else -- no perk to display here
			slot:WaitForChild('Button'):SetAttribute(Skin, nil)
			slot.Visible = false -- just turn it off
		end

		local SkinModule = Game_Data:WaitForChild('Cosmetics'):WaitForChild("Survivor"):FindFirstChild(tostring(Handler.Inventory_Storage[Skin].Current[current_index]))
		
		if SkinModule and slot.Visible then
			SkinModule = require(SkinModule)

			slot:WaitForChild('Inner'):WaitForChild('Name').Text = SkinModule.Set_Name
			slot:WaitForChild('Body').ImageColor3 = SkinModule.Set_Color
			slot:WaitForChild('InnerBody').ImageColor3 = SkinModule.Set_Color
			slot:WaitForChild('Outter').ImageColor3 = SkinModule.Set_Color
		end
	end
end

function Display_Emotes()
	local current_index = -Settings.Emotes_Per_Page

	current_index += (Handler.Inventory_Storage.Emotes.Current_Page * Settings.Emotes_Per_Page)

	--UI.Inventory_Frames:WaitForChild('PageNum').Text = '<b>' .. Handler.Inventory_Storage.Items.Current_Page .. ' / </b><font color="#d0d0d0">' .. Handler.Inventory_Storage.Items.Max_Pages .. '</font>'
	
	for current_slot, slot in pairs(Handler.Inventory_Storage.Emotes.UI_Contents) do
		current_index += 1

		if not Handler.Connections.Emote_Inventory[slot] then


			Handler.Connections.Emote_Inventory[slot] = slot:WaitForChild('Button').MouseButton1Click:Connect(function()
				--print(slot:GetAttribute('Emote'), Handler.Loadout_Storage.Emote_Slot)
				
				Modules.Data:EquipEmote(slot:GetAttribute("Emote"), Handler.Loadout_Storage.Emote_Slot)
			end)
		end

		if Handler.Inventory_Storage.Emotes.Current[current_index] then -- we have addon, module, + count
			--slot:WaitForChild('Design'):WaitForChild('Addon').Image = Handler.Inventory_Storage.Addons.Current_Addons[current_addon_index][2].Image
			--slot:WaitForChild('Design'):WaitForChild('Amount').Text = Handler.Inventory_Storage.Addons.Current_Addons[current_addon_index][3]
			--slot:WaitForChild('Button'):SetAttribute("Addon", Handler.Inventory_Storage.Addons.Current_Addons[current_addon_index][1])

			--slot:WaitForChild('Inner'):WaitForChild('Name').Text = Handler.Inventory_Storage.Emotes.Current[current_index]

			--[[if Handler.Inventory_Storage[Skin].Current[current_addon_index][3] <= 0 then
				addon_slot:WaitForChild('Design'):WaitForChild('Addon').ImageColor3 = Color3.fromRGB(48, 48, 48)
				addon_slot:WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Settings.Inactive_Color
			else
				addon_slot:WaitForChild('Design'):WaitForChild('Addon').ImageColor3 = Color3.fromRGB(255, 255, 255)
				addon_slot:WaitForChild('Design'):WaitForChild('Color').BackgroundColor3 = Handler.Inventory_Storage.Addons.Current_Addons[current_addon_index][2].Color
			end]]--

			slot:SetAttribute('Emote', Handler.Inventory_Storage.Emotes.Current[current_index])
			slot.Visible = true -- just turn it off
		else -- no perk to display here
			slot:WaitForChild('Button'):SetAttribute('Emote', nil)
			slot.Visible = false -- just turn it off
		end
		

		local Emote_Module = Game_Data:WaitForChild('Emotes'):FindFirstChild(tostring(Handler.Inventory_Storage.Emotes.Current[current_index]))

		if Emote_Module and slot.Visible then
			Emote_Module = require(Emote_Module)

			slot:WaitForChild('Inner'):WaitForChild('Name').Text = Emote_Module.Emote_Name
			slot:WaitForChild('Body').ImageColor3 = Emote_Module.Emote_Color
			slot:WaitForChild('InnerBody').ImageColor3 = Emote_Module.Emote_Color
			slot:WaitForChild('Outter').ImageColor3 = Emote_Module.Emote_Color
		end
	end
end

function Update_Skin_Inventory(Skin : "Head" | "Legs" | "Torso")
	local Skin_Inventory_Frame = UI.Inventory_Frames:FindFirstChild(Skin)
	
	if not Skin_Inventory_Frame then return warn(Skin, 'has no inventory page!') end

	if not Settings[Skin..'_Per_Page'] or Settings[Skin..'_Per_Page'] == 0 then -- calculate it
		Settings[Skin..'_Per_Page'] = 0
		
		for _, Skin_Slot in pairs(Skin_Inventory_Frame:GetChildren()) do
			if not Skin_Slot:IsA('Frame') then continue end
			Handler.Inventory_Storage[Skin].UI_Contents[tonumber(Skin_Slot.Name)] = Skin_Slot -- attach to ui
			Settings[Skin..'_Per_Page'] += 1
		end
	end

	-- Calculate the pages --
	Handler.Inventory_Storage[Skin].Current = Pull_Skin_Inventory(Skin)
	Handler.Inventory_Storage[Skin].Current_Page = 1
	Handler.Inventory_Storage[Skin].Max_Pages = (math.floor((#Handler.Inventory_Storage[Skin].Current - 1)/Settings[Skin..'_Per_Page']) + 1)

	-- Display the Page --
	Display_Skin(Skin)

	-- Display Page Navigation --
	UI.Inventory_Frames:WaitForChild('Forward').Visible = (Handler.Inventory_Storage[Skin].Max_Pages > 1)
	UI.Inventory_Frames:WaitForChild('Backward').Visible = (Handler.Inventory_Storage[Skin].Max_Pages > 1)

	UI.Design_Frames:WaitForChild('Inventory_Type').Text = "<b>INVENTORY/"..Skin:upper()..'</b>'
	UI.Inventory_Frames:WaitForChild('Page'):WaitForChild('Label').Text = '<b>' .. Handler.Inventory_Storage[Skin].Current_Page .. ' / </b><font color="#d0d0d0">' .. Handler.Inventory_Storage[Skin].Max_Pages .. '</font>'

	-- Adjust Visibility --
	
	for _, Frame in pairs(UI.Inventory_Frames:GetChildren()) do
		if not Frame:IsA('Frame') then continue end
		
		if Frame == Skin_Inventory_Frame then
			Frame.Visible = true
		elseif Frame.Name == 'Backward' or Frame.Name == 'Forward' or Frame.Name == 'Page' then
			-- do nothing --
		else
			Frame.Visible = false
		end
	end
end

function Update_Emote_Inventory()
	local Emote_Inventory_Frame = UI.Inventory_Frames:WaitForChild('Emotes')

	if not Settings['Emotes_Per_Page'] or Settings['Emotes_Per_Page'] == 0 then -- calculate it
		Settings['Emotes_Per_Page'] = 0

		for _, Slot in pairs(Emote_Inventory_Frame:GetChildren()) do
			if not Slot:IsA('Frame') then continue end
			Handler.Inventory_Storage.Emotes.UI_Contents[tonumber(Slot.Name)] = Slot -- attach to ui
			Settings['Emotes_Per_Page'] += 1
		end
	end

	-- Calculate the pages --
	Handler.Inventory_Storage['Emotes'].Current = Pull_Emote_Inventory()
	Handler.Inventory_Storage['Emotes'].Current_Page = 1
	Handler.Inventory_Storage['Emotes'].Max_Pages = (math.floor((#Handler.Inventory_Storage['Emotes'].Current - 1)/Settings['Emotes_Per_Page']) + 1)

	-- Display the Page --
	Display_Emotes()

	-- Display Page Navigation --
	UI.Inventory_Frames:WaitForChild('Forward').Visible = (Handler.Inventory_Storage['Emotes'].Max_Pages > 1)
	UI.Inventory_Frames:WaitForChild('Backward').Visible = (Handler.Inventory_Storage['Emotes'].Max_Pages > 1)

	UI.Design_Frames:WaitForChild('Inventory_Type').Text = "<b>INVENTORY/EMOTES</b>"
	UI.Inventory_Frames:WaitForChild('Page'):WaitForChild('Label').Text = '<b>' .. Handler.Inventory_Storage['Emotes'].Current_Page .. ' / </b><font color="#d0d0d0">' .. Handler.Inventory_Storage['Emotes'].Max_Pages .. '</font>'

	-- Adjust Visibility --

	for _, Frame in pairs(UI.Inventory_Frames:GetChildren()) do
		if not Frame:IsA('Frame') then continue end

		if Frame == Emote_Inventory_Frame then
			Frame.Visible = true
		elseif Frame.Name == 'Backward' or Frame.Name == 'Forward' or Frame.Name == 'Page' then
			-- do nothing --
		else
			Frame.Visible = false
		end
	end
end

function Increment(Direction : number)
	local Skin = Handler.Loadout_Storage.Current_Selection
	
	if Handler.Loadout_Storage.Current_Selection == "Head" or Handler.Loadout_Storage.Current_Selection == "Torso" or Handler.Loadout_Storage.Current_Selection == "Legs" then
		
		if (Handler.Inventory_Storage[Skin].Current_Page + Direction) <= 0 then
			Handler.Inventory_Storage[Skin].Current_Page = Handler.Inventory_Storage[Skin].Max_Pages
		elseif (Handler.Inventory_Storage[Skin].Current_Page + Direction) > Handler.Inventory_Storage[Skin].Max_Pages then
			Handler.Inventory_Storage[Skin].Current_Page = 1
		else
			Handler.Inventory_Storage[Skin].Current_Page += Direction
		end
		
		Display_Skin(Skin)
	else
		warn(Handler.Loadout_Storage.Current_Selection, 'unsupported!')
	end
end

function Handler:Update()
	Handler.Loadout_Storage.Current_Selection = "Head"
	Handler.Data_Template = Modules.Data:GetRaw().Main;
	
	Update_Emote_Loadout()
	Update_Skin_Loadout()
	
	Update_Skin_Inventory('Head') -->> perks boot up first by default
	
	-- Arrow Controls --
	if not Handler.Connections.Changed["Forward"] then

		Handler.Connections.Changed["Forward"] = UI.Inventory_Frames:WaitForChild('Forward'):WaitForChild('Button').MouseButton1Click:Connect(function()
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
