local Https = game:GetService("HttpService")

local ExitPort = script.Parent.Parent
local AudioBox = ExitPort:WaitForChild('ROOT')
local AudioBox2 = ExitPort:WaitForChild("Wall_Mount"):WaitForChild("Wall_Mount")
local Using = script.Parent:WaitForChild('Using')
local Progress = script.Parent:WaitForChild('Progress')
local Blocked = script.Parent:WaitForChild('Blocked')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local Animated = false

local Animator = ExitPort:WaitForChild('AnimationController'):WaitForChild('Animator')
local Animations = ExitPort:WaitForChild('Animations')

local MatchValues = workspace:FindFirstChild("MatchValues")

local Code = require(game.ReplicatedStorage.Modules.Code)
local module = require(game.ReplicatedStorage.Modules.Collapse)
local WebhookHandler = require(game.ServerStorage.Modules.WebhookHandler)

local Connections = {}

local Tracks = {
	Open_Idle = Animator:LoadAnimation(Animations:WaitForChild('Open'));
	Open_Gate = Animator:LoadAnimation(Animations:WaitForChild('Opening'));
	Lever_Down = Animator:LoadAnimation(Animations:WaitForChild('Lever_Open'));
	Block_Gate = Animator:LoadAnimation(Animations:WaitForChild('Blocked'));
}

local SoundIds = {
	['Open'] = 'rbxassetid://7745716516';
	['Light1'] = 'rbxassetid://8519790621';
	['Light2'] = 'rbxassetid://8519792217'; 
	['Alarm'] = 'rbxassetid://8519802812';
}

local Lights = {
	[1] = ExitPort:WaitForChild('Lights'):WaitForChild('1'):WaitForChild('Bulb_Lever');
	[2] = ExitPort:WaitForChild('Lights'):WaitForChild('2'):WaitForChild('Bulb_Lever');
	[3] = ExitPort:WaitForChild('Lights'):WaitForChild('3'):WaitForChild('Bulb_Lever');
}

local Settings = {
	["Time_To_Open"] = 20;
	["Light_Color"] = Color3.fromRGB(255, 102, 102)
}

local function AddAudio(code)
	local S = Instance.new('Sound')
	if code == 'Open' then
		S.RollOffMaxDistance = 150
		S.RollOffMinDistance = 2
		S.RollOffMode = Enum.RollOffMode.Linear
		S.Volume = 7
		S.PlayOnRemove = true
		S.Looped = false
		S.Parent = AudioBox

		S.SoundId = SoundIds.Open
		S:Destroy()
	elseif code == 'Light1' then
		S.RollOffMaxDistance = 100
		S.RollOffMinDistance = 2
		S.RollOffMode = Enum.RollOffMode.Linear
		S.Volume = 4.5
		S.PlayOnRemove = true
		S.Looped = false
		S.Parent = AudioBox2

		S.SoundId = SoundIds.Light1
		S:Destroy()

	elseif code == 'Light2' then
		S.RollOffMaxDistance = 100
		S.RollOffMinDistance = 2
		S.RollOffMode = Enum.RollOffMode.Linear
		S.Volume = 4.5
		S.PlayOnRemove = true
		S.Looped = false
		S.Parent = AudioBox2

		S.SoundId = SoundIds.Light2
		S:Destroy()
	elseif code == 'Alarm' then
		S.RollOffMaxDistance = 100
		S.RollOffMinDistance = 2
		S.RollOffMode = Enum.RollOffMode.Linear
		S.Volume = 4.5
		S.PlayOnRemove = true
		S.Looped = false
		S.Parent = AudioBox2

		S.SoundId = SoundIds.Alarm
		S:Destroy()
	end
end

local function AnimateGate()
	if Animated then return end
	Animated = true

	Tracks.Open_Gate:Play()

	Tracks.Open_Gate:AdjustSpeed(0.33)

	Tracks.Open_Gate.Stopped:Wait()

	Tracks.Open_Idle:Play() -- play the open idle
end

