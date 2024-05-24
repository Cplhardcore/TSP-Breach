class CfgPatches {
	class tsp_breach_linear {
		requiredAddons[] = {"cba_common", "tsp_breach"};
		units[] = {};
	};
};

class CfgMagazines {
    class SLAMDirectionalMine_Wire_Mag;
    class tsp_breach_linear_mag: SLAMDirectionalMine_Wire_Mag {
        displayName = "Linear Charge"; picture = "\tsp_breach_linear\gui\ui.paa"; descriptionShort = "Linear style breaching charge, used for regular/military/reinforced doors.";
        model = "tsp_breach_linear\linear_mag.p3d"; ammo = "tsp_breach_linear_ammo"; mass = 10;
        ace_explosives_setupObject = "tsp_breach_linear_place";
		class ACE_Triggers {SupportedTriggers[] = {"Timer", "Command", "MK16_Transmitter", "Shock"}; class Shock {FuseTime = 1;};};
    };
    class tsp_breach_linear_auto_mag: tsp_breach_linear_mag {
        displayName = "Linear Charge (Auto-Fuse)";
        ace_explosives_setupObject = "tsp_breach_linear_auto_place";
		class ACE_Triggers {SupportedTriggers[] = {};};
    };
};

class CfgAmmo {
    class ClaymoreDirectionalMine_Remote_Ammo;
    class tsp_breach_linear_ammo: ClaymoreDirectionalMine_Remote_Ammo {
        model = "tsp_breach_linear\linear_ammo.p3d"; mineModelDisabled = "\tsp_breach_linear\linear_ammo.p3d";
        hit = 10; indirectHit = 5; indirectHitRange = 1; explosionAngle = 90; environmentDamage[] = {1,1,1,1,0}; swingAmount = 1;
        defaultMagazine = "tsp_breach_linear_mag"; ace_explosives_magazine = "tsp_breach_linear_mag"; ace_explosives_explosive = "tsp_breach_linear_ammo";
        SoundSetExplosion[] = {"tsp_breach_linear_soundSet","ClaymoreMine_Tail_SoundSet","Explosion_Debris_SoundSet"}; 
    };
};

class CfgVehicles {
    class ACE_Explosives_Place_SLAM;
    class tsp_breach_linear_place: ACE_Explosives_Place_SLAM {ammo = "tsp_breach_linear_ammo"; model = "tsp_breach_linear\linear_place.p3d"; class EventHandlers {init = "[_this#0,-1,0.4,0.03,[0,0,0.65]] spawn tsp_fnc_breach_sticky;";};};
    class tsp_breach_linear_auto_place: tsp_breach_linear_place {class EventHandlers {init = "[_this#0,tsp_cba_breach_auto,0.4,0.03,[0,0,0.65]] spawn tsp_fnc_breach_sticky;";};};
};

class CfgWeapons {
	class Default;
	class Put: Default {
		muzzles[] += {"tsp_breach_linear_muzzle"};
		class PutMuzzle: Default {};
		class tsp_breach_linear_muzzle: PutMuzzle {magazines[] = {"tsp_breach_linear_mag","tsp_breach_linear_auto_mag"};};
	};
};

class CfgSoundSets {
    class GrenadeHe_Exp_SoundSet;
    class tsp_breach_linear_soundSet: GrenadeHe_Exp_SoundSet {soundShaders[] = {"tsp_breach_linear_soundShader"};};
};

class CfgSoundShaders {
    class GrenadeHe_closeExp_SoundShader;
    class tsp_breach_linear_soundShader: GrenadeHe_closeExp_SoundShader {samples[] = {{"\tsp_breach_linear\snd\exp1.ogg",1},{"\tsp_breach_linear\snd\exp2.ogg",1}};};
};