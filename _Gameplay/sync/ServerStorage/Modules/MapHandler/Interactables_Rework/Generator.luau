local MODELS = game:GetService("ServerStorage"):WaitForChild("Interactables")

local Interaction = {
	CurrentAmount = 0;
}

local OverlapParameters = OverlapParams.new()
OverlapParameters.RespectCanCollide = true

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

		task.spawn(function()
			for _, Port in pairs(Location:GetChildren()) do
				if Port:FindFirstChild('Deactivated') and string.match(Port.Name, "Port") then
					if not Port:FindFirstChild('Deactivated').Value then continue end
					local New_Port = New_Interaction:FindFirstChild("Workspots"):FindFirstChild(string.gsub(Port.Name, "Port",""))

					local DeactivatedBool = nil

					if (New_Port) then
						if New_Port:FindFirstChild("Deactivated") then
							DeactivatedBool = New_Port:FindFirstChild("Deactivated")
						else
							DeactivatedBool = Instance.new('BoolValue')
							DeactivatedBool.Name = 'Deactivated'
							DeactivatedBool.Parent = New_Port
						end
						DeactivatedBool.Value = true
					end
				end
			end
		end)
	end
end

return Interaction
