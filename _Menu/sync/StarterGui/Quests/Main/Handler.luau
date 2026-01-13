local Main : Frame = script.Parent.Parent:WaitForChild("Main")

local module = {
	Count = 1
}
module.__index = module

function module.New(Data) : "Creates Slot"
	local Slot = {}
	setmetatable(Slot,module)
	
	if Data.Amount > Data.Needed then Data.Amount = Data.Needed end
	
	Slot.Name = "Slot" .. tostring(module.Count) 
	Slot.Object = script:WaitForChild("Prefab"):Clone()
	
	Slot.BarBackground = Slot.Object:WaitForChild("BarBackground")
	Slot.Bar = Slot.BarBackground:WaitForChild("Bar")
	Slot.BarFlavor = Slot.BarBackground:WaitForChild("Flavor")
	
	Slot.Description = Slot.Object:WaitForChild("Description")
	Slot.Reward = Slot.Object:WaitForChild("Reward")
	
	Slot.Description.Text = Data.Description
	Slot.Reward.Text = Data.Reward
	Slot.BarFlavor.Text = Data.Amount .. "/" .. Data.Needed
	Slot.Bar.Size = UDim2.new(tonumber(Data.Amount)/tonumber(Data.Needed),0,1,0)
	
	Slot.Object.Parent = Main
	
	if Data.Completed == true then Slot:Disable() end
	
	module.Count += 1
	return Slot
end

function module:Disable() : "Shows that a quest is completed"
	self.BarFlavor.Text = "Completed"
end


return module
