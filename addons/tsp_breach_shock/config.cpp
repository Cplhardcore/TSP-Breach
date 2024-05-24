class CfgPatches {
	class tsp_breach_shock {
		requiredAddons[] = {"cba_common", "tsp_breach", "ace_interaction", "ace_explosives"};
        weapons[] = {"tsp_breach_shock"};
        units[] = {};
	};
};

//-- FUNCTIONS
class Extended_PostInit_EventHandlers {class tsp_breach_shock_init {init = "execVM '\tsp_breach_shock\init.sqf'";};};

//-- SOUNDS
class CfgSounds {class tsp_breach_fuse {name = "tsp_breach_fuse"; sound[] = {"tsp_breach_shock\snd\fuse.ogg", 5, 2, 50}; titles[] = {0, ""};};};

//-- ROPE 
class CfgVehicles {class Rope; class shock_wire: Rope {model = "\tsp_breach_shock\wire.p3d"; segmentType = "shock_wire_segment";};};
class CfgNonAIVehicles {class RopeSegment; class shock_wire_segment: RopeSegment {model = "\tsp_breach_shock\wire.p3d";};};

//-- ITEMS
class CfgWeapons {
    class ACE_Clacker;
    class tsp_breach_shock: ACE_Clacker {
        displayName = "Shock Tube";
        picture = "\tsp_breach_shock\gui\ui.paa";
        model = "\tsp_breach_shock\shock.p3d";
        ACE_Explosives_Range = 999;
        ACE_Explosives_triggerType = "Shock";
    };
};

class ACE_Triggers {
    class Shock {
        displayName = "Shock Tube";
        isAttachable = 1;
        onPlace = "_this spawn tsp_fnc_breach_shock_wire; _this call ace_explosives_fnc_AddClacker; false";
        picture = "\tsp_breach_shock\gui\ui.paa";
        requires[] = {"tsp_breach_shock"};
    };
};
