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
void SetDynamicLight(entity e, vector rgb, float rad, float lstyle, float shadows, float duration) =
{	
	e.color = rgb;
	e.light_lev = rad;
	e.style = lstyle;
	if(duration)
	{
		e.light_duration = duration;
		e.light_life_endtime = time+duration;
	}
	
	e.pflags = PFLAGS_FULLDYNAMIC;
	if(!shadows)
		e.pflags = e.pflags | PFLAGS_NOSHADOW;
		
	DLightChain_Add(e);		
}

void SetObjectLight_Client(entity e, vector rgb, float rad, float lstyle, float shadows, string tag, vector ofs) =
{
	if(e.isdead)
		return;		
		
	local entity light;
	local float index;
	
	if(tag != "")
		index = gettagindex(e, tag);
	
	for(light = e.list_tagentchain; light; light = light.tagentchain)
	{
		if(light.class == CLASS_DLIGHT)
		if(light.tag_index == index && light.origin == ofs)
			return;
	}
	
	light = spawn();
	light.class = CLASS_DLIGHT;
	
	SetDynamicLight(light, rgb, rad, lstyle, shadows, 0);
	
	Attach(light, e, index);
	setorigin(light, light.origin + ofs);
}

float GetIndexForEffect_SMOKE(entity e) =
{
	local float pindex;

	if(self.maxs_x <= 64)
		pindex = PEF_ENTITY_DAMAGE_SMOKE;
	else	
	if(self.maxs_z <= 128)
		pindex = PEF_ENTITY_DAMAGE_SMOKE_MED;
	else
		pindex = PEF_ENTITY_DAMAGE_SMOKE_LARGE;

	return pindex;
}

float GetIndexForEffect_BURN(entity e) =
{
	local float pindex;

	if(self.maxs_x <= 64)
		pindex = PEF_ENTITY_DAMAGE_BURN;
	else	
	if(self.maxs_z <= 128)
		pindex = PEF_ENTITY_DAMAGE_BURN_MED;
	else
		pindex = PEF_ENTITY_DAMAGE_BURN_LARGE;

	return pindex;
}

float GetIndexForEffect(entity e, float fx) =
{
	local float pindex;

	switch(fx)
	{
		case EFF_STUN:			pindex = PEF_ENTITY_EFFECT_STUN;			break;
		case EFF_WEPDISABLE:	pindex = PEF_ENTITY_EFFECT_WEPDISABLE;		break;
		case EFF_SMOKE:			pindex = GetIndexForEffect_SMOKE(e);		break;
		case EFF_BURN:			pindex = GetIndexForEffect_BURN(e);			break;
//		case EFF_BUTTONCHAT:	pindex = PEF_PLAYER_BUTTONCHAT;				break;
	}

	return pindex;
}

void DrawEffects(entity e, vector camera_ofs, float particledrawrange) =
{
	local vector diff, ang, org, st_org, loc;
	local float fx, pindex;

	ang = e.angles;
	makevectors(ang);
	ang = '-90 0 0';
	org = e.origin;
	
	st_org = org;
	st_org_z += e.mins_z + (e.maxs_z - e.mins_z)*0.5;
	st_org += v_forward*-1*e.maxs_x*0.5;		
	
	camera_ofs_z = org_z;
	
	diff = st_org-camera_ofs;
	if(diff*diff <= particledrawrange*particledrawrange)
	{
		makevectors(ang);
		
		for(fx = 1; fx <= 8; fx = fx*2)
		{
			if(e.effectflags & fx)
			{
				pindex = GetIndexForEffect(e, fx);

			//	if(fx == EFF_BUTTONCHAT)
			//		loc = org;
			//	else
					loc = st_org;

				if(pindex)
					pointparticles(pindex, loc, v_forward, 1);
			}
		}
	}
}

void DrawParticleEmitters(vector camera_ofs) =
{
	local vector ang, org, ofs_ang, diff;
	local float pindex;

	float particledrawrange = 1600;
	
	local entity e;
	for(e = list_particleemitterchain; e; e = e.particleemitterchain)
	{
		if(e.class == CLASS_OBJECT && e.objclass == OBJ_PARTICLEEMITTER) // particle emitter
		{
			if(e.controlent)
			{
				ang = e.controlent.angles;
				org = e.controlent.origin;
				pindex = e.controlent.particleindex;
			}
			else
			{
				ang = e.angles;
				org = e.origin;
				pindex = e.particleindex;
			}
			
			ang_x = ang_x*-1;
		}
		else
		if(e.tag_entity) // object particle effects
		{
			if(adminmode)
			if(e.tag_entity.class == CLASS_OBJECT)
			if(e.tag_entity != marker)
				continue;
				
			org = gettaginfo(e.tag_entity, e.tag_index);
			if(e.origin != '0 0 0')
			{
				ang = vectoangles(e.origin);
				ang_x = ang_x*-1;
				ang_y += e.tag_entity.angles_y;
				ang_x += e.tag_entity.angles_x;
				ang_z += e.tag_entity.angles_z;
				makevectors(ang);
				org += v_forward*vlen(e.origin);		
			}
			
			ang = '-90 0 0';
			pindex = e.particleindex;
		}	
		else
		{ // structural damage effects
			if(adminmode)
				continue;
		
			ang = e.angles;
			makevectors(ang);
			ang = '-90 0 0';
			org = e.origin;
			org_z += e.mins_z + (e.maxs_z - e.mins_z)*0.5;
			org += v_forward*-1*e.maxs_x*0.5;			
			pindex = e.particleindex;
			DrawEffects(e, camera_ofs, particledrawrange);
		}
	
		if(pindex)
		{
			camera_ofs_z = org_z;
		
			diff = org-camera_ofs;
			if(diff*diff <= particledrawrange*particledrawrange)
			{
				makevectors(ang);
				pointparticles(pindex, org + '0 0 4', v_forward, 1);
			}
		}
	}
}

