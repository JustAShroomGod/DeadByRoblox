local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local Backup_Length = 5
local Killer_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild('Trapper'))
local Trap_Source = ReplicatedStorage:WaitForChild('KillerStuff'):WaitForChild('Trap')
local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local Addons = require(script.Parent:WaitForChild('Addon'))
local Grab_Animation = script.Parent.Parent.Parent:WaitForChild('Animations'):WaitForChild('Trapper_Trap_Place')

local Trapper = {
	Settings = {
		WalkingSpeeds = {
			Base = 15;
		},
		AnimationSpeeds = {
			Default = 2; -- 2 second animation = 1.5 second cloak time
		},
	},
	Characters = {}
}

function GenerateData(Character : Model) : "Create Tweening Data"
	if Trapper.Characters[Character.Name] then return end
	
	Trapper.Characters[Character.Name] = {} -- create character/tween data for this character
	
	Trapper.Characters[Character.Name].State = "Nothing"
	Trapper.Characters[Character.Name].Trap = nil --for resetting
	
	Trapper.Characters[Character.Name].AnimationSpeeds = {
		Default = Trapper.Settings.AnimationSpeeds.Default;
	}
	
	Trapper.Characters[Character.Name].AnimationTrack = Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(Grab_Animation)
	
	-- Calculate effect of addons --
	
	local Addons_Data = data_module:GetAddons("Killer", game.Players:GetPlayerFromCharacter(Character))

	for _,Addon in pairs(Addons_Data) do
		if Addons[Addon] then
			--warn("ADDON;",Addon)
			if Addons[Addon].Effects then
				for effectName, Effect in pairs(Addons[Addon].Effects) do
					for effectName, Effect in pairs(Addons[Addon].Effects) do
						if string.match(Effect.Type, "SPEED") and string.match(Effect.Type, "ANIMATION") then
							Trapper.Characters[Character.Name].AnimationSpeeds.Default *= (1 + Effect.Value/100) -- increase or decreases
						end
					end
				end
			end
		end
	end
	
	-- Adding Sound Effects --
	local function PlaySound(id : number, volume : number, pitch : number) : "Play Sound"
		local Sound = Instance.new('Sound', Character.HumanoidRootPart)
		Sound.PlayOnRemove = true
		Sound.Volume = if volume then volume else 1
		Sound.SoundId = "http://www.roblox.com/Asset?ID="..tostring(id)
		Sound:Remove()
	end

	if Trapper.Characters[Character.Name].AnimationTrack.Length > 0 then
		Trapper.Characters[Character.Name].AnimationLength = Trapper.Characters[Character.Name].AnimationTrack.Length
	else
		game:GetService('ContentProvider'):PreloadAsync({Grab_Animation})
		Trapper.Characters[Character.Name].AnimationLength = Trapper.Characters[Character.Name].AnimationTrack.Length
	end
	
	local RayParams = RaycastParams.new()
	RayParams.FilterDescendantsInstances = {Character}
	
	local function playSoundEffect(name : string) : "Plays sound based on cue"
		
		if name == "Frame1" then
			Trapper.Characters[Character.Name].State = "Trap Locked"
			
			if Trapper.Characters[Character.Name].Trap then
				Trapper.Characters[Character.Name].Trap:WaitForChild('Panel'):WaitForChild('CanPickup').Value = false
				
				task.delay(1, function()
					code_module:SetEffect("Haste", Players:FindFirstChild(Character.Name), {5, (Killer_Module.Trap_Set)}, 'Trap_Set')
					data_module:GiveBlood(Players:FindFirstChild(Character.Name), 500, "Deviousness", "RESET TRAP")
				end)
				
				task.delay(2, function()
					Trapper.Characters[Character.Name].Trap:WaitForChild('Panel'):WaitForChild('State').Value = "Armed"
					
					Trapper.Characters[Character.Name].Trap = nil
				end)
				
				return
			end
			
			local trap_table = Character:GetAttribute("Traps")
			trap_table = string.split(trap_table, ':')
			
			Character:SetAttribute("Traps", (tonumber(trap_table[1]) - 1)..':'..trap_table[2])
			
			local New_Trap = Trap_Source:Clone()
			
			local Origin, Goal = Character:GetPivot() * CFrame.new(0, -4.4, 0), Character:GetPivot() * CFrame.new(0, -4.4, -2.4)
			local Cast = workspace:Raycast(Origin.Position, (Goal.Position - Origin.Position).Unit * (Goal.Position - Origin.Position).Magnitude, RayParams)

			if Cast then
				New_Trap:WaitForChild('HumanoidRootPart').CFrame = Character:GetPivot() * CFrame.new(0, -4.4, -Cast.Distance + 1.4)
			else
				New_Trap:WaitForChild('HumanoidRootPart').CFrame = Goal
			end
			
			New_Trap:WaitForChild("Panel"):WaitForChild("CanPickup").Value = false
			New_Trap.Name = "Trap_" .. HttpService:GenerateGUID(false)
			New_Trap.Parent = workspace
			
			task.delay(1, function()
				code_module:SetEffect("Haste", Players:FindFirstChild(Character.Name), {5, (Killer_Module.Trap_Set)}, 'Trap_Set')
				data_module:GiveBlood(Players:FindFirstChild(Character.Name), 500, "Deviousness", "SET TRAP")		
			end)
			
			task.delay(2, function()
				
				if New_Trap and New_Trap.Parent then
					New_Trap:WaitForChild('Panel'):WaitForChild('State').Value = "Armed"
				end
			end)
		elseif name == "Frame2" then
			print("play trap sound")
		else
			warn(name)
		end
	end
	
	Trapper.Characters[Character.Name].AnimationTrack.KeyframeReached:Connect(playSoundEffect)
