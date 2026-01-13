local Object = {}

function Object:Spawn(Objects : Folder, Version : number) : "Spawn this item type into map"

	for _, Location : Instance in pairs(Objects:GetChildren()) do
		if Location:GetAttribute("Version") and Location:GetAttribute("Version") ~= Version then continue end
		--
		Location.Parent = workspace
	end
end

return Object
