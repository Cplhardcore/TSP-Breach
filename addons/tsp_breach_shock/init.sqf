tsp_fnc_breach_shock_wire = {
	params ["_unit", "_explosive", "_magazine", "_fuzeTime", "_triggerItem"]; _length = 30;
	_helper_unit = "ace_fastroping_helper" createVehicle [0,0,0]; _helper_unit allowDamage false; _helper_unit setPos (getPos _unit);
	_helper_ammo = "ace_fastroping_helper" createVehicle [0,0,0]; _helper_ammo allowDamage false; _helper_ammo attachTo [_explosive, [0,0,0], "attach"];
	_rope = ropeCreate [_helper_unit, [0,0,0], _helper_ammo, [0,0,0], _length, ["", [0,0,-1]], ["", [0,0,-1]], "shock_wire"]; _helper_unit setVariable ["rope", _rope];
	while {sleep 0.1; alive _unit && _explosive isNotEqualTo objNull} do {
		if (_unit distance _explosive < (_length-3) && isNull attachedTo _helper_unit) then {_helper_unit attachTo [_unit, [0,0,0], "rightHand"]};
		if (_unit distance _explosive > (_length-2) && !(isNull attachedTo _helper_unit)) then {detach _helper_unit};
	};
	{_unit disableCollisionWith _x; detach _x} forEach [_helper_unit, _helper_ammo];
};

tsp_fnc_breach_shock_wave = {	
	params ["_unit", "_explosive", "_magazine", "_fuzeTime", "_triggerItem"];
	_helpers = attachedObjects _unit select {typeOf _x == "ace_fastroping_helper"};	if (count _helpers == 0) exitWith {}; 
	_rope = (_helpers#0) getVariable "rope"; 
	[_rope, tsp_fnc_breach_shock_wave] remoteExec ["tsp_fnc_breach_shock_wave_global", 0];
};

tsp_fnc_breach_shock_wave_global = {
	params ["_rope"];
	_source = "ace_fastroping_helper" createVehicle [0,0,0]; _source allowDamage false; _source say3D "tsp_breach_fuse";
	{
		if (_forEachIndex % 2 == 0) then {continue}; _source setPosASL (getPosASL _x);
		_light = "#lightpoint" createVehicle (getPos _x);
		_light setLightColor [1,0.5,0.5]; _light setLightAmbient [1,0.5,0.5]; _light setLightBrightness 0.05; _light setLightDayLight true;
		_light spawn {sleep 0.1; deleteVehicle _this}; sleep 0.001;
	} forEach ropeSegments _rope;
	sleep 1; deleteVehicle _source;
};

[{_this spawn tsp_fnc_breach_shock_wave; true}] call ace_explosives_fnc_addDetonateHandler;