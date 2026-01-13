local plr = game.Players.LocalPlayer
local char = workspace:WaitForChild(plr.Name)
local backpack = plr:WaitForChild("Backpack")
local scripts = backpack:WaitForChild("Scripts")
local values = scripts:WaitForChild("values")

local gettingHealingAnim = Instance.new("Animation") 
gettingHealingAnim.AnimationId = "rbxassetid://103241665663087" --"http://www.roblox.com/Asset?ID=15080329412" "17007089547"
gettingHealingAnimTrack = nil
local TRAPANIMS = game.ReplicatedStorage:WaitForChild("Game_Assets"):WaitForChild("Animations"):WaitForChild("BearTrap"):WaitForChild("Player")
local trapStuck = TRAPANIMS:WaitForChild("Player_Stuck")
local caught = TRAPANIMS:WaitForChild("Player_Trapped")
local a = nil
local b = nil
game:GetService("ContentProvider"):PreloadAsync({trapStuck,caught})
local modules = game.ReplicatedStorage:WaitForChild("Modules")
local uimod = modules:WaitForChild("Gui")
uimod = require(uimod)
local lastAction = "Nothing"
script.Parent.Changed:Connect(function()
	if lastAction ~= "Trapped" and script.Parent.Value == "Trapped" then
		if a == nil then
			a = char:WaitForChild("Humanoid"):LoadAnimation(caught)
		end
		if b == nil then
			b = char:WaitForChild("Humanoid"):LoadAnimation(trapStuck)
		end
		a:Play()
		coroutine.resume(coroutine.create(function()
			repeat task.wait() until a.IsPlaying == false 
			if script.Parent.Value == "Trapped" then
				b:Play()
			end
		end))
	end
	if script.Parent.Value ~= "Trapped" then
		if a then
			a:Stop()
			b:Stop()
		end
	end

	if string.match(string.lower(script.Parent.Value),"gettinghealing",1) then
		if gettingHealingAnimTrack == nil then
			gettingHealingAnimTrack = char:WaitForChild("Humanoid"):LoadAnimation(gettingHealingAnim)
		end
		gettingHealingAnimTrack:Play()
		uimod:Progress(script.Parent.Parent:WaitForChild("HealProgress"), "BEING HEALED")
		char:WaitForChild("Humanoid").WalkSpeed = 0
		scripts:WaitForChild("MovementSpeedScript"):WaitForChild("MainScript").Disabled = true
	else
		if string.match(string.lower(lastAction),"gettinghealing",1) then
			if gettingHealingAnimTrack ~= nil then
				gettingHealingAnimTrack:Stop()
				uimod:Progress()
				scripts:WaitForChild("MovementSpeedScript"):WaitForChild("MainScript").Disabled = false
			end
		end
	end
	lastAction = script.Parent.Value
end)
