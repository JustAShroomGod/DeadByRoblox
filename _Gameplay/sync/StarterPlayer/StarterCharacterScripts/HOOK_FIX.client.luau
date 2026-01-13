repeat task.wait() until (script:FindFirstChild("RemoteEvent") ~= nil)

local CheckAnimationStage = function(Player)
	local Character = Player
	local HookCount = if Character:GetAttribute("Hook_Stage") then string.split(Character:GetAttribute("Hook_Stage"), ':') else {0, 2}
	return HookCount[1]
end

script:WaitForChild("RemoteEvent").OnClientEvent:Connect(function(Hook,Survivor_Character,Survivor_Player)
	repeat task.wait() 
		if tonumber(CheckAnimationStage(Survivor_Character)) >= 2 then
			Survivor_Character:PivotTo(Hook:GetPivot() * CFrame.new(5.5, 7.5, 0) * CFrame.Angles(0, math.rad(-90), 0))
			Survivor_Character.PrimaryPart.Anchored = true
		else
			Survivor_Character:PivotTo(Hook:GetPivot() * CFrame.new(5.5, 7.5, 0) * CFrame.Angles(0, math.rad(-90), 0))
			Survivor_Character.PrimaryPart.Anchored = true
		end
	until Survivor_Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Hooked').Value == false
	Survivor_Character.PrimaryPart.Anchored = false
end)