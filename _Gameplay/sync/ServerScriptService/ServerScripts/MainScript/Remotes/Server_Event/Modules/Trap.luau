 local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')

local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)

local trapper_module = require(script:WaitForChild('Trapper'))
local survivor_module = require(script:WaitForChild('Survivor'))

local grabbing_animation = script.Parent.Parent:WaitForChild('Animations'):WaitForChild('Trapper_Trap_Grab')

local module = {
	Settings = {
		Speeds = {
			Base = 15;
		}
	},
	Saved = {}
}

local TrapSettings = {
	Struggle_Speed = 1000/8; -- progress per second = 8 | change number after 1000
}

-- Survivor Functions

function Disarm(Survivor : Player, Backpack, perkBase, playerValues, Trap)
	local Connections = {}
	local Cancelled = false

	Connections.Cancel = playerValues.Action.Changed:Connect(function()

		if playerValues.Action.Value == "Cancel Disarm" then
			Cancelled = true
		end
	end)

	playerValues.Action.Value = "Disarming"
	Trap:WaitForChild('Panel').User.Value = Survivor.Name

	local timestamp, timer = survivor_module:Disarm(Survivor.Character)

	repeat task.wait()
	until Cancelled or (workspace:GetServerTimeNow() - timestamp) > timer

	Connections.Cancel:Disconnect()

	if Cancelled then
		survivor_module:Cancel(Survivor.Character)
	else
		Trap.Panel.State.Value = "Disarmed"
		data_module:GiveBlood(Survivor,300,"Boldness","TRAP DISARMED")
	end

	playerValues.Action.Value = "Nothing"
	Trap:WaitForChild('Panel').User.Value = ""
end

function Struggle(Survivor : Player, Backpack, perkBase, playerValues, Trap)
	local Connections = {}
	local Cancelled = false
	
	Connections.Cancel = playerValues.Action.Changed:Connect(function()

		if playerValues.Action.Value == "Cancel Disarm" then
			Cancelled = true
		end
	end)
	
	playerValues.Action.Value = "Disarming"
	Trap:WaitForChild('Panel').User.Value = Survivor.Name
	
	Trap:WaitForChild('Panel').Progress.Value = 0 -- reset progress just in case
	
	Connections.Heart = game:GetService('RunService').Heartbeat:Connect(function(delta)
		if not Trap or not Trap.Parent then Connections.Heart:Disconnect() Connections.Heart = nil Cancelled = true end
		
		if Trap:WaitForChild('Panel'):WaitForChild('State').Value == "Captured" then
			
			if Trap.Panel.Progress.Value < 1000 then
				Trap.Panel.Progress.Value = math.clamp(Trap.Panel.Progress.Value + (delta * TrapSettings.Struggle_Speed), 0, 1000)
			end
		end
	end)

	repeat task.wait()
	until Cancelled or not Trap.Parent or Trap.Panel.Progress.Value >= 1000

	Connections.Cancel:Disconnect()
	if Connections.Heart then Connections.Heart:Disconnect() Connections.Heart = nil end

	if Trap and Trap.Parent and Trap.Panel.Progress.Value >= 1000 then
		Trap.Panel.State.Value = "Disarmed"
		playerValues.Action.Value = "Nothing"
		
		data_module:GiveBlood(Survivor,500,"Boldness","STRUGGLED OUT")
	elseif Cancelled then
		playerValues.Action.Value = "Trapped"
	end

	Trap:WaitForChild('Panel').User.Value = ""
end

-- Killer Functions

function Place(Killer : Player, Backpack, perkBase, playerValues) : "Place Trap"
	local Connections = {}
	local Cancelled = false
	
	Connections.Cancel = playerValues.KillerAction.Changed:Connect(function()
		
		if playerValues.KillerAction.Value == "Cancel Trapping" then
			Cancelled = true
		end
	end)
	
	Connections.Stun = playerValues.Stunned.Changed:Connect(function()
		
		if playerValues.Stunned.Value then
			Cancelled = true
		end
	end)
	
	playerValues.KillerAction.Value = "Trapping"
	
	local timestamp, timer = trapper_module:Trap(Killer.Character)
	
	repeat task.wait()
	until Cancelled or (workspace:GetServerTimeNow() - timestamp) > timer
	
	Connections.Cancel:Disconnect()
	Connections.Stun:Disconnect()
	
	if not Cancelled then
		Killer.Character.Humanoid.WalkSpeed = module.Settings.Speeds.Base
	else
		trapper_module:Cancel(Killer.Character)
		Killer.Character.Humanoid.WalkSpeed = module.Settings.Speeds.Base
		Killer.Character.PrimaryPart.Anchored = false
	end
	
	playerValues.KillerAction.Value = "Nothing"
