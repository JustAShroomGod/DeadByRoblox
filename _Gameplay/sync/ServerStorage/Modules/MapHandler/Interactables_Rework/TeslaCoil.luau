local MODELS = game:GetService("ServerStorage"):WaitForChild("Interactables")

local Interaction = {
	CurrentAmount = 0;
}

function Interaction:Spawn(Interactions : Folder, Version : number) : "Spawn this item type into map"
	if not MODELS:FindFirstChild(script.Name) then return warn(script.Name, 'does not exist as a model!') end
	local Source = MODELS:WaitForChild(script.Name)
	
	for _, Location : BasePart in pairs(Interactions:GetChildren()) do
		if Location:GetAttribute("Version") and Location:GetAttribute("Version") ~= Version then continue end
		--
		Interaction.CurrentAmount += 1
		
		local New_Interaction = Source:Clone()
		
		New_Interaction.Name = New_Interaction.Name..tostring(Interaction.CurrentAmount)
		New_Interaction:PivotTo(Location:GetPivot())
		
		New_Interaction.Parent = workspace
	end
end

return Interaction
