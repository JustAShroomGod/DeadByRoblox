local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TeleportService = game:GetService('TeleportService')
local teleportData = TeleportService:GetLocalPlayerTeleportData()
local remote = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Key')

--print('CLIENT - Player had:', teleportData)


if teleportData then
	remote:FireServer("Data_Transfer", teleportData)
	--warn('CLIENT DID HAVE TP DATA : ', TeleportService:GetLocalPlayerTeleportData())
end