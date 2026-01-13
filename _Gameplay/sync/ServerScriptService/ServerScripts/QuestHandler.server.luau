local ServerScriptService : ServerScriptService, ReplicatedStorage : ReplicatedStorage, Players : Players = game:GetService("ServerScriptService"),game:GetService("ReplicatedStorage"),game:GetService("Players")

local Data = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Data"))
local Events = require(ServerScriptService["Event System"]:WaitForChild("Events"))

--[[Events.Survivor.onKillerStun.Event:Connect(function(Player)
	Data:Quest(Player,"Pallet_Stuns",1)
end)

Events.Survivor.onVault.Event:Connect(function(Player)
	Data:Quest(Player,"Window_Vaults",1)
end)

Events.Survivor.onHookRescue.Event:Connect(function(Player)
	Data:Quest(Player,"Hook_Rescues",1)
end)

Events.Killer.onBreak.Event:Connect(function(Player : Player, Type : "Pallet/Wall")
	if Type == "Pallet" then
		Data:Quest(Player,"Pallets_Broken",1)
	elseif Type == "Wall" then
		Data:Quest(Player,"Walls_Broken",1)
	end
end)

Events.Killer.onAttack.Event:Connect(function(State) --TODO: change if we pull up 2v8
	local Killers = game:GetService("Teams"):FindFirstChild("Killer"):GetPlayers()
	
	if State == "Player" then
		for _, Killer in pairs(Killers) do
			Data:Quest(Killer,"Hit_Successful",1)
		end
	end
end)]]


local function onHealingFinished(Survivor, Healers)
	if not workspace:GetAttribute("Endgame") then return end -- do nothing
	
	local HealedSurv = Survivor.Backpack.Scripts.values.HealthState

	if HealedSurv.Value == 1 then --was recovered from downed
		for Healer,_ in pairs(Healers) do
			Healer = Players[Healer]
			Healer:SetAttribute("HealedQuest", if Healer:GetAttribute("HealedQuest") then Healer:GetAttribute("HealedQuest") + 1 else 1)
		end
	end
end

local function onUnhookFinished(Rescuer, RescuedSurv)
	if not workspace:GetAttribute("Endgame") then return end -- do nothing

	Rescuer:SetAttribute("HealedQuest", if Rescuer:GetAttribute("HealedQuest") then Rescuer:GetAttribute("HealedQuest") + 1 else 1)
end

Events.Survivor.onHealingFinished.Event:Connect(onHealingFinished)
Events.Survivor.onHookRescue.Event:Connect(onUnhookFinished)