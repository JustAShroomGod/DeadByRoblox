script.Parent.OnServerEvent:Connect(function(Player, Code, Info)
	print(Code)
	print(Info)
	if Code == "CodeTestLightIsConnectiondfsdfhdshjfdshjdsdsffdsfs" then
		Info.A.Value = Info.B
	end
end)