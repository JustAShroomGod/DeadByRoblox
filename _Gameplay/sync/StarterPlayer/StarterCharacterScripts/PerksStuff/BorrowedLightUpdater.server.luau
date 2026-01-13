local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Data_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Perk_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Curse: Borrowed Light'))
local Code_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Character = script.Parent.Parent
local RootPart = Character:WaitForChild('HumanoidRootPart')

local Player = game.Players:FindFirstChild(Character.Name)

local hasLight, LightTier = Data_Module:GetPerk("Curse: Borrowed Light", Player)

function checkForLight() : boolean

	for _,descendant in pairs(workspace:GetChildren())do
		
		if string.match(string.lower(descendant.Name), 'totem') and descendant:FindFirstChild("Panel") then
			
			if string.match(string.lower(descendant.Panel:WaitForChild('Effect').Value), 'borrowed light') then
				return true
			end
		end
	end

	return false
end

function closestCurse()
	local result = 1000

	for _,totem in pairs(workspace:GetChildren())do

		if string.match(string.lower(totem.Name), 'totem') and totem:FindFirstChild("Panel") then

			if string.match(string.lower(totem.Panel:WaitForChild('Effect').Value), 'dull') then
				
			else
				local currentDistance = (RootPart:GetPivot().Position - totem:GetPivot().Position).Magnitude
				
				if currentDistance < result then
					result = currentDistance
				end
			end
		end
	end
	
	return result
end

while task.wait() do
	if not hasLight then break end
	
	if checkForLight() then -- toem is up and alive
		
		if closestCurse() <= Perk_Module.Tiers[LightTier] then
			Character:SetAttribute("Perk_Borrowed_Light", true)
		else
			Character:SetAttribute("Perk_Borrowed_Light", false)
		end
	else
		Character:SetAttribute("Perk_Borrowed_Light", false)
	end

	local Should_Hide : boolean = Character:GetAttribute("Perk_Borrowed_Light")
	local Hidden = Code_Module:GetEffect("Hidden", Player)
	
	if Should_Hide and not Hidden then
		Code_Module:SetEffect("Hidden", Player, -1, "Borrowed")
	elseif (Hidden and Character:GetAttribute("Hidden_Borrowed")) and not Should_Hide then
		Code_Module:SetEffect("Hidden", Player, nil, "Borrowed")
	end
end

script:Remove()