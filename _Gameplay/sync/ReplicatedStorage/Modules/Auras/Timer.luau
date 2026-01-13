local RunService = game:GetService("RunService")

local timer = 0
local maxTimer = 0

local default = false
local runner = nil
local auras = nil
local alias = ""

local Timer = {}

function Timer.Start(Duration: number, Auras: ModuleScript, CreateAsDefault: boolean, Alias: string)
	
	timer = Duration
	maxTimer = Duration
	auras = Auras
	default = CreateAsDefault
	alias = Alias
	
	runner = RunService.Heartbeat:Connect(function(delta)
		timer -= delta
		
		if (timer <= 0) then
			auras.RemoveAura(Alias, script.Parent.Parent.Name, default)
			script:Destroy()

			runner:Disconnect()
			runner = nil
		end
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
	
	if (timer <= 0) then
		auras.RemoveAura(alias, script.Parent.Parent.Name, default)
		script:Destroy()
		
		runner:Disconnect()
		runner = nil
	end
end

return Timer
