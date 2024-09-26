/*
===========================================================================

Steel Storm Burning Retribution QuakeC Source Code
Copyright (C) 2008-2024 Kot-in-Action Creative Artel.

This file is part of the Steel Storm Burning Retribution QuakeC Source Code.

License:
  - You may use, modify, and distribute modifications of this source code under the terms of the Steel Storm Burning Retribution QuakeC Source Code License Agreement.
  - No commercial use of this source code or any derivative works is permitted.
  - All mods and modifications must be distributed for free and include this license header.
 
The full text of the license is included in the license.txt file that came with this source code.

If you have questions concerning this license, you may contact info (at) kot-in-action.com

===========================================================================
*/
float AIStartTime() =	{	return time+0.01+random()*0.1;	}

void TriggerEnemy() =
{
	local entity e;

	if(self.istoggled)
		return;
	
	SetObjectAppearance(self, self.objclass, self.variant);
	self.godmode = FALSE;
//	if(self.behaviorflags & BF_STATIONARY)
//		self.solid = SOLID_BSP;
//	else
	if(!self.tag_entity)
		self.solid = SOLID_SLIDEBOX;
	self.istoggled = TRUE;
	self.onlydrawforadmins = FALSE;	
	if(IsBaseEnt(self))
	{
		self.SendFlags = self.SendFlags | SFL_TELEPORT;
		self.teleporttouchtime = time + self.spawntime;// = time+1;
	}
//	self.SendFlags = self.SendFlags | SFL_RESET | SFL_BASEDATA;	
	self.think = StartAI;
	self.nextthink = time+random();
	
	e = self.list_childchain;
	while(e)
	{
		Func_oself(e, TriggerEnemy);
		e = e.childchain;	
	}
}

void ReleaseMinigun() =	{	SetEventFlag_Sound(self, SOUND_MINIGUN_HEAVY_STOP);		}

entity Turret(entity e, string tagname, vector offset, float VARIANT, float WEP, float WEPVAR, vector f_rate, vector b_rate, float turret_yaw_speed, float turret_yaw_maxleft, float turret_yaw_maxright, float yawofs, float destructstage) =
{
	if(e.hasturrets || e.isdead)
		return world;

	local entity turret;
	local float tagindex;
	
	turret = SpawnEnt();
//	turret.SendFlags = SFL_ISNEW;
	InitializeSharedEnt(turret);	
	turret.class = CLASS_OBJECT;
	turret.objclass = OBJ_NPC;
	turret.npcclass = NPC_TURRET;
	turret.variant = VARIANT;
//	turret.effects = turret.effects | EF_NODEPTHTEST;
	
	turret.destructatstage = destructstage;
	
//	SetAndPrecacheModel(turret, mdlname);
	SetObjectAppearance(turret, turret.objclass, turret.variant);
	if(strlen(tagname))
		tagindex = gettagindex(e, tagname);
	Attach(turret, e, tagindex);
	
	setorigin(turret, offset);
	
	turret.angles_y = yawofs;

//	turret.shootfrom_index 		= gettagindex(turret, "tag_shoot");
	
	turret.movespeed			= 0;	
//	turret.yaw_speed 			= turret_yaw_speed;
	turret.yaw_speed 			= turret.yaw_speed_base = turret_yaw_speed;
	turret.yaw_maxleft			= turret_yaw_maxleft;
	turret.yaw_maxright			= turret_yaw_maxright;
	turret.yaw_baseofs			= yawofs;
	
	turret.targetswitchdelay	= e.targetswitchdelay;	
	turret.alertnessdelay		= e.alertnessdelay;
	turret.alertness			= e.alertness;

	turret.engagedist_near		= 0;
	turret.engagedist_far		= e.engagedist_far;

	turret.behaviorflags		= BF_TURRET;
	
	turret.weapon 				= WEP;
	turret.weaponshotvariant	= WEPVAR;
	turret.burstrate			= b_rate;
	turret.firingrate			= f_rate;		
	turret.weaponrange			= e.weaponrange;
	
	if(WEP == WEP1_MINIGUN)
		turret.WepReleaseFunc = ReleaseMinigun;
	
	SetOwner(turret, e);
	SetParent(turret, e);

	AIChain_Add(turret);	
	
	turret.SendEntity = SendNPC;
	
	if(IsAssignedFunction(PostTurretSpawnFunc))
		Func_oself(turret, PostTurretSpawnFunc);
	else
		turret.shootfrom_index 	= gettagindex(turret, "tag_shoot");
		
	turret.think = StartAI;
	turret.nextthink = AIStartTime();
	
	return turret;
}

