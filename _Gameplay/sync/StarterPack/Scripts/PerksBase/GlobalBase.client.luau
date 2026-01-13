local Player : Player, ReplicatedStorage : ReplicatedStorage = game:GetService("Players").LocalPlayer, game:GetService("ReplicatedStorage") 

local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid : Humanoid = Character:WaitForChild("Humanoid")

local Camera = workspace.CurrentCamera 

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local PerksBase = script.Parent

local Backpack = Player:WaitForChild("Backpack")
local Scripts = Backpack:WaitForChild("Scripts")
local values = Scripts:WaitForChild("values")

local Modules = {
	Data = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'));
	Code = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Code'));
}

local SurvPerk_Data = ReplicatedStorage:WaitForChild("Game_Data"):WaitForChild("Perks"):WaitForChild("Survivor")

local PerkModules = {
	Serene = require(SurvPerk_Data:WaitForChild("Serene"))
}

local Connections = {}

task.spawn(function()
	local GotSerene, SereneTier = Modules.Data:GetPerk("Serene")

	if not Scripts:WaitForChild("Killer").Value then
		Connections["GeneratorsRepaired"] = workspace.MatchValues.GeneratorsRepaired.Changed:Connect(function()
			if GotSerene and not PerksBase:WaitForChild("Serene"):WaitForChild("Active").Value then
				if not Scripts:WaitForChild("Killer").Value then
					PerksBase:WaitForChild("Serene"):WaitForChild("Active").Value = true
					game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Perk_Event"):FireServer("Serene", Player.Character)
					task.wait(PerkModules.Serene.Tiers[SereneTier])
					PerksBase:WaitForChild("Serene"):WaitForChild("Active").Value = false
				end
			end

			if workspace.MatchValues.GeneratorsRepaired.Value >= 5 then
				Connections["GeneratorsRepaired"]:Disconnect()
				Connections["GeneratorsRepaired"] = nil
			end
		end)
	end
end)