local Character = script.Parent.Parent

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Data_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Code_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Character = script.Parent.Parent
local RootPart = Character:WaitForChild('HumanoidRootPart')

local Player = game.Players:GetPlayerFromCharacter(Character)

local Totem_Modules = {}

local Totem_Logic = {
	Range = 65;
	Saved_Blessings = {}; -- blessing we applied to ourself
}

function Totem_In_Proximity(Frame) : "Return List of Totems in Proximity"
	local Totems = {}
	
	for _, v in pairs(workspace:GetChildren()) do
		if not v:IsA('Model') or not v:GetAttribute("IsInteractable") then continue end
		
		if string.match(string.lower(v.Name), 'totem') then
			
			if (Frame.Position - v:GetPivot().Position).Magnitude <= Totem_Logic.Range then
				local Blessings = Code_Module:IsBlessing(v)
				
				if Blessings then

					table.insert(Totems, {
						v,
						Blessings
					})
				end
			end
		end
	end
	
	return Totems
end

for _, totem_mod in pairs(script:GetChildren()) do
	if not totem_mod:IsA('ModuleScript') then continue end
	Totem_Modules[totem_mod.Name] = require(totem_mod)
end

while task.wait() do
	local blessing_list = Totem_In_Proximity(Character:GetPivot())
	
	if #blessing_list > 0 then
		Character:SetAttribute("Blessed", true)
		
		--print(blessing_list)
		
		-- Apply Blessings --
		for _, totem_Data in pairs(blessing_list) do
			
			for blessing_on_totem, blessing_data in pairs(totem_Data[2]) do
				if not Totem_Modules[blessing_on_totem] then warn(blessing_on_totem, 'not a module!') continue end
				
				if not Totem_Logic.Saved_Blessings[blessing_on_totem] then
					Totem_Logic.Saved_Blessings[blessing_on_totem] = {
						Tier = blessing_data.Tier -- save the tier for now
					}
					
					Totem_Modules[blessing_on_totem]:Activate(Character, blessing_data.Tier) -- apply to us
				else
					continue
				end
			end
		end
	else
		
		-- Remove Blessings --
		for stored_blessing, blessing_data in pairs(Totem_Logic.Saved_Blessings) do
			Totem_Modules[stored_blessing]:Deactivate(Character) -- remove from us
			Totem_Logic.Saved_Blessings[stored_blessing] = nil
		end
		
		Character:SetAttribute("Blessed", nil)
	end
end