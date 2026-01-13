local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules.Code)

local auras = nil
local character = nil
local connection = nil

local EffectSignal = {}

function EffectSignal.Start(Character: Model, Auras: ModuleScript)
	auras = Auras
	character = Character
	connection = Character.AttributeChanged:Connect(AttributeChanged)
	
	script.Destroying:Once(function()
		EffectSignal.Disconnect()
	end)
end

function EffectSignal.Disconnect()
	if (connection) then
		connection:Disconnect()
		connection = nil
	end
end

function AttributeChanged(attribute)

	if (string.find(attribute, "Hidden") == nil) then
		return
	end
	
	script.Parent.Enabled = (Code:GetEffect("Hidden", Players:GetPlayerFromCharacter(character)) == false and not auras.IsBlind())
end

return EffectSignal
