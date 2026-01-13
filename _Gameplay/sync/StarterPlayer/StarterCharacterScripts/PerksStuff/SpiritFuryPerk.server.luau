local remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")

local data_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local plr = game.Players:WaitForChild(script.Parent.Parent.Name)
local char = plr.Character or plr.CharacterAdded:Wait()

local Backpack = plr:WaitForChild("Backpack")
local Scripts = Backpack:WaitForChild("Scripts")
local values = Scripts:WaitForChild("values")

local killer = Scripts:WaitForChild("Killer")

local killerAction = values:WaitForChild("KillerAction")
local stunned = values:WaitForChild("Stunned")
local kind = stunned:WaitForChild("Kind")

local hasSpirit, SpiritTier = data_module:GetPerk("SpiritFury", plr)

local perksBase = Scripts:WaitForChild("PerksBase")
local furyPerksBase = perksBase:WaitForChild("SpiritFury")
local pallets = furyPerksBase:WaitForChild("Pallets")

local maxPallets = 24

local templateObjects = game.ServerStorage:WaitForChild("TemplateObjects")
local spiritFuryParticle = templateObjects:WaitForChild("SpiritFuryParticle") 


function palletbreaker()
	for i = 1, maxPallets do
		local targetPallet = workspace:FindFirstChild("Pallet".. tostring(i))
		
		if targetPallet then
			local collision = targetPallet:WaitForChild("Panel"):FindFirstChild("Collision")
			
			if collision then
				
				if (collision.CFrame.p - char:WaitForChild("HumanoidRootPart").CFrame.p).magnitude < 7 then
					local state = targetPallet:WaitForChild("Panel"):WaitForChild("State")

					local newParticle = spiritFuryParticle:Clone()
					newParticle.CFrame = collision.CFrame * CFrame.new(0,-2.5,0)
					newParticle.Parent = collision

					local blackParticle = newParticle:WaitForChild("BlackParticle")
					local orangeParticle = newParticle:WaitForChild("OrangeParticle")

					task.wait(1.5)

					blackParticle.Enabled = false
					orangeParticle.Enabled = false

					task.wait(5)

					newParticle:Destroy()
					pallets.Value = 0
					return
				end
			end
		end
	end
end

local Spirit_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('SpiritFury'))

kind.Changed:Connect(function()
	if hasSpirit and pallets.Value >= Spirit_Module.Tiers[SpiritTier] then
		palletbreaker()
	else
		script:Destroy()
	end
end)
