local this = {}

local Remotes = game.ReplicatedStorage.RemoteEvents
local Server = script.Parent.Server
local Gameplay = script.Parent.Gameplay
local Survivor = script.Parent.Survivor
local Killer = script.Parent.Killer

this.Remotes = {
	ClientAttack = Remotes.EventRemotes.ClientAttack;
	ActionEvent = Remotes.EventRemotes.ActionEvent;
	MouseEvent = Remotes.EventRemotes.MouseEvent;
	InputEvent = Remotes.EventRemotes.InputEvent;
}

this.Server = {
	Heartbeat = Server.HeartBeat;
	Stepped = Server.Stepped;
}

this.Gameplay = {
	onMouseEvent = Gameplay.onMouseEvent; -- Arguments: Player, Key, Down
	onInputEvent = Gameplay.onInputEvent; -- Arguments: Player, KeyCode, Down
	onGeneratorRepaired = Gameplay.onGeneratorRepair; -- Arguments: Workers, Object
	onExitPowered = Gameplay.onExitPowered; -- Arguments: None
	onTotemTransfer = Gameplay.onTotemTransfer; -- Arguments: Totem, NewTotem
}

this.Survivor = {
	onGraspRescue = Survivor.onGraspRescue; -- Arguments: Rescuer 
	onGraspEscape = Survivor.onGraspEscape; -- Arguments: Survivor 
	onKillerStun = Survivor.onKillerStun; -- Arguments: Survivor, Killer
	onHookRescue = Survivor.onHookRescue; -- Arguments: Rescuer, RescuedSurv
	onVault = Survivor.onVault; -- Arguments: Player, Type (Wall, Pallet)
	onTotemBreak = Survivor.onTotemBreak; -- Arguments: Player, Type: Dull/Hex, Object
	onLockerEnter = Survivor.onLockerEnter; -- Arguments: Player, Rushed (bool), Object
	onLockerLeave = Survivor.onLockerLeave; -- Arguments: Player, Rushed (bool), Object
	onKillerFlashed = Survivor.onKillerFlashed; -- Arguments: Killer, Survivor
	onTotemBlessed  = Survivor.onTotemBlessed; -- Arguments: Survivor, Totem
	onHealingFinished = Survivor.onHealingFinished; -- Arguments: Survivor, Healers[]
	onCustomEvent = Survivor.CustomEvent; -- Arguments: Type, ...
}

this.Killer = {
	onAttack = Killer.onAttack; -- Arguments: State (Nothing, Object, Hit), ObjectName
	onStun = Killer.onStun; -- Arguments: Type (Stun Type), Killer
	onBreak = Killer.onBreak; -- Arguments: Killer, Type (Wall, Pallet), Object
	onVault = Killer.onVault;-- Arguments: Type
	onGrasp = Killer.onGrasp; -- Arguments, Killer, Survivor
	onLockerSearch = Killer.onLockerSearch; -- Arguments: Killer, Survivor, Object
	onHook = Killer.onHook; -- Arguments: Killer, Survivor, Object
	onTotemCrushed = Killer.onTotemCrushed; -- Arguments: Killer, Totem
	onCustomEvent = Killer.CustomEvent; -- Arguments: Type, ...
}

return this
