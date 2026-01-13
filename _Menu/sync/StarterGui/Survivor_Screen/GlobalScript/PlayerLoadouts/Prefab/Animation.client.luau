local TweenService = game:GetService("TweenService")

local Load = script.Parent.Load
local Delete = script.Parent.Delete

local Tweens = {Load = nil; Delete = nil}

Load.MouseEnter:Connect(function()
	
	if (Tweens["Load"] ~= nil) then
		Tweens["Load"]:Cancel()
		Tweens["Load"] = nil
	end
	
	Tweens["Load"] = TweenService:Create(Load, TweenInfo.new(0.5), {BackgroundTransparency = 0.925})
	Tweens["Load"]:Play()
end)

Load.MouseLeave:Connect(function()
	
	if (Tweens["Load"] ~= nil) then
		Tweens["Load"]:Cancel()
		Tweens["Load"] = nil
	end

	Tweens["Load"] = TweenService:Create(Load, TweenInfo.new(0.5), {BackgroundTransparency = 1})
	Tweens["Load"]:Play()
end)

Delete.MouseEnter:Connect(function()

	if (Tweens["Delete"] ~= nil) then
		Tweens["Delete"]:Cancel()
		Tweens["Delete"] = nil
	end

	Tweens["Delete"] = TweenService:Create(Delete, TweenInfo.new(0.5), {BackgroundTransparency = 0.925})
	Tweens["Delete"]:Play()
end)

Delete.MouseLeave:Connect(function()

	if (Tweens["Delete"] ~= nil) then
		Tweens["Delete"]:Cancel()
		Tweens["Delete"] = nil
	end

	Tweens["Delete"] = TweenService:Create(Delete, TweenInfo.new(0.5), {BackgroundTransparency = 1})
	Tweens["Delete"]:Play()
end)