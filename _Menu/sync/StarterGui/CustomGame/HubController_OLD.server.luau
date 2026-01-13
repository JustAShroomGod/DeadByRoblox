local Replicated = game.ReplicatedStorage
local RemoteEvents = Replicated.RemoteEvents
local BrowserEvent = RemoteEvents.BrowserEvent

local BrowserLobby = require(game.ServerScriptService.CustomGames.BrowserLobby)

function onBrowserEvent(Player, Username, UserID)
	
	local PlayerGui = Player.PlayerGui
	local ServerMenu = PlayerGui.CustomGame
	local Browser = ServerMenu.Browser
	local Lobbies = Browser.Lobbies
	
	if (Username == "Reset") then
		resetBrowser(Lobbies)
		return
	end
	
	if (Username == "Host") then
		BrowserLobby:addToQueue(Player.UserId, UserID)
		return
	end
	
	if (Username == "Test") then
		BrowserLobby:sendToTestServer(Player, UserID)
		return
	end
	
	if (Username == "Check") then
		BrowserLobby:checkForTester(Player)
		return
	end
	
	if (BrowserLobby:getFromQueue(UserID) ~= nil) then
		BrowserLobby:createLobby(Player, Username, UserID)
	end
	
end

function resetBrowser(Lobbies)
	for i, v in pairs(Lobbies:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
end

BrowserEvent.OnServerEvent:Connect(onBrowserEvent)