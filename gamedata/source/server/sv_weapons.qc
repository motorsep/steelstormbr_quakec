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
float GetProjectileSpeed(float WEP1, float WEP2) =
{
	// 0 = instant
	local float pspeed;
	
	if(WEP1)
	switch(WEP1)
	{
		case WEP_PLASMA:			pspeed = 800;		break;
		case WEP_PROTON:			pspeed = 1600;		break;
		case WEP_PROTON_MED:		pspeed = 1600;		break;
		case WEP_DESTROYERBEAM:		pspeed = 0;			break;
		case WEP1_MINIGUN:			pspeed = 0;			break;
		case WEP1_BEAMCANNON:		pspeed = 0;			break;
		case WEP_TURRETBEAM:		pspeed = 0;			break;
		case WEP1_STORMPLOW:		pspeed = 1200;		break;
		case WEP1_ROCKETPOD:		pspeed = 750;		break;
		case WEP_LIGHTNING:			pspeed = 0;			break;
		case WEP_REPAIR:			pspeed = 0;			break;	
		case WEP_HMISSILES:			pspeed = 500;		break;
	}

	if(WEP2)
	switch(WEP2)
	{
		case WEP2_STORMSPREAD:		pspeed = 1200;		break;
		case WEP2_STORMSHIELD:		pspeed = 0;			break;
		case WEP2_THUNDERBOLT:		pspeed = 0;			break;
		case WEP2_SHOCKWAVE:		pspeed = 0;			break;
		case WEP2_HOMINGMISSILES:	pspeed = 500;		break;		
		case WEP2_MIRVMORTAR:		pspeed = 500;		break;		// special case
	}	
	
	return pspeed;
}

vector GetProjectileAngles(vector startorg) =
{
	local vector ang, endorg, xang;
	
	if(self.class != CLASS_PLAYER)
	{
	//	startorg = gettaginfo(self, tagindex);
		endorg = self.enemy.origin;
		endorg_z += (self.enemy.maxs_z+self.enemy.mins_z)*0.5;	
		xang = vectoangles(startorg - endorg);
		ang_x = xang_x*-1;
	}	
	
	ang_y = self.angles_y;
	
	if(IsAttachedAIClass(self.npcclass))// == NPC_TURRET)
		ang += self.owner.angles;	
	
	return ang;
}

float HitValidTarget(entity attacker, entity victim) =
{
	if(attacker.class != CLASS_PLAYER)
		return FALSE;

	if(victim)
	if(victim.class == CLASS_PLAYER || victim.objclass == OBJ_NPC)
	if(victim.team != attacker.team)
		return TRUE;
		
	return FALSE;
}

void SetAccuracy(entity attacker) =
{
	attacker.accuracy = attacker.connectedhits/attacker.attemptedhits;
	UpdateScore(attacker, SCORESTAT_ACCURACY);
}

void AdjustAccuracy(entity attacker, entity victim) =
{
	if(!HitValidTarget(attacker, victim))
		return;

	attacker.connectedhits = attacker.connectedhits + 1;
	SetAccuracy(attacker);
}

void RemoveProjectile() =
{
	UnmarkGrid(self, FALSE, TRUE);	
	SH_RemoveEnt(self);
//	UpdateMobileEntChain();
}

float ProjectileTouch(entity e, void() ProjectileHitEffect, float damage, float rad) =
{
	local entity cd;
	local vector diff1;

	if(e != world)
	if(!ProjectileCanHit(e))
		return FALSE;

	self.parent.attemptedhits = self.parent.attemptedhits + 1;
	AdjustAccuracy(self.parent, e);		
		
	// don't hit spread circle balls when switching firing modes
/*	if(self.projectileclass == CLASS_SPREAD_BALL)
	if(self.owner.owner == e.owner.owner)
		return FALSE;



	// spread balls lose their owner when hit by shockwave, this prevents new balls from destroying old balls
	if(e.projectileclass == CLASS_SPREAD_BALL && self.projectileclass == CLASS_SPREAD_BALL)
		return FALSE;

	// spread ball, don't hit owner
	if(self.projectileclass == CLASS_SPREAD_BALL)
	if(e.owner)
	if(e == self.owner.owner)
		return FALSE;*/
		
	// hit something that should remove the projectile	
//	if(e != self.owner)
//	if(!(self.owner.owner && e.owner.owner == self.owner.owner))
//	{
	/*	if(self.projectileclass == CLASS_SPREAD_BALL)
		{
			print(ftos(e.class));	print("\n");
		}*/
	
		self.touch = SUB_Null;
		self.think = RemoveProjectile;
		self.nextthink = time + 0.1;		
//	}
	
//	if(self.owner.owner && e.owner.owner == self.owner.owner)//e == self.owner || e == self.owner.owner || e.owner == self.owner || e.owner.owner == self.owner.owner)
//	{
	/*	if(e.owner.owner == e.owner)
		{
			if(e.class == CLASS_SHOT)
				print("B\n");
			else
				print("B2\n");
		}
		else
			print("C\n");*/
			
//		return FALSE;
//		}
	
	if(!self.hit)
	{
		if(e && e.class != CLASS_SHOT)
			self.hit = e.id;
		else
			self.hit = -1;
			
		self.SendFlags = TRUE;
	}

	if(IsAssignedFunction(ProjectileHitEffect))
		ProjectileHitEffect();
	
	if(e)
		Damage(self.parent, e, self, damage);
		
	if(rad)
		RadiusDamage(self, e, damage, rad);
	
	return TRUE;
}

/*float ShieldHitDetected() =
{
	local entity e, closesttarg;
	
	e = findradius(self.origin, 105.55*5);
	while(e)
	{
		if((self.owner.owner.class == CLASS_PLAYER && e.objclass == CLASS_NPC) || (self.owner.owner.objclass == CLASS_NPC && e.class == CLASS_PLAYER))
		if(e.health > 0)
		if(!closesttarg || vlen(self.origin - e.origin) < vlen(self.origin - closesttarg.origin))
		{
			traceline(self.origin, e.origin+'0 0 16', TRUE, self);
			if(trace_fraction == 1)
				closesttarg = e;
		}

		e = e.chain;
	}
		
	if(closesttarg)
	{
		if(vlen(self.origin - closesttarg.origin) < closesttarg.shieldscale*105.55)
		{
			self.hitfunc(closesttarg);
			return TRUE;
		}
	}
	
	return FALSE;
}*/

float ExpiredProjectile() =
{
	local vector diff1;

	diff1 = self.origin - self.parent.origin;
	if((self.removetime && self.removetime <= time)
	||(self.owner.owner.class == CLASS_PLAYER && diff1*diff1 > CANDAMAGEMAXDIST*CANDAMAGEMAXDIST))
		return TRUE;
		
	return FALSE;
}

void ProjectileThink_Default() =
{
//	if(ShieldHitDetected())
//		return;

	local vector diff1;

	UnmarkGrid(self, FALSE, TRUE);	
	
	diff1 = self.velocity;
	if(diff1*diff1 < 1)// == '0 0 0') // FIXME (this is a hack)
	{
		self.think = RemoveProjectile;
		self.nextthink = time + 0.1;		
		return;
	}		
		
	if(ExpiredProjectile())
	{
		self.parent.attemptedhits = self.parent.attemptedhits + 1;
		SetAccuracy(self.parent);	
		RemoveProjectile();
		return;
	}
		
//	traceline(self.origin, self.origin.v_forward*2000, FALSE, self);
//	if(trace_ent)
//		AI_Dodge(trace_ent, self.origin, trace_endpos);

	MarkGrid(self, FALSE, TRUE, self.gridpos);

		
	self.nextthink = SV_UPDATEDELAY;
	self.think = ProjectileThink_Default;
}

