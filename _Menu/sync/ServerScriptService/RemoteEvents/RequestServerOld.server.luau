warn("WE ARE USING OLD MMK")

local MemoryStore, MessengingService, HttpService, ReplicatedStorage = game:GetService('MemoryStoreService'), game:GetService('MessagingService'), game:GetService('HttpService'), game:GetService('ReplicatedStorage')
local PrivateStore = MemoryStore:GetSortedMap("PrivateCodes")
local CodeStore = MemoryStore:GetSortedMap("ServerCodes")

local Data_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local MMK_PENALTY = {
	Survivor = 20;
	Killer = 180; -- if they dc it's 100% on them
}

local Remotes = {
	InfoSend = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Count');
	RequestServer = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('RequestTestServer');
}

local ServerListing = {}
local TestListing = {}

local restricted_lobbies = {} --lobbies which are broken

local GroupId = 3863491

function UpdateLobbyCounter() : "Update Lobby Counter to now show full lobbies"
	local Amount = 0

	local function GetQueue(server) : number
		local i = 0

		for name, data in pairs(server.QueueList) do
			i += 1
		end

		return i
	end

	local function validLobby(lobbyID) : "Compares against broken lobby list"

		for _, Restricted_Lobby in pairs(restricted_lobbies) do
			if Restricted_Lobby == lobbyID then
				return false
			end
		end

		return true
	end

	for i, Lobby in pairs(ServerListing) do
		if (Lobby.LobbySize.Survivors - (Lobby.CurrentLobby.Survivors + GetQueue(Lobby))) <= 0 or not validLobby(Lobby.Host.ID) or Lobby.LockedUnder.Leader then continue end -- skip over if no slots available or it's a private game or it's swf locked


		if Lobby.LastPing then

			if (workspace:GetServerTimeNow() - Lobby.LastPing) >= 40 then
				continue -- if last ping is greater then 30 seconds assume it's closed
			end
		end

		Amount += 1
	end

	Remotes.InfoSend:FireAllClients(Amount)
end

MessengingService:SubscribeAsync("Servers", function(tbl : "Table")
	local Data, Existed : boolean = HttpService:JSONDecode(tbl.Data), false

	for i, Lobby in pairs(ServerListing) do

		if Lobby.Host.ID == Data.Host.ID then
			Existed, ServerListing[i] = true, Data -- overwrite the data
			break
		end
	end

	if not Existed and type(Data.LockedUnder) == "table" and Data.Host.ID ~= 0 then -- not a starting host don't bother
		table.insert(ServerListing, Data)
	end

	for i, Lobby in pairs(ServerListing) do

		if Lobby.Host.CLOSED or (not Lobby.Host.HOSTED and (workspace:GetServerTimeNow() - Lobby.LastPing) > 60) then
			table.remove(ServerListing, table.find(ServerListing, Lobby))
		end
	end

	UpdateLobbyCounter()
end)

