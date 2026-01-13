local Game_Assets = game:GetService('ReplicatedStorage'):WaitForChild('Game_Assets')

local Heart_Settings = {
	Pump_Rate = 2;
	Tween_Speed = 1;
	Volume_Adjust_Rate = 3; -- tween 3x faster than visuals
	Heart_Min_Alpha = 0.15;
	Heart_Distortion = 0.5; -- makes smaller instead
	Heart_Distances = {
		Min = 5;
		Max = 100;
	}
}

local Heart_Handler = {
	Heart = nil;
	Heart_Audio = nil;
	Heart_Data = {
		Last_Pump = nil;
	},
}

function Tween_Heart(Transparency : number, Lerp : "step")
	Transparency = ((1 - Heart_Settings.Heart_Min_Alpha) * Transparency) + Heart_Settings.Heart_Min_Alpha -->> fix transparency
	
	local Transparency_Alpha = math.clamp(Heart_Handler.Heart.Transparency + ((Transparency - Heart_Handler.Heart.Transparency) * (Lerp * Heart_Settings.Tween_Speed)), Heart_Settings.Heart_Min_Alpha, 1)
	local Color_Alpha = (math.clamp(-(Transparency_Alpha/(1 - Heart_Settings.Heart_Min_Alpha)) + 1, 0, 1) * 255)
	
	--print(Color_Alpha, Transparency_Alpha)
	
	Heart_Handler.Heart.Transparency = Transparency_Alpha
	Heart_Handler.Heart.Color = Color3.fromRGB(255, Color_Alpha, Color_Alpha)
end

function Pump_Heart(Delta_Distance : number) : "Pump the Heart"
	
	if not Delta_Distance then
		Delta_Distance = 1 -- far distance
	end
	
	if not Heart_Handler.Heart_Data.Last_Pump then
		Heart_Handler.Heart_Data.Last_Pump = workspace:GetServerTimeNow()
	end
	
	local Last_Pump, Current_Pump_Rate = (workspace:GetServerTimeNow() - Heart_Handler.Heart_Data.Last_Pump), Heart_Settings.Pump_Rate
	local Distortion = 1
	
	Current_Pump_Rate = Current_Pump_Rate + ((0.25 - Current_Pump_Rate) * (1 - Delta_Distance))
	
	if Last_Pump < Current_Pump_Rate then
		
		if Last_Pump < Current_Pump_Rate/2 then -- grow out
			Distortion = Distortion + ((Heart_Settings.Heart_Distortion - Distortion) * (Last_Pump/(Current_Pump_Rate/2)))
		else -- grow in
			Distortion *= Heart_Settings.Heart_Distortion
			Distortion = Distortion + ((1 - Distortion) * ((Last_Pump - Current_Pump_Rate/2) / (Current_Pump_Rate/2)))
		end
	else -- new heart pump
		Heart_Handler.Heart_Data.Last_Pump = workspace:GetServerTimeNow()
	end
	
	--print(Distortion, Delta_Distance)
	
	Heart_Handler.Heart.Size = Heart_Handler.Heart:GetAttribute("Size") * Distortion
	Heart_Handler.Heart.CFrame = game.Players.LocalPlayer.Character:WaitForChild('UpperTorso').CFrame * Heart_Handler.Heart:GetAttribute("Offset")
end

function Volume_Adjust(New_Volume : number, Step : number) : "Adjust Heart_Beat Volume"
	if not Heart_Handler.Heart_Audio then return end
	
	Heart_Handler.Heart_Audio.PlaybackSpeed = Heart_Handler.Heart_Audio.PlaybackSpeed + (((New_Volume/Heart_Handler.Heart_Audio:GetAttribute("Pitch_Speed")) - Heart_Handler.Heart_Audio.PlaybackSpeed) * (Heart_Settings.Volume_Adjust_Rate * Step))
	Heart_Handler.Heart_Audio.Volume = Heart_Handler.Heart_Audio.Volume + ((New_Volume - Heart_Handler.Heart_Audio.Volume) * (Heart_Settings.Volume_Adjust_Rate * Step))
	
	if New_Volume == 0 and Heart_Handler.Heart_Audio.Volume <= 0.1 then
		Heart_Handler.Heart_Audio.Playing = false
	end
end

function Heart_Handler:Stop(Step) : "Ends Heartbeat"
	Tween_Heart(1, Step)
	Pump_Heart()
	Volume_Adjust(0, Step)
