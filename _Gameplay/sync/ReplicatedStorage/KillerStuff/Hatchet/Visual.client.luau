local Tool = script.Parent

-- Keep Hatchet Visible --
function KeepVisible(part : BasePart) : "Local Trransparency Modifier"
	part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
		part.LocalTransparencyModifier = 0
		part.Transparency = 0
	end)

	part:GetPropertyChangedSignal("Transparency"):Connect(function()
		part.LocalTransparencyModifier = 0
		part.Transparency = 0
	end)
	part.Transparency = 0
	part.LocalTransparencyModifier = 0
end

for _, object in pairs(Tool:GetChildren()) do
	if object:IsA('BasePart') then
		KeepVisible(object)
	end
end

--6648492342