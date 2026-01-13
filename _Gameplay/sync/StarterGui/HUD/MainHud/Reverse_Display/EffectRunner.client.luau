local TweenService = game:GetService("TweenService")

local Display = script.Parent
local Clock = Display.Clock

Display:GetAttributeChangedSignal("LastTick"):Connect(function()
	
	local clockTween = TweenService:Create(Clock, TweenInfo.new(0.15), {ImageTransparency = 0})
	clockTween:Play()
	
	-- TODO: Create Hand Tweenings and start all together
	
	clockTween.Completed:Once(function()
		-- TODO: Run Clock Animation
		task.wait(1.5)
		
		local clockTween = TweenService:Create(Clock, TweenInfo.new(0.15), {ImageTransparency = 1})
		clockTween:Play()
		
		-- TODO: Create Hand Tweenings and start all together
	end)
	
	
end)