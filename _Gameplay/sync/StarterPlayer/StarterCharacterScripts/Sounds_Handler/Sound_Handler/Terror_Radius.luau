local TweenService = game:GetService("TweenService")
local Game_Assets = game:GetService('ReplicatedStorage'):WaitForChild('Game_Assets')

local Radius_Handler = {
	Audios = {};
	Fade_Rate = 0.35;
}

local function lerp(a, b, x)
	return (a + ((b - a) * x))
end

function Volume_Adjust(Sound, New_Volume : number, Step : number) : "Adjust Heart_Beat Volume"
	Sound.Volume = lerp(Sound.Volume, New_Volume, Radius_Handler.Fade_Rate * Step)
end

function Radius_Handler:Stop(Step) : "Ends Heartbeat"
	for _,OtherSound in pairs(Radius_Handler.Audios) do
		Volume_Adjust(OtherSound, 0, Step)
	end
end

function Radius_Handler:Play(Sound : Sound, Sound_Settings : "table", Step : number, Delta_Dist) : "Used for classic heart beat (small audio track replayed)"
	if not Radius_Handler.Audios[Sound.Name] then
		Radius_Handler.Audios[Sound.Name] = Instance.new('Sound', game:GetService('SoundService'))
		Radius_Handler.Audios[Sound.Name].SoundId = Sound.SoundId
	end
	
	for _,OtherSound in pairs(Radius_Handler.Audios) do
		if OtherSound == Radius_Handler.Audios[Sound.Name] then continue end -- dont touch the one we want to change
		if OtherSound.Volume == 0 or OtherSound.Playing == false then continue end

		Volume_Adjust(OtherSound, 0, Step)
	end
	
	-- Adjust Volume of Heart --
	local Target_Volume : number = Sound:GetAttribute('Volume')

	-- Use Sound Balancing Now --
	if Sound_Settings then
		Target_Volume = (Sound_Settings.Master/10) * (Sound_Settings.Music/10) * Target_Volume -- sets new target
	end

	if not Radius_Handler.Audios[Sound.Name].Playing then
		Radius_Handler.Audios[Sound.Name].Playing = true
		Radius_Handler.Audios[Sound.Name].Looped = true
	end

	Volume_Adjust(Radius_Handler.Audios[Sound.Name], Target_Volume, Step)
end

function Radius_Handler:Configure() : "Create Our Heart"
	return Radius_Handler
end

return Radius_Handler:Configure()