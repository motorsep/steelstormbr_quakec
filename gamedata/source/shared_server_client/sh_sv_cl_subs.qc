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
void PacifyCompiler_Shared() =
{
	local entity e;
	local string s;
	local float f;
	local vector v;
	
	e = spawn();
	e.shotlen = 0;
	
	//START DPEXTENSIONS
		e.disableclientprediction	= e.disableclientprediction;
		e.buttonchat				= e.buttonchat;
		e.buttonuse					= e.buttonuse;
		e.colormod					= e.colormod;
		e.exteriormodeltoclient		= e.exteriormodeltoclient;
		e.glow_color				= e.glow_color;
		e.glow_size					= e.glow_size;
		e.glow_trail				= e.glow_trail;
		e.viewmodelforclient		= e.viewmodelforclient;
		e.button3					= e.button3;
		e.button4					= e.button4;
		e.button5					= e.button5;
		e.button6					= e.button6;
		e.button7					= e.button7;
		e.button8					= e.button8;
		e.idealpitch				= e.idealpitch;
		e.pitch_speed				= e.pitch_speed;
		f							= gettaginfo_parent;
		s							= gettaginfo_name;
		v							= gettaginfo_offset;
		v							= gettaginfo_forward;
		v							= gettaginfo_right;
		v							= gettaginfo_up;
		e.clientcolors				= e.clientcolors;
		e.customizeentityforclient	= e.customizeentityforclient;
		e.drawonlytoclient			= e.drawonlytoclient;
		e.contentstransition		= e.contentstransition;
		e.movetypesteplandevent		= e.movetypesteplandevent;
		e.modelflags				= e.modelflags;
		e.netaddress				= e.netaddress;
		e.nodrawtoclient			= e.nodrawtoclient;
		e.ping						= e.ping;
		e.punchvector				= e.punchvector;
		e.movement					= e.movement;
		s							= worldstatus;
		e.clientstatus				= e.clientstatus;
		e.dphitcontentsmask			= e.dphitcontentsmask;
		f							= trace_dpstartcontents;
		f							= trace_dphitcontents;
		f							= trace_dphitq3surfaceflags;
		s							= trace_dphittexturename;
		e.viewzoom					= e.viewzoom;
		e.playermodel				= e.playermodel;
		e.playerskin				= e.playerskin;
		e.cursor_active				= e.cursor_active;
		e.cursor_screen				= e.cursor_screen;
		e.cursor_trace_start		= e.cursor_trace_start;
		e.cursor_trace_endpos		= e.cursor_trace_endpos;
		e.cursor_trace_ent			= e.cursor_trace_ent;
		e.light_lev					= e.light_lev;
		e.color						= e.color;
		e.style						= e.style;
		e.pflags					= e.pflags;
	//END DPEXTENSIONS
	
	remove(e);
}

/*string zonecpy(string dst, string src) = // if dst is not null or zoned, this will cause errors
{
	local string s;

	if(src != string_null)
		s = strzone(src);
	
	if(dst != string_null)
		strunzone(dst);

	return s;
}

string freezone(string s) = // if s is not null or zoned, this will cause errors
{
	if(s != string_null)
		strunzone(s);
	
	s = string_null;
	
	return s;
}*/

/*float IsAssignedFunction(void() func) =
{
	if(func && func != SUB_Null)
		return TRUE;
		
	return FALSE;
}*/

/*entity UpdateLinkedList(.float field, float match, .entity entchain) =
{
	local entity list, e;
	list = e = findchainfloat(field, match);
	while(e)
	{
		e.entchain = e.chain;
		e = e.chain;
	}
	
	return list;
}

entity UpdateLinkedEntList(.entity field, entity match, .entity entchain) =
{
	local entity list, e;
	list = e = findchainentity(field, match);
	while(e)
	{
		e.entchain = e.chain;
		e = e.chain;
	}
	
	return list;
}*/

/*entity UpdateLinkedList(.float field, float match, .entity entchain) =
{
	local entity list, e, laste;
	e = list_notcellchain;
	while(e)
	{
		if(e.field == match)
		{
			if(laste)
				laste.entchain = e;
			else
				list = e;
				
			laste = e;
		}
			
		e = e.notcellchain;
	}
	
	return list;
}*/

