class CfgPatches {
	class tsp_sound {
		requiredAddons[] = {"cba_common"};
		units[] = {};
	};
};

//-- FUNCTIONS
class CfgFunctions {
	class tsp_sound {
		class functions {
			class cba {file = "tsp_sound\cba.sqf"; preInit = true;};
			class init {file = "tsp_sound\init.sqf"; postInit = true;};
		};
	};
};