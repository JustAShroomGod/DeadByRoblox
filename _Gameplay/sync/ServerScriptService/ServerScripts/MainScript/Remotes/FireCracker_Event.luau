local ReplicatedStorage : ReplicatedStorage, ServerStorage : ServerStorage = game:GetService('ReplicatedStorage'), game:GetService("ServerStorage")
local RemoteStorage = ReplicatedStorage:WaitForChild('RemoteEvents')
local TemplateObjects = ServerStorage:WaitForChild("TemplateObjects")
local DropItems = TemplateObjects:WaitForChild("DropItems")

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
		
		connection.OnServerEvent:Connect(function(Player) 
			local Character = Player.Character
			local Scripts = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
			local playerValues = Scripts:WaitForChild('values')

			playerValues.Action.Value = 'ThrowingFirecracker'

			local hasFirecracker = Character:FindFirstChild("Red_FireCracker")
			
			if hasFirecracker then
				local Track = Player.Character:WaitForChild('Humanoid'):LoadAnimation(script:WaitForChild("Animation"))
				Track:Play()
				
				Track.Stopped:Wait()

				local FireCracker = script:WaitForChild("RedFireCracker"):Clone()
				local FirecrackerHandle = FireCracker:FindFirstChild("Handle")
				
				hasFirecracker:Destroy()
				
				FirecrackerHandle.Anchored = true
				FireCracker:FindFirstChild("Used").Value = true
				FireCracker:SetAttribute("Owner",Player.Name)
				FireCracker:PivotTo(Character:GetPivot() * CFrame.new(1.3, -2.7 + (FirecrackerHandle.Size.Y/2), -2))
				FireCracker["Server-Script"].Enabled = true
				FireCracker.Parent = workspace
			end

			playerValues.Action.Value = 'Nothing'
		end)
	else
		warn('Remote does not exist:', script.Name)
	end

	return self
end

return remote.new()
