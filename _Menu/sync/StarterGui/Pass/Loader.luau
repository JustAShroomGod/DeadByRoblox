local ReplicatedStorage : ReplicatedStorage, Players : Players, RunService : RunService = game:GetService("ReplicatedStorage"), game:GetService("Players"), game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

local PerkModules_Container = ReplicatedStorage:WaitForChild("Game_Data"):WaitForChild("Perks")

local Remote = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("Server_Client")

local Container = script.Parent:WaitForChild("Container")
local Tiers = script.Parent:WaitForChild("Container"):WaitForChild("BarBackground"):WaitForChild("Tiers")
local Prefabs = Tiers:WaitForChild("Prefabs")

local SelectedPlayer_Gift = nil
local Divider = nil

local ViewportDummies = workspace:FindFirstChild("ViewportDummies");
local CosmeticsModule = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Cosmetics"))

local LocalTiers = {}

local Buttons = {
	Back = {
		Object = script.Parent:WaitForChild("Back");
		Body = script.Parent:WaitForChild("Back"):WaitForChild("Body");
	};
	BuyPass = {
		Object = script.Parent:WaitForChild("BuyPass");
		Body = script.Parent:WaitForChild("BuyPass"):WaitForChild("Body");
	};
	GiftPass = {
		Object = script.Parent:WaitForChild("GiftPass");
		Body = script.Parent:WaitForChild("GiftPass"):WaitForChild("Body");
	};
}

local Data_Module = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Data"))

local function SendNotification(TitleText : string, BodyText : string)
	StarterGui:SetCore("SendNotification", {
		Title = TitleText;
		Text = BodyText;
		Icon = 000000;
		Duration = 5;
	})
end

local function HoverIn(Body : ImageLabel)
	Body.ImageTransparency = 0
	Body.Hover.Visible = true
	Body.Outline.ImageTransparency = 0
	Body.Parent.Label.TextTransparency = 0
end

local function HoverOut(Body : ImageLabel)
	Body.ImageTransparency = 0.5
	Body.Hover.Visible = false
	Body.Outline.ImageTransparency = 0.4
	Body.Parent.Label.TextTransparency = 0.4
end

local function BuyPass(isGift : boolean)
	if isGift then
		if SelectedPlayer_Gift then
			if SelectedPlayer_Gift == LocalPlayer.UserId then
				Data_Module:GetPassPrompt(LocalPlayer)
			else
				Data_Module:GetPassPrompt(LocalPlayer, SelectedPlayer_Gift)
			end
		end
	else
		Data_Module:GetPassPrompt(LocalPlayer)
	end
end

local function ApplyCosmetic(Dummy : Model, Cosmetic : string, Side : string, Character : string) : "Apply all since we are doing only sets right now"
	CosmeticsModule.ApplyCosmetic(Dummy, Cosmetic,if Side ~= "Survivor" then "Killer" else "Survivor", Character)

	local prior_parent = Dummy.Parent
	Dummy.Parent = workspace
	task.wait(.5)
	Dummy.Parent = prior_parent
end

local module = {}
module.__index = module

