local Code = require(game.ReplicatedStorage.Modules.Code)

local Player = game.Players.LocalPlayer

local Prog = {}
Prog.__index = Prog

function BreakTable(metaTable)
	local percent = 0
	
	if metaTable.raw == "Attribute_Table" or metaTable.raw == 'Broken' or metaTable.raw == 'WiggleProgress' then -- special percentages that hold both values
		local split = metaTable.Value:split(':') -- splits into table
		
		percent =  split[1]/split[2]
	else
		percent = metaTable.Value
	end
	
	return percent
end

function BreakAttribute(att : string)
	local split = att:split(':') -- splits into table
	
	return split[1]/split[2]
end

function Prog:Update(percent_update)
	local bar, p = self.UI.Bar, self.Percent
	
	if typeof(self.Percent) == "Instance" then
		p = tonumber(p.Value) -- will convert string values to numbers or leave float/ints at numbers
		
	elseif typeof(self.Percent) == 'table' then
		
		if typeof(self.Percent.Value) == "string" then
			p = BreakAttribute(self.Percent.raw:GetAttribute(self.Percent.Value))
		elseif self.Percent.raw then
			p = BreakTable(self.Percent)
		end
	end
	
	p = tonumber(p) -- convert to number
	
	if p > 1 then
		p /= 1000
	end
	
	p = math.clamp(p, 0, 1)
	
	bar.Size = UDim2.new(p, 0, 1, 0)
	self:UpdateColor()
end

function Prog:UpdateColor()
	
	if (self.Tracking == nil) then
		return
	end
	
	if (self.Tracking.BaseValue == nil) then
		return
	end

	if (self.Tracking.AttributeName == nil) then
		return
	end
	
	local bar, p, SpeedAdjustments = self.UI.Bar, self.Percent, self.UI.Parent.Parent.SpeedAdjustments

	local BaseValue = self.Tracking.BaseValue
	local PlayerValue = Code:GetPlayerValue(Player, self.Tracking.AttributeName)

	local ColorBigger = if (not self.Tracking.Reverse) then Color3.fromRGB(255, 0, 0) else Color3.fromRGB(255, 170, 0)
	local ColorSmaller = if (not self.Tracking.Reverse) then Color3.fromRGB(255, 170, 0) else Color3.fromRGB(255, 0, 0)
	
	bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SpeedAdjustments.Visible = false
	
	if (IsBigger(BaseValue, PlayerValue)) then
		bar.BackgroundColor3 = ColorBigger
		SpeedAdjustments.Circle.ImageColor3 = ColorBigger
		SpeedAdjustments.Image.Rotation = if (not self.Tracking.Reverse) then 180 else 0
		SpeedAdjustments.Visible = true
		return
	end 
	
	if (IsSmaller(BaseValue, PlayerValue)) then
		bar.BackgroundColor3 = ColorSmaller
		SpeedAdjustments.Circle.ImageColor3 = ColorSmaller
		SpeedAdjustments.Image.Rotation = if (not self.Tracking.Reverse) then 0 else 180
		SpeedAdjustments.Visible = true
		return
	end
end
	
function IsBigger(Base, Current) -- Tells us if the BaseValue is bigger
	
	if (Base < Current) then
		return false
	end
	
	if (Base == Current) then
		return false
	end
	
	return true
end

function IsSmaller(Base, Current) -- Tells us if the BaseValue is smaller

	if (Base > Current) then
		return false
	end

	if (Base == Current) then
		return false
	end

	return true
end
	

local function GatherUI(parent) -- smart gather system will return a nice error if we do it incorrectly
	local Parent_Frame = parent

	local Frame1 = Parent_Frame:FindFirstChildOfClass("Frame")

	if not Frame1 then
		return warn('Syntax: Incorrect Format || Missing Frame1 Child (Ex: Parent_Frame{Frame1{Frame2}}')
	end

	local Bar = Frame1:FindFirstChildOfClass('Frame')

	if not Bar then
		return warn('Syntax: Incorrect Format || Missing Frame2 Child (Ex: Parent_Frame{Frame1{Frame2}}')
	end
	
	return {
		["Parent"] = Parent_Frame;
		["Bar"] = Bar;
	}
