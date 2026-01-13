local SendSkillCheck = game.ReplicatedStorage.RemoteEvents:WaitForChild("SendSkillCheck")
local Code = require(game.ReplicatedStorage.Modules.Code)

local Player = game.Players.LocalPlayer
local Prefab = script.Prefab

local Backpack = Player.Backpack
local Scripts = Backpack.Scripts
local Action = Scripts.values.Action

local Prefix = "rbxassetid://"

local AudioIds = {
	['Alert'] = Prefix..1479839128;
	['Bad'] = Prefix..9476395954;
	['Good'] = Prefix..1480001625;
	['Great'] = Prefix..1479888663;
}

local SFX = {}

local SkillCheck = {}

SkillCheck.__index = SkillCheck

function SkillCheck.New(ID: number)

	local newCheck = setmetatable({}, SkillCheck)

	local uiObject = Prefab:Clone()
	uiObject.Name = "SkillCheck"
	uiObject.Parent = Player.PlayerGui.HUD

	local DespawnEvent = Instance.new("BindableEvent", uiObject)
	local ExpiredEvent = Instance.new("BindableEvent", uiObject)

	newCheck.UIObject = uiObject
	newCheck.DespawnEvent = DespawnEvent
	newCheck.ExpiredEvent = ExpiredEvent
	newCheck.UniqueId = ID

	newCheck.Zones = {
		Good = {0, 0};
		Great = {0, 0};
	}

	newCheck.Sizes = {4 * Code:GetPlayerValue(Player, "SC_Difficulty"), 12 * Code:GetPlayerValue(Player, "SC_Difficulty")}
	newCheck.StartArea = {75, 270}

	newCheck.RotationSpeed = 240
	newCheck.SpawnDelay = 1
	newCheck.Direction = if (Code:GetPlayerValue(Player, "SC_Invert") > 0) then -1 else 1
	newCheck.Goal = 360
	newCheck.Run = false

	return newCheck
end

function SkillCheck:Configure(Attribute: string, value: "any")
	self[Attribute] = value
end

function SkillCheck:Spawn(Context)

	if (self.UIObject.Visible) then
		return
	end

	self.StartRotation = math.random(self.StartArea[1], self.StartArea[2])
	self.StartRotation = self:BuildGreatZone(self.Sizes[1], self.StartRotation)
	self:BuildGoodZone(self.Sizes[2], self.StartRotation)

	self.UIObject.Needle.Rotation = if (self.Direction > 0) then 0 else 360

	SFX["Alert"]:Play()

	coroutine.wrap(function()
		task.wait(self.SpawnDelay * 0.8)
		self.UIObject.Visible = true

		task.wait(self.SpawnDelay * 0.2)

		self.Run = true
		self.Context = Context
		self:Rotate()
	end)()
end

function SkillCheck:Despawn()
	self.Run = false
	self.UIObject.Visible = false
	self.DespawnEvent:Fire()
end

function SkillCheck:BuildGreatZone(size: number, start: number)

	for i,v in pairs(self.UIObject.GREAT:GetChildren()) do
		v:Destroy()
	end

	local needed = (360 / 4) / 100 * size

	self.Zones.Great = {
		start - 6,
		(start) + (4 * (needed - 2) - 2)
	}

	for count = 1, needed do
		local new = self.UIObject.Prefs.GreatZone:Clone()
		new.Rotation = (start - 4) + (4 * (count - 1))
		new.Visible = true
		new.Parent = self.UIObject.GREAT
	end

	return ((start - 4) + (4 * needed))
end

function SkillCheck:BuildGoodZone(size: number, start: number)

	for i,v in pairs(self.UIObject.GOOD:GetChildren()) do
		v:Destroy()
	end

	local needed = (360 / 4) / 100 * size

	self.Zones.Good = {
		start - 6,
		(start) + (4 * (needed - 1))
	}

	for count = 1, needed do
		local new = self.UIObject.Prefs.GoodZone:Clone()
		new.Rotation = (start - 4) + (4 * (count - 1))
		new.Visible = true
		new.Parent = self.UIObject.GOOD
	end

	return ((start - 4) + (4 * needed))
end

function SkillCheck:Rotate()

	if (self.Runner ~= nil) then
		return
	end

	self.Runner = game["Run Service"].Heartbeat:Connect(function(delta)

		if (not self.UIObject.Visible or not self.Run) then
			return
		end
		
		local CurrentAction = Action.Value
		local IsInAction = string.find(CurrentAction, self.Context)

		local needle = self.UIObject.Needle
		local goalCondition = if (self.Direction > 0) then needle.Rotation >= self.Goal else needle.Rotation <= self.Goal

		needle.Rotation += (((self.RotationSpeed * Code:GetPlayerValue(Player, "SC_Speed")) * delta) * self.Direction)

		if (goalCondition) then
			self.Run = false
			self.UIObject.Visible = false

			self.ExpiredEvent:Fire(self.UniqueId)
			SFX["Bad"].TimePosition = 0.45
			SFX["Bad"]:Play()
		end

	end)
end

function SkillCheck:Hit()

	local needle = self.UIObject.Needle
	local goalCondition = if (self.Direction > 0) then needle.Rotation >= self.Goal else needle.Rotation <= self.Goal

	if (not self.UIObject.Visible or goalCondition) then
		self.Run = false
		return nil
	end

	if (needle.Rotation >= self.Zones.Great[1] and needle.Rotation <= self.Zones.Great[2]) then
		self.Run = false
		SFX["Great"]:Play()
		return "Great"
	end

	if (needle.Rotation >= self.Zones.Good[1] and needle.Rotation <= self.Zones.Good[2]) then
		self.Run = false
		SFX["Good"]:Play()
		return "Good"
	end

	self.Run = false
	SFX["Bad"].TimePosition = 0.45
	SFX["Bad"]:Play()
	return "Fail"
end

function SkillCheck:GetDespawnEvent()
	return self.DespawnEvent
end

function SkillCheck:GetExpiredEvent()
	return self.ExpiredEvent
end

function SkillCheck:GetUniqueId()
	return self.UniqueId
end

function InitializeAudio()

	if (#SFX > 0) then
		return
	end

	for i, id in pairs(AudioIds) do

		if (SFX[id] ~= nil) then
			continue
		end

		local sfx = Instance.new("Sound", game.SoundService)
		sfx.Name = i
		sfx.SoundId = id
		sfx.Volume = 1

		SFX[i] = sfx
	end
end

InitializeAudio()

return SkillCheck