function module.new(Data : {}, Index : number)
	local TierData = Data["Tier" .. Index]
	if not Divider then Divider = math.clamp(math.floor(Data.Progress / Data.Tier1.Needed), 0, 10) end

	local Tier = {}
	setmetatable(Tier,module)
	Tier.Object = if TierData.Paid then Prefabs:WaitForChild("Paid"):Clone()  else Prefabs:WaitForChild("Free"):Clone()
	Tier.Index = Index
	Tier.Object.Name = "Tier" .. Tier.Index
	Tier.Claim = Tier.Object:WaitForChild("Claim")
	Tier.Bar = Container:WaitForChild("BarBackground"):WaitForChild("Bar")

	Tier.Object:WaitForChild("Name").Text = TierData.Reward.Prize
	
	if Divider >= Index then
		if TierData.Paid then
			if Data.HasPass then
				Tier.Claim.Visible = true
			end
		else
			Tier.Claim.Visible = true
		end
	end
	
	if TierData.Claimed then
		Tier:ClaimTier()
	end
	
	Tier.Bar.Size = UDim2.new(tonumber(Data.Progress)/tonumber(1000),0,1,0)

	if Tier.Object:FindFirstChild("Locked") then Tier.Object:FindFirstChild("Locked").Visible = not Data.HasPass end
	if Tier.Claim.Visible then
		Tier.Claim.MouseButton1Click:Connect(function()
			Data_Module:ClaimPassReward(LocalPlayer, Tier.Object.Name)
		end)
	end	

	Tier.Object.Parent = Tiers
	Tier.Object.Visible = true
	
	
	if TierData.Reward.Type == "Cosmetic" then
		task.spawn(function()
			local ViewportCamera = Instance.new("Camera", script)
			ViewportCamera.Name = TierData.Reward.Prize

			local Viewport = Tier.Object:WaitForChild("ViewportFrame")
			Viewport.CurrentCamera = ViewportCamera

			local ClientViewportDummy = ViewportDummies['Character']:Clone()
			ClientViewportDummy.Parent = workspace

			-- apply cosmetic to dummy --
			ApplyCosmetic(ClientViewportDummy, TierData.Reward.Prize, TierData.Reward.Character, if TierData.Reward.Character == "Survivor" then nil else TierData.Reward.Character)
			ClientViewportDummy.Parent = Viewport

			local Angle = 0
			RunService.Heartbeat:Connect(function() -- rotates dummy (remove or find a better way)
				Angle += 2
				ViewportCamera.CFrame = CFrame.new(((ClientViewportDummy:GetPivot() * CFrame.Angles(0, math.rad(Angle), 0)) * CFrame.new(-8.5, 4.5, 0)).Position, ClientViewportDummy:GetPivot().Position)
			end)
		end)
	elseif TierData.Reward.Type == "Perk" then
		task.spawn(function()
			local PerkModule = require(PerkModules_Container:FindFirstChild(TierData.Reward.Character):FindFirstChild(TierData.Reward.Prize))
			
			local Icon = Tier.Object:FindFirstChild("PerkIcon")
			
			Icon.Image = PerkModule.Image
		end)
	end
	
	return Tier
end

function module:RecalculateUnlocked()
	if Divider >= self.Index  then
		self.Claim.Visible = true
	end
end

function module:ClaimTier()
	self.Claim.Visible = false
end

function module:UnlockTier()
	self.Object:WaitForChild("Locked").Visible = false
end

Remote.OnClientEvent:Connect(function(server_command : string,...)
	local args = {...}

	if server_command == "pass_start" then
		local Data = args[1]
		
		for i = 1,10 do
			LocalTiers["Tier" .. i] = module.new(Data,i)
		end
		
		if Data.HasPass then
			Buttons.BuyPass.Object.Visible = false
		end
	elseif server_command == "pass_claimed" then
		LocalTiers[args[1]]:ClaimTier()
	elseif server_command == "pass_bought_self" then
		Buttons.BuyPass.Object.Visible = false
		
		for _,Tier in pairs(LocalTiers) do
			if Tier.Object:FindFirstChild("Locked") then
				Tier:UnlockTier()
				Tier:RecalculateUnlocked()
			end
		end
	elseif server_command == "pass_bought_gift" then		
		SendNotification("Gifting successful!", "Recipient thanks you <3")
	elseif server_command == "pass_error" then		
		SendNotification(args[1], args[2])
	end
end)

Buttons.Back.Object:WaitForChild("Button").MouseButton1Click:Connect(function()
	script.Parent.Parent:WaitForChild("ChooseBand").Enabled = true
	script.Parent.Enabled = false
end)

Buttons.GiftPass.Object.TextBox.FocusLost:Connect(function()
	local Username = Buttons.GiftPass.Object.TextBox.Text
	local UserId = Players:GetUserIdFromNameAsync(Username) or nil
	
	if UserId then
		SelectedPlayer_Gift = UserId
	else
		SelectedPlayer_Gift = nil
	end
end)

for _, Button in pairs(Buttons) do
	Button.Object:WaitForChild("Button").MouseEnter:Connect(function()
		HoverIn(Button.Body)
	end)

	Button.Object:WaitForChild("Button").MouseLeave:Connect(function()
		HoverOut(Button.Body)
	end)

	if Button.Object.Name == "Back" then continue end
	
	Button.Object:WaitForChild("Button").MouseButton1Click:Connect(function()
		BuyPass(if string.match(Button.Object.Name, "Gift") then true else false)
	end)
end

return module
