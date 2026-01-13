local module = {}
local http = game:GetService('HttpService')
local encryptor = require(script:WaitForChild('library'):WaitForChild('aeslua'))

local Password = "Alt_Dentified"

function module:Path(data : "table", Player : Player)
	local converted = http:JSONEncode(data)
	
	converted = encryptor.encrypt(Password..'_'..Player.UserId, converted, 16, 2)
	
	return converted
end

return module
