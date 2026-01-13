local Players = game.Players

local PowerModel = script.Parent
local Addons = PowerModel.Addons
local PowerRemote = PowerModel.PowerValues.PowerRemote

local Player: Player = Players:GetPlayerFromCharacter(PowerModel.Parent)
local Character = Player.Character
local Humanoid = Character.Humanoid
local RootPart = Character.HumanoidRootPart

local Data = require(game.ReplicatedStorage.Modules:WaitForChild("Data"))

local initialized = false
local BlinkSound = PowerModel.BlinkSound

local validActions = {"Nothing", "BlinkAction", "Fatigue"}

function initialize()
	initialized = true

	local Addons_Data = Data:GetAddons("Killer", game.Players[Player.Name])
	PowerRemote:FireClient(Player, "Init")

	for _,Addon in pairs(Addons_Data) do
		if (Addons:FindFirstChild(Addon) ~= nil) then
			local AddonModule = require(Addons[Addon])
			AddonModule.init()
			task.wait()
		end
	end
	
	BlinkSound.Parent = Player.Character
	_G.GetValue(Player.Name, "LungeDuration"):Add("BaseDebuff", -0.1, -1)
end

initialize()

function CommandReceived(Player, Command, ...)
	
	local args = {...}
	
	if (Command == "SetValue") then
		SetValue(args[1], args[2])
	end
	
	if (Command == "Teleport") then
		BlinkSound.PlaybackSpeed = 0.8
		BlinkSound.PitchShiftSoundEffect.Octave = math.random(0.8, 1.2)
		BlinkSound.TimePosition = 0.7
		BlinkSound:Play()
	end
	
	if (Command == "Action") then
		
		local killerAction = Player.Backpack.Scripts.values.KillerAction
		
		if (table.find(validActions, killerAction.Value) ~= nil or args[1] == nil) then
			return
		end
		
		if (table.find(validActions, args[1]) == nil) then
			return
		end
		
		killerAction.Value = args[1]
	end
	
end

function SetValue(Attribute, Value)
	PowerModel:SetAttribute(Attribute, Value)
end

PowerRemote.OnServerEvent:Connect(CommandReceived)