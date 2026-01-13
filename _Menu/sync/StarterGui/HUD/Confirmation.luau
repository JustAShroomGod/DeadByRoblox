local Prefab = script.Prefab

local Confirmation = {}
Confirmation.__index = Confirmation

function Confirmation.new(Header: string, Body: string, Confirm: () -> (), Deny: () -> ())
	
	local self = setmetatable({}, Confirmation)
	
	self.UI = Prefab:Clone()
	self.UI.Name = "Header"
	self.UI.Parent = script.Parent
	
	self.UI.Separator.HeaderTitle.Text = Header
	self.UI.Separator.DescTitle.Text = Body
	
	self.UI.Separator.ConfirmBtn.MouseButton1Click:Once(function()
		self.UI:Destroy()
		Confirm()
	end)
	
	self.UI.Separator.DenyBtn.MouseButton1Click:Once(function()
		self.UI:Destroy()
		Deny()
	end)
	
	return self
end

return Confirmation
