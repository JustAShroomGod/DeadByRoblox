local Players, ReplicatedStorage, ServerScriptService, ServerStorage = game:GetService('Players'), game:GetService('ReplicatedStorage'), game:GetService('ServerScriptService'), game:GetService("ServerStorage")

local Trap : Model = script.Parent.Parent
local Animator : Animation = Trap:WaitForChild('AnimationController'):WaitForChild('Animator')

local Root_Part : BasePart, Hit_Box : BasePart = Trap:WaitForChild('HumanoidRootPart'), Trap:WaitForChild('Hitbox')

local Game_Assets = ReplicatedStorage:WaitForChild("Game_Assets")
local Trap_Animations = Game_Assets:WaitForChild("Animations"):WaitForChild("BearTrap")

local Iri_Stone = require(game.ReplicatedStorage.Game_Data.Addons.Killer.IridescentStone)

local Addon_Settings = {
	IridescentStone = {
		ResetTime = Iri_Stone.Reset_Time;
		lastReset = workspace:GetServerTimeNow();
	}
}

local Trap_Settings = {
	State = Trap:WaitForChild('Panel'):WaitForChild('State'); -- state of trap
	User = Trap:WaitForChild('Panel'):WaitForChild('User'); -- killer setting trap or survivor disarming
	Progress = Trap:WaitForChild('Panel'):WaitForChild('Progress'); -- progress in disarming the trap
	Trapped = Trap:WaitForChild('Panel'):WaitForChild('Trapped'); -- person trapped
	CanPickup = Trap:WaitForChild("Panel"):WaitForChild("CanPickup") --if killer is able to pick it up
}

local Connections = {}

local Animations = {
	Stored = {
		Trapped = Trap_Animations:WaitForChild("Player"):WaitForChild("Player_Trapped");
		Stuck = Trap_Animations:WaitForChild("Player"):WaitForChild("Player_Stuck");
	};
	Trap = {
		Closed = Animator:LoadAnimation(Trap_Animations:WaitForChild("Object"):WaitForChild("BearTrap_Closed"))
	}; -- stores traps animations
	Characters = {}; -- stores character animations / prevents animation overloading
}


local Modules = {
	data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'));
	Code = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Code"));
	BadgeManager = require(ServerStorage:FindFirstChild("Modules"):FindFirstChild("BadgeManager"))
}
--[[
States Explained

States
 * Armed - In_Game and ready to trap;
 * Disarmed - Disabled and In_Game
 * Captured - In_Game and caught a user
]]

--local Events = require(game.ServerScriptService["Event System"]:WaitForChild("Events"))


local RootPart : BasePart, TrapHitBox : BasePart = Trap:WaitForChild('HumanoidRootPart'), Trap:WaitForChild('Hitbox')
local Trap_Sound : Sound = RootPart:WaitForChild('Sound')


local AddonValues = {
	["IridescentStone"] = {
		["Timer"] = 0,
		["RefreshTimer"] = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild('IridescentStone')).Reset_Time
	}
}

-- Useful functions --

function Notify() : "Sends Trap Notification"
	for i, plr in pairs(game.Teams.Killer:GetPlayers()) do
		Modules.Code:AddNotification(Trap.PrimaryPart.CFrame, 5, "Default", plr)
	end
	Trap_Sound:Play()
end

function GetAnimations(Character : Model) : boolean | "Crafts Survivor Animations to be stored on server"
	if Animations.Characters[Character.Name] then return true end
	local AnimationPoint : Animator = Character:WaitForChild('Humanoid'):WaitForChild('Animator')

	Animations.Characters[Character.Name] = {}

	for animationName, Animation in pairs(Animations.Stored) do
		Animations.Characters[Character.Name][animationName] = Animator:LoadAnimation(Animation)
	end

	return true
end

function StopSurvivorAnimations() : "Stop Survivor Animations"

	for Character_Name, AnimationTable in pairs(Animations.Characters) do

		for _, AnimationTrack : AnimationTrack in pairs(AnimationTable) do

			if AnimationTrack.IsPlaying then
				AnimationTrack:Stop()
			end
		end
	end
end

-- Main Logic --
Animations.Trap.Closed:Play()