void SilenceObjectSounds(entity e, float childrenonly) =
{
	local entity nexte;

	if(!childrenonly)
	{
		e.think = SUB_Null;
		e.nextthink = 0;
		
		sound(e, CHAN_BODY, "sounds/null.wav", 1, ATTN_NORM);
		sound(e, CHAN_VOICE, "sounds/null.wav", 1, ATTN_NORM);
	}
			
	e = e.list_childchain;
	while(e)
	{
		nexte = e.childchain;
	
		if(e.class == CLASS_SOUND)
		{
			SilenceObjectSounds(e, false);
			SH_RemoveEnt(e);
		}
	
		e = nexte;
	}
}

void RemoveAttachedEffects(entity e) =
{
	local entity emitter, nexte;

	emitter = e.list_tagentchain;
	while(emitter)
	{
		nexte = emitter.tagentchain;

		if(emitter.objclass == OBJ_PARTICLEEMITTER)
			SH_RemoveEnt(emitter);

		emitter = nexte;
	}
}

void RemoveObjectEffects(entity e) =
{
	local entity emitter, nexte;

	RemoveAttachedEffects(e);
	RemoveAttachedEffects(e.controlent);
}

void RemoveExplosion() =
{
/*	if(!self.alpha)
		self.alpha = 1;

	self.alpha -= frametime/0.2;
	
	if(self.alpha < 0.001)
	{*/
		SH_RemoveEnt(self);
/*		return;
	}
	
	self.nextthink = time;*/
}

entity ExplosionEffect(vector org, string modelname, float skinnum, float scaleval, float lifetime) =
{
	local entity e;
	e = spawn();
	
	e.drawmask = MASK_NORMAL;
	SetAndPrecacheModel(e, modelname);
	setorigin(e, org);
	e.skin = skinnum;
//	e.angles_y = (random()*360)-180;
	e.scale = scaleval;
	
	e.nextthink = time + lifetime;//max(0, lifetime-0.2);
	e.think = RemoveExplosion;	
	
	return e;
}

void SpawnExplosionEffects(vector vec, float dlight) =
{
	local entity e;

	e = ExplosionEffect(vec, "models/sfx/explosion1.dpm", 0, 3, 60/30);
	if(dlight)
	{
		SetDynamicLight(e, '0.93 0.53 0', 600, 0, FALSE, 60/30);
		e.light_ofs = '0 0 32';
	}
	pointparticles(particleeffectnum("EF_EXPLOSION_SPARKS1"), vec, '0 0 0', 1);
}

void SpawnPlasmaHit(vector vec, float type, float e_scale) =
{
	local entity e;
	local float rad;
	local vector rgb;
	
	e = spawn();
	
	e.drawmask = MASK_NORMAL;
	e.predraw = InterpolateAnimation;
	e.frames_idle = '0 15 20';
	e.AnimFunc = e.Anim_Default = anim_basic;
	
	if(!type)
	{
		SetAndPrecacheModel(e, "sprites/spread_explosion.spr32");
		rgb = '0 0.4 1';
		rad = 200;
	}
	else
	if(type == 1)
	{
		SetAndPrecacheModel(e, "sprites/plasma_explosion.spr32");
		rgb = '1 0.5 0';
		rad = 200;		
	}
	else
	if(type == 2)
	{
		SetAndPrecacheModel(e, "sprites/plasma_explosion.spr32");
		e.colormod = '0.5 0 1';
		rgb = '1 0 1';
		rad = 200;		
	}
		
	SetDynamicLight(e, rgb, rad, 0, FALSE, 0.2);
		
	setorigin(e, vec);
	e.angles_z = (random()*360)-180;
	e.scale = e_scale;
}

/*void SpawnPlasmaHitBurn(vector vec, float e_skin) =
{
	local entity e;
	e = spawn();

	e.drawmask = MASK_NORMAL;
	e.predraw = InterpolateAnimation;
	e.frames_idle = '0 1 12';
	e.AnimFunc = e.Anim_Default = anim_basic;
	SetAndPrecacheModel(e, "sprites/spread_impact.spr32");
	e.skin = e_skin;
	setorigin(e, vec);
	e.angles = self.angles;
	e.angles_y -= 180;
}*/

void SpawnRocketHit(vector vec) =
{
	SpawnExplosionEffects(vec, true);	
	
	local float r;
	local string soundname;
	r = max(1, ceil(random()*5));
	soundname = strcat("sounds/weapons/rockets/ss_ship_rocketpod_explosion", ftos(r));
	soundname = strcat(soundname, ".wav");
	pointsound(vec, soundname, 1, ATTN_NORM);	
}

void SpawnMissileHit(vector vec) =
{
	SpawnExplosionEffects(vec, true);	
	pointsound(vec, "sounds/weapons/rockets/ss_ship_homingmissile_explosion.wav", 1, ATTN_NORM);	
}

void SpawnMIRVHit(vector vec) =
{
	SpawnExplosionEffects(vec, true);		
	pointsound(vec, "sounds/weapons/rockets/ss_ship_MIRV_explosions.wav", 1, ATTN_NORM);	
}

/*void SpawnSpark(vector vec, vector ang) =
{
	local entity e;
	e = spawn();

	e.drawmask = MASK_NORMAL;
	e.predraw = InterpolateAnimation;
	e.frames_idle = '0 1 8';
	e.AnimFunc = e.Anim_Default = anim_basic;
	SetAndPrecacheModel(e, "models/weapons/minigun_sparks.dpm");
	setorigin(e, vec);
	e.angles = ang;
	e.angles_z = (random()*360)-180;	
}*/

void SplatterSound(entity e, string soundname) =
{
	if(global_splattersoundtime <= time)
		pointsound(e.origin, soundname, bound(0, vlen(self.velocity)/500, 1), ATTN_NORM);
	
	global_splattersoundtime = time+0.05;		
}

void GibTrail(entity e, string effectname) =
{
	trailparticles(e, particleeffectnum(effectname), e.origin, e.lastgibtrailorg);
	e.lastgibtrailorg = e.origin;	
}

