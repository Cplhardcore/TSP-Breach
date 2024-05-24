tsp_fnc_breach_silhouette_stick = {
    params ["_unit", "_range", "_explosive", "_fuzeTime", "_triggerItem"];
    sleep _fuzeTime;
    if !('silhouette' in typeOf _explosive) exitWith {};
    _stick = 'tsp_breach_silhouette_stick' createVehicle [0,0,0]; 
    _stick attachTo [_explosive, [0, 0, 1]]; detach _stick; 
    _stick setVelocityModelSpace [0,15,-5]; _stick addTorque [0,20,0];
};

tsp_fnc_breach_silhouette_sticky = {
	params ["_charge"]; if !(local _charge) exitWith {};
	[getText (configFile >> "CfgVehicles" >> (typeOf _charge) >> "ammo"), getPos _charge, []] params ["_class", "_pos", "_dirUp"];
    waitUntil {sleep 0.1; _nulled = _charge isEqualTo objNull; if (!_nulled) then {_dirUp = [vectorDir _charge, vectorUp _charge]}; _nulled};
    _ammo = (allMissionObjects _class) select {_x distance2D _pos < 2}; 
	if (count _ammo > 0) then {_ammo = _ammo#0;
        _visual = createSimpleObject ["tsp_breach_silhouette\silhouette_place.p3d", (getPosASL _ammo) vectorAdd [0,0,0.85]];
		[_visual, _dirUp] remoteExec ["setVectorDirAndUp"]; [_ammo, true] remoteExec ["hideObjectGlobal", 2];
		waitUntil {_ammo isEqualTo objNull}; deleteVehicle _visual;
	};	
};

[{_this spawn tsp_fnc_breach_silhouette_stick; true}] call ace_explosives_fnc_addDetonateHandler;