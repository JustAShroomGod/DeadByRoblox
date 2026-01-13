local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules.Code)
local Data = require(ReplicatedStorage.Modules.Data)

local Remotes = ReplicatedStorage.RemoteEvents
local AuraEvent = Remotes.ServerToClient.AuraEvent

local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local AuraFolder = workspace.Auras

local Backpack = LocalPlayer.Backpack
local Scripts = Backpack.Scripts
local Values = Scripts.values

local Settings = nil
local Categories = {"Default", "Ally", "Hostile", "Objects", "Totems", "Special"}
local TweenTime = 0.5

local IsBlind
local Initialized = false

local AuraEntry = {
	Object = nil;
	Timer = nil;
}

local AuraArray = {}

local Auras = {}

function Auras.Setup()

	Settings = Data:GetSettings()
	local Colors = if (Scripts.Killer.Value) then Settings.COLORS["Killer"] else Settings.COLORS["Survivor"]

	for count = 1, #Categories do
		local category = Categories[count]
		local categoryColor = {Colors[category]["Outline"], Colors[category]["Fill"]}

		local categoryColorOutline = Color3.fromRGB(categoryColor[1][1], categoryColor[1][2], categoryColor[1][3])
		local categoryColorFill = Color3.fromRGB(categoryColor[2][1], categoryColor[2][2], categoryColor[2][3])

		local categoryModel = Instance.new("Model")
		categoryModel.Name = category
		categoryModel.Parent = AuraFolder

		local categoryHighlight = Instance.new("Highlight")
		categoryHighlight.Name = "Aura"
		categoryHighlight.Parent = categoryModel

		categoryHighlight.OutlineColor = categoryColorOutline
		categoryHighlight.FillColor = categoryColorFill
	end
	
	Auras.SetupArray()
	LocalCharacter.AttributeChanged:Connect(AttributeChanged)
end

function Auras.SetupArray()

	for count = 1, #Categories do
		AuraArray[Categories[count]] = {}
	end
	
	Initialized = true
end

function Auras.AddAura(Category: string, Duration: number, Object: Instance, CreateAsDefault: boolean, Alias: string)
	
	repeat task.wait()
	until LocalCharacter:GetAttribute("IntroDone") and Initialized
	
	Alias = Alias or Object.Name
	local ColorOutline, ColorFill = Auras.GetCategoryColor(Category)
	
	--print(Object, Alias)
	
	if (AuraArray[Category][Alias] ~= nil) then
		return
	end
	
	if (AuraArray["Default"][Object.Name] ~= nil and Category ~= "Default") then
		Auras.RemoveAura(Object.Name, "Default", false)
	end
	
	local clone = Object:Clone()
	clone.Name = Object.Name
	clone.Parent = AuraFolder[Category]
	CleanupClone(clone)
	
	local highlight = Instance.new("Highlight")
	highlight.Name = Alias
	highlight.Parent = clone
	highlight.Adornee = clone
	highlight.Enabled = true

	highlight.OutlineColor = ColorOutline
	highlight.FillColor = ColorFill
	
	highlight.OutlineTransparency = 1
	highlight.FillTransparency = 1
	
	local newEntry = table.clone(AuraEntry)
	newEntry.Object = clone
	
	if (Duration > 0) then
		
		Duration += Code:GetPlayerValue(LocalPlayer, "AuraExtension")
		
		local timerScript = script.Timer:Clone()
		timerScript.Parent = clone
		
		local timer = require(timerScript)
		timer.Start(Duration, Auras, CreateAsDefault, Alias)
		newEntry.Timer = timer
	end
	
	newEntry.AuraObject = highlight
	AuraArray[Category][Alias] = newEntry
	
	local tweenOutline = TweenService:Create(highlight, TweenInfo.new(TweenTime), {OutlineTransparency = 0})
	local tweenfill = TweenService:Create(highlight, TweenInfo.new(TweenTime), {FillTransparency = 0.5})

	tweenfill:Play()
	tweenOutline:Play()
	
	--Object.Destroying:Once()(function(parentName)
		
	--end)
	
	return clone
end

function Auras.RemoveAura(Object: string, Category: string, CreateAsDefault: boolean)
	
	if (AuraArray[Category][Object] == nil) then
		return
	end 
	
	if (CreateAsDefault) then
		local obj = AuraArray[Category][Object].Object:Clone()
		Auras.AddAura("Default", -1, obj, false)
	end
	
	local obj = AuraArray[Category][Object].Object
	local tweenOutline = TweenService:Create(AuraArray[Category][Object].AuraObject, TweenInfo.new(TweenTime), {OutlineTransparency = 1})
	local tweenfill = TweenService:Create(AuraArray[Category][Object].AuraObject, TweenInfo.new(TweenTime), {FillTransparency = 1})
	
	tweenfill:Play()
	tweenOutline:Play()
	
	AuraArray[Category][Object] = nil
	
	tweenOutline.Completed:Once(function()
		AuraFolder[Category][obj.Name]:Destroy()
	end)
	
