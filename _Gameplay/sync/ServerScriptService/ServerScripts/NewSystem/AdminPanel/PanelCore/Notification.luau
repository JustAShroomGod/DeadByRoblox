local RunService = game:GetService("RunService")

local Main = script.Parent.Parent.Main
local NotifiyFrame = Main.Notification

local Notification = {}

Notification.Timer = 0

function Notification.Init()
	RunService.Heartbeat:Connect(Update)
end

function Notification.ShowSuccess(message: string)
	NotifiyFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	NotifiyFrame.UIStroke.Color = Color3.fromRGB(0, 170, 0)
	NotifiyFrame.Message.Text = message
	Notification.Timer = 2.5
end

function Notification.ShowError(message: string)
	NotifiyFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	NotifiyFrame.UIStroke.Color = Color3.fromRGB(170, 0, 0)
	NotifiyFrame.Message.Text = message
	Notification.Timer = 2.5
end

function Update(delta)
	NotifiyFrame.Visible = Notification.Timer > 0
	Notification.Timer -= delta
end

return Notification
