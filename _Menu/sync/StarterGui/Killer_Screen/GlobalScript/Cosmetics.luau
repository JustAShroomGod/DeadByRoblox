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
}

local Handler = {
	Store_Data = Modules.Data:GetStore();
	ViewportDummies = workspace:FindFirstChild("ViewportDummies");
}

local TempData = { --TODO work on making dummies work + resolving this possible memory leak
	Dummies = {};
	Frames = {};
	Cameras = {}
}

local function Clean()
	for _,v in pairs(Custom_Frame:WaitForChild("Skins"):GetChildren()) do
		if v:IsA("UIListLayout") then continue end
		
		v:Destroy()
	end
	
	--[[for _, Frame in pairs(TempData.Dummies) do
		Frame:Destroy()
	end
	
	for _, Frame in pairs(TempData.Frames) do
		Frame:Destroy()
	end
	
	for _, Frame in pairs(TempData.Cameras) do
		Frame:Destroy()
	end]]
end

function ApplyCosmetic(Dummy : Model, Cosmetic : string, SelectedKiller : string) : "Apply all since we are doing only sets right now"
	Modules.CosmeticsModule.ApplyCosmetic(Dummy, Cosmetic, "Killer", SelectedKiller)

	local prior_parent = Dummy.Parent
	Dummy.Parent = workspace
	task.wait(.5)
	Dummy.Parent = prior_parent

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
		if (Info.Information.Team == "Survivor") then continue end
		if not (string.match(tostring(Info.Information.Character),Player:WaitForChild("Data"):WaitForChild("Loadout"):WaitForChild("Killer").Value)) then continue end
		if Custom_Frame:FindFirstChild("Skins"):FindFirstChild(Cosmetic_Set) then continue end
		
		local UiPrefab = UI.CosmeticTemplate:Clone()

		local ViewportCamera = Instance.new("Camera", script)
		ViewportCamera.Name = Cosmetic_Set

		local Viewport = UiPrefab:WaitForChild("Viewport")
		Viewport.CurrentCamera = ViewportCamera

		local ClientViewportDummy = Handler.ViewportDummies['Character']:Clone()
		ClientViewportDummy.Parent = workspace

		-- apply cosmetic to dummy --
		ApplyCosmetic(ClientViewportDummy, Cosmetic_Set, Player:WaitForChild("Data"):WaitForChild("Loadout"):WaitForChild("Killer").Value)
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

function Handler.Create()
	Handler.CreateCosmetics()
end

script.Parent.Parent:WaitForChild("Content"):WaitForChild("Cosmetics"):GetPropertyChangedSignal("Visible"):Connect(function()
	if not script.Parent.Parent:WaitForChild("Content"):WaitForChild("Cosmetics").Visible then
		Clean()
	end
end)

return Handler
