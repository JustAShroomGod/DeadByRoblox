local Item_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Items')

local Event = script.Parent:WaitForChild('Flashlight')

local BlindSettings = {
	CurrentTag = nil;
	ProcessingCreation = false;
}

local function ReturnBeamer(character)
	
	for _,f in pairs(character:GetChildren()) do
		
		if f:GetAttribute("Tool") then
			return f
		end
	end
	
	return nil
end

Event.OnServerEvent:Connect(function(player, ...)
	if not player.Character or not script:IsDescendantOf(player.Backpack) then return end
	local args = {...}
	
	local Command = args[1]
	
	repeat task.wait()
	until not BlindSettings.ProcessingCreation
	
	if Command == "StartBlinding" and not BlindSettings.CurrentTag and args[2] then
		if not (player.Backpack.Scripts.values.Action.Value == "UsingFlashlight") then return end
		
		BlindSettings.ProcessingCreation = true
		
		local Flashlight = ReturnBeamer(player.Character)
		local rawkiller = game.Players:FindFirstChild(args[2].Parent.Name)
		
		if not rawkiller or not rawkiller.Character or not Flashlight then BlindSettings.ProcessingCreation = false return end
		local Flashlight_Module = Item_Data:FindFirstChild(Flashlight.Name)
		
		if not Flashlight_Module then
			Flashlight_Module = Item_Data:WaitForChild('Yellow_Flashlight')
		end
		
		Flashlight_Module = require(Flashlight_Module)
		
		--TODO: they tehnically can blind the killer by aiming the flashlight randomly if theyre in range soo i think a check with myb :Dot product would help
		
		if not ((player.Character.PrimaryPart.Position - rawkiller.Character.PrimaryPart.Position).Magnitude <=  Flashlight_Module.Range) then
			BlindSettings.ProcessingCreation = false
			return
		end
		
		-- Check if we hit killer's target --
		if args[2].Name ~= "Flash_Zone" then
			BlindSettings.ProcessingCreation = false
			return
		end
		
		local BlindFile = rawkiller.Backpack.Scripts.BlindScript
		local Total_Charges = Flashlight_Module.Charges
		local Total_Brightness = Flashlight_Module.Brightness
		local Addon_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Survivor')
		local addon_1, addon_2 = Flashlight:GetAttribute("Addon_1"), Flashlight:GetAttribute("Addon_2")

		if addon_1 and addon_1 ~= "" then
			addon_1 = Addon_Data:FindFirstChild(addon_1)

			if addon_1 then
				addon_1 = require(addon_1)
				
				if addon_1.Charges then
					Total_Charges += addon_1.Charges
				end
				
				if addon_1.Brightness then
					Total_Brightness += addon_1.Brightness
				end
			end
		end

		if addon_2 and addon_2 ~= "" then
			addon_2 = Addon_Data:FindFirstChild(addon_2)

			if addon_2 then
				addon_2 = require(addon_2)
				
				if addon_2.Charges then
					Total_Charges += addon_2.Charges
				end
				
				if addon_2.Brightness then
					Total_Brightness += addon_2.Brightness
						
				end
			end
		end
		
		Flashlight['Flashlight-Script'].Drain.Value = Flashlight_Module.Drain
		Flashlight['Flashlight-Script'].Charges.Value = Total_Charges
			
		-- Create Flash --
		BlindSettings.CurrentTag = Instance.new("StringValue")
		BlindSettings.CurrentTag.Name = player.Name
		BlindSettings.CurrentTag.Value = tostring(Total_Brightness)
		BlindSettings.CurrentTag.Parent = BlindFile.Flashing
	
		
		-- Add Flash to Folder
		BlindSettings.ProcessingCreation = false
	elseif Command == "StopBlinding" and BlindSettings.CurrentTag then
		BlindSettings.CurrentTag:Destroy() BlindSettings.CurrentTag = nil
	end
end)
