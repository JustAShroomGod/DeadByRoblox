local Players = game:GetService("Players")

local Main = script.Parent.Parent.Main
local Prefab = Main.PlayerList.Prefab
local ListFrame = Main.PlayerList

local PlayerList = {}

PlayerList.Modules = {}
PlayerList.Connections = {}

function PlayerList.Init(ModuleList: "table")
	PlayerList.Modules = ModuleList
	
	ListFrame.SearchID.Enter.Activated:Connect(function()
		local player, name, id = PlayerList.Modules.ActionPanel.GetInfoByID(tonumber(ListFrame.SearchID.TextField.Text))
		
		if (player == nil and name == nil and id == nil) then
			return
		end
		
		PlayerList.Modules.ActionPanel.ShowActionPanel(player, name, id)
	end)
	
	ListFrame.SearchName.Enter.Activated:Connect(function()
		local player, name, id = PlayerList.Modules.ActionPanel.GetInfoByName(ListFrame.SearchName.TextField.Text)
		
		if (player == nil and name == nil and id == nil) then
			return
		end
		
		PlayerList.Modules.ActionPanel.ShowActionPanel(player, name, id)
	end)
	
end

function PlayerList.CreateList()
	
	for index, child in pairs(ListFrame:GetChildren()) do
		if (not child:IsA("ImageButton") or child.Name == "Prefab") then
			continue
		end

		child:Destroy()
	end
	
	for index, connection in pairs(PlayerList.Connections) do
		connection:Disconnect()
		connection = nil
		PlayerList.Connections[index] = nil
	end
	
	for index, player in pairs(Players:GetPlayers()) do
		if (PlayerList.Connections["Player_" .. player.UserId] ~= nil) then
			continue
		end
		
		local newPrefab = Prefab:Clone()
		newPrefab.Name = player.UserId
		newPrefab.Username.Text = player.Name
		newPrefab.Parent = ListFrame
		
		newPrefab.Avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size100x100)
		
		PlayerList.Connections["Player_" .. player.UserId] = newPrefab.Activated:Connect(function()
			PlayerList.Modules.ActionPanel.ShowActionPanel(player, player.Name, player.UserId)
		end)
		
		newPrefab.Visible = true
	end
end

return PlayerList
