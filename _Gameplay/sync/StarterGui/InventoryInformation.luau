local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UiSettings = ReplicatedStorage:WaitForChild("UI_SETTINGS")


local module = {}

function module.returnId(name : StringValue,tier : StringValue) : "Returns id & rarity/color"
	for _,v in pairs(UiSettings:GetDescendants()) do
		if v.Name == name then
			return v:GetAttribute("Image"), if tier then v:GetAttribute("Tier" .. tier) else v:GetAttribute("Color")
		end
	end
end

return module
