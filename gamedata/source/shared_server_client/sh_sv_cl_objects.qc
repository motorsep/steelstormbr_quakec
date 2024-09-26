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
void PrecacheModel(string modelname) =
{
	if((CODEBASE == CLIENTCODE && !adminmodeactive)
	|| spawningsectorents)
		return;

	precache_model(modelname);
}

float IsAttachedAIClass(float aiclass) =
{
	switch(aiclass)
	{
		case NPC_TURRET:	return TRUE;		break;
	}

	return FALSE;
}

/*float IsUsingCollisionHull(entity e) =
{
	if(strtolower(substring(e.model, strlen(e.model)-10, 7)) == "_chull.")
		return TRUE;
		
	return FALSE;
}*/

void SetAndPrecacheModel(entity e, string modelname) =
{
//	PrecacheModel(modelname);
	setmodel(e, modelname);
}

string GenerateDeadModelName(string modelname, float mdlnum) =
{
	local string suffix;

	suffix = substring(modelname, strlen(modelname)-4, 4);
	modelname = strcat(substring(modelname, 0, strlen(modelname)-4), "_dead");
	modelname = strcat(modelname, ftos(mdlnum));
	modelname = strcat(modelname, suffix);
	return modelname;
}

string GenerateChullModelName(entity e, string modelname) =
{
	local string suffix;
	local float angfloor, angceil, angfloordiff, angceildiff;
	
	if(e.chullrotation < CHULLROT_ALL)
	if((e.angles_base_y/45) - (floor(e.angles_base_y/45)))
	{
		angfloor = floor(e.angles_base_y/45)*45;
		angceil = ceil(e.angles_base_y/45)*45;
		
		angfloordiff = AngleDifference(angfloor, e.angles_base_y);
		angceildiff = AngleDifference(angceil, e.angles_base_y);
		
		if(angfloordiff < angceildiff)
			e.angles_base_y = angfloor;
		else
			e.angles_base_y = angceil;
	}
	
	if(e.chullrotation >= CHULLROT_ROUND)
	{
		e.angles_y = 0;
		return modelname;
	}
	else
	if(!((e.angles_base_y/90) - floor(e.angles_base_y/90))) // if chull is at 45 degrees subtract 45 degrees from chull angles to match alt chull model
	{
		e.angles_y = e.angles_base_y;
		return modelname;
	}
	
	e.angles_y = e.angles_base_y - 45;
			
	suffix = substring(modelname, strlen(modelname)-4, 4);
	modelname = strcat(substring(modelname, 0, strlen(modelname)-4), "_45");
	modelname = strcat(modelname, suffix);
	
	return modelname;	
}

void PrecacheModelForStates(string mdl, float states, float e_deadmodels) =
{
	local float count, numdeadmodels;
	local string modelname;
	
	if(strlen(mdl))
	{
		if(states != 3)
		if(states != 1)
		if(e_deadmodels != -1)
		{
			numdeadmodels = max(1, e_deadmodels);
			for(count = 1; count <= numdeadmodels; count++)
			{
				modelname = GenerateDeadModelName(mdl, count);
				PrecacheModel(modelname);
			}
		}
		
		if(states != 2)
			PrecacheModel(mdl);
	}
}

void SetObjectModel(entity e, string modelname, float states) =
{
	local string suffix;
	
	// state 3 = don't look for _dead suffix
	
//	if(states < 2)
	if(strlen(modelname))
		PrecacheModelForStates(modelname, states, e.deadmodels);
	
	if(e.isdead)
	if(e.deadmodels == -1 || e.flags & FL_ITEM)
	{
		MakeObjectInvisibleToClients(e);
		if(CODEBASE == SERVERCODE)
			return;
	}
	else
	if(states != 3)
		modelname = GenerateDeadModelName(modelname, e.deadmodelnum);

	setmodel(e, modelname);
}

void SetObjectSize(entity e, vector e_mins, vector e_maxs) =
{
//	if(IsUsingCollisionHull(e))
//	if(CODEBASE == SERVERCODE)
//	if(e.isusingcollisionhull)
//		return;
	setsize(e, e_mins, e_maxs);
}

void SetObjectSize_AI(entity e, vector e_mins, vector e_maxs) =
{
	if(CODEBASE == CLIENTCODE)
	{
		e_mins = e_mins*1.5;
		e_maxs = e_maxs*1.5;
	}
	
	SetObjectSize(e, e_mins, e_maxs);
}

void UseCollisionHull(entity e, string clientmodel, float usemodelstates, string chullmodel, float usechullstates) =
{
	// states
	// 0 = always
	// 1 = only when alive
	// 2 = only when dead
	// 3 = always, but never use dead model, use base chull model instead
	
//	if(usemodelstates != 2)
	// precache client models while loading on server
	if(strlen(clientmodel))
		PrecacheModelForStates(clientmodel, usemodelstates, e.deadmodels);
	
//	if(strlen(chullmodel))
//		PrecacheModelForStates(chullmodel, usechullstates, e.deadmodels);
	
	if((e.isdead && usechullstates == 1)
	|| (!e.isdead && usechullstates == 2))	
		e.isusingcollisionhull = FALSE;
	else
		e.isusingcollisionhull = TRUE;

//	e.chullrotation = CHULLROT_ALL;	
		
	if(CODEBASE == CLIENTCODE || !e.isusingcollisionhull)
		SetObjectModel(e, clientmodel, usemodelstates);
	else
	if(CODEBASE == SERVERCODE)
	{	
		if(strlen(chullmodel))
			chullmodel = GenerateChullModelName(e, chullmodel);
		SetObjectModel(e, chullmodel, usechullstates);
	}
}

void SetObjectLight(entity e, vector rgb, float rad, float lstyle, float shadows, string tag, vector ofs) =
{
	if(CODEBASE == SERVERCODE)
		return;

	SetObjectLight_Client(e, rgb, rad, lstyle, shadows, tag, ofs);
}

void SetObjectEffect(entity e, string effectname, string tag, vector ofs) =
{
	if(CODEBASE == SERVERCODE)
		return;
		
	if(e.isdead)
		return;
		
	local entity emitter;
	local float index;
	
	if(tag != "")
		index = gettagindex(e, tag);
	
	for(emitter = e.list_tagentchain; emitter; emitter = emitter.tagentchain)
	{
		if(emitter.objclass == OBJ_PARTICLEEMITTER)
		if(emitter.tag_index == index && emitter.origin == ofs)
			return;
	}
	
	emitter = spawn();
	emitter.objclass = OBJ_PARTICLEEMITTER;

	emitter.particleemittereffect = zonecpy(emitter.particleemittereffect, effectname);
	emitter.particleindex = particleeffectnum(emitter.particleemittereffect);		
	
	Attach(emitter, e, index);
	setorigin(emitter, emitter.origin + ofs);
	
	ParticleEmitterChain_Add(emitter);
}

string GetTeamName(float teamnum) =
{
	local string s;

	switch(teamnum)
	{
		case 0:		s = "Neutral";	break;
		case 1:		s = "Red";		break;
		case 2:		s = "Blue";		break;
	}
	
	return s;
}

vector GetTeamColor(float teamnum) =
{
	local vector rgb;

	if(!GameMode_HasTeams(gamemode))
		teamnum = 0;
	
	switch(teamnum)
	{
		case 0:		rgb = '1 1 1';		break;
		case 1:		rgb = '1 0 0';		break;
		case 2:		rgb = '0 0 1';		break;
	}

	return rgb;
}

