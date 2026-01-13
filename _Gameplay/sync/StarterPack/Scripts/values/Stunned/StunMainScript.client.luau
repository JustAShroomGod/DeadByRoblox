local remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
betterUpdate = remoteEvents:WaitForChild("NewPropertie")

local userInputService = game:GetService("UserInputService")

local player = game.Players.LocalPlayer
local char = workspace:WaitForChild(player.Name)

local camera = workspace.CurrentCamera
local humanoid = char:WaitForChild("Humanoid")
local head = char:WaitForChild("Head")

local Perk_Data = game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks')
local Item_Data = game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Items')

local Modules = {
	Data = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'));
	Code = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Code'));
}

local Backpack = player:WaitForChild("Backpack")
local Scripts = Backpack:WaitForChild("Scripts")
local killer = Scripts:WaitForChild("Killer")

local BloodRage = {
	Power = nil;
	Progress = nil;
	State = nil;
}

function Obfuscate(TYPE, VALUE1, VALUE2)
	local tablev = {}
	local List = {"Bbh1O", "D9v8", "Dbh1O", "Dvh1O", "Dhv8"}

	TYPE = string.lower(TYPE)

	if TYPE == 'string' then
		TYPE = 'S101'
	elseif TYPE == 'object' then
		TYPE = 'O101'
	elseif TYPE == 'number' then
		TYPE = 'I101'
	elseif TYPE == 'bool' then
		TYPE = 'B101'
	end

	local Packaged = {
		['C22'] = TYPE;
		['C21'] = VALUE1;
		['C20'] = VALUE2;
	}

	for _,key in pairs(List) do
		tablev[key] = Packaged
	end

	betterUpdate:FireServer(tablev)
end

local backpack = player:WaitForChild("Backpack")
local scripts = backpack:WaitForChild("Scripts")
local killer_value = scripts:WaitForChild("Killer")
local values = scripts:WaitForChild("values")
local action = values:WaitForChild("KillerAction")
local stunned = values:WaitForChild("Stunned")
local stunner = stunned:WaitForChild("Stunner")
local kind = stunned:WaitForChild("Kind")

local globalKiller = scripts:WaitForChild("GlobalKiller")

local character = Modules.Data:GrabCharacter()

local playerscripts = player:WaitForChild("PlayerScripts")
local controlscript = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()

local Stun_Animation = script:WaitForChild('Stun_Animation')
local track = {}

local stunned = false
local recovering = false

local tier = 1