entity SpawnProjectile(string modelname, vector ang, float vel_forward, void() TouchFunc, void() HitFunc, void() ThinkFunc, vector pos, float MOVETYPE, float MODELFLAGS, float SHOTVARIANT, float ISMOBILE) =
{
	local entity e, shooter;
//	local vector xang;
	
//	if(self.objclass == CLASS_NPC && self.tag_entity) // shooter is a turret
//		shooter = self.parent;
//	else
//		shooter = self.owner;
	
	e = SpawnFloater();
	SetOwner(e, self);//e.owner = self;
	SetParent(e, self.parent);
	e.movetype = MOVETYPE;
	e.solid = SOLID_TRIGGER;
	e.class = CLASS_SHOT;
	e.shotclass = SHOT_PROJECTILE;
	if(self.weaponshotvariant)
		e.shotvariant = self.weaponshotvariant;
	else	
		e.shotvariant = SHOTVARIANT;
	e.mobile = ISMOBILE;

	if(ISMOBILE)
//		UpdateMobileEntChain();
		MobileEntChain_Add(e);

//	if(self.tag_entity)//self.npcclass == NPC_TURRET)
//		ang += self.owner.angles;
	
/*	if(self.enemy)
	{
		local vector eorg;
		eorg = self.enemy.origin;
		eorg_z += self.enemy.maxs_z*0.5;
		xang = vectoangles(pos - eorg);
		ang_x = xang_x;
	}*/
	
	SetAndPrecacheModel(e, modelname);
	setsize(e, '-16 -16 -16', '16 16 16');		
	setorigin(e, pos);		
	
	e.angles = ang;
	
//	print(ftos(e.angles_x));print("B\n");	
	
	ang_x = ang_x*-1;
	makevectors(ang);
	e.movespeed = vel_forward;
	e.velocity = v_forward*e.movespeed;

	e.origionalyaw = e.angles_y;
	e.intendeddirection = e.angles;
	
	e.touch = TouchFunc;
	e.hitfunc = HitFunc;
//	e.modelflags = MODELFLAGS;	
	
	if(ThinkFunc)
		Func_oself(e, ThinkFunc);
	else
		Func_oself(e, ProjectileThink_Default);
	
	if(!e.removetime)
		e.removetime = time+2;//(1280/vel_forward);	

	e.SendEntity = SendProjectile;
	e.SendFlags = SFL_ORIGIN | SFL_ANGLES;
	
	return e;
}

entity SpawnProjectileFromTag(string modelname, vector ang, float vel_forward, void() TouchFunc, void() HitFunc, void() ThinkFunc, float tagindex, float MOVETYPE, float MODELFLAGS, float SHOTVARIANT, float ISMOBILE) =
{
	local vector pos;
	local entity e;
	
	pos = gettaginfo(self, tagindex);
	e = SpawnProjectile(modelname, ang, vel_forward, TouchFunc, HitFunc, ThinkFunc, pos, MOVETYPE, MODELFLAGS, SHOTVARIANT, ISMOBILE);
	return e;
}

void PlasmaHit(entity e) =	{	ProjectileTouch(e, SUB_Null, 15, FALSE);	}

void PlasmaTouch() =	{	PlasmaHit(other);	}

void FirePlasma() =
{
	local string modelname;
	local float vel_forward, tagindex;
	local vector ang;
	local void() TouchFunc, HitFunc, ThinkFunc;
	
	modelname = "models/weapons/spread.dpm";
	tagindex = self.(shootfrom_index[self.firingfrom]);	
	
	ang = GetProjectileAngles(gettaginfo(self, tagindex));
	
	vel_forward = 800;
	TouchFunc = PlasmaTouch;
	HitFunc = PlasmaHit;
	ThinkFunc = SUB_Null;
	
	if(self.(shootfrom_index[1]))
		self.firingfrom = !self.firingfrom;	
		
	SpawnProjectileFromTag(modelname, ang, vel_forward, TouchFunc, HitFunc, ThinkFunc, tagindex, MOVETYPE_FLY, 0, PROJ_PLASMA_LIGHT, FALSE);
}

void ProtonHit(entity e) =	{	ProjectileTouch(e, SUB_Null, 15, FALSE);	}
void ProtonTouch() =	{	ProtonHit(other);	}

void FireProton() =
{
	local string modelname;
	local float vel_forward, tagindex;
	local vector ang;
	local void() TouchFunc, HitFunc, ThinkFunc;
	
	modelname = "models/weapons/proton_torpedo.dpm";
	tagindex = self.(shootfrom_index[self.firingfrom]);	
	
	ang = GetProjectileAngles(gettaginfo(self, tagindex));
	
	vel_forward = 1600;
	TouchFunc = ProtonTouch;
	HitFunc = ProtonHit;
	ThinkFunc = SUB_Null;
	
	if(self.(shootfrom_index[1]))
		self.firingfrom = !self.firingfrom;	
		
	SpawnProjectileFromTag(modelname, ang, vel_forward, TouchFunc, HitFunc, ThinkFunc, tagindex, MOVETYPE_FLY, 0, PROJ_PROTON, FALSE);
}

void Proton_MedHit(entity e) =	{	ProjectileTouch(e, SUB_Null, 30, FALSE);	}
void Proton_MedTouch() =	{	Proton_MedHit(other);	}

void FireProton_Med() =
{
	local string modelname;
	local float vel_forward, tagindex;
	local vector ang;
	local void() TouchFunc, HitFunc, ThinkFunc;
	
	modelname = "models/weapons/proton_torpedo.dpm";
	tagindex = self.(shootfrom_index[self.firingfrom]);	
	
	ang = GetProjectileAngles(gettaginfo(self, tagindex));
	
	vel_forward = 1600;
	TouchFunc = Proton_MedTouch;
	HitFunc = Proton_MedHit;
	ThinkFunc = SUB_Null;
	
	if(self.(shootfrom_index[1]))
		self.firingfrom = !self.firingfrom;	
		
	SpawnProjectileFromTag(modelname, ang, vel_forward, TouchFunc, HitFunc, ThinkFunc, tagindex, MOVETYPE_FLY, 0, PROJ_PROTON_MED, FALSE);
}

void RocketHit(entity e) =	{	ProjectileTouch(e, SUB_Null, 50, 250);	}

void RocketTouch() =	{	RocketHit(other);	}

void RocketThink() =
{
	local vector diff1;

	UnmarkGrid(self, FALSE, TRUE);	
	
	diff1 = self.velocity;
	if(diff1*diff1 < 1)// == '0 0 0') // FIXME (this is a hack)
	{
		self.think = RemoveProjectile;
		self.nextthink = time + 0.1;		
		return;
	}

	if(!self.removetime)
		self.removetime = time + 2.5;

	if(ExpiredProjectile())
	{
		self.parent.attemptedhits = self.parent.attemptedhits + 1;
		SetAccuracy(self.parent);	
		RocketHit(world);
	//	RemoveProjectile();
		return;
	}
		
	MarkGrid(self, FALSE, TRUE, self.gridpos);		
		
//	if(ShieldHitDetected())
//		return;
		
	local float newideal_yaw;
	newideal_yaw = self.angles_y + random()*60-30;
		
	
	if(AngleDifference(newideal_yaw, self.origionalyaw) <= 20)
		self.ideal_yaw = newideal_yaw;

	self.yaw_speed = 0.85;

	self.nextthink = time + 0.3;
	self.think = RocketThink;		
}

