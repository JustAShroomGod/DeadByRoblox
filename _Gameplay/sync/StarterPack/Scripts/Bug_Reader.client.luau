local Remotes = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
local bug_reader = Remotes:WaitForChild('Bug_Reader')

bug_reader.OnClientEvent:Connect(function(...)
	local args = {...}
	
	local Context = args[1]
	local Result = args[2]
	
	print('//////////////////////')
	warn(Context, ':', Result)
	print('//////////////////////')
end)