function Disarm()
	if Connections.Hitbox then Connections.Hitbox:Disconnect() Connections.Hitbox = nil end

	if Trap_Settings.Trapped.Value then
		if Connections.Animation then Connections.Animation:Disconnect() Connections.Animation = nil end
		if Connections.Hit then Connections.Hit:Disconnect() Connections.Hit = nil end
		local Player : Player = Players:FindFirstChild(Trap_Settings.Trapped.Value.Name)

		if Player then
			local Character = Trap_Settings.Trapped.Value
			local Scripts = Player:WaitForChild('Backpack'):WaitForChild('Scripts')

			Character:SetAttribute("Motion_Locked", false)
			_G.GetValue(Player, "Speed"):Remove("Trapped")

			Character:WaitForChild('HumanoidRootPart').Anchored = false
			Scripts:WaitForChild('values'):WaitForChild('Action').Value = "Nothing"

			StopSurvivorAnimations()
		end
	end


	if not Animations.Trap.Closed.IsPlaying then
		Animations.Trap.Closed:Play()
	end

	Trap_Settings.Trapped.Value = nil
	Trap_Settings.Progress.Value = 0
	Trap_Settings.CanPickup.Value = true

	coroutine.wrap(Notify)() -- make gui

	Trap_Settings.User.Value = "" -- reset user value if not already reset
	Addon_Settings.IridescentStone.lastReset = workspace:GetServerTimeNow() -- start timer for stone
end

function Armed()
	Trap_Settings.CanPickup.Value = false

	if Animations.Trap.Closed.IsPlaying then
		Animations.Trap.Closed:Stop()
	end

	Trap_Settings.Progress.Value = 0

	Addon_Settings.IridescentStone.lastReset = nil

	if Connections.Hitbox then Connections.Hitbox:Disconnect() Connections.Hitbox = nil end
	Connections.Hitbox = TrapHitBox.Touched:Connect(HitSomething)
end

function Captured()
	if Connections.Hitbox then Connections.Hitbox:Disconnect() Connections.Hitbox = nil end
	if not Trap_Settings.Trapped.Value then return end

	local Player : Player = Players:FindFirstChild(Trap_Settings.Trapped.Value.Name)
	if not Player then return end

	if not Animations.Trap.Closed.IsPlaying then
		Animations.Trap.Closed:Play()
	end

	local Character : Model, Scripts = Trap_Settings.Trapped.Value, Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local PlayerSettings = {
		Humanoid = Character:WaitForChild('Humanoid');
		IsKiller = Scripts:WaitForChild('Killer').Value;
	}

	Trap_Settings.CanPickup.Value = false

	if PlayerSettings.IsKiller then
		local OldPos = Player.Character.HumanoidRootPart.Position
		task.wait(0.3)
		repeat task.wait() until (Player.Backpack.Scripts.values.Stunned.Value == false) and (Player.Character.HumanoidRootPart.Position - OldPos).Magnitude > 7
		Trap_Settings.State.Value = "Armed"
		Trap_Settings.CanPickup.Value = true
	else
		coroutine.wrap(Notify)()

		Character:SetAttribute("Motion_Locked", true)
		_G.GetValue(Player, "Speed"):Add("Trapped", 0, -1)
		
		Character:WaitForChild('HumanoidRootPart').Anchored = true
		Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(RootPart.Position.X, Character:WaitForChild("HumanoidRootPart").CFrame.p.Y, RootPart.Position.Z)

		GetAnimations(Character)

		Animations.Characters[Character.Name].Trapped:Play()

		Connections.Animation = Animations.Characters[Character.Name].Trapped.Stopped:Connect(function()
			Connections.Animation:Disconnect() Connections.Animation = nil
			Animations.Characters[Character.Name].Stuck:Play()
		end)


		local Killers = Modules.Code:getKiller()

		if Killers then
			if typeof(Killers) == "table" then
				for _, Killer in pairs(Killers) do
					Killer.Character:SetAttribute("AmountCaught", if not Killer.Character:GetAttribute("AmountCaught") then 1 else (Killer.Character:GetAttribute("AmountCaught") + 1))
					
					if Killer.Character:GetAttribute("AmountCaught") == 3 then
						Modules.BadgeManager.Award("Trap Master", Killer.UserId)
					end
					
					task.spawn(function()
						Modules.DataModule:GiveBlood(Killer, 1500, "Hunter", "TRAPPED!")
					end)
				end
			else				
				Killers.Character:SetAttribute("AmountCaught", if not Killers.Character:GetAttribute("AmountCaught") then 1 else (Killers.Character:GetAttribute("AmountCaught") + 1))
				
				if Killers.Character:GetAttribute("AmountCaught") == 3 then
					Modules.BadgeManager.Award("Trap Master", Player.UserId)
				end
				
				task.spawn(function()
					Modules.DataModule:GiveBlood(Killers, 1500, "Hunter", "TRAPPED!")
				end)
			end
		end
	end
end

