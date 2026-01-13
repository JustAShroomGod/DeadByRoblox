local playerService, replicatedStorage : ReplicatedStorage, serverScriptService : ServerScriptService = game:GetService('Players'), game:GetService('ReplicatedStorage'), game:GetService('ServerScriptService')

local Data = require(replicatedStorage.Modules.Data)
local Code = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local remoteStorage : Folder = replicatedStorage:WaitForChild('RemoteEvents')

repeat task.wait() until workspace:FindFirstChild("ExitGate1") and workspace:FindFirstChild("ExitGate2")

local Exits = {
	workspace:WaitForChild('ExitGate1');
	workspace:WaitForChild('ExitGate2');
	workspace:FindFirstChild('ExitGate3')
}



local function ItemGet(player : Player) : "Rewards us our current held item"
	local Model = player.Character

	for _, item in pairs(Model:GetChildren()) do
		if not item:IsA('Model') then continue end
		
		if item:GetAttribute("Tool") then
			--print(item, 'reward back')
			--[[if item.Name == "Bone_Knife" then
				print("Bone_Knife")
				Data:Quest(player,"HalloweenQuest_2")
			end]]
			--print('TODO: GIVE ITEM!')
			--Data:RewardItem(player, item)
		end
	end
end

function invisible(character : "Character") : "Hides our character!"

	-- Remove Images --
	for _, decal in pairs(character:GetDescendants()) do
		if decal.ClassName ~= 'Decal' and decal.ClassName ~= 'SurfaceGui' then continue end
		decal:Destroy()
	end

	-- Hide Parts --
	for _, part in pairs(character:GetDescendants()) do
		if not part:IsA('BasePart') then continue end
		part.Transparency = 1
	end
end

local function Action(Character : "Character")
	local player = playerService:GetPlayerFromCharacter(Character)

	if player then
		local ourPlayer : StringValue = game.ReplicatedStorage:WaitForChild('Match'):WaitForChild('Players'):WaitForChild(player.Name)

		if ourPlayer:GetAttribute("Team") == "Survivor" and not ourPlayer:GetAttribute("Escaped") then
			ourPlayer:SetAttribute("Escaped", true)
			ItemGet(player)
			Code:AddEscape(player)
		end
	end
end

function ExitGate(gate : Model, part : Part) : "Checks exit gate if valid send part through"
	local gateSettings : Folder = gate:WaitForChild('Panel')

	part = if part.Parent:FindFirstChildOfClass('Humanoid') then part.Parent elseif part.Parent.Parent:FindFirstChildOfClass('Humanoid') then part.Parent.Parent else nil

	if not gateSettings.Blocked.Value and gateSettings.Progress.Value >= 99 and part then
		Action(part)
	end
end

for _,exitGate : Model in pairs(Exits) do
	local Gate = exitGate:WaitForChild('Escape_Trigger')

	Gate.Touched:Connect(function(p : Part)
		ExitGate(exitGate, p)
	end)
end