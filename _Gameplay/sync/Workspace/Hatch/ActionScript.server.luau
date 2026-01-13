local Players : Players, ReplicatedStorage : ReplicatedStorage, RunService : RunService,ServerStorage : ServerStorage = game:GetService('Players'), game:GetService('ReplicatedStorage'), game:GetService('RunService'),game:GetService("ServerStorage")

local remoteStorage = ReplicatedStorage:WaitForChild('RemoteEvents')

local Match : Folder = ReplicatedStorage:WaitForChild('Match')
local Generator_Count : IntValue = workspace:WaitForChild('MatchValues'):WaitForChild('GeneratorsRepaired')
local Hatch = script.Parent

local HatchTracks = {
	Unlocking = Hatch:WaitForChild('Humanoid'):WaitForChild("Animator"):LoadAnimation(script:WaitForChild('Unlocking'));
	Open = Hatch:WaitForChild('Humanoid'):WaitForChild("Animator"):LoadAnimation(script:WaitForChild('Unlocked'));
}

local Remotes = {
	Hatch = remoteStorage:WaitForChild('HatchAction')
}

local Modules = {
	Escape = require(script:WaitForChild('Escape'));
	Code = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'));
	Data = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Data"));
	EndGameCollapse = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Collapse'));
	BadgeManager = require(ServerStorage:FindFirstChild("Modules"):FindFirstChild("BadgeManager"))
}

local Perk_Modules = {
	Focused = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Focused'))
}

--[[local Audios = {
	Door = Hatch:WaitForChild('HumanoidRootPart'):WaitForChild('Door');
	Hint = Hatch:WaitForChild('HumanoidRootPart'):WaitForChild('Hint');
	Unlocking = Hatch:WaitForChild('HumanoidRootPart'):WaitForChild('Unlocking');
}]]--

local mid_close = false

local Server_Settings = {
	Prior_Open = false;
	Tampered = false;
	Spawned = false;
	Length = 5;
	Speed_Modification = 1;
}

local EGC : boolean, Local_State : string  = false, "Hidden"

function last_survivor() : "does the checks for last survivor"
	local Survivor = game.Teams:WaitForChild('Survivor'):GetPlayers()

	if #Survivor <= 1 then
		return true
	end

	return false
end

function UpdateHatch() : "Update Hatch Properties"
	local Current_State = Hatch:GetAttribute("State")

	if Server_Settings.Spawned then
		Hatch:PivotTo(Hatch:GetAttribute("Spawn")) -- Set Location

		for _, part in pairs(Hatch:WaitForChild('Visual'):GetChildren()) do

			if part:IsA('BasePart') then
				part.Transparency = 0
			end
		end
	else

		for _, part in pairs(Hatch:WaitForChild('Visual'):GetChildren()) do

			if part:IsA('BasePart') then
				part.Transparency = 1
			end
		end
	end

	if Current_State == "Open" then

		if not HatchTracks.Open.IsPlaying then
			HatchTracks.Open:Play()
		end

		Modules.Code:World_Sound("Hatch_Hint", Hatch)


		if not Hatch:WaitForChild('HumanoidRootPart'):WaitForChild('Smoke').Enabled then
			Hatch.HumanoidRootPart.Smoke.Enabled = true
		end

		Hatch:SetAttribute("Progress", 0)
	elseif Current_State == "Unlocking" then

		if HatchTracks.Open.IsPlaying then
			HatchTracks.Open:Stop()
		end

		Modules.Code:World_Sound('Hatch_Unlocking', Hatch)
		--[[if Audios.Hint.IsPlaying then
			Audios.Hint:Stop()
		end
		
		if not Audios.Unlocking.IsPlaying then
			Audios.Unlocking.Playing = true
		end]]--

		if Hatch:WaitForChild('HumanoidRootPart'):WaitForChild('Smoke').Enabled then
			Hatch.HumanoidRootPart.Smoke.Enabled = false
		end
	elseif Current_State == "Idle" then

		if HatchTracks.Open.IsPlaying then
			HatchTracks.Open:Stop()
		end

		Modules.Code:World_Sound('Hatch_Idle', Hatch)
		--[[if Audios.Hint.IsPlaying then
			Audios.Hint:Stop()
		end

		if Audios.Unlocking.IsPlaying then
			Audios.Unlocking.Playing = false
		end]]--

		if Hatch:WaitForChild('HumanoidRootPart'):WaitForChild('Smoke').Enabled then
			Hatch.HumanoidRootPart.Smoke.Enabled = false
		end
	end
end

