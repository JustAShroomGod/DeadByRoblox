local Game_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data')
local Item_Data = Game_Data:WaitForChild('Items')
local Code = require(game.ReplicatedStorage.Modules.Code)

humanoid = script.Parent.Parent:WaitForChild("Humanoid")

using = script.Parent:WaitForChild("Using")
state = script.Parent:WaitForChild("State")
progress = script.Parent:WaitForChild("Progress")

item_pos = script.Parent.Parent:WaitForChild("ItemPos")

prefix = "http://www.roblox.com/Asset?ID="

openningAnim = Instance.new("Animation")
openningAnim.Name = "OpenningAnim"
openningAnim.AnimationId = prefix.. "15072078329"

openAnim = Instance.new("Animation")
openAnim.Name = "OpenAnim"
openAnim.AnimationId = prefix.. "http://www.roblox.com/Asset?ID=15072098070"

closingAnim = Instance.new("Animation")
closingAnim.Name = "ClosingAnim"
closingAnim.AnimationId = prefix.. "15072102052"

animTrack = nil
local lastuser = nil -- the user of the chest and reciever of the item

--Settings you can change--
local increaseSpeed = 20 -- Chest Searching Speed --

local Items = {}

--Settings you can change--

for _, item in pairs(game:GetService('ServerStorage'):WaitForChild('TemplateObjects'):WaitForChild('DropItems'):GetChildren()) do
	local item_mod = Item_Data:FindFirstChild(item.Name)
	
	if item_mod then
		item_mod = require(item_mod)
		
		if item_mod.Active and not item_mod.Testing and item_mod.Loot_Chance > 0 then
			table.insert(Items, {
				item, -- raw item
				item_mod -- module
			})
		end
	end
end

--print(Items)

function giveItem() -- function go give the items
	--[[spawn(function()
		print("LASTUSER:".. lastuser.Name)
	end) ]]

	if lastuser then -- last user found
		local char = lastuser.Character -- obtaining last user's character
		--print(char)
		if char then -- it there is a character procede
			local randomItem = nil
			local spin = math.random(1, 8000)/10
			--print(spin)
			repeat task.wait()
				randomItem = Items[math.random(1, #Items)]
			until randomItem[2].Loot_Chance >= spin
			--print("ITEM SPAWN")
			local newObject = randomItem[1]:Clone()
			--print("CLONE")
			local newObjectHandle = newObject:WaitForChild("Handle")
			--print("FOUND")
			newObjectHandle.Anchored = true
			--print("ANCHOR")
			newObject:PivotTo(item_pos.CFrame)
			--print("CFRAME_SET")
			newObject.Parent = workspace
			--print("WORKSPACE")
		end
	end
end

function increaseEvent()
	repeat task.wait(0.2)
		
		if progress.Value < 1000 and lastuser then -- adds progress if below 100 and we have a lastuser
			
			local player = game.Players:FindFirstChild(using.Value)
			
			if (player == nil) then
				return
			end
			
			local Current_Rate = increaseSpeed * Code:GetPlayerValue(player, "ActionSpeed")
			
			if workspace:GetAttribute("Loot_Goblin") then
				Current_Rate -= (Current_Rate * (require(Game_Data:WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Loot Goblin')).Tiers[workspace:GetAttribute("Loot_Goblin")]/100))/2
			end

			--connection = game:GetService("RunService").Heartbeat:Connect(function()
			--if progress.Value < 1000 then
				progress.Value +=  Current_Rate
				--end
			--end)
		else
			if lastuser then
				giveItem()
			end
			
			if connection then
				connection = nil
			end
		end
	until connection == nil
end

using.Changed:Connect(function()
	local stoppedCon
	local player = game.Players:FindFirstChild(using.Value)

	if player and player.Character then  -- we have player and player's character	
		player.Character:SetAttribute("CurrentInteractable", script.Parent.Parent.Name)

		lastuser = player -- sets the lastuser
		connection = true -- makes the connections for toolbox progression
		
		spawn(increaseEvent) -- makes the increasing of toolbox w/out interrupting script

		if animTrack == nil and state.Value == "Closed" then
			
			if progress.Value < 1000 then -- Handles the animations
				
				animTrack = humanoid.Animator:LoadAnimation(openningAnim)
				animTrack:Play()
				animTrack:AdjustSpeed(0.4)
				
				stoppedCon = animTrack.Stopped:Connect(function() -- stopped connection function
					if state.Value == "Closing" or state.Value == "Closed" then return end

					state.Value = "Open"

					animTrack = humanoid.Animator:LoadAnimation(openAnim)
					animTrack:Play()
					animTrack:AdjustSpeed(1)

					stoppedCon:Disconnect()
					stoppedCon = nil
				end)
				
				return
			end
		end
	else

		if connection then -- disabled our connection if it exist
			connection = nil
			
			lastuser.Character:SetAttribute("CurrentInteractable", "")
		end

		if animTrack then
			
			if animTrack.Animation.Name == "OpenAnim"
				or animTrack.Animation.Name == "OpenningAnim" then
				
				if progress.Value < 1000 then
					
					state.Value = "Closing"
					animTrack:Stop()
					
					animTrack = humanoid.Animator:LoadAnimation(closingAnim)
					animTrack:Play()

					local stoppedCon2 stoppedCon2 = animTrack.Stopped:Connect(function()
						
						state.Value = "Closed"
						
						if stoppedCon2 then
							stoppedCon2:Disconnect()
							stoppedCon2 = nil
						end
						
						animTrack = nil
					end)
				end
			end
		end
	end
end)