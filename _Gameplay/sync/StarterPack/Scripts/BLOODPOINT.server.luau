local ScoreEvents = script.Parent.values.Match:WaitForChild("BloodPoints")
Code = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'));

for _,Event in pairs(ScoreEvents:GetChildren()) do
	Event.Changed:Connect(function()
		if Event.Value > 12000 then
			Event.Value = 12000
		end
		
		if Event.Value < 0 then
			Event.Value = 0
		end
	end)
end

script.Parent.values.Hooked.Changed:Connect(function()
	if script.Parent.values.Hooked.Value == true then
		Code:Exhaust(script.Parent.Parent.Parent, 0 )	-- add exhaustion removal code here
	end
end)

local isDh = false
local HealthState = script.Parent.values.HealthState
local Progress = 0
script.RemoteEvent.OnServerEvent:Connect(function(p,v)
	Progress = v
end)
script.Parent.values.Action.Changed:Connect(function()
	if script.Parent.values.Action.Value == "DeadHard" then
		if isDh == false then
			isDh = true
		end
	elseif isDh == true then
		isDh = false
		if HealthState.Value == 0 then
			HealthState.Value = 1
			print(Progress)
			script.Parent.values.Action.Value = "Nothing"
			task.wait(0.7)
			script.Parent.values.HealProgress.Value = Progress
		end 
	end
end)

-- Spawn protect --
local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local HasMither, MitherTier = Data_Module:GetPerk("NoMither", script.Parent.Parent.Parent)

while task.wait() do
	if not (script:FindFirstChild("REMOVE") ~= nil) then
		if HasMither then
			script.Parent.values.HealthState.Value = 1
		else
			script.Parent.values.HealthState.Value = 2
		end
	else
		break
	end
end 

