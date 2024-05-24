class CfgPatches {
	class tsp_breach_frame {
		requiredAddons[] = {"cba_common", "tsp_breach"};
		units[] = {};
	};
};

class CfgMagazines {
    class SLAMDirectionalMine_Wire_Mag;
    class tsp_breach_frame_mag: SLAMDirectionalMine_Wire_Mag {
        displayName = "Frame Charge"; picture = "\tsp_breach_frame\gui\ui.paa"; descriptionShort = "Frame style breaching charge, used for walls and reinforced doors. Has a high potential to be lethal.";  //ACTUAL DESC
        model = "tsp_breach_frame\frame_mag.p3d"; ammo = "tsp_breach_frame_ammo"; mass = 20;
        ace_explosives_setupObject = "tsp_breach_frame_place";
		class ACE_Triggers {SupportedTriggers[] = {"Timer", "Command", "MK16_Transmitter", "Shock"}; class Shock {FuseTime = 1;};};
    };
};

class CfgAmmo {
    class ClaymoreDirectionalMine_Remote_Ammo;
    class tsp_breach_frame_ammo: ClaymoreDirectionalMine_Remote_Ammo {
        model = "tsp_breach_frame\frame_ammo.p3d"; mineModelDisabled = "\tsp_breach_frame\frame_ammo.p3d";
        hit = 100; indirectHit = 70; indirectHitRange = 5; explosionAngle = 120; environmentDamage[] = {1,1,1,1,1}; swingAmount = 1;
        defaultMagazine = "tsp_breach_frame_mag"; ace_explosives_magazine = "tsp_breach_frame_mag"; ace_explosives_explosive = "tsp_breach_frame_ammo";
    };
};

class CfgVehicles {
    class ACE_Explosives_Place_SLAM;
    class tsp_breach_frame_place: ACE_Explosives_Place_SLAM {ammo = "tsp_breach_frame_ammo"; model = "tsp_breach_frame\frame_place.p3d"; class EventHandlers {init = "[_this#0] spawn tsp_fnc_breach_sticky;";};};
};

class CfgWeapons {
	class Default;
	class Put: Default {
		muzzles[] += {"tsp_breach_frame_muzzle"};
		class PutMuzzle: Default {};
		class tsp_breach_frame_muzzle: PutMuzzle {magazines[] = {"tsp_breach_frame_mag"};};
	};
};
