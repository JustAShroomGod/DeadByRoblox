local Modules = {
	Killer = require(script:WaitForChild('Killer_Handler'));
	Survivor = require(script:WaitForChild('Survivor_Handler'));
}

local Mode = "None"
local Killer_Value = game.Players.LocalPlayer:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('Killer')

function Switch(Desired : "Killer" | "Survivor")
	if Mode == Desired then return end -- same mode do nothing
	Mode = Desired
	
	if Mode == 'Survivor' then
		Modules.Killer:Stop()
		Modules.Survivor:Run()
	elseif Mode == 'Killer' then
		Modules.Survivor:Stop()
		Modules.Killer:Run()
	end
end

if Killer_Value.Value then
	Switch('Killer')
else
	Switch('Survivor')
end

Killer_Value.Changed:Connect(function()
	
	if Killer_Value.Value then
		Switch('Killer')
	else
		Switch('Survivor')
	end
end)

require(script.Object_Animation)