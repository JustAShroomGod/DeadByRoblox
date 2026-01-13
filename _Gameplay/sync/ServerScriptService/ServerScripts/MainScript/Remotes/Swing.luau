local ReplicatedStorage, Tween, RunService, Players = game:GetService('ReplicatedStorage'),  game:GetService('TweenService'), game:GetService('RunService'), game:GetService('Players')
local RemoteStorage = ReplicatedStorage:WaitForChild('RemoteEvents')
local Modules = {
	Data = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'));
	Events = require(game.ServerScriptService["Event System"].Events)
}

local remote = {}

local PerkSettings = {
	STBFL = {4, 3, 2};
}

local SoundIds = {
	["Wood"] = 2794814721,
	["Rock"] = 2794814378,
	["Metal"] = 1355483983
}

local objectMaterials = {
	['Rock'] = {'trash', 'hook', 'hill'};
	['Metal'] = {'generator', 'barrel'};
}

local function GrabRemote()

	for _,r in pairs(RemoteStorage:GetChildren())do

		if string.lower(r.Name) == string.lower(script.Name) then
			return r
		end
	end

	return false
end

local function playAudio(...) : "Plays sound"
	local args = {...}
	local ID, Place, Settings = args[1], args[2], args[3]
	local Sound = Instance.new('Sound')

	Sound.SoundId = ID
	Sound.PlayOnRemove = true
	Sound.Parent = Place or game:GetService('SoundService')

	Sound:Destroy()
end

local function OnTouch(...) : "Actual Hit Event"
	local args = {...}
	local player, part = args[1], args[2]
	local KillerPack = player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local playerValues = KillerPack:WaitForChild('values')

	local ReachedParent, CurrentInstance = false, part

	repeat -- task.wait() -- grabs outermost folder/model
		if CurrentInstance and CurrentInstance.Parent ~= workspace then
			CurrentInstance = CurrentInstance.Parent
		end

		if not CurrentInstance or CurrentInstance.Parent == workspace then
			ReachedParent = true
		end
	until ReachedParent

	-- Current Instance At This Point is the child of WorkSpace/Character Model --
	
	print(CurrentInstance, part, 'is our compared')
	
	if not CurrentInstance then return end
	
	local function HitPlayer() : "Checks if this is valid player to hit"

		if CurrentInstance:FindFirstChild('Humanoid') then

			if Players:FindFirstChild(CurrentInstance.Name) then -- is real player
				local survivorValues : Folder = Players:WaitForChild(CurrentInstance.Name):WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')

				if survivorValues:WaitForChild('Action').Value ~= "InLocker" -- not in locker currently
					and not survivorValues:WaitForChild('Hooked').Value -- not on hook
					and survivorValues:WaitForChild('HealthState').Value > 0 then -- have health to lose

					return true
				end
			end
		end

		return false
	end

	if HitPlayer() then -- we hit a player
		playerValues.KillerAction.Value = 'WeaponSwing'

		local Survivor = Players:WaitForChild(CurrentInstance.Name)

		RemoteStorage:WaitForChild('Event'):Fire("Hit", player, Survivor, "Basic")
		
		return warn('hit a player!')
	else
		print('hit', CurrentInstance)
	end

	return warn('activating hit forgiveness')
end

function remote.new()
	local self = {}
	setmetatable(self, remote)

	local connection = GrabRemote()

	if connection then

		connection.OnServerEvent:Connect(function(player : Player, command, part)
			local Player_Values = player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')
			
			if command == "Hit" then
				OnTouch(player, part)
			elseif command == "Start_Hit" then
				Player_Values:WaitForChild('KillerAction').Value = "Attacking"
				Player_Values:WaitForChild('Action').Value = "Attacking"
			elseif command == "Stop_Hit" then
				Player_Values:WaitForChild('KillerAction').Value = "Nothing"
				Player_Values:WaitForChild('Action').Value = "Nothing"
			end
		end)
	else
		warn('Remote does not exist:', script.Name)
	end

	return self
end

return remote.new()
