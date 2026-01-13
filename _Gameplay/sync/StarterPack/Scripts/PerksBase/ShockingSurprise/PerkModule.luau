local Code = require(game.ReplicatedStorage.Modules.Code)
local Events = require(game.ServerScriptService["Event System"].Events)
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild("ShockingSurprise"))

local this = {}

this.Player = nil
this.initialized = false
this.Tier = 0

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier
	
	Events.Gameplay.onGeneratorRepaired.Event:Connect(OnGeneratorRepaired)
end

function OnGeneratorRepaired(Workers: table, Generator: Model)
	local Player = this.Player
	local Tier = this.Tier
	
	if (table.find(Workers, Player.Name) ~= nil) then
		TriggerShockwave(Generator)
	end
end

function TriggerShockwave(Generator: Model)
	
	local Shockwave: MeshPart = Generator.RootPart.Shockwave
	local Radius = Perk_Module.Tiers[this.Tier] * 2
	local detonation = game.TweenService:Create(Shockwave, TweenInfo.new(Perk_Module.Travel_Time), {Size = Vector3.new(Radius, 1, Radius)})
	
	local touched = nil
	
	Shockwave.Transparency = 0
	detonation:Play()
	
	local function disconnect()
		if (touched ~= nil) then
			touched:Disconnect()
			touched = nil
		end
	end
	
	touched = Shockwave.Touched:Connect(function(part: Part)
		if (part.Parent == nil) then
			return
		end
		
		if (game.Players:FindFirstChild(part.Parent.Name) ~= nil) then
			local target: Player = game.Players[part.Parent.Name]
			
			if (target.Name == this.Player.Name) then
				return
			end
			
			if (target.Team == game.Teams.Killer) then
				Code:Stun_Killer(target, "ShockingSurprise")
				disconnect()
			end
		end
	end)

	detonation.Completed:Connect(function()
	local dissipation = game.TweenService:Create(Shockwave, TweenInfo.new(0.2), {Transparency = 1})
		dissipation:Play()

		dissipation.Completed:Connect(function()
			Shockwave.Size = Vector3.new(1, 0, 0)
			Shockwave.Transparency = 1
			disconnect()
		end)
	end)
	
	
end

return this