/*entity UpdateLinkedEntList(.entity field, entity match, .entity entchain) =
{
	local entity list, e, laste;
	e = list_notcellchain;
	while(e)
	{
		if(e.field == match)
		{
			if(laste)
				laste.entchain = e;
			else
				list = e;
				
			laste = e;
		}
			
		e = e.notcellchain;
	}
	
	return list;
}*/

void PlayerChain_Add(entity e) =		{	list_playerchain = LinkedList_Add(e, list_playerchain, playerchain, playerchain_prev);	}
void PlayerChain_Remove(entity e) =		{	list_playerchain = LinkedList_Remove(e, list_playerchain, playerchain, playerchain_prev);	}

void ObjectChain_Add(entity e) =			{	list_objectchain = LinkedList_Add(e, list_objectchain, objectchain, objectchain_prev);	}
void ObjectChain_Remove(entity e) =			{	list_objectchain = LinkedList_Remove(e, list_objectchain, objectchain, objectchain_prev);	}

void TagEntChain_Add(entity e) =
{
	if(e.tag_entity)
		e.tag_entity.list_tagentchain = LinkedList_Add(e, e.tag_entity.list_tagentchain, tagentchain, tagentchain_prev);
}

void TagEntChain_Remove(entity e) =	
{
	if(e.tag_entity)
		e.tag_entity.list_tagentchain = LinkedList_Remove(e, e.tag_entity.list_tagentchain, tagentchain, tagentchain_prev);
}

void AIChain_Add(entity e) =	{	list_aichain = LinkedList_Add(e, list_aichain, aichain, aichain_prev);	}
void AIChain_Remove(entity e) = {	list_aichain = LinkedList_Remove(e, list_aichain, aichain, aichain_prev);	}

void PathChain_Add(entity e) =		{	list_pathchain = LinkedList_Add(e, list_pathchain, pathchain, pathchain_prev);	}
void PathChain_Remove(entity e) =	{	list_pathchain = LinkedList_Remove(e, list_pathchain, pathchain, pathchain_prev);	}

void DLightChain_Add(entity e) =	{	list_dlightchain = LinkedList_Add(e, list_dlightchain, dlightchain, dlightchain_prev);	}
void DLightChain_Remove(entity e) =	{	list_dlightchain = LinkedList_Remove(e, list_dlightchain, dlightchain, dlightchain_prev);	}

void ParticleEmitterChain_Add(entity e) =		{	list_particleemitterchain = LinkedList_Add(e, list_particleemitterchain, particleemitterchain, particleemitterchain_prev);	}
void ParticleEmitterChain_Remove(entity e) =	{	list_particleemitterchain = LinkedList_Remove(e, list_particleemitterchain, particleemitterchain, particleemitterchain_prev);	}

void TeamChain_Add(entity e) =		{	list_teamchain = LinkedList_Add(e, list_teamchain, teamchain, teamchain_prev);	}
void TeamChain_Remove(entity e) =	{	list_teamchain = LinkedList_Remove(e, list_teamchain, teamchain, teamchain_prev);	}

void ObjectiveChain_Add(entity e) =		{	list_objectivechain = LinkedList_Add(e, list_objectivechain, objectivechain, objectivechain_prev);	}
void ObjectiveChain_Remove(entity e) =		{	list_objectivechain = LinkedList_Remove(e, list_objectivechain, objectivechain, objectivechain_prev);	}

float GetNewPathGroupID(float ISCLIENT) =
{
	local float count, groupexists, newid, multiple;
	local entity e;

	if(ISCLIENT)
		multiple = -1;
	else
		multiple = 1;
	
	for(count = 1*multiple; !newid; count+=1*multiple)
	{
		e = list_pathchain;
		while(e && !groupexists)
		{
			if(count == e.pathgroupid)
			{
				groupexists = TRUE;
				break;
			}
			e = e.pathchain;
		}
		
		if(!groupexists)
			newid = count;
			
		groupexists = FALSE;
	}
	
	return newid;
}

