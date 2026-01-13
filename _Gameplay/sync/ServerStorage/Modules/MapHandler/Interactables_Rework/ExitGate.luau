local MODELS = game:GetService("ServerStorage"):WaitForChild("Interactables")
local testing = true

local Interaction = {
	CurrentAmount = 0;
}

function GetExit() : "Get Exit Gate Type for this Map"
	
	if testing and MODELS:FindFirstChild("Exit_Default") then
		return MODELS:WaitForChild("Exit_Default")
	end
	
	
	return MODELS:WaitForChild(script.Name) -- fail safe
end

function Interaction:Spawn(Interactions : Folder, Version : number) : "Spawn this item type into map"
	local Source = GetExit(Interactions.Name, Interactions.Parent.Name)
	if not Source then return warn(Interactions.Name, 'does not exist as a model!') end
	
	for _, Location : BasePart in pairs(Interactions:GetChildren()) do
		if Location:GetAttribute("Version") and Location:GetAttribute("Version") ~= Version then continue end
		--
		Interaction.CurrentAmount += 1
		
		local New_Interaction = Source:Clone()
		
		New_Interaction.Name = script.Name..tostring(Interaction.CurrentAmount)
		
		New_Interaction:PivotTo(Location.CFrame)
		New_Interaction.Parent = workspace
	end
end

return Interaction