function HitSomething(Part : BasePart) : "Trigger when we hit a part"
	if Part.Name == "Flash_Zone" then return end
	if Trap_Settings.Trapped.Value or Trap_Settings.State.Value == "Disarmed" or Trap_Settings.State.Value == "Captured" then
		Connections.Hitbox:Disconnect() Connections.Hitbox = nil
	end
	local Humanoid : Humanoid = Part.Parent:FindFirstChild("Humanoid")

	if not Humanoid then
		Part.Parent.Parent:FindFirstChildOfClass("Humanoid")
	end
	if not Humanoid then return end

	local Player : Player = Players:FindFirstChild(Humanoid.Parent.Name)
	if not Player then return end

	local Scripts = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local PerksBase, Values = Scripts:WaitForChild('PerksBase'), Scripts:WaitForChild('values')
	local PlayerSettings = {
		IsKiller = Scripts:WaitForChild('Killer').Value;
		IFrame = Modules.Code:GetEffect("IFrame", Player);
		AFrame = Modules.Code:GetEffect("AFrame", Player);
		Health = Values:WaitForChild('HealthState');
		Action = Values:WaitForChild('Action');
		Hooked = Values:WaitForChild('Hooked')
	}

	Trap_Settings.CanPickup.Value = false

	if PlayerSettings.IsKiller and Modules.data_module:GetAddon("Killer", Player, "Loyal Teeth") then Trap_Settings.State.Value = "Disarmed" return end -- ignore killer
	if (PlayerSettings.AFrame and PlayerSettings.AFrame.Active) or (PlayerSettings.IFrame and PlayerSettings.IFrame.Active) then return end -- has iframe/aframes do **IGNORE**

	if PlayerSettings.IsKiller then
		local Stun, Kind = Values:WaitForChild('Stunned'), Values:WaitForChild('Stunned'):WaitForChild('Kind')

		if not Stun.Value then
			Modules.Code:Stun_Killer(Player, "Trap")

			Trap_Settings.Trapped.Value = Humanoid.Parent
			Trap_Settings.State.Value = "Captured"
			
			Modules.BadgeManager.Award("Oopsie Daisy", Player.UserId)
		end
	elseif PlayerSettings.Action.Value ~= "Disarming" and not PlayerSettings.Hooked.Value and PlayerSettings.Health.Value > 0 then
		local CF = script.Parent.Parent.HumanoidRootPart.CFrame * CFrame.new(0,4,0)
		Trap_Settings.Progress.Value = 0
		Trap_Settings.Trapped.Value = Humanoid.Parent
		Trap_Settings.State.Value = "Captured"

		PlayerSettings.Action.Value = "Trapped"

		if PlayerSettings.Health.Value > 1 then
			PlayerSettings.Health.Value = 1
		end

		coroutine.resume(coroutine.create(function()
			repeat task.wait() 
				PlayerSettings.Action.Value = "Trapped"
				Humanoid.Parent.HumanoidRootPart.CFrame = CF
			until Trap_Settings.State.Value == "Disarmed"
			PlayerSettings.Action.Value = "Nothing"
		end))

		if Connections.Hit then Connections.Hit:Disconnect() Connections.Hit = nil end
		Connections.Hit = PlayerSettings.Health.Changed:Connect(function()
			if Connections.Hit then Connections.Hit:Disconnect() Connections.Hit = nil end
			Trap_Settings.State.Value = "Disarmed"
		end)
	end
end

Trap_Settings.State.Changed:Connect(function()
	local Current_State : "Armed" | "Disarmed" | "Captured" = Trap_Settings.State.Value

	if Current_State == "Disarmed" then -- got disarmed
		--print('State is changed to disarmed')
		Disarm()
	elseif Current_State == "Armed" then -- got armed
		Armed()
	elseif Current_State == "Captured" then -- got a player
		--print('Changed State to Captured')
		Captured()
	--else
		--warn(Current_State)
	end
end)

-- IRI Addon --
local Stone_Connection = nil

for _, Killer_Player in pairs(game.Teams:WaitForChild('Killer'):GetPlayers()) do
	if Stone_Connection then break end

	if Modules.data_module:GetAddon("Killer", Killer_Player, 'IridescentStone') then
		Stone_Connection = true
	end
end

if Stone_Connection then -- 1 killer had stone connection activate it

	while task.wait() do

		if (not Trap_Settings.Trapped.Value or Trap_Settings.Trapped.Value == nil) and (Trap_Settings.State.Value == "Disarmed" or Trap_Settings.State.Value == "Inactive") and Addon_Settings.IridescentStone.lastReset then

			if (workspace:GetServerTimeNow() - Addon_Settings.IridescentStone.lastReset) >= Addon_Settings.IridescentStone.ResetTime then
				Trap_Settings.State.Value = "Armed"
			end
		end
	end
end
