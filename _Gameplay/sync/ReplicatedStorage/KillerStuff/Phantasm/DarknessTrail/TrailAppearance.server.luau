local Character = nil
local PowerModel = nil
local PowerValues = nil

local Code = require(game.ReplicatedStorage.Modules.Code)
local KillerData = require(game.ReplicatedStorage.Game_Data.Killers.Phantasm)

local timer = KillerData.Phantasm_Frequency

local count = 0

local phantasmList = {}

script:GetPropertyChangedSignal("Enabled"):Connect(function()
	
	if (not script.Enabled) then
		return
	end

	Character = script.Parent.Parent.Parent
	local Humanoid = Character:WaitForChild("Humanoid")

	Character.PrimaryPart:WaitForChild("DarknessTrail").TrailEmitter.Enabled = false

	game["Run Service"].Heartbeat:Connect(function(delta)
		Character.PrimaryPart.DarknessTrail.TrailEmitter.Enabled = (
			Humanoid.MoveDirection.Magnitude > 0.01 
			and Code:GetEffect("Darkness", game.Players:GetPlayerFromCharacter(Character)))
	end)
end)

