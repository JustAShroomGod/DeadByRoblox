local Perk_Data  = game:GetService("ReplicatedStorage"):WaitForChild("Game_Data"):WaitForChild("Perks")

local module = {}

module.Killer = {
	"Defending a hooked survivor closely (camping) buys survivors time to repair generators: camp with caution";
	"Constantly going after 1 survivor (tunneling) buys other survivors time to repair generators";
	"Hitting a survivor with a basic attack interrupts their unhook, but they can unhook when you are on a hit cooldown";
	"The direction killers face is indicated by the red stain, you can ambush survivors by facing away to not show it";
	"Killers can lunge attack by holding down left click, allowing you to hit survivors from further away";
	"While you are carrying a survivor you are slower but you are still able to use your weapon";
}

module.Survivor = {
	"Architect is a Killer that can gain the ability to move faster with a lower turning sensitivity, in this state you can enter a Locker to avoid being hit";
	"Psychopath is a Killer that can enter a frenzy-like state and can see nearby survivor auras, stunning him in this state will give a longer stun duration";
	"Reaper is a Killer that can hit multiple survivors at once if they are affected by the Soul Bound effect, you can use lockers to avoid being hit";
	"Being hit twice by killers results in a down. Some killer powers and perks allow them to down with 1 hit";
	"Downed survivors cannot heal themselves to completely, but need a teammate to recover them";
	"Fast and medium vaulting a window alerts killers to your location from anywhere on the map, slow vaulting does not";
	"A survivor can vault a window 3 times before it is blocked to them. Killers cannot see if a window is blocked";
	"Blocked windows can be vaulted by killers. They vault slower than survivors";
	"Staying in a locker hides your aura to killers, but they can open the locker and grab you";
	"Failing a skill check while repairing a generator will alert killers to your location";
	"Being in a deep wound as survivor will down you after some time, but you can mend to remove it";
	"Fast entering or exiting a locker as survivor alerts killers to your location and makes noise";
	"Exhaustion caused by exhaustion perks as survivor can be recovered if you stand still, walk, or crouch";
	"Loop killers around pallets and not drop them instantly, buying time for your teammates’ generator repair";
	"The strength of pallets and windows depends on how long it takes for killers to navigate around them";
	"Opening chests as survivor grants you a random item. Drop your current held item by pressing “R”";
	"Survivor items include flashlights, toolboxes, medkits. They cannot be used after depletion. You can only hold one";
	"Running as survivor leaves highly visible scratch marks behind you only killers can see, which fade after some time";
	"To recover a health state, survivors can heal each other, self-heal using a perk or a medkit";
	"Being hooked with less than 50% your life bar remaining means death if you are rescued and hooked again";
	"After your 2nd hook you enter the 2nd stage, with 50% less time than the 1st stage to be rescued before death";
	"After your 1st hook you can try 3 self-unhooks, each with a 4% success chance. Failing drains your life bar";
	"Hooks can be sabotaged by toolboxes to prevent hooking. Hooks’ cooldown is based on the toolbox used";
	"Survivors can use flashlights to blind killers";
	"Killers kicking a generator with progress causes it to emit sparks, regressing its progress until a survivor repairs it";
	"Killers can close an open hatch, starting an endgame collapse and powering on the exit ";
	"Survivors can open closed hatches using a key that is rarely found in chests or using a perk";
	"Endgame collapses start if an exit opens, or the hatch is closed. Survivors die if they fail to escape before the clock hits 0";
	"The obsession is a random survivor, indicated by their avatar being inside a black circle";
	"When exposed, survivors are downed with a basic attack, indicated by status effect";
	"When broken, survivors cannot heal themselves or have their teammates heal them from injured to healthy";
	"Curse totems are glowing totems that can be broken by survivors to remove killers’ perks";
	"Hiding is not as effective, as killers can see your scratch marks if you run to hide or by using aura-reading perks";
	"You can save survivors who are picked up by killers by dropping a pallet on them or blinding them";
	"Stunning killers by dropping a pallet on them after you are hit does not increase their stun duration";
}

module.Global = {
	"Shack is a building on most maps, with a strong window and pallet and a potential basement spawn";
	"The basement on each map contains 4 hooks, a chest, lockers. There are no pallets or windows within";
	"7 generators spawn on each map, but only 5 need to be repaired by survivors to open the exits to escape";
	"1 hatch spawns randomly on the map if at least 2 generators have been repaired or if there is 1 survivor alive.";
}

for _,Side in pairs(Perk_Data:GetChildren()) do
	for _,Perk in pairs(Side:GetChildren()) do
		local Perk_Module = require(Perk)
		
		if Perk_Module.Active and not Perk_Module.Testing then
			table.insert(module.Global, Side.Name .. ' perk "' .. Perk_Module.Name .. '" : '  .. Perk_Module.Description)
		end
	end
end

return module
