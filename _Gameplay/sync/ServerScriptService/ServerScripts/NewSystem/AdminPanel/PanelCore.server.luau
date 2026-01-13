local UIS = game:GetService("UserInputService")
local OpenPanel = script.Parent.OpenPanel
local Main = script.Parent.Main

local mouseBehavior = false

local Modules = {
	PlayerList = require(script.PlayerList);
	ActionPanel = require(script.ActionPanel);
	Notification = require(script.Notification);
}

function InputDown(inputObj: InputObject, processed: boolean)
	
	if (inputObj.KeyCode.Value ~= Enum.KeyCode.F2.Value) then
		return
	end
	
	ToggleView()
end

function OpenButtonDown()
	ToggleView()
end

function ToggleView()
	
	if (not Main.Visible) then
		mouseBehavior = UIS.MouseBehavior
		UIS.MouseBehavior = Enum.MouseBehavior.Default
		UIS.MouseIconEnabled = true
	else
		UIS.MouseBehavior = mouseBehavior
		UIS.MouseIconEnabled = if (mouseBehavior ~= Enum.MouseBehavior.Default) then false else true
	end
	
	Main.Visible = not Main.Visible
	Modules.PlayerList.CreateList()	
end

Modules.PlayerList.Init(Modules)
Modules.ActionPanel.Init(Modules)
Modules.Notification.Init()

UIS.InputBegan:Connect(InputDown)
OpenPanel.Activated:Connect(OpenButtonDown)