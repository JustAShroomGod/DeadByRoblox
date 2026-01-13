local Beams = {}
local Template = script.Parent.Parent:WaitForChild("Sample")

script.Parent.OnServerEvent:Connect(function(Player,Info)
	local G = false
	local Name, Enabled, Attach0, Attach1 = Info[1], Info[2], Info[3], Info[4]
	if Attach1 and Attach1.Parent and (Attach1:FindFirstChild("RootRigAttachment") ~= nil) then
		if Attach0 and Attach0.Parent and (Attach0:FindFirstChild("RootRigAttachment") ~= nil) then
			G = true
		end
	end
	if G == true then
		local Beam = nil
		if Beams[Name] then
			Beam = Beams[Name]
		else
			local newBeam = Template:Clone()
			newBeam.Parent = workspace.Terrain
			Beams[Name] = newBeam
			Beam = Beams[Name]
		end
		Beam.Enabled = Enabled
		if Attach0 and Attach0.Parent and (Attach0:FindFirstChild("RootRigAttachment") ~= nil) then
			Beam.Attachment0 = Attach0.RootRigAttachment
		end
		if Attach1 and Attach1.Parent and (Attach1:FindFirstChild("RootRigAttachment") ~= nil) then
			Beam.Attachment1 = Attach1.RootRigAttachment
		end
	else
		if Beams[Name] then
			Beams[Name]:Destroy()
			Beams[Name] = nil
		end
	end
end)
