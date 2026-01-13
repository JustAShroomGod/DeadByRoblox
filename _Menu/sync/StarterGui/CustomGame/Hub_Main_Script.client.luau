local ReplicatedStorage = game.ReplicatedStorage

local Player = game.Players.LocalPlayer
local ServerMenu = Player.PlayerGui.CustomGame
local ChooseBand = Player.PlayerGui:WaitForChild('ChooseBand')

local Map_Listing = require(script:WaitForChild('Custom_Maps'))
local Mode_Listing = require(script:WaitForChild('Custom_Modes'))

local Stored = {
	Lobby_Kick_Buttons = {};
	Lobby_Join_Buttons = {};
	Server_Join_Buttons = {};
}

local Menus = {
	Creator = ServerMenu.Creator;
	Browser = ServerMenu.Browser;
	Hub = ServerMenu.Hub;
	Lobby = ServerMenu.Lobby_Viewer;
	Custom_Creator = ServerMenu.Game_Creator;
	Custom_Joiner = ServerMenu.Custom_Browser;
	Queue = ServerMenu.Queue_Info
}

local Remotes = {
	SWF = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('SWF_Event');
	Request_Server = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('RequestTestServer');
	Join_Server = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Join_Custom');
}

local Descriptions = {
	["Create"] = {"<b>Survive with Friends</b>",  "\n Play together with your Friends and try to survive the Killer."},
	["Join"] = {"<b>Join Party</b>", "\n Join a friends party to Play with them!"},
	["Server_Create"] = {"<b>Create a Custom Game</b>", "\n Create a Custom game to Play against your friends!"},
	["Server_Join"] = {"<b>Join a Custom Game</b>", "\n View the Custom games available to join."},
}

function FindSwf(Player : Player) : Configuration | nil

	for _, swf_lobby in pairs(ReplicatedStorage:WaitForChild('SWF'):GetChildren()) do

		for _, survivor in pairs(swf_lobby:GetChildren()) do

			if survivor.Name == Player.Name then
				return swf_lobby
			end
		end
	end
end

function Display_Menu(Menu : Instance)
	
	for _, menu in pairs(Menus) do
		
		if menu == Menu then
			menu.Visible = true
		else
			menu.Visible = false
		end
	end
end
--
function Display_Queue(swf_lobby)
	Display_Menu(Menus.Queue)
	workspace:WaitForChild('Camera'):WaitForChild('SWFBlur').Enabled = false
	
	local length = workspace:GetAttribute("Longest_Queue")
	
	if not length then
		length = 3 * 60
	end
	
	if swf_lobby then
		local our_time_waiting = (workspace:GetServerTimeNow() - swf_lobby:GetAttribute('TIME_STAMP'))

		length = tonumber(length) + 60
		
		if our_time_waiting >= length then
			Menus.Queue.Text = "<b> QUEUED : "..'2'.." MIN REMAINING </b>"
		else
			Menus.Queue.Text = "<b> QUEUED : "..math.floor(((length - our_time_waiting) + 60)/60).." MIN REMAINING </b>"
		end
	else
		Menus.Queue.Text = "<b> QUEUED : "..'2'.." MIN REMAINING </b>"
	end
end

--
function Update_Creator()
	Menus.Creator.Options.Option_Friend:WaitForChild('Button'):WaitForChild('Display').Text = if Stored.Party.Friend then "- TRUE" else "- FALSE"
	Menus.Creator.Options.Option_Friend:WaitForChild('Button'):WaitForChild('Display').TextColor3 = if Stored.Party.Friend then Color3.fromRGB(63, 255, 42) else Color3.fromRGB(255, 0, 0)

	Menus.Creator.Options.Option_Password:WaitForChild('Password').Text = if Stored.Party.Password then Stored.Party.Password else ""
	Menus.Creator.Options.Option_Password:WaitForChild('Password'):WaitForChild('Display').Text = if Stored.Party.Password then "- TRUE" else "- FALSE"
	Menus.Creator.Options.Option_Password:WaitForChild('Password'):WaitForChild('Display').TextColor3 = if Stored.Party.Password then Color3.fromRGB(63, 255, 42) else Color3.fromRGB(255, 0, 0)
