local Bell = script.Parent:WaitForChild('Handle')

function SetModifier()
	Bell.LocalTransparencyModifier = Bell.Transparency
end

Bell.LocalTransparencyModifier = Bell.Transparency

Bell:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(SetModifier)
Bell:GetPropertyChangedSignal("Transparency"):Connect(SetModifier)