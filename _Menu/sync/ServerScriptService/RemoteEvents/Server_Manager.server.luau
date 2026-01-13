local MemoryStore, MessengingService, HttpService, ReplicatedStorage, TeleportService = game:GetService('MemoryStoreService'), game:GetService('MessagingService'), game:GetService('HttpService'), game:GetService('ReplicatedStorage'), game:GetService('TeleportService')
local PrivateStore = MemoryStore:GetSortedMap("PrivateCodes")
local CodeStore = MemoryStore:GetSortedMap("ServerCodes")

local Modules = {
	Data = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'));
	Server_Listing = require(script:WaitForChild('Server_Listing')); -->> limits us to 1 message request a server
}

local Remotes = {
	RequestServer = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('RequestTestServer');
	Bug_Reader = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Bug_Reader');
	SWF = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('SWF_Event');
	Custom_Join = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Join_Custom');
}

local MMK_PENALTY = {
	Survivor = 10;
	Killer = 15; -- if they dc it's 100% on them
}

local Places = {
	Gameplay = 14904829680;
	Testbuild = 15091839543;
	Testmenu = 17105536841;
}

local Looking_For_Match = {
	SOLO = {}; -- SOLO searchers
	PRO = {}; -- pro searchers
	SWF = {}; -- swf searchers
}

local Taken_Servers = {} -- to not repeat

local Ideal_Ping_Range = 5 --15 -- ideal ping zone if lobby is found with this ping go to them (avoid broken lobbies more often)

task.spawn(function()
	require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Cosmetics')).RemoveScripts()
end)

function FindSwf(Player : Player) : Configuration | nil
	
	for _, swf_lobby in pairs(ReplicatedStorage:WaitForChild('SWF'):GetChildren()) do
		
		for _, survivor in pairs(swf_lobby:GetChildren()) do
			
			if survivor.Name == Player.Name then
				return swf_lobby
			end
		end
	end
end