end

function Grab(Killer : Player, Trap : Model, playerValues) : "Grab Trap"
	local Character = Killer.Character
	local trap_table = Character:GetAttribute("Traps")
	trap_table = string.split(trap_table, ':')

	playerValues.KillerAction.Value = "Grabbing"

	Character.Humanoid.WalkSpeed = 0
	Character.PrimaryPart.Anchored = true
	
	if not module.Saved[Character.Name] then
		module.Saved[Character.Name] = {}
		module.Saved[Character.Name].Track = Character.Humanoid:WaitForChild('Animator'):LoadAnimation(grabbing_animation)
	end
	
	module.Saved[Character.Name].Track:Play(nil, nil, 5)
	
	task.wait(.1)
	Character.Humanoid.WalkSpeed = 0
	
	module.Saved[Character.Name].Track.Stopped:Wait()
	
	Character:SetAttribute("Traps", (tonumber(trap_table[1]) + 1)..':'..trap_table[2])
	Trap:Destroy()

	data_module:GiveBlood(game.Players:FindFirstChild(Character.Name), 150, "Deviousness", "COLLECTED TRAP")
	
	Character.Humanoid.WalkSpeed = module.Settings.Speeds.Base
	Character.PrimaryPart.Anchored = false
	
	playerValues.KillerAction.Value = "Nothing"
end

function Reset(Killer : Player, Trap : Model, perkBase, playerValues) : "Reset Trap"
	local Connections = {}
	local Cancelled = false

	Connections.Cancel = playerValues.KillerAction.Changed:Connect(function()

		if playerValues.KillerAction.Value == "Cancel Resetting" then
			Cancelled = true
		end
	end)

	Connections.Stun = playerValues.Stunned.Changed:Connect(function()

		if playerValues.Stunned.Value then
			Cancelled = true
		end
	end)

	playerValues.KillerAction.Value = "Resetting"

	local timestamp, timer = trapper_module:Reset(Killer.Character,Trap)

	repeat task.wait()
	until Cancelled or (workspace:GetServerTimeNow() - timestamp) > timer

	Connections.Cancel:Disconnect()
	Connections.Stun:Disconnect()

	if not Cancelled then
		Killer.Character.Humanoid.WalkSpeed = module.Settings.Speeds.Base
	else
		trapper_module:Cancel(Killer.Character)
		Killer.Character.Humanoid.WalkSpeed = module.Settings.Speeds.Base
		Killer.Character.PrimaryPart.Anchored = false
	end

	playerValues.KillerAction.Value = "Nothing"
end

--

function module:Fire(Player : Player, Arguments : "table")
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')
	
	if Arguments[2] == "Place" and Player.Character:GetAttribute("Traps") then
		local amount = string.split(Player.Character:GetAttribute("Traps"), ':')
		
		if Arguments[3] and tonumber(amount[1]) > 0 then -- has a trap
			Place(Player, Backpack, perkBase, playerValues)
		elseif playerValues.KillerAction.Value == "Trapping" then
			playerValues.KillerAction.Value = "Cancel Trapping"
		end
	elseif Arguments[2] == "Grab" then
		Grab(Player, Arguments[3], playerValues)
	elseif Arguments[2] == "Reset" then
		if Arguments[3] then
			Reset(Player, Arguments[3], perkBase, playerValues)
		elseif playerValues.KillerAction.Value == "Resetting" then
			playerValues.KillerAction.Value = "Cancel Resetting"
		end
	elseif Arguments[2] == "Struggle" then
		if Arguments[3] then
			Struggle(Player, Backpack, perkBase, playerValues, Arguments[4])
		elseif playerValues.Action.Value == "Disarming" then
			playerValues.Action.Value = "Cancel Disarm"
		end
	elseif Arguments[2] == "Disarm" then
		
		if Arguments[3] then
			Disarm(Player, Backpack, perkBase, playerValues, Arguments[4])
		elseif playerValues.Action.Value == "Disarming" then
			playerValues.Action.Value = "Cancel Disarm"
		end
	end
end

return module