void FireRockets() =
{
	local string modelname, tagL, tagR;
	local float vel_forward;
	local vector ang, downang;
	local void() TouchFunc, HitFunc, ThinkFunc;

	if(self.maxfiringpos > 1)
		self.autofiretime = time+0.2;	
	
	if(!self.firingpos)
		self.firingpos = self.maxfiringpos;
	
	modelname = "models/weapons/rocket.dpm";//"models/weapons/spread.dpm";//
//	ang_y = self.angles_y;
	
/*	if(self.class == CLASS_PLAYER)
		ang_x = -2.4 - self.firingpos*0.25;
	else
	{
		ang = GetProjectileAngles(self.origin);*/
	
/*		local vector start, end;
		start = self.enemy.origin;
		start_z += self.enemy.maxs_z*0.5;
		end = self.origin;
		end_z += self.maxs_z*0.5;
		angb = vectoangles(start - end);
		ang_x = angb_x;*/
//	}
	
	vel_forward = 750;
	TouchFunc = RocketTouch;
	HitFunc = RocketHit;
	ThinkFunc = RocketThink;
	
	if(self.class == CLASS_PLAYER)
	{
		tagL = "tag_rockets.L";
		tagR = "tag_rockets.R";
	}
	else
	{
		tagL = tagR = strcat("tag_rocket", ftos(self.firingpos));
		tagL = strcat(tagL, ".L");
		tagR = strcat(tagR, ".R");
	}

	if(self.class == CLASS_PLAYER)
		downang_x = -2.4 - self.firingpos*0.25;
	
	ang = GetProjectileAngles(gettaginfo(self, gettagindex(self, tagL))) + downang;
	SpawnProjectileFromTag(modelname, ang, vel_forward, TouchFunc, HitFunc, ThinkFunc, gettagindex(self, tagL), MOVETYPE_FLY, MF_ROCKET, PROJ_ROCKET, TRUE);

	if(self.npcclass != NPC_MICROFLYER)
	{
		ang = GetProjectileAngles(gettaginfo(self, gettagindex(self, tagR))) + downang;
		SpawnProjectileFromTag(modelname, ang, vel_forward, TouchFunc, HitFunc, ThinkFunc, gettagindex(self, tagR), MOVETYPE_FLY, MF_ROCKET, PROJ_ROCKET, TRUE);
	}
		
	self.firingpos -= 1;		
}

float BulletTrace(entity attacker, entity projectile, float damage, float shotnum) =
{
	local vector pos, ang, endpos;
	local float tagindex, shotdist;
	
//	tagindex = gettagindex(attacker, tagname);
	pos = projectile.origin;//gettaginfo(attacker, tagindex);
	
	ang = projectile.angles;//attacker.angles_y;
	
//	if(IsAttachedAIClass(attacker.npcclass))// == NPC_TURRET)
//		ang_y += attacker.owner.angles_y;
	
	makevectors(ang);
	
	attacker.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	traceline(pos, pos+v_forward*5000, FALSE, attacker);
	attacker.dphitcontentsmask = 0;
	endpos = trace_endpos;

	shotdist = vlen(endpos - pos);	

	attacker.attemptedhits = attacker.attemptedhits+1;
	
	if(trace_ent)
	if(shotdist <= CANDAMAGEMAXDIST)
	{
	//	if(cvar("sv_printminigunhits"))
	//		eprint(trace_ent);
	//	if(shotdist > 1600)
	//		damage = damage*bound(0.1, 1-((shotdist-1600)/1600), 1);
	
		if(trace_ent.health)
		{
			projectile.hit = trace_ent.id;
			AdjustAccuracy(attacker, trace_ent);	
		}
		
		Damage(attacker, trace_ent, world, damage);
	}
	
	return shotdist;
}

entity FireMinigunTrace(string tagname, vector ofs, float traceyaw) =
{
	local entity trace;
	local vector ang, org;
	local float tagindex;
	
	trace = SpawnFloater();
	SetOwner(trace, self);
	SetParent(trace, self);
	trace.class = CLASS_SHOT;
	trace.shotclass = SHOT_BULLET;
//	if(self.weaponshotvariant)
//		trace.shotvariant = self.weaponshotvariant;
//	else
//		trace.shotvariant = BULL_MINIGUN_PLAYER;
	
	SetAndPrecacheModel(trace, "null");

	tagindex = gettagindex(self, tagname);
	org = gettaginfo(self, tagindex) + ofs;
	setorigin(trace, org);		
	ang_y = traceyaw;
	
	if(IsAttachedAIClass(self.npcclass))
		ang_y = self.owner.angles_y + self.angles_y;
	else
		ang_y = self.angles_y;
	
	if(self.class != CLASS_PLAYER)
	{
		local vector hitorg, xang;
		hitorg = self.enemy.origin;
		hitorg_z += (self.enemy.maxs_z+self.enemy.mins_z)*0.5;
		xang = vectoangles(hitorg-trace.origin);
		ang_x = xang_x*-1;
	}		
	
	trace.angles_y = ang_y;
	trace.shotlen = BulletTrace(self, trace, 5, 0);		
	
	makevectors(ang);
	
	trace.SendEntity = SendBullet;
	trace.SendFlags = TRUE;
	trace.effects = EF_NODEPTHTEST;
	trace.think = SUB_Remove;
	trace.nextthink = time+0.25;	
	
	if(self.class == CLASS_PLAYER)
	if(self.think != shoot_miniguns)
	{
		shoot_miniguns();
		SetEventFlag_Animation(self, ANIM_PLAYER_MINIGUNS);
	//	self.SendFlags = self.SendFlags | SFL_ANIM_SHOOT_MINIGUNS;
	}
	
	return trace;
}

void FireMiniguns() =
{
	local entity e;
	local float traceyaw;

	if(self.class == CLASS_PLAYER)
	{
		e = FireMinigunTrace("tag_miniguns.R", '0 0 0', self.angles_y);
		e.shotvariant = BULL_MINIGUN_PLAYER;
		e = FireMinigunTrace("tag_miniguns.L", '0 0 0', self.angles_y);	
		e.shotvariant = BULL_MINIGUN_PLAYER;
		SetEventFlag_Sound(self, SOUND_MINIGUN_PLAYER_FIRE);
	}
	else
	{
		if(IsAttachedAIClass(self.npcclass))
			traceyaw = self.owner.angles_y + self.angles_y;
		else
			traceyaw = self.angles_y;
		e = FireMinigunTrace("tag_shoot", '0 0 0', traceyaw);	
		e.shotvariant = self.weaponshotvariant;
		SetEventFlag_Sound(self, SOUND_MINIGUN_HEAVY_FIRE);
	}
}

void FireFlackGuns() =
{
	local entity e;
	local float count;
	local vector ang, ofs;
	
	ang = self.angles;
	ang_z = 0;
	
	makevectors(ang);
	
	for(count = 0; count < 3; count++)
	{
		makevectors(ang);
		ofs = v_up*(12-random()*24) + v_right*(12-random()*24);
		e = FireMinigunTrace("tag_miniguns.R", ofs, self.angles_y+random()*5-2.5);	
		e.shotvariant = BULL_FLACKGUN_PLAYER;
	}

	for(count = 0; count < 3; count++)
	{
		makevectors(ang);
		ofs = v_up*(12-random()*24) + v_right*(12-random()*24);	
		e = FireMinigunTrace("tag_miniguns.L", ofs, self.angles_y+random()*5-2.5);
		e.shotvariant = BULL_FLACKGUN_PLAYER;
	}
	
	SetEventFlag_Sound(self, SOUND_FLACKGUN_PLAYER_FIRE);
}

