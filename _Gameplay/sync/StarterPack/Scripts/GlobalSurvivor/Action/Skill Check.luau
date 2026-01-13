local RemoteEvents = game.ReplicatedStorage.RemoteEvents
local SendSkillCheck = RemoteEvents:WaitForChild("SendSkillCheck")
local SkillCheckResult = RemoteEvents:WaitForChild("SkillCheckResult")
local SkillCheck = require(game.ReplicatedStorage.Modules.SkillCheck)

local Player = game.Players.LocalPlayer

local Action = {
	Key = "Interact";
	ActionName = "#HIT SKILL";
	Priority = 1; -- scale of 1-5
	ActionInfo = {
		CurrentSkillCheck = nil;
		Queue = {};
		SkillCheckObj = nil;
		CurrentContext = nil;
		CurrentValues = nil;
	},
	Debounces = {
		InProgress = false;
	},
}

function Init()
	Action.ActionInfo.SkillCheckObj = SkillCheck.New(nil)
	Action.ActionInfo.SkillCheckObj:GetDespawnEvent().Event:Connect(Despawned)
	Action.ActionInfo.SkillCheckObj:GetExpiredEvent().Event:Connect(Expired)
end

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	
	Action.ActionInfo.CurrentValues = currentValues
	
	if (Action.ActionInfo.CurrentSkillCheck ~= nil) then
		CanRun = true
	end
	
	return CanRun
end

function Action:Start(...) : "Start Action?"
	if Action.Debounces.InProgress then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InProgress = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	
	local Character = Player.Character
	local result = Action.ActionInfo.SkillCheckObj:Hit()

	if (result ~= nil) then
		SendSkillCheck:FireServer(Action.ActionInfo.SkillCheckObj:GetUniqueId(), result)
		
		coroutine.wrap(function()
			
			SkillCheckResult:Fire(Action.ActionInfo.CurrentContext, result)
			
			if (result ~= "Fail") then
				task.wait(0.5)
			end
			
			Action.ActionInfo.SkillCheckObj:Despawn()
		end)()
	end
	
	Action.Debounces.InProgress = false
end

function Action:Process(...) : boolean | "Returns true if this action can be ran"
	local args = {...}
	local actionList, remoteList = args[1], args[2]
	
	if Constraints(actionList) then
		return true
	end
	
	return false
end

function Despawned(ID)
	Action.ActionInfo.CurrentSkillCheck = nil
	SpawnNext()
end

function Expired(ID)

	SkillCheckResult:Fire(Action.ActionInfo.CurrentContext, "Miss")
	SendSkillCheck:FireServer(ID, "Miss")
	Action.ActionInfo.CurrentSkillCheck = nil
	
	SpawnNext()
end

function SkillCheckReceived(ID: number, Configuration: "table", Context)
	
	table.insert(Action.ActionInfo.Queue, {
		id = ID;
		config = Configuration;
		context = Context;
	})

	if (Action.ActionInfo.CurrentSkillCheck == nil) then
		SpawnNext()
	end
end

function SpawnNext()
	
	if (Action.ActionInfo.SkillCheckObj == nil) then
		warn("SkillCheckObj Missing")
		Init()
	end
	
	if (#Action.ActionInfo.Queue == 0) then
		return
	end
	
	local nextSkillCheck = Action.ActionInfo.Queue[1]
	table.remove(Action.ActionInfo.Queue, 1)
	
	Action.ActionInfo.CurrentSkillCheck = nextSkillCheck.id
	Action.ActionInfo.CurrentContext = nextSkillCheck.context
	Action.ActionInfo.SkillCheckObj:Configure("UniqueId", nextSkillCheck.id)
	
	local Context = Action.ActionInfo.CurrentContext
	local CurrentAction = Action.ActionInfo.CurrentValues.Action.Value
	local IsInAction = string.find(CurrentAction, Context) ~= nil or Context == "Nothing"
	
	if (not IsInAction) then
		Despawned(Action.ActionInfo.CurrentSkillCheck)
		return
	end
	
	for attr, value in pairs(nextSkillCheck.config) do
		Action.ActionInfo.SkillCheckObj:Configure(attr, value)
	end
	
	Action.ActionInfo.SkillCheckObj:Spawn(Action.ActionInfo.CurrentContext)
end

function MatchStarted()
	
	repeat task.wait(0.5)
	until Player:FindFirstChild("PlayerValues") ~= nil
	
	Init()
end

SendSkillCheck.OnClientEvent:Connect(SkillCheckReceived)
game.ReplicatedStorage.Match.Started.Changed:Connect(MatchStarted)


return Action
