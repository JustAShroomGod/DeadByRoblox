local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player.PlayerGui

local Button : ImageButton = script.Parent
local themesound = PlayerGui:WaitForChild('Theme')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = {
	Data = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
}

function muteMenu(command)
	
	if command == "mute" then
		themesound.Volume = 0
	elseif command == "unmute" then
		themesound.Volume = 0.1
	end
end

local AUDIO = Modules.Data:Audio()

script.Parent.Audio.Text = "<b>" ..tostring(AUDIO).."</b>"

Button.MouseButton1Click:Connect(function()
	local AUDIO = Modules.Data:Audio(true)

	script.Parent.Audio.Text = "<b>" ..tostring(AUDIO).."</b>"

	if AUDIO then
		muteMenu("unmute")
	else
		muteMenu("mute")
	end
end)

if AUDIO then
	muteMenu("unmute")
else
	muteMenu("mute")
end