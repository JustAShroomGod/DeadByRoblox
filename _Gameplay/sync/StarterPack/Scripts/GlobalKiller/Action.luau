local KillerModules = game:GetService('ReplicatedStorage'):WaitForChild('KillerModules')

local Action = {
	Modules = {};
	Powers = {};
	CollectedPower = false;
}

for _,action in pairs(script:GetChildren()) do
	Action.Modules[action.Name] = require(action)
end



function Action:Process(...)
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	
	local available = {}
	
	for _, action in pairs(Action.Modules) do
		
		if action:Process(actionList, remoteList, modules) then
			
			if available[action.Key] then
				
				if available[action.Key].ActionName ~= action.ActionName -- different action
					and available[action.Key].Priority > action.Priority then -- new action is higher in priority
					
					available[action.Key] = action
				end
			else
				available[action.Key] = action
			end
		end
	end
	
	if not Action.CollectedPower then
		Action.CollectedPower = true

		local OurModules = KillerModules:WaitForChild(modules.Data:GetCharacter())
		
		for _, mod in pairs(OurModules:GetChildren()) do
			Action.Powers[mod.Name] = require(mod)
		end
	end
	
	for _, powerAction in pairs(Action.Powers) do
		
		if powerAction:Process(actionList, remoteList, modules) then
			
			if available[powerAction.Key] then
				
				if available[powerAction.Key].ActionName ~= powerAction.ActionName
					and available[powerAction.Key].Priority > powerAction.Priority then
					
					available[powerAction.Key] = powerAction
				end
			else
				available[powerAction.Key] = powerAction
			end
		end
	end
	
	return available
end

return Action