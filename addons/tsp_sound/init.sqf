addMissionEventHandler ["Map", {	
	params ["_isOpened","_isForced"];
	if (!tsp_cba_sound_map) exitWith {};
	if (_isOpened) then {
		playSound3D ["tsp_sound\snd\mapOpened.ogg", player, false, getPosASL player, 4.9, 1, 50];
	} else {
		playSound3D ["tsp_sound\snd\mapClosed.ogg", player, false, getPosASL player, 4.9, 1, 50];
	};
}];
player addEventHandler ["inventoryOpened", {if (!tsp_cba_sound_inv) exitWith {};playSound3D ["tsp_sound\snd\inventoryOpened.ogg", player, false, getPosASL player, 4.9, 1, 20]}];
player addEventHandler ["inventoryClosed", {if (!tsp_cba_sound_inv) exitWith {};playSound3D ["tsp_sound\snd\inventoryClosed.ogg", player, false, getPosASL player, 4.9, 1, 20]}];
player addEventHandler ["take", {if (!tsp_cba_sound_inv) exitWith {};if (!isNull (findDisplay 602)) then {playSound3D ["tsp_sound\snd\take.ogg", player, false, getPosASL player, 4.9, 1, 20]}}];
player addEventHandler ["put", {if (!tsp_cba_sound_inv) exitWith {};if (!isNull (findDisplay 602)) then {playSound3D ["tsp_sound\snd\put.ogg", player, false, getPosASL player, 4.9, 1, 20]}}];
