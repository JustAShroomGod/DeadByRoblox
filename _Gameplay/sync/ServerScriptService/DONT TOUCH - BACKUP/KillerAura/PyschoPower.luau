local Player = game.Players.LocalPlayer
local Players = game:GetService('Players')
local DataStorage = Player:WaitForChild('Data')

local backpack = Player:WaitForChild("Backpack")
local Scripts = backpack:WaitForChild("Scripts")
local killer = Scripts:WaitForChild("Killer")
local character = DataStorage:WaitForChild("Killer")

local code_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local ITEM_TO_SEARCH = "Players" -- can be "Players" or "Objects"


local PlayerDefault = {
	["Active"] = false;
	["Color"] = Color3.fromRGB(255, 0, 0);  -- decides aura color! --
	["Priority"] = 1; -- gonna us a number system (1 being top most priority (perks), 2 being other's perks (other perks/kindred), 3 being game events (default aura stuff))
}

local ReturnDefault = {
	Survivors = {};
	Killers = {};
}

local BloodRage = {
	Power = nil;
	Progress = nil;
	State = nil;
	AuraDistance = nil;
}

-- Personal Aura Settings --

local Aura = {
	Settings = {
		MinDistance = 20;
		MaxDistance = 70;
	};
}

function CanAura(plr)
	local CanShow = false 
	
	if character.Value == "Psychopath" then
		local plr_character = plr.Character
		local plr_Values = plr:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')
		
		if not plr or not plr.Character or not plr.Character.PrimaryPart
			or not Player or not Player.Character or not Player.Character.PrimaryPart then
			return false
		end
		
		BloodRage.Power = Player.Character:WaitForChild("BloodRage")
		BloodRage.AuraDistance = BloodRage.Power:WaitForChild("PowerValues"):GetAttribute("AuraDistance")
		BloodRage.Progress = BloodRage.Power:GetAttribute("Progress")
		BloodRage.State = BloodRage.Power:GetAttribute("State")
	
		if BloodRage then -- we have the right power in character means we are Psychopath
		
			if (BloodRage.State == 1) then
			
				CanShow = true -- we are in frenzy show esp
			end
		end
	
		
		local Distance = (plr_character.PrimaryPart.Position - Player.Character.PrimaryPart.Position).magnitude
	
		if Distance >= BloodRage.AuraDistance.X and not code_module:GetEffect("Hidden", plr) and Distance <= BloodRage.AuraDistance.Y then
			-- do nothing since can show is already true at this point
		else
			CanShow = false
		end
	end
	
	return CanShow
end


function ValidValue(Other_Player) -- doesn't need to change a constant --

	if Other_Player and Other_Player.Parent and Other_Player == Player.Name then -- it's us or nothing
		return false, nil
	end

	local Object_Value = game.ReplicatedStorage:WaitForChild('Match'):WaitForChild('Players'):WaitForChild(Other_Player.Name)

	if code_module:IsDead(Other_Player)
		or Object_Value:GetAttribute("Escaped") then -- player died or escaped

		return false, nil
	end

	return true, Other_Player
end

local function deepCopy(original)
	local copy = {}
	
	for k, v in pairs(original) do
		
		if type(v) == "table" then
			v = deepCopy(v)
		end
		
		copy[k] = v
	end
	
	return copy
end

function Aura:AuraType()
	return ITEM_TO_SEARCH
end

function Aura:Grab(Table)
	local Return = deepCopy(ReturnDefault)
	
	for current_Player, survivor in pairs(Table.Survivors)do -- only loops through survivors
		local IsValid, newplayer = ValidValue(survivor)
		
		if IsValid then
			Return.Survivors[current_Player] = deepCopy(PlayerDefault)
			
			if CanAura(newplayer) then
				Return.Survivors[current_Player]["Active"] = true
			end
		end
	end
	
	return Return
end

return Aura
