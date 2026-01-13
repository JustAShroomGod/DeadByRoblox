local UserInputService = game:GetService('UserInputService')

local Mobile_Layout = script.Parent.Parent.Parent:WaitForChild('Mobile_Layout')
local Window = script.Parent.Parent.Parent

local Keybind_Template, Mobile_Template, Zone_Template = script:WaitForChild('Key_Template'), script:WaitForChild('MobileButton'), script:WaitForChild('Zone_Template')
local Bind_List = script.Parent.Parent:WaitForChild('Binds')

local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local String_Module = require(script:WaitForChild('String_Random'))
local Random_Gen = Random.new()

local Warning_Label = script.Parent.Parent:WaitForChild('WARNING')

local Size_Increments = {0.1, 0.15, 0.2, 0.25, 0.33, .425, 0.5, 0.6, 0.75, 1, 1.5, 2, 3, 5, 10}

local Default_Forbidden_Keys = {
	-- movement controls --
	[Enum.KeyCode.W] = true;
	[Enum.KeyCode.A] = true;
	[Enum.KeyCode.S] = true;
	[Enum.KeyCode.D] = true;
	[Enum.KeyCode.Thumbstick1] = true;
	[Enum.KeyCode.Thumbstick2] = true;
	
	-- hard set controls --
	[Enum.KeyCode.LeftShift] = true;
	[Enum.KeyCode.LeftControl] = true;
	[Enum.KeyCode.Tab] = true;
	
	-- roblox keys --
	[Enum.KeyCode.ButtonStart] = true;
	[Enum.KeyCode.ButtonSelect] = true;
	[Enum.KeyCode.Escape] = true;
	[Enum.KeyCode.BackSlash] = true;
	[Enum.KeyCode.Slash] = true;
	[Enum.UserInputType.Touch] = true;
	[Enum.UserInputType.Gyro] = true;
	[Enum.UserInputType.Focus] = true;
	[Enum.UserInputType.None] = true;
	[Enum.UserInputType.TextInput] = true;
	[Enum.UserInputType.InputMethod] = true;
	[Enum.UserInputType.Accelerometer] = true;
}

local ActionNames = {
	Survivor = {
		["Interact"] = "Perform Action";
		["Interact2"] = "Interact";
		["Interact3"] = "Use Item";
		["Interact10"] = "Perk Action 2";
		["Interact11"] = "Match Overview";
		["Interact4"] = "Perk Action";
		["Interact5"] = "Drop Item";
		["Interact6"] = "Emote 1";
		["Interact7"] = "Emote 2";
		["Secondary_Power"] = "Secondary Power";
	};
	
	Killer = {
		["Interact"] = "Perform Action";
		["Interact2"] = "Attack/Lunge";
		["Interact3"] = "Primary Power";
		["Interact10"] = "Perk Action 2";
		["Interact11"] = "Match Overview";
		["Interact4"] = "Perk Action";
		["Interact5"] = "Drop Survivor";
		["Interact6"] = "Emote 1";
		["Interact7"] = "Emote 2";
		["Secondary_Power"] = "Secondary Power";
	}
}

local Handler = {
	Connections = {};
	Forbidden = {};
}

function GetActionName(side: string, key: string)
	return ActionNames[side][key] or key
end

function DisconnectConnections() : "End Connections"

	for signal, _ in pairs(Handler.Connections) do -- save memory
		Handler.Connections[signal]:Disconnect() Handler.Connections[signal] = nil
	end
end

function FilteredKey(Key : string) : "Returns filtered key name"
	
	Key = string.gsub(Key, "MouseButton", "Mouse ")
	Key = string.gsub(Key, "Button", "")
	Key = string.gsub(Key, "DPad", "DPad ")
	
	return Key
end

function EnummedKey(Key : string) : "Returns filtered key name"
	local IsUserKey, err = pcall(function()
		return Enum.KeyCode[Key]
	end)
	
	if IsUserKey then
		return Enum.KeyCode[Key]
	else
		return Enum.UserInputType[Key]
	end
end

