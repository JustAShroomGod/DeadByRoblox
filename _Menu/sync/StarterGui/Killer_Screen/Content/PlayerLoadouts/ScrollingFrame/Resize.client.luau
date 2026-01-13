local GridLayout = script.Parent.UIGridLayout

GridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	script.Parent.CanvasSize = UDim2.new(0, 0, 0, GridLayout.AbsoluteContentSize.Y + 6)
end)