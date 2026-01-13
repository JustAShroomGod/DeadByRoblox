local runService = game:GetService("RunService")
local Player = game.Players:WaitForChild(script.Parent.Parent.Name)

local Backpack = Player:WaitForChild("Backpack")
local Scripts = Backpack:WaitForChild("Scripts")
local values = Scripts:WaitForChild("values")

local killer = Scripts:WaitForChild("Killer")
local action = values:WaitForChild("Action")


local server = game:GetService('ServerScriptService')
local Data = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))


local Cap = 12000

local db1, db2 = false, false

local Rate = 50

local function Reward(Catagory, Amount, Action)
	Data:GiveBlood(Player, Amount, Catagory, Action)
end

local TimeSpent = 0

runService.Heartbeat:Connect(function(step)

	if not killer.Value then

		if action.Value == 'SelfHealing' or action.Value == 'MedkitHeal' then

			db1 = true
			TimeSpent += (step * Rate)
		elseif action.Value == 'Repairing' or action.Value == 'ToolBoxRepair' then

			db2 = true
			TimeSpent += (step * Rate)
		else

			if db1 then
				db1 = false
				Reward('Survival', TimeSpent, 'HEAL')
			end

			if db2 then
				db2 = false
				Reward('Objectives', TimeSpent, 'REPAIRS')
			end

			TimeSpent = 0
		end
	end
end)