function Handler:GetKeys(Side : string, Platform : string)
	Bind_List.Visible = false
	
	Handler.Forbidden = {}
	
	DisconnectConnections()
	
	for _, UI_Element in pairs(Bind_List:GetChildren()) do
		if UI_Element:IsA('UIListLayout') then continue end
		UI_Element:Remove()
	end
	
	if Platform == "Mobile" then
		return "Mobile"
	else
		local Keys = Data_Module:GetSettings().KEYBINDS -- pulls our up-to-date keybinds

		if Keys[Side] then
			
			if Keys[Side][Platform] then
				Keys = Keys[Side][Platform]
			else
				error(Platform..': does not exist for binds')
			end
		else
			error(Side..': does not exist for binds')
		end
		
		return Keys
	end
end

function Handler:SetKeys(List : "table", Team : "Killer" | "Survivor", Platform)
	local Listening = nil;
	
	for interaction_name, key in pairs(List) do
		local Clone = Keybind_Template:Clone()
		
		Clone.Name = interaction_name
		Clone:WaitForChild('Title_Interaction').Text = GetActionName(Team, interaction_name)
		Clone:WaitForChild('Button'):WaitForChild('Key').Text = FilteredKey(key)
		
		Handler.Forbidden[EnummedKey(key)] = true
		
		Handler.Connections[interaction_name] = Clone:WaitForChild('Button'):WaitForChild('Detector').MouseButton1Click:Connect(function()
			if Listening then return end -- listening to a key press
			Listening = Clone
			
			Clone:WaitForChild('Button'):WaitForChild('Key').Text = "LISTENING FOR KEY"
			
			Handler.Connections["Listening"] = UserInputService.InputBegan:Connect(function(input)
				Handler.Connections["Listening"]:Disconnect() Handler.Connections["Listening"] = nil
				local Valid = true;
				local Inserted_Key = input
				
				if input.KeyCode == Enum.KeyCode.Unknown then
					Inserted_Key = input.UserInputType
				else
					Inserted_Key = input.KeyCode
				end

				if string.match(tostring(Inserted_Key), 'UserInputType') and not string.match(tostring(Inserted_Key), 'MouseButton') then
					Valid = false -- fail since it's a unknown userinput type
				end
				
				if Handler.Forbidden[Inserted_Key] or Default_Forbidden_Keys[Inserted_Key] then
					Valid = false
				end
				
				
				if Valid then
					Inserted_Key = tostring(Inserted_Key)
					Inserted_Key = string.gsub(Inserted_Key, "Enum.KeyCode.", "")
					Inserted_Key = string.gsub(Inserted_Key, "Enum.UserInputType.", "")
					
					Data_Module:Set_Key({
						Interaction = interaction_name;
						Key = Inserted_Key;
						Platform = Platform;
						Team = Team;
					})
					
					Handler.Forbidden[EnummedKey(key)] = nil
					
					key = Inserted_Key -- overwrite key
					
					Handler.Forbidden[EnummedKey(Inserted_Key)] = true -- add to blacklist
					Clone:WaitForChild('Button'):WaitForChild('Key').Text = FilteredKey(Inserted_Key)
					
					task.wait(0.2)
				else
					Warning_Label.Visible = true
					task.wait(2)
					Warning_Label.Visible = false
					Clone:WaitForChild('Button'):WaitForChild('Key').Text = FilteredKey(key)
					task.wait(0.2)
				end
				
				Listening = false
			end)
		end)
		
		Clone.Parent = Bind_List
	end
	
	Bind_List.Visible = true
end

