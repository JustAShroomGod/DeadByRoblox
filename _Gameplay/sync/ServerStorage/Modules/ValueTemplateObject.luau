local RunService = game:GetService("RunService")

local module = {}

module.Values = {}
module.summarize = nil
module.Example = {
	["Value"] = 0,
	["Timer"] = -1,
}

function module.New(func)
	module.summarize = function(...)
		func(...)
	end
end

function module.Add(name: string, value: number, timer: number)
	
	local set = table.clone(module.Example)
	set.Value = value
	set.Timer = if (timer == nil) then -1 else timer
	
	module.Values[name] = set
	
	if (timer)  then
		if (timer > 0) then
			module.TickTimer(name)
		end
	end
	module.Summarize()
end

function module.Remove(name: string)
	if (module.Values[name] ~= nil) then
		module.Values[name] = nil
		module.Summarize()
	end
end

function module.TickTimer(name)
	
	local runner
	runner = RunService.Heartbeat:Connect(function(delta)
		local set = module.Values[name]
		set.Timer -= delta
		
		if (set.Timer <= 0) then
			module.Values[name] = nil
			module.Summarize()
			
			runner:Disconnect()
			runner = nil
		else
			module.Values[name] = set
		end
	end)
end

function module.Summarize()
	
	local sum = 0
	
	for key, valueSet in pairs(module.Values) do
		sum += valueSet.Value
	end
	
	module.summarize(sum)
end

return module
