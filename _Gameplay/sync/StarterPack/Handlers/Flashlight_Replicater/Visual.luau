-- Variables --
local camera = workspace.CurrentCamera
local player = game.Players.LocalPlayer
local player_hud = player.PlayerGui:WaitForChild("HUD")
local blindingFrame = player_hud:WaitForChild("BlindingFrame")
-- Variables --

local brightness = {
	["Settings"] = {
		["MaxBrightness"] = 2;
		["MaxBlur"] = 30
	};
	["Effects"] = {
		["Blur"] = Instance.new("BlurEffect", camera);
		["Brightness"] = Instance.new("ColorCorrectionEffect", camera);
	};
}
brightness.Effects.Blur.Enabled = false

function brightness.Update(value)
	if not value then value = 0 end
	
	brightness.Effects.Blur.Enabled = value > 0
	
	blindingFrame.Transparency = if (value > 0) then (1 - (value / 100)) else 1
	brightness.Effects.Blur.Size = (value * brightness.Settings.MaxBlur)/100
end

return brightness
