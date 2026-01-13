local Events = require(game.ServerScriptService["Event System"].Events)
local Whisper_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Whispers'))

local RunService = game:GetService("RunService")

local this = {}

this.Player = nil
this.initialized = false

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	
	if (this.Heartbeat == nil) then
		this.Heartbeat = RunService.Heartbeat:Connect(function(delta)
			
			local Scripts = this.Player.Backpack.Scripts
			local Action = Scripts.values.Action.Value

			local PerkValues = script.Parent
			local Radius = Whisper_Module.Tiers[Tier]
			
			searchRadius(Radius)
		end)
	end
end

function searchRadius(Radius)
	local Perk = script.Parent
	
	for _, Player in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do
	
		local Dist = getDistance(this.Player, Player)
		
		if (Dist <= Radius) then
			Perk:SetAttribute("isTracking", true)
			return
		end
	end
	
	Perk:SetAttribute("isTracking", false)
end

function getDistance(Player, Target)
	local PlayerCharacter = game.Workspace:FindFirstChild(this.Player.Name)
	local TargetCharacter = game.Workspace:FindFirstChild(Target.Name)
	
	if not PlayerCharacter or not TargetCharacter then return 1000 end -- return large number to indicate off if can't get number
	
	local PlayerPosition: Vector3 = PlayerCharacter.HumanoidRootPart.CFrame.Position
	local TargetPosition: Vector3 = TargetCharacter.HumanoidRootPart.CFrame.Position
	
	return math.abs((PlayerPosition - TargetPosition).Magnitude)
end

return this
