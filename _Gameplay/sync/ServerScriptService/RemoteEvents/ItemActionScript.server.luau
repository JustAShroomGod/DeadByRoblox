local ReplicatedStorage : ReplicatedStorage, ServerStorage : ServerStorage = game:GetService("ReplicatedStorage"), game:GetService("ServerStorage")

local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = string.gsub(script.Name, "Script", "")
remoteEvent.Parent = remoteEvents

local templateObjects = ServerStorage:WaitForChild("TemplateObjects")

local dropItems = templateObjects:WaitForChild("DropItems")
local itemsStuff = ServerStorage:WaitForChild("ItemsStuff")


--[[remoteEvent.OnServerEvent:Connect(function(Player : Player, loadOutItem : Model, action : StringValue, event : string)
	if not loadOutItem or not action or not event then return end
	local Character : Model = Player.Character
	
	if event == 'Drop' and
		not loadOutItem:GetAttribute("Dropped")
		and action.Value ~= "GrabItemAction" then
		local loadOutItemHandle = loadOutItem:FindFirstChild("Handle")
		local fixatt = loadOutItem:GetAttribute('QuickFixed')

		loadOutItem:SetAttribute("Dropped", true) -- prevent drop spam hopefully
		Player.Character:SetAttribute("Motion_Locked", true)
		
		action.Value = "DropItemAction"

		local DropTrack = Character.Humanoid:LoadAnimation(script:WaitForChild('Drop'))
		
		DropTrack.KeyframeReached:Once(function(keyframe)
			
			if keyframe == "DropFrame" then
				local dropItem = dropItems:FindFirstChild(loadOutItem.Name)
				
				if dropItem then
					local ClonedItem = false
					local newDropItem = dropItem:Clone()
					local newDropItemHandle = newDropItem:WaitForChild("Handle")
					
					newDropItemHandle.Anchored = true
					newDropItem:PivotTo(Character:GetPivot() * CFrame.new(1.3, -2.7 + (newDropItemHandle.Size.Y/2), -1.3))
					newDropItem:SetAttribute('QuickFixed', fixatt)

					for ItemClass, ItemList in pairs(storageValues) do
						if ClonedItem then break end

						for ItemName, ItemProperties in pairs(ItemList) do
							if ClonedItem then break end

							if ItemName == loadOutItem.Name then
								ClonedItem = true

								for _, Property in pairs(ItemProperties) do
									local thisStorageValue = loadOutItem:FindFirstChild(Property)

									if thisStorageValue then
										thisStorageValue:Clone().Parent = newDropItem
									end
								end
							end
						end
					end

					newDropItem:SetAttribute("Picked", true) -- make it seem like somebody is picking it up when dropping to create artifical delay between dropping/picking up
					newDropItem:SetAttribute("Tool", true)
					newDropItem.Parent = workspace
					loadOutItem:Destroy()

					task.delay(.25, function()
						newDropItem:SetAttribute("Picked", false)
					end)
				end
			end
		end)
		
		DropTrack:Play(.2, 4, 4.5)

		DropTrack.Stopped:Wait()
		task.wait(.5)
		action.Value = "Nothing"
		Player.Character:SetAttribute("Motion_Locked", false)
	elseif event == 'Grab' then
		if action.Value == 'DropItemAction' then return end

		local ITEM_NAME : string = loadOutItem.Name
		local itemObject : Model = itemsStuff:FindFirstChild(ITEM_NAME)

		if itemObject and not loadOutItem:GetAttribute("Picked") then
			local newItemObject = itemObject:Clone()
			local ClonedItem = false

			loadOutItem:SetAttribute("Picked", true)
			action.Value = "GrabItemAction"
			Player.Character:SetAttribute("Motion_Locked", true)
			
			for _,ItemType in pairs(storageValues) do
				if ClonedItem then break end

				for itemName,itemProperties in pairs(ItemType) do
					if ClonedItem then break end

					if itemName == ITEM_NAME then
						ClonedItem = true

						for _,storageValue in pairs(itemProperties) do
							local lastStorageValue = loadOutItem:FindFirstChild(storageValue)
							local thisStorageValue = newItemObject:FindFirstChild(storageValue)

							if lastStorageValue and thisStorageValue then
								thisStorageValue.Value = lastStorageValue.Value
							end
						end
					end
				end
			end

			newItemObject:SetAttribute("Tool", true)
			newItemObject:SetAttribute('QuickFixed', loadOutItem:GetAttribute('QuickFixed'))
			newItemObject.Parent = Character
			loadOutItem:Destroy()

			local PickUpTrack = Character.Humanoid:LoadAnimation(script:WaitForChild('Pickup'))
			PickUpTrack:Play(.2, 4, 4.5)

			PickUpTrack.Stopped:Wait()
			task.wait(.5)

			action.Value = "Nothing"
			Player.Character:SetAttribute("Motion_Locked", false)
		end
	end
end)]]

