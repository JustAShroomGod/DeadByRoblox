local Handler = {}
local Strings = {"a", "b", "c", "d", "e", "f", "g", "h", 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'}

local Random_Gen = Random.new()

function RandomLetter() : "Return Random Letter"
	
	if math.random() > .5 then
		return Strings[Random_Gen:NextInteger(1, #Strings)]
	else
		return Strings[Random_Gen:NextInteger(1, #Strings)]:upper()
	end
end

function Handler:GetString(Amount : number) : "Return RNG String Amount"
	local Current = ""
	
	for i = 1, Amount, 1 do
		Current = Current..RandomLetter()
	end
	
	return Current
end

return Handler
