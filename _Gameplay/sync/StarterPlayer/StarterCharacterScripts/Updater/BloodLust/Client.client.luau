local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local ChaseUpdater = game.ReplicatedStorage.RemoteEvents.ChaseUpdater

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Teams = game:GetService('Teams')

local Survivor_Team = Teams:WaitForChild('Survivor')
local LocalPlayer = Players.LocalPlayer

local Chase_Settings = {
	Orb_Interval = 0.85; -- drop orbs every # seconds
	Orb_Uptime = 6.5; -- how closesly tracked they have to follow
}

local IDs = {}
local LastOrb = {}
local Connections = {}
local NonChase = {"Hiding","InLocker"}

function GenerateOrb(Character, ID)
	local Orb = Instance.new("Part", workspace)
	Orb.Anchored = true
	Orb.CanCollide = false
	Orb.CanQuery = false
	Orb.Size = Vector3.new(1.5, 1.5, 1.5)
	Orb.Transparency = if script:GetAttribute("Testing") then 0.5 else 1
	Orb.Name = "Chase_Mechanic"
	Orb:SetAttribute("Survivor", Character.Name)
	Orb:SetAttribute("ID", ID)
	Orb:PivotTo(Character:GetPivot())

	coroutine.wrap(function()
		task.wait(Chase_Settings.Orb_Uptime)

		if Orb then
			Orb:Remove()
		end

		if Connections[Orb] then
			Connections[Orb]:Disconnect()
			Connections[Orb] = nil
		end
	end)()

	return Orb
end

function onHeartBeat(delta)
	if (LocalPlayer.Team == Survivor_Team) then
		return
	end
	
	for index, player: Player in pairs(Survivor_Team:GetPlayers()) do
		if (LastOrb[player.Name] == nil or IDs[player.Name] == nil) then resetSurvivor(player) end
		if (workspace:GetServerTimeNow() -  (LastOrb[player.Name]) < Chase_Settings.Orb_Interval) then return end
		if (not canSpawnOrb(player)) then return end
		
		local Orb = GenerateOrb(player.Character, IDs[player.Name])
		Connections[Orb] = Orb.Touched:Connect(function(obj : Part)
			if (obj:IsDescendantOf(LocalPlayer.Character)) then
				if (Orb:GetAttribute("ID") == IDs[Orb:GetAttribute("Survivor")]) then
					ChaseUpdater:FireServer("Collect", Players[Orb:GetAttribute("Survivor")])
					
					Connections[Orb]:Disconnect() 
					Connections[Orb] = nil
					Orb:Destroy()
				end
			end
		end)
	end
end

function canSpawnOrb(Survivor: Player)
	
	local Humanoid = Survivor.Character.Humanoid
	local Scripts = Survivor.Backpack.Scripts
	local values = Scripts.values

	if (Humanoid.MoveDirection.Magnitude <= 0) then return false end
	if (not Scripts.MovementSpeedScript.Shift.Value) then return false end
	if (values.Hooked.Value) then return false end
	if (values.Holded.Value) then return false end
	if (values.HealthState.Value < 1) then return false end
	if (table.find(NonChase, values.Action.Value)  ~= nil) then return false end
	
	return true
end

function ChaseEventReceive(Command)
	if (Command == "End") then
		for index, player in pairs(Survivor_Team:GetPlayers()) do
			resetSurvivor(player)
		end
	end
end

function resetSurvivor(player: Player)
	LastOrb[player.Name] = workspace:GetServerTimeNow()
	IDs[player.Name] = HttpService:GenerateGUID()
end

ChaseUpdater.OnClientEvent:Connect(ChaseEventReceive)
RunService.Heartbeat:Connect(onHeartBeat)