void Attach(entity e, entity h, float i) =
{
	TagEntChain_Remove(e);

	e.tag_index = i;
	e.tag_entity = h;
	
	TagEntChain_Add(e);
}

void AttachFollow(entity e, entity h, float i) =
{
	e.tag_index = i;
	e.tag_entity = h;
}


//void NotCellChain_Remove(entity e) =	{	list_notcellchain = LinkedList_Remove(e, list_notcellchain, notcellchain, notcellchain_prev);	}

//void NotCellChain_Add(entity e) =	{	list_notcellchain = LinkedList_Add(e, list_notcellchain, notcellchain, notcellchain_prev);	}

/*vector GetTagAngles(entity head, string tagname) =
{
	local float index;
	local vector basepos, ang;
	local entity e;
	
	index = gettagindex(head, tagname);
	basepos = gettaginfo(head, index);
	
	e = spawn();
	e.tag_entity = head;
	e.tag_index = index;
	
	ang = e.angles;
	
	while(e)
	{
		ang += e.tag_entity.angles;
		e = e.tag_entity;
	}
	
	return ang;
}*/

entity Chain2(entity e) = // this isn't needed anymore with new dpextensions
{
	local entity output;
	output = e;

	while(e)
	{
		e.chain2 = e.chain;
		e = e.chain;
	}
	
	return output;
}

float BindAngle(float minang, float ang, float maxang) =
{
	local float angrange;
	
	if(ang < minang || ang > maxang)
	{
		angrange = maxang - minang;
		ang = ((ang/angrange) - floor(ang/angrange))*angrange;
		
		if(ang > maxang)
			ang -= angrange;
		else
		if(ang < minang)
			ang += angrange;			
	}
	
	return ang;
}

float NormalizeAngle(float difference) =
{
	if(difference > 180)
		difference -= 360;
	else
	if(difference < -180)
		difference += 360;		
		
	return difference;
}

float AngleDifference(float angA, float angB) =
{
	local float angC, count;
	
	for(count = 0; angA < 0; angA +=360);{}	
	for(count = 0; angB < 0; angB +=360);{}
	for(count = 0; angA >= 360; angA -=360);{}
	for(count = 0; angB >= 360; angB -=360);{}
	
	angC = angA - angB;

	if(angC < 0)
		angC = angC*-1;
	
	if(angC > 180)
		angC = (angC - 360)*-1;
	
	return angC;
}

float AngleDifference2(float angA, float angB) =
{
	local float angC;
	
	angC = angA - angB;
	
	if(angC > 180)
		angC -= 360;
	else
	if(angC < -180)
		angC += 360;
	
	return angC;
}

void AddColorMod(entity e, vector addcolor) =
{
	local vector realaddcolor;

	realaddcolor = addcolor - '1 1 1';
	e.colormod += realaddcolor;

	e = e.list_tagentchain;
	while(e)
	{
		AddColorMod(e, addcolor);
		e = e.tagentchain;
	}
}

void SubtractColorMod(entity e, vector subcolor) =
{
	local vector realsubcolor;

	realsubcolor = '1 1 1' - subcolor;
	e.colormod += realsubcolor;
	
	e = e.list_tagentchain;
	while(e)
	{
		SubtractColorMod(e, subcolor);
		e = e.tagentchain;
	}	
}

/*void Func_oself(entity e, void() func) =
{
	local entity oself;
	oself = self;
	self = e;
	func();
	self = oself;
}*/

void SetOwner(entity c, entity o) =
{
	local entity oldo;

	oldo = c.owner;
	c.owner = o;

//	if(!o)
//		o = oldo;

	if(oldo)
	if(oldo != c)
		oldo.list_childchain = LinkedList_Remove(c, oldo.list_childchain, childchain, childchain_prev);

	if(o)
	if(c != o)
		o.list_childchain = LinkedList_Add(c, o.list_childchain, childchain, childchain_prev);
//	o.list_childchain = UpdateLinkedEntList(owner, o, childchain);
}

