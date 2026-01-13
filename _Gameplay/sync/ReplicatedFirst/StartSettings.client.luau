local starterGui = game:GetService('StarterGui')
local resetBindable = Instance.new("BindableEvent")

starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)

task.wait(2.5)

local coreCall do
	local MAX_RETRIES = 8

	local StarterGui = game:GetService('StarterGui')
	local RunService = game:GetService('RunService')

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

starterGui:SetCore("ResetButtonCallback", resetBindable)