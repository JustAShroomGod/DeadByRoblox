script.Parent.Climbing:Connect(function()
	script.Parent:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	script.Parent:ChangeState(Enum.HumanoidStateType.Running)
end)