end

function Auras.AddPlayerAura(Category: string, Duration: number, Player: Player, Alias: string)
	
	Alias = Alias or Player.Name
	
	if (AuraArray[Category][Alias] ~= nil) then
		return
	end
	
	local ColorOutline, ColorFill = Auras.GetCategoryColor(Category)

	local highlight = Instance.new("Highlight")
	highlight.Name = Alias
	highlight.Parent = AuraFolder[Category]
	highlight.Adornee = Player.Character
	highlight.Enabled = (Code:GetEffect("Hidden", Player) == false)

	highlight.OutlineColor = ColorOutline
	highlight.FillColor = ColorFill
	
	highlight.OutlineTransparency = 1
	highlight.FillTransparency = 1
	
	local newEntry = table.clone(AuraEntry)
	newEntry.Object = Alias

	if (Duration > 0) then
		
		Duration += Code:GetPlayerValue(LocalPlayer, "AuraExtension")
		
		local timerScript = script.PlayerTimer:Clone()
		timerScript.Parent = highlight

		local timer = require(timerScript)
		timer.Start(Duration, Auras)
		
		newEntry.Timer = timer
	end
	
	if (Category ~= "Ally") then
		local effectScript = script.EffectSignal:Clone()
		effectScript.Parent = highlight

		local effects = require(effectScript)
		effects.Start(Player.Character, Auras)

		newEntry.EffectSignal = effects
	end
	
	newEntry.AuraObject = highlight
	AuraArray[Category][Alias] = newEntry
	
	local tweenOutline = TweenService:Create(highlight, TweenInfo.new(TweenTime), {OutlineTransparency = 0})
	local tweenfill = TweenService:Create(highlight, TweenInfo.new(TweenTime), {FillTransparency = 0.5})

	tweenfill:Play()
	tweenOutline:Play()
end

function Auras.RemovePlayerAura(Alias: string, Category: string)

	if (AuraArray[Category][Alias] == nil) then
		return
	end
	
	local tweenOutline = TweenService:Create(AuraArray[Category][Alias].AuraObject, TweenInfo.new(TweenTime), {OutlineTransparency = 1})
	local tweenfill = TweenService:Create(AuraArray[Category][Alias].AuraObject, TweenInfo.new(TweenTime), {FillTransparency = 1})

	tweenfill:Play()
	tweenOutline:Play()

	AuraArray[Category][Alias] = nil

	tweenOutline.Completed:Once(function()
		AuraArray[Category][Alias].AuraObject:Destroy()
	end)
end

function Auras.GetCategoryColor(Category: string)
	
	local Colors = if (Scripts.Killer.Value) then Settings.COLORS["Killer"] else Settings.COLORS["Survivor"]
	local categoryColor = {Colors[Category]["Outline"], Colors[Category]["Fill"]}

	local categoryColorOutline = Color3.fromRGB(categoryColor[1][1], categoryColor[1][2], categoryColor[1][3])
	local categoryColorFill = Color3.fromRGB(categoryColor[2][1], categoryColor[2][2], categoryColor[2][3])
	
	return categoryColorOutline, categoryColorFill
end

function Auras.GetAura(Object: string, Category: string)
	return AuraArray[Category][Object]
end

function Auras.GetAll()
	local auras = {}

	for count = 1, #Categories do
		for _, object in pairs(AuraArray[Categories[count]]) do
			table.insert(auras, object)
		end
	end

	return auras
end

function Auras.IsBlind()
	return IsBlind
end

function CleanupClone(Object: Instance)
	
	if (Object:IsA("BasePart") and string.find(Object.Name, "Particle") == nil and Object.Transparency >= 1) then
		Object.Transparency = 0.99
	end
	
	for i, v in pairs(Object:GetDescendants()) do
		if (v:IsA("Script") or v:IsA("ModuleScript") or v:IsA("LocalScript")) then
			v:Destroy()
		end
		
		if (v:IsA("BasePart") or v:IsA("UnionOperation")) then
			v.CanCollide = false
			v.CanQuery = false
			v.CanTouch = false
			v.CollisionGroup = "NoCollision"
			v.CastShadow = false
			v.Anchored = true
		end
		
		if v.Name == "Balloon" then
			v:RemoveTag("Balloon")
			v:Destroy()
		end
	end
end

function AttributeChanged(attribute)

	if (string.find(attribute, "Blind") == nil or Code:GetEffect("Blind") == IsBlind) then
		return
	end
	
	IsBlind = Code:GetEffect("Blind")

	for i, v in pairs(AuraFolder:GetChildren()) do
		v.Aura.Enabled = (IsBlind == false)
	end
end

return Auras