float PreSpawnNPC(entity e, float NPC_CLASS) =
{
	if((!GameMode_CanSpawnEnemies(gamemode) || (!e.id && missionfileexists) || (e.multiplayeronly && singleplayer)) && !e.permanent)
	{
		SH_RemoveEnt(e);
		return FALSE;
	}
	
	if(!SetDefaultSharedStats(e))
		return FALSE;	
	
	if(!spawningsectorents)
		ai_total = ai_total+1;
	
	local float OCCUPY;
	
//	e.SendFlags = SFL_ISNEW;
	e.postinitthink = SUB_Null;
	InitializeSharedEnt(e);	
	
//	if(!e.owner)
//		SetOwner(e, e);

	if(!e.spawnedfrom && !e.spawnedfromtag)
	{
		SetOwner(e, e);//self.owner = self;
		SetParent(e, e);
	}
	
	AIChain_Add(e);
	if(!e.spawnedfrom && !e.spawnedfromtag)
		ObjectChain_Add(e);
		
	e.variant = e.npcclass = NPC_CLASS;
	e.class = CLASS_OBJECT;
	e.objclass = OBJ_NPC;
	
	SetID(e);	
	
	SetObjectAppearance(e, e.objclass, e.variant);
//	SetObjectSize(e, e.objclass, e.variant);
	
	e.damage_effects = e.damage_effects | DMGEF_BURN;
	
	e.movetype = MOVETYPE_NONE;
	e.activemovetype = MOVETYPE_WALK;
	e.solid = SOLID_SLIDEBOX;

	e.PreRemoveFunc = RemoveNPC;

//	if(!e.flags & FL_REVIVE)
//	{
	/*	if(!e.owner || e.owner == e)
		{
			e.origin_roambase = e.origin_base;
			if(e.origin_roambase == '0 0 0')
				print("WARNING: using bad origin_roambase in spawn\n");
		}*/
		
//		if(IsBaseEnt(e))
//			print("was setting origin_base here\n");
	//		e.origin_base = e.origin;
//	}	
	
//	if(e.origin == '0 0 0')
//		print("Warning: Bad origin during npc spawning.\n");
		
//	InitializeSharedEnt(e);	

	if(!(e.flags & FL_REVIVE))
	if(e.origin_base != '0 0 0')
		InitializeObjectOrientation(e);	

//	e.flags -= e.flags & FL_REVIVE;	
	
//	if(!e.behaviorflags & BF_FLIES)
//		OCCUPY = TRUE;	
	
//	if(e.gridpos != '0 0 0')
//		UnmarkGrid(e, TRUE, OCCUPY);
	
//	MarkGrid(e, TRUE, OCCUPY, e.gridpos);	
	
	e.SendEntity = SendNPC;

	return TRUE;
}

float turret_stationary(float WEP, float VER, float switchdelay, float alertdelay, vector f_rate, float ALERTNESS_TYPE, void() func) =
{
	local entity turret_head;
	local float isspawned;
	
	PostTurretSpawnFunc = func;	
	isspawned = PreSpawnNPC(self, VER);
	PostTurretSpawnFunc = SUB_Null;	
	
	if(!isspawned)
		return FALSE;
	
//	self.activemovetype = MOVETYPE_NONE; // FIXME hacked to get projectiles to collide
//	self.movetype = MOVETYPE_NONE;
//	self.solid = SOLID_BSP;
	self.engagedist_far = 2500;
	
	self.health	= self.max_health = 300*skillmultiple;
	if(spawningsectorents)
	{
		self.health = enthealth;
		enthealth = 0;
	}
		
	self.targetswitchdelay	= switchdelay;	
	self.alertnessdelay		= alertdelay;
	self.alertness			= ALERTNESS_DAMAGE | ALERTNESS_TYPE;	
	
	self.behaviorflags		= BF_STATIONARY;
	
	self.think = StartAI;
	self.nextthink = AIStartTime();
	
//	turret_head = Turret(self, "tag_turret", modelname, WEP, f_rate, 1, 180, -180, 0);
	
//	self.hasturrets = TRUE;
	
	return TRUE;
}

void InitializeTurretHead_LightPlasma() =
{
	self.(shootfrom_index[0]) 	= gettagindex(self, "plasma_barrel.L");
	self.(shootfrom_index[1]) 	= gettagindex(self, "plasma_barrel.R");
}

void light_plasma_turret() =
{
	if(!turret_stationary(WEP_PLASMA, NPC_LIGHTPLASMATURRET, 0.5, 0.5, '0.5 0.5 0', ALERTNESS_CONE, InitializeTurretHead_LightPlasma))
		return;

	self.points = 200;
//	if(!self.objectname)
//		self.objectname = zonecpy(self.objectname, "Light Plasma Turret");
}

