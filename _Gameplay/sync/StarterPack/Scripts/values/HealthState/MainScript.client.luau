task.wait(0.3)
local remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
betterUpdate = remoteEvents:WaitForChild("NewPropertie")
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local Backpack = plr:WaitForChild("Backpack")
local Scripts = Backpack:WaitForChild("Scripts")
local values = Scripts:WaitForChild("values") 
local action = values:WaitForChild("Action")
local healthState = values:WaitForChild("HealthState")
local movementSpeedScript = Scripts:WaitForChild("MovementSpeedScript")
local movementSpeedScriptMainScript = movementSpeedScript:WaitForChild("MainScript")
local prefix = "rbxassetid://"

local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local animationIds = {{96708709340927, 1}, {106886767092837, 1}} --{{15072042785, 3.8}, {15072053251, 2.83}}
local hitAnim = Instance.new("Animation")

for _, animationId in pairs (animationIds) do
	hitAnim.AnimationId = prefix.. tostring(animationId[1])
	
	local animTrack = humanoid:LoadAnimation(hitAnim)
	animTrack:Play()
	animTrack:AdjustSpeed(5)
end

local lastState = 2

local function update(bool)
	if action.Value == "InCarry" then return end -- do not do anything if being carried (looks wierd)
	
	if healthState.Value == 1 then
		
		if bool or healthState.Value < lastState then
			local thisAnimation = animationIds[1]
			hitAnim.AnimationId = prefix.. tostring(thisAnimation[1])
			local animTrack = char:WaitForChild("Humanoid"):LoadAnimation(hitAnim)
			animTrack:Play() animTrack:AdjustSpeed(thisAnimation[2])
		end
	elseif healthState.Value == 0 then
		Code_Module.Speeds:addMultiplier(plr, "Downed", 0, -1)
		
		local thisAnimation = animationIds[2]
		hitAnim.AnimationId = prefix.. tostring(thisAnimation[1])
		
		local animTrack = char:WaitForChild("Humanoid"):LoadAnimation(hitAnim)
		animTrack:Play()
		animTrack:AdjustSpeed(thisAnimation[2])
		
		repeat task.wait() 
			if healthState.Value == 0 then
			else
				animTrack:AdjustSpeed(99)
			end
		until animTrack.IsPlaying == false

		Code_Module.Speeds:removeMultiplier(plr, "Downed")
	end
end

healthState.Changed:Connect(function()
	update()

	lastState = healthState.Value
end)

healthState.Update.Changed:Connect(function()
	update(true)
end)