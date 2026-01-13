local RunService : RunService, ServerStorage : ServerStorage,ReplicatedStorage : ReplicatedStorage,PlayersService : Players = game:GetService("RunService"),game:GetService("ServerStorage"),game:GetService("ReplicatedStorage"),game:GetService("Players")
local Connections = {}

local Bleedout_Speeds = {240, 240, 120} -- amount of time it should last to bleed out fully in seconds (10 min, 6 min, 2 min)

local Player = PlayersService:WaitForChild(script.Parent.Name)
local Character = Player.Character

local Backpack = Player:WaitForChild("Backpack")
local ScriptsFolder = Backpack:WaitForChild("Scripts")
local Values = ScriptsFolder:WaitForChild("values")

local Code = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local BadgeManager = require(ServerStorage:FindFirstChild("Modules"):FindFirstChild("BadgeManager"))

function Event(step)
	local Current_Blood = Character:GetAttribute("Blood")
	
	if not Current_Blood then return end -- blood does not exist yet
	Current_Blood = Current_Blood:split(':')
	
	if not tonumber(Current_Blood[2]) then return end -- blood does not exist yet
	if Values:WaitForChild('Holded').Value or Values:WaitForChild('Hooked').Value then return end -- carried or hooked
	if Values:WaitForChild('Action').Value == "GettingHealing" then return end -- being healed do not bleed out
	local hookStage = string.split(Character:GetAttribute("Hook_Stage"), ':')
	local bleedout_rate = step * (1000/Bleedout_Speeds[math.clamp(hookStage[1] + 1, 1, 3)])
	
	if (tonumber(Current_Blood[1]) - bleedout_rate) <= 0 and Connections.Heart then
		Character:SetAttribute("Blood", "0:"..Current_Blood[2])
		Code:AddDeath(game.Players:WaitForChild(script.Parent.Name))
		
		task.spawn(function()
			local Killers = game:GetService("Teams"):FindFirstChild("Killer"):GetPlayers()
			
			BadgeManager.Award("Ground Hug",Player.UserId)

			for _, Killer in pairs(Killers) do
				BadgeManager.Award("Torment",Killer.UserId)
			end
		end)
		
		if Connections.Heart then Connections.Heart:Disconnect() Connections.Heart = nil end
	else
		Character:SetAttribute("Blood", (tonumber(Current_Blood[1]) - bleedout_rate)..":"..Current_Blood[2]) -- reduce blood
	end
end

Values:WaitForChild('HealthState').Changed:Connect(function()
	
	if Values.HealthState.Value <= 0 and not Connections.Heart then
		Connections.Heart = RunService.Heartbeat:Connect(Event)
	elseif Connections.Heart then
		Connections.Heart:Disconnect() Connections.Heart = nil
	end
end)