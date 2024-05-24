tsp_fnc_breach_doors = {  //-- Get doors in radius
	params ["_center", ["_actionRadius", 10], ["_houseRadius", 25], ["_doors", []]];
	{  //-- For all houses in radius 
		_house = _x;
		{  //-- For all door useractions in house
			_actionClass = _x;
			if !(["door", _actionClass] call BIS_fnc_inString) then {continue}; 
			_actionName = (getText (configOf _house >> "UserActions" >> _actionClass >> "actionNamedSel"));
			if (_actionName == "") then {_actionName = (getText (configOf _house >> "UserActions" >> _actionClass >> "position"))};
			_actionPos = _house modelToWorldWorld (_house selectionPosition _actionName);
			if (count (_doors select {_x#3 distance _actionPos < 1}) > 0.1 || _center distance _actionPos > _actionRadius) then {continue};  //-- If too close to another door or center of house, dont count it
			_doors pushBack [_house, _actionClass, _actionName, _actionPos];
		} forEach ((configfile >> "CfgVehicles" >> typeOf _house >> "UserActions") call BIS_fnc_getCfgSubClasses); 
	} forEach (nearestObjects [ASLtoATL _center, ["Static"], _houseRadius]);
	_doors
};

tsp_fnc_breach_data = {  //-- Get ALL the door data
	params ["_house", "_door", ["_animName", "NO"]];
	_id = [_door, "0123456789"] call BIS_fnc_filterString;
	_pos = _house modelToWorldWorld (_house selectionPosition _door);  //-- Actual door selection pos
	_animName = ({if ((_x find "door" != -1 || _x find "Door" != -1) && _x find _id != -1 && _x find "_handle" == -1) exitWith {_x}} forEach (animationNames _house));
	_animPhase = _house animationPhase _animName;
	_locked = _house getVariable ["bis_disabled_Door_" + _id, 0];
	_triggerName = "NO"; ({if (_x find "trigger" != -1 && _id isEqualTo ([_x, "0123456789"] call BIS_fnc_filterString)) exitWith {_triggerName = _x}} forEach (_house selectionNames "MEMORY"));
	_triggerPos = _house modelToWorldWorld (_house selectionPosition [_triggerName, "Memory"]); if (ASLtoAGL _triggerPos distance _house < 1) then {_triggerPos = _pos};
	_handleName = "NO";({if (_x find "handle" != -1 && _id isEqualTo ([_x, "0123456789"] call BIS_fnc_filterString)) exitWith {_handleName = _x}} forEach (_house selectionNames "MEMORY"));
	_handlePos = _house modelToWorldWorld (_house selectionPosition [_handleName, "Memory"]); if (ASLtoAGL _handlePos distance _house < 1 || _animPhase == 1) then {_handlePos = _triggerPos};
	_hingeName = "NO";({if (_x find "axis" != -1 && _id isEqualTo ([_x, "0123456789"] call BIS_fnc_filterString)) exitWith {_hingeName = _x}} forEach (_house selectionNames "MEMORY"));
	_hingePos = _house modelToWorldWorld (_house selectionPosition [_hingeName, "Memory"]); if (ASLtoAGL _hingePos distance _house < 1) then {_hingePos = _handlePos};
	[_id, _house, _door, _pos, _animName, _animPhase, _locked, _triggerName, _triggerPos, _handleName, _handlePos, _hingeName, _hingePos]
};

tsp_fnc_breach_intersect = {  //-- Gets door/wall between 2 points
	params ["_start", "_end", ["_ignore", objNull]];	
	((lineIntersectsSurfaces [_start, _end, _ignore, objNull, true, 1, "GEOM"])#0) params ["_intersectPos", "_normal", "_object"]; if (isNil "_object") exitWith {[]};  //-- Get house
	(([_object, "GEOM"] intersect [ASLToAGL _start, ASLToAGL _end])#0) params ["_selection", "_distance"]; if (isNil "_selection") exitWith {[_object]}; if !("door" in _selection) exitWith {[_object]};
	[_object, _selection] call tsp_fnc_breach_data;  //-- Just return everything about door, "doorData"
};

tsp_fnc_breach_action = {  //-- Add ACE actions
	params ["_unit"];
	{deleteVehicle _x} forEach (missionNameSpace getVariable ["tsp_breach_allActionsHelpers",[]]); tsp_breach_allActionsHelpers = [];  //-- Delete all old helpers on opening menu
	{  //-- For all door actions in radius
		_x params ["_house", "_actionClass", "_actionName", "_actionPos"];
		([_house, _actionName] call tsp_fnc_breach_data) params ["_id","_house","_door","_pos","_animName","_animPhase","_locked","_triggerName","_triggerPos","_handleName","_handlePos","_hingeName","_hingePos"];
		_helper = "ACE_LogicDummy" createVehicleLocal [0,0,0]; _helper setPosASL _handlePos; tsp_breach_allActionsHelpers pushBack _helper;  //-- Create helper object, ace_marker_flags_red // ACE_LogicDummy
		_mainAction = ["main", "Door", "", {true}, {  //-- Create main action
			_this params ["_helper", "_unit", "_passed"]; _passed params ["_house", "_actionName"];
			_helper setVariable ["doorData", [_house, _actionName] call tsp_fnc_breach_data];  //-- Set variable on its helper to pass the "doorData"
		}, {}, [_house, _actionName], {[0,0,0]}, 2.5, [false, false, false, false, true]] call ace_interact_menu_fnc_createAction;
		[_helper, 0, [], _mainAction] call ace_interact_menu_fnc_addActionToObject;  //-- Add main action to "_helper"
		{
			_x params ["_name", "_image", "_code", "_condition"];
			_params = {_doorData = ((_this#0) getVariable "doorData"); _doorData params ["_id","_house","_door","_pos","_animName","_animPhase","_locked","_triggerName","_triggerPos","_handleName","_handlePos","_hingeName","_hingePos"];};
			_action = [_id, _name, _image, compile (((str _params) trim ["{}", 0]) + ((str _code) trim ["{}", 0])), compile (((str _params) trim ["{}", 0]) + ((str _condition) trim ["{}", 0])), {}, _helper, [0,0,0], 2.5] call ace_interact_menu_fnc_createAction;
			[_helper, 0, ["main"], _action] call ace_interact_menu_fnc_addActionToObject;
		} forEach [
			["Open","\tsp_breach\gui\open.paa",{[_doorData,1] call tsp_fnc_breach_adjust; if !(isNil "tsp_fnc_animate_door") then {[tsp_playa, true] call tsp_fnc_animate_door};},{_animPhase < 0.9 && _locked != 1}], 						
			["Close","\tsp_breach\gui\close.paa",{[_doorData,0] call tsp_fnc_breach_adjust; if !(isNil "tsp_fnc_animate_door") then {[tsp_playa, false] call tsp_fnc_animate_door};},{_animPhase > 0.1 && _locked != 1}], 
			["Unlock","\tsp_breach\gui\unlock.paa",{[_doorData,-1,0] call tsp_fnc_breach_adjust; if !(isNil "tsp_fnc_animate_door") then {[tsp_playa, true] call tsp_fnc_animate_door};},{_locked == 1 && _animPhase == 0 && (([eyePos tsp_playa, tsp_playa] call tsp_fnc_outsideness) < ([eyePos tsp_playa vectorAdd (vectorDir player vectorMultiply 2), tsp_playa] call tsp_fnc_outsideness))}], 
			["Lock","\tsp_breach\gui\lock.paa",{[_doorData,-1,1] call tsp_fnc_breach_adjust; if !(isNil "tsp_fnc_animate_door") then {[tsp_playa, true] call tsp_fnc_animate_door};},{_locked == 0 && _animPhase == 0}], 
			["Use Paperclip","\tsp_breach\gui\paperclip.paa",{[tsp_playa,_doorData,0.75,"tsp_paperclip",[0,0.5,0.25,0.15]] spawn tsp_fnc_breach_pick},{_locked == 1 && _animPhase == 0 && "tsp_paperclip" in (items tsp_playa)}], 
			["Use Lockpick","\tsp_breach\gui\lockpick.paa",{[tsp_playa,_doorData,0,"tsp_lockpick",[0,0.75,0.5,0.05]] spawn tsp_fnc_breach_pick},{_locked == 1 && _animPhase == 0 && "tsp_lockpick" in (items tsp_playa)}]
		];
	} forEach ([getPosASL _unit] call tsp_fnc_breach_doors);
};

tsp_fnc_breach_adjust = {  //-- Manipulate doors
	params ["_doorData", ["_amount", -1], ["_lock", -1]];  //-- "_amount" can be -1 (nothing), 0 - 1 (closed - open) // "_lock" can be -1 (nothing), 0 (unlocked), 1 (locked), 3 (break)
	_doorData params ["_id", "_house", "_door", "_pos", "_animName", "_animPhase", "_locked", "_triggerName", "_triggerPos", "_handleName", "_handlePos", "_hingeName", "_hingePos"];
	if (_amount != -1) then {{_house animate [[_animName, _x#0, _x#1] call tsp_fnc_stringReplace, _amount]} forEach [["a_rot","b_rot"],["b_rot","a_rot"],["a_rot","_rot"],["b_rot","_rot"], ["EH", "EH"]]};  //-- Double doors
	if (_lock == 0 && _locked != 0) exitWith {_house setVariable [("bis_disabled_Door_" + _id), _lock, true]; playSound3D ["tsp_breach\snd\unlock.ogg", _pos, false, _pos, 4, 1, 50]};  //-- Unlock	
	if (_lock == 1 && _locked != 1) exitWith {_house setVariable [("bis_disabled_Door_" + _id), _lock, true]; playSound3D ["tsp_breach\snd\lock.ogg", _pos, false, _pos, 4, 1, 50]};   //-- Lock
	if (_lock == 3 && _locked != 3) exitWith {  //-- Break
		_house setVariable [("bis_disabled_Door_" + _id), _lock, true]; playSound3D ["tsp_breach\snd\break.ogg", _pos, false, _pos, 1, 1, 50];
		_smoke = "#particlesource" createVehicle ASLtoATL _handlePos; _smoke setParticleClass "ImpactSmoke"; _smoke setDropInterval 0.1; sleep 0.2; deleteVehicle _smoke;
	};
};

tsp_fnc_breach_sticky = {
	params ["_charge", ["_fuse", -1], ["_floor", -1], ["_multi", 0.03], ["_vis", []]]; if !(local _charge) exitWith {};
	[getPos _charge, [], getText (configFile >> "CfgVehicles" >> (typeOf _charge) >> "ammo"), getText (configFile >> "CfgVehicles" >> (typeOf _charge) >> "model")] params ["_pos", "_dirUp", "_class", "_model"];
	_start = (getPosASL _charge) vectorAdd ([vectorDir _charge, 0, 2] call BIS_fnc_rotateVector3D vectorMultiply 1);
	_end = (getPosASL _charge) vectorAdd ([vectorDir _charge, 0, 2] call BIS_fnc_rotateVector3D vectorMultiply -1.2);
	((lineIntersectsSurfaces [_start, _end, _charge, player, true, 1, "FIRE"])#0) params ["_intersectPos", "_normal", "_object"];
	if !(isNil "_object") then {
		_charge setPosASL (_intersectPos vectorAdd (vectorDir _charge vectorMultiply _multi)); _charge setVectorDir _normal; _charge enableSimulation false;
		if (_floor != -1) then {_charge setPosASL (getPosASL _charge vectorAdd [0,0,(-([_charge] call tsp_fnc_distanceFromSurface)) + _floor])};
		if (_fuse > -1) then {[_charge, getPosATL _charge, getDir _charge, getText (configFile >> "CfgAmmo" >> _class >> "defaultMagazine"), "Timer", [_fuse], _charge] call ace_explosives_fnc_placeExplosive};
	};	
	waitUntil {_nulled = _charge isEqualTo objNull; if (!_nulled) then {_dirUp = [vectorDir _charge, vectorUp _charge]}; _nulled};
	_ammos = (allMissionObjects _class) select {_x distance2D _pos < 2}; if (count _ammos == 0) exitWith {}; _ammos params ["_ammo"];
	[_ammo, _dirUp] remoteExec ["setVectorDirAndUp"];
	if (_vis isNotEqualTo []) then {
		_visual = createSimpleObject [_model, (getPosASL _ammo) vectorAdd _vis];
		[_visual, _dirUp] remoteExec ["setVectorDirAndUp"]; [_ammo, true] remoteExec ["hideObjectGlobal", 2];
		waitUntil {_ammo isEqualTo objNull}; deleteVehicle _visual;
	};
};
	
tsp_fnc_breach_effectiveness = {  //-- Select effectiveness based on house type
	params ["_house", "_environmentDamage"]; _environmentDamage params ["_glass", "_civil", "_military", "_reinforced", "_wall"];
	if (typeOf _house in tsp_cba_breach_military) exitWith {_military};	if (typeOf _house in tsp_cba_breach_reinforced) exitWith {_reinforced}; _civil
};

tsp_fnc_breach_push = {  //-- Check if door is push or pull
	params ["_unit", "_doorData"];
	_doorData params ["_id","_house","_door","_pos","_animName","_animPhase","_locked","_triggerName","_triggerPos","_handleName","_handlePos","_hingeName","_hingePos"];
	_initialPosition = _house modelToWorld (_house selectionPosition [_door, "ViewGeometry", "AveragePoint"]);	//-- AveragePoint to get center of door selection
	_house animate [_animName, 1 + -_animPhase]; sleep 0.15;
	_finalPosition = _house modelToWorld (_house selectionPosition [_door, "ViewGeometry", "AveragePoint"]);  //-- AveragePoint to get center of door selection
	_house animate [_animName, _animPhase];  //-- Reset to original state
	if (_unit distance _initialPosition < _unit distance _finalPosition) then {true} else {false};
};

tsp_fnc_breach_melee = {
	params ["_unit", "_environmentDamage"];
	_doorData = [AGLtoASL positionCameraToWorld [0, 0, 0], AGLtoASL positionCameraToWorld [0, 0, 3], _unit] call tsp_fnc_breach_intersect; if (count _doorData < 2) exitWith {};  //-- If no door found
	_doorData params ["_id","_house","_door","_pos","_animName","_animPhase","_locked","_triggerName","_triggerPos","_handleName","_handlePos","_hingeName","_hingePos"];
	if (_animPhase != 0 || _locked == 3) exitWith {  //-- If door is open (0.01-1: open, 0: closed) or lock broken, we just want to swing it around
		playSound3D ["tsp_breach\snd\fail.ogg", _pos, false, _pos, 2, 1, 40];			
		if ([_unit, _doorData] call tsp_fnc_breach_push) then {[_doorData, if (_animPhase == 0) then {1} else {0}] spawn tsp_fnc_breach_adjust};  //-- Wee
	};
	[random 1 < [_house, _environmentDamage] call tsp_fnc_breach_Effectiveness] params ["_success"];
	playSound3D [if (_success) then {"tsp_breach\snd\destroy.ogg"} else {"tsp_breach\snd\fail.ogg"}, _pos, false, _pos, 2, 1, 40];
	if (_success) then {[_doorData, if ([_unit, _doorData] call tsp_fnc_breach_push) then {1} else {0.15}, 3] spawn tsp_fnc_breach_adjust};  //-- If push then open fully, else partical, also break lock
};

tsp_fnc_breach_explosive = {
	params ["_explosive", "_environmentDamage", ["_swingAmount", 1]];
	{  //-- For all door actions in radius
		_x params ["_house", "_actionClass", "_actionName", "_actionPos"];
		_doorData = [_house, _actionName] call tsp_fnc_breach_data;
		_doorData params ["_id","_house","_door","_pos","_animName","_animPhase","_locked","_triggerName","_triggerPos","_handleName","_handlePos","_hingeName","_hingePos"];
		if ("MBG" in (typeOf _house) && "Door" in (typeOf _house)) then {_house setDamage 0.75};  //-- MBG killhouses
		if (random 1 <= [_house, _environmentDamage] call tsp_fnc_breach_effectiveness) then {[_doorData, _swingAmount, 3] spawn tsp_fnc_breach_adjust};
	} forEach ([getPosASL _explosive, 3] call tsp_fnc_breach_doors);
};

tsp_fnc_breach_gun = {
	params ["_unit", "_ammo"];
	_doorData = [AGLtoASL positionCameraToWorld [0, 0, 0], AGLtoASL positionCameraToWorld [0, 0, 3], _unit] call tsp_fnc_breach_intersect;
	_doorData params ["_id","_house","_door","_pos","_animName","_animPhase","_locked","_triggerName","_triggerPos","_handleName","_handlePos","_hingeName","_hingePos"]; if (isNil "_house") exitWith {};	
	_effectiveness = if (_ammo in tsp_cba_breach_ammo) then {1} else {(((getNumber (configFile >> "CfgAmmo" >> _ammo >> "hit")) min 50)/50)*tsp_cba_breach_ammo_multiplier};  //-- Cap at 50 and divide by 50 to get 0-1 value
	if !(random 1 < [_house, [0,_effectiveness,_effectiveness/2,_effectiveness/10,0]] call tsp_fnc_breach_effectiveness && _animPhase == 0) exitWith {};  //-- If successful and door closed
	playSound3D ["tsp_breach\snd\destroy.ogg", _pos, false, _pos, 0.2, 1, 30]; [_doorData, 0.15, 3] spawn tsp_fnc_breach_adjust;  //-- Blow it and, but only a little bit and break lock
};

tsp_fnc_breach_pick = {
	params ["_unit", "_doorData", "_deleteChance", "_item", "_environmentDamage"];	
	_doorData params ["_id","_house","_door","_pos","_animName","_animPhase","_locked","_triggerName","_triggerPos","_handleName","_handlePos","_hingeName","_hingePos"];
	_effectiveness = [_house, _environmentDamage] call tsp_fnc_breach_effectiveness;    //-- Get effectiveness
	if (_unit getUnitTrait "Engineer") then {_effectiveness = _effectiveness + 0.75};  //-- This is the lock picking lawyer ~
	if (random 1 <= _deleteChance) then {_unit removeItem _item};      //-- Delete item
	_unit disableAI "ANIM";	_unit playMoveNow "Acts_CarFixingWheel";  //-- Animation
	[random 10 max 5, [_unit, _effectiveness, _doorData], {          //-- ACE progress bar
		(_this#0) params ["_unit", "_effectiveness", "_doorData"];
		_unit enableAI "ANIM"; _unit switchMove "AmovPknlMstpSnonWnonDnon";
		if (random 1 <= _effectiveness) then {[_doorData, -1, 0] call tsp_fnc_breach_adjust; ["", "Success"] spawn BIS_fnc_showSubtitle} else {["", "Failed"] spawn BIS_fnc_showSubtitle};	
	}, {}, "Picking..."] call ace_common_fnc_progressBar;
};

tsp_fnc_breach_wall = {
	params ["_explosive", "_environmentDamage"];
	if (random 1 >= _environmentDamage#4) exitWith {};  //-- Check explosive
	_start = (_explosive modelToWorldWorld (_explosive selectionPosition ["breach", "Memory"])) vectorAdd (([vectorDir _explosive, 0, 2] call BIS_fnc_rotateVector3D vectorMultiply 1));
	_end = (_explosive modelToWorldWorld (_explosive selectionPosition ["breach", "Memory"])) vectorAdd (([vectorDir _explosive, 0, 2] call BIS_fnc_rotateVector3D vectorMultiply -1));
	[_explosive, _start, _end] spawn {params ["_explosive", "_start", "_end"]; sleep 0.1;
		([_start, _end] call tsp_fnc_breach_intersect) params ["_wall"]; if (isNil "_wall") exitWith {}; if (_wall isEqualType "") exitWith {};  //-- Get wall
		if !(_wall in ((nearestTerrainObjects [_wall, ["WALL", "FENCE"], 10])+(nearestObjects [_wall, ["WALL", "FENCE"], 10]))) exitWith {};    //-- Check wall
		_wall setDamage 1;  //-- Kill wall
		if (!tsp_cba_breach_wall_physics) exitWith {};  //-- Physics
		_physics = createVehicle ["tsp_breach_wall", getPosATL _wall, [], 0, "CAN_COLLIDE"]; _physics setDir (getDir _wall);
		_newWall = createSimpleObject [(getModelInfo _wall)#1, getPos _wall]; _newWall attachTo [_physics,[0,0,0]];
		_physics setVelocity (_explosive vectorModelToWorld tsp_cba_breach_wall_velocity); hideObjectGlobal _wall;
	};
};

tsp_fnc_breach_glass = {  //-- Break glass in radius
	params ["_pos", "_radius"];
	{  //-- For all houses in radius
		[_x] params ["_house"]; 
		if (getAllHitPointsDamage _house isEqualTo []) then {continue};
		(getAllHitPointsDamage _house) params ["_hitpoints", "_selections", "_damage"];
		{  //-- For all selections
			[_x, _house modelToWorld (_house selectionPosition _x)] params ["_selection", "_selectionPos"];
			if (_selectionPos distance _pos > _radius || _damage#_forEachIndex == 1 || !(["glass", _selection] call BIS_fnc_inString || ["window", _selection] call BIS_fnc_inString)) then {continue};  //-- Skip
			[_house, [_selection, 1]] remoteExec ["setHit", 0]; 
			playSound3D [format ["A3\Sounds_F\arsenal\sfx\bullet_hits\glass_0%1.wss", (floor random 8) + 1], _selectionPos, false, AGLtoASL _selectionPos, 3, 1, 25];
		} forEach _selections;
	} forEach (nearestObjects [_pos, ["BUILDING", "HOUSE", "CHURCH", "CHAPEL", "BUNKER", "FORTRESS", "VIEW-TOWER", "LIGHTHOUSE", "FUELSTATION", "HOSPITAL", "TOURISM"], 20]);
};

tsp_fnc_breach_lock = {  //-- Lock random doors in radius
	params ["_pos", "_radius", "_houseChance", "_doorChance", ["_lock", 1]];
	{  //-- For all buildings in radius  || (_x in tsp_cba_breach_lock_blacklist)
		if (random 1 >= _houseChance || _x getVariable ["breach_blacklist", false] || ((typeOf _x) in tsp_cba_breach_lock_blacklist)) then {continue};  //--  Skip
		for "_i" from 0 to (count (configfile >> "CfgVehicles" >> typeOf _x >> "UserActions")) do {if (random 1 <= _doorChance) then {_x setVariable [format ["bis_disabled_Door_%1", _i], _lock, true]}};
	} forEach (nearestTerrainObjects [_pos, ["BUILDING", "HOUSE", "CHURCH", "CHAPEL", "BUNKER", "FORTRESS", "VIEW-TOWER", "LIGHTHOUSE", "FUELSTATION", "HOSPITAL", "TOURISM"], _radius]);
};

//_helper = "Sign_Arrow_F" createVehicleLocal _start; _helper setPosASL _start;
//_helper = "Sign_Arrow_F" createVehicleLocal _end; _helper setPosASL _end;
//addMissionEventHandler ["Draw3D", {systemChat (str [([eyePos player, player] call tsp_fnc_outsideness),([eyePos player vectorAdd (vectorDir player vectorMultiply 2), player] call tsp_fnc_outsideness)])}];