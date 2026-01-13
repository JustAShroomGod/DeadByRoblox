local LocalPlayer = game.Players.LocalPlayer
local ServerMenu = LocalPlayer.PlayerGui.CustomGame
local ChooseBand = LocalPlayer.PlayerGui:WaitForChild('ChooseBand')
local Browser = ServerMenu.Browser
local Hub = ServerMenu.Hub

local UserInputService = game:GetService("UserInputService")


local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

--TeleportService:TeleportPartyAsync(17105536841, {game.Players.cheetamcu, game.Players.PlsGiveMe_ATaco})




local Replicated = game.ReplicatedStorage
local RemoteEvents = Replicated.RemoteEvents
local BrowserEvent = RemoteEvents.BrowserEvent

local RoleText = "Selected Role: \n"
local RoleToSend = "Killer" -- start on Killer

local Heartbeat = nil
local RefreshTime = 10

local Descriptions = {
	["Host"] = {"<b>Custom Game</b>", "\n Play as a Killer against your Friends or try to survive with them."},
	["Create"] = {"<b>Survive with Friends</b>",  "\n Play together with your Friends and try to survive the Killer."},
	["Join"] = {"<b>Join Game</b>", "\n Join your Friends in an already existing Custom Game/SWF Lobby"},
	["Tester Servers"] = {"<b>Test Servers</b>", "\n Creates a Public Test Server of the next Update."},
}



function refreshBrowser(SetRole)
	if (not Browser.Visible) then
		return
	end

	SetRole = SetRole or false

	BrowserEvent:FireServer("Reset")

	local Friends = LocalPlayer:GetFriendsOnline()

	if (Friends) then
		
		for index, friend in pairs(Friends) do
			if not friend.IsOnline then continue end
			
			if (friend.LocationType == 5) or (friend.LocationType == 4) then
				BrowserEvent:FireServer(friend.DisplayName, friend.VisitorId, RoleToSend)
			end
		end
	end

	if (SetRole) then
		TeleportService:SetTeleportSetting("MatchmakingData", if (RoleToSend == "Survivor") then {"Survivor"} else {"Killer"})
		TeleportService:SetTeleportSetting("GlobalGameContext", "in_game_" .. RoleToSend:lower())
	end

	BrowserEvent:FireServer(LocalPlayer.Name, LocalPlayer.UserId)
end

function hookHeartbeat()
	Heartbeat = RunService.Heartbeat:Connect(function(delta)
		RefreshTime -= delta

		if (RefreshTime <= 0) then
			RefreshTime = 10
			refreshBrowser(false)
		end

	end)
end

function ShowBrowser()
	ClickSurvivor() -- autoswitch to survivor when clicking browser / if not clicked browser they will be set to killer by default so creating servers will assign killer unless manually swapped to survivor (flows the best)
	Hub.Visible = false
	Browser.Visible = true
end

function ShowHub()
	Hub.Visible = true
	Browser.Visible = false
end

function ClickHost()
	BrowserEvent:FireServer("Host", "Custom", RoleToSend)
	TeleportService:SetTeleportSetting("MatchmakingData", if (RoleToSend == "Survivor") then {"Survivor"} else {"Killer"})
	TeleportService:SetTeleportSetting("GlobalGameContext", "in_game_" .. RoleToSend:lower())
end

function ClickCreate()
	BrowserEvent:FireServer("Host", "SWF", "Survivor")
	TeleportService:SetTeleportSetting("MatchmakingData", {"Survivor"})
	TeleportService:SetTeleportSetting("GlobalGameContext", "in_game_survivor")
end

function ClickTesterHub()
	BrowserEvent:FireServer("Test", "PTB", RoleToSend)
	TeleportService:SetTeleportSetting("MatchmakingData", if (RoleToSend == "Survivor") then {"Survivor"} else {"Killer"})
	TeleportService:SetTeleportSetting("GlobalGameContext", "in_game_" .. RoleToSend:lower())
end

function ClickKiller()
	RoleToSend = "Killer"
	Browser.Selection.Killer.BackgroundColor3 = Color3.new(0.0392157, 0.529412, 0.741176)
	Browser.Selection.Survivor.BackgroundColor3 = Color3.new(0.223529, 0.223529, 0.223529)
	refreshBrowser(true)
end

function ClickSurvivor()
	RoleToSend = "Survivor"
	Browser.Selection.Survivor.BackgroundColor3 = Color3.new(0.0392157, 0.529412, 0.741176)
	Browser.Selection.Killer.BackgroundColor3 = Color3.new(0.223529, 0.223529, 0.223529)
	refreshBrowser(true)
end

function Close()
	ShowHub()
	ServerMenu.Enabled = false
	ChooseBand.Enabled = true
	game.Players.LocalPlayer.Character.PrimaryPart.Anchored = false
end

function init()
	Browser.Settings.Refresh.MouseButton1Click:Connect(refreshBrowser)
	Browser.Selection.Survivor.MouseButton1Click:Connect(ClickSurvivor)
	Browser.Selection.Killer.MouseButton1Click:Connect(ClickKiller)
	Browser.Settings.Hub.MouseButton1Click:Connect(ShowHub)
	Hub["Tester Servers"].MouseButton1Click:Connect(ClickTesterHub)

	BrowserEvent:FireServer("Check")

	for i, v in pairs(Descriptions) do
		local HubButton: TextButton = Hub[i]

		HubButton.MouseEnter:Connect(function()
			Hub.Separator.Title.Text = v[1]
			Hub.Separator.Description.Text = v[2]
		end)
	end


	hookHeartbeat()
end

init()

Hub.Separator.Back.Button.MouseButton1Click:Connect(Close)
Hub.Join.MouseButton1Click:Connect(ShowBrowser)
Hub.Create.MouseButton1Click:Connect(ClickCreate)
Hub.Host.MouseButton1Click:Connect(ClickHost)