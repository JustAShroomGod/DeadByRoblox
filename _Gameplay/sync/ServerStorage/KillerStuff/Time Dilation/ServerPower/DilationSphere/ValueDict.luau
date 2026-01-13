local ValueDict = {}

function ValueDict.Get()
	return {
		
		-- Universal Values
		SC_Speed = false;
		ActionSpeed = false;
		StunMultiplier = false;
		SpeedMultiplier = false;
		WindowVaultSpeed = true;
		
		-- Killer Values
		WipeSpeed = false;
		LungeSpeed = false;
		MissCooldown = true;
		LungeDuration = false;
		WallBreakSpeed = true;
		PalletBreakSpeed = true;
		GeneratorBreakSpeed = true;
		
		-- Survivor Values
		RepairSpeed = false;
		HealingSpeed = false;
		CleanseSpeed = false;
		OpeningSpeed = false;
	}
end

return ValueDict