void RemoveGib() =
{
	self.alpha -= (1/3)*frametime;
	
	if(self.alpha <= 0)
		SH_RemoveEnt(self);
	else
		self.nextthink = time+frametime;
}

void SpawnGibs(entity e, string tagname, vector offset, string gibmodel, float gibskin, float numgibs, float spawnspread, float minscale, float maxscale, float minpitch, float maxpitch, float minvel, float maxvel, float minspin, float maxspin, float lifetime, float t_density, void() t_trailfunc, void() t_splatterfunc) =
{
	if(!cvar("cl_gibs"))
		return;
	
	local float count, gscale, spin;
	local vector org, ang;
	local entity gib;

	if(strlen(tagname))
		org = gettaginfo(e, gettagindex(e, tagname));
	else
	if(e.tag_entity)
		org = gettaginfo(e.tag_entity, e.tag_index);
	else
		org = e.origin;
			
	if(offset != '0 0 0')
	{
		ang = vectoangles(offset);
		ang_x = ang_x*-1;
		ang_y += e.angles_y;
		ang_x += e.angles_x;
		ang_z += e.angles_z;
		makevectors(ang);
		org += v_forward*vlen(offset);		
	}
	else
	if(!strlen(tagname))
		org_z += (e.maxs_z+e.mins_z)*0.5;
	
	for(count = 0; count < numgibs; count++)
	{
		gscale = minscale + (maxscale - minscale)/numgibs*count;
		
		gib = spawn();
		SetAndPrecacheModel(gib, gibmodel);	
		gib.skin = gibskin;
		gib.movetype = MOVETYPE_BOUNCE;
		gib.solid = SOLID_SLIDEBOX;
		gib.scale = gscale;
		gib.density = t_density;
		gib.trailfunc = t_trailfunc;
		gib.splatterfunc = t_splatterfunc;
		gib.alpha = 1;
		
		gib.drawmask = MASK_NORMAL;
		
		ang = '0 0 0';
		ang_y = count*(360/numgibs) + random()*(360/numgibs);
		
		makevectors(ang);
		setorigin(gib, org+v_forward*spawnspread);	
		gib.lastgibtrailorg = gib.origin;
		
		ang_x = minpitch + random()*(maxpitch-minpitch);
		spin = minspin+(random()*(maxspin-minspin));
		
		makevectors(ang);
		gib.velocity = v_forward*(minvel+random()*(maxvel-minvel));
		gib.avelocity = randomvec()*spin;
		
		gib.think = RemoveGib;
		gib.nextthink = time+5;
		
		MobileEntChain_Add(gib);
		HasAvelocityChain_Add(gib);
	}
}

void SpawnPlantDust() =
{
	local vector vec;
	vec = self.origin;
	vec_z += self.maxs_z+8;

	pointparticles(particleeffectnum("EF_PLANT_DUST"), vec, '0 0 0', 1);	
	pointsound(vec, "sounds/debris/ss_plant_softsurface.wav", 1, ATTN_NORM);
}

void SpawnTreeDust() =
{
	local vector vec;
	vec = self.origin;
	vec_z += self.maxs_z+8;

//	ExplosionEffect(vec, "models/sfx/explosion1.dpm", 1, 3, 60/30);	
	pointparticles(particleeffectnum("EF_TREE_DUST"), vec, '0 0 0', 1);	
	pointsound(vec, "sounds/debris/ss_tree_softsurface.wav", 1, ATTN_NORM);
}

void SpawnCactusSlime() =
{
	local vector vec;
	vec = self.origin;
	vec_z += self.maxs_z+8;

//	ExplosionEffect(vec, "models/sfx/explosion1.dpm", 1, 3, 60/30);	
	pointparticles(particleeffectnum("EF_CACTI_SLIME"), vec, '0 0 0', 1);	
	pointsound(vec, "sounds/debris/ss_debris_cactus.wav", 1, ATTN_NORM);
}

void SpawnDustCloud() =
{
	local vector vec;
	vec = self.origin;
	vec_z += (self.maxs_z+self.mins_z)*0.5;

//	ExplosionEffect(vec, "models/sfx/explosion1.dpm", 1, 3, 60/30);	
	pointparticles(particleeffectnum("EF_ROCK_DUST"), vec, '0 0 0', 1);	
	pointsound(vec, "sounds/debris/ss_rock_softsurface.wav", 1, ATTN_NORM);
}

void SpawnCrystalDustCloud() =
{
	local vector vec;
	vec = self.origin;
	vec_z += self.maxs_z+8;

	ExplosionEffect(vec, "models/sfx/explosion1.dpm", 1, 3, 60/30);	
	pointparticles(particleeffectnum("EF_CRYSTAL_DUST"), vec, '0 0 0', 1);	
	pointsound(vec, "sounds/debris/ss_crystal_softsurface.wav", 1, ATTN_NORM);
}

void SpawnExplosion(vector vec, float dlights) =
{
	SpawnExplosionEffects(vec, dlights);
	pointsound(vec, "sounds/weapons/explosions/ss_explosion2.wav", 1, ATTN_NORM);	
}

void SpawnEquipmentFireballCloud_Effects(float dlights) =	
{	
	local vector vec;
	vec = self.origin;
	vec_z += (self.maxs_z+self.mins_z)*0.5;

	SpawnExplosion(vec, dlights);	
	pointsound(vec, "sounds/debris/ss_metal_softsurface.wav", 1, ATTN_NORM);	
}

void SpawnEquipmentFireballCloud() =	{	SpawnEquipmentFireballCloud_Effects(true);		}

void SpawnEquipmentFireballCloud_NoLight() =	{	SpawnEquipmentFireballCloud_Effects(false);		}

void ExecuteDelayedExplosion() =
{
	self.DeathFunc();
	SH_RemoveEnt(self);
}

void SpawnCameraShaker(vector org, float dur) =
{
	local entity e;
	e = spawn();
	setorigin(e, org);
	
	e.camerashake_x = CAMFL_SHAKE;
	e.camerashake_y = time + dur;
	e.camerashake_z = time;
	e.shakecamera = true;
	CameraShakeChain_Add(e);		
	
	e.nextthink = time+dur;
	e.think = SUB_Remove;
}