float BeamTrace(entity beam, entity attacker, float damage, vector pos, vector ang) =
{
	local float shotdist;
	local vector endpos;
	local entity hitent, e, combattarget;
	
//	pos = beam.origin;
//	ang = beam.angles;

//	ang_x = ang_x*-1;

	if(damage)
	{
		e = list_nonsolidsolidchain;
		while(e)
		{
			e.solid = SOLID_NOT;
			e = e.nonsolidsolidchain;
		}

		makevectors(ang);
		attacker.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
		traceline(pos, pos+v_forward*10000, FALSE, attacker);
		attacker.dphitcontentsmask = 0;
		endpos = trace_endpos;
		shotdist = vlen(pos - endpos);
		
		e = list_nonsolidsolidchain;
		while(e)
		{
			e.solid = SOLID_SLIDEBOX;
			e = e.nonsolidsolidchain;
		}	

		beam.hit = trace_ent.id;	
		hitent = trace_ent;
		
		if(hitent)
		{
			if(shotdist <= CANDAMAGEMAXDIST)
			{
				if(beam.items1 == WEP1_BEAMCANNON)
				if(hitent.class == CLASS_PLAYER)
					damage = damage*(1/3);
				
				Damage(attacker, hitent, world, damage);
				beam.enemy = attacker.enemy;
				
				if(HitValidTarget(attacker, hitent))
				{
					beam.connectedhits = TRUE;
				
					if(beam.items1 == WEP1_BEAMCANNON)
					if(beam.frags < 3)
					if(hitent.health <= 0)
					if(hitent.solid == SOLID_SLIDEBOX)
					{
						beam.frags = beam.frags+1;
						if(beam.frags >= 3)
							attacker.challenge_perforator = TRUE;
					}
				}
			}
		}
	}
	else
	{
		if(beam.items1 == WEP_REPAIR)
		{
			combattarget = attacker.ally;
			if(!combattarget)
				combattarget = beam.ally;
		}
		else
		{
			combattarget = attacker.enemy;	
			if(!combattarget)
				combattarget = beam.enemy;
		}
	
		beam.hit = combattarget.owner.id;
		endpos = combattarget.origin;
		endpos_z += (combattarget.maxs_z+combattarget.mins_z)*0.5;
		shotdist = vlen(pos - endpos);
	}

	return shotdist;
}

void BeamThink() = 
{
	local entity ownerent, combattarget;
	local float cooldown, tagindex;
	local vector org;
//	local string tagname;
	
	ownerent = self.owner;

	if(self.items1 == WEP_REPAIR)
	{
		combattarget = ownerent.ally;
		if(!combattarget)
			combattarget = self.ally;
	}
	else
	{
		combattarget = ownerent.enemy;	
		if(!combattarget)
			combattarget = self.enemy;
	}
	
//	if(self.owner.class == CLASS_PLAYER)
//		tagname = "tag_cannon.R";
//	else
//		tagname = "tag_shoot";	
	
	local float dmg, shottime;
		
	if(self.shotvariant == BEAM_CANNON || self.shotvariant == BEAM_DESTROYERBEAM)
	{
		cooldown = 2;
		dmg = 300;
		shottime = 0.5;
	}
	else
	if(self.shotvariant == BEAM_REPAIR)			
	{
		cooldown = 3;	
		dmg = 0;
		shottime = 0.3;
	}
	else
	if(self.shotvariant == BEAM_TURRETBEAM)			
	{
		cooldown = 3;	
		dmg = 33.34;
		shottime = 0.5;
	}
	
	if(ownerent.class != CLASS_PLAYER)
	{
		cooldown = ownerent.firingrate_x;
	
	/*	if((self.shotvariant == BEAM_REPAIR && !ownerent.ally)
		|| (self.shotvariant != BEAM_REPAIR && !ownerent.enemy))
		{
			SH_RemoveEnt(self);
			return;		
		}*/
	}
	
//	if(ownerent.(attack_finished[self.wepclass]) - cooldown + shottime <= time
	if(AttackFinished(ownerent, self.items1, self.items2, 1) - cooldown + shottime <= time)
//	|| (self.shotclass == CLASS_REPAIR && !ownerent.enemy))
	{
		if(self.shotvariant == BEAM_REPAIR)	
		{
			if(self.owner.ally)
				Revive(self.owner.ally);	
			self.ally = world;
			self.owner.ally = world;
		//	self.owner.enemy = world;
		}
	
		ownerent.attemptedhits = ownerent.attemptedhits+1;
		if(self.connectedhits)
			ownerent.connectedhits = ownerent.connectedhits+1;
		SetAccuracy(ownerent);
	
		SH_RemoveEnt(self);
		return;
	}
	
	local float len;
	local vector ang;

	org = gettaginfo(self.owner, self.owner.shootfrom_index);
	
	if(self.owner.class != CLASS_PLAYER)
	if(combattarget)
	{
		local vector hitorg, xang;
		
		hitorg = combattarget.origin;
		hitorg_z += (combattarget.maxs_z+combattarget.mins_z)*0.5;
			
		xang = vectoangles(hitorg-org);
		ang_x = xang_x*-1;
	}	
	else
		ang_x = self.angles_x;

	ang_y = self.owner.angles_y;
	if(IsAttachedAIClass(self.owner.npcclass))
		ang_y += self.owner.owner.angles_y;

	if(dmg > 0 && shottime > 0)
		dmg = dmg*(frametime/shottime);
		
	len = BeamTrace(self, self.owner, dmg, org, ang);		
		
	if(len != self.shotlen || ang != self.angles || org != self.origin)
	{
		setorigin(self, org);
		self.shotlen = len;
		self.angles = ang;		
		self.SendFlags = TRUE;
	}
	
	self.nextthink = time+frametime;
}

void FireBeamWeapon(float SHOTVARIANT, float WEP1, float WEP2, float DMG) =
{
	local entity trace, combattarget;
	local vector ang, org;
	local string tagname;
	local float tagindex;
	
//	if(self.class == CLASS_PLAYER)
//		tagname = "tag_cannon.R";
//	else
//		tagname = "tag_shoot";
	
	trace = SpawnFloater();
	trace.effects = EF_NODEPTHTEST;
	SetOwner(trace, self);
	SetParent(trace, self);
	trace.class = CLASS_SHOT;
	trace.shotclass = SHOT_BEAM;
	trace.shotvariant = SHOTVARIANT;
	trace.items1 = WEP1;
	trace.items2 = WEP2;
	SetAndPrecacheModel(trace, "null");
	
//	tagindex = gettagindex(self, tagname);
	org = gettaginfo(self, self.shootfrom_index);
	setorigin(trace, org);		
	if(IsAttachedAIClass(self.npcclass))
		ang_y = self.owner.angles_y + self.angles_y;
	else
		ang_y = self.angles_y;
	
	if(self.class != CLASS_PLAYER)
	{
		if(WEP1 == WEP_REPAIR)
			combattarget = self.ally;
		else
			combattarget = self.enemy;
			
		local vector hitorg, xang;
		hitorg = combattarget.origin;
		hitorg_z += (combattarget.maxs_z+combattarget.mins_z)*0.5;
		xang = vectoangles(hitorg-trace.origin);
		ang_x = xang_x*-1;
	}		
	
	trace.angles = ang;
	trace.shotlen = BeamTrace(trace, self, DMG, org, ang);

//	ang = trace.angles;
//	makevectors(ang);
//	setorigin(trace, self.origin+v_forward*trace.shotlen*0.5);
//	trace.angles = ang;
	trace.SendEntity = SendBeam;
	trace.SendFlags = TRUE;
	trace.effects = EF_NODEPTHTEST;
	trace.think = BeamThink;
	trace.nextthink = time+frametime;	
	
	//anim?
}

