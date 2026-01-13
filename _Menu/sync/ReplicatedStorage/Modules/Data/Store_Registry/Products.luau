local module = {}

module[1689353515] = function(_product,player)
	require(script.Parent.Parent):SetCurrency(1500000, player) -- give 1.5m
	return true
end

module[1689353074] = function(_product,player)
	require(script.Parent.Parent):SetCurrency(565000, player) -- give 565k
	return true
end

module[1689349990] = function(_product,player)
	require(script.Parent.Parent):SetCurrency(100000, player) -- give 100k
	return true
end

module[3420127758] = function(_product,player) -- give pass to yourself/gift
	require(script.Parent.Parent):UnlockPass(player)
	return true
end

module[3488013162] = function(_product,player) -- give pass to yourself/gift
	require(script.Parent.Parent):UnlockPass(player)
	warn(script.Parent.Parent)
	return true
end

return module