void beam_turret_firefunc() =
{
	self.waittomovetime = time+1;
	self.yaw_speed = 0.3;
	FireWeapon(self.weapon, 0, FALSE, 1);
}

void heavy_beam_turret() =
{
	if(!turret_stationary(WEP_TURRETBEAM, NPC_HEAVYBEAMTURRET, 1, 1, '3 3 0', ALERTNESS_CONE, SUB_Null))
		return;
		
	self.points = 400;
//	if(!self.objectname)
//		self.objectname = zonecpy(self.objectname, "Beam Turret");		
}

void InitializeTurretHead_Rocket() =	{	self.maxfiringpos = 3;	}

void rocket_turret() =
{
	if(!turret_stationary(WEP1_ROCKETPOD, NPC_ROCKETTURRET, 0.5, 0.5, '1 1 0', ALERTNESS_CONE, InitializeTurretHead_Rocket))
		return;

	self.points = 400;
//	if(!self.objectname)
//		self.objectname = zonecpy(self.objectname, "Rocket Turret");		
}

void repair_turret() =
{
	if(!turret_stationary(WEP_REPAIR, NPC_REPAIRTURRET, 1, 1, '3 3 0', ALERTNESS_OMNIDIRECTIONAL, SUB_Null))
		return;
		
	self.points = 300;
	self.flags = self.flags | FL_NOREVIVE;
	self.behaviorflags = self.behaviorflags | BF_LOOKFORALLIES;
//	if(!self.objectname)
//		self.objectname = zonecpy(self.objectname, "Repair Turret");	
}

void friendly_light_tank() =
{
//	if(IsTriggered(light_tank))
//		return;

	if(!PreSpawnNPC(self, NPC_FRIENDLYLIGHTTANK))
		return;

//	if(!self.objectname)
//		self.objectname = zonecpy(self.objectname, "Friendly Light Tank");		
		
	self.team = 1;
		
	self.shootfrom_index 	= gettagindex(self, "tag_projectile");
	
	self.movespeed			= 70;
	self.movementinertia	= 0.4;
	self.yaw_speed			= 2.5;

	self.points = 200;
	self.health	= self.max_health = 500;
	if(spawningsectorents)
	{
		self.health = enthealth;
		enthealth = 0;
	}
	
	self.targetswitchdelay	= 0.5;	
	self.alertnessdelay		= 0.5;
	self.alertness			= ALERTNESS_DAMAGE | ALERTNESS_CONE;

	self.engagedist_near	= 500;
	self.engagedist_far		= 700;

	self.behaviorflags		= BF_STRAFEINCOMBAT | BF_ROAM_NOTARGET;
	
	self.weapon 			= WEP_PLASMA;
	self.weaponshotvariant	= PROJ_PLASMA_LIGHT;
	self.firingrate			= '0.2 0.2 0';	
	self.weaponrange		= 1350;
	
	self.think = StartAI;
	self.nextthink = AIStartTime();
}

void light_tank() =
{
//	if(IsTriggered(light_tank))
//		return;

	if(!PreSpawnNPC(self, NPC_LIGHTTANK))
		return;

//	if(!self.objectname)
//		self.objectname = zonecpy(self.objectname, "Light Tank");
		
	self.shootfrom_index 	= gettagindex(self, "tag_projectile");
	
	self.movespeed			= 70;
	self.movementinertia	= 0.4;
	self.yaw_speed			= 2.5;

	self.points = 200;
	self.health	= self.max_health = 100*skillmultiple;
	if(spawningsectorents)
	{
		self.health = enthealth;
		enthealth = 0;
	}
	
	self.targetswitchdelay	= 0.5;	
	self.alertnessdelay		= 0.5;
	self.alertness			= ALERTNESS_DAMAGE | ALERTNESS_CONE;

	self.engagedist_near	= 500;
	self.engagedist_far		= 700;

	self.behaviorflags		= BF_STRAFEINCOMBAT | BF_ROAM_NOTARGET;
	
	self.weapon 			= WEP_PLASMA;
	self.weaponshotvariant	= PROJ_PLASMA_LIGHT;
	self.firingrate			= '0.5 1 0';	
	self.weaponrange		= 1350;
	
	self.think = StartAI;
	self.nextthink = AIStartTime();
}

