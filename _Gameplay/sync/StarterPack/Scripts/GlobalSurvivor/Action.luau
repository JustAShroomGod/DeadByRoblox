local Action = {
	Modules = {};
	BugTick = tick()
}

for _,action in pairs(script:GetChildren()) do
	Action.Modules[action.Name] = require(action)
end

function Action:Process(...)
	local args = {...}
	
	Action.BugTick = tick() -- will let me know if it's the loop that breaks
	
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
	
	return available
end

return Action