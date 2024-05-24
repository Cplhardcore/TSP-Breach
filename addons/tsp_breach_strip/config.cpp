class CfgPatches {
	class tsp_breach_strip {
		requiredAddons[] = {"cba_common", "tsp_breach"};
		units[] = {};
	};
};

class CfgMagazines {
    class SLAMDirectionalMine_Wire_Mag;
    class tsp_breach_strip_mag: SLAMDirectionalMine_Wire_Mag {
        displayName = "Strip Charge"; picture = "\tsp_breach_strip\gui\ui.paa"; descriptionShort = "strip style breaching charge, used for regular/military/reinforced doors.";
        model = "tsp_breach_strip\strip_mag.p3d"; ammo = "tsp_breach_strip_ammo"; mass = 10;
        ace_explosives_setupObject = "tsp_breach_strip_place";
		class ACE_Triggers {SupportedTriggers[] = {"Timer", "Command", "MK16_Transmitter", "Shock"}; class Shock {FuseTime = 1;};};
    };
    class tsp_breach_strip_auto_mag: tsp_breach_strip_mag {
        displayName = "Strip Charge (Auto-Fuse)";
        ace_explosives_setupObject = "tsp_breach_strip_auto_place";
		class ACE_Triggers {SupportedTriggers[] = {};};
    };
};

class CfgAmmo {
    class ClaymoreDirectionalMine_Remote_Ammo;
    class tsp_breach_strip_ammo: ClaymoreDirectionalMine_Remote_Ammo {
        model = "tsp_breach_strip\strip_ammo.p3d"; mineModelDisabled = "\tsp_breach_strip\strip_ammo.p3d";
        hit = 10; indirectHit = 5; indirectHitRange = 1; explosionAngle = 90; environmentDamage[] = {1,1,1,1,0}; swingAmount = 1;
        defaultMagazine = "tsp_breach_strip_mag"; ace_explosives_magazine = "tsp_breach_strip_mag"; ace_explosives_explosive = "tsp_breach_strip_ammo";
        SoundSetExplosion[] = {"tsp_breach_strip_soundSet","ClaymoreMine_Tail_SoundSet","Explosion_Debris_SoundSet"}; 
    };
};

class CfgVehicles {
    class SLAMDirectionalMine;
    class ACE_Explosives_Place_SLAM;
    class tsp_breach_strip_place: ACE_Explosives_Place_SLAM {ammo = "tsp_breach_strip_ammo"; model = "tsp_breach_strip\strip_place.p3d"; class EventHandlers {init = "[_this#0] spawn tsp_fnc_breach_sticky;";};};
    class tsp_breach_strip_auto_place: tsp_breach_strip_place {class EventHandlers {init = "[_this#0, tsp_cba_breach_auto] spawn tsp_fnc_breach_sticky;";};};
};

class CfgWeapons {
	class Default;
	class Put: Default {
		muzzles[] += {"tsp_breach_strip_muzzle"};
		class PutMuzzle: Default {};
		class tsp_breach_strip_muzzle: PutMuzzle {magazines[] = {"tsp_breach_strip_mag","tsp_breach_strip_auto_mag"};};
	};
};

class CfgSoundSets {
    class GrenadeHe_Exp_SoundSet;
    class tsp_breach_strip_soundSet: GrenadeHe_Exp_SoundSet {soundShaders[] = {"tsp_breach_strip_soundShader"};};
};

class CfgSoundShaders {
    class GrenadeHe_closeExp_SoundShader;
    class tsp_breach_strip_soundShader: GrenadeHe_closeExp_SoundShader {samples[] = {{"\tsp_breach_strip\snd\exp1.ogg",1},{"\tsp_breach_strip\snd\exp2.ogg",1}};};
};


//soundHit[] = {"\tsp_breach_strip\snd\exp1.ogg",2.51189,1,1500};
//soundHit1[] = {"\tsp_breach_strip\snd\exp1.ogg",2.51189,1,1500};
//soundHit2[] = {"\tsp_breach_strip\snd\exp2.ogg",2.51189,1,1500};
//soundHit1[] = {"A3\Sounds_F\arsenal\explosives\grenades\Explosion_HE_grenade_01",2.51189,1,1500};
//SoundSetExplosion[] = {"ClaymoreMine_Exp_SoundSet","ClaymoreMine_Tail_SoundSet","Explosion_Debris_SoundSet"};
//,"GrenadeHe_Tail_SoundSet","Explosion_Debris_SoundSet"