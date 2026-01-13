local RunService = game:GetService("RunService")

local ValueComponent = {}

ValueComponent.__index = ValueComponent

function ValueComponent.new(amount: number, duration: number, resourceComp: ResourceComponent)
	
	local self = setmetatable({}, ValueComponent)

	self.Active = true
	self.Amount = amount
	self.Duration = duration
	self.ResourceComponent = resourceComp
	
	if (duration == nil) then
		return self
	end
	
	if (duration > 0) then
		self.Runner = RunService.Heartbeat:Connect(function(delta)
			self:RunDuration(delta)
		end)
	end

	return self
end

function ValueComponent:GetValue()
	return self.Amount
end

function ValueComponent:RunDuration(delta)
	
	self.Duration -= delta
	
	if (self.Duration <= 0) then
		self.Runner:Disconnect()
		self.Runner = nil
		self:Delete(true)
	end
end

function ValueComponent:Delete(cleanUp: boolean)
	
	self.Amount = nil
	self.Duration = nil
	
	if (cleanUp) then
		self.ResourceComponent:Cleanup()
	end
	
	self.ResourceComponent:Summarize()

end

return ValueComponent
