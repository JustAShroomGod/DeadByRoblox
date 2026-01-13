local StarterGui : StarterGui, RunService : RunService  = game:GetService('StarterGui'), game:GetService('RunService')

local coreCall do
	local MAX_RETRIES = 8

	function coreCall(method, ...)
		local result = {}
		for retries = 1, MAX_RETRIES do
			result = {pcall(StarterGui[method], StarterGui, ...)}
			if result[1] then
				break
			end
			RunService.Stepped:Wait()
		end
		return unpack(result)
	end
end

coreCall('SetCore', 'ResetButtonCallback', false)