void SetParent(entity c, entity p) =	{	c.parent = p;	}

void RemoveEnt(entity e) =
{
	local float count, maxarraycount;
	local string s;

	if(IsAssignedFunction(e.ClearStringFunc))
		Func_oself(e, e.ClearStringFunc);

	if(IsAssignedFunction(e.PreRemoveFunc))
		Func_oself(e, e.PreRemoveFunc);

	TagEntChain_Remove(e);
	MobileEntChain_Remove(e);
	AIChain_Remove(e);	
	PlayerChain_Remove(e);
	PathChain_Remove(e);
	DLightChain_Remove(e);
	TeamChain_Remove(e);
	ObjectiveChain_Remove(e);
	
	if(CODEBASE == SERVERCODE)
		maxarraycount = NUMLANGUAGES+1;
	else
	if(CODEBASE == CLIENTCODE)
		maxarraycount = NUMLANGUAGES;
		
	for(count = 0; count < maxarraycount; count++)
	{
		s = e.(objectivetext[count]);
		s = freezone(s);
	}
	
	if(e.owner)
		SetOwner(e, world);
		
	if(e.parent)
		SetParent(e, world);	

	e.tag_entity = world;
	e.tag_index = 0;
		
//	remove(e);
}

void RemoveOwnedEnts(entity targ) =
{
	local entity e, nexte;
//	local float updatemobile;
	
//	e = nextent(world);
	e = targ.list_childchain;
	while(e)
	{
//		nexte = nextent(e);
		nexte = e.childchain;
	
	//	if(e.owner == targ)
	//	if(e != targ)
		if(e != targ)
		if(e.class != CLASS_SHOT)
		if(e.class != CLASS_OBJECT) // what is this for?
		{
//			if(e.mobile)
//				updatemobile = true;
		//	e.owner = world;
			SH_RemoveEnt(e);
		}
		
		e = nexte;
	}	
	
//	targ.list_childchain = UpdateLinkedEntList(owner, targ, childchain);
	
//	if(updatemobile)
//		UpdateMobileEntChain();	
}

void RemoveTagEnts(entity e) =
{
	local entity f, nextf;
	f = e.list_tagentchain;//findchainentity(tag_entity, e);
	while(f)
	{
		nextf = f.tagentchain;
		SH_RemoveEnt(f);	
		f = nextf;
	}
}

void ClearEntType(.float floatfield, float MATCH) =
{
	local entity e, nexte;
	e = nextent(world);
	while(e)
	{	
		nexte = nextent(e);
		if(e.floatfield == MATCH)
		{
			if(e.RemoveFunc) // client only FIXME
				e.RemoveFunc(e);
			else
				SH_RemoveEnt(e);
		}
		
		e = nexte;
	}	
}

//void ClearWaypoints() =	{	ClearEntType(class, CLASS_WAYPOINT);	}

entity SpawnFloater() =
{
	local entity e;
	e = spawn();
//	NotCellChain_Add(e);
	
	return e;
}

void ExecuteDelayFunc() =
{
	Func_oself(self.owner, self.DelayFunc);
	SH_RemoveEnt(self);
}

void Func_delay(entity e, float delaytime, void() func) =
{
	local entity relay;
	
	relay = spawn();
	SetOwner(relay, e);
	relay.nextthink = time+delaytime;
	relay.think = ExecuteDelayFunc;
	relay.DelayFunc = func;
}

