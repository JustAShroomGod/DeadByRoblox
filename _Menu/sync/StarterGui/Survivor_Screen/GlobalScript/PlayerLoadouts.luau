local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Prefab = script.Prefab
local Remote = game.ReplicatedStorage.RemoteEvents.PlayerLoadouts

local Content = PlayerGui.Survivor_Screen.Content
local PlayerLoadoutsScreen = Content.PlayerLoadouts

local Save_Button = PlayerLoadoutsScreen.Save
local Save_NameField = PlayerLoadoutsScreen.NameBox
local ScrollingList = PlayerLoadoutsScreen.ScrollingFrame

local ConfirmationDialogue = require(PlayerGui.HUD.Confirmation)

local Connected = false

local PlayerLoadouts = {}

function PlayerLoadouts:Connect()
	
	if (Connected) then
		return
	end
	
	Connected = true
	
	Save_Button.MouseButton1Click:Connect(function()
		local loadoutList = Remote:InvokeServer("Save", script:GetAttribute("KillerSide"), Save_NameField.Text)
		PlayerLoadouts:BuildList(loadoutList)
	end)
	
	PlayerLoadoutsScreen:GetPropertyChangedSignal("Visible"):Connect(function()
		PlayerLoadouts:Clear()
	end)
	
end

function PlayerLoadouts:RequestLoadouts()
	
	local loadoutList = Remote:InvokeServer("Request", script:GetAttribute("KillerSide"))
	PlayerLoadouts:BuildList(loadoutList)
	
end

function PlayerLoadouts:Clear()
	for _, obj in pairs(ScrollingList:GetChildren()) do
		if (not obj:isA("Frame")) then
			continue
		end
		
		obj:Destroy()
	end
end

function PlayerLoadouts:BuildList(loadoutList: "table")
	
	PlayerLoadouts:Clear()
	
	for name, loadout in pairs(loadoutList) do
		local newEntry = Prefab:Clone()
		newEntry.LoadoutName.Text = name
		newEntry.Parent = ScrollingList
		
		newEntry.Load.MouseButton1Click:Connect(function()
			Remote:InvokeServer("Load", script:GetAttribute("KillerSide"), name)
		end)
		
		newEntry.Delete.MouseButton1Click:Connect(function()
			
			local function Cancel()
				Content.Parent.Enabled = true
			end
			
			local function Delete()
				local loadoutList = Remote:InvokeServer("Delete", script:GetAttribute("KillerSide"), name)
				PlayerLoadouts:BuildList(loadoutList)
				Content.Parent.Enabled = true
			end
			
			Content.Parent.Enabled = false
			ConfirmationDialogue.new(`Delete Loadout "{name}"`, `Are you sure you want to delete the following Loadout:\n\n"{name}"`, Delete, Cancel)
		end)
	end
	
end

return PlayerLoadouts