void medium_tank() =
{
	if(!PreSpawnNPC(self, NPC_MEDIUMTANK))
		return;

//	if(!self.objectname)
//		self.objectname = zonecpy(self.objectname, "Medium Tank");		
		
	self.(shootfrom_index[0]) 	= gettagindex(self, "tag_projectile.L");
	self.(shootfrom_index[1]) 	= gettagindex(self, "tag_projectile.R");
	
	self.movespeed			= 40;
	self.movementinertia	= 0.5;	
//	self.acceleration		= 2;
	self.yaw_speed			= 1.75;

	self.points = 400;
	self.health	= self.max_health = 200*skillmultiple;
	if(spawningsectorents)
	{
		self.health = enthealth;
		enthealth = 0;
	}
	
	self.targetswitchdelay	= 0.5;	
	self.alertnessdelay		= 0.5;
	self.alertness			= ALERTNESS_DAMAGE | ALERTNESS_CONE;

	self.engagedist_near	= 500;
	self.engagedist_far		= 700;

	self.behaviorflags		= BF_STRAFEINCOMBAT | BF_ROAM_NOTARGET;
	
	self.weapon 			= WEP_PLASMA;
	self.weaponshotvariant	= PROJ_PLASMA_MED;
	self.burstrate			= '0.2 0.2 0';
	self.firingrate			= '1 2 4';	
	self.weaponrange		= 1350;
	
	self.think = StartAI;
	self.nextthink = AIStartTime();
}

void heavy_tank_proton() =
{
	if(!PreSpawnNPC(self, NPC_HEAVYTANK_PROTON))
		return;	

//	if(!self.objectname)
//		self.objectname = zonecpy(self.objectname, "Heavy Proton Tank");
	self.showhealth = TRUE;
		
	self.movespeed			= 25;
	self.movementinertia	= 0.3;
	self.yaw_speed			= 0.8;

	self.points = 2500;
	self.health	= self.max_health = 1000*skillmultiple;
	if(spawningsectorents)
	{
		self.health = enthealth;
		enthealth = 0;
	}
	
	self.targetswitchdelay	= 0.5;	
	self.alertnessdelay		= 0.5;
	self.alertness			= ALERTNESS_DAMAGE | ALERTNESS_CONE;

	self.engagedist_near	= 500;
	self.engagedist_far		= 700;
	self.weaponrange		= 2500;

	self.behaviorflags		= BF_ROAM;
	
	self.think = StartAI;
	self.nextthink = AIStartTime();	
}

void minigun_turret_firefunc() =
{
	self.waittomovetime = time+0.5;
	self.yaw_speed = 0.35;
	FireWeapon(self.weapon, 0, FALSE, 1);
}

void heavy_tank_minigun() =
{
	if(!PreSpawnNPC(self, NPC_HEAVYTANK_MINIGUN))
		return;	

//	if(!self.objectname)
//		self.objectname = zonecpy(self.objectname, "Heavy Minigun Tank");
	self.showhealth = TRUE;		
		
	self.movespeed			= 25;
	self.movementinertia	= 0.3;
	self.yaw_speed			= 0.8;

	self.points = 5000;
	self.health	= self.max_health = 1000*skillmultiple;
	if(spawningsectorents)
	{
		self.health = enthealth;
		enthealth = 0;
	}
	
	self.targetswitchdelay	= 0.5;	
	self.alertnessdelay		= 0.5;
	self.alertness			= ALERTNESS_DAMAGE | ALERTNESS_CONE;

	self.engagedist_near	= 500;
	self.engagedist_far		= 700;
	self.weaponrange		= 2500;

	self.behaviorflags		= BF_ROAM;
	
	self.think = StartAI;
	self.nextthink = AIStartTime();	
}

void lightning_tank_firingrules() =
{
	self.firetime = time+0.3;
}

void lightning_tank() =
{
	if(!PreSpawnNPC(self, NPC_LIGHTNINGTANK))
		return;	
	
//	if(!self.objectname)
//		self.objectname = zonecpy(self.objectname, "Ligntning Tank");
	
	self.shootfrom_index 	= gettagindex(self, "tag_shoot");	
	
	self.movespeed			= 100;
	self.movementinertia	= 0.4;	
	self.yaw_speed			= 2.5;

	self.points = 200;
	self.health	= self.max_health = 75*skillmultiple;
	if(spawningsectorents)
	{
		self.health = enthealth;
		enthealth = 0;
	}
	
	self.targetswitchdelay	= 0.5;	
	self.alertnessdelay		= 0.1;
	self.alertness			= ALERTNESS_DAMAGE | ALERTNESS_OMNIDIRECTIONAL;

	self.engagedist_near	= 350;
	self.engagedist_far		= 425;

	self.behaviorflags		= BF_ROAM | BF_STRAFEINCOMBAT | BF_HARASS;
	
	self.weapon 			= WEP_LIGHTNING;
	self.weaponrange		= 500+86;
	self.firingrate			= '2 2 0';	
	self.FiringRules		= lightning_tank_firingrules;
	
	self.think = StartAI;
	self.nextthink = AIStartTime();	
}