Remotes.Custom_Join.OnServerInvoke = function(Player: Player, Server)

	Remotes.Bug_Reader:FireAllClients('===================')
	Remotes.Bug_Reader:FireAllClients(Player.Name..' wants '..Server)
	
	local function GetQueue(server) : number
		local i = 0

		for name, data in pairs(server.QueueList) do
			i += 1
		end

		return i
	end

	local function GetLobby(serverid, server_listing) : "Lobby"

		--Remotes.Bug_Reader:FireAllClients('------------------')
		--Remotes.Bug_Reader:FireAllClients(serverid)
		--Remotes.Bug_Reader:FireAllClients('------------------')
		
		for _, Lobby in pairs(server_listing) do

			--Remotes.Bug_Reader:FireAllClients('--')
			
			if Lobby.Host.ID == serverid then
				--Remotes.Bug_Reader:FireAllClients('FOUND IT')
				return Lobby
			else
				--Remotes.Bug_Reader:FireAllClients(Lobby.Host.ID)
			end
		end

		return nil
	end

	local function InQueue(server) : boolean

		for name, data in pairs(server.QueueList) do

			if name == Player.Name then
				return true
			end
		end

		return false
	end
	
	if Server and game.ReplicatedStorage:WaitForChild('SERVERS'):FindFirstChild(Server) then
		Server = game.ReplicatedStorage:WaitForChild('SERVERS'):WaitForChild(Server)
		Remotes.Bug_Reader:FireAllClients('CUSTOM SERVER FOUND!')
	else
		Server = nil
	end
	
	if Server then
		local Encode = { -- tell them we want to reserve spots
			Message = "SOLO";
			LobbyId = tonumber(Server.Name);
			User = Player.Name;
			Id = Player.UserId;
			Time = workspace:GetServerTimeNow();
		}

		Modules.Data:SetTeam("Survivor", Player)
		
		--Remotes.Bug_Reader:FireAllClients(tostring(Player) .. ' demands ' .. tostring(Server))
		
		local function GrabLobby() : "Return Raw Lobby"
			
			if Server:GetAttribute("Tester_Only") then
				return GetLobby(Encode.LobbyId, Modules.Server_Listing.Testing_Servers)
			else
				return GetLobby(Encode.LobbyId, Modules.Server_Listing.Normal_Servers)
			end
		end
		
		local UpdateTime = GrabLobby().LastPing -- store the last update

		Remotes.Bug_Reader:FireAllClients('found custom game attempting to send encode', Encode.LobbyId)
		
		local success, error_ = pcall(function()
			return MessengingService:PublishAsync("Reservations", HttpService:JSONEncode(Encode))
		end)

		if success then
			--Remotes.Bug_Reader:FireAllClients(tostring(Player) .. 'challenged server!')
			
			local Temp = GrabLobby()
			
			Remotes.Bug_Reader:FireAllClients('WAITING ON CUSTOM GAME:', Temp)
			
			repeat task.wait(1)
				Temp = GrabLobby()
			until not Temp -- server died
				or (workspace:GetServerTimeNow() - Encode.Time) >= 30 -- lobby would have removed us give up
				or InQueue(Temp) -- we got the server
				or (Temp.LobbySize.Survivors - (Temp.CurrentLobby.Survivors + GetQueue(Temp))) < 0 -- lost the space
			
			Remotes.Bug_Reader:FireAllClients('GOT A RESPONSE OR WAITED OUT FROM CUSTOM GAME!')
			Remotes.Bug_Reader:FireAllClients('SERVER:', Temp)
			Remotes.Bug_Reader:FireAllClients('QUEUE_STATUS:', InQueue(Temp))
			Remotes.Bug_Reader:FireAllClients('REMAINING:', (Temp.LobbySize.Survivors - (Temp.CurrentLobby.Survivors + GetQueue(Temp))))
			Remotes.Bug_Reader:FireAllClients('TIME:', (workspace:GetServerTimeNow() - Encode.Time))
			
			if Temp and InQueue(Temp) and (Temp.LobbySize.Survivors - (Temp.CurrentLobby.Survivors + GetQueue(Temp))) >= 0 then
				Remotes.Bug_Reader:FireAllClients('RESERVATION SUCCESS!')
				
				--print(Temp.Code)
				--print(Temp.Host.ID)
				
				local success, _err = pcall(function()
					
					if Server:GetAttribute("Tester_Only") then
						return TeleportService:TeleportToPrivateServer(Places.Testbuild, Temp.Code, {Player}, "", "SOLO")
					else
						return TeleportService:TeleportToPrivateServer(Places.Gameplay, Temp.Code, {Player}, "", "SOLO")
					end
				end)

				if success then
					return true
				else
					Remotes.Bug_Reader:FireAllClients('TELEPORT FAILED!')
				end
			else
				Remotes.Bug_Reader:FireAllClients('RESERVATION FAILED!')
			end
		else
			Remotes.Bug_Reader:FireAllClients("MMK ERRORED", error_)
		end
	end
	
	Remotes.Bug_Reader:FireAllClients('GOT TO END WE RETURNING FALSE')
	Remotes.Bug_Reader:FireAllClients('===================')
	
	return false
end

Remotes.SWF.OnServerEvent:Connect(function(Player : Player, Command : "Create" | "Join" | "Leave", Party : Configuration | nil)
	print(Player, 'has used swf remote!')
	
	
	if Command == "Create" and Party then
		local Curr_Lobby = FindSwf(Player)
		
		if Curr_Lobby then
			warn('We have lobby?')
		else
			local New_Lobby = Instance.new('Configuration')
			New_Lobby.Name = Player.Name
			
			Modules.Data:SetTeam("Survivor", Player)
			
			New_Lobby:SetAttribute("Friend_Only", if Party.Friend then true else false)
			New_Lobby:SetAttribute("Password", if Party.Password then Party.Password else false)
			
			local Our_Survivor = Instance.new('Configuration', New_Lobby)
			Our_Survivor.Name = Player.Name
			
			New_Lobby.Parent = ReplicatedStorage:WaitForChild('SWF')
		end
	elseif Command == "Join" and Party then
		local Curr_Lobby = FindSwf(Player)

		if Curr_Lobby then
			warn('We have lobby?')
		else
			
			if #Party:GetChildren() < 4 then
				local Our_Survivor = Instance.new('Configuration')
				Our_Survivor.Name = Player.Name
				Our_Survivor.Parent = Party

				Modules.Data:SetTeam("Survivor", Player)
			end
		end
	elseif Command == "Leave" then
		local Curr_Lobby = FindSwf(Player)
		
		if Curr_Lobby then
			
			if Curr_Lobby.Name == Player.Name then -->> we are host destroy the entire thing
				Curr_Lobby:Remove()
			else
				Curr_Lobby:WaitForChild(Player.Name):Remove()
			end
		else
			warn('We were not in a lobby?')
		end
	elseif Command == "Kick" and Party then
		
		if Player.Name == Party.Parent.Name and Player.Name ~= Party.Name then
			Party:Remove()
		else
			warn(Player, 'is kicking when not owner?')
		end
	else
		warn(Command, 'is unsupported or lack of party was found!')
	end
end)

