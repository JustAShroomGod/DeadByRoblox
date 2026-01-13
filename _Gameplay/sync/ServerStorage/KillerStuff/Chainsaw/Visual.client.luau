local Tool = script.Parent

-- Keep Chainsaw Visible --
local function KeepVisible(part : BasePart) : "Local Trransparency Modifier"
	part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
		part.LocalTransparencyModifier = 0
	end)

	part.LocalTransparencyModifier = 0
end

for _, object in pairs(Tool:WaitForChild('BodyParts'):GetChildren()) do
	if object:IsA('BasePart') then
		KeepVisible(object)
	end
end