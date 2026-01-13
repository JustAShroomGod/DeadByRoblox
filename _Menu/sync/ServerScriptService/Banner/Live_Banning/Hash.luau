local module = {}

function module:Generate(data_points : Message, length : number)
	local LegalCharacters = "_AaBbCcDdEeFfG-gHhIiJjK*kLlMm.NnOo/PpQqRrSsTtUuVvWwXxY#yZz1234567890" -- the characters that our hash will consist of
	local Curr_Hash = ""
	
	local str = game:GetService('HttpService'):JSONEncode(data_points)
	local string_length = string.len(str)
	
	local Country = string.byte(data_points.Country)
	local Time = string.byte(data_points.Clo)
	local Age = string.byte(data_points.Age)
	local Device = string.byte(data_points.Dev)
	local Verified = if data_points.Verified then 1 else 0
	
	local SEED = Country..Time..Age..Device..string_length..data_points.UP..Verified
	
	local rng = Random.new(SEED) -- length / clock_time
	
	for curr_char = 1, length do -- attach hashing
		local unrandom_num = rng:NextInteger(1, #LegalCharacters)
		local random_char = string.sub(LegalCharacters, unrandom_num, unrandom_num)
		
		Curr_Hash..= random_char
	end
	
	return Curr_Hash
end

return module
