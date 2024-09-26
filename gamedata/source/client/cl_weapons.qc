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
void ShieldThink() =
{
	self.alpha = ((self.borntime+0.25) - time)/0.25;

	if(self.alpha <= 0 || !self.tag_entity)
		SH_RemoveEnt(self);
	else
		self.nextthink = time+0.05;	
}

.float	spawnedshields;
.float	hitsoundtime;
entity SpawnShieldEffect(entity shield, entity hit_ent) =
{
	if(hit_ent.hitsoundtime < time)
	{
		if(hit_ent == player)
			pointsound(hit_ent.origin, "sounds/player/ss_player_hit.wav", 1, ATTN_NORM);
		else
			pointsound(hit_ent.origin, "sounds/enemies/ss_enemy_hit.wav", 1, ATTN_NORM);
		hit_ent.hitsoundtime = time+0.1;
	}

	if(!shield)
	{
		shield = spawn();
		SetAndPrecacheModel(shield, "models/weapons/impact_sphere.dpm");
		shield.scale = hit_ent.shieldscale;
		shield.drawmask = MASK_NORMAL;
		Attach(shield, hit_ent, 0);	
	}
	
	return shield;
}

void OrientShieldEffect(entity shield, entity hit_ent, vector hitorg) =
{
	shield.borntime = time;	
	shield.angles = vectoangles(hitorg - (hit_ent.origin)) - hit_ent.angles; 
	shield.angles_z = random()*360;
	shield.alpha = 1;
	shield.think = ShieldThink;
	shield.nextthink = time+0.1;	
}

vector DrawDirectShieldEffect(vector hitorg, entity projectileent, vector ang, entity hit_ent) =
{
	local vector linestart, circlecenter;
	local float d, circlecenter_dir_dp, rad;

	makevectors(ang);	
	
	rad = hit_ent.shieldscale*105.55;
	linestart = hitorg - v_forward*(rad+1);
	circlecenter = hit_ent.origin - linestart;
	circlecenter_dir_dp = v_forward * circlecenter;
	d = circlecenter_dir_dp - sqrt(circlecenter_dir_dp*circlecenter_dir_dp - circlecenter*circlecenter + rad*rad);
	
	hitorg = linestart + v_forward*d;
	
	if(!projectileent.spawnedshields || projectileent.shotclass == SHOT_BULLET)
		projectileent.shieldent = SpawnShieldEffect(projectileent.shieldent, hit_ent);

	OrientShieldEffect(projectileent.shieldent, hit_ent, hitorg);
	
	return hitorg;
}

void DrawIndirectShieldEffect(vector hitorg, entity hit_ent) =
{
	local entity shield;
	shield = SpawnShieldEffect(world, hit_ent);
	OrientShieldEffect(shield, hit_ent, hitorg);
}

void DrawBulletTraces(entity e) =
{
	local float count, tracespeed, traceeffect, llev;
	local vector origionalstart, end, start, diff1, diff2;
	
	if(e.shotvariant == BULL_FLACKGUN_PLAYER)
	{
		tracespeed = 6000;
		traceeffect = PEF_FLACKGUN_TRACE;
	}
	else
	if(e.shotvariant == BULL_MINIGUN_PLAYER)
	{
		tracespeed = 3000;
		traceeffect = PEF_MINIGUN_TRACE;	
	}
	else
	if(e.shotvariant == BULL_MINIGUN_HEAVY)
	{
		tracespeed = 3000;
		traceeffect = PEF_HEAVYTANK_MINIGUN_TRACE;		
	}
	
//	for(count = 0; count < 2; count++)
//	{
		origionalstart = e.origin;//(org_start[count]);
		end = e.org_end;//[count]);
		start = origionalstart + normalize(end - origionalstart)*((time-e.borntime)*tracespeed);
		
		diff1 = origionalstart - start;
		diff2 = origionalstart - end;
		if(e.drawtime+0.2 > time && diff1*diff1 <= diff2*diff2)
			trailparticles(e, traceeffect, start, end);	
//	}
}

