local Item_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Items')
local ItemClass = {}

local Settings = {
	ItemColor = Color3.fromRGB(89, 89, 89);
	ItemPictureID = "rbxgameasset://Images/item_Flashlight";
}

function ItemClass:GetInfo(rawItem)
	local Percentage, Color, Name, Image = 0, Settings.ItemColor, string.lower(rawItem.Name), Settings.ItemPictureID

	Percentage = rawItem:GetAttribute('Progress')/10 --rawItem:WaitForChild('UseProgress', 3).Value

	local Item_Module = Item_Data:FindFirstChild(rawItem.Name)

	if not Item_Module then
		warn(rawItem.Name, 'missing module!')
		--Item_Module = Item_Data:FindFirstChild(Translate(rawItem))
	end

	if Item_Module then
		Item_Module = require(Item_Module)
		Image = Item_Module.Image
		Color = Item_Module.Color
	end

	return Percentage, Image, Color
end

return ItemClass