Remotes.RequestServer.OnServerEvent:Connect(function(plr : Player, placecode : string, side : "Killer/Survivor", typeofmatch : "Normal" | "Pro")

	if placecode == "Normal" then
		local data = Modules.Data:GetRaw(plr).Main
		
		if side == 'Killer' then -- Generate a new lobby
			local MMK_Setting, Place_ID = Modules.Data:GetMMKSettings(plr), if workspace:GetAttribute("TESTING") then Places.Testbuild else Places.Gameplay

			Modules.Data:SetTeam("Killer", plr)
			
			--[[if data.Misc.MMK_TIME then
				repeat task.wait()
				until (workspace:GetServerTimeNow() - data.Misc.MMK_TIME) >= MMK_PENALTY.Killer

				data.Misc.MMK_TIME = workspace:GetServerTimeNow()
			else
				task.wait(7)
			end]]

			local code = TeleportService:ReserveServerAsync(Place_ID)

			MMK_Setting.Custom.Enabled = false -- enabled custom game
			MMK_Setting.Custom.Friend = false -- set friend access
			MMK_Setting.Custom.Password = false -- set password
			MMK_Setting.Custom.Map = false -- set map
			MMK_Setting.Pro.Enabled = false
			
			MMK_Setting.Code = code -->> Insert the Code into Our Data Store Now <<--
			
			TeleportService:TeleportToPrivateServer(Place_ID, MMK_Setting.Code, {plr}) -- takes us to our private lobby
		elseif side == 'Survivor' then
			local MMK_Setting = Modules.Data:GetMMKSettings(plr)
			
			Modules.Data:SetTeam("Survivor", plr)
			
			--[[if data.Misc.MMK_TIME then
				repeat task.wait()
				until (workspace:GetServerTimeNow() - data.Misc.MMK_TIME) >= MMK_PENALTY.Survivor

				data.Misc.MMK_TIME = workspace:GetServerTimeNow()
			else
				task.wait(7)
			end]]
			
			local Search_Type = "Normal"
			
			
			Looking_For_Match.SOLO[plr.Name] = { -- insert us into mmk
				Search_Type = "Normal";
				Timestamp = workspace:GetServerTimeNow(); -- time they started queue
			}
		elseif side == "SWF" then
			warn(plr.Name, 'wishs to boot up their swf')
			
			local Swf, swf_lobby = {}, game.ReplicatedStorage:WaitForChild('SWF'):FindFirstChild(plr.Name)
			
			if swf_lobby then

				for _, player in pairs(swf_lobby:GetChildren()) do
					if not game.Players:FindFirstChild(player.Name) then continue end
					table.insert(Swf, game.Players:WaitForChild(player.Name))
				end

				if #Swf <= 0 then -- punish for solo queuing in swf
					swf_lobby:Remove()
				else
					swf_lobby:SetAttribute("TIME_STAMP", workspace:GetServerTimeNow())
					swf_lobby:SetAttribute("QUEUED", true)

					Looking_For_Match.SWF[plr.Name] = {
						Search_Type = 'Normal';
						Players = Swf;-- 0 -- Folder:GetChildren() or something like that
						Timestamp = workspace:GetServerTimeNow(); -- time they started queue
						SWF_OBJECT = swf_lobby;
					}
				end
			end
		end
	elseif placecode == "Create" then
		local MMK_Setting, Place_ID = Modules.Data:GetMMKSettings(plr), if workspace:GetAttribute("TESTING") then Places.Testbuild else Places.Gameplay
		
		Modules.Data:SetTeam("Killer", plr) -->> killer creates match << -- TODO: CHANGE IN FUTURE
		
		warn(side)
		
		local code = TeleportService:ReserveServerAsync(Place_ID)
		
		
		MMK_Setting.Custom.Enabled = true -- enabled custom game
		MMK_Setting.Custom.Friend = side.Friend -- set friend access
		MMK_Setting.Custom.Password = if side.Password then side.Password else false -- set password
		MMK_Setting.Custom.Map = if side.Map then side.Map else false -- set map
		MMK_Setting.Custom.Mode = if side.Mode then side.Mode else false
		
		MMK_Setting.Code = code -->> Insert the Code into Our Data Store Now <<--

		TeleportService:TeleportToPrivateServer(Place_ID, MMK_Setting.Code, {plr}) -- takes us to our private lobby
	elseif placecode == "NEW_MENU" then
		TeleportService:Teleport(Places.Testmenu, plr)
	elseif placecode == "Remove" then
		if Looking_For_Match.SOLO[plr.Name] then
			Looking_For_Match.SOLO[plr.Name] = nil
		end
	end
end)

