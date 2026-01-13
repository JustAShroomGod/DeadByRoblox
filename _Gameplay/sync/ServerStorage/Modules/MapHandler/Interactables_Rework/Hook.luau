local Handler = require(script:WaitForChild("Handler"))
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
		task.wait() -- put a minor wait to help w/ execution times
		
		Interaction.CurrentAmount += 1
		
		local New_Interaction = Source:Clone()
		New_Interaction.Name = New_Interaction.Name..tostring(Interaction.CurrentAmount)
		New_Interaction:SetPrimaryPartCFrame(Location.CFrame)
		New_Interaction.Parent = workspace
		
		if Location:FindFirstChild('Basement') then
			New_Interaction:WaitForChild('Panel'):WaitForChild('Basement').Value = true
		end
		
		task.spawn(function()
			Handler.New(New_Interaction)
		end)
	end
end

return Interaction