void DrawThunderBoltPolygon(vector start, vector end, float maxlen, string texturename) =
{
	local vector texturesize, top_left, top_right;
	local float subdist;
	
	texturesize = drawgetimagesize(texturename);
	texturesize = texturesize*(maxlen/texturesize_y);

	if(maxlen)
		subdist = vlen(start-end)/maxlen;
	
	top_left_y = top_right_y = 1 - subdist;
	top_right_x = 1;
	
	makevectors(vectoangles(end-start));

	R_BeginPolygon(texturename, DRAWFLAG_NORMAL);
	R_PolygonVertex(end+v_right*-texturesize_x*0.5, top_left, '1 1 1', 1);	
	R_PolygonVertex(end+v_right*texturesize_x*0.5, top_right, '1 1 1', 1);
	R_PolygonVertex(start+v_right*texturesize_x*0.5, '1 1 0', '1 1 1', 1);
	R_PolygonVertex(start+v_right*-texturesize_x*0.5, '0 1 0', '1 1 1', 1);
	R_EndPolygon();	
}

void DrawThunderBoltEffect(entity e, vector start, vector end, string imagename) =
{
	imagename = strcat(imagename, ftos(e.frame));
	imagename = strcat(imagename, ".tga");

	DrawThunderBoltPolygon(start, end, 500, imagename);
	
	if(effectdrawtime <= time)
	if(e.hitent)
		pointparticles(PEF_THUNDERBOLT_HIT, end, normalize(start-end), 1);
}

void DrawBolt(entity e, string bolt_start_imgname, string bolt_end_imgname, float extraimagespace, float boltextension, float EFFECT) =
{
	local vector diff, start, end, ang, thunderbolt_start_imgsize;
	local entity spreadtoent;
	local float bolt_ofs, extension;

	if(e.frame1time < time)
	{
		if(e.frame1time)
			e.frame = bound(0, floor(random()*3), 2);
			
		e.frame1time = time + 0.02;	
	}
	
	bolt_ofs = 32;
	bolt_start_imgname = strcat(bolt_start_imgname, ftos(e.frame));
	bolt_start_imgname = strcat(bolt_start_imgname, ".tga");
	thunderbolt_start_imgsize = drawgetimagesize(bolt_start_imgname);

	ang_y = e.angles_y;
	makevectors(ang);
	
	start = e.origin;//+'0 0 32'+v_forward*bolt_ofs;
//	if(e.hitent)
//		extension = e.hitent.maxs_x;
	
	e.(org_start[0]) = start+v_forward*(thunderbolt_start_imgsize_y-extraimagespace);
	end = e.(org_start[0]) + v_forward*(e.shotlen+extension+boltextension);
	
	if(e.hitent)
	if(e.hitent.shieldscale)
		end = DrawDirectShieldEffect(end, e, e.angles, e.hitent);	
		
	makevectors(ang);
	pointparticles(PEF_THUNDERBOLT_MUZZLEFLASH, e.(org_start[0]), v_forward, 1);
	DrawThunderBoltPolygon(start, start+v_forward*thunderbolt_start_imgsize_y, thunderbolt_start_imgsize_y, bolt_start_imgname);
	DrawThunderBoltEffect(e, e.(org_start[0]), end, bolt_end_imgname);

	e.list_childchain.origin = end+v_forward*-48;
	
	if(effectdrawtime <= time)
//	if(e.hitent || e.shotlen < 586)
		pointparticles(EFFECT, end, normalize(start-end), 1);
	
	if(!CanDamage(e.owner, e.hitent, world))
		return;
		
//	spreadtoent = list_aichain;
	spreadtoent = findradius(e.hitent.origin, 512);
	while(spreadtoent)
	{
		diff = e.hitent.origin - spreadtoent.origin;
	
		if(diff*diff <= 512*512)
		if(CanDamage(e.owner, spreadtoent, e.hitent))
		{
			start = e.hitent.origin;
			start_z += e.hitent.mins_z + (e.hitent.maxs_z - e.hitent.mins_z)*0.5;
			end = spreadtoent.origin;
			end_z += e.hitent.mins_z+ (spreadtoent.maxs_z - spreadtoent.mins_z)*0.5;
			DrawThunderBoltEffect(e, start, end, bolt_end_imgname);	
		}

		spreadtoent = spreadtoent.chain;//aichain;
	}
}

