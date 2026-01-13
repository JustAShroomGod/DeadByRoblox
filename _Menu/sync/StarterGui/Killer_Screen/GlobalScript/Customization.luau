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
	Data_Template = Modules.Data:GetRaw()[Modules.Data:GetKiller()];
	Loadout_Storage = {
		Current_Selection = "Head";
	},
	Inventory_Storage = {
		Head = {
			Current_Page = 1;
			Max_Pages = 1;
			Current = {};
			UI_Contents = {};
		},
		Torso = {
			Current_Page = 1;
			Max_Pages = 1;
			Current = {};
			UI_Contents = {};
		},
		Weapon = {
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
	for _, Skin_String_Value : StringValue in pairs(Handler.Data_Folder:WaitForChild('Loadout'):WaitForChild('Cosmetic'):WaitForChild('Killer'):GetChildren()) do
		local Skin_Frame, Skin_Module = UI.Loadout_Frames:WaitForChild('Cosmetic'):FindFirstChild(Skin_String_Value.Name), Game_Data:WaitForChild('Cosmetics'):WaitForChild('Killer'):FindFirstChild(Skin_String_Value.Value)
		
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

function Pull_Skin_Inventory(Skin_Type : "Head" | "Weapon" | "Torso") : "Get Catagory::Type that are Currently Active"
	local Skins = {}

	for Skin_Name, Skin_Content in pairs(Handler.Data_Template.Inventory.Cosmetics) do 
		
		
		if Skin_Content[Skin_Type] and Game_Data:WaitForChild('Cosmetics'):WaitForChild('Killer'):FindFirstChild(Skin_Name) then -- has the body part and it is unlocked
			table.insert(Skins, Skin_Name) -- assign tier to it
		end
	end

	-- alphabetize the order --
	table.sort(Skins, function(skin_one, skin_two)
		return skin_one:lower() < skin_two:lower()
	end)

	return Skins
end

function Display_Skin(Skin : "Head" | "Weapon" | "Torso")
	local current_index = -Settings[Skin..'_Per_Page']

	current_index += (Handler.Inventory_Storage[Skin].Current_Page * Settings[Skin..'_Per_Page'])

	--UI.Inventory_Frames:WaitForChild('PageNum').Text = '<b>' .. Handler.Inventory_Storage[Skin].Current_Page .. ' / </b><font color="#d0d0d0">' .. Handler.Inventory_Storage.Addons.Max_Pages .. '</font>'

	for current_slot, slot in pairs(Handler.Inventory_Storage[Skin].UI_Contents) do
		current_index += 1

		if not Handler.Connections.Skin_Inventory[slot] then
			
			
			Handler.Connections.Skin_Inventory[slot] = slot:WaitForChild('Button').MouseButton1Click:Connect(function()
				Modules.Data:EquipCosmetic("Killer", slot:GetAttribute(Skin), {
					Skin
				})
			end)
		end
		
		if Handler.Inventory_Storage[Skin].Current[current_index] then
			--slot:WaitForChild('Title').Text = Handler.Inventory_Storage[Skin].Current[current_index]

			slot:SetAttribute(Skin, Handler.Inventory_Storage[Skin].Current[current_index])
			slot.Visible = true -- just turn it off
		else -- no perk to display here
			slot:WaitForChild('Button'):SetAttribute(Skin, nil)
			slot.Visible = false -- just turn it off
		end
		
		local SkinModule = Game_Data:WaitForChild('Cosmetics'):WaitForChild("Killer"):FindFirstChild(tostring(Handler.Inventory_Storage[Skin].Current[current_index]))

		if SkinModule and slot.Visible then
			SkinModule = require(SkinModule)

			slot:WaitForChild('Inner'):WaitForChild('Name').Text = SkinModule.Set_Name
			slot:WaitForChild('Body').ImageColor3 = SkinModule.Set_Color
			slot:WaitForChild('InnerBody').ImageColor3 = SkinModule.Set_Color
			slot:WaitForChild('Outter').ImageColor3 = SkinModule.Set_Color
		end
	end
end

function Update_Skin_Inventory(Skin : "Head" | "Weapon" | "Torso")
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
		elseif Frame.Name == 'Backward' or Frame.Name == 'Foward' or Frame.Name == 'Page' then
			-- do nothing --
		else
			Frame.Visible = false
		end
	end
end

function Increment(Direction : number)
	
	if Handler.Loadout_Storage.Current_Selection == "Skin" then
		
		if (Handler.Inventory_Storage.Perks.Current_Page + Direction) <= 0 then
			Handler.Inventory_Storage.Perks.Current_Page = Handler.Inventory_Storage.Perks.Max_Pages
		elseif (Handler.Inventory_Storage.Perks.Current_Page + Direction) > Handler.Inventory_Storage.Perks.Max_Pages then
			Handler.Inventory_Storage.Perks.Current_Page = 1
		else
			Handler.Inventory_Storage.Perks.Current_Page += Direction
		end
		
		Display_Skin()
	else
		warn(Handler.Loadout_Storage.Current_Selection, 'unsupported!')
	end
end

function Handler:Update()
	Handler.Loadout_Storage.Current_Selection = "Head"
	
	Handler.Data_Template = Modules.Data:GetRaw()[Modules.Data:GetKiller()];
	
	
	
	Update_Skin_Loadout()
	
	Update_Skin_Inventory('Head') -->> perks boot up first by default
	
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