string PrepLine_Entity(string line, entity e) =
{
	if(e.modelflags & MF_ROTATE)
		e.angles_base = '0 0 0';

	if(e.owner.canhaveteam)
	{
		line = AppendToken(line, SEP_SPACE, "TEAM");
		line = AppendToken(line, SEP_SPACE, ftos(e.owner.team));		
	}
		
	if(CODEBASE == SERVERCODE)
	{
		line = AppendToken(line, SEP_SPACE, "ISTRIGGER");
		line = AppendToken(line, SEP_SPACE, ftos(e.istrigger));	
		
		line = AppendToken(line, SEP_SPACE, "ISTARGET");
		line = AppendToken(line, SEP_SPACE, ftos(e.istarget));			
	}
		
	line = AppendToken(line, SEP_SPACE, "OBJCLASS");
	line = AppendToken(line, SEP_SPACE, ftos(e.objclass));

	line = AppendToken(line, SEP_SPACE, "VARIANT");	
	line = AppendToken(line, SEP_SPACE, ftos(e.variant));
	
	line = AppendToken(line, SEP_SPACE, "ORIGINBASE");	
	line = AppendToken(line, SEP_SPACE, vtos(e.origin_base));

	line = AppendToken(line, SEP_SPACE, "ANGLESBASE");	
	line = AppendToken(line, SEP_SPACE, vtos(e.angles_base));

	line = AppendToken(line, SEP_SPACE, "ENTID");	
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.entid));

	line = AppendToken(line, SEP_SPACE, "TARGETENTID");	
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.targetentid));

	line = AppendToken(line, SEP_SPACE, "TARGETSTAGETWOENTID");	
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.targetstagetwoentid));

	line = AppendToken(line, SEP_SPACE, "TARGETSTAGETHREEENTID");	
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.targetstagethreeentid));		
	
	line = AppendToken(line, SEP_SPACE, "MOVEMENTBEHAVIOR");	
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.movement_behavior));

	line = AppendToken(line, SEP_SPACE, "PATHGROUPID");	
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.pathgroupid));

	line = AppendToken(line, SEP_SPACE, "TRIGGERENTID");	
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.triggerentid));
	
	line = AppendToken(line, SEP_SPACE, "TRIGGERDELAY");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.triggerdelaytime));
	
	line = AppendToken(line, SEP_SPACE, "ASSOCIATIONENTID");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.associationentid));
	
	line = AppendToken(line, SEP_SPACE, "TRIGGEROBJECTIVEENTID");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.triggerobjectiveentid));
	
	line = AppendToken(line, SEP_SPACE, "STARTSTATEOFF");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.startstateoff));	
	
	line = AppendToken(line, SEP_SPACE, "MAPICON");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.mapicon));
	
	line = AppendToken(line, SEP_SPACE, "MAXTRIGGERS");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.maxtriggers));
	
	line = AppendToken(line, SEP_SPACE, "MULTIPLAYERONLY");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.multiplayeronly));	

	if(e.spawner_max_areaents)
	{
		line = AppendToken(line, SEP_SPACE, "SPAWNER_MAXAREAENTS");	
		line = AppendToken(line, SEP_SPACE, ftos(e.spawner_max_areaents));	
	}	
	
	if(e.spawner_max_ents)
	{
		line = AppendToken(line, SEP_SPACE, "SPAWNER_MAXENTS");	
		line = AppendToken(line, SEP_SPACE, ftos(e.spawner_max_ents));		

		line = AppendToken(line, SEP_SPACE, "SPAWNER_MAXLIGHTTANKS");	
		line = AppendToken(line, SEP_SPACE, ftos(e.spawner_max_lighttanks));	
		
		line = AppendToken(line, SEP_SPACE, "SPAWNER_MAXMEDIUMTANKS");	
		line = AppendToken(line, SEP_SPACE, ftos(e.spawner_max_mediumtanks));	

		line = AppendToken(line, SEP_SPACE, "SPAWNER_MAXLIGHTNINGTANKS");	
		line = AppendToken(line, SEP_SPACE, ftos(e.spawner_max_lightningtanks));	

		line = AppendToken(line, SEP_SPACE, "SPAWNER_MAXHEAVYTANKS");	
		line = AppendToken(line, SEP_SPACE, ftos(e.spawner_max_heavytanks));			
	}
	
