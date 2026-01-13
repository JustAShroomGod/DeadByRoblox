local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Data_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Perk_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Curse: Lockdown'))
local Code_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Character = script.Parent.Parent
local Player = game.Players:FindFirstChild(Character.Name)

local playerValues = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')

local hasPerk, PerkTier = Data_Module:GetPerk("Curse: Lockdown", Player)
local LastFound : "Time Stamp" = workspace:GetServerTimeNow()

local Totems = {}
local Attribute_Keyword = "Perk_Lockdown"

for _, model in pairs(workspace:GetChildren()) do
	if not model:IsA('Model') and not model:GetAttribute("IsInteractable") then continue end
	
	if string.match(string.lower(model.Name), 'totem') then
		table.insert(Totems, model)
	end
end

function FetchTotem() : "Update Time Stamp and Return Boolean"
	
	for _, totem in pairs(Totems) do
		if not totem:FindFirstChild('Panel') then continue end
		
		if totem.Panel:WaitForChild('Effect').Value == "Lockdown" then
			LastFound = workspace:GetServerTimeNow()
			return true
		end
	end
	
	return false
end

local Connection

if not hasPerk then
	workspace:SetAttribute(Attribute_Keyword, nil)
	script.Disabled = true
	script:Remove()
else
	
	Connection = game["Run Service"].Stepped:Connect(function(t, delta)
		local Still_Exist = FetchTotem()
		
		if not Still_Exist and (workspace:GetServerTimeNow() - LastFound) >= 30 then
			Connection:Disconnect() Connection = nil -- break loop we lost the totem
			workspace:SetAttribute(Attribute_Keyword, nil)
			script.Disabled = true
			script:Remove()
		end
		
		if not Still_Exist then
			
			if (workspace:GetServerTimeNow() - LastFound) >= 30 and Connection then -- undo the loop
				Connection:Disconnect() Connection = nil -- break loop we lost the totem
				workspace:SetAttribute(Attribute_Keyword, nil)
				script.Disabled = true
				script:Remove()
			end
			
			if workspace:GetAttribute(Attribute_Keyword) then
				workspace:SetAttribute(Attribute_Keyword, nil) -- undo the attribute since perk totem is deactivated to undo perk
			end
		else-- We still have the totem up and running Currently --
			local Injured_Players = Code_Module:IsInjured("Any") -- get # of injured currently

			if Injured_Players >= Perk_Module.Tiers[PerkTier] then
				
				if not workspace:GetAttribute(Attribute_Keyword) then -- we do not have attribute active
					workspace:SetAttribute(Attribute_Keyword, true)
				end
			elseif workspace:GetAttribute(Attribute_Keyword) then -- We did not meet enough injured Players --
				workspace:SetAttribute(Attribute_Keyword, nil) -- undo attribute
			end
		end
	end)
end -- do nothing