end

local function BuildUI(...)
	local args = {...}

	local Parent_Frame = Instance.new("Frame", args[1])
	Parent_Frame.Name = "Progress"
	Parent_Frame.BackgroundTransparency = 0.45
	Parent_Frame.BackgroundColor3 = Color3.fromRGB(11,11,11)
	Parent_Frame.BorderSizePixel = 0
	
	local BarFrame = Instance.new("Frame", Parent_Frame)
	BarFrame.BackgroundTransparency = 1
	BarFrame.BorderSizePixel = 0
	BarFrame.AnchorPoint = Vector2.new(0.5,0.5)
	BarFrame.Position = UDim2.new(0.5,0,0.5,0)
	BarFrame.Size = UDim2.new(1,0,0.75,0)
	
	local Bar = Instance.new("Frame", BarFrame)
	Bar.Name = "Bar"
	Bar.BorderSizePixel = 0
	Bar.BackgroundTransparency = 0.2
	Bar.BackgroundColor3 = args[2] or Color3.fromRGB(255,255,255)
	Bar.AnchorPoint = Vector2.new(0,0.5)
	Bar.Position = UDim2.new(0,0,0.5,0)
	Bar.Size = UDim2.new(0.5,0,1,0)

	return {
		["Parent"] = Parent_Frame;
		["Bar"] = Bar;
	}
end

function Prog:SetColor(newcolor)
	self.UI.Bar.BackgroundColor3 = newcolor or Color3.fromRGB(255,255,255)
end

function Prog:NewPercent(...) -- replace intvalue from percentage holder or add one
	local args = {...}

	self.Percent = args[1]

	if typeof(self.Percent) == "Instance" and self.Percent.ClassName ~= "Frame" then
		if self.Connection then self.Connection:Disconnect() self.Connection = nil end

		self.Connection = self.Percent.Changed:Connect(function()
			self:Update()
		end)

	elseif typeof(self.Percent) == "number" then
		if self.Connection then self.Connection:Disconnect() self.Connection = nil end
	elseif typeof(self.Percent) == 'table' then
		if self.Connection then self.Connection:Disconnect() self.Connection = nil end

		if typeof(self.Percent.Value) == "string" then

			self.Connection = self.Percent.raw:GetAttributeChangedSignal(self.Percent.Value):Connect(function()
				self:Update()
			end)
		elseif self.Percent.raw then -- it's a special table

			self.Connection = self.Percent.Changed:Connect(function()
				self:Update()
			end)
		end
	else
		if self.Connection then self.Connection:Disconnect() self.Connection = nil end

		self.Percent = self.Percent or 0
	end
	
	self:Update()
end

function Prog.new(...) -- recieve percentage holder, and parent, color
	local args = {...}

	local newpercent = args[1]
	
	local self = {}
	setmetatable(self, Prog) -- give it all the functions
	
	if typeof(args[1]) == "Instance" and args[1].ClassName == "Frame" then
		self.UI, newpercent = GatherUI(args[1])
		newpercent = args[2]
		
		if typeof(self.UI) ~= "table" then
			return warn("Could not convert the frame!\n")
		end
	else
		self.UI = BuildUI(args[2], args[3])
	end
	
	self.Percent = newpercent or 0
	
	if typeof(self.Percent) == "Instance" and self.Percent.ClassName ~= "Frame" then
		if self.Connection then self.Connection:Disconnect() self.Connection = nil end

		self.Connection = self.Percent.Changed:Connect(function()
			self:Update()
		end)

	elseif typeof(self.Percent) == "number" then
		if self.Connection then self.Connection:Disconnect() self.Connection = nil end
		
	elseif typeof(self.Percent) == 'table' then
		if self.Connection then self.Connection:Disconnect() self.Connection = nil end
		
		if self.Percent.raw then -- it's a special table
			
			self.Connection = self.Percent.Changed:Connect(function()
				self:Update()
			end)
		end
	else
		if self.Connection then self.Connection:Disconnect() self.Connection = nil end

		self.Percent = 500
	end

	self:Update()

	return self
end

return Prog