void micro_flyer_firingrules() =	{	self.ammo_rockets_current -= 1;	}

void micro_flyer() =
{
	if(!self.id)
		return;

//	if(!self.objectname)
//		self.objectname = zonecpy(self.objectname, "Micro Flyer");
		
	self.behaviorflags		= BF_STRAFEINCOMBAT | BF_ROAM_NOTARGET | BF_FLIES | BF_ROAM | BF_NOSLEEP;		
	self.movement_behavior	= MB_ROAM;
	self.flags =			self.flags - (self.flags & FL_NOREVIVE);
		
	PreSpawnNPC(self, NPC_MICROFLYER);
	
	self.activemovetype = MOVETYPE_NOCLIP;
	self.solid = SOLID_SLIDEBOX;
	
	self.movespeed			= 40;
	self.movementinertia	= 0.5;
	self.yaw_speed			= self.yaw_speed_base = 3.5;
	self.flightelevation	= 400;
	
	self.explodetime = 0.2;
	
	self.points = 250;
	self.health	= self.max_health = 100*skillmultiple;
	if(spawningsectorents)
	{
		self.health = enthealth;
		enthealth = 0;
	}
	
	self.targetswitchdelay	= 0.5;	
	self.alertnessdelay		= 0.5;
	self.alertness			= ALERTNESS_DAMAGE | ALERTNESS_OMNIDIRECTIONAL;	
	
	self.engagedist_far		= 400;	
	self.engagedist_near	= 600;
	

	if(self.owner.health <= self.owner.max_health*0.33)
	{
		self.weapon				= WEP_PROTON;
		self.firingrate			= '0.2 0.2 0';
	}
	else
	if(self.owner.health <= self.owner.max_health*0.66)
	{
		self.weapon				= WEP_HMISSILES;
		self.firingrate			= '0.5 0.5 0';
		if(!(self.flags & FL_REVIVE))
			self.ammo_rockets_current = self.ammo_rockets_max = 5;			
	}
	else
	{
		self.weapon				= WEP1_ROCKETPOD;
		self.firingrate			= '0.5 0.5 0';		
		if(!(self.flags & FL_REVIVE))
			self.ammo_rockets_current = self.ammo_rockets_max = 5;	
	}
	
//	self.firingrate 		= '1 2 4';
//	self.burstrate			= '0.2 0.2 0';
	
	self.weaponrange		= 1350;	
	self.maxpitchaim		= 45;
	self.maxfiringpos		= 1;
	if(self.ammo_rockets_max)
		self.FiringRules		= micro_flyer_firingrules;
	if(!(self.flags & FL_REVIVE))
		self.refueltime			= time + 15;
	
//	self.removewhendead		= TRUE;
	
	self.think = StartAI;
	self.nextthink = time;//AIStartTime();
}

void carrier_stagetransition() =
{
	if(time < self.waittomovetime)
		return;

	self.FastThink = SUB_Null;
	self.firebuilduptime = 0;	
	
	if(self.health <= 0)
		return;
	
	local entity e, nexte;
	e = self.list_childchain;
	while(e)
	{
		nexte = e.childchain;
		if(e != self)
		if(e.npcclass == NPC_MICROFLYER)
			SH_RemoveEnt(e);
	
		e = nexte;
	}
	
	self.numchildren = 0;
}

void carrier_tank_eventfunc_stagetwo() =
{
	KillChildren(self, self);
	self.maxchildren = 6;

	self.waittomovetime = time+1;
	self.FastThink = carrier_stagetransition;
}

void carrier_tank_eventfunc_stagethree() =
{
	KillChildren(self, self);
	self.maxchildren = 4;
	
	self.waittomovetime = time+1;
	self.FastThink = carrier_stagetransition;
}