end
--
function Update_Game_Creator()
	Menus.Custom_Creator.Options.Option_Friend:WaitForChild('Button'):WaitForChild('Display').Text = if Stored.Custom.Friend then "- TRUE" else "- FALSE"
	Menus.Custom_Creator.Options.Option_Friend:WaitForChild('Button'):WaitForChild('Display').TextColor3 = if Stored.Custom.Friend then Color3.fromRGB(63, 255, 42) else Color3.fromRGB(255, 0, 0)

	Menus.Custom_Creator.Options.Option_Password:WaitForChild('Password').Text = if Stored.Custom.Password then Stored.Custom.Password else ""
	Menus.Custom_Creator.Options.Option_Password:WaitForChild('Password'):WaitForChild('Display').Text = if Stored.Custom.Password then "- TRUE" else "- FALSE"
	Menus.Custom_Creator.Options.Option_Password:WaitForChild('Password'):WaitForChild('Display').TextColor3 = if Stored.Custom.Password then Color3.fromRGB(63, 255, 42) else Color3.fromRGB(255, 0, 0)
	
	Menus.Custom_Creator.Options.Option_Map:WaitForChild('Button'):WaitForChild('Display').Text = if Stored.Custom.Map then "- "..Stored.Custom.Map else "- RANDOM"
	Menus.Custom_Creator.Options.Option_Mode:WaitForChild('Button'):WaitForChild('Display').Text = if Stored.Custom.Mode then "- "..Stored.Custom.Mode else "- Normal"
end

function GetNextMap(current_map)
	current_map = string.gsub(current_map, '- ', "")

	print(current_map)
	
	local curr_index = table.find(Map_Listing, current_map)
	
	if not curr_index then
		curr_index = 1
	end
	
	if (curr_index + 1) > #Map_Listing then
		curr_index = 1
	else
		curr_index += 1
	end
	
	if Map_Listing[curr_index] == "RANDOM" then
		return nil
	else
		return Map_Listing[curr_index]
	end
end

function GetNextMode(current_mode)
	current_mode = string.gsub(current_mode, '- ', "")

	local curr_index = table.find(Mode_Listing, current_mode)
	
	if not curr_index then
		curr_index = 1
	end

	if (curr_index + 1) > #Mode_Listing then
		curr_index = 1
	else
		curr_index += 1
	end

	if Mode_Listing[curr_index] == "Normal" then
		return nil
	else
		return Mode_Listing[curr_index]
	end
end
--
function Craft_Lobby_Template(User : string) : Instance
	local New_Template = Menus.Lobby.Prefab:WaitForChild('Template'):Clone()
	New_Template.Name = User
	
	New_Template:WaitForChild('User_Name').Text = User .. ' - '
	New_Template.Visible = true
	
	return New_Template
end

