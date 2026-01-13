local Debounce = false
local Reset_Point = script.Parent.Parent:WaitForChild('Reset')

script.Parent.Touched:Connect(function(part)
	if Debounce then return end
	Debounce = true
	
	local Humanoid = part.Parent:FindFirstChildOfClass('Humanoid')
	
	if Humanoid then
		Humanoid.Parent:PivotTo(Reset_Point:GetPivot())
	end
	
	Debounce = false
end)