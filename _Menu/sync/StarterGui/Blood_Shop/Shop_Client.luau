local ReplicatedStorage : ReplicatedStorage, TweenService : TweenService = game:GetService('ReplicatedStorage'), game:GetService("TweenService")

local data_module, hover_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')), require(game.Players.LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('HUD'):WaitForChild('Hover_Module'))
local Game_Data = ReplicatedStorage:WaitForChild('Game_Data')

local Blood_Shop_UI = game.Players.LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('Blood_Shop')

local Shop = {
	Connections = {};
}

function Shop:CleanShop(SHOP : Frame) : "Clean out Shop Frame and disconnect Connections"

	for connection, signal in pairs(Shop.Connections) do -- save memory by undoing connections --
		Shop.Connections[connection]:Disconnect() Shop.Connections[connection] = nil
	end

	for _, row in pairs(SHOP:GetChildren()) do
		if row:IsA('UIAspectRatioConstraint') then continue end -- do not remove constraint
		row:Remove()
	end
	
	Blood_Shop_UI:WaitForChild('Shops'):WaitForChild('Killer').Visible = false
	Blood_Shop_UI:WaitForChild('Shops'):WaitForChild('Survivor').Visible = false
end


function Shop:Update(Side : "Survivor" | "Killer")
	local current_shop, invokeDebounce = nil, false
	local shop_data = data_module:GetShop(Side) -- update the data --
	local current_inventory =  data_module:GetInventory(Side) -- faster-ui-processing by storing here --
	
	if Side == "Survivor" then
		current_shop = Blood_Shop_UI:WaitForChild('Shops'):WaitForChild('Survivor')
	else
		current_shop = Blood_Shop_UI:WaitForChild('Shops'):WaitForChild('Killer')
	end

	Shop:CleanShop(current_shop)
	
	-- Craft Contents --
	for row, row_data in pairs(shop_data.Data) do
		local raw_y = string.gsub(row, "Row", '')
		raw_y = tonumber(raw_y)
		
		-- Clone Row --
		local New_Row = Blood_Shop_UI:WaitForChild('Shops'):WaitForChild('Prefab'):WaitForChild('Row'):Clone()
		New_Row.Name = row
		New_Row.Parent = current_shop

		New_Row.Position = UDim2.new(0.5,0, ((raw_y - 1) * .2), 0)

		for slot, slot_data in pairs(row_data) do
			local raw_x = string.gsub(slot, "Slot", '')
			raw_x = tonumber(raw_x)
			
			local New_Slot = Blood_Shop_UI:WaitForChild('Shops'):WaitForChild('Prefab'):WaitForChild('Slot'):Clone()
			New_Slot.Name = slot
			New_Slot.Visible = true
			New_Slot.Parent = New_Row

			if slot_data.Purchased or raw_y < shop_data.Row then -- blackout purchased or unavailable rows
				New_Slot:WaitForChild('Visual').Visible = false
				continue -- darkens and skips
			end
			
			local game_module = Game_Data:WaitForChild(slot_data.Catagory)
			local desired_tier = nil

			if game_module:FindFirstChild(Side) then
				game_module = game_module:WaitForChild(Side)
			end
			
			local SlotData_Name = slot_data.Name

			if not game_module:FindFirstChild(slot_data.Name) then
				SlotData_Name = string.sub(slot_data.Name,1,#slot_data.Name - 1)
				game_module = game_module:FindFirstChild(SlotData_Name) 
			else
				game_module = game_module:FindFirstChild(slot_data.Name) 
			end

			if game_module then
				game_module = require(game_module)
				
				New_Slot:WaitForChild('Visual'):WaitForChild('Label').Image = game_module.Image -- display image
				
				Shop.Connections[row..'_'..slot..'Hover_Enter'] = New_Slot:WaitForChild('Purchase').MouseEnter:Connect(function()
					hover_module:Display(slot_data.Catagory, game_module, desired_tier)
				end)

				Shop.Connections[row..'_'..slot..'Hover_Leave'] = New_Slot:WaitForChild('Purchase').MouseLeave:Connect(function()
					hover_module:Hide()
				end)
				
				if slot_data.Catagory == "Perks" then
					desired_tier = current_inventory.Perks[SlotData_Name] + 1 --TODO: Speed this up somehow...

					New_Slot:WaitForChild('Visual'):WaitForChild('Cost').Text = game_module.Cost[desired_tier] -- display price
					
					if raw_y == shop_data.Row then -- proper color
						New_Slot:WaitForChild('Visual').BackgroundColor3 = game_module.Colors[desired_tier] -- display color
					else -- gray out
						New_Slot:WaitForChild('Visual').BackgroundColor3 = Color3.fromRGB(95, 95, 95) -- display color
					end
				else
					New_Slot:WaitForChild('Visual'):WaitForChild('Cost').Text = game_module.Cost -- display price
					
					if raw_y == shop_data.Row then -- proper color
						New_Slot:WaitForChild('Visual').BackgroundColor3 = game_module.Color -- display color
						New_Slot:WaitForChild('Visual'):WaitForChild('Label').ImageColor3 = Color3.fromRGB(255, 255 ,255)
						New_Slot:WaitForChild('Visual'):WaitForChild('Cost').TextColor3 = Color3.fromRGB(255, 0, 0)
					else -- gray out
						New_Slot:WaitForChild('Visual').BackgroundColor3 = Color3.fromRGB(95, 95, 95) -- display color
						New_Slot:WaitForChild('Visual'):WaitForChild('Label').ImageColor3 = Color3.fromRGB(39, 39, 39)
						New_Slot:WaitForChild('Visual'):WaitForChild('Cost').TextColor3 = Color3.fromRGB(52, 0, 0)
					end
				end
				
				if raw_y == shop_data.Row then -- save memory by only forming click connections for purchasable

					Shop.Connections[row..'_'..slot] = New_Slot:WaitForChild('Purchase').MouseButton1Click:Connect(function()
						if invokeDebounce then return end -- cancel out multiple request --
						invokeDebounce = true
						
						local success = data_module:Game_Purchase(Side, raw_y..'_'..raw_x)
						
						if success then
							script:WaitForChild('Buy'):Play()
							Shop:Update(Side)
							hover_module:Hide()	
						end
						
						invokeDebounce = false
					end)
				elseif raw_y == 5 and not slot_data.Purchased then -- this slot is the max row and is unpurchased
					
					Shop.Connections[row..'_'..slot] = New_Slot:WaitForChild('Purchase').MouseButton1Click:Connect(function()
						if invokeDebounce then return end -- cancel out multiple request --
						invokeDebounce = true

						local success = data_module:Game_Purchase(Side, raw_y..'_'..raw_x)

						if success then
							script:WaitForChild('Buy'):Play()
							Shop:Update(Side)
						end

						invokeDebounce = false
					end)
				end

			else
				error(SlotData_Name..' : did not load into the shop, because it could not be found in game data!')
			end
		end
	end
	
	-- make visible --
	for _, row in pairs(current_shop:GetChildren()) do
		if row:IsA('UIAspectRatioConstraint') then continue end
		row.Visible = true
	end

	current_shop.Visible = true

	if data_module:GetLevel(Side) >= 50 and data_module:GetPrestige(Side) < 3 then
		Blood_Shop_UI:WaitForChild('Shops'):WaitForChild('Prestige').Visible = true

		Shop.Connections['PRESTIGE'] = Blood_Shop_UI:WaitForChild('Shops'):WaitForChild('Prestige'):WaitForChild('Confirm').MouseButton1Click:Connect(function()
			if invokeDebounce then return end -- cancel out multiple request --
			invokeDebounce = true

			local sucess = data_module:Prestige(Side)

			if sucess then
				Shop:Update(Side)
			end

			invokeDebounce = false
		end)
	else
		Blood_Shop_UI:WaitForChild('Shops'):WaitForChild('Prestige').Visible = false
	end
end

return Shop