void SpawnDelayedExplosion(vector vec, float delaytime, void() ExplosionType) =
{
	local entity e;
	e = spawn();
	setorigin(e, vec);
	e.DeathFunc = ExplosionType;
	e.nextthink = time+delaytime;
	e.think = ExecuteDelayedExplosion;
}

void EndExplosion(entity e) =
{
	RemoveTagEnts(e);
	if(self.objclass != OBJ_NPC)
		SetObjectAppearance(e, e.objclass, e.variant);	
	RadarEntChain_Remove(e);
	HittableChain_Remove(e);
}

void UpdateDeadObjectAppearance() =
{
	EndExplosion(self);
	self.think = SUB_Null;
	self.nextthink = 0;
}

void LongExplosion(float shaketime, float explodesize, float explosionspertick, float explosionnum, void() ThinkFunc) =
{
	local vector vec;
	
	explosionnum = explosionnum + 1;
	
	if(!self.owner.isdead)
	{
		SH_RemoveEnt(self);
		return;
	}

	if(self.owner.tag_entity)
	{
		vec = gettaginfo(self.owner.tag_entity, self.owner.tag_index);
		setorigin(self, vec);
	}
	else
	if(self.owner.origin != '0 0 0')
		setorigin(self, self.owner.origin);
		
	vec = self.origin+randomvec()*random()*explodesize;
	vec_z = bound(vec_z + self.owner.maxs_z + 8, vec_z, self.owner.origin_z + explodesize);//= max(vec_z, self.owner.origin_z + self.owner.maxs_z + 8);
	SpawnExplosion(vec, true);
	
	self.camerashake_x = CAMFL_SHAKE;
	self.camerashake_y = time + shaketime;
	self.camerashake_z = time;
	self.shakecamera = true;
//	UpdateCameraShakeChain();	
	CameraShakeChain_Add(self);
	
	if(!self.explodeuntiltime)
	{
		EndExplosion(self.owner);
		
		self.camerashake_y = time + bound(0, shaketime*(explodesize/75), 1.5);		
		self.nextthink = self.camerashake_y;
		self.think = SUB_Remove;
		return;
	}

	if(self.explodeuntiltime < time)
	{
		if(self.explodeuntiltime > 0)
			self.explodeuntiltime = bound(1, floor(explodesize/75), 10)*-1;
		else
			self.explodeuntiltime++;
			
		LongExplosion(shaketime, explodesize, 1, 0, ThinkFunc);	
		return;
	}
	
	if(explosionnum < explosionspertick)
	{
		LongExplosion(shaketime, explodesize, explosionspertick, explosionnum, ThinkFunc);	
		return;
	}
	
	self.nextthink = time + 0.2;
	self.think = ThinkFunc;	
}

void InitExplosion(float dur, void() ThinkFunc) =
{
	local entity e;
	
//	self.colormod = '0.4 0.4 0.4';
	
//	self.isdead = true;
	if(self.objclass == OBJ_NPC)
		SetObjectAppearance(self, self.objclass, self.variant);
	
	e = spawn();
	SetOwner(e, self);//e.owner = self;
	SetParent(e, self);
	e.explodeuntiltime = time + dur;
	Func_oself(e, ThinkFunc);
}

void Explode_Huge_Think() =		{	LongExplosion(2.8, 650, 3, 0, Explode_Huge_Think);	}
void Explode_Large_Think() =	{	LongExplosion(1.8, 350, 1, 0, Explode_Large_Think);	}
void Explode_Small_Think() =	{	LongExplosion(0.5, 100, 1, 0, Explode_Small_Think);	}
void Explode_Tiny_Think() =		{	LongExplosion(0.3, 50, 1, 0, Explode_Tiny_Think);	}

void Splatter_Oil_Intense() = 
{		
	pointparticles(particleeffectnum("EF_OIL_SPLATTER_INTENSE"), self.origin, '0 0 0', 1);	
	SplatterSound(self, "sounds/debris/ss_metal_gib.wav");
}

void Splatter_Oil_Weak() = 
{		
	pointparticles(particleeffectnum("EF_OIL_SPLATTER_WEAK"), self.origin, '0 0 0', 1);	
//	SplatterSound(self, "sounds/debris/ss_metal_gib.wav");
}

void Splatter_Cactus() = 
{		
	pointparticles(particleeffectnum("EF_CACTUS_SPLATTER"), self.origin, '0 0 0', 1);	
	SplatterSound(self, "sounds/debris/ss_debris_cactus.wav");
}

void Trail_Oil() =	{	GibTrail(self, "EF_SMOKE_TRAIL");		}

void Trail_Oil_Thin() =	{	GibTrail(self, "EF_SMOKE_TRAIL_THIN");		}

void Trail_Smoke_Container() =	{	GibTrail(self, "EF_SMOKE_TRAIL_CONTAINER");		}

void Explode_Barrel() =
{
	SpawnEquipmentFireballCloud();
}

/*void Explode_Container() =
{
	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 0, 3, 16, 0.9, 1.2, -55, -78, 450, 650, 350, 850, 20, 1, Trail_Smoke_Container, Splatter_Oil_Intense);
	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 2, 5, 10, 0.6, 1, -75, -80, 400, 600, 350, 850, 20, 1, Trail_Oil_Thin, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 3, 10, 12, 0.6, 1.5, -70, -80, 450, 550, 350, 850, 20, 1, Trail_Oil_Thin, Splatter_Oil_Weak);
}*/

void Explode_MedContainer() =
{
	local vector vec;

	SpawnEquipmentFireballCloud();
	
	vec = self.origin;
	vec_z += (self.maxs_z+self.mins_z)*0.5;
	SpawnExplosion(vec, true);		
	
	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 0, 3, 66, 1.2, 1.7, -55, -78, 450, 650, 350, 850, 20, 1, Trail_Smoke_Container, Splatter_Oil_Intense);
	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 2, 5, 50, 1, 1.5, -75, -80, 400, 600, 350, 850, 20, 1, Trail_Oil_Thin, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 3, 10, 52, 1, 1.7, -70, -80, 450, 550, 350, 850, 20, 1, Trail_Oil_Thin, Splatter_Oil_Weak);
}