void DrawThunderBolt(entity e) =	{	DrawBolt(e, "gfx/weapons/thunderbolt_start", "gfx/weapons/thunderbolt", 1, 0, PEF_THUNDERBOLT_HIT);	}

void DrawLightningBolt(entity e) =	{	DrawBolt(e, "gfx/weapons/lt_bolt", "gfx/weapons/lt_thunderbolt", 28, 0, PEF_LIGHTNINGBOLT_HIT);	}

void DrawRepairBeam(entity e) =
{
	local vector end, ang;

/*	if(e.owner.class == CLASS_PLAYER)
		e.(org_start[0]) = gettaginfo(e.owner, TAG_CANNON_R);
	else
		e.(org_start[0]) = gettaginfo(e.owner, gettagindex(e.owner, "tag_shoot"));
		
	ang_x = e.angles_x;	
	ang_y = e.owner.angles_y;*/
	
	ang = e.angles;
	
//	if(IsAttachedAIClass(e.owner.npcclass))// == NPC_TURRET)
//		ang_y += e.owner.owner.angles_y;	
	
	makevectors(ang);

	traceline(e.origin, e.origin + v_forward*e.shotlen, TRUE, e.owner);
	end = trace_endpos;
	
	e.list_childchain.origin = end+v_forward*-48;	
	
	trailparticles(e, PEF_REPAIR_TRACE, e.origin, end);
	
	if(effectdrawtime > time)
		return;	

	makevectors(ang);
	pointparticles(PEF_REPAIR_MUZZLEFLASH, e.origin, v_forward, 1);
	pointparticles(PEF_REPAIR_HIT, end, v_forward*-1, 1);		
		
}

void DrawBeamWeapon(entity e, float TRACE, float MUZZLEFLASH, float HIT, float SMOKE) =
{
	local vector end, ang;

//	if(e.owner.class == CLASS_PLAYER)
//		e.(org_start[0]) = gettaginfo(e.owner, TAG_CANNON_R);
//	else
//		e.(org_start[0]) = gettaginfo(e.owner, gettagindex(e.owner, "tag_shoot"));
		
//	ang_x = e.angles_x;	
//	ang_y = e.owner.angles_y;
	
	ang = e.angles;
	
//	if(IsAttachedAIClass(e.owner.npcclass))// == NPC_TURRET)
//		ang_y += e.owner.owner.angles_y;	
	
	makevectors(ang);

	traceline(e.origin, e.origin + v_forward*e.shotlen, TRUE, e.owner);
	end = trace_endpos;
	
	if(e.hitent)
	if(e.hitent.shieldscale)
	if(!e.hitent.isdead)
	{
	//	local float dist;
	//	dist = vlen(e.origin - end);
		end = DrawDirectShieldEffect(end, e, e.angles, e.hitent);	
	}

	makevectors(ang);	
	trailparticles(e, TRACE, e.origin+v_forward*32, end);
	
	e.list_childchain.origin = end+v_forward*-48;
	
	if(effectdrawtime > time)
		return;		

	makevectors(ang);
	pointparticles(MUZZLEFLASH, e.origin, v_forward, 1);
	pointparticles(HIT, end, v_forward*-1, 1);
	if(SMOKE)
		pointparticles(SMOKE, end, v_forward*-1, 1);
}

.vector lastsmokepos;
void DrawMissileTrail(entity e) =
{
	if(effectdrawtime > time)
		return;

	local vector ang;
	ang = e.angles;
	ang_x = ang_x*-1;
	makevectors(ang);
	pointparticles(PEF_MISSILE_EXHAUST, e.origin, v_forward*-1, 1);
		
	if(time > e.borntime+0.1)
		ParticleTrail(e, PEF_MISSILE_SMOKE, e.origin+v_forward*-64, lastsmokepos);
	e.lastsmokepos = e.origin+v_forward*-64;
}