script.Parent.Changed:Connect(function() -- if we have been stunned or unstunned --
	if not script.Parent.Value or not killer_value.Value then return end -- cancel out
	local IFrame, AFrame = Modules.Code:GetEffect("IFrame"), Modules.Code:GetEffect("AFrame")

	if (IFrame and IFrame.Active) or (AFrame and AFrame.Active) or (action.Value == "GraspBegin" and kind.Value ~= "Defense") then -- cancel out stun
		stunned = false
		Obfuscate("bool", script.Parent, false)
		return
	else
		if character.Value == "Psychopath" and killer.Value then
			BloodRage.Power = char:WaitForChild("BloodRage")
			BloodRage.AuraDistance = BloodRage.Power:WaitForChild("PowerValues"):GetAttribute("AuraDistance")
			BloodRage.Progress = BloodRage.Power:GetAttribute("Progress")
			BloodRage.State = char:GetAttribute("Power_State")
		end

		stunned = true -- our stun value is true in the script --

		humanoid:Move(Vector3.zero)
		controlscript:Disable() -- ties us down in controls CHANGE CHEETAH add this to pickup to prevent moving while picking up --

		humanoid.WalkSpeed = 0
		humanoid.AutoRotate = false
		humanoid.Parent.HumanoidRootPart.Anchored = true

		local CameraController = require(Scripts:WaitForChild('GlobalKiller').Camera)
		CameraController.Camera.HeadLocked = true

		if action.Value ~= "Rush_Charge" then
			Obfuscate("string", action, "Stun")
		end

		local HasPerk, PerkTier = Modules.Data:GetPerk("Enduring")
		local stunTime, validStun = 0, false

		if char:GetAttribute("Carry") then -- send request to free them
			remoteEvents:WaitForChild('Server_Event'):FireServer("Carry", "Rescued")

			if kind.Value ~= "Defense" then -- do not convert if ds
				kind.Value = "Wiggle" -- convert to wiggle so no stun immunity
			end
		end

		if kind.Value == "Normal"
			or kind.Value == "Pallet" then
			
			local stunnerPlayer = game.Players[stunner.Value]
			local StunMultiplier = Modules.Code:GetPlayerValue(stunnerPlayer, "StunMultiplier")

			validStun = true
			stunTime = 2 * StunMultiplier
		elseif kind.Value == "Knife" then
			validStun = not require(Item_Data:WaitForChild('Bone_Knife')).Ignore_Reduction
			stunTime = require(Item_Data:WaitForChild('Bone_Knife')).Stun_Duration
		elseif kind.Value == "Trap" then
			validStun = false
			stunTime = 3.5
		elseif kind.Value == "Wiggle" then
			validStun = false
			stunTime = 3.5
		elseif kind.Value == "Fearless" then
			validStun = not require(Perk_Data:WaitForChild('Survivor'):WaitForChild('Fearless')).Ignore_Reduction
			stunTime = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('Fearless')).Stun_Duration
		elseif kind.Value == "HeadOn" then
			validStun = not require(Perk_Data:WaitForChild('Survivor'):WaitForChild('HeadOn')).Ignore_Reduction
			stunTime = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('HeadOn')).Stun_Duration
		elseif kind.Value == "Defense" then
			validStun = not require(Perk_Data:WaitForChild('Survivor'):WaitForChild('DecisiveStrike')).Ignore_Reduction
			stunTime = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('DecisiveStrike')).Stun_Duration
		elseif kind.Value == "Tic Tac" then
			validStun = not require(Perk_Data:WaitForChild('Survivor'):WaitForChild('Tic Tac')).Ignore_Reduction
			stunTime = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('Tic Tac')).Stun_Duration
		elseif kind.Value == "ShockingSurprise" then
			validStun = false
			stunTime = require(Perk_Data:WaitForChild('Survivor'):WaitForChild('ShockingSurprise')).Stun_Duration
		end

		if HasPerk and validStun then
			stunTime *= (100 - require(Perk_Data:WaitForChild('Killer'):WaitForChild('Enduring')).Tiers[PerkTier])/100
		end

		if character.Value == "Psychopath" and BloodRage.State == "Using" then
			stunTime = 5
			coroutine.resume(coroutine.create(function()
				if kind.Value == "Fearless" or kind.Value == "Knife" then
					script:WaitForChild("RemoteEvent"):FireServer("Shabam")
				else
					script:WaitForChild("RemoteEvent"):FireServer()
				end
			end))
		end

		if script.Parent.CloakRelatedStun.Value == true then
			stunTime *= 1.6
		end

		track.stun = humanoid:LoadAnimation(Stun_Animation)

		local stunStoppedConnection stunStoppedConnection = track.stun.Stopped:Connect(function()
			stunStoppedConnection:Disconnect()

			CameraController.Camera.HeadLocked = false

			humanoid.Parent.HumanoidRootPart.Anchored = false
			humanoid.AutoRotate = true
			humanoid.WalkSpeed = Modules.Code:GetPlayerValue(player, "Speed") * Modules.Code:GetPlayerValue(player, "SpeedMultiplier")

			stunned = false

			Obfuscate("string", kind, "Normal")
			Obfuscate("bool", script.Parent, false)
			if action.Value ~= "Rush_Charge" then
				controlscript:Enable()
				Obfuscate("string", action,"Nothing")
			end
		end)

		track.stun:Play(0, 1, 1/stunTime)
		remoteEvents.EventRemotes.ActionEvent:FireServer("Stun", kind.Value)
	end
end)
