local TweenService = game:GetService("TweenService")

local ValueComponent = require(script.Parent.ValueComponent)

local ResourceComponent = {}

ResourceComponent.__index = ResourceComponent

function ResourceComponent.new(attributeConfig: Configuration, attributeKey: string, default: number)
	local self = setmetatable({}, ResourceComponent)
	
	self.AttributeConfig = attributeConfig
	self.AttributeKey = attributeKey
	self.Default = default
	self.Amount = default
	self.Values = {}
	
	attributeConfig:SetAttribute(attributeKey, default)
	
	return self
end

function ResourceComponent:Set(value: number)
	self.Amount = value
	self.AttributeConfig:SetAttribute(self.AttributeKey, self.Amount)
end

function ResourceComponent:Add(key: string, value: number, duration: number)
	
	if (self.Values[key] ~= nil) then
		self.Values[key].Amount = value
		self.Values[key].Duration = duration
		self:Summarize()
		return
	end
	
	local newValueComponent = ValueComponent.new(value, duration, self)
	self.Values[key] = newValueComponent
	self:Summarize()
end

function ResourceComponent:Remove(key: string)

	if (self.Values[key] == nil) then
		return
	end

	self.Values[key]:Delete(false)
	self.Values[key] = nil
	self:Summarize()
end

function ResourceComponent:Get(valueList: "table")
	
	local current = self.Default
	
	for key, valueComponent in pairs(self.Values) do
		if (valueComponent.Amount == nil) then
			continue
		end
		
		if (valueList ~= nil) then
			if (table.find(valueList, key) == nil) then
				continue
			end
		end
		
		if (valueComponent:GetValue() == 0) then
			return 0
		end
		
		current += valueComponent:GetValue()
	end
	
	return current
end

function ResourceComponent:Cleanup()
	for key, valueComponent in pairs(self.Values) do
		if (valueComponent == nil) then
			self:Remove(key)
			continue
		end
		
		if (valueComponent.Amount == nil) then
			self:Remove(key)
			continue
		end
	end
end

function ResourceComponent:Summarize(valueList: "table")
	self.Amount = self:Get(valueList)
	self.AttributeConfig:SetAttribute(self.AttributeKey, self.Amount)
	return self.Amount
end

return ResourceComponent