void Spread_CircleThink() =
{
	local vector org, ang;
	local float updateinterval;	

	updateinterval = frametime;//SV_UPDATEDELAY;
	
	self.velocity = '0 0 0';
	
//	if(frametime)
//	{
//	org = self.owner.owner.origin;
//	org_z += (self.owner.maxs_z+self.owner.mins_z)*0.5;//self.owner.owner.mins_z + (self.owner.owner.maxs_z - self.owner.owner.mins_z)*0.75;

		ang_y = (self.owner.angles_y+self.ballnum*(360/6)*2)*self.direction;

		org = self.owner.owner.origin;// + (self.owner.owner.origin - self.owner.owner.oldorigin)*updateinterval;
//	org_z += self.owner.owner.mins_z + (self.owner.owner.maxs_z - self.owner.owner.mins_z)*0.5;
		org_z += (self.owner.owner.maxs_z+self.owner.owner.mins_z)*0.75;
		
		makevectors(ang);
		org += v_forward*(250+(self.direction*15));
		setorigin(self, org);
	//	self.velocity = normalize(org - self.origin)*vlen(org - self.origin)*(1/updateinterval);
		
	//	ang = vectoangles(self.velocity);
		self.angles_y = ang_y + 115*self.direction;
//	self.colormod = '1 0 0';
//	self.oldyaw = self.newyaw;
//	self.newyaw = ang_y;
//	}
	
//	if(frametime)
		self.nextthink = time;//+= frametime;
//	else
//		self.nextthink = time + frametime;
	self.think = Spread_CircleThink;
}

void DrawEnergyBallFade(entity e) =
{
	if(frametime)
	if(e.fadetime)
	if(time >= e.fadetime)
		e.alpha -= 1/(0.75/frametime);
}

void DrawShots() =
{
	local entity e;

	e = list_shotchain;
	while(e)
	{
		if(e.shotclass == SHOT_PROJECTILE)
		{
			if(e.shotvariant == PROJ_STORMSHIELD)
				DrawEnergyBallFade(e);
			else
			if(e.shotvariant == PROJ_MISSILE || e.shotvariant == PROJ_ROCKET || e.shotvariant == PROJ_MIRV || e.shotvariant == PROJ_MINIMIRV)
				DrawMissileTrail(e);
				
			if(!e.mobile)
				setorigin(e, e.origin+e.velocity*frametime);
		}
		else
		if(e.shotclass == SHOT_BULLET)
			DrawBulletTraces(e);
		else
		if(e.shotclass == SHOT_BEAM)
		{
			if(e.shotvariant == BEAM_DESTROYERBEAM)
				DrawBeamWeapon(e, PEF_DESTROYERBEAM_TRACE, PEF_DESTROYERBEAM_MUZZLEFLASH, PEF_DESTROYERBEAM_HIT, FALSE);
			else
			if(e.shotvariant == BEAM_CANNON)
				DrawBeamWeapon(e, PEF_BEAMCANNON_TRACE, PEF_BEAMCANNON_MUZZLEFLASH, PEF_BEAMCANNON_HIT, FALSE);
			else
			if(e.shotvariant == BEAM_TURRETBEAM)
				DrawBeamWeapon(e, PEF_TURRETBEAM_TRACE, PEF_TURRETBEAM_MUZZLEFLASH, PEF_TURRETBEAM_HIT, PEF_TURRETBEAM_SMOKE);
			else
			if(e.shotvariant == BEAM_THUNDERBOLT)
				DrawThunderBolt(e);
			else
			if(e.shotvariant == BEAM_LIGHTNINGBOLT)
				DrawLightningBolt(e);
			else
			if(e.shotvariant == BEAM_REPAIR)
				DrawRepairBeam(e);
		}
		e = e.shotchain;
	}
}

void Shockwave() =
{
	local float ownerid;
	local entity ownerent;
	local string soundname;
	
	ownerid = ReadLong();
	ownerent = GetLinkedListEnt_float(list_canshootchain, canshootchain, id, ownerid);//findfloat(world, id, ownerid);
	
	pointparticles(PEF_SHOCKWAVE, ownerent.origin+'0 0 32', '0 0 1', 1);
	
	if(ownerent.class == CLASS_PLAYER)
		soundname = "sounds/weapons/shockwave/ss_ship_shockwave.wav";
	else
	if(ownerent.objclass == OBJ_NPC)
		soundname = "sounds/weapons/shockwave/ss_boss_shockwave.wav";
	
	pointsound(ownerent.origin, soundname , 1, ATTN_NORM);
}