script.Parent:WaitForChild('Exit_Gate').OnServerEvent:Connect(function(Player, ...)
	local args = {...}
	local command = args[1]

	local Values = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')

	if command == "KillerOpen" then
		Progress.Value = 1000
	end

	if command == "Open" then
		Player.Character:SetAttribute("Motion_Locked", true) -- motion locked

		Values.Action.Value = "OpeningGate" -- action change
		
		Player.Character:SetAttribute("CurrentInteractable", ExitPort.Name)
		
		Tracks.Lever_Down:Play() -- hold down lever

		Player.Character:PivotTo(ExitPort:WaitForChild('Port').CFrame * CFrame.new(0, 0.55, 0)) -- position
		Player.Character.PrimaryPart.Anchored = true

		-- if ds deactive ds --

		if not (MatchValues:FindFirstChild("GeneratorsRepaired").Value >= 5) then
			local ForwardedMessage = "[***NOT BANNED***] Anti-Cheat is tracking suspicious activity from "..Player.Name..' for trying to open exit gates at ' .. tostring(5 - MatchValues:FindFirstChild("GeneratorsRepaired").Value) .. ' generators left!'
			WebhookHandler.TriggerPEL(ForwardedMessage)

			return 
		end

		Using.Value = Player.Name

	elseif command == "Close" then
		Player.Character.PrimaryPart.Anchored = false
		Player.Character:SetAttribute("Motion_Locked", false)

		Using.Value = "NoUsing"

		if Tracks.Lever_Down.IsPlaying then -- release lever
			Tracks.Lever_Down:Stop()
		end

		Values.Action.Value = "Nothing"
		
		Player.Character:SetAttribute("CurrentInteractable", "")
	end
end)

workspace:GetAttributeChangedSignal("No_Escape"):Connect(function()
	local raw_string = workspace:GetAttribute("No_Escape")

	if not raw_string then return warn("no attribute") end
	local raw_Table = string.split(raw_string, ":")

	if not raw_Table[1] or not raw_Table[2] then warn("Corrupted Warden Values!") end

	Blocked.Value = true

	local Tween = nil

	for _,att in pairs(ExitPort:WaitForChild('Escape_Block'):GetChildren())do
		if att:IsA('Attachment') then
			att.Smoke.Enabled = true
		end
	end

	Tracks.Block_Gate:Play() -- play blocked animation

	repeat task.wait()
	until (workspace:GetServerTimeNow() - tonumber(raw_Table[2])) >= (tonumber(raw_Table[1]) - 1)

	if Tracks.Block_Gate.IsPlaying then -- release lever
		Tracks.Block_Gate:Stop()
	end

	for _,att in pairs(ExitPort:WaitForChild('Escape_Block'):GetChildren())do
		if att:IsA('Attachment') then
			att.Smoke.Enabled = false
		end
	end

	Blocked.Value = false
end)

Connections.ProgressProperty = Progress:GetPropertyChangedSignal("Value"):Connect(function()

	if not (Progress.Value < 1000) then
		module:Start()
		AnimateGate()

		if Connections.Heart then
			Connections.Heart:Disconnect()
			Connections.Heart = nil
		end

		if Connections.ProgressProperty then
			Connections.ProgressProperty:Disconnect()
			Connections.ProgressProperty = nil
		end
	end
end)

Connections.Heart = RunService.Heartbeat:Connect(function(step)

	if Progress.Value > 749 and Lights[3].Color ~= Settings.Light_Color then -- light 3
		AddAudio("Light1")
		AddAudio('Alarm')
		Lights[3].Color = Settings.Light_Color
		Lights[3].PointLight.Enabled = true
		task.wait(3)
		AddAudio("Alarm")
		task.wait(3)
		AddAudio("Alarm")
		task.wait(3)
		AddAudio("Alarm")
	elseif Progress.Value > 499 and Lights[2].Color ~= Settings.Light_Color then -- light 2

		AddAudio('Light2')
		Lights[2].Color = Settings.Light_Color
		Lights[2].PointLight.Enabled = true
	elseif Progress.Value > 249 and Lights[1].Color ~= Settings.Light_Color then -- light 1

		AddAudio('Light1')
		Lights[1].Color = Settings.Light_Color
		Lights[1].PointLight.Enabled = true
	end

	if Using.Value ~= "NoUsing" and Progress.Value < 1000 then

		local OpeningSpeed = Code:GetPlayerValue(Using.Value, "OpeningSpeed")

		Progress.Value += ((step * OpeningSpeed) * (1000/Settings.Time_To_Open))
	end

	Progress.Value = math.clamp(Progress.Value, 0, 1000)
end)