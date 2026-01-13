Light = script.Parent.PointLight
Part = script.Parent

while task.wait(1) do
	Light.Color = Color3.fromRGB(0, 25, 255)
	Part.Color = Color3.fromRGB(0, 25, 255)
	task.wait(1)
	Light.Color = Color3.fromRGB(255, 0, 0)
	Part.Color = Color3.fromRGB(179, 0, 0)
end