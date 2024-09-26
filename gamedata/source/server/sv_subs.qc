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
void PacifyCompiler_Server() =
{
	local entity e;
	
		e.th_stand = e.th_stand;
		e.th_walk = e.th_walk;
		e.th_run = e.th_run;
		e.th_pain = e.th_pain;
		e.th_die = e.th_die;
		e.th_missile = e.th_missile;
		e.th_melee = e.th_melee;
	
		activator = activator;
		
		e.wad = e.wad;
		e.map = e.map;
		e.worldtype = e.worldtype;
		e.delay = e.delay;
		e.wait = e.wait;
		e.lip = e.lip;
		e.speed = e.speed;
		e.skill = e.skill;
		e.killtarget = e.killtarget;
		e.pos1 = e.pos1;
		e.pos2 = e.pos2;
		e.mangle = e.mangle;
		
	//	e.parent = e.parent;
		e.attack_finished = e.attack_finished;
	//	e.cellconnection = e.cellconnection;
		
		e.cellpath = e.cellpath;
	
	remove(e);
}

/*float IsTimeToRemove(entity e) =
{
	if(time >= e.removetime)
	{
		e.nextthink = time + 0.01;
		e.think = SUB_Remove;
		return TRUE;
	}	
	
	return FALSE;
}*/

void SetPermanentID(entity e) = // THIS IS TOO SLOW!!!
{
	if(e.class != CLASS_OBJECT)
		return;

	if(e.entid > 0)
		return;

	local entity otherent;
	local float count, newentid, taken;

//	if(e.objclass == OBJ_TRAIN)
//	{
//		e.entid = e.id;
//		return;
//	}
	
	for(count = 1; e.entid <= 0; count++)
	{
		taken = FALSE;
		for(otherent = list_objectchain; otherent; otherent = otherent.objectchain)
		{
			if(otherent.entid == count)
			{
				taken = TRUE;
				break;
			}
		}
		
		if(!taken)
		{
			e.entid = count;
			return;
		}
	}
}

void SetID(entity e) =
{
	if(e.id)
		return;

	totalentities++;
	e.id = totalentities;
	
	SetPermanentID(e);		
}

entity SpawnEnt() =
{
	local entity e;
	e = spawn();
	SetID(e);
	return e;
}

float AngleWander(float ang, float intendedang, float maxwander) =
{
	ang += maxwander - random()*maxwander*2;
	if(ang > intendedang + maxwander)
		ang = intendedang + maxwander;
	if(ang < intendedang - maxwander)
		ang = intendedang - maxwander;
		
	return ang;
}

void PlaySound(entity noisyent, float CHANNEL, string soundfile) =
{
	sound(noisyent, CHANNEL, soundfile, 1, ATTN_NORM);
//	if(noisyent.class == CLASS_PLAYER)
//		AlertAI_audio(noisyent);
}

void Animate() =
{
	if(self.frame1time <= time)
		self.AnimFunc();
}

float IsBaseEnt(entity e) =
{
	if(!e.spawnedfrom && !e.spawnedfromtag && e.owner == e)
		return TRUE;
		
	return FALSE;
}

void MakeObjectInvisibleToClients(entity e) =
{
	if(adminmodeactive)
		SetAndPrecacheModel(e, "null");
	else
		SetAndPrecacheModel(e, "");
		
//	e.SendFlags = e.SendFlags | SFL_HIDE;
	e.onlydrawforadmins = TRUE;
}

float GetTE_CenterPrint_MSG_TYPE(entity e) =
{
	local float MSG_TYPE;

	if(e)
	{
		MSG_TYPE = MSG_ONE;
		msg_entity = e;		
	}
	else
		MSG_TYPE = MSG_ALL;
		
	return MSG_TYPE;
}

void TE_CenterPrint(entity e, float msgid) =
{
	local float MSG_TYPE;
	MSG_TYPE = GetTE_CenterPrint_MSG_TYPE(e);	

	WriteByte(MSG_TYPE, SVC_TEMPENTITY);
	WriteByte(MSG_TYPE, TE_CENTERPRINT);
	WriteByte(MSG_TYPE, msgid);
}

void TE_CenterPrint_ExtendedInfo_Flag(entity e, string name, float t) =
{
	local float MSG_TYPE;
	MSG_TYPE = GetTE_CenterPrint_MSG_TYPE(e);	
		
	WriteString(MSG_TYPE, name);
	WriteLong(MSG_TYPE, t);
}