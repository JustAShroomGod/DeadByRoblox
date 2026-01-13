local AnimationInfo = require(script:WaitForChild("AnimationInfo"))

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local Killer_Spawn_CFrame = CFrame.new(-4.79831457, 115.690002, -34.0858994, -0.999997854, 0, 0.00209999969, 0, 1, 0, -0.00209999969, 0, -0.999997854)

player:WaitForChild("Data")

local tween = {}
local signal = {}
local var = {}
local ram = {}

function TweenIn(ind)
	local part = workspace.SSCamPos 

	if ind == 1 then
		part = workspace.KKCamPos
	elseif ind == 2 then
		part = workspace.SSCamPos
	elseif ind == 3 then
		part = workspace.SWFCamPos
	elseif ind == 4 then
		part = {
			--CFrame = Leaderboard_CFrame;
		}
	end

	local tween = game:GetService("TweenService"):Create(workspace.CurrentCamera, TweenInfo.new(0.8), {
		CFrame = part.CFrame
	})
	tween:Play()
end

function TweenOut()
	local tween = game:GetService("TweenService"):Create(workspace.CurrentCamera, TweenInfo.new(0.8), {
		CFrame = workspace.Points:WaitForChild(2).CFrame
	})
	tween:Play()
end


function spawnEffect ()
	for h = 1,7 do
		for r = 1, 4 do
			for depth = 1, 2  do
				spawn(function()
					local part = Instance.new("Part", workspace.CurrentCamera) part.Color = Color3.fromRGB(0, 0, 0)
					part.Anchored = true part.CanCollide = false part.Material = "Neon" local rSize = math.random(20,50)/100 
					local baseSize = Vector3.new(rSize, rSize, rSize) part.Size = Vector3.new(0.05, 0.05, 0.05)
					part.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, -player.Character.HumanoidRootPart.Size.Y*1.6, 0)
					part.CFrame = part.CFrame * CFrame.Angles(0,math.rad(360/5 * r),0)
					part.CFrame = part.CFrame * CFrame.new(0, h, -1.3/depth) part.CFrame = part.CFrame * CFrame.Angles(math.rad(math.random(45,90)), math.rad(math.random(45,90)), math.rad(math.random(45,90)))
					part.Transparency = 1
					local tween = game:GetService("TweenService"):Create(part, TweenInfo.new(0.15), {["Transparency"] = 0, ["Size"] = baseSize}) tween:Play()
					local tweenCon tweenCon = tween.Completed:Connect(function()
						local tween = game:GetService("TweenService"):Create(part, TweenInfo.new(0.15), {["Transparency"] = 1, ["Size"] = Vector3.new(0.05, 0.05, 0.05)}) tween:Play()
						tweenCon = tween.Completed:Connect(function()
							part:Destroy()
							tweenCon:Disconnect()
						end)
					end) 

				end)
			end
		end
	end
end

local humanoid_settings = { 
	Survivor = {
		BodyDepthScale = 0.78
		,BodyHeightScale = 1.2
		,BodyProportionScale = 0
		,BodyTypeScale = 0
		,BodyWidthScale = 0.75
		,HeadScale = 0.88
	}
	,Killer = {
		BodyDepthScale = 0.9
		,BodyHeightScale = 1.52
		,BodyProportionScale = 0
		,BodyTypeScale = 0
		,BodyWidthScale = 0.95
		,HeadScale = 1.2
	} 
} 

local function update_size(mode)
	local unit = 1

	if mode == "Menu" then
		unit = 1.78

		mode = "Killer"
	end

	for name, value in pairs(humanoid_settings[mode]) do
		local object = player.Character.Humanoid:FindFirstChild(name)

		if object then
			object.Value = value*unit
		else
			local object = Instance.new("NumberValue", player.Character.Humanoid)
			object.Name = name
			object.Value = value*unit
		end 
	end	
end

local previous = {}

local function read()
	local new = {}

	if script.SWF.Value then
		new.context = "SWF"
	else
		--[[if player.PlayerGui.PreMS.Enabled then
			new.context = "Survivor"
			new.item = player.Data.Loadout.Item.Value
		elseif player.PlayerGui.PreMK.Enabled then
			new.context = "Killer"
			new.character = player.Data.Loadout.Killer.Value
		elseif player.PlayerGui.Leaderboard.Enabled then
			new.context = "Leaderboard"
		else 
			new.context = "Menu"
		end]]
		new.context = "Menu"
		
	end

	return new
end

-- Deals with item --