void SetObjectAppearance(entity e, float CLASS, float VARIANT) =
{
	local string mdl, chull;
	local float episode, e_skin, chullstates;
	local entity t;
	
	switch(CLASS)
	{
		case 0:
			if(e.class == CLASS_PLAYER)
			{
				e.canhaveteam = TRUE;
				SetMapObject(e);
				PrecacheModel("models/player/player_gibs1.dpm");
				SetObjectModel(e, "models/player/player.dpm", 0);
				if(!e.isdead)
					SetObjectLight(e, '0 0.4 1', 125, 0, 0, "", '-64 0 32');

				SetObjectSize(e, '-64 -64 0', '64 64 102');	
				e.frames_idle			= '1 12 12';
				e.frames_move			= '13 13 12';
				e.frames_shoot_hmissiles_R = '85 96 12';
				e.frames_shoot_hmissiles_L = '97 108 12';	
				e.EffectFunc = Effects_Player;			
				e.DeathFunc = Explode_Small;
			}
		break;
	
		case OBJ_PATH:
			SetObjectModel(e, "models/misc/waypoint2.dpm", 1);
			SetObjectSize(e, '-16 -16 0', '16 16 16');
		break;
	
		case OBJ_NPC:
			e.canhaveteam = TRUE;
			e.chullrotation = CHULLROT_ALL;
		
			if(VARIANT == NPC_LIGHTTANK)
			{
				SetObjectModel(e, "models/enemies/light_tank/light_tank.dpm", 0);
				SetObjectSize_AI(e, '-48 -48 0', '48 48 83');
				e.EffectFunc = Effects_NPC_LightTank;
				e.DeathFunc = Explode_Small;
				e.shieldscale = 1;
				e.frames_idle			= '1 12 12';
				e.frames_move			= '13 13 12';
				e.spawntime				= 0.5;				
			}
			else
			if(VARIANT == NPC_MEDIUMTANK)
			{
				SetObjectModel(e, "models/enemies/medium_tank/medium_tank.dpm", 0);
				SetObjectSize_AI(e, '-48 -48 0', '48 48 88');
				e.EffectFunc = Effects_NPC_MediumTank;
				e.DeathFunc = Explode_Small;
				e.shieldscale = 1;
			//	e.frames_idle			= '0 0 12';
			//	e.frames_move			= '0 0 12';
				e.spawntime				= 1;				
			}
			else
			if(VARIANT == NPC_HEAVYTANK_PROTON)
			{
				SetObjectModel(e, "models/enemies/heavy_tank/heavy_tank.dpm", 0);
				SetObjectSize_AI(e, '-52 -52 0', '52 52 114');
				e.skin = 1;
				e.EffectFunc = Effects_NPC_HeavyTank;
				e.DeathFunc = Explode_Small;
				e.shieldscale = 1.5;
			//	e.frames_idle			= '0 0 12';
			//	e.frames_move			= '0 0 12';
				e.spawntime				= 2;				
				Turret(e, "tag_minigun_turret", '0 0 0', NPC_TURRETHEAD_HEAVYTANK_PROTON_MED, WEP_PROTON_MED, 0, '1 2 4', '0.2 0.2 0', 1, 180, -180, 0, FALSE);
				Turret(e, "tag_plasma_turret.L", '0 0 0', NPC_TURRETHEAD_HEAVYTANK_PROTON_L, WEP_PROTON, 0, '1 2 4', '0.2 0.2 0', 2, 179, -65, 0, FALSE);	
				Turret(e, "tag_plasma_turret.R", '0 0 0', NPC_TURRETHEAD_HEAVYTANK_PROTON_R, WEP_PROTON, 0, '1 2 4', '0.2 0.2 0', 2, 65, -179, 0, FALSE);
				e.hasturrets = TRUE;
			}
			else
			if(VARIANT == NPC_HEAVYTANK_MINIGUN)
			{
				SetObjectModel(e, "models/enemies/heavy_tank/heavy_tank.dpm", 0);
				SetObjectSize_AI(e, '-52 -52 0', '52 52 114');
				e.EffectFunc = Effects_NPC_HeavyTank;
				e.DeathFunc = Explode_Small;
				e.shieldscale = 1.5;
			//	e.frames_idle			= '0 0 12';
			//	e.frames_move			= '0 0 12';
				e.spawntime				= 2;				
				t = Turret(e, "tag_minigun_turret", '0 0 0', NPC_TURRETHEAD_HEAVYTANK_MINIGUN, WEP1_MINIGUN, BULL_MINIGUN_HEAVY, '0.1 0.1 0', '0 0 0', 1, 180, -180, 0, FALSE);
				if(t)
					t.FireFunc = minigun_turret_firefunc;
				Turret(e, "tag_plasma_turret.L", '0 0 0', NPC_TURRETHEAD_HEAVYTANK_PLASMA_L, WEP_PLASMA, PROJ_PLASMA_HEAVY, '0.5 0.5 0', '0 0 0', 2, 179, -65, 0, FALSE);	
				Turret(e, "tag_plasma_turret.R", '0 0 0', NPC_TURRETHEAD_HEAVYTANK_PLASMA_R, WEP_PLASMA, PROJ_PLASMA_HEAVY, '0.5 0.5 0', '0 0 0', 2, 65, -179, 0, FALSE);
				e.hasturrets = TRUE;
			}
			else			
			if(VARIANT == NPC_LIGHTNINGTANK)
			{
				episode = 2;
				SetObjectModel(e, "models/enemies/lightning_tank/lightning_tank.dpm", 0);
				SetObjectSize_AI(e, '-48 -48 0', '48 48 62');
				e.EffectFunc = Effects_NPC_LightningTank;
				e.DeathFunc = Explode_Small;
				e.shieldscale = 1.2;
			//	e.frames_idle			= '0 0 12';
			//	e.frames_move			= '0 0 12';
				e.spawntime				= 0.75;				
			}
			else
			if(VARIANT == NPC_MICROFLYER)
			{
				episode = 2;
			//	e.deadmodels = -1;		
				SetObjectModel(e, "models/enemies/flier/flier.dpm", 0);
				SetObjectSize_AI(e, '-21 -21 0', '21 21 42');
				e.EffectFunc = Effects_NPC_MicroFlyer;
				e.DeathFunc = Explode_Small;
				e.shieldscale = 0.8;
			//	if(e.isdead)
			//		e.skin = 1;
			//	else
			//		e.skin = 2;
			//	e.frames_idle			= '0 0 12';
			//	e.frames_move			= '0 0 12';				
			}
			else
			if(VARIANT == NPC_CARRIERTANK)
			{
				episode = 2;
				PrecacheModel("models/enemies/flier/flier.dpm");
			//	UseCollisionHull(e, "models/enemies/carrier_tank/carrier_tank.dpm", 0, "models/enemies/carrier_tank/carrier_tank_chull.dpm", 2);
				SetObjectModel(e, "models/enemies/carrier_tank/carrier_tank.dpm", 0);
				SetObjectSize_AI(e, '-132 -132 0', '132 132 211');
				e.EffectFunc = Effects_NPC_CarrierTank;
				e.DeathFunc = Explode_Large;
				e.shieldscale = 2.5;
				Turret(e, "tag_repair_turret", '0 0 0', NPC_TURRETHEAD_CARRIERTANK_REPAIR, WEP_REPAIR, 0, '3 3 0', '0 0 0', 2, 80, -80, 0, FALSE);	
				e.hasturrets = TRUE;	
			//	e.frames_idle			= '0 0 12';
			//	e.frames_move			= '0 0 12';				
			}
			else
			if(VARIANT == NPC_DESTROYERTANK)
			{
				episode = 2;
//				UseCollisionHull(e, "models/enemies/destroyer/destroyer_tank.dpm", 0, "models/enemies/destroyer/destroyer_tank_chull.dpm", 2);
				SetObjectModel(e, "models/enemies/destroyer/destroyer_tank.dpm", 0);
				SetObjectSize_AI(e, '-132 -132 0', '132 132 313');
				e.EffectFunc = Effects_NPC_DestroyerTank;
				e.DeathFunc = Explode_Large;
				e.shieldscale = 3.5;
				e.frames_idle			= '1 48 24';
				e.frames_move			= '49 60 24';				
				Turret(e, "tag_pturret_f.L", '0 0 0', NPC_TURRETHEAD_DESTROYER_PLASMA_L, WEP_PROTON, 0, '0.5 0.5 0', '0 0 0', 1, 115, -40, 45, 2);	
				Turret(e, "tag_pturret_f.R", '0 0 0', NPC_TURRETHEAD_DESTROYER_PLASMA_R, WEP_PROTON, 0, '0.5 0.5 0', '0 0 0', 1, 40, -115, -45, 2);
				Turret(e, "tag_pturret_r.L", '0 0 0', NPC_TURRETHEAD_DESTROYER_PLASMA_L, WEP_PROTON, 0, '0.5 0.5 0', '0 0 0', 1, 225, -40, 45, 3);
				Turret(e, "tag_pturret_r.R", '0 0 0', NPC_TURRETHEAD_DESTROYER_PLASMA_R, WEP_PROTON, 0, '0.5 0.5 0', '0 0 0', 1, 40, -225, -45, 3);
				Turret(e, "tag_repair_turret", '0 0 0', NPC_TURRETHEAD_DESTROYER_REPAIR, WEP_REPAIR, 0, '3 3 0', '0 0 0', 2, 80, -80, 0, FALSE);
				e.hasturrets = TRUE;			
			}
			else
			if(VARIANT == NPC_LIGHTPLASMATURRET)
			{
				PrecacheModelForStates("models/enemies/turrets/turret_plasma.dpm", 2, e.deadmodels);
				if(e.isdead)
					SetObjectModel(e, "models/enemies/turrets/turret_plasma.dpm", 2);
				else
					SetObjectModel(e, "models/enemies/turrets/turret_base.dpm", 1);
				SetObjectSize_AI(e, '-64 -64 0', '64 64 89');
				e.EffectFunc = Effects_NPC_Turret_Generic;
				e.DeathFunc = Explode_Small;
				e.shieldscale = 1;
				e.spawntime				= 0.5;					
				Turret(e, "", '0 0 48', NPC_TURRETHEAD_STATIONARY_PLASMA, WEP_PLASMA, PROJ_PLASMA_DEEP, '0.5 0.5 0', '0 0 0', 2, 180, -180, 0, FALSE);
				e.hasturrets = TRUE;			
			}
			else
			if(VARIANT == NPC_HEAVYBEAMTURRET)
			{
				episode = 2;
				PrecacheModelForStates("models/enemies/turrets/turret_beam.dpm", 2, e.deadmodels);
				if(e.isdead)
					SetObjectModel(e, "models/enemies/turrets/turret_beam.dpm", 2);
				else
					SetObjectModel(e, "models/enemies/turrets/turret_base.dpm", 1);
				SetObjectSize_AI(e, '-64 -64 0', '64 64 114');
				e.EffectFunc = Effects_NPC_Turret_Generic;
				e.DeathFunc = Explode_Small;
				e.shieldscale = 1;
				e.spawntime				= 0.5;				
				t = Turret(e, "", '0 0 48', NPC_TURRETHEAD_STATIONARY_BEAM, WEP_TURRETBEAM, 0, '3 3 0', '0 0 0', 2, 180, -180, 0, FALSE);
				if(t)
					t.FireFunc = beam_turret_firefunc;
				e.hasturrets = TRUE;			
			}		
			else
			if(VARIANT == NPC_ROCKETTURRET)
			{
				episode = 2;
				PrecacheModelForStates("models/enemies/turrets/turret_rocket.dpm", 2, e.deadmodels);
				if(e.isdead)
					SetObjectModel(e, "models/enemies/turrets/turret_rocket.dpm", 2);
				else
					SetObjectModel(e, "models/enemies/turrets/turret_base.dpm", 1);
				SetObjectSize_AI(e, '-64 -64 0', '64 64 96');
				e.EffectFunc = Effects_NPC_Turret_Generic;		
				e.DeathFunc = Explode_Small;
				e.shieldscale = 1;
				e.spawntime				= 0.5;				
				Turret(e, "", '0 0 48', NPC_TURRETHEAD_STATIONARY_ROCKET, WEP1_ROCKETPOD, 0, '1 1 0', '0 0 0', 1, 180, -180, 0, FALSE);
				e.hasturrets = TRUE;			
			}		
			else	
			if(VARIANT == NPC_REPAIRTURRET)
			{
				PrecacheModelForStates("models/enemies/turrets/turret_repair.dpm", 2, e.deadmodels);
				if(e.isdead)
					SetObjectModel(e, "models/enemies/turrets/turret_repair.dpm", 2);
				else
					SetObjectModel(e, "models/enemies/turrets/turret_base.dpm", 1);
				SetObjectSize_AI(e, '-64 -64 0', '64 64 110');
				e.EffectFunc = Effects_NPC_Turret_Generic;				
				e.DeathFunc = Explode_Small;
				e.shieldscale = 1;
				e.spawntime				= 0.5;				
				Turret(e, "", '0 0 48', NPC_TURRETHEAD_STATIONARY_REPAIR, WEP_REPAIR, 0,  '3 3 0', '0 0 0', 1, 180, -180, 0, FALSE);
				e.hasturrets = TRUE;			
			}		
			else
			if(VARIANT == NPC_TURRETHEAD_HEAVYTANK_PROTON_L)
			{
				SetObjectModel(e, "models/enemies/heavy_tank/ht_plasma_turret_L.dpm", 1);
				e.skin = 1;
				e.EffectFunc = Effects_NPC_HeavyTank_TurretHead;
			}
			else
			if(VARIANT == NPC_TURRETHEAD_HEAVYTANK_PROTON_R)
			{
				SetObjectModel(e, "models/enemies/heavy_tank/ht_plasma_turret_R.dpm", 1);
				e.skin = 1;
				e.EffectFunc = Effects_NPC_HeavyTank_TurretHead;
			}
			else
			if(VARIANT == NPC_TURRETHEAD_HEAVYTANK_PROTON_MED)
			{
				SetObjectModel(e, "models/enemies/heavy_tank/ht_minigun_turret.dpm", 1);	
				e.skin = 1;
				e.EffectFunc = Effects_NPC_HeavyTank_TurretHead;
			}					
			else			
			if(VARIANT == NPC_TURRETHEAD_HEAVYTANK_PLASMA_L)
			{
				SetObjectModel(e, "models/enemies/heavy_tank/ht_plasma_turret_L.dpm", 1);
				e.EffectFunc = Effects_NPC_HeavyTank_TurretHead;
			}
			else
			if(VARIANT == NPC_TURRETHEAD_HEAVYTANK_PLASMA_R)
			{
				SetObjectModel(e, "models/enemies/heavy_tank/ht_plasma_turret_R.dpm", 1);
				e.EffectFunc = Effects_NPC_HeavyTank_TurretHead;	
			}
			else
			if(VARIANT == NPC_TURRETHEAD_HEAVYTANK_MINIGUN)
			{
				SetObjectModel(e, "models/enemies/heavy_tank/ht_minigun_turret.dpm", 1);
				e.EffectFunc = Effects_NPC_HeavyTank_TurretHead;
			}
			else			
			if(VARIANT == NPC_TURRETHEAD_CARRIERTANK_REPAIR)
				SetObjectModel(e, "models/enemies/carrier_tank/carrier_turret.dpm", 1);
			else
			if(VARIANT == NPC_TURRETHEAD_DESTROYER_PLASMA_L)
			{
				e.deadmodels = -1;
				SetObjectModel(e, "models/enemies/destroyer/dt_pturret_l.dpm", 1);
				e.DeathFunc = Explode_Small;
			}
			else
			if(VARIANT == NPC_TURRETHEAD_DESTROYER_PLASMA_R)
			{
				e.deadmodels = -1;
				SetObjectModel(e, "models/enemies/destroyer/dt_pturret_r.dpm", 1);
				e.DeathFunc = Explode_Small;
			}
			else
			if(VARIANT == NPC_TURRETHEAD_DESTROYER_REPAIR)
				SetObjectModel(e, "models/enemies/destroyer/dt_rturret.dpm", 1);
			else
			if(VARIANT == NPC_TURRETHEAD_STATIONARY_PLASMA)
			{
				SetObjectModel(e, "models/enemies/turrets/turret_plasma.dpm", 1);
				e.EffectFunc = Effects_NPC_TurretHead_Plasma;	
			}
			else
			if(VARIANT == NPC_TURRETHEAD_STATIONARY_BEAM)
			{
				SetObjectModel(e, "models/enemies/turrets/turret_beam.dpm", 1);
				e.EffectFunc = Effects_NPC_TurretHead_Beam;
			}
			else
			if(VARIANT == NPC_TURRETHEAD_STATIONARY_ROCKET)
				SetObjectModel(e, "models/enemies/turrets/turret_rocket.dpm", 1);
			else
			if(VARIANT == NPC_TURRETHEAD_STATIONARY_REPAIR)
				SetObjectModel(e, "models/enemies/carrier_tank/carrier_turret.dpm", 1);
			else
			if(VARIANT == NPC_FRIENDLYLIGHTTANK)
			{
				episode = 2;
				SetObjectModel(e, "models/enemies/light_tank/light_tank.dpm", 0);
				SetObjectSize_AI(e, '-48 -48 0', '48 48 83');
				e.EffectFunc = Effects_NPC_LightTank;
				e.DeathFunc = Explode_Small;
				e.shieldscale = 1;
				e.frames_idle			= '1 12 12';
				e.frames_move			= '13 13 12';
				e.spawntime				= 0.5;	
				//e.colormod = '0.4 0.4 1';
				e.skin = 1;
			}
		break;
				
		case OBJ_ENEMYSPAWN:
			e.chullrotation = CHULLROT_ALL;
			SetObjectModel(e, "models/enemies/group_spawner/group_spawner.dpm", 1);
			SetObjectSize(e, '-160 -160 0', '160 160 256');
		break;
		
		case OBJ_PORTAL:
			episode = 2;
			e.canhaveteam = TRUE;

			if(CODEBASE == SERVERCODE)
			{
				PrecacheModelForStates(GenerateChullModelName(e, "models/enemies/portal/portal_idling_chull.bsp"), 3, 0);
				PrecacheModelForStates(GenerateChullModelName(e, "models/enemies/portal/portal_chull.bsp"), 0, 0);			
			}
			
			if(e.istoggled && !e.isdead)
			{
				chullstates = 3;
				chull = "models/enemies/portal/portal_idling_chull.bsp";
			}
			else
			{
				chullstates = 0;
				chull = "models/enemies/portal/portal_chull.bsp";
			}

			UseCollisionHull(e, "models/enemies/portal/portal.dpm", 0, chull, chullstates);
			SetObjectSize(e, '-160 -160 0', '160 160 400');
			e.DeathFunc = Explode_Large;
			e.shieldscale = 2.5;
		break;	
		
		case OBJ_CRYSTAL:
			e.flags = e.flags | FL_ITEM;
			SetObjectModel(e, "models/items/crystal.dpm", 1);
			SetObjectSize(e, '-16 -16 0', '16 16 16');
			e.skin = VARIANT;
			e.modelflags = MF_ROTATE;			
		break;			
		
		case OBJ_ARMORSHARD:
			if(GameMode_ShowPickupsOnMap(gamemode))
				SetMapObject(e);
			e.flags = e.flags | FL_ITEM;
			SetObjectModel(e, "models/items/armor_small.dpm", 1);
			SetObjectSize(e, '-16 -16 0', '16 16 16');
			e.modelflags = MF_ROTATE;
		break;
		
		case OBJ_ARMORSHELL:
			if(GameMode_ShowPickupsOnMap(gamemode))
				SetMapObject(e);
			e.flags = e.flags | FL_ITEM;
			SetObjectModel(e, "models/items/armor_big.dpm", 1);
			SetObjectSize(e, '-16 -16 0', '16 16 16');
			e.modelflags = MF_ROTATE;
		break;
		
		case OBJ_SHIELDPICKUP:
			if(GameMode_ShowPickupsOnMap(gamemode))
				SetMapObject(e);	
			e.flags = e.flags | FL_ITEM;
			SetObjectModel(e, "models/items/orb1.dpm", 1);
			SetObjectSize(e, '-16 -16 0', '16 16 16');
			SetObjectLight(e, '0.047 0.411 0.549', 160, 0, 0, "life_dlight", '0 0 0');
			e.modelflags = MF_ROTATE;
			e.skin = 1;
		break;
		
		case OBJ_EXTRALIFE:
			if(GameMode_ShowPickupsOnMap(gamemode))
				SetMapObject(e);
			e.flags = e.flags | FL_ITEM;
			SetObjectModel(e, "models/items/orb1.dpm", 1);
			SetObjectSize(e, '-16 -16 0', '16 16 16');
			SetObjectLight(e, '0.796 0.494 0.023', 160, 0, 0, "life_dlight", '0 0 0');
			e.modelflags = MF_ROTATE;
		break;
		
		case OBJ_FLAG:
			episode = 2;
		//	e.canhaveteam = TRUE;
			precache_sound("sounds/ctf/ss_ctf_enemy_flag_cap.wav");
			precache_sound("sounds/ctf/ss_ctf_enemy_score.wav");
			precache_sound("sounds/ctf/ss_ctf_player_flag_cap.wav");
			precache_sound("sounds/ctf/ss_ctf_player_score.wav");
			SetMapObject(e);
			SetObjectModel(e, "models/objects/ctf/flag_ctf.dpm", 1);
			SetObjectSize(e, '-16 -16 0', '16 16 16');		
			e.skin = VARIANT;
			e.frames_idle			= '1 30 30';
		break;
		
		case OBJ_FLAGBASE:
			episode = 2;
		//	e.canhaveteam = TRUE;
			SetMapObject(e);
			SetObjectModel(e, "models/objects/ctf/ctf_flag_base.dpm", 1);
			SetObjectSize(e, '-16 -16 0', '16 16 16');	
			e.skin = VARIANT;
		//	e.colormod = GetTeamColor(VARIANT);	
		break;		
		
		case OBJ_WEAPONPICKUP1:
			if(GameMode_ShowPickupsOnMap(gamemode))
				SetMapObject(e);
			e.flags = e.flags | FL_ITEM;
			
			if(VARIANT == WEP1_MINIGUN)			SetObjectModel(e, "models/weapons/pickup_minigun.dpm", 1);		
			else
			if(VARIANT == WEP1_STORMPLOW)		SetObjectModel(e, "models/weapons/pickup_stormplow.dpm", 1);		
			else
			if(VARIANT == WEP1_BEAMCANNON)		SetObjectModel(e, "models/weapons/pickup_beamcannon.dpm", 1);		
			else		
			if(VARIANT == WEP1_ROCKETPOD)		SetObjectModel(e, "models/weapons/rocket_pack.dpm", 1);		

			SetObjectSize(e, '-48 -48 0', '48 48 64');
			e.modelflags = MF_ROTATE;
		break;
		
		case OBJ_WEAPONPICKUP2:
			episode = 2;
			if(GameMode_ShowPickupsOnMap(gamemode))
				SetMapObject(e);
			e.flags = e.flags | FL_ITEM;
			
			if(VARIANT == WEP2_FLACKGUN)		SetObjectModel(e, "models/weapons/pickup_flak.dpm", 1);		
			else			
			if(VARIANT == WEP2_SHOCKWAVE)		SetObjectModel(e, "models/weapons/pickup_shockwave.dpm", 1);		
			else
			if(VARIANT == WEP2_STORMSPREAD)		SetObjectModel(e, "models/weapons/pickup_stormspread.dpm", 1);		
			else
			if(VARIANT == WEP2_STORMSHIELD)		SetObjectModel(e, "models/weapons/pickup_stormshield.dpm", 1);	
			else
			if(VARIANT == WEP2_THUNDERBOLT)		SetObjectModel(e, "models/weapons/pickup_thunderbolt.dpm", 1);	
			else
			if(VARIANT == WEP2_HOMINGMISSILES)	SetObjectModel(e, "models/weapons/hmissiles_pack.dpm", 1);		
			else
			if(VARIANT == WEP2_MIRVMORTAR)		SetObjectModel(e, "models/weapons/mirv_pickup.dpm", 1);		

			SetObjectSize(e, '-48 -48 0', '48 48 64');
			e.modelflags = MF_ROTATE;
		break;		
		
		case OBJ_PRESSUREPLATE:
			SetObjectModel(e, "models/objects/pressure_plate/pressure_plate.dpm", 1);
			SetObjectSize(e, '-72 -72 0', '72 72 8');
			e.skin = e.istoggled;
		break;
		
		case OBJ_FORCEFIELD:
//			SetObjectModel(e, "models/objects/force_field/force_field_emitter.dpm");
			if(VARIANT == 0)
			{
				PrecacheModel("models/objects/force_field/force_field_off_chull.bsp");
				if(e.istoggled)
					chull = "models/objects/force_field/force_field_off_chull.bsp";
				else
					chull = "models/objects/force_field/force_field_on_chull.bsp";
				UseCollisionHull(e, "models/objects/force_field/force_field_emitter.dpm", 1, chull, 1);
				SetObjectSize(e, '-64 -64 0', '64 64 512');
			}
			else
			if(VARIANT == 1)
			{
				PrecacheModel("models/objects/force_field/force_field2_off_chull.bsp");
				if(e.istoggled)
					chull = "models/objects/force_field/force_field2_off_chull.bsp";
				else
					chull = "models/objects/force_field/force_field2_on_chull.bsp";
				UseCollisionHull(e, "models/objects/force_field/force_field2_emitter.dpm", 1, chull, 1);
				SetObjectSize(e, '-64 -64 0', '64 64 512');
			}
			if(e.istoggled)
				SetMapObject(e);
			e.skin = e.istoggled;
		break;		
		
		case OBJ_EXITPAD:
			SetMapObject(e);
			UseCollisionHull(e, "models/objects/exit_pad/exit_pad.dpm", 1, "models/objects/exit_pad/exit_pad_chull.bsp", 1);				
			SetObjectSize(e, '-100 -100 0', '100 100 42');
		break;
		
		case OBJ_SPAWNPAD:
		//	e.canhaveteam = TRUE;
			e.chullrotation = CHULLROT_ROUND;
			SetMapObject(e);
			UseCollisionHull(e, "models/objects/spawn_pad/spawn_pad.dpm", 1, "models/objects/spawn_pad/spawn_pad_chull.bsp", 1);			
			SetObjectSize(e, '-200 -200 0', '200 200 42');
			e.colormod = GetTeamColor(VARIANT);
		break;
		
		case OBJ_TELEPORTER:
			UseCollisionHull(e, "models/objects/teleport/teleport.dpm", 1, "models/objects/teleport/teleport_chull.bsp", 1);
			SetObjectSize(e, '-200 -200 0', '200 200 42');
			if(e.activated || !GameMode_HideTeleporters(gamemode))
				SetMapObject(e);
		break;
		
		case OBJ_TERMINAL:
			episode = 2;	
			e.canhaveteam = TRUE;

			if(e.requireskey)
			{
				if(e.istoggled)
					e.skin = 3;
				else
					e.skin = 1;
			}
			else
			{
				if(e.istoggled)
					e.skin = 2;
				else
					e.skin = 0;
			}
			
			if(VARIANT == 0)
			{
				UseCollisionHull(e, "models/objects/terminal/terminal.dpm", 1, "models/objects/terminal/terminal_chull.bsp", 1);
				SetObjectSize(e, '-200 -200 0', '200 200 42');
			}
			else
			if(VARIANT == 1)
			{
				UseCollisionHull(e, "models/objects/terminal/terminal_small.dpm", 1, "models/objects/terminal/terminal_small_chull.bsp", 1);
				SetObjectSize(e, '-200 -200 0', '200 200 42');
			}
			e.frame = 1;
			e.frames_idle = '0 0 0';
		break;		
		
		case OBJ_DATAKEY:
			episode = 2;
			e.flags = e.flags | FL_ITEM;
			e.modelflags = MF_ROTATE;			
			SetObjectModel(e, "models/items/datakey.dpm", 1);
			SetObjectSize(e, '-16 -16 0', '16 16 16');		
			e.skin = VARIANT;
		//	e.frames_idle			= '1 30 30';		
		break;

		case OBJ_CORRUPTFUSIONCORE:
			episode = 2;	
			e.flags = e.flags | FL_ITEM;
			e.modelflags = MF_ROTATE;				
			SetObjectModel(e, "models/items/fusion_core_corrupt.bsp", 1);
			SetObjectSize(e, '-16 -16 0', '16 16 16');		
		break;
		
		case OBJ_FUSIONCORERACK:
			episode = 2;	
			e.canhaveteam = TRUE;
			e.deadmodels = -1;
			UseCollisionHull(e, "models/objects/fusion_core_rack/fusion_core_rack.bsp", 1, "models/objects/fusion_core_rack/fusion_core_rack.bsp", 1);
			SetObjectSize(e, '-256 -256 0', '256 256 164');		
			e.DeathFunc = Explode_Object;
		break;		
		
		case OBJ_STONE:
			PrecacheModel("models/objects/stones/stones_dead.dpm");
			PrecacheModel("models/objects/stones/stones_dead_gib.dpm");
			
			if(e.isdead)
			{
				VARIANT = 10;
				e.angles_y = random()*360;
			}
			
			if(VARIANT == 0)
			{
				e.gibscale = 1;
				UseCollisionHull(e, "models/objects/stones/stone1.dpm", 1, "models/objects/stones/stone1_chull.bsp", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 112');
			}
			else
			if(VARIANT == 1)
			{
				e.gibscale = 1;
				UseCollisionHull(e, "models/objects/stones/stone2.dpm", 1, "models/objects/stones/stone2_chull.bsp", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 112');
			}
			else
			if(VARIANT == 2)
			{
				e.gibscale = 1;
				UseCollisionHull(e, "models/objects/stones/stone3.dpm", 1, "models/objects/stones/stone3_chull.bsp", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 112');
			}
			else
			if(VARIANT == 3)
			{
				e.gibscale = 1.6;
				UseCollisionHull(e, "models/objects/stones/stone4.dpm", 1, "models/objects/stones/stone4_chull.bsp", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 140');
			}
			else
			if(VARIANT == 4)
			{
				e.gibscale = 2;
				UseCollisionHull(e, "models/objects/stones/stone1_b.dpm", 1, "models/objects/stones/stone1_b_chull.bsp", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 168');
			}
			else
			if(VARIANT == 5)
			{
				e.gibscale = 2;
				UseCollisionHull(e, "models/objects/stones/stone2_b.dpm", 1, "models/objects/stones/stone2_b_chull.bsp", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 168');
			}
			else
			if(VARIANT == 6)
			{
				e.gibscale = 2;
				UseCollisionHull(e, "models/objects/stones/stone3_b.dpm", 1, "models/objects/stones/stone3_b_chull.bsp", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 168');
			}
			else
			if(VARIANT == 7)
			{
				e.gibscale = 2.6;
				UseCollisionHull(e, "models/objects/stones/stone4_b.dpm", 1, "models/objects/stones/stone4_b_chull.bsp", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 210');
			}
			else
			if(VARIANT == 8)
			{
				e.gibscale = 0.6;
				UseCollisionHull(e, "models/objects/stones/stone1_s.dpm", 1, "models/objects/stones/stone1_s_chull.bsp", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 56');
			}
			else
			if(VARIANT == 9)
			{
				e.gibscale = 0.6;
				UseCollisionHull(e, "models/objects/stones/stone3_s.dpm", 1, "models/objects/stones/stone3_s_chull.bsp", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 56');
			}
			else
			if(VARIANT == 10)
			{
				e.isusingcollisionhull = FALSE;
				SetAndPrecacheModel(e, "models/objects/stones/stones_dead.dpm");
				SetObjectSize(e, '-32 -32 0', '32 32 0');
			}
			
			if(CODEBASE == CLIENTCODE)
			if(e.isdead)
			if(e.gibscale)
				e.scale = bound(0, 1 + (e.gibscale-1)*0.5, 1.4);
			
			e.DeathFunc = Explode_Object;
			e.allowrandomscale = TRUE;
		break;
		
/*		case OBJ_ROCKGROUP:	// THIS IS NOT USED!
			SetObjectModel(e, "models/objects/stones/stone_group.dpm", 1);
			if(VARIANT == 0)	SetObjectSize(e, '-72 -72 0', '72 72 128');
			else
			if(VARIANT == 1)	SetObjectSize(e, '-16 -16 0', '16 16 128');
			else
			if(VARIANT == 2)	SetObjectSize(e, '-72 -72 0', '72 72 128');		

			e.DeathFunc = Explode_Object;			
			e.skin = VARIANT;
			e.allowrandomscale = TRUE;
		break;	*/		
		
		case OBJ_ENVCRYSTAL:
			PrecacheModel("models/objects/crystals/cave_crystals_gibs.dpm");
			UseCollisionHull(e, "models/objects/crystals/cave_crystals.dpm", 0, "models/objects/crystals/cave_crystals_chull.bsp", 1);
			SetObjectSize(e, '-48 -48 0', '48 48 48');
			e.DeathFunc = Explode_Object;
			e.skin = VARIANT;
			e.allowrandomscale = TRUE;
		break;

		case OBJ_STALAGMITE:
			if (VARIANT == 0)
			{
				UseCollisionHull(e, "models/objects/stalagmites/stalagmites1.dpm", 1, "models/objects/stalagmites/stalagmites1_chull.bsp", 1);
				SetObjectSize(e, '-48 -48 0', '48 48 128');
			}
			else
			if (VARIANT == 1)
			{
				UseCollisionHull(e, "models/objects/stalagmites/stalagmites2.dpm", 1, "models/objects/stalagmites/stalagmites2_chull.bsp", 1);
				SetObjectSize(e, '-48 -48 0', '48 48 128');
			}
			e.allowrandomscale = TRUE;
		break;

		case OBJ_VOLCANO:
			e.chullrotation = CHULLROT_ROUND;
			if (VARIANT == 0)
			{
				UseCollisionHull(e, "models/objects/volcano/volcano1.dpm", 1, "models/objects/volcano/volcano1_chull.bsp", 1);
				SetObjectSize(e, '-96 -96 0', '96 96 128');
				e.skin = 0;
			}
			else
			if (VARIANT == 1)
			{
				UseCollisionHull(e, "models/objects/volcano/volcano1_medium.dpm", 1, "models/objects/volcano/volcano1_medium_chull.bsp", 1);
				SetObjectSize(e, '-48 -48 0', '48 48 64');
				e.skin = 0;
			}
			else
			if (VARIANT == 2)
			{
				UseCollisionHull(e, "models/objects/volcano/volcano1_small.dpm", 1, "models/objects/volcano/volcano1_small_chull.bsp", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 32');
				e.skin = 0;
			}
			else
			if (VARIANT == 3)
			{
				UseCollisionHull(e, "models/objects/volcano/volcano1.dpm", 1, "models/objects/volcano/volcano1_chull.bsp", 1);
				SetObjectSize(e, '-96 -96 0', '96 96 128');
				e.skin = 1;
			}
			else
			if (VARIANT == 4)
			{
				UseCollisionHull(e, "models/objects/volcano/volcano1_medium.dpm", 1, "models/objects/volcano/volcano1_medium_chull.bsp", 1);
				SetObjectSize(e, '-48 -48 0', '48 48 64');
				e.skin = 1;
			}
			else
			if (VARIANT == 5)
			{
				UseCollisionHull(e, "models/objects/volcano/volcano1_small.dpm", 1, "models/objects/volcano/volcano1_small_chull.bsp", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 32');
				e.skin = 1;
			}
			else
			if (VARIANT == 6)
			{
				UseCollisionHull(e, "models/objects/volcano/volcano1.dpm", 1, "models/objects/volcano/volcano1_chull.bsp", 1);
				SetObjectSize(e, '-96 -96 0', '96 96 128');
				e.skin = 2;
			}
			else
			if (VARIANT == 7)
			{
				UseCollisionHull(e, "models/objects/volcano/volcano1_medium.dpm", 1, "models/objects/volcano/volcano1_medium_chull.bsp", 1);
				SetObjectSize(e, '-48 -48 0', '48 48 64');
				e.skin = 2;
			}
			else
			if (VARIANT == 8)
			{
				UseCollisionHull(e, "models/objects/volcano/volcano1_small.dpm", 1, "models/objects/volcano/volcano1_small_chull.bsp", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 32');
				e.skin = 2;
			}
			else
			if (VARIANT == 9)
			{
				UseCollisionHull(e, "models/objects/volcano/volcano1.dpm", 1, "models/objects/volcano/volcano1_chull.bsp", 1);
				SetObjectSize(e, '-96 -96 0', '96 96 128');
				e.skin = 3;
			}
			else
			if (VARIANT == 10)
			{
				UseCollisionHull(e, "models/objects/volcano/volcano1_medium.dpm", 1, "models/objects/volcano/volcano1_medium_chull.bsp", 1);
				SetObjectSize(e, '-48 -48 0', '48 48 64');
				e.skin = 3;
			}
			else
			if (VARIANT == 11)
			{
				UseCollisionHull(e, "models/objects/volcano/volcano1_small.dpm", 1, "models/objects/volcano/volcano1_small_chull.bsp", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 32');
				e.skin = 3;
			}
			e.allowrandomscale = TRUE;
		break;

		case OBJ_ROADBLOCK:
			if (VARIANT == 0)
				UseCollisionHull(e, "models/objects/roadblocks/roadblock1.dpm", 1, "models/objects/roadblocks/roadblock1_chull.bsp", 1);
			else
			if (VARIANT == 1)
				UseCollisionHull(e, "models/objects/roadblocks/roadblock1_dropped.dpm", 1,  "models/objects/roadblocks/roadblock1_dropped_chull.bsp", 1);
			else
			if (VARIANT == 2)
				UseCollisionHull(e, "models/objects/roadblocks/roadblock2.dpm", 1, "models/objects/roadblocks/roadblock2_chull.bsp", 1);
			else
			if (VARIANT == 3)
				UseCollisionHull(e, "models/objects/roadblocks/roadblock2_dropped.dpm", 1, "models/objects/roadblocks/roadblock2_dropped_chull.bsp", 1);
			else
			if (VARIANT == 4)
				UseCollisionHull(e, "models/objects/roadblocks/roadblock3.dpm", 1, "models/objects/roadblocks/roadblock3_chull.bsp", 1);
			else
			if (VARIANT == 5)
				UseCollisionHull(e, "models/objects/roadblocks/roadblock4.dpm", 1, "models/objects/roadblocks/roadblock4_chull.bsp", 1);
			SetObjectSize(e, '-32 -32 0', '32 32 64');
			e.skin = VARIANT;
		break;

		case OBJ_ROCKFORMATION:
			if (VARIANT == 0)
				UseCollisionHull(e, "models/objects/rock_formations/rock_formation1.dpm", 1, "models/objects/rock_formations/rock_formation1_chull.bsp", 1);
			SetObjectSize(e, '-128 -128 0', '128 128 512');
			e.allowrandomscale = TRUE;
		break;

		case OBJ_TREE:
			PrecacheModel("models/objects/plants/palmtree_gibs.dpm");
			PrecacheModelForStates("models/objects/plants/palmtree.dpm", 2, e.deadmodels);
			
			if(e.isdead)
				UseCollisionHull(e, "models/objects/plants/palmtree.dpm", 2, "", 1);
			else
			if (VARIANT == 0)
				UseCollisionHull(e, "models/objects/plants/palmtree1_med.dpm", 1, "models/objects/plants/palmtree1_med_chull.bsp", 1);
			else
			if (VARIANT == 1)
				UseCollisionHull(e, "models/objects/plants/palmtree2_med.dpm", 1, "models/objects/plants/palmtree2_med_chull.bsp", 1);
			else
			if (VARIANT == 2)
				UseCollisionHull(e, "models/objects/plants/palmtree3_med.dpm", 1, "models/objects/plants/palmtree3_med_chull.bsp", 1);
			
			SetObjectSize(e, '-16 -16 0', '16 16 0');			
			e.DeathFunc = Explode_Object;
			e.allowrandomscale = TRUE;
		break;

		case OBJ_GRASS:
			episode = 2;	
			if (VARIANT == 0)
				SetObjectModel(e, "models/objects/plants/grass_patch1.dpm", 1);
			else
			if (VARIANT == 1)
				SetObjectModel(e, "models/objects/plants/grass_patch2.dpm", 1);
			else
			if (VARIANT == 2)
				SetObjectModel(e, "models/objects/plants/grass_patch3.dpm", 1);
			SetObjectSize(e, '-64 -64 0', '64 64 0');	
			e.allowrandomscale = TRUE;
		break;

		case OBJ_PLANT:
			e.chullrotation = CHULLROT_ALL;
		
			if(VARIANT >= 0 && VARIANT <= 3)
				e.deadmodels = -1;
		
			if(VARIANT == 0)
			{
				PrecacheModel("models/objects/plants/plant1_gibs.dpm");
				SetObjectModel(e, "models/objects/plants/plant1.dpm", 1);
			}
			else
			if(VARIANT == 1)
			{
				PrecacheModel("models/objects/plants/plant1_gibs.dpm");
				SetObjectModel(e, "models/objects/plants/plant1_noflowers.dpm", 1);
			}
			else
			if(VARIANT == 2)
			{
				PrecacheModel("models/objects/plants/plant2_gibs.dpm");
				SetObjectModel(e, "models/objects/plants/plant2.dpm", 1);
			}
			else
			if(VARIANT == 3)
			{
				PrecacheModel("models/objects/plants/plant3_gibs.dpm");
				SetObjectModel(e, "models/objects/plants/plant3.dpm", 1);
			}
			else
			if(VARIANT == 4)
			{
				PrecacheModel("models/objects/plants/cactus_gibs.dpm");
				PrecacheModelForStates("models/objects/plants/cactus_small.dpm", 2, e.deadmodels);
				if(e.isdead)
					UseCollisionHull(e, "models/objects/plants/cactus_small.dpm", 2, "", 1);
				else			
					UseCollisionHull(e, "models/objects/plants/cactus1.dpm", 1, "models/objects/plants/cactus1_chull.bsp", 1);
			}
			else
			if(VARIANT >= 5 && VARIANT <= 7)
			{
				PrecacheModel("models/objects/plants/cactus_gibs.dpm");
				PrecacheModelForStates("models/objects/plants/cactus_big.dpm", 2, e.deadmodels);
				if(e.isdead)
					UseCollisionHull(e, "models/objects/plants/cactus_big.dpm", 2, "", 1);
				else
				if(VARIANT == 5)
						UseCollisionHull(e, "models/objects/plants/cactus2.dpm", 1, "models/objects/plants/cactus2_chull.bsp", 1);
				else
				if(VARIANT == 6)
						UseCollisionHull(e, "models/objects/plants/cactus3.dpm", 1, "models/objects/plants/cactus3_chull.bsp", 1);
				else
				if(VARIANT == 7)
					UseCollisionHull(e, "models/objects/plants/cactus4.dpm", 1, "models/objects/plants/cactus4_chull.bsp", 1);
			}
			
			if(!e.isusingcollisionhull)
				e.issolidcorpse = !e.isdead;
			
			SetObjectSize(e, '-16 -16 0', '16 16 64');
			e.DeathFunc = Explode_Object;
			e.allowrandomscale = TRUE;
		break;

		case OBJ_EQUIPMENT:
			e.canhaveteam = TRUE;
			PrecacheModel("models/enemies/gibs/tank_gibs1.dpm");
			e.deadmodels = -1;
			if(VARIANT == 0)
			{
				e.chullrotation = CHULLROT_ROUND;
				UseCollisionHull(e, "models/objects/containers/barrel02.dpm", 1, "models/objects/containers/barrel02_chull.bsp", 1);
				SetObjectSize(e, '-16 -16 0', '16 16 64');
			}
			else
			if(VARIANT == 1)
			{
				e.chullrotation = CHULLROT_ROUND;
				UseCollisionHull(e, "models/objects/containers/barrel01.dpm", 1, "models/objects/containers/barrel01_chull.bsp", 1);
				SetObjectSize(e, '-16 -16 0', '16 16 64');
			}
			else
			if(VARIANT == 2)
			{
				UseCollisionHull(e, "models/objects/containers/barrel01a.dpm", 1, "models/objects/containers/barrel01a_chull.bsp", 1);
				SetObjectSize(e, '-16 -16 0', '16 16 64');
			}
			e.DeathFunc = Explode_Object;
		break;
			
		case OBJ_EQUIPMENT_BIG:
			e.canhaveteam = TRUE;
			PrecacheModel("models/enemies/gibs/tank_gibs1.dpm");
			e.deadmodels = -1;
			UseCollisionHull(e, "models/objects/containers/container01.dpm", 1, "models/objects/containers/container01_chull.bsp", 1);
			SetObjectSize(e, '-64 -64 0', '64 64 93');
			e.skin = VARIANT;
			e.DeathFunc = Explode_Object;
		break;

		case OBJ_EQUIPMENT_MED:
			e.canhaveteam = TRUE;
			PrecacheModel("models/enemies/gibs/tank_gibs1.dpm");
			e.deadmodels = -1;	
			if (VARIANT == 0)
				UseCollisionHull(e, "models/objects/containers/container02.dpm", 1, "models/objects/containers/container02_chull.bsp", 1);
			else
			if (VARIANT == 1)
				UseCollisionHull(e, "models/objects/containers/container03.dpm", 1, "models/objects/containers/container03_chull.bsp", 1);
			SetObjectSize(e, '-32 -32 0', '32 32 86');
			e.DeathFunc = Explode_Object;
		break;
		
		case OBJ_STRUCTURE:
			e.canhaveteam = TRUE;
			PrecacheModel("models/enemies/gibs/tank_gibs1.dpm");
		
			if(VARIANT == STRUCTURE_INCINERATOR)
			{
				PrecacheModel("models/objects/structures/building01.bsp");
				PrecacheModel("models/objects/structures/building01_dead1.bsp");
				PrecacheModel("models/objects/structures/building01_off.bsp");			
			
				if(e.istoggled)
					mdl = "models/objects/structures/building01_off.bsp";
				else
				if(e.isdead)
					mdl = "models/objects/structures/building01_dead1.bsp";
				else				
					mdl = "models/objects/structures/building01.bsp";
	
				UseCollisionHull(e, mdl, 3, "models/objects/structures/building01.bsp", 0);
				
				if(!e.istoggled)
				{
					SetObjectEffect(e, "EF_INCINERATOR_SMOKE", "", '72 -96 408');
					SetObjectEffect(e, "EF_INCINERATOR_SMOKE", "", '80 96 408');
				}
				
				SetObjectSize(e, '-320 -320 0', '320 320 400');
			}
			else
			if(VARIANT == STRUCTURE_BUNKER)
			{
				UseCollisionHull(e, "models/objects/structures/building02.bsp", 0, "models/objects/structures/building02.bsp", 0);
				SetObjectSize(e, '-210 -210 0', '210 210 180');
			}
			else
			if(VARIANT == STRUCTURE_HANGAR)
			{
				UseCollisionHull(e, "models/objects/structures/building03.bsp", 0, "models/objects/structures/building03.bsp", 0);
				SetObjectSize(e, '-300 -300 0', '300 300 256');
			}
			else
			if(VARIANT == STRUCTURE_BARRACKS)
			{
				UseCollisionHull(e, "models/objects/structures/building04.bsp", 0, "models/objects/structures/building04.bsp", 0);
				SetObjectSize(e, '-280 -280 0', '280 280 128');
			}
			else
			if(VARIANT == STRUCTURE_COOLINGTOWER)
			{
				UseCollisionHull(e, "models/objects/structures/cooling_tower01.bsp", 0, "models/objects/structures/cooling_tower01.bsp", 0);
				SetObjectSize(e, '-280 -280 0', '280 280 256');
			}
			else
			if(VARIANT == STRUCTURE_COOLINGTOWER_TWIN)
			{
				UseCollisionHull(e, "models/objects/structures/cooling_tower02.bsp", 0, "models/objects/structures/cooling_tower02.bsp", 0);
				SetObjectSize(e, '-280 -280 0', '280 280 256');				
			}
			else
			if(VARIANT == STRUCTURE_OBELISK)
			{	
				e.canhaveteam = FALSE;			
				e.deadmodels = -1;
				SetMapObject(e);
				UseCollisionHull(e, "models/objects/obelisk/obelisk01.dpm", 1, "models/objects/obelisk/obelisk01_chull.bsp", 1);
				SetObjectSize(e, '-150 -150 0', '150 150 186');
			}
			else
			if(VARIANT == STRUCTURE_PYLON)
			{
				episode = 2;	

				if(CODEBASE == SERVERCODE)
				{
					PrecacheModelForStates(GenerateChullModelName(e, "models/objects/pylon/pylon01_chull.bsp"), 3, 0);
					PrecacheModelForStates(GenerateChullModelName(e, "models/objects/pylon/pylon01_shield_chull.bsp"), 3, 0);	
				}
				
				if(e.istoggled || e.isdead)
				{
					chull = "models/objects/pylon/pylon01_chull.bsp";
					if(e.isdead)
						e_skin = 2;
					else
						e_skin = 1;
				}
				else
				{
					chull = "models/objects/pylon/pylon01_shield_chull.bsp";
					e_skin = 0;				
				}
				
				UseCollisionHull(e, "models/objects/pylon/pylon01.dpm", 3, chull, 3);
				SetObjectSize(e, '-256 -256 0', '256 256 256');
			}
			else
			if(VARIANT == STRUCTURE_GASPUMP)
			{	
				e.canhaveteam = FALSE;			
				episode = 2;	

				UseCollisionHull(e, "models/objects/big_pump/big_pump.dpm", 0, "models/objects/big_pump/big_pump_chull.bsp", 0);
				SetObjectSize(e, '-150 -150 0', '150 150 186');
				
				if(e.istoggled)
				{
					e.frames_idle_x = e.frames_idle_y = e.frame;
					e.frames_idle_z = 1;				
					e_skin = 0;
				}
				else
				{
					e.frames_idle = '1 60 30';
					e_skin = 1;
				}
			}
			else
			if(VARIANT == STRUCTURE_REFINERY)
			{
				episode = 2;	

				PrecacheModel("models/objects/refinery/refinery.bsp");
				PrecacheModel("models/objects/refinery/refinery_operating.bsp");
				PrecacheModel("models/objects/refinery/refinery_dead1.bsp");

				if(e.isdead)
					mdl = "models/objects/refinery/refinery_dead1.bsp";
				else
				if(e.istoggled)
					mdl = "models/objects/refinery/refinery.bsp";
				else
					mdl = "models/objects/refinery/refinery_operating.bsp";
				
				UseCollisionHull(e, mdl, 3, "models/objects/refinery/refinery_chull.bsp", 0);
				SetObjectSize(e, '-256 -256 0', '256 256 256');
				
				if(!e.istoggled)
				{
					SetObjectEffect(e, "EF_INCINERATOR_SMOKE", "", '-288 -344 496');
					SetObjectEffect(e, "EF_INCINERATOR_SMOKE", "", '-288 -696 496');
					SetObjectEffect(e, "EF_INCINERATOR_SMOKE", "", '224 -344 496');
					SetObjectEffect(e, "EF_INCINERATOR_SMOKE", "", '400 -520 496');
					SetObjectEffect(e, "EF_REFINERY_PURPLESTEAM", "", '-288 416 336');
				}				
			}			
			else
			if(VARIANT == STRUCTURE_EVAPORATOR)
			{
				episode = 2;			

				PrecacheModel("models/objects/evaporator/evaporator.bsp");
				PrecacheModel("models/objects/evaporator/evaporator_operating.bsp");
			
				if(e.istoggled)
					mdl = "models/objects/evaporator/evaporator.bsp";
				else
					mdl = "models/objects/evaporator/evaporator_operating.bsp";
				
				UseCollisionHull(e, mdl, 3, "models/objects/evaporator/evaporator_chull.bsp", 3);
				SetObjectSize(e, '-256 -256 0', '256 256 256');
				
				if(!e.istoggled)
				{
					SetObjectEffect(e, "EF_INCINERATOR_SMOKE", "", '916 -108 660');
					SetObjectEffect(e, "EF_INCINERATOR_SMOKE", "", '916 108 660');
					SetObjectEffect(e, "EF_EVAPORATOR_DRILL", "", '0 0 392');
					SetObjectEffect(e, "EF_EVAPORATOR_PIPESSTEAM", "", '304 -384 48');
					SetObjectEffect(e, "EF_EVAPORATOR_GREENSMOKE", "", '1024 0 200');
				}
			}		
			else
			if(VARIANT == STRUCTURE_BBOSS)
			{
				episode = 2;
				UseCollisionHull(e, "models/objects/bboss/bboss.bsp", 0, "models/objects/bboss/bboss.bsp", 0);
				SetObjectSize(e, '-150 -150 0', '150 150 186');				
			}
			else
			if(VARIANT == STRUCTURE_BBOSS_SMALL)
			{
				episode = 2;
				UseCollisionHull(e, "models/objects/bboss/bboss_small.bsp", 0, "models/objects/bboss/bboss_small.bsp", 0);
				SetObjectSize(e, '-150 -150 0', '150 150 186');				
			}			
			
			e.skin = e_skin;			
			e.DeathFunc = Explode_Large;	
		break;
		
		case OBJ_VEHICLE:
			if(VARIANT == 0)
			{
				SetObjectModel(e, "models/enemies/light_tank/light_tank_dead1.dpm", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 0');
			}
			else
			if(VARIANT == 1)
			{
				SetObjectModel(e, "models/enemies/medium_tank/medium_tank_dead1.dpm", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 0');
			}		
			else
			if(VARIANT == 2)
			{
				episode = 2;	
				SetObjectModel(e, "models/enemies/lightning_tank/lightning_tank_dead1.dpm", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 0');
			}	
			else
			if(VARIANT == 3)
			{
				SetObjectModel(e, "models/enemies/heavy_tank/heavy_tank_dead1.dpm", 1);
				SetObjectSize(e, '-48 -48 0', '48 48 0');
			}
			else
			if(VARIANT == 4)
			{
				episode = 2;	
			//	UseCollisionHull(e, "models/enemies/carrier_tank/carrier_tank_dead1.dpm", 1, "models/enemies/carrier_tank/carrier_tank_chull_dead1.dpm", 1);
				SetObjectModel(e, "models/enemies/carrier_tank/carrier_tank_dead1.dpm", 1);
				SetObjectSize(e, '-128 -128 0', '128 128 128');
			//	e.solid = SOLID_BBOX;
			}
			else
			if(VARIANT == 5)
			{
				episode = 2;	
			//	UseCollisionHull(e, "models/enemies/destroyer/destroyer_tank_dead1.dpm", 1, "models/enemies/destroyer/destroyer_tank_chull_dead1.dpm", 1);
				SetObjectModel(e, "models/enemies/destroyer/destroyer_tank_dead1.dpm", 1);
				SetObjectSize(e, '-128 -128 0', '128 128 128');
			//	e.solid = SOLID_BBOX;
			}
			else
			if(VARIANT == 6)
			{
				SetObjectModel(e, "models/enemies/turrets/turret_plasma_dead1.dpm", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 0');
			}
			else
			if(VARIANT == 7)
			{
				SetObjectModel(e, "models/enemies/turrets/turret_rocket_dead1.dpm", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 0');
			}			
			else
			if(VARIANT == 8)
			{
				SetObjectModel(e, "models/enemies/turrets/turret_beam_dead1.dpm", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 0');
			}
			else
			if(VARIANT == 9)
			{
				SetObjectModel(e, "models/enemies/turrets/turret_repair_dead1.dpm", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 0');
			}
			else
			if(VARIANT == 10)
			{
				SetObjectModel(e, "models/player/player_dead1.dpm", 1);
				SetObjectSize(e, '-32 -32 0', '32 32 0');
			}
		break;			
		
		case OBJ_PARTICLEEMITTER:
			e.chullrotation = CHULLROT_ALL;
			SetObjectModel(e, "models/editor/pemitter.dpm", 1);	
			SetObjectSize(e, '-16 -16 0', '16 16 16');
		break;

		case OBJ_AMBIENTSOUND:
			SetObjectModel(e, "models/editor/ambient_sound.dpm", 1);	
			SetObjectSize(e, '-16 -16 0', '16 16 16');
			e.modelflags = MF_ROTATE;
		break;
		
		case OBJ_TRIGGERRELAY:
			SetObjectModel(e, "models/editor/trigger_box.dpm", 1);	
			SetObjectSize(e, '-64 -64 0', '64 64 128');
			e.skin = e.touchtrigger;
	//		e.modelflags = MF_ROTATE;	
		break;
		
		default:	SetObjectModel(e, "models/blank.mdl", 1);		break;
	}
	
	LOADINGFROMEPISODE = episode;
}

void SetPortalMaxValues() =
{
	self.spawner_max_areaents = 12;
	self.spawner_max_ents = 4;
	self.spawner_max_lighttanks = 3;
	self.spawner_max_mediumtanks = 3;
	self.spawner_max_lightningtanks = 3;
	self.spawner_max_heavytanks = 1;
}

void SetEnemySpawnerMaxValues() =
{
	self.spawner_max_ents = 3;
	self.spawner_max_lighttanks = 2;
	self.spawner_max_mediumtanks = 2;
	self.spawner_max_lightningtanks = 0;
	self.spawner_max_heavytanks = 0;
}

void SetTerminalDefaultValues() =
{
	self.object_activationtime = 5;
}