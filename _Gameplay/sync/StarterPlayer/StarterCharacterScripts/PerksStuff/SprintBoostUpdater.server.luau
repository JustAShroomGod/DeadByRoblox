local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Data_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Code_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('SprintBurst'))

local Character = script.Parent.Parent
local RootPart = Character:WaitForChild('HumanoidRootPart')
local Player = game.Players:GetPlayerFromCharacter(Character)

local isRunning : BoolValue = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('MovementSpeedScript'):WaitForChild('Shift')

local lastMovement = workspace:GetServerTimeNow()


local hasBoost, BoostTier = Data_Module:GetPerk("SprintBurst", game.Players:FindFirstChild(Character.Name))

while task.wait() do
	if not hasBoost then break end
	local isMoving : boolean = (RootPart.Velocity.Magnitude > 0)
	
	if not Code_Module:IsExhausted(Player) and isRunning.Value and isMoving then
		Code_Module:Exhaust(Player, Perk_Module.Tiers[BoostTier])
		Code_Module:SetEffect("Haste", Player, {Perk_Module.Duration, Perk_Module.Speed_Boost}, "Sprint_Boost")
	end
end

script:Remove()