local MessengingService = game:GetService('MessagingService')
local Http = game:GetService('HttpService')
local MemoryService = game:GetService('MemoryStoreService')
local TeleportService = game:GetService('TeleportService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Data_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local Server_Codes : MemoryStoreSortedMap = MemoryService:GetSortedMap("ServerCodes")
local Private_Codes : MemoryStoreSortedMap = MemoryService:GetSortedMap("PrivateCodes")

local BUG_READ = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents'):WaitForChild('BUGREAD')

local Menu_ID = 14904820737

local ServerType = { -- automates mmk server types
	['14904829680'] = "Servers";
	['15091839543'] = 'TestServers';
	['15074204284'] = 'TestServers';
}

local MMK = {
	Server = {
		Code = 0;
		Created = workspace:GetServerTimeNow();
		Rank = 20;
		Pro_Only = false; -- pro server or not?
		Region = "Any";
		LockedUnder = {
			Leader = false;
			Time = 0;
		}; -- Locked under this swf leader
		Custom = {
			Enabled = false;
			FriendsOnly = false;
			Mode = false;
			Password = nil;
			Map = nil;
		},
		Host = {
			ID = 0;
			HOSTED = false;
			CLOSED = false;
		},
		LobbySize = {
			Survivors = 4;
			Killers = 1;
		},
		QueueList = {},
		LastPing = workspace:GetServerTimeNow();
		CurrentLobby = {
			Survivors = 0;
			Killers = 0;
		},
	},
	PingAttempt = false
}

local function GetQueue() : number
	local amount = 0
	
	for playername, data in pairs(MMK.Server.QueueList) do
		amount += 1
	end
	
	return amount
end

local function GrabCode(UserId : number) : 'Return Lobby Key'
	local Success, Lobby = false, nil
	
	Success, Lobby = pcall(function()
		return Server_Codes:GetAsync(UserId)
	end)
	
	if not Success then
		
		repeat task.wait(4) --changed from 5
			Success, Lobby = pcall(function()
				return Server_Codes:GetAsync(UserId)
			end)
		until Success
	end
	
	if not Lobby then
		-- check private codes

		Success, Lobby = pcall(function()
			return Private_Codes:GetAsync(UserId)
		end)

		if not Success then

			repeat task.wait(4) --changed from 5
				Success, Lobby = pcall(function()
					return Private_Codes:GetAsync(UserId)
				end)
			until Success
		end
		
		if Lobby then
			MMK.Server.Custom.Enabled = true
		end
	end
	
	return Lobby
end

local function SetHosting(Player : Player) : "Set Match as Hosted"
	if MMK.Server.Host.HOSTED then return warn("Already Hosted") end
	
	MMK.Server.Host.ID = Player.UserId
	
	--BUG_READ:FireAllClients(Player.Name..' is now attempting to host!')
	
	local Current_Data = Data_Module:GetRaw(Player, 'Survivor') -->> get our mmk data
	Current_Data = Current_Data.Misc.MMK -->> grab mmk data
	
	MMK.Server.Pro_Only = Current_Data.Pro.Enabled
	
	if MMK.Server.Pro_Only then
		workspace:SetAttribute("Pro_Enabled", true)
	end
	
	if Current_Data.Custom.Enabled then -->> attach custom game data
		MMK.Server.Custom.Enabled = if Player.UserId == 54804102 then false else true
		MMK.Server.Custom.FriendsOnly = Current_Data.Custom.Friend
		MMK.Server.Custom.Password = Current_Data.Custom.Password
		MMK.Server.Custom.Map = Current_Data.Custom.Map
		MMK.Server.Custom.Mode = Current_Data.Custom.Mode
		
		if (not workspace:GetAttribute("TESTING")) then
			workspace:SetAttribute('CUSTOM', true) -->> lets game operate under custom rules

			if MMK.Server.Custom.Map then
				workspace:SetAttribute('CUSTOM_MAP', MMK.Server.Custom.Map)
			end
		end
		
		if MMK.Server.Custom.Mode then
			workspace:SetAttribute("CUSTOM_MODE", MMK.Server.Custom.Mode)
			
			if MMK.Server.Custom.Mode == "2 Killers" then
				MMK.Server.LobbySize.Killers = 2
				MMK.Server.LobbySize.Survivors = 8
			elseif MMK.Server.Custom.Mode == "TOURNAMENT" then
				MMK.Server.LobbySize.Killers = 1
				MMK.Server.LobbySize.Survivors = 5
				workspace:SetAttribute('CUSTOM_MAP', "TOURNAMENT")
			end
		end
	end
	
	MMK.Server.Region = Current_Data.Region -- TODO: Add our region (find through roblox eventually)
	MMK.Server.Code = Current_Data.Code

	--BUG_READ:FireAllClients(tostring(Player) .. ' HOSTED')

	if (MMK.Server.Code and tostring(MMK.Server.Code) ~= '0') or (game:GetService('RunService'):IsStudio()) then
		BUG_READ:FireAllClients("Server is now hosted!")
		MMK.Server.Host.HOSTED = true
	else -- this was not a hosting was failed
		MMK:SHUTDOWN()
	end
end

local function UpdateAmount() : "Update Current Lobby"
	local Killer_Count, Survivor_Count = 0, 0
	
	for _, Player : Player in pairs(game:GetService('Players'):GetPlayers()) do
		
		if MMK.Server.Host.ID == Player.UserId then
			Killer_Count += 1
		else -- they are a survivor
			Survivor_Count += 1
		end
		
		if MMK.Server.QueueList[Player.Name] then
			MMK.Server.QueueList[Player.Name] = nil
		end
	end
	
	for PlayerName, PlayerData in pairs(MMK.Server.QueueList) do

		if (workspace:GetServerTimeNow() - PlayerData.Time) >= 45 then -- took too long
			MMK.Server.QueueList[PlayerName] = nil -- remove it
		end
	end
	
	if MMK.Server.LockedUnder.Leader and MMK.Server.LockedUnder.Leader ~= true then -- it has a leader + a lock
		
		if (workspace:GetServerTimeNow() - MMK.Server.LockedUnder.Time) >= 50 then -- took to long remove the lock
			MMK.Server.LockedUnder.Leader = false
		end
	end
	
	MMK.Server.CurrentLobby.Killers = Killer_Count
	MMK.Server.CurrentLobby.Survivors = Survivor_Count
	
	return Killer_Count, Survivor_Count
end

function MMK:PING() : "Ensures the game was pinged or re-attempts until so."
	if MMK.PingAttempt then return end
	MMK.PingAttempt = true
	local Success, Lobby = false, nil
	
	UpdateAmount() -- update prior to ping
	MMK.Server.LastPing = workspace:GetServerTimeNow() -- updates ping time
	
	local servertype : string = ServerType[tostring(game.PlaceId)]
	
	Success, Lobby = pcall(function()
		return MessengingService:PublishAsync(servertype, Http:JSONEncode(MMK.Server))
	end)

	if not Success then

		repeat task.wait(4) --changed from 5
			Success, Lobby = pcall(function()
				return MessengingService:PublishAsync(servertype, Http:JSONEncode(MMK.Server))
			end)
		until Success
	end
	
	if not game:GetService('RunService'):IsServer() then
		BUG_READ:FireAllClients("Server Updated/PINGED!")
	end
	
	MMK.PingAttempt = false
end

function MMK:SHUTDOWN() : "Shut down server"
	BUG_READ:FireAllClients("Starting Shutdown Process")
	
	MMK.Server.Host.HOSTED = false
	MMK.Server.Host.CLOSED = true
	
	MMK:PING()

	BUG_READ:FireAllClients("Server Shutdown!")
	
	task.wait(1)
	
	for _, Player in pairs(game:GetService('Players'):GetPlayers()) do
		TeleportService:Teleport(Menu_ID, Player)
	end
end

function MMK:Join(Player : Player) : "Player Joined Game"

	if MMK.Server.Host.CLOSED then
		TeleportService:Teleport(Menu_ID, Player) -- send them back
	elseif MMK.Server.Host.HOSTED then
		if MMK.Server.QueueList[Player.Name] then
			MMK.Server.QueueList[Player.Name] = nil
		end
		
		UpdateAmount()
	else
		SetHosting(Player) -- they are the host
	end
end

function MMK:Leave(Player : Player, Closing) : "Player Left Game"
	
	if Player.UserId == MMK.Server.Host.ID then
		MMK:SHUTDOWN()
	else
		UpdateAmount()
	end
end

function MMK:QUEUE(queue : "table") : "Queue up for game"
	
	if queue.Message == "SOLO" and not MMK.Server.LockedUnder.Leader then -- single survivor wants to join
		BUG_READ:FireAllClients("Request to join server from", queue.User)
		
		if (MMK.Server.LobbySize.Survivors + MMK.Server.LobbySize.Killers) - (MMK.Server.CurrentLobby.Survivors + MMK.Server.CurrentLobby.Killers + GetQueue()) >= 1 then
			BUG_READ:FireAllClients("Request Accepted")
			
			MMK.Server.QueueList[queue.User] = {
				Id = queue.Id;
				Time = queue.Time;
			}
			
			MMK:PING() -- let them know asap
		else
			BUG_READ:FireAllClients("===========")
			BUG_READ:FireAllClients("Current Amount:", MMK.Server.LobbySize.Survivors + MMK.Server.LobbySize.Killers)
			BUG_READ:FireAllClients("Current Queued:", GetQueue())
			BUG_READ:FireAllClients("Request Denied not enough space")
		end
		
	elseif queue.Message == "RESERVE" and not MMK.Server.LockedUnder.Leader then -- swf wants in this action
		BUG_READ:FireAllClients("Request to join server as a swf of", queue.Amount, "from", queue.SwfLeader)
		
		MMK.Server.LockedUnder.Leader = true -- set to true b4 id to check
		
		if MMK.Server.LobbySize.Survivors - (MMK.Server.CurrentLobby.Survivors + GetQueue()) >= queue.Amount then
			BUG_READ:FireAllClients("Swf Joining")
			
			MMK.Server.LockedUnder.Time = queue.Time
			MMK.Server.LockedUnder.Leader = queue.SwfLeader

			MMK:PING() -- let them know asap
		else
			BUG_READ:FireAllClients("Request to join server as a swf failed not enough space!")
			MMK.Server.LockedUnder.Leader = false -- undo the lock
		end
	end
end

return MMK
