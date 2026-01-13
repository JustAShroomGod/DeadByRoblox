-- Handles Circular/Radial Images --

local prefix = 'rbxassetid://'
local Image = prefix..8907779300;

local Rad = {}
Rad.__index = Rad

function Rad:Update()
	local G1, G2, p = self.UI.Gradient1, self.UI.Gradient2, self.Percent
	
	if typeof(self.Percent) == "Instance" then
		p = p.Value
	end
	
	if p >= 0.1 then
		p /= 100
	end
	
	local point1, point2 = (1-p) * -360, math.clamp(p * 360, 0, 180)

	if point1 <= -180 then
		G1.Parent.Visible = false
	else
		G1.Parent.Visible = true
	end
	
	if point2 <= 0 then
		G2.Parent.Visible = false
	else
		G2.Parent.Visible = true
	end
	
	G1.Rotation = point1
	G2.Rotation = point2
end

local function GatherUI(parent) -- smart gather system will return a nice error if we do it incorrectly
	local Parent_Frame = parent
	
	local Frame1, Frame2 = Parent_Frame:FindFirstChild('Frame1'), Parent_Frame:FindFirstChild('Frame2')
	
	if not Frame2 or not Frame1 then
		return warn('Syntax: Incorrect or Missing Format (Ex: Frame{Frame1, Frame2}')
	end
	
	local Image1, Image2 = Frame1:FindFirstChildOfClass('ImageLabel'), Frame2:FindFirstChildOfClass('ImageLabel')
	
	if not Image1 or not Image2 then
		return warn("Syntax: Image Labels are missing!")
	end
	
	local Gradient1, Gradient2 = Image1:FindFirstChildOfClass("UIGradient"), Image2:FindFirstChildOfClass("UIGradient")
	
	if not Gradient1 or not Gradient2 then
		return warn("Syntax: No Gradients Found in Image Labels!")
	end
	
	return {
		["Parent"] = Parent_Frame;
		["Gradient1"] = Gradient1;
		["Gradient2"] = Gradient2;
	}
end

local function BuildUI(...)
	local args = {...}
	
	warn(args, "\n here")
	
	local Parent_Frame = Instance.new("Frame", args[2])
	Parent_Frame.Name = "Radial"
	Parent_Frame.BackgroundTransparency = 1
	
	local Frame1 = Instance.new("Frame", Parent_Frame)
	Frame1.Name = "Frame1"
	Frame1.ClipsDescendants = true
	Frame1.BackgroundTransparency = 1
	Frame1.Size = UDim2.new(0.5,0,1,0)

	local Frame2 = Frame1:Clone()
	Frame2.Name = "Frame2"
	Frame2.AnchorPoint = Vector2.new(1,0)
	Frame2.Position = UDim2.new(1,0,0,0)
	Frame2.Parent = Parent_Frame
	
	local ImageLabel = Instance.new("ImageLabel", Frame1)
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.Size = UDim2.new(2,0,1,0)
	ImageLabel.Image = args[1]
	ImageLabel.ImageColor3 = args[3] or Color3.fromRGB(255,255,255)

	local Gradient1 = Instance.new('UIGradient', ImageLabel)
	Gradient1.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0, 0),
		NumberSequenceKeypoint.new(0.5, 0, 0),
		NumberSequenceKeypoint.new(0.501, 1, 0),
		NumberSequenceKeypoint.new(1, 1, 0),
	})
	
	ImageLabel = ImageLabel:Clone()
	ImageLabel.AnchorPoint = Vector2.new(1,0)
	ImageLabel.Position = UDim2.new(1,0,0,0)
	ImageLabel.Parent = Frame2
	
	local Gradient2 = ImageLabel:FindFirstChild("UIGradient")
		
	return {
		["Parent"] = Parent_Frame;
		["Gradient1"] = Gradient1;
		["Gradient2"] = Gradient2;
	}
end

function Rad:NewPercent(...) -- replace intvalue from percentage holder or add one
	local args = {...}
	
	self.Percent = args[1]
	
	if typeof(self.Percent) == "Instance" then
		if self.Connection then self.Connection:Disconnect() self.Connection = nil end

		self.Connection = self.Percent.Changed:Connect(function()
			self:Update()
		end)
	else
		if self.Connection then self.Connection:Disconnect() self.Connection = nil end
	end
	
	self:Update()
end

function Rad:SetColor(newcolor)
	
	local G1, G2 = self.UI.Gradient1, self.UI.Gradient2
	
	G1.Parent.ImageColor3 = newcolor or Color3.fromRGB(255, 255, 255)
	G2.Parent.ImageColor3 = newcolor or Color3.fromRGB(255, 255, 255)
end

function Rad.new(...) -- recieve imageid, percentage holder, and parent
	local args = {...}
	
	local self = {}
	setmetatable(self, Rad) -- give it all the functions
	
	if typeof(args[1]) == "Instance" then
		self.UI = GatherUI(args[1])
		
		if typeof(self.UI) ~= "table" then
			return warn("Could not convert the frame!\n")
		end
	else
		self.UI = BuildUI(prefix..args[1], args[3], args[4])
	end
	
	self.Percent = args[2] or 85

	if typeof(self.Percent) == "Instance" then
		if self.Connection then self.Connection:Disconnect() self.Connection = nil end
		
		self.Connection = self.Percent.Changed:Connect(function()
			self:Update()
		end)
	else
		if self.Connection then self.Connection:Disconnect() self.Connection = nil end
	end

	self:Update()
	
	return self
end

return Rad
