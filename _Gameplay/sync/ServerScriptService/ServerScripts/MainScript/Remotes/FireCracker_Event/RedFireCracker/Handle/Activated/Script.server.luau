local Orientation = script.Parent.Parent.Orientation
while true do
	wait()
	if script.Parent.Value == true then
		if not script.Parent.Parent["Fire Crackling"].IsPlaying then
			script.Parent.Parent["Fire Crackling"]:Play()
		end
		script.Parent.Parent.Beam.Enabled = true
		script.Parent.Parent.ParticleEmitter.Enabled = true
		script.Parent.Parent.Attachment2.Position = Vector3.new(script.Parent.Parent.Attachment2.Position.X,script.Parent.Parent.Attachment2.Position.Y + 35, script.Parent.Parent.Attachment2.Position.Z)
		script.Parent.Parent.Attachment.Position = Vector3.new(script.Parent.Parent.Attachment.Position.X,script.Parent.Parent.Attachment.Position.Y + 5, script.Parent.Parent.Attachment.Position.Z)
	end
end