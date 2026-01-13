local Players : Players, TeleportService : TeleportService, ReplicatedStorage : ReplicatedStorage, TweenService : TweenService = game:GetService("Players"), game:GetService("TeleportService"), game:GetService("ReplicatedStorage"), game:GetService("TweenService")

local Player = Players.LocalPlayer
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local lock = false

script.Parent.Changed:Once(function() --will run once
	if script.Parent.Value and not lock then -- we are disconnecting!
		lock = true

		task.wait(0.5)

		--actual teleporting out--
		local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
		playerGui:SetTopbarTransparency(0)

		local screen = require(game:GetService("ReplicatedFirst"):WaitForChild('TeleportUI').Load).load()

		task.wait(3)

		TeleportService:Teleport(14904820737, Player, {}, screen.object)

		script.Disabled = true
		-- actual teleporting out--
	end
end)
