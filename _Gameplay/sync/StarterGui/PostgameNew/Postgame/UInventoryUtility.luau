localPlayer = game:GetService("Players").LocalPlayer
playerGui = localPlayer:WaitForChild("PlayerGui")


local InventoryInformation = require(playerGui:WaitForChild("InventoryInformation"))

--DESIGNLOADERSLIST 
PREFIX = "rbxassetid://"
PREFIX2 = "rbxgameasset://Images/"


function findByName(tab, name : string)
	for _, object in pairs(tab) do
		if not object:IsA("Folder") and object.Name == name then
			return object
		end
	end
end

local InventoryUtility = {}
InventoryUtility.DesignLoadersList = {
	Item = function(instance, data)
		local imageid,color = InventoryInformation.returnId(data.name)

		instance.Rarity.BackgroundColor3 = color
		instance.Icon.Image = imageid
	end,
	Addon = function (instance, data)
		local imageid,color = InventoryInformation.returnId(data.name)

		instance.Rarity.BackgroundColor3 = color
		instance.Icon.Image = imageid
		--[[local color = data.rarity.color
		instance.Rarity.BackgroundColor3 = color
		instance.Icon.Image = PREFIX.. tostring(data.imageid)]]
	end,
	Offering = function (instance, data)
		local color = data.rarity.color
		instance.Rarity.ImageColor3 = color
		instance.Icon.Image = PREFIX.. tostring(data.imageid)
	end,
	Perk = function (instance, data)
		local imageid,tiercolor = InventoryInformation.returnId(data.name,tostring(data.tier))

		instance.Rarity.BackgroundColor3 = tiercolor
		instance.Icon.Image = imageid

		for _, any in pairs(instance.Plus:GetChildren()) do
			any.Visible = tonumber(any.Name) <= data.tier
		end

		instance:SetAttribute("PerkName", data.name)

		--[[perkExample.Rotation = -rotation.Value
		local perkChoiceInd = math.random(1,#perkChoices)
		local perkChoice = perkChoices[perkChoiceInd] table.remove(perkChoices, perkChoiceInd)
		local perkIndex = perkChoice[1]
		local perkTier = perkChoice[2]

		stuffIndex.Value = "Perks"
		stuff.Value = perkIndex.. "Tier".. tostring(perkTier)
		]]
	end,
}








return InventoryUtility