end

function Heart_Handler:Pump_Classic(Distance : number, Sound : Sound, Sound_Settings : "table", Step : number, Muted: boolean, TerrorRadiusMax : number) : "Used for classic heart beat (small audio track replayed)"
	if not (Heart_Settings.Heart_Distances.Max == TerrorRadiusMax) then
		Heart_Settings.Heart_Distances.Max = TerrorRadiusMax
	end
	
	local Delta_Dist = math.clamp(Distance, 0, Heart_Settings.Heart_Distances.Max) - Heart_Settings.Heart_Distances.Min
	Delta_Dist = math.clamp(Delta_Dist, 0, Heart_Settings.Heart_Distances.Max - Heart_Settings.Heart_Distances.Min)/(Heart_Settings.Heart_Distances.Max - Heart_Settings.Heart_Distances.Min)
	
	-- Now Dist is 0-1 perf configured to Radiuses --
	
	if Delta_Dist < 1 then
		if not Heart_Handler.Heart_Audio then
			Heart_Handler.Heart_Audio = Instance.new('Sound', game:GetService('SoundService'))
		end

		if not (Heart_Handler.Heart_Audio.SoundId == Sound.SoundId) then
			Heart_Handler.Heart_Audio.SoundId = Sound.SoundId
		end

		-- Adjust Volume of Heart --
		local Min_Volume, Max_Volume = Sound:GetAttribute('Volume_Min'), Sound:GetAttribute("Volume_Max")
		local Target_Volume : number = ((-Delta_Dist + 1) * (Max_Volume - Min_Volume)) + Min_Volume
		
		-- Use Sound Balancing Now --
		if Sound_Settings then
			Max_Volume = (Sound_Settings.Master/10) * (Sound_Settings.SFX/10) * Max_Volume -- Sets new Max Volume
			Target_Volume = (Sound_Settings.Master/10) * (Sound_Settings.SFX/10) * Target_Volume -- sets new target
		end
		
		Heart_Handler.Heart_Audio:SetAttribute("Pitch_Speed", (Max_Volume / Sound:GetAttribute("Pitch_Speed"))) -- make faster at max vol

		Heart_Handler.Heart_Audio.Playing = true
		Heart_Handler.Heart_Audio.Looped = true
		
		Volume_Adjust(if (not Muted) then Target_Volume else 0, Step)
	else
		Volume_Adjust(0, Step)
	end
	
	Pump_Heart(Delta_Dist)
	Tween_Heart(Delta_Dist, Step)
end

function Heart_Handler:Pump_Music(Distance : number, Sound : Sound, Sound_Settings : "table",  Step : number) : "Used for Lingering Radius (looping audio track)"
	local Delta_Dist = math.clamp(Distance, 0, Heart_Settings.Heart_Distances.Max) - Heart_Settings.Heart_Distances.Min
	Delta_Dist = math.clamp(Delta_Dist, 0, Heart_Settings.Heart_Distances.Max - Heart_Settings.Heart_Distances.Min)/(Heart_Settings.Heart_Distances.Max - Heart_Settings.Heart_Distances.Min)

	-- Now Dist is 0-1 perf configured to Radiuses --

	Pump_Heart(Delta_Dist)
	Tween_Heart(Delta_Dist, Step)
end

function Heart_Handler:Configure() : "Create Our Heart"
	local Screen = Instance.new('ScreenGui', game.Players.LocalPlayer:WaitForChild('PlayerGui'))
	Screen.Name = "Heart_Beat_Handler_Screen"
	Screen.IgnoreGuiInset = true
	
	local View_Port = Instance.new('ViewportFrame', Screen)
	View_Port.CurrentCamera = workspace.CurrentCamera
	View_Port.BackgroundTransparency = 1
	View_Port.Size = UDim2.new(1, 0, 1, 0)
	
	Heart_Handler.Heart = Game_Assets:WaitForChild('Models'):WaitForChild('Heart'):WaitForChild('DefaultNew'):Clone() -- clone us a heart
	Heart_Handler.Heart.Transparency = 1
	Heart_Handler.Heart.Parent = View_Port
	Heart_Handler.Heart.Color = Color3.fromRGB(255, 0, 0)
	Heart_Handler.Heart.Material = Enum.Material.Neon
	
	return Heart_Handler
end

return Heart_Handler:Configure()