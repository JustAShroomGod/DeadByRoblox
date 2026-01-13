local Character = script.Parent.Parent
local RootPart = Character:WaitForChild('HumanoidRootPart')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Code_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Player = game.Players:GetPlayerFromCharacter(Character)

local ActionValue : BoolValue = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild("Action")
local HealthState : number = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild("HealthState")
local isRunning : BoolValue = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('MovementSpeedScript'):WaitForChild('Shift')

local Gash_Logic = {
	StoredGash = 0; -- exaustion removal stored?
	LastFrame = 0;
	StoredRemoval = 0; -- amount to remove
}

while task.wait() do
	local isMoving : boolean = (RootPart.Velocity.Magnitude > 0)
	local gash_attribute = Character:GetAttribute("Gash")
	
	if gash_attribute then
		local gash_table = string.split(gash_attribute, ':')

		if tonumber(gash_table[1]) > 0 then
			if Gash_Logic.StoredGash <= 0 then
				Gash_Logic.StoredGash = tonumber(gash_table[1]) -- save last gash amount
			end

			if ActionValue.Value == "Mending" or (isMoving and isRunning.Value) then
				Gash_Logic.StoredGash = tonumber(gash_table[1]) -- save last gash amount
				Gash_Logic.LastFrame = workspace:GetServerTimeNow()
				Gash_Logic.StoredRemoval = 0
			else
				local calculatedGash = math.clamp(Gash_Logic.StoredGash - Gash_Logic.StoredRemoval, 0, 9999999) -- should output predicted gash in this moment

				Gash_Logic.StoredRemoval += (workspace:GetServerTimeNow() - Gash_Logic.LastFrame)

				Gash_Logic.LastFrame = workspace:GetServerTimeNow()

				if calculatedGash > 0 then
					Character:SetAttribute("Gash", calculatedGash..':'..gash_table[2])
				else
					Character:SetAttribute("Gash", nil) -- remove attribute no longer exhausted
					Gash_Logic.StoredGash = 0 -- save last exhaustion amount
					Gash_Logic.LastFrame = workspace:GetServerTimeNow()
					
					HealthState.Value = 0 -- if we have ran out of time then we die --
				end
			end
		else
			Character:SetAttribute("Gash", nil) -- remove attribute
			Gash_Logic.StoredGash = 0 -- save last gash amount
			Gash_Logic.StoredRemoval = 0
			Gash_Logic.LastFrame = workspace:GetServerTimeNow()
		end
	else
		Gash_Logic.StoredGash = 0 -- save last exhaustion amount
		Gash_Logic.StoredRemoval = 0
		Gash_Logic.LastFrame = workspace:GetServerTimeNow()
	end
end