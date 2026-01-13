local Player : Player,RunService : RunService,MarketplaceService : MarketplaceService,ReplicatedStorage : ReplicatedStorage = game:GetService("Players").LocalPlayer,game:GetService("RunService"),game:GetService("MarketplaceService"),game:GetService("ReplicatedStorage")
local PlayerGui : PlayerGui = Player.PlayerGui

local Modules = {
	Data = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
}

local Game_Data = ReplicatedStorage:WaitForChild('Game_Data')

local Store_Data = Modules.Data:GetStore()
local ViewportDummys = workspace:WaitForChild("ViewportDummies")

local Prefabs = {
	["CharacterTemplate"] = script:WaitForChild("CharacterTemplate");
	["CosmeticTemplate"] = script:WaitForChild("CosmeticTemplate");
	["PerkTemplate"] = script:WaitForChild("PerkTemplate");
	['CurrencyTemplate'] = script:WaitForChild('CurrencyTemplate')
}


local module = {}

function GetDLCModule(DLC : string)
	
	-- Exceptions since roblox filters Psychopath on website --
	if string.match(DLC, "Psycho") then
		return Game_Data:WaitForChild('Killers'):WaitForChild('Psychopath')
	end
	
	for _, killer_module in pairs(Game_Data:WaitForChild('Killers'):GetChildren()) do
		
		if string.match(DLC, killer_module.Name) then
			return killer_module
		end
	end
end

function ApplyCosmetic(Dummy : Model, Asset_Id : number) : "Apply all since we are doing only sets right now"
	
	if Asset_Id == "" then
		return
	end
	
	local Asset_To_Clone = Modules.Data:GetAsset(Asset_Id) -- Returns Asset Folder
	
	if not Asset_To_Clone then return end
	
	-- load in accessories --
	for _, Body_Part : Folder in pairs(Asset_To_Clone:WaitForChild('Assets'):GetChildren()) do
		
		for _, Asset : Accessory in pairs(Body_Part:GetChildren()) do
			Asset:Clone().Parent = Dummy
		end
	end
	
	-- load in decals --
	--[[for _, Folder in pairs(Asset_To_Clone:WaitForChild('Assets'):GetChildren()) do
		warn('No method for loading in decals for:', Folder.Name)
	end]]
	
	-- reload/refresh dummy for viewport --
	local prior_parent = Dummy.Parent
	Dummy.Parent = workspace
	task.wait(.5)
	Dummy.Parent = prior_parent

end

function ApplyEmote(Dummy : Model, Info : "module script") : "Apply Emote to Dummy Rig"
	local Prior_Parent = Dummy.Parent
	local Target_Animator = Dummy:WaitForChild('Humanoid'):WaitForChild('Animator')
	local Animation_Instance = Instance.new('Animation', Target_Animator)
	Animation_Instance.AnimationId = Info.Emote_Asset
	
	Dummy.Parent = workspace
	
	local Target_Track = Target_Animator:LoadAnimation(Animation_Instance)

	Dummy.Parent = Prior_Parent
	
	Target_Track.Stopped:Connect(function() -->> inf loop
		Target_Track:Play()
	end)
	
	Target_Track:Play()
end

function module.ChangeSelected(Selected : StringValue)
	for _,v in pairs(script.Parent:WaitForChild("Navigator"):GetChildren()) do
		if v:IsA("TextButton") then
			if v.Name == Selected then
				v.BackgroundTransparency = 0.5
			else
				v.BackgroundTransparency = 1
			end
		end
	end
	
	for _,v in pairs(script.Parent:GetChildren()) do
		if (v:IsA("Frame") or v:IsA("ScrollingFrame")) and not (v.Name == "Navigator") then 
			if v.Name == Selected then
				v.Visible = true
			else
				v.Visible = false
			end
		end
	end
end

function module.ChangeCustomSelected(Selected : StringValue)
	for _,v in pairs(script.Parent:WaitForChild("Customization"):WaitForChild('Header'):GetChildren()) do
		if v:IsA("TextButton") then
			if v.Name == Selected then
				v.BackgroundTransparency = 0.5
			else
				v.BackgroundTransparency = 1
			end
		end
	end

	for _,v in pairs(script.Parent:WaitForChild('Customization'):GetChildren()) do
		if v.Name == 'Header' then continue end
		
		if (v:IsA("Frame") or v:IsA("ScrollingFrame")) then
			
			if v.Name == Selected then
				v.Visible = true
			else
				v.Visible = false
			end
		end
	end
end

local Number_Abbrev = {"K", "M", "B"}

