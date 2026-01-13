local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local Backup_Length = 5

local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local Addons = require(script.Parent:WaitForChild('Addon'))

local GameAssets = ReplicatedStorage:WaitForChild("Game_Assets")

local Disarm_Animation = GameAssets:WaitForChild("Animations"):WaitForChild("BearTrap"):WaitForChild("Player"):WaitForChild("Trap_Disarm")

local Survivor = {
	Settings = {
		AnimationSpeeds = {
			Default = 1; -- 2 second animation = 1.5 second cloak time
		},
	},
	Characters = {}
}

function GenerateData(Character : Model) : "Create Tweening Data"
	if Survivor.Characters[Character.Name] then return end
	
	Survivor.Characters[Character.Name] = {} -- create character/tween data for this character
	
	Survivor.Characters[Character.Name].State = "Nothing"
	
	Survivor.Characters[Character.Name].AnimationSpeeds = {
		Default = Survivor.Settings.AnimationSpeeds.Default;
	}
	
	Survivor.Characters[Character.Name].AnimationTrack = Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(Disarm_Animation)
	
	-- Adding Sound Effects --
	local function PlaySound(id : number, volume : number, pitch : number) : "Play Sound"
		local Sound = Instance.new('Sound', Character.HumanoidRootPart)
		Sound.PlayOnRemove = true
		Sound.Volume = if volume then volume else 1
		Sound.SoundId = "http://www.roblox.com/Asset?ID="..tostring(id)
		Sound:Remove()
	end

	if Survivor.Characters[Character.Name].AnimationTrack.Length > 0 then
		Survivor.Characters[Character.Name].AnimationLength = Survivor.Characters[Character.Name].AnimationTrack.Length
	else
		game:GetService('ContentProvider'):PreloadAsync({Disarm_Animation})
		Survivor.Characters[Character.Name].AnimationLength = Survivor.Characters[Character.Name].AnimationTrack.Length
	end
	
	
	local function playSoundEffect(name : string) : "Plays sound based on cue"
		
		if name == "Disarmed" then
			print('Disarm trap / play sound')
			Survivor.Characters[Character.Name].State = "Disarmed"
		else
			warn(name)
		end
	end
	
	Survivor.Characters[Character.Name].AnimationTrack.KeyframeReached:Connect(playSoundEffect)
end

--

function Survivor:Disarm(Character) : "Does Cloaking Animation"
	if not Survivor.Characters[Character.Name] then GenerateData(Character) end
	local Time = Survivor.Characters[Character.Name].AnimationLength * (1/Survivor.Characters[Character.Name].AnimationSpeeds.Default)
	
	Survivor.Characters[Character.Name].State = "Disarming"
	Survivor.Characters[Character.Name].AnimationTrack:Play(nil, nil, Survivor.Characters[Character.Name].AnimationSpeeds.Default)

	Character.Humanoid.WalkSpeed = 0
	
	local timestamp = workspace:GetServerTimeNow()
	coroutine.wrap(function()
		
		task.wait(.1)
		Character.Humanoid.WalkSpeed = 0
		
		repeat task.wait()
		until (workspace:GetServerTimeNow() - timestamp) > Time or Survivor.Characters[Character.Name].State == "Cancel"
		
		Survivor.Characters[Character.Name].State = "Nothing"
	end)()
	
	return timestamp, Time
end

function Survivor:Cancel(Character)
	if not Survivor.Characters[Character.Name] then
		repeat task.wait()
		until Survivor.Characters[Character.Name]
	end
	
	if Survivor.Characters[Character.Name].State ~= "Disarming" then return end
	
	Survivor.Characters[Character.Name].State = "Cancel"
	Survivor.Characters[Character.Name].AnimationTrack:Stop()
end

return Survivor
