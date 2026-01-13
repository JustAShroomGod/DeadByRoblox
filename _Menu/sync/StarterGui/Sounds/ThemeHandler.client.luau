local prefix = "rbxassetid://"
local sound = script.Theme
local killerbreathsound = sound.Parent.Parent.KillerBreathSound
local killer_character = game.Players.LocalPlayer:WaitForChild("Data"):WaitForChild("Loadout"):WaitForChild("Killer")
local RunService = game:GetService("RunService")


local SOUNDIDS = { --list of sound ids
	["default"] = 9909356605, -- NEEDS REPLACING --
	["Survivor"] = 15088520699, --survivor theme 1574351145
	["Killer"] = 15088520699, -- NEEDS REPLACING --
	--["halloween"] = 15088692480, --halloween theme
}

RunService.Stepped:Connect(function()
	if killer_character.Value == "Trapper" then
		--killerbreathsound.SoundId = prefix.. 9081177146
	--elseif killer_character.Value == "Wraith" then
		--killerbreathsound.SoundId = prefix.. 7106139870 --sound not loading
	else
		killerbreathsound.SoundId = "" --if no other character then nothing
	end
end)


local CurrentSongInUse = "" --the soundid that will be placed here

--function to update which menu (context) we are on
local function update(context)
	if context == "Survivor" then
		CurrentSongInUse = SOUNDIDS.default
		--killerbreathsound.Playing = false
	elseif context == "Killer" then
		CurrentSongInUse = SOUNDIDS.default
		--killerbreathsound.Playing = true
	elseif context == "MenuScreen" then
		CurrentSongInUse = SOUNDIDS.default
	end
end

RunService.Heartbeat:Connect(function()
	if --[[game.Players.LocalPlayer.PlayerGui:WaitForChild("PreMS").Enabled then
		update("Survivor")
	elseif game.Players.LocalPlayer.PlayerGui:WaitForChild("PreMK").Enabled then
		update("Killer")
	elseif]] game.Players.LocalPlayer.PlayerGui:WaitForChild("ChooseBand").Enabled then
		update("MenuScreen")
end
	
	if not (sound.SoundId == prefix.. CurrentSongInUse) then
		sound.SoundId = prefix.. CurrentSongInUse
	end
end)

sound:Play()
