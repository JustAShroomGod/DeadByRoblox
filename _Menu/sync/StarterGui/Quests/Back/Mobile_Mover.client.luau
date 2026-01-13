local UIS = game:GetService('UserInputService')
local New_Position = UDim2.new(0.35, 0, 0.8, 0)

if UIS.TouchEnabled then
	script.Parent.Position = New_Position
end