void carrier_tank() =
{
	if(!PreSpawnNPC(self, NPC_CARRIERTANK))
		return;	

//	if(!self.objectname)
//		self.objectname = zonecpy(self.objectname, "Carrier Tank");
	self.showhealth = TRUE;		
		
	self.movespeed			= 25;
	self.movementinertia	= 0.6;
	self.yaw_speed			= 0.5;

	self.points = 20000;
	self.health	= self.max_health = 8000*skillmultiple;
	if(spawningsectorents)
	{
		self.health = enthealth;
		enthealth = 0;
	}
	
	self.targetswitchdelay	= 0.5;	
	self.alertnessdelay		= 0.5;
	self.alertness			= ALERTNESS_DAMAGE | ALERTNESS_OMNIDIRECTIONAL;

	self.engagedist_near	= 500;
	self.engagedist_far		= 700;

	self.behaviorflags		= BF_ROAM | BF_SPAWNCHILDREN | BF_AVOIDEDGES | BF_STRAFEINCOMBAT | BF_LOOKFORALLIES;
	self.SpawnChildrenFunc	= micro_flyer;
	self.childtagprefix		= "tag_flier";
	self.maxchildren		= 8;
	
	self.SecondaryWeaponFiringRules = AI_FireShockwave;
	self.firingrate			= '5 5 0';	
	self.secondaryfiringrate = '4 4 0';
	
	self.flags 				= self.flags | FL_NOREVIVE | FL_ISBOSS | FL_SOLIDONDEATH;
	
	self.TriggerEventFunc_StageTwo = carrier_tank_eventfunc_stagetwo;
	self.TriggerEventFunc_StageThree = carrier_tank_eventfunc_stagethree;
	
	self.think = StartAI;
	self.nextthink = AIStartTime();	
	
//	newturret("tag_repair_turret", "models/enemies/carrier_tank/carrier_turret.dpm", WEP_REPAIR, '3 3 0', 2, 80, -80, 0);	
//	self.hasturrets = TRUE;
}

void destroyer_tank_cannonbuildup() =
{
	if(time < self.firebuilduptime)
		return;

	self.FastThink = SUB_Null;
	self.firebuilduptime = 0;	
	
	if(self.health <= 0)
		return;
	
//	self.SendFlags = self.SendFlags | SFL_ANIM_SHOOT2;	
	SetEventFlag_Animation(self, ANIM_DESTROYER_SHOOT2);
	FireWeapon(self.weapon, 0, FALSE, 1);
}

void destroyer_tank_firefunc() =
{
//	self.SendFlags = self.SendFlags | SFL_ANIM_SHOOT1;
	SetEventFlag_Animation(self, ANIM_DESTROYER_SHOOT1);
	self.waittomovetime = time+1.7;
	self.firebuilduptime = time+1.2;
	self.FastThink = destroyer_tank_cannonbuildup;
	self.yaw_speed = 0.4;
}

void destroyer_tank() =
{
	if(!PreSpawnNPC(self, NPC_DESTROYERTANK))
		return;	
	
//	if(!self.objectname)
//		self.objectname = zonecpy(self.objectname, "Destroyer Tank");
	self.showhealth = TRUE;	
	
	self.shootfrom_index 	= gettagindex(self, "tag_shoot");	
	
	self.movespeed			= 45;
	self.movementinertia	= 0.6;
	self.yaw_speed = self.yaw_speed_base = 0.5;

	self.points = 30000;
	self.health	= self.max_health = 8000*skillmultiple;
	if(spawningsectorents)
	{
		self.health = enthealth;
		enthealth = 0;
	}
	
	self.targetswitchdelay	= 0.5;	
	self.alertnessdelay		= 0.5;
	self.alertness			= ALERTNESS_DAMAGE | ALERTNESS_OMNIDIRECTIONAL;

	self.engagedist_near	= 700;
	self.engagedist_far		= 900;

	self.behaviorflags		= BF_ROAM_NOTARGET | BF_ROAM_ALTERNATE | BF_STRAFEINCOMBAT | BF_INCREASESPEEDATSTAGETWO | BF_INCREASESPEEDATSTAGETHREE | BF_LOOKFORALLIES;

	self.roamdata			 = '3 5 0'; //  BF_ROAM_NOTARGET for 3 seconds / BF_ROAM for 5 seconds
	
	self.weapon 			= WEP_DESTROYERBEAM;
//	self.secondaryweapon	= WEP2_SHOCKWAVE;
	self.SecondaryWeaponFiringRules = AI_FireShockwave;
	self.firingrate			= '5 5 0';	
	self.secondaryfiringrate = '4 4 0';
	self.weaponrange		= 3500;	
//	self.maxpitchaim		= 45;	
	
	self.FireFunc			= destroyer_tank_firefunc;
	
	self.flags 				= self.flags | FL_NOREVIVE | FL_ISBOSS | FL_SOLIDONDEATH;	
	
	self.think = StartAI;
	self.nextthink = AIStartTime();
	
//	newturret("tag_pturret_f.L", "models/enemies/destroyer/dt_pturret_l.dpm", WEP_PLASMA, '0.5 0.5 0', 1, 115, -40, 45);	
//	newturret("tag_pturret_f.R", "models/enemies/destroyer/dt_pturret_r.dpm", WEP_PLASMA, '0.5 0.5 0', 1, 40, -115, -45);
//	newturret("tag_pturret_r.L", "models/enemies/destroyer/dt_pturret_l.dpm", WEP_PLASMA, '0.5 0.5 0', 1, 225, -40, 45);
//	newturret("tag_pturret_r.R", "models/enemies/destroyer/dt_pturret_r.dpm", WEP_PLASMA, '0.5 0.5 0', 1, 40, -225, -45);
//	newturret("tag_repair_turret", "models/enemies/destroyer/dt_rturret.dpm", WEP_REPAIR, '3 3 0', 2, 80, -80, 0);
	
//	self.hasturrets = TRUE;
}

