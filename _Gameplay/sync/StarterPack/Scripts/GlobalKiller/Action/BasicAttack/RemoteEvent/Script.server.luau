local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local Badge_Manager = require(ServerStorage:WaitForChild("Modules"):WaitForChild("BadgeManager"))
local Events = require(game:GetService("ServerScriptService"):WaitForChild('Event System'):WaitForChild('Events'));

local Killer_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild('Psychopath'))

script.Parent.OnServerEvent:Connect(function(P,S,i)
	if not i then
		S:Play()
	elseif i == "Psychopath" then
		local Character = P.Character

		local current_rage = string.split(Character:GetAttribute("Power"), ':')

		Character:SetAttribute("Power", math.clamp(tonumber(current_rage[1]) + Killer_Module.Rage_Gain.Miss_Attack, 0, tonumber(current_rage[2]))..':'..current_rage[2])
	end
end)
