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
dialogObject:addDialog("Hello! How can i help?", {"How do i get into a match?", "How do i get the pass rewards?", "How do i buy more killers?", "How do i make Queues faster?", "Whats up with these weird people near the Campfire?" , "Bye!"})

--

-- what happens when triggered
prompt.Triggered:Connect(function(player)
	dialogObject:triggerDialog(player, 1)
end)

-- logic to go through dialogs
dialogObject.responded:Connect(function(responseNum, dialogNum)
	if dialogNum == 1 then
		if responseNum == 1 then
			dialogObject:hideGui("All you gotta do is press the button of the role you want to play, then, press the button: find lobby or make lobby")
		end
		if responseNum == 2 then
			dialogObject:hideGui("Play the game dawg")
		end
		if responseNum == 3 then
			dialogObject:hideGui("You can currently buy most DLC killers by using Blood in the Store, they cost around 1 Million Blood each")
		end
		if responseNum == 4 then
			dialogObject:hideGui("You can buy a private server for 10 robux and try to queue there, theoretically, it should be quicker, but its not guaranteed")
		end
		if responseNum == 5 then
			dialogObject:hideGui("Those are Developers of the game, they are the ones that made me!")
		end
		if responseNum == 6 then
			dialogObject:hideGui("Bye!")
		end
	end
end)