local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local PowerModel = script.Parent
local PowerValues = PowerModel.PowerValues
local PowerRemote = PowerValues.PowerRemote
local PowerEvent = PowerValues.PowerEvent

local Player: Player = Players:GetPlayerFromCharacter(PowerModel.Parent)
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character.Humanoid
local RootPart = Character.HumanoidRootPart

local KillerData = require(game.ReplicatedStorage.Game_Data.Killers.Scientist)
local AddonData = game.ReplicatedStorage.Game_Data.Addons.Killer

local Reverse = require(script.Reverse)
local ObjBuffer = require(script.ObjBuffer)
local DilationSphere = require(script.DilationSphere)

local Code = require(game.ReplicatedStorage.Modules.Code)
local Data = require(game.ReplicatedStorage.Modules.Data)

local TimeScaleRef = Instance.new("NumberValue")
local ReverseEffectRef = Instance.new("ColorCorrectionEffect")
local DilationEffectRef = Instance.new("ColorCorrectionEffect")

local validActions = {"Nothing"}
local bufferCooldown = 0.05
local bufferTimer = 0

local lastReverse = workspace:GetServerTimeNow()

local objectCache = {["Generators"] = {}; ["Totems"] = {}; ["Players"] = {}}
local tweenElements = {"Background", "Progress", "ClockIcon", "Tally"}

local nonBufferedActions = {"Vault"}
local initialized = false
local scaleValue = nil

function initialize()

	SetPowerValues()
	LinkPlayerEvents()
	ApplyAddons()

	initialized = true
	PowerModel:SetAttribute("Initialized", true)

	game["Run Service"].Heartbeat:Connect(Update)
end

function LinkPlayerEvents()
	for i, plr: Player in pairs(game.Teams.Survivor:GetPlayers()) do
		plr.CharacterRemoving:Once(CharacterRemoved)
	end
	
	for i, plr: Player in pairs(Players:GetPlayers()) do
		LinkUIElement(plr)
	end
end

function SetPowerValues()
	
	for attrName, attrValue in (KillerData.PowerValues) do
		PowerValues:SetAttribute(attrName, attrValue)
	end
	
	ObjBuffer.SetBufferSize(KillerData.PowerValues.Time_To_Reverse / bufferCooldown)
	
	TimeScaleRef.Parent = workspace.MatchValues
	TimeScaleRef.Name = "TimeScale"
	TimeScaleRef.Value = 1
	
	DilationEffectRef.Name = "DilationEffect"
	DilationEffectRef.Parent = game.Lighting
	DilationEffectRef.Enabled = true
	DilationEffectRef.Saturation = 0
	
	ReverseEffectRef.Name = "ReverseEffect"
	ReverseEffectRef.Parent = game.Lighting
	ReverseEffectRef.Enabled = false
	ReverseEffectRef.Saturation = 0
	
	DilationSphere.Init()
end

function RevealUI(DilationDisplay)
	DilationDisplay.Visible = true
	
	for i, v in pairs(tweenElements) do
		local element = DilationDisplay[v]
		local property = if (element:IsA("Frame")) then "BackgroundTransparency" else "ImageTransparency"
		local tween = TweenService:Create(element, TweenInfo.new(1.5), {[tostring(property)] = 0})
		tween:Play()
		
		local tweenS = TweenService:Create(DilationDisplay.UIStroke, TweenInfo.new(1.5), {Transparency = 0.7})
		tweenS:Play()
	end
end

function LinkUIElement(Player: Player)
	
	local PlayerGui = Player.PlayerGui
	local DilationDisplay = PlayerGui.HUD.MainHud.Dilation_Display
	
	Player.Character:GetAttributeChangedSignal("IntroDoneS"):Once(function()
		RevealUI(DilationDisplay)
	end)
	
	TimeScaleRef.Changed:Connect(function()
		if (TimeScaleRef.Value < 1) then
			local pos = 0.5 / 1 * TimeScaleRef.Value
			local tween = TweenService:Create(DilationDisplay.Tally, TweenInfo.new(0.25), {Position = UDim2.fromScale(pos , 1)})
			tween:Play()
			
			local saturation = 0 - (1 - TimeScaleRef.Value)
			local tweenEffect = TweenService:Create(DilationEffectRef, TweenInfo.new(0.5), {Saturation = saturation})
			tweenEffect:Play()
			return
		end
		
		if (TimeScaleRef.Value > 1) then
			local pos = (0.5 / (GetValue("Max_Scale") - 1) * (TimeScaleRef.Value - 1)) + 0.5
			local tween = TweenService:Create(DilationDisplay.Tally, TweenInfo.new(0.25), {Position = UDim2.fromScale(pos , 1)})
			tween:Play()
			
			local saturation = 1 / GetValue("Max_Scale") * TimeScaleRef.Value
			local tweenEffect = TweenService:Create(DilationEffectRef, TweenInfo.new(0.5), {Saturation = saturation})
			tweenEffect:Play()
			return
		end
		
		if (TimeScaleRef.Value == 1) then
			local tween = TweenService:Create(DilationDisplay.Tally, TweenInfo.new(0.25), {Position = UDim2.fromScale(0.5 , 1)})
			tween:Play()
			
			local tweenEffect = TweenService:Create(DilationEffectRef, TweenInfo.new(0.5), {Saturation = 0})
			tweenEffect:Play()
			return
		end
	end)
	
end

function ApplyAddons()
	local Addons_Data = Data:GetAddons("Killer", game.Players[Player.Name])

	for _,Addon in pairs(Addons_Data) do
		if (script.Addons:FindFirstChild(Addon) == nil) then
			continue
		end
		
		require(script.Addons:FindFirstChild(Addon)).Init(Player)
	end
	
	coroutine.wrap(CacheObjects)()
