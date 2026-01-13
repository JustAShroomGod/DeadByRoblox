if true and game:GetService("RunService"):IsStudio() and game:GetService("Players").LocalPlayer.Name == "Bromeri" or game:GetService("Players").LocalPlayer.Name == "KameronLP11"  then
	Postgame = require(script.Parent.Postgame)
	task.wait(20)
	Postgame:Startup()
else
	script.Parent.Enabled = false
	script:Destroy()

end