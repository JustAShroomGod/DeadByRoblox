local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	return 100, 1 -- return percentage or percentage.Value (pretty sure returning raw value would still work, but would make a lot and I mean a lot of connetions taht could be problematic.)
end

return Perk_Progress
