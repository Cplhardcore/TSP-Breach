class CfgPatches {
	class tsp_breach_popper {
		requiredAddons[] = {"cba_common", "tsp_breach"};
		units[] = {};
	};
};

class CfgMagazines {
    class SLAMDirectionalMine_Wire_Mag;
    class tsp_breach_popper_mag: SLAMDirectionalMine_Wire_Mag {
        displayName = "Lock Popper"; picture = "\tsp_breach_popper\gui\ui.paa"; descriptionShort = "Small charge used for regular/military doors.";
        model = "tsp_breach_popper\popper_mag.p3d"; ammo = "tsp_breach_popper_ammo"; mass = 10;
        ace_explosives_setupObject = "tsp_breach_popper_place";
		class ACE_Triggers {SupportedTriggers[] = {"Timer", "Command", "MK16_Transmitter"};};
    };
    class tsp_breach_popper_auto_mag: tsp_breach_popper_mag {
        displayName = "Lock Popper (Auto-Fuse)";
        ace_explosives_setupObject = "tsp_breach_popper_auto_place";
		class ACE_Triggers {SupportedTriggers[] = {};};
    };
};

class CfgAmmo {
    class SLAMDirectionalMine_Wire_Ammo;
    class tsp_breach_popper_ammo: SLAMDirectionalMine_Wire_Ammo {
        model = "tsp_breach_popper\popper_ammo.p3d"; mineModelDisabled = "\tsp_breach_popper\popper_ammo.p3d";
        hit = 2; indirectHit = 1; indirectHitRange = 1; explosionAngle = 20; environmentDamage[] = {0,1,0.75,0,0}; swingAmount = 0.25;
        defaultMagazine = "tsp_breach_popper_mag"; ace_explosives_magazine = "tsp_breach_popper_mag"; ace_explosives_explosive = "tsp_breach_popper_ammo";
        SoundSetExplosion[] = {"tsp_breach_popper_soundSet"}; explosionEffects = "popperExplosionEffect";    
    };
};

class CfgVehicles {
    class ACE_Explosives_Place_SLAM;
    class tsp_breach_popper_place: ACE_Explosives_Place_SLAM {ammo = "tsp_breach_popper_ammo"; model = "tsp_breach_popper\popper_place.p3d"; class EventHandlers {init = "[_this#0] spawn tsp_fnc_breach_sticky";};};
    class tsp_breach_popper_auto_place: tsp_breach_popper_place {class EventHandlers {init = "[_this#0, tsp_cba_breach_auto] spawn tsp_fnc_breach_sticky";};};
};

class popperExplosionEffect {
    class sparks {intensity = 1; interval = 1; lifeTime = 0.5; position[] = {0,0,0}; simulation = "particles"; type = "AmmoExpSparks";};    
    class sparks2 {intensity = 1; interval = 1; lifeTime = 0.5; position[] = {0,0,0}; simulation = "particles"; type = "AirFireSparks";};
    class smoke {intensity = 1; interval = 1; lifeTime = 0.5; position[] = {0,0,0}; simulation = "particles"; type = "ImpactSmoke";};
};

class CfgWeapons {
	class Default;
	class Put: Default {
		muzzles[] += {"tsp_breach_popper_muzzle"};
		class PutMuzzle: Default {};
		class tsp_breach_popper_muzzle: PutMuzzle {magazines[] = {"tsp_breach_popper_mag", "tsp_breach_popper_auto_mag"};};
	};
};

class CfgSoundSets {
    class GrenadeHe_Exp_SoundSet;
    class tsp_breach_popper_soundSet: GrenadeHe_Exp_SoundSet {soundShaders[] = {"tsp_breach_popper_soundShader"};};
};

class CfgSoundShaders {
    class GrenadeHe_closeExp_SoundShader;
    class tsp_breach_popper_soundShader: GrenadeHe_closeExp_SoundShader {samples[] = {{"\tsp_breach_popper\snd\exp1.ogg",1}};};
};