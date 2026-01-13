local this = {}

this.Killer = {
	Movement = {
		Speed = 0,
		DefaultSpeed = 0;
		SpeedMultiplier = 1.0;
		LungeSpeed = 30;
		WindowVaultSpeed = 1.65;
	},
	Action = {
		DisruptiveActions = 0;
		MissCooldown = 1.5;
		WipeSpeed = 1.0;
		GeneratorBreakSpeed = 1.5;
		PalletBreakSpeed = 1.5;
		WallBreakSpeed = 1.5;
		LungeDuration = 0.6;
		ActionSpeed = 1.0;
	},
	Misc = {
		AuraExtension = 0;
		StunMultiplier = 1;
		SC_Speed = 1;
		SC_Invert = 0; -- if over 0 it will have skill checks spawned going the opposite direction
		SC_Difficulty = 1; -- Scale Factor of Success Zones
	},
}

this.Survivor = {
	Action = {
		RepairSpeed = 11.11;
		HealingSpeed = 60;
		CleanseSpeed = 1.0;
		OpeningSpeed = 1.0;
		ActionSpeed = 1.0;
	},
	Movement = {
		Speed = 0,
		DefaultSpeed = 0,
		SpeedMultiplier = 1.0,
		WindowVaultSpeed = 1;
	},
	Misc = {
		AuraExtension = 0;
		StunMultiplier = 1;
		SC_Speed = 1;
		SC_Invert = 0; -- if over 0 it will have skill checks spawned going the opposite direction
		SC_Difficulty = 1; -- Scale Factor of Success Zones
	},
}

this.Gameplay = {
	GeneratorStackDecrease = 0.1;
	GeneratorRegression = 4.5;
	SkillCheckChances = {
		Generator = 16;
		Healing = 18;
		Medkit = 20;
	}
}

return this