void EnemySpawnGroup() =
{
	local float count, r, tagnum, tagindex, numoptions, numents, numtagoptions, e_spawntime, spawned_lighttanks, spawned_mediumtanks, spawned_heavytanks, spawned_lightningtanks, validnpctype;
	local entity e, tagmdl;
	local vector pos;
	local string mdl;
	
	if(self.objclass == OBJ_PORTAL)
	{	
//		numtagoptions = 8;
		tagmdl = spawn();
		mdl = "models/enemies/portal/portal.dpm";
		setmodel(tagmdl, mdl);
		setorigin(tagmdl, self.origin);
		tagnum = bound(1, ceil(random()*8), 8);	
	}
	else
	if(self.objclass == OBJ_ENEMYSPAWN)
	{
		tagmdl = self;
//		numtagoptions = 3;
		tagnum = 1;
	}
	
	if(self.spawner_max_lighttanks)		{		numents += self.spawner_max_lighttanks;			numoptions++;	}
	if(self.spawner_max_mediumtanks)	{		numents += self.spawner_max_mediumtanks;		numoptions++;	}
	if(self.spawner_max_heavytanks)		{		numents += self.spawner_max_heavytanks;			numoptions++;	}
	if(self.spawner_max_lightningtanks)	{		numents += self.spawner_max_lightningtanks;		numoptions++;	}
	
	if(!numoptions)
		return;
	
	if(numents > self.spawner_max_ents)
		numents = self.spawner_max_ents;
	
	for(count = 0; count < numents; count++)
	{	
		e = SpawnEnt();
		e.angles_y = self.angles_y;
		e.movement_behavior	= MB_ROAM;		
		e.spawnedfrom = self.objclass;
		
		SetOwner(e, self);
		SetParent(e, e);
		
		if(self.objclass == OBJ_PORTAL || self.objclass == OBJ_ENEMYSPAWN)
		{	
			if(self.objclass == OBJ_PORTAL)
			{
			//	e.SendFlags = e.SendFlags | SFL_TELEPORT;
				if(tagnum > 8)
					tagnum = 1; 
			}
			
			tagindex = gettagindex(tagmdl, strcat("tag_spawn", ftos(tagnum)));
			pos = gettaginfo(tagmdl, tagindex);	
			tagnum++;
		}
		else		
			pos = self.origin;
		
		tracebox(pos+'0 0 128', e.mins, e.maxs, pos+'0 0 -128', FALSE, e);
		
		if(trace_fraction == 1 || trace_ent.objclass == OBJ_NPC)
		{
			if(trace_fraction == 1)
				dprint("EnemySpawnGroup: Warning: Spawned enemy outside of level.\n");
			
			SH_RemoveEnt(e);
			continue;
		}
			
		e.origin_base = trace_endpos;

		r = bound(1, ceil(random()*numoptions), numoptions);	
		
		validnpctype = FALSE;
		while(!validnpctype)
		{
			switch(r)
			{
				case 1:		if(spawned_lighttanks < self.spawner_max_lighttanks)			validnpctype = TRUE;	else 	r++;	break;
				case 2:		if(spawned_mediumtanks < self.spawner_max_mediumtanks)			validnpctype = TRUE;	else	r++;	break;
				case 3:		if(spawned_heavytanks < self.spawner_max_heavytanks)			validnpctype = TRUE;	else	r++;	break;
				case 4:		if(spawned_lightningtanks < self.spawner_max_lightningtanks)	validnpctype = TRUE;	else	r++;	break;
			}
			if(r > 4)
				r = 1;
		}
		
		switch(r)
		{
			case 1:		e.postinitthink = light_tank;		e_spawntime = time+0.5;		spawned_lighttanks++;
						if(spawned_lighttanks == self.spawner_max_lighttanks)
							numoptions -= 1;
			break;
			
			case 2: 	e.postinitthink = medium_tank;		e_spawntime = time+1;		spawned_mediumtanks++;
						if(spawned_mediumtanks == self.spawner_max_mediumtanks)
							numoptions -= 1;
			break;
			
			case 3: 	e.postinitthink = heavy_tank_proton;	e_spawntime = time+2;		spawned_heavytanks++;
						if(spawned_heavytanks == self.spawner_max_heavytanks)
							numoptions -= 1;
			break;
			
			case 4:		e.postinitthink = lightning_tank; 	e_spawntime = time+0.75;	spawned_lightningtanks++;
						if(spawned_lightningtanks == self.spawner_max_lightningtanks)
							numoptions -= 1;
			break;
		}	

	//	if(self.objclass == CLASS_PORTAL)
	//	{
			e.solid = SOLID_NOT;
			e.movetype = MOVETYPE_NONE;
			e.teleporttouchtime = time + 1;
	//	}		
		
		InitializeSharedEnt(e);	
		
		if(IsStuck(e))
		{
			SH_RemoveEnt(e);
			continue;		
		}
		
		if(LOADINGFROMEPISODE > EPISODE)
		{
			SH_RemoveEnt(e);
			continue;
		}		
		
		e.teleporttouchtime = time + e.spawntime;
	}
	
	if(tagmdl != self)
		remove(tagmdl);
}