function Handler:OpenLayout(Team : "Killer" | "Survivor") : "Open Editor for Mobile Layout"
	local Keys = Data_Module:GetSettings().KEYBINDS[Team].Mobile -- pulls our up-to-date keybinds
	local Chosen_Button, Last_Button, Slider = nil, nil, nil;
	
	local Current_Finger, LastFinger = nil, nil;
	
	DisconnectConnections()
	
	Window.Visible = true
	
	-- Finger Dragging --
	
	Handler.Connections['Drag_1'] = UserInputService.TouchStarted:Connect(function(finger)
		if Current_Finger then return end
		if not Chosen_Button then return end
		Current_Finger = finger
	end)
	
	Handler.Connections["Drag_2"] = UserInputService.TouchMoved:Connect(function(finger)
		if not Current_Finger or not Chosen_Button then return end -- no finger/button registered
		if finger ~= Current_Finger then return end -- wrong finger
		
		local trueX, trueY = (Chosen_Button.AbsolutePosition.X + Chosen_Button.AbsoluteSize.X/2), (Chosen_Button.AbsoluteSize.Y + Chosen_Button.AbsoluteSize.Y/2)

		-- Convert absolute to scale --
		local Scale = Vector2.new(finger.Position.X, finger.Position.Y)
		Scale = Scale - Chosen_Button.Parent.AbsolutePosition -- offsets the parent
		Scale = Scale/Chosen_Button.Parent.AbsoluteSize -- offsets the size giving us proper scale
		
		Chosen_Button.Position = UDim2.new(Scale.X, 0, Scale.Y, 0)
	end)
	
	Handler.Connections["Drag_3"] = UserInputService.TouchEnded:Connect(function(finger)
		if Current_Finger ~= finger then return end
		
		Chosen_Button = nil
		Slider = nil
		Current_Finger = nil
	end)
	
	-- Switch --
	local Edit_Button = Mobile_Layout:WaitForChild(Team):WaitForChild('Editor'):WaitForChild('Edit')
	
	Handler.Connections["Edit_Mode"] = Edit_Button.MouseButton1Click:Connect(function()

		if Edit_Button.Text == "Layout" and Team == "Killer" then -- switch to camera
			Edit_Button.Text = "Camera"
			Edit_Button.BackgroundColor3 = Color3.fromRGB(11, 37, 122)
		else -- switch to layout
			Edit_Button.Text = "Layout"
			Edit_Button.BackgroundColor3 = Color3.fromRGB(122, 13, 15)
		end

		Mobile_Layout:WaitForChild(Team):WaitForChild('Editor'):WaitForChild('Buttons').Visible = (Edit_Button.Text == "Layout")
		Mobile_Layout:WaitForChild(Team):WaitForChild('Editor'):WaitForChild('Zones').Visible = (Edit_Button.Text == "Camera")

		Mobile_Layout:WaitForChild(Team):WaitForChild('Controls').Visible = (Edit_Button.Text == "Layout")
		Mobile_Layout:WaitForChild(Team):WaitForChild('Deadzone').Visible = (Edit_Button.Text == "Camera")
	end)
	
	-- Saving Layout/Zones --
	Handler.Connections['Finalize'] = Mobile_Layout:WaitForChild(Team):WaitForChild('Editor'):WaitForChild('Close').MouseButton1Down:Connect(function()
		local Results = {
			Team = Team;
			Layout = {};
			Deadzone = {};
		}

		for _, interaction in pairs(Mobile_Layout:WaitForChild(Team):WaitForChild('Controls'):WaitForChild('Layout'):GetChildren()) do
			Results.Layout[interaction.Name] = {
				Position = interaction.Position;
				Size = interaction.Size;
			}
		end

		for _, interaction in pairs(Mobile_Layout:WaitForChild(Team):WaitForChild('Deadzone'):WaitForChild('Layout'):GetChildren()) do
			Results.Deadzone[interaction.Name] = {
				Position = interaction.Position;
				Size = interaction.Size;
			}
		end
		
		Mobile_Layout:WaitForChild(Team):WaitForChild('Controls'):WaitForChild('Layout'):ClearAllChildren()
		Mobile_Layout:WaitForChild(Team):WaitForChild('Deadzone'):WaitForChild('Layout'):ClearAllChildren()

		Mobile_Layout.Visible = false
		Mobile_Layout:WaitForChild(Team).Visible = false

		Window.Visible = true

		Data_Module:Set_Mobile(Results)
	end)
	
	-- Layout Editor --
	Handler.Connections["Button_Up"] = Mobile_Layout:WaitForChild(Team):WaitForChild('Editor'):WaitForChild('Buttons'):WaitForChild('Up').MouseButton1Click:Connect(function(finger)
		if not Last_Button then return end
		local rounded_Size = math.floor(Last_Button.Size.X.Scale * 1000)/1000
		local current_Size = table.find(Size_Increments, rounded_Size)
		
		if not current_Size then
			current_Size = 5
		end
		
		current_Size += 1
		
		if current_Size <= 0 then
			current_Size = #Size_Increments
		elseif current_Size > #Size_Increments then
			current_Size = 1
		end
		
		current_Size = Size_Increments[current_Size]
		
		Last_Button.Size = UDim2.new(current_Size, 0, current_Size, 0)
	end)

	Handler.Connections["Button_Down"] = Mobile_Layout:WaitForChild(Team):WaitForChild('Editor'):WaitForChild('Buttons'):WaitForChild('Down').MouseButton1Click:Connect(function(finger)
		if not Last_Button then return end
		local rounded_Size = math.floor(Last_Button.Size.X.Scale * 1000)/1000
		local current_Size = table.find(Size_Increments, rounded_Size)

		if not current_Size then
			current_Size = 5
		end

		current_Size -= 1

		if current_Size <= 0 then
			current_Size = #Size_Increments
		elseif current_Size > #Size_Increments then
			current_Size = 1
		end

		current_Size = Size_Increments[current_Size]
		
		Last_Button.Size = UDim2.new(current_Size, 0, current_Size, 0)
	end)
	
	for interaction_name, button in pairs(Keys) do
		if not button.Button then continue end
		
		local Clone = Mobile_Template:Clone()
		Clone.Name = interaction_name
		Clone:WaitForChild('Action').Text = GetActionName(Team, interaction_name)
		
		Clone.Size = UDim2.new(button.Size[1], 0, button.Size[2], 0)
		Clone.Position = UDim2.new(button.Position[1], 0, button.Position[2], 0)

		Handler.Connections[interaction_name] = Clone.MouseButton1Down:Connect(function()
			if Chosen_Button then return end -- listening to a key press
			
			Chosen_Button = Clone
			Last_Button = Chosen_Button
			
			Mobile_Layout:WaitForChild(Team):WaitForChild('Editor'):WaitForChild('Title_2').Text = 'Editing: '..Clone:WaitForChild('Action').Text
		end)

		Clone.Parent = Mobile_Layout:WaitForChild(Team):WaitForChild('Controls'):WaitForChild('Layout')
	end
	
	-- Dead Zone Editor --
	local Axis_Button = Mobile_Layout:WaitForChild(Team):WaitForChild('Editor'):WaitForChild('Zones'):WaitForChild('Axis')
	
	Handler.Connections["Button_Edit_Mode"] = Axis_Button.MouseButton1Click:Connect(function()
		
		if Axis_Button.Text == "VERTICAL" then
			Axis_Button.Text = "HORIZONTAL"
		else
			Axis_Button.Text = "VERTICAL"
		end
	end)
	
	Handler.Connections["Delete"] = Mobile_Layout:WaitForChild(Team):WaitForChild('Editor'):WaitForChild('Zones'):WaitForChild('Remove').MouseButton1Click:Connect(function(finger)
		if not Last_Button then return end
		Last_Button:Remove()
		Last_Button = nil
	end)
	
	Handler.Connections["Button_Up_Zone"] = Mobile_Layout:WaitForChild(Team):WaitForChild('Editor'):WaitForChild('Zones'):WaitForChild('Up').MouseButton1Click:Connect(function(finger)
		if not Last_Button then return end
		local Vector_X, Vector_Y = math.floor(Last_Button.Size.X.Scale * 1000)/1000, math.floor(Last_Button.Size.Y.Scale * 1000)/1000
		
		if Axis_Button.Text == "HORIZONTAL" then -- increase X
			local Current_Size = table.find(Size_Increments, Vector_X)

			if not Current_Size then Current_Size = 5 end
			Current_Size += 1

			if Current_Size <= 0 then
				Current_Size = #Size_Increments
			elseif Current_Size > #Size_Increments then
				Current_Size = 1
			end

			Vector_X = Size_Increments[Current_Size]
		else -- increase Y
			local Current_Size = table.find(Size_Increments, Vector_Y)

			if not Current_Size then Current_Size = 5 end
			Current_Size += 1

			if Current_Size <= 0 then
				Current_Size = #Size_Increments
			elseif Current_Size > #Size_Increments then
				Current_Size = 1
			end

			Vector_Y = Size_Increments[Current_Size]
		end
		
		Last_Button.Size = UDim2.new(Vector_X, 0, Vector_Y, 0)
	end)

	Handler.Connections["Button_Down_Zone"] = Mobile_Layout:WaitForChild(Team):WaitForChild('Editor'):WaitForChild('Zones'):WaitForChild('Down').MouseButton1Click:Connect(function(finger)
		if not Last_Button then return end
		local Vector_X, Vector_Y = math.floor(Last_Button.Size.X.Scale * 1000)/1000, math.floor(Last_Button.Size.Y.Scale * 1000)/1000

		if Axis_Button.Text == "HORIZONTAL" then -- increase X
			local Current_Size = table.find(Size_Increments, Vector_X)

			if not Current_Size then Current_Size = 5 end
			Current_Size -= 1

			if Current_Size <= 0 then
				Current_Size = #Size_Increments
			elseif Current_Size > #Size_Increments then
				Current_Size = 1
			end

			Vector_X = Size_Increments[Current_Size]
		else -- increase Y
			local Current_Size = table.find(Size_Increments, Vector_Y)

			if not Current_Size then Current_Size = 5 end
			Current_Size -= 1

			if Current_Size <= 0 then
				Current_Size = #Size_Increments
			elseif Current_Size > #Size_Increments then
				Current_Size = 1
			end

			Vector_Y = Size_Increments[Current_Size]
		end

		Last_Button.Size = UDim2.new(Vector_X, 0, Vector_Y, 0)
	end)
	
	local function ConnectDraggableZone(Zone : TextButton)
		
		Handler.Connections[Zone.Name] = Zone.MouseButton1Down:Connect(function()
			if Chosen_Button then return end -- listening to a key press

			Chosen_Button = Zone
			Last_Button = Chosen_Button

			Mobile_Layout:WaitForChild(Team):WaitForChild('Editor'):WaitForChild('Title_2').Text = 'Editing: '..Zone.Name
		end)
	end
	
	Handler.Connections["Add"] = Mobile_Layout:WaitForChild(Team):WaitForChild('Editor'):WaitForChild('Zones'):WaitForChild('Add').MouseButton1Click:Connect(function(finger)
		local New_Button = Zone_Template:Clone()
		New_Button.Name = String_Module:GetString(2)..tostring(Random_Gen:NextInteger(1000000, 9999999))
		New_Button.Text = New_Button.Name

		New_Button.Size = UDim2.new(Size_Increments[5], 0, Size_Increments[5], 0)
		New_Button.AnchorPoint = Vector2.new(0.5, 0.5)
		New_Button.Position = UDim2.new(0.5, 0, 0.5, 0)

		New_Button.Parent = Mobile_Layout:WaitForChild(Team):WaitForChild('Deadzone'):WaitForChild('Layout')
		
		ConnectDraggableZone(New_Button)
		
		Last_Button = New_Button
	end)
	
	for zone_name, zone_data in pairs(Keys.Deadzones) do

		local Clone = Zone_Template:Clone()
		Clone.Name = zone_name
		Clone.Text = zone_name

		Clone.Size = UDim2.new(zone_data.Size[1], 0, zone_data.Size[2], 0)
		Clone.Position = UDim2.new(zone_data.Position[1], 0, zone_data.Position[2], 0)
		
		ConnectDraggableZone(Clone)

		Clone.Parent = Mobile_Layout:WaitForChild(Team):WaitForChild('Deadzone'):WaitForChild('Layout')
	end
	
	-- Starting Window --
	Edit_Button.Text = "Layout"
	Edit_Button.BackgroundColor3 = Color3.fromRGB(122, 13, 15)
	
	Mobile_Layout:WaitForChild(Team):WaitForChild('Editor'):WaitForChild('Buttons').Visible = true -- start on
	Mobile_Layout:WaitForChild(Team):WaitForChild('Editor'):WaitForChild('Zones').Visible = false -- start off

	Mobile_Layout:WaitForChild(Team):WaitForChild('Controls').Visible = true -- start on
	Mobile_Layout:WaitForChild(Team):WaitForChild('Deadzone').Visible = false -- start off
	
	Mobile_Layout:WaitForChild(Team):WaitForChild('Editor'):WaitForChild('Edit').Visible = (Team == "Killer")
	
	Mobile_Layout:WaitForChild(Team).Visible = true
	Mobile_Layout.Visible = true
end


return Handler
