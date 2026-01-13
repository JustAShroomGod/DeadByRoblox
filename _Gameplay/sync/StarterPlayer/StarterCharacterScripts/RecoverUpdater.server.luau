local remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
local runService = game:GetService("RunService") 
local plr = game.Players:WaitForChild(script.Parent.Name)
local char = workspace:WaitForChild(plr.Name) 
local Backpack = plr:WaitForChild("Backpack")
local Scripts = Backpack:WaitForChild("Scripts")
local values = Scripts:WaitForChild("values") 
local action = values:WaitForChild("Action")
local hooked = values:WaitForChild("Hooked")
local healthState = values:WaitForChild("HealthState")
local healProgress = values:WaitForChild("HealProgress")
local recovering = values:WaitForChild("Recovering")
local perksBaseFolder = Scripts:WaitForChild("PerksBase")
local prePerksBase = {"Unbreakable"}

local perksBase = {}
for _, name in pairs(prePerksBase) do
	local this0 = perksBaseFolder:WaitForChild(name)
	local thisTable = {}

	for v1, this1 in pairs(this0:GetChildren()) do
		thisTable[this1.Name] = this1
	end

	perksBase[name] = thisTable
end

local dataModule = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))

healthState.Changed:Connect(function()
	healProgress.Value = 0
end)

char:GetAttributeChangedSignal("Hit"):Connect(function()
	if char:GetAttribute("Hit") == true then
		task.wait(0.85)
		char:SetAttribute("Hit", false)
	end
end)

local runCon
recovering.Changed:Connect(function()

	if recovering.Value then
		runCon = runService.Heartbeat:Connect(function(step)
			if action.Value == "Recover" 
				and hooked.Value == false
				and healthState.Value == 0 then
				
				char:SetAttribute("CurrentInteractable", plr.Name)
				local gotunbreakable, unbreakableTier = dataModule:GetPerk("Unbreakable", plr)
				local gotmither, mitherTier = dataModule:GetPerk("NoMither", plr)

				local recoverSpeed = step * 33

				if gotunbreakable then
					recoverSpeed *= require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Unbreakable')).Tiers[unbreakableTier]
				end

				if gotmither then
					recoverSpeed *= require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('NoMither')).Tiers[mitherTier]
				end

				if tonumber(healProgress.Value) > 950 then

					if not perksBase["Unbreakable"]["Used"].Value and gotunbreakable or gotmither then

						if tonumber(healProgress.Value) < 1000 then
							healProgress.Value = healProgress.Value + recoverSpeed
						else
							if not perksBase["Unbreakable"]["Used"].Value then
								perksBase["Unbreakable"]["Used"].Value = true
							end

							healProgress.Value = 0
							healthState.Value = 1
							require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code')):SetCollision(plr, 'Survivor')
						end
					end
				else
					healProgress.Value = healProgress.Value + recoverSpeed
				end

			end
		end)
	else
		if runCon then runCon:Disconnect() runCon = nil end
		char:SetAttribute("CurrentInteractable", "")
	end
end)
