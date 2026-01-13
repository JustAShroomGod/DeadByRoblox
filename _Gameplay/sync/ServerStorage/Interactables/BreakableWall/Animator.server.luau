local Audio_Source = script.Parent:WaitForChild('Collision')
local Broken = false

local Connection = script.Parent:WaitForChild('Panel'):WaitForChild('Broken'):GetPropertyChangedSignal("Value")
Connection:Once(function()
	if Broken then return end
	
	if script.Parent.Panel.Broken.Value then
		Broken = true
		
		script.Parent:WaitForChild('Planks'):Remove()
		script.Parent:WaitForChild('Studs'):Remove()
		script.Parent:WaitForChild('Wooden'):Remove()
		
		Audio_Source:WaitForChild('SecondKickSound'):Play()
		Audio_Source:WaitForChild('SecondKickBackground'):Play()
		
		Audio_Source.CanCollide = false
	end
end)