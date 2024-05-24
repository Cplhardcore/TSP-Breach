class CfgPatches {
	class tsp_breach_silhouette {
		requiredAddons[] = {"cba_common", "tsp_breach"};
		units[] = {"tsp_breach_silhouette_twig", "tsp_breach_silhouette_stick"};
	};
};

//-- FUNCTIONS
class Extended_PostInit_EventHandlers {class tsp_breach_silhouette {init = "execVM '\tsp_breach_silhouette\init.sqf'";};};

class CfgMagazines {
    class SLAMDirectionalMine_Wire_Mag;
    class tsp_breach_silhouette_mag: SLAMDirectionalMine_Wire_Mag {
        displayName = "Silhouette Charge"; picture = "\tsp_breach_silhouette\gui\ui.paa"; descriptionShort = "Works on walls and doors.";
        model = "tsp_breach_silhouette\silhouette_mag.p3d"; ammo = "tsp_breach_silhouette_ammo"; mass = 80;
        ace_explosives_setupObject = "tsp_breach_silhouette_place";
		class ACE_Triggers {SupportedTriggers[] = {"Timer", "Command", "MK16_Transmitter", "Shock"}; class Shock {FuseTime = 1;};};
    };
};

class CfgAmmo {
    class ClaymoreDirectionalMine_Remote_Ammo;
    class tsp_breach_silhouette_ammo: ClaymoreDirectionalMine_Remote_Ammo {
        model = "tsp_breach_silhouette\silhouette_ammo.p3d"; mineModelDisabled = "\tsp_breach_silhouette\silhouette_ammo.p3d";        
        hit = 40; indirectHit = 40; indirectHitRange = 4; explosionAngle = 120; environmentDamage[] = {1,1,1,1,1}; swingAmount = 1;
        defaultMagazine = "tsp_breach_silhouette_mag"; ace_explosives_magazine = "tsp_breach_silhouette_mag"; ace_explosives_explosive = "tsp_breach_silhouette_ammo";
        SoundSetExplosion[] = {"tsp_breach_silhouette_soundSet","ClaymoreMine_Tail_SoundSet","Explosion_Debris_SoundSet"}; 
    };
};

class CfgVehicles {
    class SLAMDirectionalMine;
    class ACE_Explosives_Place_SLAM;
    class tsp_breach_silhouette_place: ACE_Explosives_Place_SLAM {ammo = "tsp_breach_silhouette_ammo"; model = "tsp_breach_silhouette\silhouette_place.p3d"; class EventHandlers {init = "[_this#0, true] remoteExec ['hideObjectGlobal', 2]; [_this#0,-1,0,0.3,[0,0,0.85]] spawn tsp_fnc_breach_sticky; _this#0 spawn {sleep 0.1; [_this, false] remoteExec ['hideObjectGlobal', 2]};";};};
	class Items_base_F; 
    class tsp_breach_silhouette_twig: Items_base_F {scope = 2; displayName = "Twig"; model = "tsp_breach_silhouette\twig.p3d";};
    class tsp_breach_silhouette_stick: tsp_breach_silhouette_twig {displayName = "Stick"; model = "tsp_breach_silhouette\stick.p3d";};
};

class CfgWeapons {
	class Default;
	class Put: Default {
		muzzles[] += {"tsp_breach_silhouette_muzzle"};
		class PutMuzzle: Default {};
		class tsp_breach_silhouette_muzzle: PutMuzzle {magazines[] = {"tsp_breach_silhouette_mag","tsp_breach_silhouette_auto_mag"};};
	};
};

class CfgSoundSets {
    class GrenadeHe_Exp_SoundSet;
    class tsp_breach_silhouette_soundSet: GrenadeHe_Exp_SoundSet {soundShaders[] = {"tsp_breach_silhouette_soundShader"};};
};

class CfgSoundShaders {
    class GrenadeHe_closeExp_SoundShader;
    class tsp_breach_silhouette_soundShader: GrenadeHe_closeExp_SoundShader {samples[] = {{"\tsp_breach_silhouette\snd\exp1.ogg",1}};};
};