Hatch:GetAttributeChangedSignal("Progress"):Connect(function()
	local Current_Progress = Hatch:GetAttribute("Progress") -- current progress to opening
	local Current_State = Hatch:GetAttribute("State")

	if tonumber(Current_Progress) >= 1000 and (Current_State ~= "Open") then
		Hatch:SetAttribute("State", "Open") -- open the hatch
		--Audios.Door:Play()
		Modules.Code:World_Sound('Hatch_Open', Hatch)

		Server_Settings.Prior_Open = true -- do not notify again

		if Hatch:GetAttribute("User") then
			local Player = game.Players:FindFirstChild(Hatch:GetAttribute("User"))

			if Player then
				Modules.BadgeManager.Award("Key To Success", Player.UserId)
				Modules.Data:GiveBlood(Player, 5000, "Suvival", "HATCH UNLOCK")

				if Player.Character:FindFirstChild("Purple_Key") then
					Player.Character.Purple_Key:Remove()
				end

				Hatch:SetAttribute("User", nil)
				Player.Character:SetAttribute("Motion_Locked", false)
				Player.Character.PrimaryPart.Anchored = false
			end
		end

		UpdateHatch()
	elseif not Server_Settings.Tampered and (Current_State ~= "Open") then -- perk or key use let killer know it's been tampered
		Server_Settings.Tampered = true
		for i, plr in pairs(game.Teams.Killer:GetPlayers()) do
			Modules.Code:AddNotification(Hatch:GetPivot() * CFrame.new(0, 4, 0), 5, "Hatch", plr)
		end
	end
end)

Remotes.Hatch.OnServerEvent:Connect(function(Player : Player, Command : "Close" | "Unlock" | "Stop_Unlock")
	if (Player.Character:GetPivot().Position - Hatch.HumanoidRootPart.Position).Magnitude >= 7.5 then return end
	local Current_Progress = Hatch:GetAttribute("Progress") -- current progress to opening
	local Current_State = Hatch:GetAttribute("State")
	local Current_User = Hatch:GetAttribute("User")

	if (Current_User and Current_User ~= "" and Current_User ~= Player.Name) then return end -- Can not input hatch commands if someone else is using

	if Command == "Start_Close" and Current_State == "Open" then 
		mid_close = true
		return
	end

	if Command == "Close" and Current_State == "Open" then -- killer stomp close
		Hatch:SetAttribute("State", "Idle")
		Hatch:SetAttribute("Progress", 0)

		UpdateHatch()

		Modules.Data:GiveBlood(Player, 2500, "Deviousness", "HATCH CLOSED")
		Modules.BadgeManager.Award("Not So Fast", Player.UserId)

		if not EGC and last_survivor() then
			EGC = true
			Generator_Count.Value = 5
			Modules.EndGameCollapse:Start()
			mid_close = false
		end
	elseif Command == 'Unlock' and Current_State == "Idle" then -- unlock
		local HasFocused, FocusTier = Modules.Data:GetPerk("Focused", Player)

		Server_Settings.Speed_Modification = 1 -- reset speed modifier to 1

		if HasFocused then
			Server_Settings.Speed_Modification *= (Perk_Modules.Focused.Tiers[FocusTier]/100)
		end

		if (HasFocused and last_survivor()) or Player.Character:FindFirstChild("Purple_Key") then
			Hatch:SetAttribute("User", Player.Name)
			Hatch:SetAttribute('State', "Unlocking")
			Player.Character:SetAttribute("Motion_Locked", true)
			Player.Character.PrimaryPart.Anchored = true
			Player.Character:PivotTo(Hatch:GetPivot() * CFrame.new(0, 4.1, 3.4))
		end
	elseif Command == "Stop_Unlock" and Hatch:GetAttribute("User") == Player.Name and Current_State == "Unlocking" then -- stop unlocking
		Hatch:SetAttribute('State', "Idle")
		Hatch:SetAttribute("User", nil)
		Player.Character:SetAttribute("Motion_Locked", false)
		Player.Character.PrimaryPart.Anchored = false
	elseif Command == "Use" and Current_State == "Open" and not mid_close then -- escape through hatch
		Hatch:SetAttribute("User", Player.Name)

		Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "HatchScape"

		Modules.Data:GiveBlood(Player, 5000, "Objectives", "HATCH ESCAPE")
		Modules.Data:GiveBlood(Player, 10000, "Survival", "ESCAPED")

		if Modules.Code:IsObsession(Player) then
			Modules.Data:GiveBlood(Player, 2500, "Survival", "OBSESSION ESCAPED")
		end

		Modules.Escape:Escape(Player)
		Modules.BadgeManager.Award("Backdoor", Player.UserId)

		task.wait(1.5)

		Hatch:SetAttribute("User", nil)
	end

	UpdateHatch()
end)

RunService.Stepped:Connect(function(_, step)
	if Hatch:GetAttribute("State") == "Open" or not Match:WaitForChild('Started').Value then coroutine.yield() return end -- not enough time has elapsed do nothing / Hatch is already open no point to update further
	local last_survivor : boolean = last_survivor()
	local CurrentGenerators = Generator_Count.Value

	if (last_survivor or CurrentGenerators >= 2) and not Server_Settings.Spawned then
		Server_Settings.Spawned = true -- spawn in the hatch
		UpdateHatch()
	end

	if not Server_Settings.Spawned then coroutine.yield() return end -- hatch is not spawned therefore no logic to mess with
	local Current_Progress = Hatch:GetAttribute("Progress") -- current progress to opening
	local Current_State = Hatch:GetAttribute("State")

	if Current_State == "Unlocking" then
		Hatch:SetAttribute("Progress", ((1000/Server_Settings.Length) * Server_Settings.Speed_Modification * step) + Current_Progress)
	end

	if Server_Settings.Prior_Open then coroutine.yield() return end -- Previously opened do not bother opening for last survivor

	if last_survivor and Server_Settings.Spawned and tonumber(Current_Progress) < 1000 then -- open the hatch
		Hatch:SetAttribute("Progress", 1000) -- auto open
	end
end)
