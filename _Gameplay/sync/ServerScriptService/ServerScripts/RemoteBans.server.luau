local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

function BanReceive(Message)

	local Data = Message.Data
	Data = HttpService:JSONDecode(Data)
	local _UserId, _Reason, _Duration, _Notes, _ExcludeAlts = Data["UserId"], Data["Reason"], Data["Duration"], Data["Notes"], Data["ExcludeAlts"]
	_Duration = tonumber(_Duration)
	_UserId = tonumber(_UserId)
	
	local Ban = (_Reason ~= "Unban")
	
	if (Ban) then
		Players:BanAsync(
		{
			UserIds = {_UserId},
			Duration = _Duration,
			DisplayReason = _Reason,
			PrivateReason = _Notes or "",
			ExcludeAltAccounts = _ExcludeAlts,
			ApplyToUniverse = true
		})
	else
		Players:UnbanAsync({
			UserIds = {_UserId},
			ApplyToUniverse = true
		})
		
		Players:UnbanAsync({
			UserIds = {_UserId},
			ApplyToUniverse = false
		})
	end

end

MessagingService:SubscribeAsync("RemoteBans", BanReceive)