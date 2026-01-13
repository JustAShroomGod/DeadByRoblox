local TweenService : TweenService = game:GetService("TweenService")

local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Prefab : Part = script:WaitForChild("Prefab")

local TweenInformation = TweenInfo.new(
	0.2,
	Enum.EasingStyle.Back,
	Enum.EasingDirection.In
)

local module = {}

local Set_Distance = 25

function StunKiller(Killer)
	local stun = Killer:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Stunned')
	local IFrame, AFrame = Code_Module:GetEffect("IFrame", Killer), Code_Module:GetEffect("AFrame", Killer)

	if not stun.Value
		and (not AFrame or (AFrame and not AFrame.Active))
		and (not IFrame or (IFrame and not IFrame.Active)) then -- No IFrame
		
		Code_Module:Stun_Killer(Killer, 'Tic Tac')
	end
end

local function ShowTicTac(Survivor, Killer)
	local TicTac_Prefab = Prefab:Clone()
	TicTac_Prefab.Parent = workspace

	local SurvivorPosition = Survivor.PrimaryPart.Position
	local KillerPosition = Killer.PrimaryPart.Position
	
	TicTac_Prefab.Position = SurvivorPosition
	
	local Tween = TweenService:Create(TicTac_Prefab,TweenInformation,{Position = KillerPosition})
	
	Tween.Completed:Once(function()
		TicTac_Prefab:Destroy()
	end)

	Tween:Play()
end

function module:Activate(player, ...)
	local args = {...}
	local tic_Attribute = player.Character:GetAttribute("Tic_Tac")
	local Backpack = player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')

	local function ActivateTic()
		player.Character:SetAttribute("Tic_CD", true)
		playerValues.Action.Value = "Throwing"
		
		for _, Killer in pairs(game.Teams:WaitForChild('Killer'):GetPlayers()) do
			if not Killer.Character then continue end
			
			if (Killer.Character:GetPivot().Position - player.Character:GetPivot().Position).magnitude <= Set_Distance then
				ShowTicTac(player.Character, Killer.Character)
				StunKiller(Killer)
			end
		end
		
		task.wait(.25)
		playerValues.Action.Value = "Nothing"
	end
	
	if tic_Attribute and not player.Character:GetAttribute("Tic_CD") then -- attempting to deactivate/turn off
		ActivateTic()
	end
end

return module