---------------------------\
local Server_Tracks = {}

function GrabItem(Character : Model) : "Return Item in Character"
	if not Character then return end

	for _, model in pairs(Character:GetChildren()) do

		if model:IsA('Model') and model:GetAttribute("Tool") then
			return model
		end
	end

	return nil
end

remoteEvent.OnServerEvent:Connect(function(Player : Player, COMMAND : "GRAB" | "DROP", Item : Model, SwapItem)
	local Character = Player.Character
	local Player_Values = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')
	local Our_Item = GrabItem(Character)

	local Action = Player_Values:WaitForChild('Action')

	if not Server_Tracks[Player] then
		Server_Tracks[Player] = {
			Drop = Character.Humanoid:LoadAnimation(script:WaitForChild('Drop'));
			Grab = Character.Humanoid:LoadAnimation(script:WaitForChild('Drop'));
		}
	end

	--print(COMMAND, Our_Item, Action)

	if COMMAND == "DROP" and Our_Item and Action.Value == "Nothing" then Action.Value = "DropItemAction"
		Player.Character:SetAttribute("Motion_Locked", true) -- lock in place
		Player.Character.PrimaryPart.Anchored = true
		
		Server_Tracks[Player].Drop.KeyframeReached:Once(function(keyframe)
			if keyframe == "DropFrame" and Action.Value == "DropItemAction" then
				local Item_To_Drop = if dropItems:FindFirstChild(Our_Item.Name) then dropItems:WaitForChild(Our_Item.Name):Clone() else nil

				if Item_To_Drop then

					Item_To_Drop:WaitForChild('Handle').Anchored = true
					Item_To_Drop:PivotTo(Character:GetPivot() * CFrame.new(1.3, -2.7 + (Item_To_Drop.Handle.Size.Y/2), -1.3))

					for attribute, value in pairs(Our_Item:GetAttributes()) do
						Item_To_Drop:SetAttribute(attribute, value) -->> over-write/save
					end

					Our_Item:Remove() -->> take away our item
					Item_To_Drop.Parent = workspace -->> place on floor
					---------------

					--[[newDropItem:SetAttribute("Picked", true) -- make it seem like somebody is picking it up when dropping to create artifical delay between dropping/picking up

					task.delay(.25, function()
						newDropItem:SetAttribute("Picked", false)
					end)]]-- >> gonna see if we can make do w/ out this
				else
					error(Our_Item.Name .. ' is not in the drop items folder!')
				end
			end
		end)

		Server_Tracks[Player].Drop:Play()--.1, 4, 1.8)
		Server_Tracks[Player].Drop:AdjustSpeed(1.5)
		Server_Tracks[Player].Drop.Stopped:Wait()

		Action.Value = "Nothing"
		Player.Character:SetAttribute("Motion_Locked", false)
		Player.Character.PrimaryPart.Anchored = false

		--task.wait(0.5)
	elseif COMMAND == 'GRAB' and Item and Action.Value == "Nothing" and not Item:GetAttribute("Grabbed") then
		Item:SetAttribute("Grabbed", true) Action.Value = "GrabItemAction"
		if SwapItem then
			local Item_To_Drop = if dropItems:FindFirstChild(Our_Item.Name) then dropItems:WaitForChild(Our_Item.Name):Clone() else nil

			if Item_To_Drop then

				Item_To_Drop:WaitForChild('Handle').Anchored = true
				Item_To_Drop:PivotTo(Character:GetPivot() * CFrame.new(1.3, -2.7 + (Item_To_Drop.Handle.Size.Y/2), -1.3))

				for attribute, value in pairs(Our_Item:GetAttributes()) do
					Item_To_Drop:SetAttribute(attribute, value) -->> over-write/save
				end

				Our_Item:Remove() -->> take away our item
				Item_To_Drop.Parent = workspace -->> place on floor
			end
		end

		local Item_To_Grab = if itemsStuff:FindFirstChild(Item.Name) then itemsStuff:WaitForChild(Item.Name):Clone() else nil

		if Item_To_Grab then
			Player.Character:SetAttribute("Motion_Locked", true)
			Player.Character.PrimaryPart.Anchored = true
			
			for attribute, value in pairs(Item:GetAttributes()) do
				if attribute == "Grabbed" then continue end
				Item_To_Grab:SetAttribute(attribute, value)
			end

			Item:Remove()
			Item_To_Grab.Parent = Character

			Server_Tracks[Player].Grab:Play()--.2, 4, 1.8)
			Server_Tracks[Player].Grab:AdjustSpeed(1.5)
			Server_Tracks[Player].Grab.Stopped:Wait()
			
			--task.wait(0.5)

			Action.Value = "Nothing"
			Player.Character:SetAttribute("Motion_Locked", false)
			Player.Character.PrimaryPart.Anchored = false
		end
	else
		warn('Unknown Command:', COMMAND)
	end
end)