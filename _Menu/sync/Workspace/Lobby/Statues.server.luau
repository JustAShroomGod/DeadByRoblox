local prefix = "rbxassetid://"

local children = script:GetChildren()

for x, char in pairs (children) do
	local humanoid = char.Humanoid

	local id = 14220607791  --13610230142 --5644839876

	if char.Name == "Bromeri" then
		id = 14220961743
	elseif char.Name == "VeroxCode" then
		id = 14226780290
	elseif char.Name == "Wraith" then
		id = 7911731609
	elseif char.Name == "K0_rd" then
		id = 18524179624
	elseif char.Name == "cream_aw" then
		id = 105028256175884
	elseif char.Name == "PoIarPatroller" then
		id = 18868307051
	elseif char.Name == "cheetamcu" then
		id = 18524179624
	elseif char.Name == "PaRK_JimIN9555" then
		id = 18524179624
	elseif char.Name == "its_o9ine" then
		id = 18524179624
	elseif char.Name == "Bromeri_Dance" then
		id = 10258272240
	elseif char.Name == "juauelmior1212" then
		id = 18868307051
	elseif char.Name == "Eepyling" then
		id = 18868307051
	elseif char.Name == "12fp" then
		id = 18868307051
		elseif char.Name == "GreatAnthony100" then
		id = 18868307051
	elseif char.Name == "Kum1lite" then
		id = 18868307051
	elseif char.Name == "Danielo" then
		id = 10258272240
	end

	local animation = Instance.new("Animation", char)
	animation.AnimationId = prefix.. tostring(id)

	local animtrack = humanoid:LoadAnimation(animation)
	animtrack:Play()
end


--10258272240 dance animation
