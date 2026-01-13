local Replicated = game.ReplicatedStorage
local RemoteEvents = Replicated.RemoteEvents
local BrowserEvent = RemoteEvents.BrowserEvent

local MemoryStoreService = game:GetService("MemoryStoreService")
local PrivateStore = MemoryStoreService:GetSortedMap("PrivateCodes")
local Queue = MemoryStoreService:GetSortedMap("CustomGames")

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local Data_Module = require(Replicated:WaitForChild('Modules'):WaitForChild('Data'))

local QueueTable = {
	UserID = 0,
	ServerID = 0,
	Type = "TYPE"
}

local PlaceIDs = {
	["SWF"] = 14904835144,
	["Custom"] = 14904829680,
	["PTB"] = 15091839543,
}

local Tester_Boolean : boolean = workspace:GetAttribute('TESTER_ONLY')
local TesterOnly = {"PTB"}

local this = {}

function this:checkForTester(Player) : "True if can test"
	
	if Tester_Boolean and (not Data_Module:GetPermission("Testing", Player)) then
		local ServerMenu = Player.PlayerGui.CustomGame
		local Hub = ServerMenu.Hub
		
		if Hub:FindFirstChild('Tester Servers') then
			Hub['Tester Servers']:Remove()
		end
		
		return false
	end
	
	return true
end

function this:sendToTestServer(Player, Type)
	if not this:checkForTester(Player) then return warn("Testers Only!") end
	
	local NewTable = QueueTable
	NewTable.UserID = Player.UserId
	NewTable.Type = Type

	local ReservedServer = TeleportService:ReserveServerAsync(PlaceIDs[Type])
	NewTable.ServerID = ReservedServer

	PrivateStore:SetAsync(Player.UserId, ReservedServer, 90)
	Queue:SetAsync(Player.UserId, NewTable, 90)
	TeleportService:TeleportToPrivateServer(PlaceIDs[Type], ReservedServer, {Player})
	
end

function this:createLobby(Player, Username, UserID)
	local ServerMenu = Player.PlayerGui.CustomGame
	local Browser = ServerMenu.Browser
	local Prefab = script.Prefab
	
	local NewLobby = Prefab:Clone()
	NewLobby.Name = Username
	NewLobby.PlayerName.Text = Username
	NewLobby.Parent = Browser.Lobbies
	
	this:setupLobbyElement(Player, NewLobby, UserID)
end

function this:setupLobbyElement(Player, UIElement, UserID)
	local LobbyArray = this:getFromQueue(UserID)
	local PlaceID = PlaceIDs[LobbyArray.Type]
	local ServerID = LobbyArray.ServerID
	
	if Tester_Boolean and (table.find(TesterOnly, LobbyArray.Type)) then
		
		if not this:checkForTester(Player) then
			return UIElement:Destroy()
		end
	end
	
	UIElement.Type.Text = LobbyArray.Type
	
	UIElement.Join.MouseButton1Click:Connect(function()
		if (LobbyArray.Type == "SWF") then
			TeleportService:TeleportToPrivateServer(PlaceID, ServerID, {Player}, "SWF")
		else
			TeleportService:TeleportToPrivateServer(PlaceID, ServerID, {Player})
		end
	end)
	
	UIElement.Visible = true
end

function this:addToQueue(UserID, Type)
	local NewTable = QueueTable
	NewTable.UserID = UserID
	NewTable.Type = Type
	
	local ReservedServer = TeleportService:ReserveServerAsync(PlaceIDs[Type])
	NewTable.ServerID = ReservedServer
	
	TeleportService:TeleportToPrivateServer(PlaceIDs[Type], ReservedServer, {Players:GetPlayerByUserId(UserID)}, if (Type == "SWF") then "SWF" else nil)
	
	PrivateStore:SetAsync(UserID, ReservedServer, 90)
	Queue:SetAsync(UserID, NewTable, 90)
end

function this:getFromQueue(UserID)
	local success, result = pcall(function() 
		Queue:GetAsync(UserID) 
	end)
	
	if (success) then
		return Queue:GetAsync(UserID)
	end
	
	return nil
end

return this
