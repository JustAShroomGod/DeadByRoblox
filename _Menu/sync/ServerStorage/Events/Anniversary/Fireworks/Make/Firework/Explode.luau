local ts = game:GetService("TweenService")
local self = script.Parent
local blowing = false

return function()
	if blowing == true then return end
	
	blowing = true
	
	self.CanCollide = false
	self.Sparks.Enabled = true
	--self.Wind:Destroy()
	self.Perform:Play()
	
	local g = {Position = Vector3.new(self.Position.X, self.Position.Y + 50, self.Position.Z)}
	local tw = ts:Create(script.Parent, TweenInfo.new(1, Enum.EasingStyle.Linear), g)
	
	tw:Play()
	tw.Completed:Wait()
	
	self.Perform:Destroy()
	self.Sparks:Destroy()
	self.Explosion.Enabled = true
	self.Transparency = 1

	game.Debris:AddItem(self, 3)
	
end