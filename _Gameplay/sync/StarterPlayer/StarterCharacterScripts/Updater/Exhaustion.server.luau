local Character = script.Parent.Parent

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Data_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Code_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Character = script.Parent.Parent
local RootPart = Character:WaitForChild('HumanoidRootPart')

local Player = game.Players:GetPlayerFromCharacter(Character)

local isRunning : BoolValue = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('MovementSpeedScript'):WaitForChild('Shift')

local Exhaust_Logic = {
	StoppedRunning = 0; -- time in which we stopped moving
	StoredExhaustion = 0; -- exaustion removal stored?
	LastFrame = 0;
	StoredRemoval = 0; -- amount to remove
}

while task.wait() do
	local isMoving : boolean = (RootPart.Velocity.Magnitude > 0)
	local exhaustion_attribute = Character:GetAttribute("Exhaustion")

	local Rejuvenation = Code_Module:GetEffect("Rejuvenation", Player)

	if exhaustion_attribute then
		local exhaustion_table = string.split(exhaustion_attribute, ':')

		if tonumber(exhaustion_table[1]) > 0 then

			if Exhaust_Logic.StoredExhaustion <= 0 then
				Exhaust_Logic.StoredExhaustion = tonumber(exhaustion_table[1]) -- save last exhaustion amount
			end

			if isMoving and isRunning.Value then
				Exhaust_Logic.StoredExhaustion = tonumber(exhaustion_table[1]) -- save last exhaustion amount
				Exhaust_Logic.LastFrame = workspace:GetServerTimeNow()
				Exhaust_Logic.StoredRemoval = 0
				--Exhaust_Logic.StoppedRunning = workspace:GetServerTimeNow() -- update stopped running to recent running
			else -- we are not moving or not running refill exhaustion
				local calculatedExhaustion = math.clamp(Exhaust_Logic.StoredExhaustion - Exhaust_Logic.StoredRemoval, 0, 9999999) -- should output predicted exhaustion in this moment
				
				if Rejuvenation then
					Rejuvenation = (Rejuvenation.Value/100) * (workspace:GetServerTimeNow() - Exhaust_Logic.LastFrame)
					
					Exhaust_Logic.StoredRemoval += ((workspace:GetServerTimeNow() - Exhaust_Logic.LastFrame) + Rejuvenation)
				else
					Exhaust_Logic.StoredRemoval += (workspace:GetServerTimeNow() - Exhaust_Logic.LastFrame)
				end
				
				Exhaust_Logic.LastFrame = workspace:GetServerTimeNow()

				if calculatedExhaustion > 0 then
					Character:SetAttribute("Exhaustion", calculatedExhaustion..':'..exhaustion_table[2])
				else
					Character:SetAttribute("Exhaustion", nil) -- remove attribute no longer exhausted
					Exhaust_Logic.StoredExhaustion = 0 -- save last exhaustion amount
					Exhaust_Logic.LastFrame = workspace:GetServerTimeNow()
					--Exhaust_Logic.StoppedRunning = workspace:GetServerTimeNow() -- update stopped running to recent running
				end
			end
		else
			Character:SetAttribute("Exhaustion", nil) -- remove attribute no longer exhausted
			Exhaust_Logic.StoredExhaustion = 0 -- save last exhaustion amount
			Exhaust_Logic.StoredRemoval = 0
			Exhaust_Logic.LastFrame = workspace:GetServerTimeNow() -- update stopped running to recent running
		end
	else
		Exhaust_Logic.StoredExhaustion = 0 -- save last exhaustion amount
		Exhaust_Logic.StoredRemoval = 0
		Exhaust_Logic.LastFrame = workspace:GetServerTimeNow() -- update stopped running to recent running
	end
end