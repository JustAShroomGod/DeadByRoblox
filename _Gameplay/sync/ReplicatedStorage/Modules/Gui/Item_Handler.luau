local Prefix = "rbxgameasset://Images/"
local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local KillerAddons = ReplicatedStorage:WaitForChild("Game_Data"):WaitForChild("Addons"):WaitForChild("Killer")
local SurvivorAddons = ReplicatedStorage:WaitForChild("Game_Data"):WaitForChild("Addons"):WaitForChild("Survivor")

local ItemFrame = {
	Modules = {}
}
ItemFrame.__index = ItemFrame

local RadialModule = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Circle_Dependency')) -- used to fill radials
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

for _,module in pairs(script:GetChildren())do
	ItemFrame.Modules[module.Name] = require(module)
end

local function ReturnAddons(Item)
	local Addons_Data = data_module:GetAddons("Killer", player)
	local AddonModules = {}

	for _, Addon in ipairs(Addons_Data) do

		if KillerAddons:FindFirstChild(Addon) then
			table.insert(AddonModules, require(KillerAddons[Addon]))
		end
	end

	if Item then
		AddonModules = {}
		local Add_on1 = Item:GetAttribute("Addon_1")
		local Add_on2 = Item:GetAttribute("Addon_2")
		
		if Add_on1 then
			if SurvivorAddons:FindFirstChild(Add_on1) then
				table.insert(AddonModules, require(SurvivorAddons[Add_on1]))
			end
		end
		if Add_on2 then
			if SurvivorAddons:FindFirstChild(Add_on2) then
				table.insert(AddonModules, require(SurvivorAddons[Add_on2]))
			end
		end
	end

	return AddonModules
end

function ItemFrame:Update(...) -- recieve itemFrame Whole, actionlist
	local args = {...}

	local frame, playerValues = args[1], args[2]
	local percent1, percent2, count, color, imageID = -1,-1,0, Color3.fromRGB(0, 0, 0), Prefix
	local isKiller = player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('Killer').Value

	if isKiller then --killer show power
		local characterType = playerValues.Data:GetCharacter();
		local powerFrame = frame:WaitForChild('Main')
		local addon1,addon2 = frame:WaitForChild("Addon1"),frame:WaitForChild("Addon2")

		local killerType = nil

		for moduleName, module in pairs(ItemFrame.Modules) do
			if string.match(string.lower(moduleName), string.lower(characterType)) then
				killerType = moduleName
			end
		end

		if killerType then
			local killerArgs = {ItemFrame.Modules[killerType]:GetInfo(playerValues)}

			percent1 = killerArgs[1]
			count = killerArgs[2]
			imageID = killerArgs[3]
			color = killerArgs[4]

			local Addons = ReturnAddons()

			if Addons[1] then
				addon1.Icon.Image = Addons[1].Image
				addon1.BackgroundColor3 = Addons[1].Color
				addon1.Visible = true
			end

			if Addons[2] then
				addon2.Icon.Image = Addons[2].Image
				addon2.BackgroundColor3 = Addons[2].Color
				addon2.Visible = true
			end

			frame.Visible = true
		else
			warn(characterType, 'module does not exist!')
			frame.Visible = false
		end
	else --survivor display or don't display item
		local character = player.Character
		local itemFrame = frame:WaitForChild('Main')

		if character then
			local currentItem = playerValues.CharacterItem -- our current item

			if currentItem and currentItem:GetAttribute("Class") and ItemFrame.Modules[currentItem:GetAttribute("Class")] then
				local itemArgs

				local Success,Error = pcall(function()
					itemArgs = {ItemFrame.Modules[currentItem:GetAttribute('Class')]:GetInfo(currentItem)} -- returns a percentage of item + image + background color!
				end)

				if Success then
					percent2 = itemArgs[1]
					imageID = itemArgs[2]
					color = itemArgs[3]
					frame.Visible = true

					local Addons = ReturnAddons(currentItem)
					local addon1,addon2 = frame:WaitForChild("Addon1"),frame:WaitForChild("Addon2")
					if Addons[1] then
						addon1.Icon.Image = Addons[1].Image
						addon1.BackgroundColor3 = Addons[1].Color
						addon1.Visible = true
					else
						addon1.Visible = false
					end

					if Addons[2] then
						addon2.Icon.Image = Addons[2].Image
						addon2.BackgroundColor3 = Addons[2].Color
						addon2.Visible = true
					else
						addon2.Visible = false
					end
				else
					frame.Visible = false
				end
			elseif currentItem and not currentItem:GetAttribute("Class") then
				frame.Visible = false
				error(currentItem.Name.." has no class")
			elseif currentItem and not ItemFrame.Modules[currentItem:GetAttribute("Class")] then
				frame.Visible = false
				error(currentItem.Name..' does not have a sub-module')
			else -- has no item equipped || disable the gui
				frame.Visible = false
			end
		end
	end

	local Background = RadialModule.new(frame:WaitForChild('Main'), percent1) -- update the power bar
	local mainFrame = frame:WaitForChild('Main')

	if count and count >= 1 then
		mainFrame.Count.Visible = true
		mainFrame.Count.Text = count
	else  -- has no items collected || disable the gui
		mainFrame.Count.Visible = false
	end

	mainFrame.Icon.BackgroundColor3 = color
	mainFrame.Icon.Image = imageID

	if percent2 >= 0 then
		mainFrame.ItemProgress.Visible = true

		local eq = (100 - percent2) -- 100/100 = 0 removed or 100 - 30 = 60 removed
		eq = 143 * (-eq/100) - 18

		mainFrame.ItemProgress.Bar.ImageLabel:WaitForChild('UIGradient').Rotation = eq
	else
		mainFrame.ItemProgress.Visible = false
	end
end

return ItemFrame