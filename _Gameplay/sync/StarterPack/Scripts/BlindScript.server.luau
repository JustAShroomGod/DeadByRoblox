local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local ServerStorage = game:GetService('ServerStorage')

local Badge_Manager = require(ServerStorage:WaitForChild("Modules"):WaitForChild("BadgeManager"))
local Data_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Code_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Events = require(ServerScriptService["Event System"].Events)

local IsKiller : BoolValue = script.Parent:WaitForChild('Killer')
local FlashFolder : Folder, Brightness : StringValue, Blinded : BoolValue = script:WaitForChild('Flashing'), script:WaitForChild('Brightness'), script:WaitForChild('Blinded')

local Action = script.Parent:WaitForChild('values'):WaitForChild('KillerAction')
local Stun = script.Parent:WaitForChild('values'):WaitForChild('Stunned')

local Killer = script.Parent.Parent.Parent
local Character = Killer.Character

local FlashedFilled = false

local Debounces = {
	LastBlind = 0;
	LastReward = 0;
}

local Settings = {
	['Fall_Off_Rate'] = 0.31;
	["Fill_Rate"] = 67;
	["Deplate_Rate"] = 70;
	["Blind_Time"] = 2.4;
	["Reward_Time"] = 1;
	--
	Blind_Recover = 60; -- point we can start blinding again
	--
	Rewards = {
		Blind = 400;
		Save = 1250;
	}
}


function GetCount() : "Return Amount of Brightness Gaining" -- gains total brightness
	local CurrentBrightness, FallOff = 0, 1

	for _, numberValue : StringValue in pairs(FlashFolder:GetChildren())do

		if not game.Players:FindFirstChild(numberValue.Name) then numberValue:Destroy() continue end -- left while blinding the jerk

		if tonumber(numberValue.Value) >= 10 then -- firecracker/flashbang future support
			CurrentBrightness = 100
			break
		else
			CurrentBrightness += tonumber(numberValue.Value) * FallOff
			FallOff -= Settings.Fall_Off_Rate
		end
	end

	return CurrentBrightness
end

function BlindedEvent() : "Trigger when we become blinded"
	Debounces.LastBlind = workspace:GetServerTimeNow()
	Blinded.Value = true
	
	if Action.Value ~= "Hooking" and (workspace:GetServerTimeNow() - Debounces.LastReward) >= Settings.Reward_Time then
		Debounces.LastReward = workspace:GetServerTimeNow()
		
		local RescueToProcess : boolean = false
		local IFrame, AFrame = Code_Module:GetEffect("IFrame", Killer), Code_Module:GetEffect("AFrame", Killer)
		
		if Character:GetAttribute("Carry") and not Stun.Value
			and Action.Value ~= "GraspBegin"
			and (not IFrame or (IFrame and not IFrame.Active)) -- No IFrame
			and (not AFrame or (AFrame and not AFrame.Active)) then
			RescueToProcess = true
			
			Code_Module:Stun_Killer(Killer, "Wiggle")
		end
		
		for _, Player : StringValue in pairs(FlashFolder:GetChildren()) do
			if not game.Players:FindFirstChild(Player.Name) then Player:Remove() continue end
			local raw_player = game.Players:FindFirstChild(Player.Name)
			
			Events.Survivor.onKillerFlashed:Fire(Killer, raw_player)
			Data_Module:GiveBlood(raw_player, Settings.Rewards.Blind, "Boldness", "KILLER BLIND")
			Badge_Manager.Award("Light Mode",raw_player.UserId)
			
			if RescueToProcess then
				Data_Module:GiveBlood(raw_player, Settings.Rewards.Save, "Altruism", "KILLER GRASP RESCUE")
				Badge_Manager.Award("A Friend In Need", raw_player.UserId)
			end
			
			Player:Remove()
		end
	end
end

Blinded.Changed:Connect(function()
	
	if Blinded.Value then
		FlashedFilled = true
		task.wait(Settings.Blind_Time)
		FlashedFilled = false
	end
end)

local time_started, beat = workspace:GetServerTimeNow(), nil
beat = RunService.Heartbeat:Connect(function(delta)
	if not IsKiller.Value then
		
		if (workspace:GetServerTimeNow() - time_started) >= 30 then
			beat:Disconnect() beat = nil
		end
		
		coroutine.yield() return -- stops script if we are not killer
	end
	
	-- Process Blindness Value --
	local BrightnessAdd = GetCount() -- returns total brightness [0-4] or 100 if flashbang
	
	if (workspace:GetServerTimeNow() - Debounces.LastBlind) >= Settings.Blind_Time then -- we are not on beamer cooldown
		local FinalBright : number = 0

		if BrightnessAdd > 0 and not Blinded.Value then -- we are being blinded

			if BrightnessAdd >= 100 then
				FinalBright = 100
			else
				FinalBright = math.clamp(tonumber(Brightness.Value) + (BrightnessAdd * Settings.Fill_Rate * delta), 0, 100)
			end
		else -- we are not being blinded
			FinalBright = math.clamp(tonumber(Brightness.Value) - (Settings.Deplate_Rate * delta), 0, 100)
		end
		
		Brightness.Value = FinalBright
	end
	
	-- Process Blind Flipping --
	if (workspace:GetServerTimeNow() - Debounces.LastBlind) >= Settings.Blind_Time and not Blinded.Value and tonumber(Brightness.Value) >= 100 then
		BlindedEvent()
	elseif (workspace:GetServerTimeNow() - Debounces.LastBlind) >= Settings.Blind_Time and Blinded.Value and tonumber(Brightness.Value) <= Settings.Blind_Recover then
		Blinded.Value = false
	end
end)