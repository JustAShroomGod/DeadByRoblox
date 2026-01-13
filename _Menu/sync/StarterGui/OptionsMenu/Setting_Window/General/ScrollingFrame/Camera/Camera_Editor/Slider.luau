local Handler = {}

function Handler.new(Frame : Frame) : "Returns Slider"
	local self = {}

	self.Slider = Frame:WaitForChild('Slide')

	self.Percent = 0.5

	self.Update = function(tables)
		self.Percent = self.Slider.Position.X.Scale
	end

	self.Slide = function(tables, ScaledPosition)
		self.Slider.Position = ScaledPosition
		self:Update()
	end

	self.Amount = function(tables)
		self:Update()
		return self.Percent
	end

	return self
end

return Handler
