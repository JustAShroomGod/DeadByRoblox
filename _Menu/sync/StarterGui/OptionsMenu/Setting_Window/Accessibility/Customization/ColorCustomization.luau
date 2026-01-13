local Player = game.Players.LocalPlayer

local UIS = game:GetService("UserInputService")
local Data = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))

local Customizaton = script.Parent
local Selection = script.Parent.Parent.Selection

local R, G, B = Customizaton.Red, Customizaton.Green, Customizaton.Blue
	
local MouseDown = false

local ActiveSlider = {
	Object = nil;
	Index = 0;
}

local ColorCustomization = {}

ColorCustomization.Current = {
	Prefab = nil; -- Prefab of Aura Setting
	Side = ""; -- Killer/Survivor 
	Type = ""; -- Outline/Fill
	ColorArray = {} -- RGB Values
}

function ColorCustomization.ResetCustomization()
	ColorCustomization.Current = {
		Prefab = nil; 
		Side = ""; 
		Type = ""; 
		ColorArray = {} 
	}
end

function ColorCustomization.SaveCustomization()
	Data:SetColor(ColorCustomization.Current.Side, ColorCustomization.Current.Prefab.Name, ColorCustomization.Current.Type, ColorCustomization.Current.ColorArray)

	local prefab = ColorCustomization.Current.Prefab
	local colorButton = if (ColorCustomization.Current.Type == "Outline") then prefab.OutlineColor else prefab.FillColor

	colorButton.BackgroundColor3 = Color3.fromRGB(
		ColorCustomization.Current.ColorArray[1], 
		ColorCustomization.Current.ColorArray[2], 
		ColorCustomization.Current.ColorArray[3]
	)

	ColorCustomization.ResetCustomization()
end

function ColorCustomization.SetCustomize(prefab, side, type, array)
	
	ColorCustomization.Current = {
		Prefab = prefab;
		Side = side;
		Type = type;
		ColorArray = array
	}
	
	InitSlider(R, 1)
	InitSlider(G, 2)
	InitSlider(B, 3)
	
	ColorCustomization.SetSlider(R, array[1])
	ColorCustomization.SetSlider(G, array[2])
	ColorCustomization.SetSlider(B, array[3])
	
	ColorCustomization.SetResult()
	UIS.InputEnded:Connect(InputEnded)
	UIS.InputChanged:Connect(InputChanged)
end

function ColorCustomization.SetSlider(Slider, Value)
	Slider.Needle.Position = UDim2.fromScale(1 / 255 * Value, 0.5)
end

function ColorCustomization.SetResult()
	Customizaton.Result.BackgroundColor3 = Color3.fromRGB(
		ColorCustomization.Current.ColorArray[1], 
		ColorCustomization.Current.ColorArray[2], 
		ColorCustomization.Current.ColorArray[3]
	)
end

function InitSlider(Slider, ArrayIndex)
	
	local Needle: ImageButton = Slider.Needle
	
	Needle.MouseButton1Down:Connect(function()
		
		MouseDown = true
		
		ActiveSlider = {
			Object = Slider;
			Index = ArrayIndex;
		}
	end)
	
end

function InputChanged(input)
	
	if (ActiveSlider.Object == nil or not MouseDown) then
		return
	end
	
	if (input.UserInputType ~= Enum.UserInputType.MouseMovement 
		and input.UserInputType ~= Enum.UserInputType.Touch 
		and not (input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.Thumbstick1)) then
		
		return
	end
	
	local Mouse_Location = UIS:GetMouseLocation()

	local Scale = Vector2.new(Mouse_Location.X, Mouse_Location.Y)
	Scale = Scale - ActiveSlider.Object.AbsolutePosition -- offsets the parent
	Scale = Scale / ActiveSlider.Object.AbsoluteSize -- offsets the size giving us proper scale

	Scale = math.clamp(Scale.X, 0.01, 1)
	ActiveSlider.Object.Needle.Position = UDim2.fromScale(Scale, 0.5)
	
	ColorCustomization.Current.ColorArray[ActiveSlider.Index] = (255 * Scale)
	ColorCustomization.SetResult()
end

function InputEnded(input)
	
	if (input.UserInputType ~= Enum.UserInputType.MouseButton1 
		and input.UserInputType ~= Enum.UserInputType.Touch 
		and not (input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonA)) then
		
		return
	end
	
	MouseDown = false

	ActiveSlider = {
		Object = nil;
		Index = 0;
	}
	
end

return ColorCustomization
