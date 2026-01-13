local ReplicatedStorage = game:GetService('ReplicatedStorage')
local plr = game.Players.LocalPlayer
local playerGui = plr:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild('RemoteEvents')
local Frame = script.Parent
local Buttons = Frame.Parent:WaitForChild("Selector")
local ScrollingBox = Frame:WaitForChild('Messages')
local Exit = Frame:WaitForChild('OK')


--[[function ClearBox()
	for _,gui in pairs(ScrollingBox:GetChildren())do
		if not gui:IsA('UIListLayout') then
			gui:Destroy() -- remove anything that isn't the uilist layout
		end
	end
end
function AddToBox(tablev)
	ClearBox() -- clear the ui first
	
	local Template = Instance.new('TextLabel')
	Template.BackgroundTransparency = 1
	Template.Size = UDim2.new(0.95,0,0.05,0)
	Template.Font = Enum.Font.Arial
	Template.TextColor3 = Color3.fromRGB(255,255,255)
	Template.TextSize = 18
	Template.TextStrokeTransparency = 0.9
	Template.ZIndex = 2
	Template.TextScaled = false
	Template.TextWrapped = true
	Template.TextXAlignment = Enum.TextXAlignment.Left
	Template.TextYAlignment = Enum.TextYAlignment.Top
	
	for _,message in pairs(tablev) do
		local I = Template:Clone()
		I.Text = message
		I.Parent = ScrollingBox
	end
end


Remotes.MessageUpdate.OnClientEvent:Connect(function(setting, value)
	if setting == 'NewMessage' then
		Buttons.Visible = false
		Exit.Visible = false
		AddToBox(value)
		Frame.Visible = true
		wait(5)
		Exit.Visible = true
	end
end)]]

ScrollingBox:WaitForChild("Text").RichText = true
ScrollingBox:WaitForChild("Text").Text = require(ReplicatedStorage:WaitForChild("PatchNotes").PatchNote).Content

--[[ScrollingBox.MouseWheelBackward:Connect(function()
	ScrollingBox.CanvasSize = ScrollingBox.CanvasSize + UDim2.new(0,0,5,0)
end)]]

Exit.MouseButton1Click:Connect(function()
	Frame.Visible = false -- close frame
	Buttons.Visible = true
end)
