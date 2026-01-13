local UIS = game:GetService("UserInputService")

local RemotesArea = game.ReplicatedStorage:WaitForChild("RemoteEvents")
local DevEvents = RemotesArea:WaitForChild("DevEvents")

local OpenPanel = script.Parent.OpenPanel
local Main = script.Parent.Main
local ChooseEnabled = false
local TitleToggle = false

local Modules = {
	PlayerList = require(script.PlayerList);
	ActionPanel = require(script.ActionPanel);
	Notification = require(script.Notification);
}

function InputDown(inputObj: InputObject, processed: boolean)
	
	if (inputObj.KeyCode.Value == Enum.KeyCode.T.Value and not processed) then
		ToggleTitle()
		return
	end
	
	if (inputObj.KeyCode.Value ~= Enum.KeyCode.F2.Value) then
		return
	end
	
	ToggleView()
end

function OpenButtonDown()
	ToggleView()
end

function ToggleTitle()
	TitleToggle = not TitleToggle
	DevEvents:FireServer("Title", TitleToggle)
end

function ToggleView()
	
	local chooseBand = game.Players.LocalPlayer.PlayerGui.ChooseBand
	
	if (Main.Visible == false) then
		ChooseEnabled = chooseBand.Enabled
	end
	
	Main.Visible = not Main.Visible
	chooseBand.Enabled = if (Main.Visible == false) then ChooseEnabled else false
	Modules.PlayerList.CreateList()	
end

Modules.PlayerList.Init(Modules)
Modules.ActionPanel.Init(Modules)
Modules.Notification.Init()

UIS.InputBegan:Connect(InputDown)
OpenPanel.Activated:Connect(OpenButtonDown)