//	if(e.scale)
//	{
//		line = AppendToken(line, SEP_SPACE, "SCALE");
//		line = AppendToken(line, SEP_SPACE, ftos(e.scale));
//	}
	
	if(e.objclass == OBJ_FLAGBASE)
	{
		line = AppendToken(line, SEP_SPACE, "NOFLAG");
		line = AppendToken(line, SEP_SPACE, ftos(e.owner.noflag));
	}

	if(e.owner.objclass == OBJ_TRIGGERRELAY)
	{
		line = AppendToken(line, SEP_SPACE, "TOUCHTRIGGER");
		line = AppendToken(line, SEP_SPACE, ftos(e.owner.touchtrigger));		
	}
	
	if(e.owner.objclass == OBJ_TERMINAL)
	{
		line = AppendToken(line, SEP_SPACE, "ACTIVATIONTIME");
		line = AppendToken(line, SEP_SPACE, ftos(e.owner.object_activationtime));		
		
		line = AppendToken(line, SEP_SPACE, "TERMINALTYPE");
		line = AppendToken(line, SEP_SPACE, ftos(e.owner.terminaltype));

		line = strcat(line, SEP_SPACE, "REQUIRESKEY", SEP_SPACE, ftos(e.owner.requireskey));
	}
	
	if(e.owner.objclass == OBJ_STRUCTURE
	&& e.owner.variant == STRUCTURE_REFINERY)
		line = strcat(line, SEP_SPACE, "INDESTRUCTIBLE", SEP_SPACE, ftos(e.owner.indestructible));

	return line;
}

string PrepLine_Objective(string line, entity e) =
{
	local string o;

	line = AppendToken(line, SEP_SPACE, "OBJCLASS");
	line = AppendToken(line, SEP_SPACE, ftos(e.objclass));
	
	line = AppendToken(line, SEP_SPACE, "ENTID");	
	line = AppendToken(line, SEP_SPACE, ftos(e.entid));

	line = AppendToken(line, SEP_SPACE, "PRIORITY");	
	line = AppendToken(line, SEP_SPACE, ftos(e.objectivepriority));	

	line = AppendToken(line, SEP_SPACE, "OBJECTIVETEXT");	
	line = AppendToken(line, SEP_SPACE, "\"");
	if(CODEBASE == SERVERCODE)
		o = e.(objectivetext[currentlanguage+1]);
	if(o == "DEFAULT" || CODEBASE == CLIENTCODE)
		o = e.objectivetext;	
	line = strcat(line, o, "\"");
	
	return line;
}

string PrepLine_Train(string line, entity e) =
{
	line = AppendToken(line, SEP_SPACE, "OBJCLASS");
	line = AppendToken(line, SEP_SPACE, ftos(e.objclass));
	
//	if(CODEBASE == CLIENTCODE)
//	{
		line = AppendToken(line, SEP_SPACE, "ENTID");
		line = AppendToken(line, SEP_SPACE, ftos(e.owner.entid));	
//	}
//	else
	if(CODEBASE == SERVERCODE)
	{
		line = AppendToken(line, SEP_SPACE, "TARGETNAME");
		line = AppendToken(line, SEP_SPACE, e.targetname);
		
		line = AppendToken(line, SEP_SPACE, "ISDELETEDFORMISSION");
		line = AppendToken(line, SEP_SPACE, ftos(e.isdeletedformission));
	}
	
	line = AppendToken(line, SEP_SPACE, "TRIGGERENTID");	
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.triggerentid));
	
	line = AppendToken(line, SEP_SPACE, "TRIGGERDELAY");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.triggerdelaytime));	
	
	line = AppendToken(line, SEP_SPACE, "STARTSTATEOFF");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.startstateoff));	
	
	line = AppendToken(line, SEP_SPACE, "MULTIPLAYERONLY");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.multiplayeronly));		
	
	return line;
}

string PrepLine_AmbientSound(string line, entity e) =
{
	line = AppendToken(line, SEP_SPACE, "OBJCLASS");
	line = AppendToken(line, SEP_SPACE, ftos(e.objclass));

	line = AppendToken(line, SEP_SPACE, "ORIGINBASE");	
	line = AppendToken(line, SEP_SPACE, vtos(e.origin_base));

	line = AppendToken(line, SEP_SPACE, "ANGLESBASE");
	line = AppendToken(line, SEP_SPACE, vtos(e.angles_base));	

	line = AppendToken(line, SEP_SPACE, "ENTID");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.entid));

	line = AppendToken(line, SEP_SPACE, "AMBIENTSOUND");
	line = AppendToken(line, SEP_SPACE, e.ambientsoundeffect);
	
	line = AppendToken(line, SEP_SPACE, "MULTIPLAYERONLY");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.multiplayeronly));		
	
	return line;
}

