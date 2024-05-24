if (!tsp_cba_breach) exitWith {};

[{_this spawn {  //-- Handle explosives goaing off
    params ["_unit", "_range", "_explosive", "_fuzeTime", "_triggerItem"];
	[_unit, ["OMLightSwitch", 50]] remoteExec ["say3D", 0];
	sleep _fuzeTime;
	_environmentDamage = getArray (configFile >> "CfgAmmo" >> (typeOf _explosive) >> "environmentDamage");  //-- Get explosive breaching data
	if (_environmentDamage isEqualTo []) exitWith {};
	[_explosive, _environmentDamage, getNumber (configFile >> "CfgAmmo" >> (typeOf _explosive) >> "swingAmount")] call tsp_fnc_breach_explosive;
	[_explosive, _environmentDamage] call tsp_fnc_breach_wall;
	if (_environmentDamage#0 == 1) then {(getPos _explosive) spawn {sleep 0.2; [_this, 7] call tsp_fnc_breach_glass}};  //-- Add delay so it matches explosion
	true
}}] call ace_explosives_fnc_addDetonateHandler;

["if (['door', _this#4] call BIS_fnc_inString && tsp_cba_breach_vanilla) then {hint 'Vanilla Door Actions are Disabled'; true} else {false};"] spawn tsp_fnc_addUIEvent;  //-- Vanilla actions
["ace_interactMenuOpened", {params ["_type"]; if (tsp_cba_breach_ace && _type == 0) exitWith {[tsp_playa] spawn tsp_fnc_breach_action}}] call CBA_fnc_addEventHandler;   //-- ACE actions
player addEventHandler ["FiredMan", {params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo"]; [_unit, _ammo] spawn tsp_fnc_breach_gun}];                               //-- Handle gunshot
if (isServer && tsp_cba_breach_lock_house != 0) then {[[0,0,0], 900000, tsp_cba_breach_lock_house, tsp_cba_breach_lock_door] call tsp_fnc_breach_lock};                //-- Lock random doors