local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Data_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Perk_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Tic Tac'))

local Character = script.Parent.Parent
local Player = game.Players:FindFirstChild(Character.Name)

local playerValues = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')

local hasTic, TicTier = Data_Module:GetPerk("Tic Tac", Player)
local storedTime = 0

local Perk_Logic = {
	Mode = "Idle"; -- Idle, Filling
	Debounces = {
		enteredRadius = 0; -- when they entered radius
		ticCooldown = 0
	},
}

Character:GetAttributeChangedSignal("Tic_CD"):Connect(function()
	
	if Character:GetAttribute("Tic_CD") then
		storedTime = 0
		Perk_Logic.Debounces.ticCooldown = workspace:GetServerTimeNow()
		Perk_Logic.Mode = "Idle"
		Character:SetAttribute("Tic_CD", nil)
	end
end)

function CycleKiller(Killer, currentTime)
	
	if playerValues.Hooked.Value and (workspace:GetServerTimeNow() - Perk_Logic.Debounces.ticCooldown) >= 7.5 and Killer and Killer:IsA('Player') then

		if Perk_Logic.Mode == "Filling" then

			if (Killer.Character:GetPivot().Position - Character:GetPivot().Position).Magnitude > Perk_Module.Radius then
				Perk_Logic.Mode = "Idle"
				storedTime += (workspace:GetServerTimeNow() - Perk_Logic.Debounces.enteredRadius) -- add to current time
				Perk_Logic.Debounces.enteredRadius = workspace:GetServerTimeNow()
			else
				currentTime += (workspace:GetServerTimeNow() - Perk_Logic.Debounces.enteredRadius) -- make current tiem accurate
			end
		else -- we are in idle mode

			if (Killer.Character:GetPivot().Position - Character:GetPivot().Position).Magnitude <= Perk_Module.Radius then -- switch to filling mode
				Perk_Logic.Mode = "Filling"
				Perk_Logic.Debounces.enteredRadius = workspace:GetServerTimeNow() -- start timer here
			end
		end
	else -- not on hook reset stored time
		storedTime = 0
	end

	Character:SetAttribute("Tic_Tac", Perk_Module.Tiers[TicTier]..':'..math.clamp(currentTime, 0, Perk_Module.Tiers[TicTier])) -- update last moment we moved
end

while task.wait() do
	if not hasTic then break end
	
	for _, Killer_Player in pairs(game.Teams:WaitForChild('Killer'):GetPlayers()) do
		CycleKiller(Killer_Player, storedTime)
	end
end

script:Remove()