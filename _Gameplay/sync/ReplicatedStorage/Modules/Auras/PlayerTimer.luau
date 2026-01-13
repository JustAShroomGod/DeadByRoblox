local RunService = game:GetService("RunService")

local timer = 0
local maxTimer = 0

local runner = nil
local auras = nil

local Timer = {}

function Timer.Start(Duration: number, Auras: ModuleScript)
	
	timer = Duration
	maxTimer = Duration
	auras = Auras
	
	runner = RunService.Heartbeat:Connect(function(delta)
		timer -= delta
		
		if (timer > 0) then
			return
		end
		
		auras.RemovePlayerAura(script.Parent.Name, script.Parent.Parent.Name)
		script:Destroy()

		runner:Disconnect()
		runner = nil
	end)
end

function Timer.Refresh()
	if (timer > maxTimer) then
		return
	end
	
	timer = maxTimer
end

function Timer.Set(Value: number)
	timer = Value
end

function Timer.Increase(Value: number)
	timer += Value
end

function Timer.Decrease(Value: number)
	timer -= Value
	
	if (timer > 0) then
		return
	end
	
	auras.RemovePlayerAura(script.Parent.Name, script.Parent.Parent.Name)
	script:Destroy()

	runner:Disconnect()
	runner = nil
end

return Timer