void FireDestroyerBeam() =	{	FireBeamWeapon(BEAM_DESTROYERBEAM, WEP_DESTROYERBEAM, 0, 300*(frametime/0.3));	}///(0.3/frametime));	}

void FireBeamCannon() =	{	FireBeamWeapon(BEAM_CANNON, WEP1_BEAMCANNON, 0, 300*(frametime/0.3));	}///(0.3/frametime));	}

void FireTurretBeam() =	{	FireBeamWeapon(BEAM_TURRETBEAM, WEP_TURRETBEAM, 0, 33.34*(frametime/1));	}//);	}

void StormPlowHit(entity e) =	{	ProjectileTouch(e, SUB_Null, 8, 0);	}
void StormPlowTouch() =			{	StormPlowHit(other);	};

void SpreadHit(entity e) =		{	ProjectileTouch(e, SUB_Null, 8, FALSE);	}
void SpreadTouch() =			{	SpreadHit(other);	};

void FireEnergyWep_Blaster() =
{
	local string modelname;
	local float vel_forward;
	local vector ang;
	local void() TouchFunc, HitFunc, ThinkFunc;	
	
	ang_y = self.angles_y;
	vel_forward = 1200;
	modelname = "models/weapons/spread.dpm";	
	TouchFunc = StormPlowTouch;
	HitFunc = StormPlowHit;
	
		SpawnProjectileFromTag(modelname, ang, vel_forward, TouchFunc, HitFunc, ThinkFunc, gettagindex(self, "tag_cannon.R"), MOVETYPE_FLY, 0, PROJ_STORMPLOW, FALSE);
}

void FireSpread() =
{
	local entity e;
	local string modelname, tagname;
	local float count, coneang, shots, vel_forward;
	local vector ang;
	local void() TouchFunc, HitFunc, ThinkFunc;	
	
	coneang = 90;
	shots = 5;
	vel_forward = 1200;
	modelname = "models/weapons/spread.dpm";	
	TouchFunc = SpreadTouch;
	HitFunc = SpreadHit;
//	ThinkFunc = SUB_Null;
	
	for(count = 0; count < shots; count++)
	{
		if(count == 0)
			tagname = "";
		else
		if(count == 1)
			tagname = "";
		else
		if(count == 2)
			tagname = "";
		else
		if(count == 3)
			tagname = "";
		else
		if(count == 4)
			tagname = "";			
		
		ang_y = (self.angles_y - coneang*0.5) + ((coneang/(shots-1))*count);
		e = SpawnProjectileFromTag(modelname, ang, vel_forward, TouchFunc, HitFunc, ThinkFunc, self.shootfrom_index, MOVETYPE_FLY, 0, PROJ_STORMSPREAD, FALSE);
		// only play firing sounds for the first shot in the set
		if(count)
			e.mute = TRUE;
	}
}

entity	list_ballchain;
.entity	ballchain;
void Spread_CircleThink() =
{
//	if(ShieldHitDetected())
//		return;

	local vector org, ang;

	if(time >= self.fadetime)
	{
		if(self.alpha == 1)
			self.SendFlags = self.SendFlags | SFL_FADE;
		self.alpha -= 1/(0.75/SV_UPDATEDELAY);		
		
		if(time - self.fadetime >= 2)
		{
			SH_RemoveEnt(self);
			return;
		}
		else
		if(time - self.fadetime >= 0.75)
			self.touch = SUB_Null;
	}
		
//	org = self.owner.owner.origin;
//	org_z += (self.owner.owner.maxs_z+self.owner.owner.mins_z)*0.75;
		
	ang_y = (self.owner.angles_y+self.ballnum*(360/6)*2)*self.direction;
	
	org = self.owner.owner.origin + (self.owner.owner.origin - self.owner.owner.oldorigin2)*frametime*(1/SV_UPDATEDELAY)*10;
	org_z += (self.owner.owner.maxs_z+self.owner.owner.mins_z)*0.75;
	
	makevectors(ang);
	org += v_forward*(250+(self.direction*15));
	
	self.velocity = normalize(org - self.origin)*vlen(org - self.origin)*(1/SV_UPDATEDELAY);//*speedmultiple;
	
	ang = vectoangles(self.velocity);
	self.angles_y = ang_y;
	
	self.nextthink = time;//self.nextthink+SV_UPDATEDELAY;
	self.think = Spread_CircleThink;
}

void FireSpread_Circle() =
{
	local string modelname;
	local float count, newballcount, shots, vel_forward, newdirection;//, updatechain;
	local vector ang, pos, org;
	local void() TouchFunc, HitFunc, ThinkFunc;	
	local entity e, nexte, lastball, ball, newball;
	
	shots = 6;
	vel_forward = 1200;
	modelname = "null";//sprites/explode1.spr32";	
	TouchFunc = SpreadTouch;
	HitFunc = SpreadHit;
	ThinkFunc = Spread_CircleThink;

	org = self.origin;
	org_z += (self.maxs_z+self.mins_z)*0.75;	
	
	e = findradius(org, 300);
	while(e)
	{
		nexte = e.chain;
		if(e.shotclass == SHOT_PROJECTILE)
		if(e.shotvariant == PROJ_STORMSHIELD)
		if(e.owner.owner == self)
		{
			if(e.alpha < 1)
				e.SendFlags = e.SendFlags | SFL_FADERESET;

			e.touch = TouchFunc;
			e.alpha = 1;
			e.fadetime = time+0.75;
		
			if(!list_ballchain)
				list_ballchain = e;
			else
				lastball.ballchain = e;
			lastball = e;
		}
		e = nexte;		
	}	
	
//	if(updatechain)
//		UpdateMobileEntChain();
	
	if(!self.ballcontroller)
	{
		self.ballcontroller = SpawnFloater();
		SetOwner(self.ballcontroller, self);//self.ballcontroller.owner = self;
		SetParent(self.ballcontroller, self);
		self.ballcontroller.movetype = MOVETYPE_NOCLIP;
		self.ballcontroller.avelocity = '0 500 0';
	}
	
	for(count = 0; count < shots; count++)
	{
		ball = list_ballchain;
		while(ball)
		{
			if(ball.ballnum == count)
				break;
				
			ball = ball.ballchain;
		}
		
		if(!ball)
		{
			if((count*0.5) - floor(count*0.5) == 0)
				newdirection = 1;
			else
				newdirection = -1;	
		
			ang_y = (self.ballcontroller.angles_y+count*(360/6)*2)*newdirection;
		
			makevectors(ang);
			pos = org+v_forward*(250+(newdirection*15));
		
			newball = SpawnProjectile(modelname, '0 0 0', vel_forward, TouchFunc, HitFunc, SUB_Null, pos, MOVETYPE_FLY, 0, PROJ_STORMSHIELD, FALSE);
			newball.direction = newdirection;
			SetOwner(newball, self.ballcontroller);//newball.owner = self.ballcontroller;
			SetParent(newball, self);
			setsize(newball, '-32 -32 -16', '32 32 32');
			newball.ballnum = count;//+1;
			newball.alpha = 1;
			newball.fadetime = time+0.75;
			Func_oself(newball, ThinkFunc);
			
			if(newballcount)
				newball.mute = TRUE;
			newballcount++;
		}
	}
	
	e = list_ballchain;
	list_ballchain = world;
	while(e)
	{
		nexte = e.ballchain;
		e.ballchain = world;
		e = nexte;
	}
}

