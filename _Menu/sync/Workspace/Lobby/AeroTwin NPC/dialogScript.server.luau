-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--modules
local DialogModule = require(ReplicatedStorage.Dialogs.DialogModule)

--references
local player = game.Players.LocalPlayer
local npc = script.Parent -- Reference to the NPC model
local npcGui = npc:WaitForChild("Head"):WaitForChild("gui")
local prompt = npc:WaitForChild("ProximityPrompt")

local dialogObject = DialogModule.new("Showcase NPC", npc, prompt)
dialogObject:addDialog("Lets take a l👀k!", {"Who are you?", "Are you secret?", "Are you the real Aero?", "Do you do anything?", "👀Bye!"})

--

-- what happens when triggered
prompt.Triggered:Connect(function(player)
	dialogObject:triggerDialog(player, 1)
end)

-- logic to go through dialogs
dialogObject.responded:Connect(function(responseNum, dialogNum)
	if dialogNum == 1 then
		if responseNum == 1 then
			dialogObject:hideGui("I'm Aero Secret Twin (im secret)")
		end
		if responseNum == 2 then
			dialogObject:hideGui("Yes im secret")
		end
		if responseNum == 3 then
			dialogObject:hideGui("No because im Aero Secret Twin!!!")
		end
		if responseNum == 4 then
			dialogObject:hideGui("No im just wasting ur time lol")
		end
		if responseNum == 5 then
			dialogObject:hideGui("Bye!")
		end
	end
end)