end

--

function Trapper:Trap(Character) : "Does Cloaking Animation"
	if not Trapper.Characters[Character.Name] then GenerateData(Character) end
	local Slam_Time = Trapper.Characters[Character.Name].AnimationLength * (1/Trapper.Characters[Character.Name].AnimationSpeeds.Default)

	Trapper.Characters[Character.Name].State = "Trapping"
	Trapper.Characters[Character.Name].AnimationTrack:Play(nil, nil, Trapper.Characters[Character.Name].AnimationSpeeds.Default)

	Character.Humanoid.WalkSpeed = 0
	Character.HumanoidRootPart.Anchored = true

	local timestamp = workspace:GetServerTimeNow()
	coroutine.wrap(function()
		
		task.wait(.1)
		Character.Humanoid.WalkSpeed = 0
		--Character.HumanoidRootPart.Anchored = false
		
		repeat task.wait()
		until (workspace:GetServerTimeNow() - timestamp) > Slam_Time or Trapper.Characters[Character.Name].State == "Cancel"
		
		if Trapper.Characters[Character.Name].State == "Trapping" or Trapper.Characters[Character.Name].State == "Trap Locked" then
			Character.HumanoidRootPart.Anchored = false
			Character.Humanoid.WalkSpeed = Trapper.Settings.WalkingSpeeds.Base
		end
		
		Trapper.Characters[Character.Name].State = "Nothing"
	end)()
	
	return timestamp, Slam_Time
end

function Trapper:Reset(Character, Trap : Model) : "Does Cloaking Animation"
	if not Trapper.Characters[Character.Name] then GenerateData(Character) end
	local Slam_Time = Trapper.Characters[Character.Name].AnimationLength * (1/Trapper.Characters[Character.Name].AnimationSpeeds.Default)

	Trapper.Characters[Character.Name].State = "Resetting"
	Trapper.Characters[Character.Name].AnimationTrack:Play(nil, nil, Trapper.Characters[Character.Name].AnimationSpeeds.Default)
	Trapper.Characters[Character.Name].Trap = Trap
	
	Character.Humanoid.WalkSpeed = 0
	Character.HumanoidRootPart.Anchored = true

	local timestamp = workspace:GetServerTimeNow()
	coroutine.wrap(function()

		task.wait(.1)
		Character.Humanoid.WalkSpeed = 0
		--Character.HumanoidRootPart.Anchored = false

		repeat task.wait()
		until (workspace:GetServerTimeNow() - timestamp) > Slam_Time or Trapper.Characters[Character.Name].State == "Cancel"

		if Trapper.Characters[Character.Name].State == "Resetting" or Trapper.Characters[Character.Name].State == "Trap Locked" then
			Character.HumanoidRootPart.Anchored = false
			Character.Humanoid.WalkSpeed = Trapper.Settings.WalkingSpeeds.Base
		end

		Trapper.Characters[Character.Name].State = "Nothing"
	end)()

	return timestamp, Slam_Time
end

function Trapper:Cancel(Character)
	if not Trapper.Characters[Character.Name] then
		repeat task.wait()
		until Trapper.Characters[Character.Name]
	end
	
	if Trapper.Characters[Character.Name].State ~= "Trapping" then return end
	
	Trapper.Characters[Character.Name].State = "Cancel"
	
	if Trapper.Characters[Character.Name].AnimationTrack.TimePosition < 0.5 then
		Trapper.Characters[Character.Name].AnimationTrack:Stop()
	else
		Trapper.Characters[Character.Name].AnimationTrack:AdjustSpeed(-2.5)
	end
	
	if Trapper.Characters[Character.Name].AnimationTrack.IsPlaying then
		Trapper.Characters[Character.Name].AnimationTrack.Stopped:Wait()
	end
end

return Trapper
