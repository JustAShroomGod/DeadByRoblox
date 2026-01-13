local PlayerGui = game.Players.LocalPlayer:WaitForChild('PlayerGui')

local back = script.Parent.Parent.Button

function BackOut()
	PlayerGui.Blood_Shop.Enabled = false
--	PlayerGui.LoadOutS.Enabled = false	
	PlayerGui.RulesScreen.Enabled = false		
	
	back.Parent.Body.ImageTransparency = 0.5
	back.Parent.Body.Hover.Visible = false
	back.Parent.Body.Outline.ImageTransparency = 0.4
	back.Parent.Label.TextTransparency = 0.4
	PlayerGui.ChooseBand.Enabled = true
	game.Players.LocalPlayer.Character.PrimaryPart.Anchored = false
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

back.MouseEnter:Connect(BackHovered)
back.MouseLeave:Connect(backunHovered)

back.MouseButton1Up:Connect(BackOut)