string PrepLine_ParticleEmitter(string line, entity e) =
{
	line = AppendToken(line, SEP_SPACE, "OBJCLASS");
	line = AppendToken(line, SEP_SPACE, ftos(e.objclass));

	line = AppendToken(line, SEP_SPACE, "ORIGINBASE");	
	line = AppendToken(line, SEP_SPACE, vtos(e.origin_base));

	line = AppendToken(line, SEP_SPACE, "ANGLESBASE");
	line = AppendToken(line, SEP_SPACE, vtos(e.angles_base));	

	line = AppendToken(line, SEP_SPACE, "ENTID");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.entid));

	line = AppendToken(line, SEP_SPACE, "PARTICLEEMITTEREFFECT");
	line = AppendToken(line, SEP_SPACE, e.particleemittereffect);
	
	line = AppendToken(line, SEP_SPACE, "STARTSTATEOFF");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.startstateoff));	
	
	line = AppendToken(line, SEP_SPACE, "MULTIPLAYERONLY");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.multiplayeronly));		

	line = AppendToken(line, SEP_SPACE, "TRIGGERENTID");	
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.triggerentid));	
	
	line = AppendToken(line, SEP_SPACE, "TRIGGERDELAY");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.triggerdelaytime));	
	
	if(CODEBASE == SERVERCODE)
	{
		line = AppendToken(line, SEP_SPACE, "ISTARGET");
		line = AppendToken(line, SEP_SPACE, ftos(e.istarget));			
	}	
	
	return line;
}

string PrepLine_Path(string line, entity e) =
{
	line = AppendToken(line, SEP_SPACE, "OBJCLASS");
	line = AppendToken(line, SEP_SPACE, ftos(e.objclass));

	line = AppendToken(line, SEP_SPACE, "ENTID");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.entid));

	line = AppendToken(line, SEP_SPACE, "PATHGROUPID");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.pathgroupid));
	
//	if(e.owner.prevpathpointid)
//		line = AppendToken(line, SEP_A, ftos(e.owner.prevpathpointid));
//	else
	line = AppendToken(line, SEP_SPACE, "PREVPATHENTID");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.prevpathpoint.entid));
		
//	if(e.owner.nextpathpointid)
//		line = AppendToken(line, SEP_A, ftos(e.owner.nextpathpointid));
//	else

	line = AppendToken(line, SEP_SPACE, "NEXTPATHENTID");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.nextpathpoint.entid));
		
	line = AppendToken(line, SEP_SPACE, "ORIGIN");
	line = AppendToken(line, SEP_SPACE, vtos(e.owner.origin));
	
	if(pathfunctions)
	{
		line = AppendToken(line, SEP_SPACE, "PATHFUNCTIONS");
		line = AppendToken(line, SEP_SPACE, ftos(pathfunctions));	
	}
	
	if(CODEBASE == SERVERCODE)
	{
		line = AppendToken(line, SEP_SPACE, "ISTRIGGER");
		line = AppendToken(line, SEP_SPACE, ftos(e.istrigger));	
	}	
	
	line = AppendToken(line, SEP_SPACE, "TARGETENTID");	
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.targetentid));	
	
	line = AppendToken(line, SEP_SPACE, "TRIGGEROBJECTIVEENTID");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.triggerobjectiveentid));	
	
	line = AppendToken(line, SEP_SPACE, "MULTIPLAYERONLY");
	line = AppendToken(line, SEP_SPACE, ftos(e.owner.multiplayeronly));		
	
	return line;
}

/*string PrepLine_Waypoint(string line, entity e) = // NOT FOR SAVING
{
	line = AppendToken(line, SEP_SPACE, ftos(e.id));
	line = AppendToken(line, SEP_SPACE, vtos(e.origin));
	return line;
}*/