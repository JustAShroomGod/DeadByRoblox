local ReplicatedStorage, Players, TweenService, RunService = game:GetService('ReplicatedStorage'), game:GetService('Players'), game:GetService('TweenService'), game:GetService('RunService')

local moduleStorage : Folder, remoteStorage : Folder = ReplicatedStorage:WaitForChild('Modules'), ReplicatedStorage:WaitForChild('RemoteEvents')

local remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
local betterUpdate = remoteEvents:WaitForChild("NewPropertie")

local uis = game:GetService("UserInputService")

local plr = game.Players.LocalPlayer
local char = workspace:WaitForChild(plr.Name)

local Scripts : Model = plr:WaitForChild('Backpack'):WaitForChild('Scripts')
local playerValues : Folder, playerPerks :Folder = Scripts:WaitForChild('values'), Scripts:WaitForChild('PerksBase')

local Perk_Data = ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks')

local Modules = {
	Data = require(moduleStorage:WaitForChild('Data'));
	Code = require(moduleStorage:WaitForChild('Code'));
	Control = require(plr:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls();
}

local Backpack = plr:WaitForChild("Backpack")
local Scripts = Backpack:WaitForChild("Scripts")
local values = Scripts:WaitForChild("values")

local killer = Scripts:WaitForChild("Killer")

local shift = script:WaitForChild("Shift")
local crouching = values:WaitForChild("Crouching")

local healthState = values:WaitForChild("HealthState")
local urbanActive = false


function Obfuscate(TYPE, VALUE1, VALUE2)
	local tablev = {}
	local List = {"Bbh1O", "D9v8", "Dbh1O", "Dvh1O", "Dhv8"}

	TYPE = string.lower(TYPE)

	if TYPE == 'string' then
		TYPE = 'S101'
	elseif TYPE == 'object' then
		TYPE = 'O101'
	elseif TYPE == 'number' then
		TYPE = 'I101'
	elseif TYPE == 'bool' then
		TYPE = 'B101'
	end

	local Packaged = {
		['C22'] = TYPE;
		['C21'] = VALUE1;
		['C20'] = VALUE2;
	}

	for _,key in pairs(List) do
		tablev[key] = Packaged
	end

	betterUpdate:FireServer(tablev)
end

uis.InputBegan:Connect(function(input)

	if killer.Value == false then
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.ButtonL1 then
			if healthState.Value > 0 and crouching.Value == false then
				local newPropertie = true

				if shift.Value ~= newPropertie then
					shift.Value = newPropertie
					Obfuscate("bool", shift, newPropertie)
					char:SetAttribute("Sprint", true)
				end
			end
		end
	end
end)

uis.InputEnded:Connect(function(input)
	
	if killer.Value == false then
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL1 then
			
			if healthState.Value > 0 and crouching.Value == false then
				local newPropertie = false
				shift.Value = newPropertie
				Obfuscate("bool", shift, newPropertie)
				char:SetAttribute("Sprint", false)
			end
		end
	end
end)

RunService.Heartbeat:Connect(function()
	local Crouch = char:GetAttribute("Crouch")
	
	if (not Crouch and urbanActive) then
		Modules.Code.Speeds:removeMultiplier(plr, "Crouch")
		Modules.Code.Speeds:removeMultiplier(plr, "Urban_Boost")
		urbanActive = false
	end
end)

healthState.Changed:Connect(function()
	if healthState.Value == 0 then
		local newPropertie = false
		if shift.Value ~= newPropertie then
			shift.Value = newPropertie
			Obfuscate("bool", shift, newPropertie)
			char:SetAttribute("Sprint", false)
		end
	end
end)

local Player = game.Players.LocalPlayer
local Character = Player.Character

local HasFixated, FixatedTier = Modules.Data:GetPerk("Fixated")
local HasUrban, UrbanTier = Modules.Data:GetPerk("UrbanEvasion")

local PerkSettings = {
	Fixated = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('Fixated')).Tiers;
	Urban = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('UrbanEvasion')).Tiers;
}

Character:GetAttributeChangedSignal("Sprint"):Connect(function()
	local Sprint = Character:GetAttribute("Sprint")

	if Sprint == true then
		Modules.Code.Speeds:addMultiplier(Player, "Sprint", Modules.Code.Speeds.Survivor.Running, -1)
		Modules.Code.Speeds:removeMultiplier(Player, "Crouch")
		Modules.Code.Speeds:removeMultiplier(Player, "Urban_Boost")
	else
		Modules.Code.Speeds:removeMultiplier(Player, "Sprint")
	end
end)

Character:GetAttributeChangedSignal("Crouch"):Connect(function()
	local Crouch = Character:GetAttribute("Crouch")

	if Crouch == true then
		
		if HasUrban then
			Modules.Code.Speeds:addMultiplier(Player, "Urban_Boost", PerkSettings.Urban[UrbanTier] - 1, -1)
			urbanActive = true
		end
		
		Modules.Code.Speeds:addMultiplier(Player, "Crouch", Modules.Code.Speeds.Survivor.Crouching, -1)
		Modules.Code.Speeds:removeMultiplier(Player, "Sprint")
	else
		Modules.Code.Speeds:removeMultiplier(Player, "Crouch")
		Modules.Code.Speeds:removeMultiplier(Player, "Urban_Boost")
	end
end)