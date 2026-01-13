local Data = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))
local Slider_Module = require(script:WaitForChild('Slider'))

local Slider_1, Slider_2 = script.Parent:WaitForChild('Slider_1'), script.Parent:WaitForChild('Slider_2')
local Slider_X, Slider_Y = Slider_Module.new(Slider_1), Slider_Module.new(Slider_2)

local IsSliding, Slider, Slide_Object = false, nil, nil
local Current_Settings = Data:GetSettings().CAMERA.Sensitivity

Slider_1:WaitForChild('Slide').Position = UDim2.new(Current_Settings.X/10, 0, 0.5, 0)
Slider_2:WaitForChild('Slide').Position = UDim2.new(Current_Settings.Y/10, 0, 0.5, 0)

Slider_1:WaitForChild('Slide'):WaitForChild('Sens').Text = math.floor((Current_Settings.X * 100) + 0.5)/100
Slider_2:WaitForChild('Slide'):WaitForChild('Sens').Text = math.floor((Current_Settings.Y * 100) + 0.5)/100

Slider_1:WaitForChild('Slide').MouseButton1Down:Connect(function()
	IsSliding = true
	Slider = Slider_1
	Slide_Object = Slider_X
end)

Slider_2:WaitForChild('Slide').MouseButton1Down:Connect(function()
	IsSliding = true
	Slider = Slider_2
	Slide_Object = Slider_Y
end)

game:GetService('UserInputService').InputChanged:Connect(function(input)
	if not IsSliding or not Slider or not Slide_Object then return end
	
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch or (input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.Thumbstick1) then
		local Mouse_Location = game:GetService('UserInputService'):GetMouseLocation()
		
		local Scale = Vector2.new(Mouse_Location.X, Mouse_Location.Y)
		Scale = Scale - Slider.AbsolutePosition -- offsets the parent
		Scale = Scale/Slider.AbsoluteSize -- offsets the size giving us proper scale
		
		Scale = math.clamp(Scale.X, 0.01, 1) -- clamp it
		
		Slide_Object:Slide(UDim2.new(Scale, 0, 0.5, 0))
		
		Slider:WaitForChild('Slide'):WaitForChild('Sens').Text = math.floor((Scale * 100) + 0.5)/10
	end
end)

game:GetService('UserInputService').InputEnded:Connect(function(input)
	if not IsSliding then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or (input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonA) then
		IsSliding = false
		Slider = nil
		Slide_Object = nil
		
		Data:Set_Sens(Vector2.new(Slider_1:WaitForChild('Slide').Position.X.Scale, Slider_2:WaitForChild('Slide').Position.X.Scale))
	end
end)