float ThunderBoltTrace(entity bolt, entity attacker, float damage, vector pos, vector ang) =
{
	local entity e;
	local vector diff1, endpos;
	local float posadjustment;
	
	if(bolt.shotvariant == BEAM_LIGHTNINGBOLT)
		posadjustment = -92;	
	
//	if(tagid)
//		pos = gettaginfo(attacker, tagid);//attacker.origin+'0 0 32'+v_forward*32;
/*	else
	{
		pos = attacker.origin+v_forward*60;
		pos_z += (attacker.maxs_z+attacker.mins_z)*0.5;
	}*/

//	ang_y = attacker.angles_y;
	makevectors(ang);
	
	pos += v_forward*posadjustment;
	
	attacker.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY;
	traceline(pos, pos+v_forward*(500+86), FALSE, attacker);
	attacker.dphitcontentsmask = 0;
	
	endpos = trace_endpos;
	
	bolt.hit = FALSE;
	
	if(trace_ent)
	if(CanDamage(attacker, trace_ent, world))
	{
		bolt.hit = trace_ent.id;
		
//		if(bolt.shotvariant == BEAM_THUNDERBOLT)
//		{
			e = findradius(trace_ent.origin, 512);
			while(e)
			{
				if(CanDamage(attacker, e, trace_ent))
				{
					diff1 = trace_ent.origin - e.origin;
					if(diff1*diff1 <= 512*512)
					{
						Damage(attacker, e, world, damage);
						if(bolt.shotvariant == BEAM_THUNDERBOLT)
						{
							if(!(e.flags & FL_ISBOSS))	
							{
								e.stuntime = 0;
								AddStunTime(e, 2);
							}
						}
						else
						if(bolt.shotvariant == BEAM_LIGHTNINGBOLT)
							AddWepDisableTime(trace_ent, 5*(frametime/0.3));
					}
				}
									
				e = e.chain;
			}
		
//			if(bolt.shotvariant == BEAM_THUNDERBOLT)
//				AddStunTime(e, 3*(frametime/0.3));
//			else
//			if(bolt.shotvariant == BEAM_LIGHTNINGBOLT)
//				AddWepDisableTime(trace_ent, 3*(frametime/0.3));
//		}
//		else
//		if(bolt.shotvariant == BEAM_LIGHTNINGBOLT)
//		if(!(attacker.class == CLASS_PLAYER && trace_ent.class == CLASS_PLAYER))
//			AddWepDisableTime(trace_ent, 3*(frametime/0.3));
		
//		Damage(attacker, trace_ent, damage);
	}
	
	return vlen(pos - endpos)-86;
}

void BoltThink(float WEP1, float WEP2, float duration, float cooldown) = 
{
	local entity ownerent;
	ownerent = self.owner;

	if(AttackFinished(ownerent, WEP1, WEP2, 1) - cooldown + duration <= time)
	{
		SH_RemoveEnt(self);
		return;
	}
	
	local float len, oldhit, posadjustment;
	local vector ang, org;
	
	if(WEP1 == WEP_LIGHTNING)
		posadjustment = -92;
	else
	if(WEP2 == WEP2_THUNDERBOLT)
		posadjustment = -16;
	
	oldhit = self.hit;
	
	ang_y = self.owner.angles_y;	

	makevectors(ang);		
	org = gettaginfo(self.owner, self.owner.shootfrom_index);	
	org += v_forward*posadjustment;	
	
	len = ThunderBoltTrace(self, self.owner, 20*(frametime/duration), org, ang);
	
	if(len != self.shotlen || ang != self.angles || org != self.origin)
	{
		setorigin(self, org);
		self.shotlen = len;
		self.angles = ang;		
		self.SendFlags = TRUE;
	}	
	
	self.nextthink = time+frametime;
}

void ThunderBoltThink() =	{	BoltThink(0, WEP2_THUNDERBOLT, 0.3, 3);		}

void FireThunderBolt() =
{
	local entity trace;
	local vector ang, org;
	
	trace = SpawnFloater();
	SetOwner(trace, self);//trace.owner = self;
	SetParent(trace, self);
	trace.class = CLASS_SHOT;
	trace.shotclass = SHOT_BEAM;
	trace.shotvariant = BEAM_THUNDERBOLT;
	SetAndPrecacheModel(trace, "null");
	
	trace.angles_y = self.angles_y;	
	makevectors(trace.angles);
	setorigin(trace, gettaginfo(self, self.shootfrom_index)+v_forward*-16);	
	
	trace.shotlen = ThunderBoltTrace(trace, self, 20*(frametime/0.3), trace.origin, ang);

	trace.SendEntity = SendBeam;
	trace.SendFlags = TRUE;
	trace.think = ThunderBoltThink;
	trace.nextthink = time+frametime;	
}

void MissileHitEffect() =	{		}

void MissileExplode(entity e) =	{	ProjectileTouch(e, SUB_Null, 100, 250);	}

void MissileTouch() =	{	MissileExplode(other);	}

void MissileThink() =
{
	local float diffA, lifetime;
	local vector diff1, diff2;
	
	lifetime = 5;
	
	if(!self.removetime)
		self.removetime = time + lifetime;

	if(ExpiredProjectile())
	{
		self.parent.attemptedhits = self.parent.attemptedhits + 1;
		SetAccuracy(self.parent);	
		MissileExplode(world);
	//	RemoveProjectile();
		return;
	}
		
	if(time > self.removetime - lifetime + 0.5)
	{
		local entity e, closesttarg;
		
		e = findradius(self.origin, 1000);
		while(e)
		{
			if(e.objclass == OBJ_NPC || e.class == CLASS_PLAYER)
			if(!(e.health <= 0))
			if(self.parent.team != e.team)
			if(CanDamage(self.parent, e, world))
			{
				diff1 = self.origin - e.origin;
				diff2 = self.origin - closesttarg.origin;
				if(!closesttarg || diff1*diff1 < diff2*diff2)
				{
					traceline(self.origin, e.origin+'0 0 32', TRUE, self);
					if(trace_fraction == 1)
						closesttarg = e;
				}
			}
			
			e = e.chain;
		}
			
		if(closesttarg)
		{
			diff1 = self.origin - closesttarg.origin;
			diffA = closesttarg.shieldscale*105.55;
			if(diff1*diff1 < diffA*diffA)
			{
				MissileExplode(closesttarg);
			//			RemoveProjectile();
				return;
			}	
			else
			{
				local vector ang;
				self.yaw_speed = 1.2;
				ang = vectoangles((closesttarg.origin+'0 0 32') - self.origin);
				self.angles_x = ang_x;
				self.ideal_yaw = ang_y;

			//	ang = self.angles;
			//	ang_x = ang_x*-1;
			//	makevectors(ang);
			//	self.velocity = v_forward*vlen(self.movespeed);
			}
		}
	}
	
	self.nextthink = time + SV_UPDATEDELAY;
	self.think = MissileThink;	
}

void FireMissiles() =
{
	local string modelname, tagnameL, tagnameR;
	local float vel_forward;
	local vector ang;
	local void() TouchFunc, ThinkFunc;
	
	modelname = "models/weapons/hmissile.dpm";
	ang_y = self.angles_y;
//	vel_forward = 500;
	TouchFunc = MissileTouch;
	ThinkFunc = MissileThink;

	if(self.owner.class == CLASS_PLAYER)
	{
		vel_forward = 500;
		tagnameL = "tag_hmissile.L";
		tagnameR = "tag_hmissile.R";
	}
	else
	{
		vel_forward = 600;
		tagnameL = "tag_shoot";
	}
		
	SpawnProjectileFromTag(modelname, ang, vel_forward, TouchFunc, SUB_Null, ThinkFunc, gettagindex(self, tagnameL), MOVETYPE_FLY, MF_ROCKET, PROJ_MISSILE, TRUE);	
	if(self.owner.class == CLASS_PLAYER)
	{
		SpawnProjectileFromTag(modelname, ang, vel_forward, TouchFunc, SUB_Null, ThinkFunc, gettagindex(self, tagnameR), MOVETYPE_FLY, MF_ROCKET, PROJ_MISSILE, TRUE);	
	
		shoot_missiles();
		SetEventFlag_Animation(self, ANIM_PLAYER_MISSILES);
	//	self.SendFlags = self.SendFlags | SFL_ANIM_SHOOT_MISSILES;
	}
}