function Update_Lobby()
	if Stored.Lobby_Connection then Stored.Lobby_Connection:Disconnect() Stored.Lobby_Connection = nil end
	local Stored_Swf = nil
	
	for index, _ in pairs(Stored.Lobby_Kick_Buttons) do -- clean up memory
		Stored.Lobby_Kick_Buttons[index]:Disconnect()
		Stored.Lobby_Kick_Buttons[index] = nil
	end

	game:GetService('TeleportService'):SetTeleportSetting("MatchmakingData", {"Survivor"})
	game:GetService('TeleportService'):SetTeleportSetting("GlobalGameContext", "in_game_survivor")
	
	local run_solo = false
	Stored.Lobby_Connection = game:GetService('RunService').Heartbeat:Connect(function()
		if not Stored_Swf then
			Stored_Swf = FindSwf(Player)
		end

		if not Stored_Swf or run_solo then coroutine.yield() return end
		run_solo = true
		
		if Stored_Swf and Stored_Swf.Parent and Stored_Swf:FindFirstChild(Player.Name) then -- still exist and we are still part of party
			--print('still processing')
			
			-- remove old users --
			for _, user in pairs(Menus.Lobby.Players:GetChildren()) do
				if not user:IsA('Frame') then continue end
				
				if not Stored_Swf:FindFirstChild(user.Name) then
					user:Remove() -- not in our swf remove them
				end
			end
			
			Menus.Lobby:WaitForChild('Title').Text = Stored_Swf.Name.."'s Party"
			
			if Stored_Swf:GetAttribute("QUEUED") then
				Display_Queue(Stored_Swf)
			else
				if Stored_Swf.Name == Player.Name  then -- owner control
					Menus.Lobby.Start.Visible = if not Stored_Swf:GetAttribute("QUEUED") then true else false

					-- add in new users --
					for _, user in pairs(Stored_Swf:GetChildren()) do

						if not Menus.Lobby.Players:FindFirstChild(user.Name) then
							local new_user = Craft_Lobby_Template(user.Name)

							if new_user.Name == Player.Name then
								new_user:WaitForChild('Kick'):Remove()
								new_user:WaitForChild('User_Name').Text = user.Name
							else

								Stored.Lobby_Kick_Buttons[user.Name] = new_user:WaitForChild('Kick').MouseButton1Click:Connect(function()
									Remotes.SWF:FireServer("Kick", user)
								end)
							end

							new_user.Parent = Menus.Lobby.Players
						end
					end
				else -- viewier control
					Menus.Lobby.Start.Visible = false

					-- add in new users --
					for _, user in pairs(Stored_Swf:GetChildren()) do

						if not Menus.Lobby.Players:FindFirstChild(user.Name) then
							local new_user = Craft_Lobby_Template(user.Name)

							new_user:WaitForChild('Kick'):Remove() -- do not need this

							new_user.Parent = Menus.Lobby.Players
						end
					end
				end
			end
		else
			print('Collapsing loop!')
			if Stored.Lobby_Connection then Stored.Lobby_Connection:Disconnect() Stored.Lobby_Connection = nil end
			Display_Menu(Menus.Hub)
		end
		
		run_solo = false
	end)
end
--
function Disconnect_Join()
	if Stored.Lobbies_Connection then Stored.Lobbies_Connection:Disconnect() Stored.Lobbies_Connection = nil end
	if Stored.Password_Confirm then Stored.Password_Confirm:Disconnect() Stored.Password_Confirm = nil end
	if Stored.Password_Close then Stored.Password_Close:Disconnect() Stored.Password_Close = nil end

	for index, _ in pairs(Stored.Lobby_Join_Buttons) do -- clean up memory
		Stored.Lobby_Join_Buttons[index]:Disconnect()
		Stored.Lobby_Join_Buttons[index] = nil
	end
	
	for _, lobby in pairs(Menus.Browser:WaitForChild('Lobbies'):GetChildren()) do
		if not lobby:IsA('Frame') then continue end
		lobby:Remove()
	end
end

