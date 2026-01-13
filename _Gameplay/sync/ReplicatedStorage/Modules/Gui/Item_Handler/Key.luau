local Item_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Items')
local ItemClass = {}

local Settings = {
	ItemColor = Color3.fromRGB(89, 89, 89);
	ItemPictureID =  "rbxgameasset://Images/";
}

function Translate(item : Model)
	local class = item:GetAttribute("Class")
	local color = item.Name

	if class == "Toolbox" then
		color = string.gsub(color, "Tools", "")

		if color == "WornOut" then
			color = "Brown"
		elseif color == "Sabo" then
			color = "Gold"
		else
			color = nil
		end
	elseif class == "Flashlight" then
		color = string.gsub(color, "FlashLight", "")

		if color == "" or color == " " then
			color = "Yellow"
		end
	elseif class == "Medkit" then
		color = string.gsub(color, "FirstAidKit", "")

		if color == "" or color == " " then
			color = "Yellow"
		elseif color == "Event" then
			--color = "Event"
		else
			color = nil
		end
	elseif class == "Key" then
		color = string.gsub(color, "Key", "")
	elseif class == "FireCracker" then
		color = string.gsub(color, "FireCracker", "")
	else
		color = nil
	end

	if color then
		return color..'_'..class
	else
		return ""
	end
end

function ItemClass:GetInfo(rawItem)
	local Percentage, Color, Name, Image = -1, Settings.ItemColor, string.lower(rawItem.Name), Settings.ItemPictureID

	local Item_Module = Item_Data:FindFirstChild(rawItem.Name)

	if not Item_Module then
		Item_Module = Item_Data:FindFirstChild(Translate(rawItem))
	end

	if Item_Module then
		Item_Module = require(Item_Module)
		Image = Item_Module.Image
		Color = Item_Module.Color
	end

	return Percentage, Image, Color
end

return ItemClass