void FireShockwave() =
{
	local vector projectileorg, ang, diff;
	local entity e;
	
	ang_y = self.angles_y;
	makevectors(ang);
	
	e = findradius(self.origin, 750);
	while(e)
	{
		if(e != self)
		{
			diff = e.origin - self.origin;
			if(diff*diff <= 750*750)
			if(e.shotvariant != PROJ_MIRV)
			if(e.shotclass == SHOT_PROJECTILE)
			{
				projectileorg = e.origin;
				projectileorg_z = self.origin_z;
				e.liberated = TRUE;	
				e.liberator = self;
				e.SendFlags = e.SendFlags | SFL_LIBERATE;
					
				if(e.shotvariant == PROJ_STORMSHIELD)
				{
					if(time - e.fadetime <= 0.75)
					{
				/*		if(e.owner != self)
						{
							SetOwner(e, world);//e.owner = world;
							SetParent(e, world);
						}*/
					
						e.velocity = normalize(projectileorg - self.origin)*vlen(e.velocity);
						ang = vectoangles(e.velocity);
						e.angles_y = ang_y;
						e.removetime = time+(1280/vlen(e.velocity));
						e.think = ProjectileThink_Default;
						e.touch = SpreadTouch;
						e.alpha = 1;
						e.fadetime = time+0.75;
						e.SendFlags = e.SendFlags | SFL_FADERESET | SFL_ORIGIN | SFL_ANGLES;					
					}
				}
				else
				{
				/*	if(e.owner != self)
					{
						SetOwner(e, world);//e.owner = world;
						SetParent(e, world);
					}*/
				
					e.think = ProjectileThink_Default;
					e.velocity = e.velocity + normalize(projectileorg - self.origin)*vlen(e.velocity)*2;
					ang = vectoangles(e.velocity);
					e.angles_y = ang_y;
					e.SendFlags = e.SendFlags | SFL_ORIGIN | SFL_ANGLES;
				}
			}
			else
			if(CanDamage(self, e, world))
			if(e.class == CLASS_PLAYER)
				AddStunTime(e, 2);
			else
			if(e.objclass == OBJ_NPC)
			if(!(e.flags & FL_ISBOSS))				
				AddStunTime(e, 5);
		}
	
		e = e.chain;
	}
	
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_SHOCKWAVE);
	WriteLong(MSG_BROADCAST, self.id);
}

void MiniMIRVHit(entity e) =	{	ProjectileTouch(e, SUB_Null, 50, 300);	}

void MiniMIRVTouch() =	{	MiniMIRVHit(other);		}

void MiniMIRVThink() =
{
	if(self.velocity == '0 0 0') // FIXME (this is a hack) if mirv missile has hit a target and has stopped then remove.
	{
		self.think = RemoveProjectile;
		self.nextthink = time + 0.1;		
		return;
	}

	local vector ang;
	if(NormalizeAngle(self.angles_x) > -135)
		self.angles_x -= random()*8+4.5;

	self.angles_y = AngleWander(self.angles_y, self.intendeddirection_y, 30);
	
	ang = self.angles;
	ang_x = -ang_x;
	makevectors(ang);
	self.velocity = v_forward*vlen(self.velocity);

	self.nextthink = time + 0.1;
	self.think = MiniMIRVThink;
}

void FireMiniMIRVs() =
{
	local string modelname;
	local float vel_forward, count, miniMIRVs, angrange;
	local vector ang, forwardang;
	local void() TouchFunc, HitFunc, ThinkFunc;	
	
	modelname = "models/weapons/rocket.dpm";
	vel_forward = 1000;
	TouchFunc = MiniMIRVTouch;
	HitFunc = MiniMIRVHit;
	ThinkFunc = MiniMIRVThink;		
	miniMIRVs = 15;
	
	angrange = 90;
	forwardang = self.angles;
	forwardang_x = -15;
			
	for(count = 0; count < miniMIRVs; count++)
	{
		ang = forwardang;
		ang_y = ang_y + angrange*0.5 - (angrange/miniMIRVs)*count;

		SpawnProjectile(modelname, ang, vel_forward, TouchFunc, HitFunc, ThinkFunc, self.origin, MOVETYPE_FLY, MF_ROCKET, PROJ_MINIMIRV, TRUE);
	}
}

void MIRVThink() =
{
	if(!self.removetime)
		self.removetime = time + 0.75;
		
	if(time >= self.removetime)
	{
		FireMiniMIRVs();
		RemoveProjectile();
		return;
	}

	self.nextthink = time + 0.1;
	self.think = MIRVThink;
}

void FireMIRV() =
{
	local string modelname;
	local float vel_forward;
	local vector ang;
	local void() TouchFunc, ThinkFunc;
	
	modelname = "models/weapons/mirv.dpm";
	ang_y = self.angles_y;
	ang_x = 60;
	vel_forward = 1500;
	TouchFunc = SUB_Null;
	ThinkFunc = MIRVThink;
	
	SpawnProjectileFromTag(modelname, ang, vel_forward, TouchFunc, SUB_Null, ThinkFunc, gettagindex(self, "tag_mirv"), MOVETYPE_TOSS, MF_ROCKET, PROJ_MIRV, TRUE);
	
	local vector smokevel;
	ang = self.angles;
	ang_x = 0;
	makevectors(ang);	
	smokevel = (v_forward+v_up)*-500;

	shoot_missiles();
	SetEventFlag_Animation(self, ANIM_PLAYER_MISSILES);
//	self.SendFlags = self.SendFlags | SFL_ANIM_SHOOT_MISSILES;
}

void LightningBoltThink() =	{	BoltThink(WEP_LIGHTNING, 0, 0.3, 2);		}

void FireLightning() =
{
	local entity trace;
	local vector ang, org;
	
	trace = SpawnFloater();
	SetOwner(trace, self);//trace.owner = self;
	SetParent(trace, self);
	trace.class = CLASS_SHOT;
	trace.shotclass = SHOT_BEAM;
	trace.shotvariant = BEAM_LIGHTNINGBOLT;
	SetAndPrecacheModel(trace, "null");
	
	trace.angles_y = self.angles_y;
	org = gettaginfo(self, self.shootfrom_index);	
	makevectors(trace.angles);
	org += v_forward*-92;
	setorigin(trace, org);
	
	trace.shotlen = ThunderBoltTrace(trace, self, 20*(frametime/0.3), org, ang);

	trace.SendEntity = SendBeam;
	trace.SendFlags = TRUE;
	trace.think = LightningBoltThink;
	trace.nextthink = time+frametime;	
}

void FireRepair() =
{
	self.owner.waittomovetime = time+2;
	FireBeamWeapon(BEAM_REPAIR, WEP_REPAIR, 0, 0);
}

void ResetWeaponStats() =
{
	local float count;
	
	for(count = 0; count <= 4; count++)
		self.(attack_finished[count]) = 0;

	self.globalcooldown = 0;
	self.wepdisabletime = 0;
	self.stuntime = 0;
//	self.rechargetimetotal_energy = 0;
//	self.rechargetimetotal_missile = 0;
}

