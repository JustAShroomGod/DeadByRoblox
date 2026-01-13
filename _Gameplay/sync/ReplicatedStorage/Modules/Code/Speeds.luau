local Data_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))
local Remotes = game.ReplicatedStorage.RemoteEvents

local RunService = game:GetService("RunService")

local Global_Settings = {
	Base_Speed = 15;
	Base_Carry_Speed = 14.25;
}

local Speeds = {
	Global_Settings = {
		Base_Speed = Global_Settings.Base_Speed;
		Base_Carry_Speed = Global_Settings.Base_Carry_Speed;
	},
	Survivor = {
		Running = 0.5; -- adds a 1x multiplier on top. doubling the base speed of 7.25 to 14.5
		Walking = Global_Settings.Base_Speed;
		Crouching = -0.3; 
		Crawling = -0.5; 
		Stagger = -0.8;
		Dash = 3.35;
	},
	Trapper = {
		Movement = 0.15;
		Carry = Global_Settings.Base_Carry_Speed;
	},
	Architect = {
		Movement = 0.15;
		Carry = Global_Settings.Base_Carry_Speed;
	},
	Ninja = {
		Movement = 0.15;
		Carry = Global_Settings.Base_Carry_Speed;
	},
	Reaper = {
		Movement = 0.15;
		Carry = Global_Settings.Base_Carry_Speed;
	},
	Wraith = {
		Movement = 0.15;
		Carry = Global_Settings.Base_Carry_Speed;
	},
	Doctor = {
		Movement = 0.15;
		Carry = Global_Settings.Base_Carry_Speed;
		Charging = 10;
	},
	Nurse = {
		Movement = -0.1;
		Carry = Global_Settings.Base_Carry_Speed;
		Charge = Global_Settings.Base_Speed * 0.9 * 0.35;
		PostBlink = Global_Settings.Base_Speed * 0.9 * 0.5;
		Fatigue = Global_Settings.Base_Speed * 0.9 * 0.35;
	},
	Stalker = {
		Movement = 0.15;
		Carry = Global_Settings.Base_Carry_Speed;
	},
	Huntress = {
		Movement = 0.10;
		Carry = Global_Settings.Base_Carry_Speed;
		Aiming = 12;
	},
	Hillbilly = {
		Movement = 0.15;
		Carry = Global_Settings.Base_Carry_Speed;
		Chainsaw = 11.7;
	},
	Psychopath = {
		Movement = 0.15;
		Carry = Global_Settings.Base_Carry_Speed;
		Rage = Global_Settings.Base_Speed * 1.1 * 0.15;
		Fatigue = 3;
	},
	Priest = {
		Movement = 0.15;
		Carry = Global_Settings.Base_Carry_Speed;
	},
	Phantasm = {
		Movement = 0.15;
		Carry = Global_Settings.Base_Carry_Speed;
	},
	Scientist = {
		Movement = 0.15;
		Carry = Global_Settings.Base_Carry_Speed;
	}
}


function Speeds:Get(Player : Player, Movement : "Movement" | "Carry" | "Rage" | "Fatigue" | "Chainsaw" | "Aiming" | "Charge" | "PostBlink") : "Return Speed and Update Speeds"
	local Killer = Data_Module:GetCharacter(Player)
	local Desired_Speed = Speeds[Killer]
	
	if Desired_Speed then

		if Desired_Speed[Movement] then

			if Movement == "Movement" then

				if Killer == 'Stalker' then -- get proper tier speed first
					local Current_Tier = (Player.Character:GetAttribute("Power_Tier") or 1)
					local SpeedTier = {.96, 1, 1.04}

					Desired_Speed[Movement] = Global_Settings.Base_Killer_Speed * SpeedTier[Current_Tier] -- updates stalker speed
				end

				return Desired_Speed[Movement]
			else -- a movement not affected by blood lust
				return Desired_Speed[Movement]
			end
		else
			return error(Movement..' IS NOT A TYPE OF SPEED WE CAN PULL FROM : '..Killer)
		end
	else
		return error(Killer..' IS NOT A KILLER WE CAN PULL SPEED FROM!')
	end
end

function Speeds:addSpeed(Player, EffectName, Amount, Time)

	if (RunService:IsClient()) then
		Remotes.ClientToServer.UpdateSpeed:FireServer("Add", "Speed", EffectName, Amount, Time)
	end

	if (RunService:IsServer() or RunService:IsStudio()) then
		Remotes.ServerBindable.UpdateSpeed:Fire(Player, "Add", "Speed", EffectName, Amount, Time)
	end
end

function Speeds:retrieveKillerBaseSpeed(Player) --does not account for anything other than killer's DEFAULT SPEED!
	local Killer = Player:WaitForChild("Data"):WaitForChild("Killer").Value
	
	if Killer == "" then Killer = "Trapper" end
	
	return Speeds.Global_Settings.Base_Speed + (Speeds.Global_Settings.Base_Speed * Speeds[Killer].Movement)
end

function Speeds:addMultiplier(Player, EffectName, Amount, Time)
	
	--print(EffectName, Amount, Time)
	--print(RunService:IsClient(), RunService:IsServer(), RunService:IsStudio())

	if (RunService:IsClient()) then
		Remotes.ClientToServer.UpdateSpeed:FireServer("Add", "Multiplier", EffectName, Amount, Time)
	end

	if (RunService:IsServer() or RunService:IsStudio()) then
		Remotes.ServerBindable.UpdateSpeed:Fire(Player, "Add", "Multiplier", EffectName, Amount, Time)
	end
end

function Speeds:removeSpeed(Player, EffectName)

	if (RunService:IsClient()) then
		Remotes.ClientToServer.UpdateSpeed:FireServer("Remove", "Speed", EffectName)
	end

	if (RunService:IsServer() or RunService:IsStudio()) then
		Remotes.ServerBindable.UpdateSpeed:Fire(Player, "Remove", "Speed", EffectName)
	end
end

function Speeds:removeMultiplier(Player, EffectName)

	if (RunService:IsClient()) then
		Remotes.ClientToServer.UpdateSpeed:FireServer("Remove", "Multiplier", EffectName)
	end

	if (RunService:IsServer() or RunService:IsStudio()) then
		Remotes.ServerBindable.UpdateSpeed:Fire(Player, "Remove", "Multiplier", EffectName)
	end
end

function Speeds:addUser(Player)

	if (RunService:IsClient()) then
		Remotes.ClientToServer.UpdateSpeed:FireServer("Add", "User")
	end

	if (RunService:IsServer() or RunService:IsStudio()) then
		Remotes.ServerBindable.UpdateSpeed:Fire(Player, "Add", "User")
	end
end

function Speeds:removeUser(Player)

	if (RunService:IsClient()) then
		Remotes.ClientToServer.UpdateSpeed:FireServer(Player, "Remove", "User")
	end

	if (RunService:IsServer() or RunService:IsStudio()) then
		Remotes.ServerBindable.UpdateSpeed:Fire(Player, "Remove", "User")
	end
end

return Speeds