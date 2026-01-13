
local function BindToVisible(Part)
	Part:GetPropertyChangedSignal("Transparency"):Connect(function()
		Part.LocalTransparencyModifier = Part.Transparency
	end)
	
	Part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
		Part.LocalTransparencyModifier = Part.Transparency
	end)
	
	Part.LocalTransparencyModifier = Part.Transparency
end

for _, child in pairs(script.Parent:GetChildren()) do
	
	if child:IsA('BasePart') then
		BindToVisible(child)
	end
end