void PartialExplosion_BigContainer(vector org, vector offset, float delay) =
{
	SpawnDelayedExplosion(org, delay, SpawnEquipmentFireballCloud_NoLight);
	org_z = self.origin_z;
	org_z += (self.maxs_z+self.mins_z)*0.5;
	SpawnExplosion(org, true);

	offset_z = self.maxs_z+8;
	
	SpawnGibs(self, "", offset, "models/enemies/gibs/tank_gibs1.dpm", 0, 1, 66, 1.5, 2, -55, -78, 450, 650, 350, 850, 20, 1, Trail_Smoke_Container, Splatter_Oil_Intense);
	SpawnGibs(self, "", offset, "models/enemies/gibs/tank_gibs1.dpm", 2, 2, 50, 1.2, 2.3, -75, -80, 400, 600, 350, 850, 20, 1, Trail_Oil_Thin, SUB_Null);
	SpawnGibs(self, "", offset, "models/enemies/gibs/tank_gibs1.dpm", 3, 3, 52, 1.2, 2.5, -70, -80, 450, 550, 350, 850, 20, 1, Trail_Oil_Thin, Splatter_Oil_Weak);
}

void Explode_BigContainer() =
{
	local vector org, forwardvec;

	makevectors(self.angles);
	forwardvec = v_forward;
	org = self.origin;
	org_z += self.maxs_z;

	PartialExplosion_BigContainer(org, '0 0 0', random()*0.1);
	PartialExplosion_BigContainer(org+forwardvec*80, '80 0 0', random()*0.3);
	PartialExplosion_BigContainer(org+forwardvec*-80, '-80 0 0', random()*0.3);
}

void Explode_Player() =
{
	SpawnGibs(self, "", '0 0 0', "models/player/player_gibs1.dpm", 0, 2, 16, 1, 1, -55, -75, 450, 650, 350, 850, 20, 1, Trail_Oil, Splatter_Oil_Intense);
	SpawnGibs(self, "", '0 0 0', "models/player/player_gibs1.dpm", 1, 2, 12, 1, 1, -75, -90, 450, 550, 350, 850, 20, 1, Trail_Oil, Splatter_Oil_Weak);
	SpawnGibs(self, "", '0 0 0', "models/player/player_gibs1.dpm", 2, 5, 8, 0.7, 1.2, -45, -80, 350, 550, 350, 850, 20, 1, Trail_Oil_Thin, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/player/player_gibs1.dpm", 3, 1, 10, 1, 2, -45, -80, 350, 550, 350, 850, 20, 1, Trail_Oil, Splatter_Oil_Intense);
	SpawnGibs(self, "", '0 0 0', "models/player/player_gibs1.dpm", 4, 2, 8, 1, 1, -25, -45, 450, 650, 350, 850, 20, 1, Trail_Oil_Thin, Splatter_Oil_Weak);
	pointsound(self.origin + '0 0 64', "sounds/debris/ss_metal_softsurface.wav", 1, ATTN_NORM);	
}

void Explode_Tank() =
{
	local vector vec;

	if(self.tag_entity)
		vec = gettaginfo(self.tag_entity, self.tag_index);
	else
		vec = self.origin;

	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 0, 5, 16, 0.4, 1, -75, -90, 350, 550, 350, 850, 20, 1, SUB_Null, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 1, 3, 32, 1, 2, -55, -80, 450, 650, 350, 850, 20, 1, Trail_Oil, Splatter_Oil_Intense);
	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 2, 5, 24, 0.8, 1.5, -65, -85, 350, 550, 350, 850, 20, 1, Trail_Oil, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 3, 10, 40, 0.5, 1, -25, -55, 250, 450, 350, 850, 20, 1, Trail_Oil_Thin, Splatter_Oil_Weak);
	pointsound(vec + '0 0 64', "sounds/debris/ss_metal_softsurface.wav", 1, ATTN_NORM);
}

void Explode_Portal() =
{
	local vector vec;

	if(self.tag_entity)
		vec = gettaginfo(self.tag_entity, self.tag_index);
	else
		vec = self.origin;

	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 0, 5, 8, 0.4, 1, -75, -90, 350, 550, 350, 850, 20, 1, SUB_Null, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 1, 3, 16, 1, 2, -55, -80, 450, 650, 350, 850, 20, 1, Trail_Oil, Splatter_Oil_Intense);
	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 2, 5, 12, 0.8, 1.5, -65, -85, 350, 550, 350, 850, 20, 1, Trail_Oil, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 3, 10, 20, 0.5, 1, -25, -55, 250, 450, 350, 850, 20, 1, Trail_Oil_Thin, Splatter_Oil_Weak);
	pointsound(vec + '0 0 64', "sounds/debris/ss_metal_softsurface.wav", 1, ATTN_NORM);
	pointsound(vec + '0 0 64', "sounds/enemies/portal/ss_portal_dying.wav", 1, ATTN_NORM);
}

void PartialExplosion_FusionCoreRack(vector org, vector offset, float delay) =
{
	SpawnDelayedExplosion(org, delay, SpawnEquipmentFireballCloud_NoLight);
	org_z = self.origin_z;
	org_z += (self.maxs_z+self.mins_z)*0.5;
	SpawnExplosion(org, true);

	offset_z = self.maxs_z+8;
	
	SpawnGibs(self, "", offset, "models/enemies/gibs/tank_gibs1.dpm", 0, 2, 98, 2, 2.5, -75, -90, 550, 950, 350, 850, 20, 1, SUB_Null, SUB_Null);
	SpawnGibs(self, "", offset, "models/enemies/gibs/tank_gibs1.dpm", 1, 1, 180, 2, 2.5, -55, -80, 650, 1050, 350, 850, 20, 1, Trail_Oil, Splatter_Oil_Intense);
	SpawnGibs(self, "", offset, "models/enemies/gibs/tank_gibs1.dpm", 2, 2, 180, 2.5, 3, -65, -85, 950, 550, 350, 850, 20, 1, Trail_Oil, SUB_Null);
	SpawnGibs(self, "", offset, "models/enemies/gibs/tank_gibs1.dpm", 3, 3, 180, 2, 2.5, -25, -55, 450, 950, 350, 850, 20, 1, Trail_Oil_Thin, Splatter_Oil_Weak);
}

