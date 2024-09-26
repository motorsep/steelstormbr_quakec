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
void ParticleTrail(entity e, float EFFECT, vector start, .vector end) =
{
	if(e.end == '0 0 0')
		e.end = start;
	trailparticles(e, EFFECT, start, e.end);
	e.end = start;
}

void SetChargeEffectStats(float e_chargeeffect, float e_chargeeffect2, float e_riftscale) =
{
	self.chargeeffect			= e_chargeeffect;
	self.chargeeffect2			= e_chargeeffect2;
	self.riftscale				= e_riftscale;		
}

.float	bodysoundtime;
.float	lastbodysound;

void SilenceBodySound() =
{
	if(!self.bodysoundtime)
		return;
		
	self.bodysoundtime = 0;
	sound(self, CHAN_BODY, "sounds/null.wav", 1, ATTN_NORM);
}

void PlayEngineSounds(string soundname_idle, string soundname_move) =
{
	local float soundlen;
	local string soundname;

	if(self.velocity*self.velocity >= 300*300)
	{
		soundname = soundname_move;
		if(self.lastbodysound == 1)
			self.bodysoundtime = 0;
		self.lastbodysound = 0;
	}
	else
	{
		soundname = soundname_idle;
		if(self.lastbodysound == 0)
			self.bodysoundtime = 0;
		self.lastbodysound = 1;
	}

	if(self.bodysoundtime <= time)
	{
		soundlen = soundlength(soundname);
		self.bodysoundtime = time+soundlen;
		sound(self, CHAN_BODY, soundname, 1, ATTN_NORM);	
	}
}

void PlayRotationSound(string soundname, float soundlen) =
{
	if(self.newyaw == self.oldyaw)
	{
		SilenceBodySound();
		return;
	}

	if(self.bodysoundtime <= time)
	{
		self.bodysoundtime = time+soundlen;
		sound(self, CHAN_BODY, soundname, 1, ATTN_NORM);	
	}
}

float CanPlayEffects() =
{
	if(self.isdead)
	{
		SilenceBodySound();
		return false;
	}

	return true;
}

void Effects_Player() =
{
	if(effectdrawtime > time)
		return;
		
	local vector pos, vel;
	local float j_effect;
	local string soundname;

	if(!self.hashealth)
		return;
	
	if(!CanPlayEffects())
		return;
	
	if(self.velocity*self.velocity >= 300*300)
		j_effect = PEF_JETS_MOBILE;
	else
		j_effect = PEF_JETS_IDLE;

	makevectors(self.angles);
	vel = normalize(v_forward)*-1;		
		
	pos = gettaginfo(self, TAG_JET_R);
	pointparticles(j_effect, pos, vel, 1);
		
	pos = gettaginfo(self, TAG_JET_L);
	pointparticles(j_effect, pos, vel, 1);

	PlayEngineSounds("sounds/player/ss_ship_idle.wav", "sounds/player/ss_ship_move.wav");
}

void Effects_NPC_LightTank() =
{
	if(!CanPlayEffects())
		return;
	
	if(!self.chargeeffect)
		SetChargeEffectStats(PEF_SPAWNCHARGE_SMALL, PEF_SPAWNCHARGE_SMALL_EXPLODE, 0.74);		
		
	PlayEngineSounds("sounds/enemies/light_tank/ss_lighttank_idle.wav", "sounds/enemies/light_tank/ss_lighttank_move.wav");
}

void Effects_NPC_MediumTank() =
{
	if(!CanPlayEffects())
		return;
	
	if(!self.chargeeffect)
		SetChargeEffectStats(PEF_SPAWNCHARGE_SMALL, PEF_SPAWNCHARGE_SMALL_EXPLODE, 0.74);
	
	PlayEngineSounds("sounds/enemies/medium_tank/ss_medtank_idle.wav", "sounds/enemies/medium_tank/ss_medtank_move.wav");
}

void Effects_NPC_HeavyTank() =
{
	if(!CanPlayEffects())
		return;
	
	if(!self.chargeeffect)
		SetChargeEffectStats(PEF_SPAWNCHARGE_MEDIUM, PEF_SPAWNCHARGE_MEDIUM_EXPLODE, 1);	

	PlayEngineSounds("sounds/enemies/heavy_tank/ss_heavytank_idle.wav", "sounds/enemies/heavy_tank/ss_heavytank_move.wav");
}

void Effects_NPC_LightningTank() =
{
	if(!CanPlayEffects())
		return;
	
	if(!self.chargeeffect)
		SetChargeEffectStats(PEF_SPAWNCHARGE_SMALL, PEF_SPAWNCHARGE_SMALL_EXPLODE, 0.74);	

//	PlayEngineSounds("sounds/enemies/heavy_tank/ss_heavytank_idle.wav", 2.73, "sounds/enemies/heavy_tank/ss_heavytank_move.wav", 2.82);
}

void Effects_NPC_MicroFlyer() =
{
	if(!CanPlayEffects())
		return;
		
	PlayEngineSounds("sounds/null.wav", "sounds/enemies/carrier/ss_flier_flying.wav");		
}

void Effects_NPC_CarrierTank() =
{
	if(!CanPlayEffects())
		return;
		
	PlayEngineSounds("sounds/enemies/carrier/ss_carrier_idle.wav", "sounds/enemies/carrier/ss_carrier_move.wav");		
}

void Effects_NPC_DestroyerTank() =
{
	if(!CanPlayEffects())
		return;
		
	PlayEngineSounds("sounds/enemies/destroyer/ss_destroyer_idle.wav", "sounds/enemies/destroyer/ss_destroyer_move.wav");	
}

void Effects_NPC_Turret_Generic() =
{
	if(!CanPlayEffects())
		return;

	if(!self.chargeeffect)
		SetChargeEffectStats(PEF_SPAWNCHARGE_SMALL, PEF_SPAWNCHARGE_SMALL_EXPLODE, 0.74);		
}

void Effects_NPC_HeavyTank_TurretHead() =
{
	if(!CanPlayEffects())
		return;

	PlayRotationSound("sounds/enemies/heavy_tank/ss_heavytank_turr_rot.wav", 1.03);
}

void Effects_NPC_TurretHead_Plasma() =
{
	if(!CanPlayEffects())
		return;

	PlayRotationSound("sounds/enemies/light_plasma_turret/ss_lightturr_rot.wav", 0.98);
}

void Effects_NPC_TurretHead_Beam() =
{
	if(!CanPlayEffects())
		return;

	PlayRotationSound("sounds/enemies/heavy_beam_turret/ss_heavybeam_rot.wav", 1.01);
}