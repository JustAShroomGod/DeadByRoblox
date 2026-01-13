local Code = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Data = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Events = require(game.ServerScriptService["Event System"]:WaitForChild("Events"))
local Visual = require(script.Parent.Parent.Visual)

local this = {}

function this.initialize()
	--Nothing 
end

function onBreak()
	local Killer = Code:getKiller()

	local Killers = Code:getKiller()

	if Killers then

		if typeof(Killers) == "table" then

			for _, Killer in pairs(Killers) do
				
				if Data:GetAddon("Killer", Killer, "Serpent") then
					Visual:ForceUncloak(Killer.Character, "Serpent")
					Code:SetEffect("Haste", Killer, nil, 'Wraith_Invisible') -->> remove cloak speed
					Killer.Character:SetAttribute("Cloaked", false)
				end
			end
		else
			Visual:ForceUncloak(Killer.Character, "Serpent")
			Code:SetEffect("Haste", Killer, nil, 'Wraith_Invisible') -->> remove cloak speed
			Killer.Character:SetAttribute("Cloaked", false)
		end
	end
end

Events.Killer.onBreak.Event:Connect(onBreak)

return this