end

function CreateScaleValue()
	scaleValue = Instance.new("NumberValue")
	scaleValue.Name = "TimeScale"
	scaleValue.Value = 1
	scaleValue.Parent = workspace.MatchValues
end

function CacheObjects()
	
	task.wait(5)
	
	for i, object in pairs(workspace:GetChildren()) do
		if (string.find(object.Name, "Generator")) then
			table.insert(objectCache.Generators, object)
			ObjBuffer.Register(object)
		end
		
		if (string.find(object.Name, "Totem")) then
			table.insert(objectCache.Totems, object)
			ObjBuffer.Register(object)
		end
	end
	
	for index, player in pairs(Players:GetPlayers()) do
		
		table.insert(objectCache.Players, player)
		ObjBuffer.Register(player)
		
		player.CharacterRemoving:Once(function()
			CharacterRemoved(player)
		end)

		player.Destroying:Once(function()
			CharacterRemoved(player)
		end)
	end
end

function Update(delta)
	
	UpdateCooldown(delta)
	DilationSphere.Update(delta)
	
	if (bufferTimer > 0) then
		bufferTimer -= delta
		return
	end
	
	bufferTimer = bufferCooldown
	
	UpdateBufferObjects(delta)
	UpdateBufferPlayers(delta)
end

function UpdateBufferObjects()
	
	for i, generator in pairs(objectCache.Generators) do
		if (not ObjBuffer.IsRegistered(generator)) then
			ObjBuffer.Register(generator)
		end
		
		ObjBuffer.AddEntry(generator, {
			["Type"] = "Generator";
			["Progress"] = generator.Panel.Progress.Value;
		})
	end
	
	for i, totem in pairs(objectCache.Totems) do
		if (not ObjBuffer.IsRegistered(totem)) then
			ObjBuffer.Register(totem)
		end

		ObjBuffer.AddEntry(totem, {
			["Type"] = "Totem";
			["State"] = totem.Panel.State.Value;
			["Effect"] = totem.Panel.Effect.Value;
		})
	end
end

function UpdateBufferPlayers()
	
	for i, plr in pairs(objectCache.Players) do
		
		if (not ObjBuffer.IsRegistered(plr)) then
			ObjBuffer.Register(plr)
		end
		
		if (string.find(Code:GetKillerAction(plr), "Grasp")) then
			continue
		end
		
		if (Code:IsHooked(plr) or Code:GetSurvivorAction(plr) == "Hiding" or Code:IsCarried(plr)) then
			continue
		end
		
		ObjBuffer.AddEntry(plr, {
			["Type"] = "Player";
			["CFrame"] = plr.Character.PrimaryPart.CFrame;
			["HealthState"] = Code:GetHealthState(plr);
			["HealProgress"] = Code:GetHealProgress(plr);
		})
	end
end

function UpdateCooldown(delta)
	
	if (TimeScaleRef.Value == 1) then
		return
	end
	
	if (PowerValues:GetAttribute("Current") >= 100) then
		return
	end
	
	local current = PowerValues:GetAttribute("Current")
	local rate = PowerValues:GetAttribute("Recharge_Rate") * 60 -- only for testing 
	current += (rate * delta)

	PowerValues:SetAttribute("Current", current)
end

function CharacterRemoved(Plr: Player)
	ObjBuffer.Unregister(Player)
end

function CommandReceived(Player, Command, ...)

	local args = {...}

	if (Command == "SetValue") then
		SetValue(args[1], args[2])
	end

	if (Command == "Action") then
		SetAction(args[1])
	end
	
	if (Command == "Reverse") then
		
		if (PowerValues:GetAttribute("Current") < 100 or TimeScaleRef.Value >= 1) then
			return
		end
		
		PowerValues:SetAttribute("Current", 0)
		
		Reverse.PerformOnPlayers(objectCache.Players)
		Reverse.PerformOnObjects()
		
		DilationEffectRef.Enabled = false
		ReverseEffectRef.Enabled = true
		
		local tweenEffect = TweenService:Create(ReverseEffectRef, TweenInfo.new(0.5), {Saturation = -1})
		tweenEffect:Play()
		
		for i, plr: Player in pairs(Players:GetPlayers()) do
			local PlayerGui = plr.PlayerGui
			local ReverseDisplay = PlayerGui.HUD.MainHud.Reverse_Display
			
			ReverseDisplay:SetAttribute("LastTick", workspace:GetServerTimeNow())
		end
		
		task.wait(GetValue("Reverse_Duration") * 2)
		
		local tweenEffect = TweenService:Create(ReverseEffectRef, TweenInfo.new(0.5), {Saturation = 0})
		tweenEffect:Play()
		
		tweenEffect.Completed:Once(function()
			DilationEffectRef.Enabled = true
			ReverseEffectRef.Enabled = false
		end)
		
	end
	
	if (Command == "Speed+") then
		DilationSphere.SpeedUp()
	end
	
	if (Command == "Speed-") then
		DilationSphere.SlowDown()
	end

end

function SetAction(Action)

	local killerAction = Player.Backpack.Scripts.values.KillerAction

	if (table.find(validActions, killerAction.Value) ~= nil or Action == nil) then
		return
	end

	if (table.find(validActions, Action) == nil) then
		return
	end

	killerAction.Value = Action
end

function SetValue(Attribute, Value)
	PowerModel:SetAttribute(Attribute, Value)
end

function GetValue(Attribute)
	return PowerValues:GetAttribute(Attribute)
end

initialize()

PowerRemote.OnServerEvent:Connect(CommandReceived)