local blurEffect = nil
local back = script.Parent.Parent.Button

if workspace.CurrentCamera:FindFirstChild("SWFBlur") == nil then
	blurEffect = Instance.new("BlurEffect", workspace.CurrentCamera)
	blurEffect.Name = "SWFBlur"
	blurEffect.Enabled = false
	blurEffect.Size = 32
else
	blurEffect = workspace.CurrentCamera:FindFirstChild("SWFBlur")
	blurEffect.Enabled = false
end

function BackOut()
	--game.Players.LocalPlayer:WaitForChild("Backpack"):WaitForChild("MCC"):WaitForChild("SWF").Value = false

	game.Players.LocalPlayer.PlayerGui:WaitForChild("ChooseBand").Enabled = true
	blurEffect.Enabled = false
	back.Parent.Body.ImageTransparency = 0.5
	back.Parent.Body.Hover.Visible = false
	back.Parent.Body.Outline.ImageTransparency = 0.4
	back.Parent.Label.TextTransparency = 0.4
end

function BackHovered()
	back.Parent.Body.ImageTransparency = 0
	back.Parent.Body.Hover.Visible = true
	back.Parent.Body.Outline.ImageTransparency = 0
	back.Parent.Label.TextTransparency = 0
end

function backunHovered()
	back.Parent.Body.ImageTransparency = 0.5
	back.Parent.Body.Hover.Visible = false
	back.Parent.Body.Outline.ImageTransparency = 0.4
	back.Parent.Label.TextTransparency = 0.4
end

back.MouseButton1Down:Connect(BackOut)
back.MouseEnter:Connect(BackHovered)
back.MouseLeave:Connect(backunHovered)
