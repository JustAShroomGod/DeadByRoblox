local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Data_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Code_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Character = script.Parent.Parent
local RootPart = Character:WaitForChild('HumanoidRootPart')

local Silence_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Silence'))
local lastMovement = workspace:GetServerTimeNow()

local Player = game.Players:FindFirstChild(Character.Name)

local hasSilence, SilenceTier = Data_Module:GetPerk("Silence", Player)

while task.wait() do
	if not hasSilence then break end
	if not (Player.Team == game:GetService("Teams").Killer) then break end
	if not Character then continue end
	local isMoving : boolean = (RootPart.Velocity.Magnitude > 0)
	
	if isMoving then
		lastMovement = workspace:GetServerTimeNow()
	end
	
	Character:SetAttribute("Perk_Silence", Silence_Module.Tiers[SilenceTier]..':'..lastMovement) -- update last moment we moved
	
	local Should_Hide : boolean = (((math.clamp(workspace:GetServerTimeNow() - lastMovement, 0, Silence_Module.Tiers[SilenceTier])/Silence_Module.Tiers[SilenceTier]) * 100) >= 100)
	local Hidden = Code_Module:GetEffect("Hidden", Player)
	
	if Should_Hide and not Hidden then
		Code_Module:SetEffect("Hidden", Player, -1, "Silence") -- trigger inf hidden
	elseif (Hidden and Character:GetAttribute("Hidden_Silence")) and not Should_Hide then -- doing dual check on Hidden, because hidden value does full check for all hidden and we only want to remove silence --
		Code_Module:SetEffect("Hidden", Player, nil, "Silence") -- remove inf hidden
	end
end

script:Remove()