function Craft_Join_Template(lobby : Configuration) : Instance
	local New_Template = Menus.Browser.Prefab:WaitForChild('Template'):Clone()
	New_Template.Name = lobby.Name

	New_Template:WaitForChild('Party_Title').Text = lobby.Name .. "'s party - "..tostring(#lobby:GetChildren())..'/4'
	New_Template.Visible = true
	
	if Stored.Lobby_Join_Buttons[lobby.Name] then
		Stored.Lobby_Join_Buttons[lobby.Name]:Disconnect()
	end
	
	if lobby:GetAttribute("Password") then
		New_Template:WaitForChild('Join').Text = 'PASSWORD PROTECTED'
		New_Template:WaitForChild('Join').BackgroundColor3 = Color3.fromRGB(255, 159, 24)
		
		Stored.Lobby_Join_Buttons[lobby.Name] = New_Template:WaitForChild('Join').MouseButton1Click:Connect(function()
			Menus.Browser.Password.Visible = true -- display pop up
			
			Stored.Password_Confirm = Menus.Browser.Password:WaitForChild('Confirm').MouseButton1Click:Connect(function()
				
				if lobby:GetAttribute("Password") == Menus.Browser.Password:WaitForChild('Password').Text then
					Remotes.SWF:FireServer("Join", lobby)
					if Stored.Password_Confirm then Stored.Password_Confirm:Disconnect() Stored.Password_Confirm = nil end
					if Stored.Password_Close then Stored.Password_Close:Disconnect() Stored.Password_Close = nil end
					
					Menus.Browser.Password.Visible = false
					
					Disconnect_Join()

					Update_Lobby() -->> constant fire lobby
					
					Display_Menu(Menus.Lobby)
				end
			end)
			
			Stored.Password_Close = Menus.Browser.Password:WaitForChild('Close').MouseButton1Click:Connect(function()
				if Stored.Password_Confirm then Stored.Password_Confirm:Disconnect() Stored.Password_Confirm = nil end
				if Stored.Password_Close then Stored.Password_Close:Disconnect() Stored.Password_Close = nil end
				
				Menus.Browser.Password.Visible = false
			end)
		end)
	else

		Stored.Lobby_Join_Buttons[lobby.Name] = New_Template:WaitForChild('Join').MouseButton1Click:Connect(function()
			Remotes.SWF:FireServer("Join", lobby)
			Disconnect_Join()

			Update_Lobby() -->> constant fire lobby
			
			Display_Menu(Menus.Lobby)
		end)
	end
	
	New_Template.Parent = Menus.Browser.Lobbies
	
	return New_Template
end

function Update_Lobbies()
	if Stored.Lobbies_Connection then Stored.Lobbies_Connection:Disconnect() Stored.Lobbies_Connection = nil end

	for index, _ in pairs(Stored.Lobby_Join_Buttons) do -- clean up memory
		Stored.Lobby_Join_Buttons[index]:Disconnect()
		Stored.Lobby_Join_Buttons[index] = nil
	end
	
	local run_solo = false
	Stored.Lobbies_Connection = game:GetService('RunService').Heartbeat:Connect(function()
		if run_solo then coroutine.yield() return end
		run_solo = true
		
		-- remove old lobbies --
		for _, lobby in pairs(Menus.Browser:WaitForChild('Lobbies'):GetChildren()) do
			if not lobby:IsA('Frame') then continue end
			
			if not ReplicatedStorage:WaitForChild('SWF'):FindFirstChild(lobby.Name) or #ReplicatedStorage:WaitForChild('SWF'):WaitForChild(lobby.Name):GetChildren() >= 4 then
				lobby:Remove() -- no longer a lobby do not try
			end
		end
		
		-- add in new lobbies --
		for _, lobby in pairs(ReplicatedStorage:WaitForChild('SWF'):GetChildren()) do
			if not lobby:IsA('Configuration') then continue end
			if #lobby:GetChildren() >= 4 then continue end -- too many
			if Menus.Browser:WaitForChild('Lobbies'):FindFirstChild(lobby.Name) then continue end -- already have it
			if lobby:GetAttribute("QUEUED") then continue end
			if lobby:GetAttribute("NOT_FRIEND") then continue end -- to prevent future yeilds
			
			if lobby:GetAttribute("Friend_Only") then
				local desired_user = game.Players:FindFirstChild(lobby.Name)
				
				if desired_user and Player:IsFriendsWith(desired_user.UserId) then
					Craft_Join_Template(lobby)
				else
					lobby:SetAttribute('NOT_FRIEND', true) -- prevent relooping/yeild
				end
			else -- not made, but can still be pass protected
				Craft_Join_Template(lobby)
			end
		end
		
		-- update lobbies --
		for _, lobby in pairs(Menus.Browser:WaitForChild('Lobbies'):GetChildren()) do
			if not lobby:IsA('Frame') then continue end
			local raw_lobby = ReplicatedStorage:WaitForChild('SWF'):WaitForChild(lobby.Name)
			
			lobby:WaitForChild('Party_Title').Text = raw_lobby.Name .. "'s party - "..tostring(#raw_lobby:GetChildren())..'/4'
		end
	end)
	
	run_solo = false
end
--
function Disconnect_Join_2()
	if Stored.Servers_Connection then Stored.Servers_Connection:Disconnect() Stored.Servers_Connection = nil end
	if Stored.Password_Confirm_2 then Stored.Password_Confirm_2:Disconnect() Stored.Password_Confirm_2 = nil end
	if Stored.Password_Close_2 then Stored.Password_Close_2:Disconnect() Stored.Password_Close_2 = nil end

	for index, _ in pairs(Stored.Server_Join_Buttons) do -- clean up memory
		Stored.Server_Join_Buttons[index]:Disconnect()
		Stored.Server_Join_Buttons[index] = nil
	end

	for _, lobby in pairs(Menus.Custom_Joiner:WaitForChild('Lobbies'):GetChildren()) do
		if not lobby:IsA('Frame') then continue end
		lobby:Remove()
	end
end

function Display_Server_Response(todisplay)
	Menus.Custom_Joiner.Lobbies.Visible = not todisplay
	Menus.Custom_Joiner.Hub.Visible = not todisplay
	Menus.Custom_Joiner.Title.Visible = not todisplay
	--Menus.Custom_Joiner.Password.Visible = not todisplay
	Menus.Custom_Joiner.Server_Response.Visible = todisplay
end

function Craft_Join_Template_2(lobby : Configuration) : Instance
	local desired_lobby = lobby.Name
	
	local New_Template = Menus.Custom_Joiner.Prefab:WaitForChild('Template'):Clone()
	New_Template.Name = lobby.Name

	New_Template:WaitForChild('Server_Title').Text = game.Players:GetNameFromUserIdAsync(tonumber(lobby.Name)) .. "'s Server"
	New_Template.Visible = true

	New_Template:WaitForChild('Server_Map').Text = "Map - " .. lobby:GetAttribute("Map")

	if Stored.Server_Join_Buttons[lobby.Name] then
		Stored.Server_Join_Buttons[lobby.Name]:Disconnect()
	end

	if lobby:GetAttribute("Password") then
		New_Template:WaitForChild('Join').Text = 'PASSWORD PROTECTED'
		New_Template:WaitForChild('Join').BackgroundColor3 = Color3.fromRGB(255, 159, 24)

		Stored.Server_Join_Buttons[lobby.Name] = New_Template:WaitForChild('Join').MouseButton1Click:Connect(function()
			Menus.Custom_Joiner.Password.Visible = true -- display pop up

			Stored.Password_Confirm_2 = Menus.Custom_Joiner.Password:WaitForChild('Confirm').MouseButton1Click:Connect(function()

				if lobby:GetAttribute("Password") == Menus.Custom_Joiner.Password:WaitForChild('Password').Text then
					--Remotes.SWF:FireServer("Join", lobby)
					Display_Server_Response(true)
					Menus.Custom_Joiner.Password.Visible = false

					print('Send Request to Join Server')

					if Remotes.Join_Server:InvokeServer(desired_lobby) then
						Menus.Custom_Joiner.Server_Response.Text = "Server Accepted Request to Join: Teleporting..."
						Disconnect_Join()
						if Stored.Password_Confirm_2 then Stored.Password_Confirm_2:Disconnect() Stored.Password_Confirm_2 = nil end
						if Stored.Password_Close_2 then Stored.Password_Close_2:Disconnect() Stored.Password_Close_2 = nil end
					else
						Menus.Custom_Joiner.Server_Response.Text = "Server Rejected our Request to Join."
						task.wait(1.25)
						Display_Server_Response(false)
						Menus.Custom_Joiner.Server_Response.Text = "Awaiting Server Response..."
						Menus.Custom_Joiner.Password.Visible = true
					end
					
					--Update_Lobby() -->> constant fire lobby

					--Display_Menu(Menus.Lobby)
				end
			end)

			Stored.Password_Close_2 = Menus.Custom_Joiner.Password:WaitForChild('Close').MouseButton1Click:Connect(function()
				if Stored.Password_Confirm_2 then Stored.Password_Confirm_2:Disconnect() Stored.Password_Confirm_2 = nil end
				if Stored.Password_Close_2 then Stored.Password_Close_2:Disconnect() Stored.Password_Close_2 = nil end

				Menus.Custom_Joiner.Password.Visible = false
			end)
		end)
	else

		Stored.Server_Join_Buttons[lobby.Name] = New_Template:WaitForChild('Join').MouseButton1Click:Connect(function()
			Display_Server_Response(true)

			print('Send Request to Join Server')
			
			if Remotes.Join_Server:InvokeServer(desired_lobby) then
				Menus.Custom_Joiner.Server_Response.Text = "Server Accepted Request to Join: Teleporting..."
				Disconnect_Join()
			else
				Menus.Custom_Joiner.Server_Response.Text = "Server Rejected our Request to Join."
				task.wait(1.25)
				Display_Server_Response(false)
			end
			
			--Remotes.SWF:FireServer("Join", lobby)

			--Update_Lobby() -->> constant fire lobby

			--Display_Menu(Menus.Lobby)
		end)
	end

	New_Template.Parent = Menus.Custom_Joiner.Lobbies

	return New_Template
end

function Update_Servers()
	if Stored.Servers_Connection then Stored.Servers_Connection:Disconnect() Stored.Servers_Connection = nil end

	for index, _ in pairs(Stored.Server_Join_Buttons) do -- clean up memory
		Stored.Server_Join_Buttons[index]:Disconnect()
		Stored.Server_Join_Buttons[index] = nil
	end
	
	local run_solo = false
	Stored.Servers_Connection = game:GetService('RunService').Heartbeat:Connect(function()
		if run_solo then coroutine.yield() return end
		run_solo = true
		
		-- remove old lobbies --
		for _, lobby in pairs(Menus.Custom_Joiner:WaitForChild('Lobbies'):GetChildren()) do
			if not lobby:IsA('Frame') then continue end

			if not ReplicatedStorage:WaitForChild('SERVERS'):FindFirstChild(lobby.Name) then
				lobby:Remove() -- no longer a lobby do not try
			end
		end

		-- add in new lobbies --
		for _, lobby in pairs(ReplicatedStorage:WaitForChild('SERVERS'):GetChildren()) do
			if not lobby:IsA('Configuration') then continue end
			if Menus.Custom_Joiner:WaitForChild('Lobbies'):FindFirstChild(lobby.Name) then continue end -- already have it
			if lobby:GetAttribute("NOT_FRIEND") then continue end -- to prevent future yeilds

			if lobby:GetAttribute("Friend_Only") then

				if Player:IsFriendsWith(tonumber(lobby.Name)) then
					Craft_Join_Template_2(lobby)
				else
					lobby:SetAttribute('NOT_FRIEND', true) -- prevent relooping/yeild
				end
			else -- not made, but can still be pass protected
				Craft_Join_Template_2(lobby)
			end
		end

		-- update lobbies --
		for _, lobby in pairs(Menus.Custom_Joiner:WaitForChild('Lobbies'):GetChildren()) do
			if not lobby:IsA('Frame') then continue end
			local raw_lobby = ReplicatedStorage:WaitForChild('SERVERS'):WaitForChild(lobby.Name)
			
			-->> Update Server Information Here << --
			--lobby:WaitForChild('Party_Title').Text = raw_lobby.Name .. "'s Server - "..tostring(#raw_lobby:GetChildren())
		end
		
		run_solo = false
	end)
end

-- Buttons --
-->> custom game creation
Menus.Hub.Server_Create.MouseButton1Click:Connect(function()
	Stored.Custom = {
		Password = nil;
		Map = nil;
		Mode = nil;
		Friend = false;
	}
	
	Update_Game_Creator()
	Display_Menu(Menus.Custom_Creator)
end)

Menus.Custom_Creator.Hub.MouseButton1Click:Connect(function()
	Display_Menu(Menus.Hub)
end)

Menus.Custom_Creator.Options.Option_Friend:WaitForChild('Button').MouseButton1Click:Connect(function()
	Stored.Custom.Friend = not Stored.Custom.Friend
	Update_Game_Creator()
end)

Menus.Custom_Creator.Options.Option_Password:WaitForChild('Password').FocusLost:Connect(function()
	Stored.Custom.Password = if Menus.Custom_Creator.Options.Option_Password:WaitForChild('Password').Text ~= "" and Menus.Custom_Creator.Options.Option_Password:WaitForChild('Password').Text ~= " " then Menus.Custom_Creator.Options.Option_Password:WaitForChild('Password').Text else nil
	Update_Game_Creator()
end)

Menus.Custom_Creator.Options.Option_Map:WaitForChild('Button').MouseButton1Click:Connect(function()
	Stored.Custom.Map = GetNextMap(Menus.Custom_Creator.Options.Option_Map:WaitForChild('Button'):WaitForChild('Display').Text)
	
	Update_Game_Creator()
end)

Menus.Custom_Creator.Options.Option_Mode:WaitForChild('Button').MouseButton1Click:Connect(function()
	Stored.Custom.Mode = GetNextMode(Menus.Custom_Creator.Options.Option_Mode:WaitForChild('Button'):WaitForChild('Display').Text)

	Update_Game_Creator()
end)

Menus.Custom_Creator.Create.MouseButton1Click:Connect(function()
	Remotes.Request_Server:FireServer("Create", Stored.Custom) -->> blast party info to server

	--Update_Lobby() -->> constant fire lobby
	warn('Wait for us to teleport into our server!')
	script.Parent.Enabled = false -- so we can't spam join
	--Display_Menu(Menus.Lobby)
end)

-->> party creation
Menus.Hub.Create.MouseButton1Click:Connect(function()
	Stored.Party = {
		Password = nil;
		Friend = false;
	}
	
	Update_Creator()
	Display_Menu(Menus.Creator)
end)

Menus.Creator.Hub.MouseButton1Click:Connect(function()
	Display_Menu(Menus.Hub)
end)

Menus.Creator.Options.Option_Friend:WaitForChild('Button').MouseButton1Click:Connect(function()
	Stored.Party.Friend = not Stored.Party.Friend
	Update_Creator()
end)

Menus.Creator.Options.Option_Password:WaitForChild('Password').FocusLost:Connect(function()
	Stored.Party.Password = if Menus.Creator.Options.Option_Password:WaitForChild('Password').Text ~= "" and Menus.Creator.Options.Option_Password:WaitForChild('Password').Text ~= " " then Menus.Creator.Options.Option_Password:WaitForChild('Password').Text else nil
	Update_Creator()
end)

Menus.Creator.Create.MouseButton1Click:Connect(function()
	Remotes.SWF:FireServer("Create", Stored.Party) -->> blast party info to server
	
	Update_Lobby() -->> constant fire lobby
	
	Display_Menu(Menus.Lobby)
end)

-->> lobby viewer/viewing
Menus.Lobby.Start.MouseButton1Click:Connect(function()
	Remotes.Request_Server:FireServer("Normal", "SWF")
	Menus.Lobby.Start.Visible = false
	Menus.Lobby.Hub.Visible = false
	print('Start our Server!')
end)

Menus.Lobby.Hub.MouseButton1Click:Connect(function()
	Remotes.SWF:FireServer("Leave")
	Display_Menu(Menus.Hub)
end)

-->> lobby joining
Menus.Hub.Join.MouseButton1Click:Connect(function()
	Display_Menu(Menus.Browser)
	Update_Lobbies()
end)

Menus.Browser.Hub.MouseButton1Click:Connect(function()
	Disconnect_Join()
	Display_Menu(Menus.Hub)
end)

Menus.Hub.Separator.Back.Button.MouseButton1Click:Connect(function()
	Display_Menu(Menus.Hub)
	ServerMenu.Enabled = false
	ChooseBand.Enabled = true
	game.Players.LocalPlayer.Character.PrimaryPart.Anchored = false
end)

-->> custmo game browser --
Menus.Hub.Server_Join.MouseButton1Click:Connect(function()
	Display_Menu(Menus.Custom_Joiner)
	Update_Servers()
end)

Menus.Custom_Joiner.Hub.MouseButton1Click:Connect(function()
	Disconnect_Join_2()
	Display_Menu(Menus.Hub)
end)

for i, v in pairs(Descriptions) do
	local HubButton: TextButton = Menus.Hub[i]

	HubButton.MouseEnter:Connect(function()
		Menus.Hub.Separator.Title.Text = v[1]
		Menus.Hub.Separator.Description.Text = v[2]
	end)
end
