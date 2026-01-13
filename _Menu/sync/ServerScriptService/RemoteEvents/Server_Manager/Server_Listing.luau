local MemoryStore, MessengingService, HttpService, ReplicatedStorage = game:GetService('MemoryStoreService'), game:GetService('MessagingService'), game:GetService('HttpService'), game:GetService('ReplicatedStorage')
local PrivateStore = MemoryStore:GetSortedMap("PrivateCodes")
local CodeStore = MemoryStore:GetSortedMap("ServerCodes")

local Servers = {
	Testing_Servers = {};
	Normal_Servers = {};
	--> will add more kinds of servers eventually
	
	Last_Update = workspace:GetServerTimeNow();
	
	-- Dependents --
	Connections = {
		Server_Messages = {};
	};
}

function GetQueueAmount(Lobby) : number | "RETURN # OF QUEUED PLAYERS FOR THIS GAME"
	local i = 0

	for name, data in pairs(Lobby.QueueList) do
		i += 1
	end

	return i
end

function CreateServer(Lobby, Testing_Server) : "Quick Create Function For Server"
	--warn('Create:', Lobby)
	
	local new_server = Instance.new('Configuration')
	new_server.Name = Lobby.Host.ID
	
	if Testing_Server then
		new_server:SetAttribute("Tester_Only", true) -- attach if testing server or not
	end
	
	new_server:SetAttribute("Friend_Only", Lobby.Custom.FriendsOnly) -- attach friend only option
	new_server:SetAttribute("Password", Lobby.Custom.Password) -- attach password
	new_server:SetAttribute("Server_Code", Lobby.Code) -- attach server code TODO: Secure this better in future
	
	if Lobby.Custom.Map then -- attach map for detail viewer
		new_server:SetAttribute("Map", Lobby.Custom.Map)
	else
		new_server:SetAttribute('Map', 'RANDOM')
	end
	
	new_server.Parent = ReplicatedStorage:WaitForChild('SERVERS')
end

function Server_Exist(Host_ID, Server_List) : "Returns Server"
	
	for _, Lobby in pairs(Server_List) do
		
		if Lobby.Host.ID == Host_ID then
			return Lobby
		end
	end
	
	return false
end

function Servers:Update() -- Update Server Listings
	local Normal_Amount, Pro_Amount, Server_Type = 0, 0, Servers.Normal_Servers
	
	if workspace:GetAttribute("TESTING") then
		Server_Type = Servers.Testing_Servers
	end
	
	for i, Lobby in pairs(Server_Type) do
		if (Lobby.LobbySize.Survivors - (Lobby.CurrentLobby.Survivors + GetQueueAmount(Lobby))) <= 0 or Lobby.Custom.Enabled or Lobby.LockedUnder.Leader then continue end -- skip over if no slots available or it's a private game or it's swf locked

		if Lobby.LastPing then

			if (workspace:GetServerTimeNow() - Lobby.LastPing) >= 30 then
				continue -- if last ping is greater then 30 seconds assume it's closed or if it's custom it's not valid
			end
		end
		
		if Lobby.Pro_Only then
			Pro_Amount += 1
		else
			Normal_Amount += 1
		end
	end

	workspace:SetAttribute("Server_Amount", Normal_Amount)

	-- Remove Old & Update Existing Servers --
	for _, Lobby in pairs(ReplicatedStorage:WaitForChild('SERVERS'):GetChildren()) do
		
		if Lobby:GetAttribute("Tester_Only") then -- compare against test servers
			local Our_Server = Server_Exist(Lobby.Name, Servers.Testing_Servers)
			
			if Our_Server then
				-- update server details here?
			else
				Lobby:Remove() -- does not exist anymore
			end
		else -- compare against normal servers
			local Our_Server = Server_Exist(Lobby.Name, Servers.Normal_Servers)

			if Our_Server then
				-- update server details here?
			else
				Lobby:Remove() -- does not exist anymore
			end
		end
	end
	
	-- Insert New Servers --
	for _, Lobby in pairs(Servers.Normal_Servers) do
		if (Lobby.Code and tostring(Lobby.Code) == "0") -- no code or it isn't set correct
			or not Lobby.Custom.Enabled then -- not a custom game do not add to servers list
			continue
		end
		
		CreateServer(Lobby)
	end
	
	for _, Lobby in pairs(Servers.Testing_Servers) do
		if (Lobby.Code and tostring(Lobby.Code) == "0") -- no code or it isn't set correct
			or not Lobby.Custom.Enabled then -- not a custom game do not add to servers list
			continue
		end

		CreateServer(Lobby, true)
	end
	
	Servers.Last_Update = workspace:GetServerTimeNow()
end

function Servers.boot()
	if Servers.Connections.Server_Messages.Normal then return Servers end -->> already booted do not run again
	
	Servers.Connections.Server_Messages.Normal = MessengingService:SubscribeAsync("Servers", function(tbl : "Table")
		local Data, Existed : boolean = HttpService:JSONDecode(tbl.Data), false

		for i, Lobby in pairs(Servers.Normal_Servers) do

			if Lobby.Host.ID == Data.Host.ID then
				Existed, Servers.Normal_Servers[i] = true, Data -- overwrite the data
				break
			end
		end

		if not Existed and type(Data.LockedUnder) == "table" and Data.Host.ID ~= 0 then -- not a starting host don't bother
			table.insert(Servers.Normal_Servers, Data)
		end

		for i, Lobby in pairs(Servers.Normal_Servers) do

			if Lobby.Host.CLOSED or (not Lobby.Host.HOSTED and (workspace:GetServerTimeNow() - Lobby.LastPing) > 60) then
				table.remove(Servers.Normal_Servers, table.find(Servers.Normal_Servers, Lobby))
			end
		end
		
		Servers:Update()
	end)

	Servers.Connections.Server_Messages.Testing = MessengingService:SubscribeAsync("TestServers", function(tbl : "Table")
		local Data, Existed : boolean = HttpService:JSONDecode(tbl.Data), false

		for i, Lobby in pairs(Servers.Testing_Servers) do

			if Lobby.Host.ID == Data.Host.ID then
				Existed, Servers.Testing_Servers[i] = true, Data -- overwrite the data
				break
			end
		end

		if not Existed then
			table.insert(Servers.Testing_Servers, Data)
		end

		for i, Lobby in pairs(Servers.Testing_Servers) do

			if Lobby.Host.CLOSED or (not Lobby.Host.HOSTED and (workspace:GetServerTimeNow() - Lobby.Created) > 60) then
				table.remove(Servers.Testing_Servers, i)
			end
		end

		--warn('Testing: '..#TestListing)
		Servers:Update()
	end)
	
	return Servers
end

return Servers.boot()