local function update()
	local new = read()

	if new.context == previous.context 
		and new.character == previous.character 
		and new.item == previous.item then return end

	--	warn("-------NEW-------")
	--	warn("context =", new.context)
	--	warn("character =", new.character)
	--	warn("item =", new.item)
	--	warn("-----------------")

	if new.context == "SWF" then
		TweenIn(3)
	elseif new.context == "Survivor" then
		AnimationInfo.PlayAnimation(new.context)
		update_size(new.context)

		for _, object in pairs (game.ReplicatedStorage.KillerStuff:GetChildren()) do 
			local my_object = player.Character:FindFirstChild(object.Name)

			if my_object then 
				my_object:Destroy() 
			end 
		end

		local list = {
			"FirstAidKit",
			"WornOutTools",
			"SaboTools",
			"FlashLight",
			"GreenFlashLight",
			"PurpleFlashLight",
			"EventFlashLight",
			"EventFirstAidKit",
			"EventTools",
			"IredescentFlashLight",
			"RedFireCracker",
			"FireCracker",
		}

		for _, item_name in pairs (list) do
			local model = player.Character:FindFirstChild(item_name)

			if player.Data.Loadout.Item.Value == item_name then
				if not model then
					model = game:GetService("ReplicatedStorage"):FindFirstChild("Items"):FindFirstChild(item_name):Clone()
					model.Parent = player.Backpack
					model.Parent = player.Character

					local my_script = model:FindFirstChildOfClass("LocalScript")

					if my_script then
						my_script.Disabled = false
					end
				end
			else
				if model then
					model:Destroy()
				end
			end
		end

		TweenIn(2)

		char.LowerTorso.CFrame = workspace.SurvivorSpawn.CFrame
		char.HumanoidRootPart.Anchored = true

		--SetCharVis() 
	elseif new.context == "Killer" then
		local killer_character = player.Data.Loadout.Killer

		AnimationInfo.PlayAnimation(new.context,killer_character.Value)
		update_size(new.context)

		TweenIn(1) 

		for v0, object in pairs (game.ReplicatedStorage.KillerStuff:GetChildren()) do
			local my_object = player.Character:FindFirstChild(object.Name)

			if object.Name == player.Data.Loadout.Killer.Value then
				if my_object then
					my_object:Destroy()
					my_object = nil
				end

				if not my_object then
					local copy = object:Clone()
					
					if copy:FindFirstChildOfClass("LocalScript") then
						copy:FindFirstChildOfClass("LocalScript").Disabled = false
					end
					
					copy.Parent = char
				end
			else
				if my_object then
					my_object:Destroy()
				end
			end
		end

		char.LowerTorso.CFrame = workspace.KillerPos.CFrame
		char.HumanoidRootPart.Anchored = true
	elseif new.context == "Menu" then
		update_size(new.context)

		--SetCharInv()
		TweenOut()
		AnimationInfo.PlayAnimation(new.context)
		local list = {
			"FirstAidKit",
			"WornOutTools",
			"SaboTools",
			"FlashLight",
			"GreenFlashLight",
			"PurpleFlashLight",
			"EventFlashLight",
			"EventFirstAidKit",
			"EventTools",
			"IredescentFlashLight",
			"RedFireCracker",
			"FireCracker",
		}


		for _, item_name in pairs (list) do
			local model = player.Character:FindFirstChild(item_name)

			if model then
				model:Destroy()
			end
		end

		for _, object in pairs (game.ReplicatedStorage.KillerStuff:GetChildren()) do
			local my_object = player.Character:FindFirstChild(object.Name)

			if object.Name == player.Data.Loadout.Killer.Value then
				if not my_object then
					local copy = object:Clone()
					copy.Parent = char
					
					if copy:FindFirstChildOfClass("LocalScript") then
						copy:FindFirstChildOfClass("LocalScript").Disabled = false 
					end

					--	local value = Instance.new("ObjectValue", copy) 
					--	value.Name = "Big"
				end
			else
				if my_object then
					my_object:Destroy()
				end
			end
		end

		char.LowerTorso.CFrame = Killer_Spawn_CFrame
		char.HumanoidRootPart.Anchored = true
	end

	previous = new
end

local list = {
	script.CutScene;
	player.PlayerGui:WaitForChild("Survivor_Screen");
	player.PlayerGui:WaitForChild("Killer_Screen");
	player.PlayerGui:WaitForChild("ChooseBand");
	script.KYF;
	player.Data.Loadout:WaitForChild('Item');
	player.Data.Loadout:WaitForChild('Killer');
}

player.Character:WaitForChild("HumanoidRootPart")
player.Character:WaitForChild("LowerTorso")

update()

--repeat wait() until player.PlayerGui.Ready.Value == true

for _, child in pairs (list) do
	child.Changed:Connect(function()
		update()
	end)
end
