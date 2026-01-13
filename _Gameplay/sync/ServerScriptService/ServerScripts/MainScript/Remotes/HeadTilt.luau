local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')

local remote = {}

local function GrabRemote()
	
	for _,r in pairs(RemoteStorage:GetChildren())do
		
		if string.lower(r.Name) == string.lower(script.Name) then
			return r
		end
	end
	
	return false
end

function remote.new()
	local self = {}
	setmetatable(self, remote)
	
	local connection = GrabRemote()
	
	if connection then
		
		connection.OnServerEvent:Connect(function(player, ...)
			if not player.Character then return end
			local args = {...}

			local Neck = player.Character.Head.Neck
			
			if args[1] == "Default" then
				Neck.C0 = CFrame.new(Neck.C0.Position) * CFrame.Angles(0, 0, 0)
			else
				local Converted = math.clamp(math.deg(args[1]), -50, 90)
				Neck.C0 = CFrame.new(Neck.C0.Position) * CFrame.Angles(math.rad(Converted), 0, 0)
			end
		end)
	else
		warn('Remote does not exist:', script.Name)
	end
	
	return self
end

return remote.new()