void Explode_FusionCoreRack() =
{
	local vector org, forwardvec, rightvec;

	SpawnCameraShaker(self.origin, 3);
	
	makevectors(self.angles);
	forwardvec = v_forward;
	rightvec = v_right;
	org = self.origin;
	org_z += self.maxs_z;

	PartialExplosion_FusionCoreRack(org, '0 0 0', random()*0.1);
	PartialExplosion_FusionCoreRack(org+forwardvec*120+rightvec*40, '120 40 0', random()*0.3);
	PartialExplosion_FusionCoreRack(org+forwardvec*-120+rightvec*-40, '-120 -40 0', random()*0.3);
	PartialExplosion_FusionCoreRack(org+forwardvec*120+rightvec*-40, '120 -40 0', random()*0.3);
	PartialExplosion_FusionCoreRack(org+forwardvec*-120+rightvec*40, '-120 40 0', random()*0.3);	
}

void Explode_Pylon() =
{
	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 0, 8, 128, 1, 2, -75, -90, 550, 950, 350, 850, 20, 1, SUB_Null, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 1, 5, 256, 2, 4, -55, -80, 650, 1050, 350, 850, 20, 1, Trail_Oil, Splatter_Oil_Intense);
	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 2, 8, 256, 2.5, 4.5, -65, -85, 950, 550, 350, 850, 20, 1, Trail_Oil, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/enemies/gibs/tank_gibs1.dpm", 3, 10, 256, 1, 3, -25, -55, 450, 950, 350, 850, 20, 1, Trail_Oil_Thin, Splatter_Oil_Weak);
	pointsound(self.origin + '0 0 64', "sounds/debris/ss_metal_softsurface.wav", 1, ATTN_NORM);
}