void TriggerEnemySpawner() =
{
	self.istoggled = TRUE;
	
	SetObjectAppearance(self, self.objclass, self.variant);
	
	EnemySpawnGroup();
	
	MakeObjectInvisibleToClients(self);
}

void enemyspawner() =
{
/*	if(!GameMode_CanSpawnEnemies(gamemode) || (!self.id && missionfileexists))
	{
		SH_RemoveEnt(self);
		return;
	}*/

	if(!GameMode_CanSpawnEnemies(gamemode))
	{
		SH_RemoveEnt(self);
		return;
	}

	if(!InitializeObject(self, OBJ_ENEMYSPAWN, 0, SOLID_NOT))
		return;	
	
	if(!self.spawner_max_ents)
		SetEnemySpawnerMaxValues();
	
/*	SetOwner(self, self);//self.owner = self;
	SetParent(self, self);
	self.class = CLASS_OBJECT;
	self.objclass = CLASS_ENEMYSPAWN;	
	
	SetID(self);

	ObjectChain_Add(self);	*/
	
	MakeObjectInvisibleToClients(self);
	
	self.SendEntity = SendObject;
			
	if(self.triggerentid || self.istarget)
	{
		self.TriggerFunc = TriggerEnemySpawner;
		return;
	}	
			
	TriggerEnemySpawner();
}

float		PORTAL_INFLUENCE		= 1500;
float		PORTAL_MAXPOP			= 20;

void PortalThink() =
{
	local float count;//, spawnsmin, spawnsmax;
//	spawnsmin = 5;
//	spawnsmax = 8;
	local entity e;
	e = findradius(self.origin, PORTAL_INFLUENCE);
	while(e)
	{
		if(e.objclass == OBJ_NPC)
		if(!(e.health <= 0))
			count++;
		e = e.chain;

		if(!e)
		if(count < self.spawner_max_areaents)
			EnemySpawnGroup();//bound(spawnsmin, floor(random()*spawnsmin+1)+(spawnsmax-spawnsmin), spawnsmax));
	}
	
	self.nextthink = time + 30;
}

void PortalToggle() =
{
	if(!(self.health <= 0))

	self.istoggled = !self.istoggled;

	SetObjectAppearance(self, self.objclass, self.variant);	
	self.SendFlags = self.SendFlags | SFL_RESET;	
	
	if(self.istoggled)
		self.nextthink = FALSE;
	else
	{
		self.nextthink = time + 3;
		self.think = PortalThink;
	}
}

void portal() =
{
	if(!GameMode_CanSpawnEnemies(gamemode))
	{
		SH_RemoveEnt(self);
		return;
	}

	if(!InitializeObject(self, OBJ_PORTAL, 0, SOLID_BSP))
		return;
		
//	if(!self.objectname)
//		self.objectname = zonecpy(self.objectname, "Portal");
	self.showhealth = 2;		
		
	if(!self.spawner_max_ents)
		SetPortalMaxValues();
		
//	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	self.points = 5000;
	self.health	= self.max_health = 2000*skillmultiple;
	self.damage_effects = self.damage_effects | DMGEF_BURN;
	
	if(spawningsectorents)
	{
		self.health = enthealth;
		enthealth = 0;
	}
	
	self.explodetime = 1.8;

	self.think = PortalThink;
	
	self.TriggerFunc = PortalToggle;
	
	if(self.istoggled)
		return;	
		
	self.nextthink = time + 3;
	self.think = PortalThink;
}