function module.CreateCharacters()

	local function AbbrievateNumber(Amount : number) : string
		if Amount < 1000 then return Amount end -- return amount if not available for num abbrev
		local string_var = tostring(math.floor(Amount))

		return tonumber((string.sub(string_var, 1, ((#string_var + 2)%3) + 3))/100) .. Number_Abbrev[math.floor((#string_var-1)/3)]
	end
	
	for Killer_DLC, DLC_Info in pairs(Store_Data.Killers) do
		local killer_module = GetDLCModule(Killer_DLC)
		
		if not killer_module then warn("Could not find module:", Killer_DLC) continue end
		local True_Killer : string = killer_module.Name
		local Killer_Ownership : boolean = Modules.Data:OwnKiller(True_Killer)
		killer_module = require(killer_module)
		
		if not killer_module.Active then continue end --inactive game
		if killer_module.Testing and not Modules.Data:GetPermission("Testing") then continue end -- not a tester in testing mode
		
		local UiPrefab = Prefabs.CharacterTemplate:Clone()
		UiPrefab.Name = Killer_DLC
		UiPrefab:FindFirstChild("Name").Text = Killer_DLC
		UiPrefab:FindFirstChild("Info").Text = DLC_Info.Description
		UiPrefab:FindFirstChild("Image").Image = "rbxassetid://"..DLC_Info.Image
		UiPrefab.Parent = script.Parent:WaitForChild("Characters")

		if DLC_Info.Cost then
			UiPrefab.Robux.Text = DLC_Info.Cost.." ROBUX"
		else
			UiPrefab.Robux.Text = "OFFSALE"
			
			if not Killer_Ownership then
				DLC_Info.Purchased = false
			end
		end
		
		local events = {}
		
		if not DLC_Info.Purchased then -- have not bought

			if UiPrefab.Robux.Text ~= "OFFSALE" then
				
				events.Robux = UiPrefab:FindFirstChild("Robux").MouseButton1Click:Connect(function()
					UiPrefab.Robux.Active = false
					Modules.Data:Store_Purchase({
						Type = "Killer";
						Character = Killer_DLC;
					})

					UiPrefab.Robux.Text = "PROCESSING"

					task.delay(2,function() -- gives time for the game to process the purchase
						local Updated_Store = Modules.Data:GetStore().Killers[Killer_DLC]
						UiPrefab:FindFirstChild("Robux").Visible = not Updated_Store.Purchased

						if not UiPrefab:FindFirstChild("Robux").Visible then
							events.Robux:Disconnect()
							if events.Blood then events.Blood:Disconnect() events.Blood = nil end
						end

						if DLC_Info.Cost then
							UiPrefab.Robux.Text = DLC_Info.Cost.." ROBUX"
						else
							UiPrefab.Robux.Text = "OFFSALE"
						end

						UiPrefab.Robux.Active = true
					end)
				end)
			end
			
			if killer_module.Amount and not Killer_Ownership then
				UiPrefab.Blood.Text = AbbrievateNumber(killer_module.Amount).." BLOOD"
				
				events.Blood = UiPrefab:FindFirstChild("Blood").MouseButton1Click:Connect(function()
					UiPrefab.Blood.Active = false
					Modules.Data:Store_Purchase({
						Type = "Killer_Blood";
						Character = True_Killer;
					})

					UiPrefab.Blood.Text = "PROCESSING"

					task.delay(2,function() -- gives time for the game to process the purchase
						Killer_Ownership = Modules.Data:OwnKiller(True_Killer)
						UiPrefab:FindFirstChild("Blood").Visible = not Killer_Ownership

						if not UiPrefab:FindFirstChild("Blood").Visible then
							if events.Blood then events.Blood:Disconnect() events.Blood = nil end
						end

						UiPrefab.Blood.Text = AbbrievateNumber(killer_module.Amount).." BLOOD"
						UiPrefab.Blood.Active = true
					end)
				end)
			else -- not for purchase through blood
				UiPrefab:FindFirstChild("Blood").Visible = false
			end
		else -- bought the item already
			UiPrefab:FindFirstChild("Robux").Visible = false
			UiPrefab:FindFirstChild('Blood').Visible = false
		end
	end
end

function module.CreatePerks()

	for Perk_DLC, DLC_Info in pairs(Store_Data.DLC) do
		local UiPrefab = Prefabs.PerkTemplate:Clone()
		UiPrefab.Name = Perk_DLC
		UiPrefab:FindFirstChild("Name").Text = Perk_DLC
		UiPrefab:FindFirstChild("Info").Text = DLC_Info.Description
		UiPrefab:FindFirstChild("Image").Image = "rbxassetid://"..DLC_Info.Image
		UiPrefab.Parent = script.Parent:WaitForChild("Perks")

		UiPrefab:FindFirstChild("Button").Visible = not DLC_Info.Purchased

		if UiPrefab:FindFirstChild("Button").Visible then
			local event = UiPrefab:FindFirstChild("Button").MouseButton1Click

			event = event:Connect(function()
				UiPrefab.Button.Active = false

				Modules.Data:Store_Purchase({
					Type = "DLC";
					DLC = Perk_DLC;
				})
				
				UiPrefab.Button.Text = "PROCESSING"

				task.delay(3,function() -- gives time for the game to process the purchase
					local Updated_Store = Modules.Data:GetStore().DLC[Perk_DLC]
					UiPrefab:FindFirstChild("Button").Visible = not Updated_Store.Purchased

					if not UiPrefab:FindFirstChild("Button").Visible then
						event:Disconnect()
					end

					UiPrefab.Button.Text = "BUY"
					UiPrefab.Button.Active = true
				end)
			end)
		end
	end
end

function module.CreateCosmetics()

	local function Purchased_Set(Dict : "table") : boolean

		for body_part, purchase in pairs(Dict) do

			if not purchase then
				return false -- did not buy all
			end
		end

		return true -- bought all
	end

	for Cosmetic_Set, Info in pairs(Store_Data.Cosmetics) do
		if (not Info.Gamepass) and (Info.Store and not Info.Store.Set) then continue end -- skip over non-sets/passes


		local UiPrefab = Prefabs.CosmeticTemplate:Clone()

		local ViewportCamera = Instance.new("Camera", script)
		ViewportCamera.Name = Cosmetic_Set

		local Viewport = UiPrefab:WaitForChild("Viewport")
		Viewport.CurrentCamera = ViewportCamera

		local ClientViewportDummy = ViewportDummys['Character']:Clone()
		ClientViewportDummy.Parent = Viewport

		-- apply cosmetic to dummy --
		ApplyCosmetic(ClientViewportDummy, Info.Information.Asset)

		local Angle = 0
		RunService.Heartbeat:Connect(function() -- rotates dummy (remove or find a better way)
			Angle += 2
			ViewportCamera.CFrame = CFrame.new(((ClientViewportDummy:GetPivot() * CFrame.Angles(0, math.rad(Angle), 0)) * CFrame.new(-8.5, 4.5, 0)).Position, ClientViewportDummy:GetPivot().Position)
		end)

		UiPrefab.Name = Cosmetic_Set
		UiPrefab:FindFirstChild("Name").Text = Cosmetic_Set
		UiPrefab:FindFirstChild("Info").Text = Info.Information.Description -- description
		UiPrefab:WaitForChild('Button'):FindFirstChild("Price").Text = Info.Store.Set -- only selling sets rn
		UiPrefab.Parent = script.Parent:WaitForChild('Customization'):WaitForChild("Cosmetics")

		UiPrefab:FindFirstChild("Button").Visible = not Purchased_Set(Info.Information.Purchased)
		-- gonna add buy w/ robux button
		--print(Info)

		if Info.Gamepass then
			UiPrefab:WaitForChild('Robux_Button'):FindFirstChild("Price").Text = "Unknown" -- only selling sets rn
			-- do gamepass stuff
		else
			UiPrefab:WaitForChild('Robux_Button').Visible = false -- disable robux button
		end

		if UiPrefab:FindFirstChild("Button").Visible then
			local event = UiPrefab:FindFirstChild("Button").MouseButton1Click

			event = event:Connect(function()
				UiPrefab.Button.Active = false

				--print(Store_Data.Cosmetics, 'ORIGINAL')

				Modules.Data:Store_Purchase({
					Type = "Cosmetic";
					Cosmetic = Cosmetic_Set;
					Team = Info.Information.Team;
					Content = {"Set"}; -- which body parts or part to buy
				})

				UiPrefab.Button.Text = "PROCESSING"
				task.delay(3,function() -- gives time for the game to process the purchase
					local Updated_Store = Modules.Data:GetStore().Cosmetics[Cosmetic_Set]
					UiPrefab:FindFirstChild("Button").Visible = not Purchased_Set(Updated_Store.Information.Purchased)

					if not UiPrefab:FindFirstChild("Button").Visible then
						event:Disconnect()
					end

					UiPrefab.Button.Text = "BUY"
					UiPrefab.Button.Active = true
				end)
			end)
		end
	end
end

function module.CreateEmotes()
	--print('creating emotes...')
	

	for _, Info in pairs(Game_Data:WaitForChild('Emotes'):GetChildren()) do
		if not Info:IsA('ModuleScript') then continue end
		Info = require(Info)
		
		if Info.Unlocked or not Info.Active then continue end -- not available or unlocked by default
		if not Info.Cost then continue end -- no price attached!
		
		local UiPrefab = Prefabs.CosmeticTemplate:Clone()

		local ViewportCamera = Instance.new("Camera", script)
		ViewportCamera.Name = Info.Data_Name

		local Viewport = UiPrefab:WaitForChild("Viewport")
		Viewport.CurrentCamera = ViewportCamera
		
		local World_Model = Instance.new('WorldModel', Viewport)

		local ClientViewportDummy = ViewportDummys['Character']:Clone()
		ClientViewportDummy.Parent = World_Model
		
		ViewportCamera.CFrame = CFrame.new(((ClientViewportDummy:GetPivot() * CFrame.Angles(0, math.rad(-90), 0)) * CFrame.new(-8.5, 4.5, 0)).Position, ClientViewportDummy:GetPivot().Position)
		
		--TODO: apply emote to dummy --
		ApplyEmote(ClientViewportDummy, Info)

		UiPrefab.Name = Info.Data_Name
		UiPrefab:FindFirstChild("Name").Text = Info.Emote_Name
		UiPrefab:FindFirstChild("Info").Text = Info.Description -- description
		UiPrefab:WaitForChild('Button'):FindFirstChild("Price").Text = Info.Cost -- only selling sets rn
		UiPrefab.Parent = script.Parent:WaitForChild('Customization'):WaitForChild("Emotes")

		--TODO: CHECK IF PURCHASED!
		UiPrefab:FindFirstChild("Button").Visible = true -- not Purchased_Set(Info.Information.Purchased)
		UiPrefab:WaitForChild('Robux_Button').Visible = false -- disable robux button
		

		if UiPrefab:FindFirstChild("Button").Visible then
			local event = UiPrefab:FindFirstChild("Button").MouseButton1Click

			event = event:Connect(function()
				UiPrefab.Button.Active = false

				Modules.Data:Store_Purchase({
					Type = "Emote";
					Emote = Info.Data_Name;
				})

				UiPrefab.Button.Text = "PROCESSING"
				task.delay(3,function() -- gives time for the game to process the purchase
					--local Updated_Store = Modules.Data:GetStore().Cosmetics[Cosmetic_Set]
					UiPrefab:FindFirstChild("Button").Visible = true -- not Purchased_Set(Updated_Store.Information.Purchased)

					if not UiPrefab:FindFirstChild("Button").Visible then
						event:Disconnect()
					end

					UiPrefab.Button.Text = "BUY"
					UiPrefab.Button.Active = true
				end)
			end)
		end
	end
end

function module.CreateCustomization()
	module.CreateCosmetics()
	module.CreateEmotes()
end

function module.CreateCurrency()
	local sort = {}
	
	for name, data in pairs(Store_Data.Currency) do
		table.insert(sort, {name, data})
	end
	
	table.sort(sort, function(a, b)
		return a[2].Price < b[2].Price
	end)
	
	for product_title, Info in pairs(sort) do
		product_title, Info = Info[1], Info[2]
		if (not Info.Price) then continue end -- skip over non-sets/passes
		local UiPrefab = Prefabs.CurrencyTemplate:Clone()
		
		UiPrefab.Name = product_title
		UiPrefab:FindFirstChild("Name").Text = product_title
		UiPrefab:WaitForChild('Button').Text = "Buy for "..Info.Price..' robux' -- only selling sets rn
		UiPrefab.Parent = script.Parent:WaitForChild("Currency")
		UiPrefab:FindFirstChild("Button").Visible = true

		if UiPrefab:FindFirstChild("Button").Visible then
			local event = UiPrefab:FindFirstChild("Button").MouseButton1Click

			event = event:Connect(function()
				UiPrefab.Button.Active = false

				Modules.Data:Store_Purchase({
					Type = "Product";
					Product = Info.ProductID;
				})

				UiPrefab.Button.Text = "PROCESSING"
				task.delay(3,function() -- gives time for the game to process the purchase
					UiPrefab:WaitForChild('Button').Text = "Buy for "..Info.Price..' robux' -- only selling sets rn
					UiPrefab.Button.Active = true
				end)
			end)
		end
	end
end

return module