void Explode_Crystal() =
{
	SpawnCrystalDustCloud();
	SpawnGibs(self, "", '0 0 0', "models/objects/crystals/cave_crystals_gibs.dpm", 0, 6, 16, 0.4, 1, -75, -90, 350, 550, 350, 850, 20, 1, SUB_Null, SUB_Null);	
	SpawnGibs(self, "", '0 0 0', "models/objects/crystals/cave_crystals_gibs.dpm", 1, 1, 4, 1, 1, -75, -90, 350, 550, 350, 850, 20, 1, SUB_Null, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/objects/crystals/cave_crystals_gibs.dpm", 2, 3, 2, 1, 1, -75, -90, 350, 550, 350, 850, 20, 1, SUB_Null, SUB_Null);
}

void Explode_Stone() =
{
	SpawnDustCloud();
	SpawnGibs(self, "", '0 0 0', "models/objects/stones/stones_dead_gib.dpm", 0, 6, 16*self.gibscale, 0.4*self.gibscale, 1*self.gibscale, -75, -90, 350, 550, 350, 850, 20, 1, SUB_Null, SUB_Null);
}

void Explode_Plant1() =
{
	SpawnPlantDust();
	SpawnGibs(self, "", '0 0 0', "models/objects/plants/plant1_gibs.dpm", 0, 5, 8, 0.4, 1, -75, -90, 350, 550, 350, 850, 20, 0.5, SUB_Null, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/objects/plants/plant1_gibs.dpm", 1, 3, 8, 0.4, 1, -75, -90, 350, 550, 350, 850, 20, 0.5, SUB_Null, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/objects/plants/plant1_gibs.dpm", 2, 5, 8, 0.4, 1, -75, -90, 350, 550, 350, 850, 20, 0.5, SUB_Null, SUB_Null);
}

void Explode_Plant2() =
{
	SpawnPlantDust();
	SpawnGibs(self, "", '0 0 0', "models/objects/plants/plant2_gibs.dpm", 0, 5, 8, 0.4, 1, -75, -90, 350, 550, 350, 850, 20, 0.5, SUB_Null, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/objects/plants/plant2_gibs.dpm", 1, 3, 8, 0.4, 1, -75, -90, 350, 550, 350, 850, 20, 0.5, SUB_Null, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/objects/plants/plant2_gibs.dpm", 2, 5, 8, 0.4, 1, -75, -90, 350, 550, 350, 850, 20, 0.5, SUB_Null, SUB_Null);
}

void Explode_Plant3() =
{
	SpawnPlantDust();
	SpawnGibs(self, "", '0 0 0', "models/objects/plants/plant3_gibs.dpm", 0, 5, 8, 0.4, 1, -75, -90, 350, 550, 350, 850, 20, 0.5, SUB_Null, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/objects/plants/plant3_gibs.dpm", 1, 3, 8, 0.4, 1, -75, -90, 350, 550, 350, 850, 20, 0.5, SUB_Null, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/objects/plants/plant3_gibs.dpm", 2, 5, 8, 0.4, 1, -75, -90, 350, 550, 350, 850, 20, 0.5, SUB_Null, SUB_Null);
}

void Explode_Cactus_Small() =
{
	SpawnCactusSlime();
	SpawnGibs(self, "", '0 0 0', "models/objects/plants/cactus_gibs.dpm", 2, 5, 16, 0.8, 1.2, -65, -80, 250, 350, 350, 850, 20, 1, SUB_Null, Splatter_Cactus);	
}

void Explode_Cactus() =
{
	SpawnCactusSlime();
	SpawnGibs(self, "", '0 0 0', "models/objects/plants/cactus_gibs.dpm", 0, 5, 16, 0.8, 1.2, -75, -80, 350, 550, 350, 850, 20, 1, SUB_Null, Splatter_Cactus);
	SpawnGibs(self, "", '0 0 0', "models/objects/plants/cactus_gibs.dpm", 1, 3, 12, 0.5, 1.5, -55, -70, 450, 550, 350, 850, 20, 1, SUB_Null, Splatter_Cactus);
	SpawnGibs(self, "", '0 0 0', "models/objects/plants/cactus_gibs.dpm", 2, 5, 10, 0.4, 1, -45, -65, 400, 650, 350, 850, 20, 1, SUB_Null, Splatter_Cactus);
}

void Explode_Tree() =
{
	local vector leaf_offset;
	if(self.variant == 0)
		leaf_offset = '0 0 90';
	else
	if(self.variant == 1)
		leaf_offset = '0 0 90';
	else
	if(self.variant == 2)
		leaf_offset = '0 0 90';
	
	SpawnTreeDust();
	SpawnGibs(self, "", '0 0 0', "models/objects/plants/palmtree_gibs.dpm", 0, 5, 8, 0.4, 1, -75, -90, 350, 550, 350, 850, 20, 1, SUB_Null, SUB_Null);
	SpawnGibs(self, "", '0 0 0', "models/objects/plants/palmtree_gibs.dpm", 1, 3, 8, 0.4, 1, -75, -90, 350, 550, 350, 850, 20, 1, SUB_Null, SUB_Null);
	SpawnGibs(self, "", leaf_offset, "models/objects/plants/palmtree_gibs.dpm", 2, 5, 8, 0.4, 1, -75, -90, 350, 550, 350, 850, 20, 0.5, SUB_Null, SUB_Null);
}

void Explode_Object() =
{
	switch(self.objclass)
	{
		case OBJ_FUSIONCORERACK:	Explode_FusionCoreRack();	break;
	
		case OBJ_EQUIPMENT:			Explode_Barrel();	break;

		case OBJ_EQUIPMENT_MED:		Explode_MedContainer();		break;		
		
		case OBJ_EQUIPMENT_BIG:		Explode_BigContainer();		break;

		case OBJ_ENVCRYSTAL:		Explode_Crystal();	break;
	
		case OBJ_STONE:				Explode_Stone();	break;
		
		case OBJ_PLANT:
			if(self.variant <= 1)
				Explode_Plant1();
			else
			if(self.variant == 2)
				Explode_Plant2();
			else
			if(self.variant == 3)
				Explode_Plant3();
			else
			if(self.variant == 4)
				Explode_Cactus_Small();
			else
				Explode_Cactus();
		break;
		
		case OBJ_TREE:				Explode_Tree();		break;
		
		default:					Explode_Stone();	break;
	}
	
	UpdateDeadObjectAppearance();
}

void Explode_Large() =
{
	if(self.objclass == OBJ_STRUCTURE && self.variant == STRUCTURE_PYLON)
	{	InitExplosion(2.8, Explode_Huge_Think);		Explode_Pylon();		}
	else
	if(self.objclass == OBJ_PORTAL)
	{	InitExplosion(1.8, Explode_Large_Think);	Explode_Portal();		}
	else
	{	InitExplosion(1.8, Explode_Large_Think);	Explode_Tank();		}
}

void Explode_Small() =
{
	switch(self.class)
	{
		case CLASS_PLAYER:
			InitExplosion(0.3, Explode_Small_Think);
			Explode_Player();
		break;
		
		case CLASS_OBJECT:	
			if(self.objclass == OBJ_NPC)
			{
				InitExplosion(0.3, Explode_Small_Think);
				Explode_Tank();	
			}
			else
				Explode_Object();
		break;
		
		default:	Explode_Object();	break;
	}
}

void Explode(float isnew) =
{
	local float dmnum;

	dmnum = ReadByte();

	if(isnew)
		return;
	
//	if(self.isdead)
//		return;

	SilenceObjectSounds(self, false);

	if(self.tag_entity)
		self.isdead = true;
	else
		self.owner.isdead = true;
		
	ParticleEmitterChain_Remove(self); // stop flaming and smoking
		
	self.deadmodelnum = dmnum;	
	
//	self.isdead = true;
//	SetObjectAppearance(self, self.objclass, self.variant);		
	
	if(IsAssignedFunction(self.DeathFunc))
		self.DeathFunc();	
}

void FadeRift() =
{
	local float timeratio, duration;
	local entity e;
	
	duration = self.camerashake_y-self.camerashake_z+0.2;
	timeratio = (duration - (self.camerashake_y - time))/duration;
	
	self.owner.alpha = bound(0.01, timeratio, 1);

	for(e = self.owner.list_tagentchain; e; e = e.tagentchain)
		e.alpha = self.owner.alpha;
	
	self.alpha = bound(0.01, 1-timeratio, 1);
	
	if(self.owner.alpha >= 1)
	{
		self.owner.spawningrift = false;
		SH_RemoveEnt(self);
		return;
	}
	
	self.nextthink = time + frametime;
}

void RiftOpen() =
{
	self.scale = bound(0, self.scale + (self.owner.owner.riftscale-0.1)*frametime/0.2, self.owner.owner.riftscale);

	if(self.scale == self.owner.owner.riftscale)
	{
		self.camerashake_y = time + 0.3;
		self.camerashake_z = time;
			
		if(!IsAttachedAIClass(self.owner.npcclass))// != NPC_TURRET)
		{
			self.camerashake_x = CAMFL_SHAKE;
			self.shakecamera = true;
		//	UpdateCameraShakeChain();	
			CameraShakeChain_Add(self);
		}

		self.think = FadeRift;
	}

	self.nextthink = time + frametime;
}

void RiftChargeThink() =
{
	if(time >= self.spawntime)
	{
		self.camerashake_y = time + 0.5;
		self.camerashake_z = time;
	
		if(!IsAttachedAIClass(self.owner.npcclass))// != NPC_TURRET)
		{
			SetAndPrecacheModel(self, "models/enemies/rift_ht2.dpm");
		
			self.camerashake_x = CAMFL_SHAKE_REVERSEFADE;
			self.shakecamera = true;
		//	UpdateCameraShakeChain();
			CameraShakeChain_Add(self);
			
		//	if(effectdrawtime <= time)
				pointparticles(self.owner.chargeeffect2, self.origin-'0 0 64', '0 0 0', 10);	
		}	
			
		self.scale = 0.1;	
		self.think = RiftOpen;
		self.nextthink = time;//self.nextthink + 0.01;
		return;
	}

//	if(effectdrawtime <= time)
	if(!IsAttachedAIClass(self.owner.npcclass))// != NPC_TURRET)
		pointparticles(self.owner.chargeeffect, self.origin-'0 0 64', '0 0 0', 1);

	self.nextthink = time;//self.nextthink + 1/10;
}

void SpawnRift() =
{
	local entity rift;

	if(self.spawningrift)
		return;

	if(IsAttachedAIClass(self.npcclass))
		return;

	self.spawningrift = true;
		
	rift = spawn();
	SetOwner(rift, self);//rift.owner = self;
	SetParent(rift, self);
	self.alpha = 0.01;
	
//	if(!IsAttachedAIClass(self.npcclass))// != NPC_TURRET)
//	{	
		pointsound(self.owner.origin, "sounds/enemies/portal/ss_portal_spawning.wav", 1, ATTN_NORM);	
		setorigin(rift, self.owner.origin+'0 0 128');
		SetAndPrecacheModel(rift, "models/enemies/rift2.dpm");	
		rift.drawmask = MASK_NORMAL;
//	}
	
	rift.alpha = 0.9;
	rift.scale = self.riftscale;

	rift.spawntime = time + self.owner.spawntime;
	rift.think = RiftChargeThink;
	rift.nextthink = time + frametime;
}

void SpawnTeleportEffect() =
{
	local string soundname;

	pointparticles(particleeffectnum("EF_TELEPORT"), self.origin, '0 0 0', 1); 
	
	if(self.flags & FL_ITEM)
		soundname = "sounds/items/ss_items_spawn.wav";
	else
		soundname = "sounds/equipment/ss_teleport.wav";
	
	pointsound(self.origin, soundname, 1, ATTN_NORM);
}

void SpawnRespawnEffect() =
{
	pointparticles(particleeffectnum("EF_TELEPORT"), self.origin, '0 0 0', 1); 
	pointsound(self.origin, "sounds/player/ss_respawn.wav", 1, ATTN_NORM);
}

void ShieldPickupThink() =
{
	float lifetime;
	lifetime = 2;

	if(time > self.borntime + lifetime)
	{
		SH_RemoveEnt(self);
		return;
	}
	
	if(time < self.borntime+lifetime*0.5)
		self.alpha = ((time-self.borntime)/(lifetime*0.5));
	else
	if(time > self.borntime+lifetime*0.5)
		self.alpha = 1-((time-(self.borntime+lifetime*0.5))/(lifetime*0.5));
	
//	self.colormod_x = (1-(time-self.borntime/1));
	
	self.nextthink = time+frametime;
}

void SpawnPickupEffect(vector rgb) =
{
	local entity newshield;
	local float count;
	
	for(count = 0; count < 3; count++)
	{
		newshield = spawn();
		newshield.borntime = time;
		newshield.drawmask = MASK_NORMAL;
		Attach(newshield, player, 0);
		SetAndPrecacheModel(newshield, "models/weapons/impact_sphere.dpm");
		newshield.colormod = rgb;
		newshield.alpha = 0;
		newshield.scale = player.shieldscale;	
		newshield.angles_y = (180/3)*count + random()*(180/3);
		newshield.avelocity = '800 0 0';
		HasAvelocityChain_Add(newshield);
		
		newshield.think = ShieldPickupThink;
		newshield.nextthink = time+frametime;
	}
}

void SpawnShieldPickupEffect() =	{	SpawnPickupEffect('0 0.75 1');	}
void SpawnArmorPickupEffect() =	{	SpawnPickupEffect('1 0.2 0.2');	}

void RemoveStructuralEffects() =
{
	self.particleindex = 0;
	ParticleEmitterChain_Remove(self);
}

void ApplyStructuralEffect(string effectname) =
{
	self.particleindex = particleeffectnum(effectname);
	ParticleEmitterChain_Add(self);
}

void ApplyVisualEffects(float sendflags, float isnew) =
{
/*	local float entsize;
	
	if(self.maxs_x <= 64)
		entsize = 1;
	else
	if(self.maxs_z <= 128)
		entsize = 2;
	else
		entsize = 3;*/

	if(sendflags & SFL_EXPLODE)
		Explode(isnew);
/*	else
	if(sendflags & SFL_DAMAGE_STAGE1)
	{
		if(entsize == 1)
			ApplyStructuralEffect("EF_ENTITY_DAMAGE_SMOKE");
		else	
		if(entsize == 2)
			ApplyStructuralEffect("EF_ENTITY_DAMAGE_SMOKE_MED");
		else
		if(entsize == 3)
			ApplyStructuralEffect("EF_ENTITY_DAMAGE_SMOKE_LARGE");
	}
	else
	if(sendflags & SFL_DAMAGE_STAGE2)
	{
		if(entsize == 1)
			ApplyStructuralEffect("EF_ENTITY_DAMAGE_BURN");
		else	
		if(entsize == 2)
			ApplyStructuralEffect("EF_ENTITY_DAMAGE_BURN_MED");
		else
		if(entsize == 3)
			ApplyStructuralEffect("EF_ENTITY_DAMAGE_BURN_LARGE");
	}
	else
	if(sendflags & SFL_DAMAGE_REPAIRED)
		RemoveStructuralEffects();*/
}

void UpdateEffects(float neweffectflags) =
{
	if(neweffectflags)
	if(!self.effectflags)
		ParticleEmitterChain_Add(self);
		
	if(!neweffectflags)
	if(self.effectflags)
		ParticleEmitterChain_Remove(self);	
		
	self.effectflags = neweffectflags;
}
