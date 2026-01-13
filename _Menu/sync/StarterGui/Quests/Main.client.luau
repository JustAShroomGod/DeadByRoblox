local ReplicatedStorage : ReplicatedStorage,Players : Players = game:GetService("ReplicatedStorage"),game:GetService("Players")

local Data = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Data"))
local Quests = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Data"):WaitForChild("Quests")
local Handler = require(script:WaitForChild("Handler"))

repeat task.wait() until Data:GetQuestSelection(Players.LocalPlayer).Daily.Slot1.Character and script.Parent.Enabled

local QuestSelection = Data:GetQuestSelection(Players.LocalPlayer)

for _,Slot in QuestSelection.Daily do
	if not Slot.Character then continue end
	
	local QuestData = Data:GetQuest(Players.LocalPlayer,Slot.Character,Slot.Name)
	local QuestModule = require(if Slot.Character == "Survivor" then Quests:WaitForChild("Survivor")[Slot.Name] else Quests:WaitForChild("Killer")[Slot.Name])
	
	local QuestData_ = {
		Amount = QuestData.Amount;
		Needed = QuestData.Needed;
		Reward = QuestData.Reward;
		Description = QuestModule.ReturnDescription(QuestData,Slot.Character);
		Completed = Slot.Completed
	}

	Handler.New(QuestData_)
end