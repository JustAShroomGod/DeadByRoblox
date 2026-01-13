local union = script.Parent
	while true do
		local Tween = game:GetService("TweenService"):Create(union, TweenInfo.new(1), {Color = Color3.fromRGB(0,0,255)})
		Tween:Play()
		repeat wait() until Tween.PlaybackState == Enum.PlaybackState.Completed
		local Tween = game:GetService("TweenService"):Create(union, TweenInfo.new(1), {Color = Color3.fromRGB(75,0,130)})
		Tween:Play()
		repeat wait() until Tween.PlaybackState == Enum.PlaybackState.Completed
		local Tween = game:GetService("TweenService"):Create(union, TweenInfo.new(1), {Color = Color3.fromRGB(60, 255, 60)})
		Tween:Play()
		repeat wait() until Tween.PlaybackState == Enum.PlaybackState.Completed
		local Tween = game:GetService("TweenService"):Create(union, TweenInfo.new(1), {Color = Color3.fromRGB(194, 87, 0)})
		Tween:Play()
		repeat wait() until Tween.PlaybackState == Enum.PlaybackState.Completed
		local Tween = game:GetService("TweenService"):Create(union, TweenInfo.new(1), {Color = Color3.fromRGB(255,255,255)})
		Tween:Play()
		repeat wait() until Tween.PlaybackState == Enum.PlaybackState.Completed
	end