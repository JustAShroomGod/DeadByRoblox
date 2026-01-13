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
		New_Interaction:SetPrimaryPartCFrame(Location.CFrame)
		New_Interaction.Parent = workspace
		
		for _, port in pairs(Location:GetChildren()) do
			
			if port:FindFirstChild('Deactivated') then
				local spot = New_Interaction:FindFirstChild(port.Name)
				
				if spot:FindFirstChild('Deactivated') then spot.Deactivated:Remove() end
				local deactivate = Instance.new('BoolValue', spot)
				deactivate.Name = 'Deactivated'
				deactivate.Value = true
			end
		end
	end
end

return Interaction
