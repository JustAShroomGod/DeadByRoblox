local lastValue = 0
local Code = require(game.ReplicatedStorage.Modules.Code)

script.Parent.Changed:Connect(function()
	if script.Parent.Value > lastValue and script.Parent.Value < 5 then
		local finishedSound = script.finishedSound
		finishedSound.RollOffMaxDistance = 100000
		finishedSound.RollOffMinDistance = 1
		finishedSound.Volume = 0.4
		
		finishedSound:Play()
	end
	
	if script.Parent.Value ~= lastValue then
		lastValue = script.Parent.Value
	end

	if script.Parent.Value > 4 then
		local trialEndSound = script.trialEndSound
		trialEndSound.RollOffMaxDistance = 100000
		trialEndSound.RollOffMinDistance = 1
		trialEndSound.Volume = 0.6
		
		trialEndSound:Play()
		
		for _,gen in pairs(workspace:GetChildren()) do
			if string.match(string.lower(gen.Name), "generator") then
				if gen:WaitForChild("Panel"):WaitForChild("Progress").Value < 1000 then
					gen:WaitForChild("Panel"):WaitForChild("Progress").Value = 1000
				end
			end
		end
		for i,object in pairs(workspace:GetChildren()) do
			--for _, player in pairs(game:GetService("Players"):GetChildren()) do
				if string.match(object.Name, "ExitGate") then
					Code:AddNotification(object.Wall_Mount.Wall_Mount.CFrame, 9, "Exit")
				--end
			end
		end
	end
end)