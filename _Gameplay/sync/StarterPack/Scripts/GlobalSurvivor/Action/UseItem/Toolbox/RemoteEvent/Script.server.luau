script.Parent.OnServerEvent:Connect(function(Player,Generator,ToolBox)
	local CurrentItem = ToolBox
	if Generator ~= nil and (CurrentItem:GetAttribute("Addon_1") == "Brand New Part" or CurrentItem:GetAttribute("Addon_2") == "Brand New Part") then
		ToolBox:Destroy()
		Generator.Value += 150
	end
end)