float GetCoolDownID(float WEP1, float WEP2) = // PLAYER WEAPONS
{
	local float cdid;

	if(WEP1)
	switch(WEP1)
	{
		case WEP1_MINIGUN:			cdid = 0;	break;
		case WEP1_STORMPLOW:			cdid = 2;	break;
		case WEP1_BEAMCANNON:		cdid = 3;	break;
		case WEP1_ROCKETPOD:			cdid = 4;	break;
		
		default:					cdid = 0;	break;
	}
	
	if(WEP2)
	switch(WEP2)
	{
		case WEP2_FLACKGUN:			cdid = 0;	break;
		case WEP2_SHOCKWAVE:			cdid = 1;	break;
		case WEP2_STORMSPREAD:		cdid = 2;	break;
		case WEP2_STORMSHIELD:		cdid = 2;	break;
		case WEP2_THUNDERBOLT:		cdid = 3;	break;
		case WEP2_HOMINGMISSILES:	cdid = 4;	break;
		case WEP2_MIRVMORTAR:		cdid = 4;	break;
		
		default:					cdid = 0;	break;
	}	
	
	return cdid;
}

float AttackFinished(entity e, float WEP1, float WEP2, float weppriority) =
{
	local float cdid, cdtime;
	cdid = GetCoolDownID(WEP1, WEP2);
	if(e.class != CLASS_PLAYER && weppriority == 2)
		cdtime = e.secondarycooldown;
	else
		cdtime = e.(attack_finished[cdid]);
	return cdtime;
}

void SetAttackFinished(entity e, float WEP1, float WEP2, float cdtime, float weppriority) =
{
	if(e.objclass == OBJ_NPC)
		cdtime -= 0.01;

	float cdid;
	cdid = GetCoolDownID(WEP1, WEP2);
	if(e.class != CLASS_PLAYER && weppriority == 2)
		e.secondarycooldown = time+cdtime;
	else
		e.(attack_finished[cdid]) = time+cdtime;
}

void FireWeapon(float WEP1, float WEP2, float IGNORECOOLDOWN, float weppriority) =
{
	if(!WEP1 && !WEP2)
		return;

	if(self.class == CLASS_PLAYER)
	if(!self.items1 & WEP1)
	if(!self.items2 & WEP2)
		return;		

	if(!IGNORECOOLDOWN)
	if(AttackFinished(self, WEP1, WEP2, weppriority) > time
	|| (self.wepdisabletime > time && WEP1 != WEP1_MINIGUN && WEP2 != WEP2_FLACKGUN)
	|| (self.class == CLASS_PLAYER
		&& self.secondarycooldown > time
		&& (GetCoolDownID(WEP1, WEP2) == 2 || GetCoolDownID(WEP1, WEP2) == 3)))//(WEP == WEP_BEAMCANNON || WEP == WEP_SPREAD || WEP == WEP_THUNDERBOLT)))
		return;

	local float cooldown;//, COOLDOWN_ID;
	local vector e_firingrate, e_burstrate;
	local void() firefunc;

	if(self.class != CLASS_PLAYER
	&& weppriority == 2)
	{
		e_firingrate = self.secondaryfiringrate;
		e_burstrate = self.secondaryburstrate;
	}
	else
	{
		e_firingrate = self.firingrate;
		e_burstrate = self.burstrate;
	}	
	
//	COOLDOWN_ID = WEP;
	
	if(WEP1)
	switch(WEP1)
	{
		case WEP_PLASMA:	
		//	cooldown	= 0.25;
			firefunc	= FirePlasma;
			break;
			
		case WEP_PROTON:
			firefunc	= FireProton;
			break;
			
		case WEP_PROTON_MED:
			firefunc	= FireProton_Med;
			break;			

		case WEP1_MINIGUN:
			cooldown		= 0.1;
		//	self.rechargetime_minigun = time + cooldown;
			firefunc		= FireMiniguns;
			break;
	
		case WEP_DESTROYERBEAM:
			cooldown		= 2;
			firefunc		= FireDestroyerBeam;
			break;
	
		case WEP1_BEAMCANNON:
			cooldown		= 2;
		//	self.rechargetime_beam = time + cooldown;
			firefunc		= FireBeamCannon;
			break;

		case WEP_TURRETBEAM:
			cooldown		= 3;
			firefunc		= FireTurretBeam;
			break;
			
		case WEP1_STORMPLOW:
			cooldown		= 0.125; // FIXME recharge bar on hud doesn't know this
			firefunc		= FireEnergyWep_Blaster;
		//	self.rechargetime_spread = time + cooldown;
			break;

		case WEP1_ROCKETPOD:
			cooldown		= 2;
			if(!IGNORECOOLDOWN)
				SetAttackFinished(self, WEP1_ROCKETPOD, 0, 999, weppriority);
			//	self.rechargetime_powerup = time + 999;
			firefunc		= FireRockets;
			break;
			
		case WEP_HMISSILES:
			cooldown 		= 1;
			firefunc		= FireMissiles;
			break;				
			
		case WEP_LIGHTNING:
			cooldown		= 2;
			firefunc		= FireLightning;
			break;
			
		case WEP_REPAIR:
			cooldown		= 3;
			firefunc		= FireRepair;
			break;
	}

	if(WEP2)
	switch(WEP2)
	{
		case WEP2_FLACKGUN:
			cooldown		= 0.3;
		//	self.rechargetime_minigun = time + cooldown;
			firefunc		= FireFlackGuns;//FireMiniguns;
			break;
			
		case WEP2_STORMSPREAD:
			cooldown		= 0.3;
			firefunc		= FireSpread;
		//	self.rechargetime_spread = time + cooldown;
			break;

		case WEP2_STORMSHIELD:
			cooldown		= 0.3;
			firefunc		= FireSpread_Circle;
		//	self.rechargetime_spread = time + cooldown;
			break;
		
		case WEP2_THUNDERBOLT:
			cooldown		= 3;
		//	self.rechargetime_thunderbolt = time + cooldown;
			firefunc		= FireThunderBolt;
			break;
			
		case WEP2_SHOCKWAVE:
			cooldown		= /*scooldown =*/ 4;
		//	self.rechargetime_shockwave = time + cooldown;
			firefunc		= FireShockwave;
			break;

		case WEP2_HOMINGMISSILES:
			cooldown 		= 1;
		//	self.rechargetime_powerup = time + cooldown;
			firefunc		= FireMissiles;
			break;		

		case WEP2_MIRVMORTAR:
			cooldown		= 3;
		//	self.rechargetime_powerup = time + cooldown;
			firefunc		= FireMIRV;
			break;		
	}	
	
	if(self.objclass == OBJ_NPC)
	{
		if(self.firingrate_z)
			self.burstcount++;

		if(self.burstcount >= self.firingrate_z)
		{
			self.burstcount = 0;
			cooldown = random()*(e_firingrate_y-e_firingrate_x)+e_firingrate_x;
		}
		else
			cooldown = random()*(e_burstrate_y-e_burstrate_x)+e_burstrate_x;
	}
	
	if(!IGNORECOOLDOWN)
	{
//		self.(attack_finished[COOLDOWN_ID]) = time + cooldown;
		SetAttackFinished(self, WEP1, WEP2, cooldown, weppriority);
	//	if(self.class == CLASS_PLAYER)
	//	if(scooldown)
	//		self.secondarycooldown = time+scooldown*0.5;
	}

	firefunc();
	
	if(weppriority == 1)
	if(IsAssignedFunction(self.WepReleaseFunc))
		self.wepreleasetime = time;
}