MessengingService:SubscribeAsync("TestServers", function(tbl : "Table")
	local Data, Existed : boolean = HttpService:JSONDecode(tbl.Data), false

	for i, Lobby in pairs(TestListing) do

		if Lobby.Host.ID == Data.Host.ID then
			Existed, TestListing[i] = true, Data -- overwrite the data
			break
		end
	end

	if not Existed then
		table.insert(TestListing, Data)
	end

	for i, Lobby in pairs(TestListing) do

		if Lobby.Host.CLOSED or (not Lobby.Host.HOSTED and (workspace:GetServerTimeNow() - Lobby.Created) > 60) then
			table.remove(TestListing, i)
		end
	end

	--warn('Testing: '..#TestListing)
end)

teleportService = game:GetService("TeleportService")

local testcode = 14904829680
local gamecode = 14904829680
local PlayerTestCode = 15091839543 --PTB
local Test_Menu = 15074935970

Remotes.RequestServer.OnServerEvent:Connect(function(plr : Player, placecode : string, side : "Killer/Survivor")

	if placecode == "MENU" then
		local code = teleportService:ReserveServerAsync(Test_Menu)

		teleportService:TeleportToPrivateServer(Test_Menu, code, {plr}) -- takes us to our private lobby
	elseif placecode == "COLLISION" then
		local function CreatePTB()
			local code = teleportService:ReserveServerAsync(14904830408)

			warn('Generating A Lobby')

			local success, error = pcall(function()
				return CodeStore:SetAsync(plr.UserId, code, 120)
			end)

			if not success then
				repeat task.wait(3)
					success, error = pcall(function()
						return CodeStore:SetAsync(plr.UserId, code, 120)
					end)
				until success
			end

			teleportService:TeleportToPrivateServer(14904830408, code, {plr}) -- takes us to our private lobby
		end

		CreatePTB()
	elseif placecode == "Private" then --kyf game

		if side == 'Killer' then -- Generate a new lobby
			local code = teleportService:ReserveServerAsync(gamecode)

			local success, error = pcall(function()
				return PrivateStore:SetAsync(plr.UserId, code, 120)
			end)

			if not success then
				repeat task.wait(3)
					success, error = pcall(function()
						return PrivateStore:SetAsync(plr.UserId, code, 120)
					end)
				until success
			end

			teleportService:TeleportToPrivateServer(gamecode, code, {plr}) -- takes us to our private lobby
		elseif side == 'Survivor' then
			local Code = nil

			repeat task.wait(8)
				warn('Searching for a lobby')

				local BestMatch = nil

				for _, Lobby in pairs(ServerListing) do
					if (Lobby.LobbySize.Survivors - Lobby.CurrentLobby.Survivors) <= 0 or not Lobby.Custom.Enabled then continue end -- skip over if no slots available or it's not a custom game

					if not BestMatch then
						BestMatch = Lobby
					elseif BestMatch and (workspace:GetServerTimeNow() - Lobby.Created) > (workspace:GetServerTimeNow() - BestMatch.Created) then -- if this killer has been waiting longer switch to their lobby
						BestMatch = Lobby
					end
				end

				if BestMatch then
					Code = BestMatch.Code
				end
			until Code

			warn("TELEPORTING SURVIVOR")

			task.wait(5)
			teleportService:TeleportToPrivateServer(gamecode, Code, {plr}) -- lets us in lobby w/ code
		end
	elseif placecode == 'PTB' then
		if not Data_Module:GetPermission("Testing", plr) and workspace:GetAttribute("TESTER_ONLY") then
			return warn("Tester's only")
		end

		print('Started PTB')

		local function CreatePTB()
			local code = teleportService:ReserveServerAsync(PlayerTestCode)

			warn('Generating A Lobby')

			local success, error = pcall(function()
				return CodeStore:SetAsync(plr.UserId, code, 120)
			end)

			if not success then
				repeat task.wait(3)
					success, error = pcall(function()
						return CodeStore:SetAsync(plr.UserId, code, 120)
					end)
				until success
			end

			teleportService:TeleportToPrivateServer(PlayerTestCode, code, {plr}) -- takes us to our private lobby
		end

		if side == 'Killer' then -- Generate a new lobby
			CreatePTB()
		elseif side == 'Survivor' then
			local attempts = 0
			local Code = nil
			local WaitTime = 5

			local function GetQueue(server) : number
				local i = 0

				for name, data in pairs(server.QueueList) do

					if name ~= plr.Name then
						i += 1
					end
				end

				return i
			end

			local function grablobby(id) : "Updated Lobby"

				for i,server in pairs(TestListing) do
					if server.Host.ID == id then
						return server
					end
				end

				return nil
			end

			local function InQueue(server) : boolean

				for name, data in pairs(server.QueueList) do

					if name == plr.Name then
						return true
					end
				end

				return false
			end

			local function validLobby(lobbyID) : "Compares against broken lobby list"

				for _, Restricted_Lobby in pairs(restricted_lobbies) do
					if Restricted_Lobby == lobbyID then
						return false
					end
				end

				return true
			end

			local function LookforLobby() : "Look for lobby"
				local BestMatch, MatchStatus = nil, 'Bad'

				warn('Searching for a lobby')
				warn('========================')
				warn('-------------------------------')

				for _, Lobby in pairs(TestListing) do
					if (Lobby.LobbySize.Survivors - (Lobby.CurrentLobby.Survivors + GetQueue(Lobby))) <= 0 or not validLobby(Lobby.Host.ID) or Lobby.Custom.Enabled or Lobby.LockedUnder.Leader then continue end -- skip over if no slots available or it's a private game or it's swf locked
					local Calculation = (Lobby.LastPing - Lobby.Created)

					warn('-------')
					warn('Lobby_ID:', Lobby.Host.ID)
					print('Last Ping:', workspace:GetServerTimeNow() -  Lobby.LastPing)
					print('Waiting for:', workspace:GetServerTimeNow() - Lobby.Created)
					print('Amount:', Lobby.CurrentLobby.Survivors + GetQueue(Lobby))
					print('Ping - Creation', Calculation)

					if not BestMatch then -- no lobby so get 1 instantly
						BestMatch = Lobby.Host.ID
						break
					end
				end

				if BestMatch and workspace:GetAttribute("MMK_TEST") then
					local Lobby = grablobby(BestMatch)
					BestMatch = nil

					local Calculation = (Lobby.LastPing - Lobby.Created)

					print('=====')
					warn('Lobby_ID:', Lobby.Host.ID)
					print('Last Ping:', workspace:GetServerTimeNow() -  Lobby.LastPing)
					print('Waiting for:', workspace:GetServerTimeNow() - Lobby.Created)
					print('Amount:', Lobby.CurrentLobby.Survivors + GetQueue(Lobby))
					print('Ping - Creation', Calculation)
				end

				if BestMatch then -- we got a hookup now lets reserve a spot before teleporting
					local Encode = {
						Message = "SOLO"; -- let it know we are a solo survivor
						LobbyId = BestMatch; -- lets us know for which lobby
						User = plr.Name;
						Id = plr.UserId;
						Time = workspace:GetServerTimeNow();
					}

					local UpdateTime = grablobby(BestMatch).LastPing -- store the last update

					print('found lobby reserving', BestMatch)
					warn('Last Update:', (workspace:GetServerTimeNow() - UpdateTime))
					warn('Length of wait time:', workspace:GetServerTimeNow() - grablobby(BestMatch).Created)

					local success, error_ = pcall(function()
						return MessengingService:PublishAsync("Reservations", HttpService:JSONEncode(Encode))
					end)

					if success then
						local temp = nil

						warn("Sent message to request to join server")

						repeat task.wait(1)
							temp = grablobby(BestMatch)
						until not temp -- the lobby disipeared off the face of the earth
							or (workspace:GetServerTimeNow() - Encode.Time) >= 30 -- the lobby would have removed us at this point / give up
							or InQueue(temp) -- we got in
							or (temp.LobbySize.Survivors - (temp.CurrentLobby.Survivors + GetQueue(temp))) <= 0 -- space ran out

						print('Done Looping')

						if temp and InQueue(temp) and (temp.LobbySize.Survivors - (temp.CurrentLobby.Survivors + GetQueue(temp))) >= 1 then
							print('Got the code:', temp.Code)
							Code = temp.Code
							print('Got the code 2:', Code)
						else
							print('Elasped:', (workspace:GetServerTimeNow() - Encode.Time))
							print('Temp Check:', (temp ~= nil))
							print('Queue Check', InQueue(temp))
							print('Spaces Left', (temp.LobbySize.Survivors - (temp.CurrentLobby.Survivors + GetQueue(temp))))
						end
					else
						warn("MMK ERRORED",error_)
					end
				end
			end

			LookforLobby()

			if not Code then

				repeat task.wait(WaitTime)
					LookforLobby()

					if not Code then
						attempts += 1

						if attempts >= 3 then
							attempts = 100
							CreatePTB()
						end
					end
				until Code or attempts >= 100
			end

			print('gained a code')

			if attempts < 100 and Code then
				teleportService:TeleportToPrivateServer(PlayerTestCode, Code, {plr}, "", "SOLO") -- lets us in lobby w/ code
			end
		end
		print('Started PTB')
	elseif placecode == "Normal" then
		local data = Data_Module:GetRaw(plr).Main

		if side == 'Killer' then -- Generate a new lobby
			
			if data.Misc.MMK_TIME then
				repeat task.wait()
				until (workspace:GetServerTimeNow() - data.Misc.MMK_TIME) >= MMK_PENALTY.Killer

				data.Misc.MMK_TIME = workspace:GetServerTimeNow()
			else
				task.wait(7)
			end

			local code = teleportService:ReserveServerAsync(gamecode)
			
			if plr.Name == 'cheetamcu' then -- experiemnetal mmk
				data.Misc.MMK_Data.Code = code -->> Insert the Code into Our Data Store Now
			else -- use default mmk

				local success, error = pcall(function()
					return CodeStore:SetAsync(plr.UserId, code, 120)
				end)

				if not success then
					repeat task.wait(5)
						success, error = pcall(function()
							return CodeStore:SetAsync(plr.UserId, code, 120)
						end)
					until success
				end
			end
			

			teleportService:TeleportToPrivateServer(gamecode, code, {plr}) -- takes us to our private lobby
		elseif side == 'Survivor' then

			if data.Misc.MMK_TIME then
				repeat task.wait()
				until (workspace:GetServerTimeNow() - data.Misc.MMK_TIME) >= MMK_PENALTY.Survivor

				data.Misc.MMK_TIME = workspace:GetServerTimeNow()
			else
				task.wait(7)
			end

			local Code = nil
			local WaitTime = 20

			local function GetQueue(server) : number
				local i = 0

				for name, data in pairs(server.QueueList) do

					if name ~= plr.Name then
						i += 1
					end
				end

				return i
			end

			local function grablobby(id) : "Updated Lobby"

				for i,server in pairs(ServerListing) do
					if server.Host.ID == id then
						return server
					end
				end

				return nil
			end

			local function InQueue(server) : boolean
				if not server then return false end

				for name, data in pairs(server.QueueList) do

					if name == plr.Name then
						return true
					end
				end

				return false
			end

			local function validLobby(lobbyID) : "Compares against broken lobby list"

				for _, Restricted_Lobby in pairs(restricted_lobbies) do
					if Restricted_Lobby == lobbyID then
						return false
					end
				end

				return true
			end

			local function LookforLobby() : "Look for lobby"
				local BestMatch, MatchStatus = nil, 'Bad'
				local Ideal_Ping_Range = 20 -- ideal ping zone if lobby is found with this ping go to them (avoid broken lobbies more often)
				local Auto_Join = 60 -- if they have been waiting for a minute auto-join

				warn('Searching for a lobby')
				warn('========================')
				warn('-------------------------------')

				for _, Lobby in pairs(ServerListing) do
					if (Lobby.LobbySize.Survivors - (Lobby.CurrentLobby.Survivors + GetQueue(Lobby))) <= 0 or not validLobby(Lobby.Host.ID) or Lobby.Custom.Enabled or Lobby.LockedUnder.Leader then continue end -- skip over if no slots available or it's a private game or it's swf locked
					local Calculation = (Lobby.LastPing - Lobby.Created)

					if Calculation <= 30 and (workspace:GetServerTimeNow() - Lobby.Created) >= Ideal_Ping_Range then continue end -- don't trust these lobbies

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
						else
							MatchStatus = "Normal" -- normal lobby
						end
					elseif BestMatch and MatchStatus == "Normal" then -- compare for longest waiter or a great lobby!

						if (workspace:GetServerTimeNow() - Lobby.LastPing) <= Ideal_Ping_Range then
							BestMatch = Lobby.Host.ID
							MatchStatus = "Great" -- normal lobby
						elseif (workspace:GetServerTimeNow() - Lobby.Created) > (workspace:GetServerTimeNow() - grablobby(BestMatch).Created) then
							BestMatch = Lobby.Host.ID -- get the one who waited longest
						end
					elseif BestMatch and MatchStatus == "Great" then -- compare for longest waiter

						if (workspace:GetServerTimeNow() - Lobby.LastPing) <= Ideal_Ping_Range and (workspace:GetServerTimeNow() - Lobby.Created) > (workspace:GetServerTimeNow() - grablobby(BestMatch).Created) then -- only compare with great lobbies
							BestMatch = Lobby.Host.ID -- get the one who waited longest
						end
					end

					if BestMatch and MatchStatus == "Great" and (workspace:GetServerTimeNow() - Lobby.Created) >= Auto_Join then
						break -- auto-join them
					end
				end

				if BestMatch and workspace:GetAttribute("MMK_TEST") then
					local Lobby = grablobby(BestMatch)
					BestMatch = nil

					local Calculation = (Lobby.LastPing - Lobby.Created)

					print('=====')
					warn('Lobby_ID:', Lobby.Host.ID)
					print('Last Ping:', workspace:GetServerTimeNow() -  Lobby.LastPing)
					print('Waiting for:', workspace:GetServerTimeNow() - Lobby.Created)
					print('Amount:', Lobby.CurrentLobby.Survivors + GetQueue(Lobby))
					print('Ping - Creation', Calculation)
				end

				if BestMatch then -- we got a hookup now lets reserve a spot before teleporting
					local Encode = {
						Message = "SOLO"; -- let it know we are a solo survivor
						LobbyId = BestMatch; -- lets us know for which lobby
						User = plr.Name;
						Id = plr.UserId;
						Time = workspace:GetServerTimeNow();
					}

					local UpdateTime = grablobby(BestMatch).LastPing -- store the last update

					print('found lobby reserving', BestMatch)
					warn('Last Update:', (workspace:GetServerTimeNow() - UpdateTime))
					warn('Length of wait time:', workspace:GetServerTimeNow() - grablobby(BestMatch).Created)

					local success, error_ = pcall(function()
						return MessengingService:PublishAsync("Reservations", HttpService:JSONEncode(Encode))
					end)

					if success then
						local temp = nil

						warn("Sent message to request to join server")

						repeat task.wait(1)
							temp = grablobby(BestMatch)
						until not temp -- the lobby disipeared off the face of the earth
							or (workspace:GetServerTimeNow() - Encode.Time) >= 30 -- the lobby would have removed us at this point / give up
							or InQueue(temp) -- we got in
							or (temp.LobbySize.Survivors - (temp.CurrentLobby.Survivors + GetQueue(temp))) <= 0 -- space ran out

						print('Done Looping')

						if temp and InQueue(temp) and (temp.LobbySize.Survivors - (temp.CurrentLobby.Survivors + GetQueue(temp))) >= 1 then
							print('Got the code:', temp.Code)
							Code = temp.Code
							print('Got the code 2:', Code)
						else
							print('failed to load lobby:')
							print('Elasped:', (workspace:GetServerTimeNow() - Encode.Time))

							if temp then
								print('Queue Check', InQueue(temp))
								print('Spaces Left', (temp.LobbySize.Survivors - (temp.CurrentLobby.Survivors + GetQueue(temp))))
							else
								print('lobby is gone!')
							end
						end
					else
						warn("MMK ERRORED",error_)
					end
				end
			end

			LookforLobby()

			if not Code then

				repeat task.wait(WaitTime)
					LookforLobby()
					WaitTime = math.clamp(WaitTime - 0.35, 5, WaitTime)
				until Code
			end

			print('gained a code')

			teleportService:TeleportToPrivateServer(gamecode, Code, {plr}, "", "SOLO") -- lets us in lobby w/ code
		end
	end
end)