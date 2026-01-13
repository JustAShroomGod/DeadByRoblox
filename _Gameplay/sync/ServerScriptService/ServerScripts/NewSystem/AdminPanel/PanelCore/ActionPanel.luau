local RemotesArea = game.ReplicatedStorage:WaitForChild("RemoteEvents")
local AdminEvents = RemotesArea:WaitForChild("AdminEvents")

local Main = script.Parent.Parent.Main
local PanelFrame = Main.ActionInfoPanel

local ActionPanel = {}

ActionPanel.Modules = {}
ActionPanel.Connections = {}
ActionPanel.CurrentPlayer = nil
ActionPanel.CurrentPlayerID = nil
ActionPanel.CurrentName = nil
ActionPanel.ExcludeAlts = false

function ActionPanel.Init(ModuleList: "table")
	ActionPanel.Modules = ModuleList
	
	PanelFrame.Kick.Activated:Connect(function()
		
		if (ActionPanel.CurrentPlayer == nil) then
			return ActionPanel.Modules.Notification.ShowError("Invalid Player")
		end
		
		AdminEvents:FireServer("Kick",
			ActionPanel.CurrentPlayerID,
			-1,
			PanelFrame.InfoComponent_Reason.TextField.Text,
			PanelFrame.InfoComponent_Notes.TextField.Text,
			ActionPanel.ExcludeAlts
		)
		
		ActionPanel.Modules.Notification.ShowSuccess(`Kicked "{ActionPanel.CurrentName}" Successfully`)
		ActionPanel.HideActionPanel()
		ActionPanel.Modules.PlayerList.CreateList()
	end)
	
	PanelFrame.Ban.Activated:Connect(function()
		
		if (tonumber(PanelFrame.InfoComponent_Duration.TextField.Text) == nil) then
			ActionPanel.Modules.Notification.ShowError("Invalid Duration")
			return
		end
		
		AdminEvents:FireServer("Ban",
			ActionPanel.CurrentPlayerID,
			tonumber(PanelFrame.InfoComponent_Duration.TextField.Text) * 60 * 60,
			PanelFrame.InfoComponent_Reason.TextField.Text,
			PanelFrame.InfoComponent_Notes.TextField.Text,
			ActionPanel.ExcludeAlts
		)
		
		ActionPanel.Modules.Notification.ShowSuccess(`Banned "{ActionPanel.CurrentName}" Successfully`)
		ActionPanel.HideActionPanel()
		ActionPanel.Modules.PlayerList.CreateList()
	end)
	
	PanelFrame.Unban.Activated:Connect(function()
		
		AdminEvents:FireServer("Unban",
			ActionPanel.CurrentPlayerID,
			0,
			PanelFrame.InfoComponent_Reason.TextField.Text,
			PanelFrame.InfoComponent_Notes.TextField.Text,
			ActionPanel.ExcludeAlts
		)

		ActionPanel.Modules.Notification.ShowSuccess(`Unbanned "{ActionPanel.CurrentName}" Successfully`)
		ActionPanel.HideActionPanel()
		ActionPanel.Modules.PlayerList.CreateList()
	end)
	
	PanelFrame.InfoComponent_ExcludeAlts.ToggleButton.Activated:Connect(function()
		ActionPanel.ExcludeAlts = not ActionPanel.ExcludeAlts
		PanelFrame.InfoComponent_ExcludeAlts.ToggleButton.Text = (ActionPanel.ExcludeAlts == true) and "Yes" or "No"
	end)
	
end

function ActionPanel.GetInfoByID(playerId: number)
	
	if (playerId == nil) then
		return ActionPanel.Modules.Notification.ShowError("Invalid ID")
	end
	
	local playerName = nil
	local player = nil

	local success, _ = pcall(function()
		playerName = game:GetService("Players"):getNameFromUserIdAsync(playerId)
	end)

	if (not success) then
		return ActionPanel.Modules.Notification.ShowError("Invalid ID")
	end

	local success, _ = pcall(function()
		player = game:GetService("Players"):GetPlayerByUserId(playerId)
	end)
	
	return player, playerName, playerId
end

function ActionPanel.GetInfoByName(playerName: string)
	
	if (playerName == nil or playerName == "") then
		return ActionPanel.Modules.Notification.ShowError("Invalid Name")
	end
	
	local playerId = nil
	local player = nil
	
	local success, _ = pcall(function()
		playerId = game:GetService("Players"):GetUserIdFromNameAsync(playerName)
	end)
	
	if (not success) then
		return ActionPanel.Modules.Notification.ShowError("Invalid Name")
	end

	local success, _ = pcall(function()
		player = game:GetService("Players"):GetPlayerByUserId(playerId)
	end)
	
	return player, playerName, playerId
end

function ActionPanel.ShowActionPanel(player: Player, name, id)
	
	ActionPanel.CurrentPlayerID = id
	ActionPanel.CurrentPlayer = player
	ActionPanel.CurrentName = name
	
	PanelFrame.Visible = true
	PanelFrame.Username.Text = "Username: " .. name
	PanelFrame.PlayerID.Text = "UserID: " .. id	
	
	PanelFrame.Kick.Visible = player ~= nil
end

function ActionPanel.HideActionPanel()
	PanelFrame.Visible = false
	PanelFrame.InfoComponent_Notes.TextField.Text = ""
	PanelFrame.InfoComponent_Reason.TextField.Text = ""
	PanelFrame.InfoComponent_Duration.TextField.Text = ""
	PanelFrame.InfoComponent_ExcludeAlts.ToggleButton.Text = "No"
	ActionPanel.ExcludeAlts = false
end

return ActionPanel
