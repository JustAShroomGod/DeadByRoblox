local Teams = game.Teams
local Players = game.Players
local TweenService = game.TweenService

local PowerModel = script.Parent.Parent
local PowerValues = PowerModel.PowerValues
local PowerRemote = PowerValues.PowerRemote
local PowerEvent = PowerValues.PowerEvent

local ObjBuffer = require(script.Parent.ObjBuffer)
local Code = require(game.ReplicatedStorage.Modules.Code)
local Data = require(game.ReplicatedStorage.Modules.Data)


local Reverse = {}

function Reverse.ResetSurvivor(Player: Player)
	
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')
	
	Player.Character:SetAttribute("Invisible", false) -- remove invisibility effect
	playerValues.Action.Value = "Nothing"

	Code:SetEffect("Blind", Player, nil, "Locker")
	Code:SetEffect("Quiet", Player, nil, "Locker")

	Code:SetEffect("Hidden",Player, nil, "Locker")
	Code:SetEffect("AFrame", Player)

	Code:SetCollision(Player, 'Survivor')
end

function Reverse.PerformOnPlayers(PlayerCache: table)
	for index, player in pairs(PlayerCache) do
		if (Code:isKiller(player)) then
			continue
		end
		
		if (Code:IsHooked(player)) then
			continue
		end

		if (not ObjBuffer.IsRegistered(player)) then
			continue
		end

		Reverse.PerformOnPlayer(player)
	end
end

function Reverse.PerformOnPlayer(Player: Player)

	local playerBuffer = ObjBuffer.GetAll(Player)
	Reverse.ResetSurvivor(Player)

	coroutine.wrap(function()
		repeat task.wait(0.1)
		until (Code:GetSurvivorAction(Player) == "Nothing" and Code:GetKillerAction(Player) == "Nothing")

		Player.Character.Humanoid.WalkSpeed = 0
		Code.Speeds:addMultiplier(Player, "Reverse", 0, -1)
		ReversePlayer(Player, #playerBuffer)
	end)()
end

function Reverse.PerformOnObjects()
	
	local generators = ObjBuffer.GetAllByType("Generator")
	local totems = ObjBuffer.GetAllByType("Totem")
	
	print(generators)
	
	for i, objName in pairs(generators) do
		ReverseGenerator(workspace[objName])
	end
	
	for i, objName in pairs(totems) do
		ReverseTotem(workspace[objName])
	end
end

function ReversePlayer(Player: Player, index)
	
	local playerBuffer = ObjBuffer.GetAll(Player)
	local tweenDuration = PowerValues:GetAttribute("Reverse_Duration") / #playerBuffer

	if (index == 1) then
		Player.Character.Humanoid.WalkSpeed = Code:GetPlayerValue(Player, "Speed") * Code:GetPlayerValue(Player, "SpeedMultiplier")
		Code.Speeds:removeMultiplier(Player, "Reverse")
		return
	end

	local tween = TweenService:Create(
		Player.Character.PrimaryPart,
		TweenInfo.new(tweenDuration),
		{CFrame = playerBuffer[index]["CFrame"]}
	)
	
	Code:SetHealthState(Player, playerBuffer[index]["HealthState"])
	Code:SetHealProgress(Player, playerBuffer[index]["HealProgress"])

	tween:Play()

	tween.Completed:Once(function()
		ReversePlayer(Player, index - 1)
	end)
end

function ReverseGenerator(Object: Instance)

	local OldestBufferEntry = ObjBuffer.GetOldestEntry(Object)
	local Progress = Object.Panel.Progress
	
	Progress.Value = OldestBufferEntry["Progress"]
end

function ReverseTotem(Object: Instance)
	
	local OldestBufferEntry = ObjBuffer.GetOldestEntry(Object)
	local Progress = Object.Panel.Progress
	local Effect = Object.Panel.Effect
	local State = Object.Panel.State
	
	if (OldestBufferEntry["Effect"] == "Curse" and State.Value == 1) then
		OldestBufferEntry["Effect"] = "Dull"
	end
	
	State.Value = OldestBufferEntry["State"]
	Effect.Value = OldestBufferEntry["Effect"]
	Progress.Value = 0
end

return Reverse
