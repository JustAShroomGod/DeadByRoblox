local Game_Assets = game:GetService('ReplicatedStorage'):WaitForChild('Game_Assets')

local Chase_Handler = {
	Audio = nil;
	Fade_Rate = 1;
}

function Volume_Adjust(New_Volume : number, Step : number) : "Adjust Heart_Beat Volume"
	if not Chase_Handler.Audio then return end
	
	Chase_Handler.Audio.PlaybackSpeed = Chase_Handler.Audio.PlaybackSpeed + (((New_Volume/Chase_Handler.Audio:GetAttribute("Pitch_Speed")) - Chase_Handler.Audio.PlaybackSpeed) * (Chase_Handler.Fade_Rate * Step))
	Chase_Handler.Audio.Volume = Chase_Handler.Audio.Volume + ((New_Volume - Chase_Handler.Audio.Volume) * (Chase_Handler.Fade_Rate * Step))
	
	if New_Volume == 0 and Chase_Handler.Audio.Volume <= 0.1 then
		Chase_Handler.Audio.Playing = false
	end
end

function Chase_Handler:Stop(Step) : "Ends Heartbeat"
	Volume_Adjust(0, Step)
end

function Chase_Handler:ChangeMusic(AudioId)
	if not Chase_Handler.Audio then
	else
		if not (Chase_Handler.Audio.SoundId == AudioId) then
			Chase_Handler.Audio.SoundId = AudioId
		end
	end
end

function Chase_Handler:Play(Sound : Sound, Sound_Settings : "table", Step : number, AudioId) : "Used for classic heart beat (small audio track replayed)"
	if not Chase_Handler.Audio then
		Chase_Handler.Audio = Instance.new('Sound', game:GetService('SoundService'))
		if AudioId == nil then
			Chase_Handler.Audio.SoundId = Sound.SoundId
		end
		if AudioId ~= nil then
			if not (Chase_Handler.Audio.SoundId == AudioId) then
				Chase_Handler.Audio.SoundId = AudioId
			end
		end
	end

	-- Adjust Volume of Heart --
	local Target_Volume : number = Sound:GetAttribute('Volume')

	-- Use Sound Balancing Now --
	if Sound_Settings then
		Target_Volume = (Sound_Settings.Master/10) * (Sound_Settings.Music/10) * Target_Volume -- sets new target
	end

	Chase_Handler.Audio:SetAttribute("Pitch_Speed", (Target_Volume / Sound:GetAttribute("Speed"))) -- make faster at max vol

	Chase_Handler.Audio.Playing = true
	Chase_Handler.Audio.Looped = true

	Volume_Adjust(Target_Volume, Step)
end

function Chase_Handler:Configure() : "Create Our Heart"
	return Chase_Handler
end

return Chase_Handler:Configure()