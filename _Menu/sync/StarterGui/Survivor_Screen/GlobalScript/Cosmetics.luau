local ReplicatedStorage, RunService = game:GetService('ReplicatedStorage'), game:GetService("RunService")

local ModuleStorage, Game_Data = ReplicatedStorage:WaitForChild('Modules'), ReplicatedStorage:WaitForChild('Game_Data')

local Player = game.Players.LocalPlayer

local Custom_Frame = script.Parent.Parent:WaitForChild('Content'):WaitForChild('Cosmetics')
local Modules = {
	Data = require(ModuleStorage:WaitForChild('Data'));
	Hover = require(Player:WaitForChild('PlayerGui'):WaitForChild('HUD'):WaitForChild('Hover_Module'));
	CosmeticsModule = require(ModuleStorage:WaitForChild("Cosmetics"))
}

local UI = {
	CosmeticTemplate = Custom_Frame:WaitForChild("Templates"):WaitForChild("CosmeticTemplate");
	
	SkinButton = Custom_Frame:WaitForChild("Design"):WaitForChild("Option1");
	EmotesButton = Custom_Frame:WaitForChild("Design"):WaitForChild("Option2")
}

local Handler = {
	Store_Data = Modules.Data:GetStore();
	ViewportDummies = workspace:FindFirstChild("ViewportDummies");
	
	Selected = "Skins"
}


function ApplyCosmetic(Dummy : Model, Cosmetic : string) : "Apply all since we are doing only sets right now"
	Modules.CosmeticsModule.ApplyCosmetic(Dummy, Cosmetic, "Survivor")
	
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

function Handler.ChangeSelected()
	if Handler.Selected == "Skins" then
		Custom_Frame:WaitForChild("Emotes").Visible = true
		Custom_Frame:WaitForChild("Skins").Visible = false
		
		Handler.Selected = "Emotes"
	else
		Custom_Frame:WaitForChild("Emotes").Visible = false
		Custom_Frame:WaitForChild("Skins").Visible = true
		
		Handler.Selected = "Skins"
	end
end

function Handler.CreateCosmetics()

	local function Purchased_Set(Dict : "table") : boolean

		for body_part, purchase in pairs(Dict) do

			if not purchase then
				return false -- did not buy all
			end
		end

		return true -- bought all
	end

	for Cosmetic_Set, Info in pairs(Handler.Store_Data.Cosmetics) do
		if (not Info.Gamepass) and (Info.Store and not Info.Store.Set) then continue end -- skip over non-sets/passes
		if not (Info.Information.Team == "Survivor") then continue end
		if Custom_Frame:FindFirstChild("Skins"):FindFirstChild(Cosmetic_Set) then continue end
		
		local UiPrefab = UI.CosmeticTemplate:Clone()

		local ViewportCamera = Instance.new("Camera", script)
		ViewportCamera.Name = Cosmetic_Set

		local Viewport = UiPrefab:WaitForChild("Viewport")
		Viewport.CurrentCamera = ViewportCamera

		local ClientViewportDummy = Handler.ViewportDummies['Character']:Clone()
		ClientViewportDummy.Parent = workspace
		
		-- apply cosmetic to dummy --
		ApplyCosmetic(ClientViewportDummy, Cosmetic_Set)
		ClientViewportDummy.Parent = Viewport

		local Angle = 0
		RunService.Heartbeat:Connect(function() -- rotates dummy (remove or find a better way)
			Angle += 2
			ViewportCamera.CFrame = CFrame.new(((ClientViewportDummy:GetPivot() * CFrame.Angles(0, math.rad(Angle), 0)) * CFrame.new(-8.5, 4.5, 0)).Position, ClientViewportDummy:GetPivot().Position)
		end)

		UiPrefab.Name = Cosmetic_Set
		UiPrefab:FindFirstChild("Name").Text = Cosmetic_Set
		UiPrefab:FindFirstChild("Info").Text = Info.Information.Description -- description
		UiPrefab:WaitForChild('Button'):FindFirstChild("Price").Text = Info.Store.Set -- only selling sets rn
		UiPrefab.Parent = Custom_Frame:WaitForChild("Skins")

		UiPrefab:FindFirstChild("Button").Visible = not Purchased_Set(Info.Information.Purchased)

		UiPrefab.Visible = true


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

function Handler.CreateEmotes()
	for _, Info in pairs(Game_Data:WaitForChild('Emotes'):GetChildren()) do
		if not Info:IsA('ModuleScript') then continue end
		Info = require(Info)

		if Info.Unlocked or not Info.Active then continue end -- not available or unlocked by default
		if not Info.Cost then continue end -- no price attached!

		local UiPrefab = UI.CosmeticTemplate:Clone()

		local ViewportCamera = Instance.new("Camera", script)
		ViewportCamera.Name = Info.Data_Name

		local Viewport = UiPrefab:WaitForChild("Viewport")
		Viewport.CurrentCamera = ViewportCamera

		local World_Model = Instance.new('WorldModel', Viewport)

		local ClientViewportDummy = Handler.ViewportDummies['Character']:Clone()
		ClientViewportDummy.Parent = World_Model

		ViewportCamera.CFrame = CFrame.new(((ClientViewportDummy:GetPivot() * CFrame.Angles(0, math.rad(-90), 0)) * CFrame.new(-8.5, 4.5, 0)).Position, ClientViewportDummy:GetPivot().Position)

		--TODO: apply emote to dummy --
		ApplyEmote(ClientViewportDummy, Info)

		UiPrefab.Name = Info.Data_Name
		UiPrefab:FindFirstChild("Name").Text = Info.Emote_Name
		UiPrefab:FindFirstChild("Info").Text = Info.Description -- description
		UiPrefab:WaitForChild('Button'):FindFirstChild("Price").Text = Info.Cost -- only selling sets rn
		UiPrefab.Parent = Custom_Frame:WaitForChild("Emotes")

		UiPrefab:FindFirstChild("Button").Visible = not Handler.Store_Data.Emotes[Info.Data_Name].Information.Purchased


		UiPrefab.Visible = true

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
					warn(Modules.Data:GetStore())
					UiPrefab:FindFirstChild("Button").Visible = not Modules.Data:GetStore().Emotes[Info.Data_Name].Information.Purchased

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


function Handler.Create()
	Handler.CreateCosmetics()
	Handler.CreateEmotes()
	
	UI.SkinButton.MouseButton1Click:Connect(Handler.ChangeSelected)
	UI.EmotesButton.MouseButton1Click:Connect(Handler.ChangeSelected)
end

return Handler