while task.wait(1) do
	local longest_queue, server_type = 0, if workspace:GetAttribute('TESTING') then Modules.Server_Listing.Testing_Servers else Modules.Server_Listing.Normal_Servers
	local longest_pro_queue = 0
	
	if (workspace:GetServerTimeNow() - Modules.Server_Listing.Last_Update) >= 60 then
		Modules.Server_Listing:Update() -- update if hasn't updated by itself in a while
	end
	
	if not game:GetService('RunService'):IsStudio() then -->> so it doesn't annoy me when testing
		Remotes.Bug_Reader:FireAllClients("Server is Running...")
	end
	
	-- clear out and update listings -- (players who left)
	for swf_party, swf_data in pairs(Looking_For_Match.SWF) do
		
		if not game.Players:FindFirstChild(swf_party) then -- lobby leader already left/dipped
			Looking_For_Match.SWF[swf_party] = nil
		end
		
		for _, player in pairs(swf_data.Players) do
			
			if not game.Players:FindFirstChild(player.Name) then
				table.remove(swf_data.Players, table.find(swf_data.Players, player)) -- remove them from swf data since they elft
			end
		end
	end

	for survivor, survivor_data in pairs(Looking_For_Match.SOLO) do
		if not game.Players:FindFirstChild(survivor) then
			Looking_For_Match.SOLO[survivor] = nil
			continue
		end
		
		if survivor_data.Search_Type == "Pro" then

			if (workspace:GetServerTimeNow() - survivor_data.Timestamp) > longest_pro_queue then
				longest_pro_queue = (workspace:GetServerTimeNow() - survivor_data.Timestamp)
			end
		else

			if (workspace:GetServerTimeNow() - survivor_data.Timestamp) > longest_queue then
				longest_queue = (workspace:GetServerTimeNow() - survivor_data.Timestamp)
			end
		end
	end
	
	workspace:SetAttribute("Longest_Queue", longest_queue)
	
	--------- MATCHMAKING NORMAL SERVERS -------------------
	
	local function GetQueue(server) : number
		local i = 0

		for name, data in pairs(server.QueueList) do
			i += 1
		end

		return i
	end

	local function IsTaken(server) : boolean

		if Taken_Servers[server.Host.ID] then
			
			if (workspace:GetServerTimeNow() - Taken_Servers[server.Host.ID]) >= 60 then
				Taken_Servers[server.Host.ID] = nil
				return false
			else
				return true
			end
		end

		return false
	end
	
	local function GetLobby(serverid) : "Lobby"

		for _, Lobby in pairs(server_type) do

			if Lobby.Host.ID == serverid then
				return Lobby
			end
		end

		return nil
	end
	
	local function LookforLobby_SWF(Current_Swf : "table", Owner : string | Player) : "Look for lobby"
		local BestMatch, MatchStatus = nil, 'Bad'
		
		warn('Checking swf for:', Owner)
		warn('Waiting for:', (workspace:GetServerTimeNow() - Current_Swf.Timestamp))
		
		for _, player in pairs(Current_Swf.Players) do -- replace owner string with owner player
			
			if player.Name == Owner then
				Owner = player
				break
			end
		end

		local function InQueue(server) : boolean

			if server.LockedUnder.Leader == Owner.UserId then
				return true
			end

			return false
		end
		
		for _, Lobby in pairs(server_type) do -- Cycle Lobbies for our best possible match
			if (Lobby.LobbySize.Survivors - (Lobby.CurrentLobby.Survivors + GetQueue(Lobby))) < #Current_Swf.Players -- skip over if no slots available
				or Lobby.LockedUnder.Leader -- already has a swf tied to it skip over
				or Lobby.Custom.Enabled -- a custom game skip over it
				or IsTaken(Lobby) -- if the lobby is currently being queued for
				or (workspace:GetServerTimeNow() - Lobby.Created) <= Ideal_Ping_Range -- do not bother joining in first 15 seconds (give it time to work)
				or (workspace:GetServerTimeNow() - Lobby.LastPing) >= 180 -- lastping was over 3 minutes ago (dead lobby)
				or Lobby.Host.ID == 0 then -- host has not been set
				
				print('Skipped:', Lobby.Host.ID)
				
				continue
			end

			local Calculation = (Lobby.LastPing - Lobby.Created)

			warn('-------')
			warn('Lobby_ID:', Lobby.Host.ID)
			print('Last Ping:', workspace:GetServerTimeNow() -  Lobby.LastPing)
			print('Waiting for:', workspace:GetServerTimeNow() - Lobby.Created)
			print('Amount:', Lobby.CurrentLobby.Survivors + GetQueue(Lobby))
			print('Ping - Creation', Calculation)

			if not BestMatch then -- no lobby so get 1 instantly
				BestMatch = Lobby.Host.ID

				if (workspace:GetServerTimeNow() - Lobby.LastPing) <= Ideal_Ping_Range then
					MatchStatus = "Great" -- great lobby
					break
				else
					MatchStatus = "Normal" -- normal lobby
				end
			elseif BestMatch and MatchStatus == "Normal" then -- compare for longest waiter or a great lobby!

				if (workspace:GetServerTimeNow() - Lobby.LastPing) <= Ideal_Ping_Range then
					BestMatch = Lobby.Host.ID
					MatchStatus = "Great" -- normal lobby
					break
				end
			end
		end

		if BestMatch then -- We have found a viable Server Change our Queue Status and Insert into Queued Server List in different thread
			local Encode = { -- tell them we want to reserve spots
				Message = "RESERVE";
				LobbyId = BestMatch;
				SwfLeader = Owner.UserId;
				Time = workspace:GetServerTimeNow();
				Amount = #Current_Swf.Players;
			}

			local UpdateTime = GetLobby(BestMatch).LastPing -- store the last update

			print('found lobby reserving', BestMatch)
			warn('Last Update:', UpdateTime)
			warn('Length of wait time:', workspace:GetServerTimeNow() - GetLobby(BestMatch).Created)

			local success, error_ = pcall(function()
				return MessengingService:PublishAsync("Reservations", HttpService:JSONEncode(Encode))
			end)

			if success then
				local Temp = GetLobby(BestMatch)
				
				Looking_For_Match.SWF[Owner.Name].Search_Type = "Queued" -- will skip over us now in future instances
				Taken_Servers[Temp.Host.ID] = Encode.Time -- will prevent other survivors from wasting time on this lobby
				
				coroutine.wrap(function() -- Wrapped in thread won't delay/yield the rest of queued survivors

					repeat task.wait(1)
						Temp = GetLobby(BestMatch)
					until not Temp -- server died
						or (workspace:GetServerTimeNow() - Encode.Time) >= 60 -- lobby would have removed us give up
						or InQueue(Temp) -- we got the server
						or (Temp.LobbySize.Survivors - (Temp.CurrentLobby.Survivors + GetQueue(Temp))) < #Current_Swf.Players -- lost the space

					if Temp and InQueue(Temp) and (Temp.LobbySize.Survivors - (Temp.CurrentLobby.Survivors + GetQueue(Temp))) >= #Current_Swf.Players then
						warn('RESERVATION SUCCESS!')

						local success, _err = pcall(function()
							
							if workspace:GetAttribute("TESTING") then
								return TeleportService:TeleportToPrivateServer(Places.Testbuild, Temp.Code, Current_Swf.Players)
							else
								return TeleportService:TeleportToPrivateServer(Places.Gameplay, Temp.Code, Current_Swf.Players)
							end
						end)
						
						if success then
							Current_Swf.SWF_OBJECT:Remove() --destroy raw configuration
							Looking_For_Match.SWF[Owner.Name] = nil -- remove us from swf queues
						else
							warn('TELEPORT FAILED!')
						end
					else
						warn('RESERVATION FAILED!')
					end
					
					if Looking_For_Match.SWF[Owner.Name] then -- we failed at some point
						Looking_For_Match.SWF[Owner.Name].Search_Type = "Normal" -- bring us back into queues
					end
				end)()
			else
				warn("MMK ERRORED", error_)
			end
		end
	end
	
	local function LookforLobby_SOLO(Current_Survivor_Data : "table", Survivor : string | Player) : "Look for lobby"
		local BestMatch, MatchStatus = nil, 'Bad'
		
		--warn('Checking solo queue for:', Survivor)
		--warn('Waiting for:', (workspace:GetServerTimeNow() - Current_Survivor_Data.Timestamp))
		
		Survivor = game.Players:WaitForChild(Survivor)

		local function InQueue(server) : boolean

			for name, data in pairs(server.QueueList) do

				if name == Survivor.Name then
					return true
				end
			end

			return false
		end
		
		for _, Lobby in pairs(server_type) do -- Cycle Lobbies for our best possible match
			if (Lobby.LobbySize.Survivors - (Lobby.CurrentLobby.Survivors + GetQueue(Lobby))) < 1 -- skip over if no slots available
				or Lobby.LockedUnder.Leader -- already has a swf tied to it skip over
				or Lobby.Custom.Enabled -- a custom game skip over it
				or IsTaken(Lobby) -- if the lobby is currently being queued for
				or (workspace:GetServerTimeNow() - Lobby.Created) <= (Ideal_Ping_Range + 2) -- do not bother joining in first 15 seconds (give it time to work)
				or (workspace:GetServerTimeNow() - Lobby.LastPing) >= 180 -- lastping was over 3 minutes ago (dead lobby)
				or Lobby.Host.ID == 0 then -- host has not been set

				continue
			end

			if Current_Survivor_Data.Search_Type == "Pro" then
				if not Lobby.Pro_Only then continue end -- not pro match skip over
			else -- looking for normal
				if Lobby.Pro_Only then continue end -- pro match skip over
			end

			local Calculation = (Lobby.LastPing - Lobby.Created)

			warn('-------')
			warn('Lobby_ID:', Lobby.Host.ID)
			print('Last Ping:', workspace:GetServerTimeNow() -  Lobby.LastPing)
			print('Waiting for:', workspace:GetServerTimeNow() - Lobby.Created)
			print('Amount:', Lobby.CurrentLobby.Survivors + GetQueue(Lobby))
			print('Ping - Creation', Calculation)

			if not BestMatch then -- no lobby so get 1 instantly
				BestMatch = Lobby.Host.ID

				if (workspace:GetServerTimeNow() - Lobby.LastPing) <= Ideal_Ping_Range then
					MatchStatus = "Great" -- great lobby
					break
				else
					MatchStatus = "Normal" -- normal lobby
				end
			elseif BestMatch and MatchStatus == "Normal" then -- compare for longest waiter or a great lobby!

				if (workspace:GetServerTimeNow() - Lobby.LastPing) <= Ideal_Ping_Range then
					BestMatch = Lobby.Host.ID
					MatchStatus = "Great" -- normal lobby
					break
				end
			end
		end

		if BestMatch then -- We have found a viable Server Change our Queue Status and Insert into Queued Server List in different thread
			local Encode = { -- tell them we want to reserve spots
				Message = "SOLO";
				LobbyId = BestMatch;
				User = Survivor.Name;
				Id = Survivor.UserId;
				Time = workspace:GetServerTimeNow();
			}

			local UpdateTime = GetLobby(BestMatch).LastPing -- store the last update

			print('found lobby reserving', BestMatch)
			warn('Last Update:', UpdateTime)
			warn('Length of wait time:', workspace:GetServerTimeNow() - GetLobby(BestMatch).Created)

			local success, error_ = pcall(function()
				return MessengingService:PublishAsync("Reservations", HttpService:JSONEncode(Encode))
			end)

			if success then
				local Temp = GetLobby(BestMatch)

				Looking_For_Match.SOLO[Survivor.Name].Search_Type = "Queued" -- will skip over us now in future instances
				Taken_Servers[Temp.Host.ID] = Encode.Time -- will prevent other survivors from wasting time on this lobby

				coroutine.wrap(function() -- Wrapped in thread won't delay/yield the rest of queued survivors

					repeat task.wait(1)
						Temp = GetLobby(BestMatch)
					until not Temp -- server died
						or (workspace:GetServerTimeNow() - Encode.Time) >= 30 -- lobby would have removed us give up
						or InQueue(Temp) -- we got the server
						or (Temp.LobbySize.Survivors - (Temp.CurrentLobby.Survivors + GetQueue(Temp))) < 0 -- lost the space

					if Temp and InQueue(Temp) and (Temp.LobbySize.Survivors - (Temp.CurrentLobby.Survivors + GetQueue(Temp))) >= 0 then
						warn('RESERVATION SUCCESS!')
						
						local success, _err = pcall(function()
							
							if workspace:GetAttribute("TESTING") then
								return TeleportService:TeleportToPrivateServer(Places.Testbuild, Temp.Code, {Survivor}, "", "SOLO")
							else
								return TeleportService:TeleportToPrivateServer(Places.Gameplay, Temp.Code, {Survivor}, "", "SOLO")
							end
						end)

						if success then
							Looking_For_Match.SOLO[Survivor.Name] = nil -- remove us from solo queues
						else
							warn('TELEPORT FAILED!')
						end
					else
						warn('RESERVATION FAILED!')
					end

					if Looking_For_Match.SOLO[Survivor.Name] then -- we failed at some point
						Looking_For_Match.SOLO[Survivor.Name].Search_Type = "Normal" -- bring us back into queues
					end
				end)()
			else
				warn("MMK ERRORED", error_)
			end
		end
	end
	
	-- look through swf matches first --
	
	--[[
	cheetamcu = {
		Players = {
			game.Players.cheetamcu
			game.Players.PlsGiveMe_ATaco
		},
		Search_Type = "Normal" | "Test" | "Queued";
	}
	]]--
	
	for swf_party, swf_data in pairs(Looking_For_Match.SWF) do
		if swf_data.Search_Type ~= "Normal" then continue end -- either queued for match or wrong server type
		if (workspace:GetServerTimeNow() - swf_data.Timestamp) < longest_queue/1.25 then continue end -- if this person has not been waiting half the time of the longest queue skip over
		
		LookforLobby_SWF(swf_data, swf_party)
	end
	
	-- look through solo players --
	
	--[[
	cheetamcu = {
		Search_Type = "Normal" | "Test" | "Queued" | "Pro";
	}
	
	]]--
	
	
	for survivor, survivor_data in pairs(Looking_For_Match.SOLO) do
		if survivor_data.Search_Type == "Pro" then
			if (workspace:GetServerTimeNow() - survivor_data.Timestamp) < longest_pro_queue/1.25 then continue end -- if this person has not been waiting half the time of the longest queue skip over
			LookforLobby_SOLO(survivor_data, survivor)
		else
			if (workspace:GetServerTimeNow() - survivor_data.Timestamp) < longest_queue/1.25 then continue end -- if this person has not been waiting half the time of the longest queue skip over
			LookforLobby_SOLO(survivor_data, survivor)
		end -- either queued for match or wrong server type
	end
	
	--------- MATCHMAKING TESTING SERVERS ------------------
	
	
	-- DEBUG FOR ME --
	
end