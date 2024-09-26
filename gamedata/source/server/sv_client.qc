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
void ClientKill() =
{
	Damage(world, self, world, self.health+self.armorvalue);
}
	
void GetClientStats(float getstatflags) =
{
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_GETCLIENTSTATS);
	
	#ifndef COMPILE_SERVICE_ONLIVE
		WriteString(MSG_ONE, self.netname);	
	#endif
	
	WriteLong(MSG_ONE, getstatflags);

//	self.initialized = TRUE;
}	
	
void AnnounceConnection() =
{
	local float count;
	local string s, b;

	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CONNECTED);
	WriteByte(MSG_ONE, mission_locked);
	WriteByte(MSG_ONE, gamemode);
	WriteByte(MSG_ONE, teamplay);
	WriteByte(MSG_ONE, singleplayer);
	WriteLong(MSG_ONE, maxplayers);
	WriteByte(MSG_ONE, allowvoting);
	WriteByte(MSG_ONE, publicguesteditoraccess);
	WriteLong(MSG_ONE, fraglimit);
	WriteLong(MSG_ONE, capturelimit);
	WriteString(MSG_ONE, campaign);
	WriteString(MSG_ONE, mission);
	WriteString(MSG_ONE, world.fog);
	
	for(count = 0; count < NUMLANGUAGES; count++)
	{
		b = mission_briefing[count+1];
		if(b == "DEFAULT")
			b = mission_briefing;
		s = strcat(s, "\"", b, "\" ");
	}
	
	WriteString(MSG_ONE, s);
	WriteByte(MSG_ONE, alloweditorinmultiplayer);
}		

/*void AnnounceConnectionForAllPlayers() =
{
	local entity e;
	for(e = list_playerchain; e; e = e.playerchain)
		Func_oself(e, AnnounceConnection);
}*/
	
void ClientConnect() =
{
	local float minversion, getstatflags;

	self.class = CLASS_PLAYER;
	SetOwner(self, self);
	SetParent(self, self);
	setmodel(self, "null");
	
	self.jointime = time;
	
	minversion = 1;
	if(EPISODE > minversion)
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_REQUESTEPISODENUM);
		self.requestingepisodenum = TRUE;
	}
	
	SetID(self);
	PlayerChain_Add(self);
	self.team = -1;
	
	AnnounceConnection();
	
	self.SendEntity = SendPlayer;	
	self.SendFlags = SFL_RESET | SFL_BASEDATA;
	self.effects = self.effects | EF_NODEPTHTEST;	
	SetLocalPlayerAdminFlags();	

	SendObjectiveTextToPlayer();
	
	emptyserver_restarttime = 0;	
	
//	#ifndef COMPILE_GAMEPLAYOPTIONS_SINGLEPLAYER
//		bprint(strcat(self.netname, " has connected.\n"));
//	#endif
	
	if(singleplayer)
	{
		getstatflags = GSF_COLORS | GSF_ITEMS;	
		StopAllActivity();
	}
	else
	{
		getstatflags = GSF_COLORS;
		DecodeLevelParms();	
		if(!self.items1 && !self.items2)
		{
			self.items1 = 1;
			dprint("WARNING: missing weapons\n");
		}				
		
		self.earneditems1 = 1;
	}
	
	GetClientStats(getstatflags);
	ChooseTeam();	
	
	if(!singleplayer)
	if(self.netaddress != "local")
	if(strlen(cvar_string("sv_join_password")))
	{
		self.requestingjoinpassword = TRUE;	
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_REQUESTJOINPASSWORD);
	}		
	
	UpdateVoteStatsToClient(self, MSG_ONE);	
}
	
void ClientDisconnect() =
{
	local entity e;
	local float playersstillalive, serveroccupied;

	if(self.netaddress == "local")	
		return;
		
	if(!singleplayer)
	if(dropitemsinmultiplayer)
	if(GameMode_DropPlayerItemsOnDisconnect(gamemode))
		DropItems(self);	
		
	if(self.flagent)
		DropFlag(self);
	
/*	if(GameMode_PlayerHasLives(gamemode))
	if(self.health > 0)
	{
		UpdateLives(global_lives+1);
		for(e = list_playerchain; e; e = e.playerchain)
			UpdateClientGameStatus(e);
	}*/

	if(!singleplayer)
	if(showingmissionscores)
	if(self.scoreviewingtime != -1)
		PlayerFinishedViewingMissionScores(TRUE, FALSE);
	
	for(e = list_playerchain; e; e = e.playerchain)
	{
		if(e != self)
			serveroccupied = TRUE;
	}

	if(!serveroccupied)
		emptyserver_restarttime = time;
	
//	#ifndef COMPILE_GAMEPLAYOPTIONS_SINGLEPLAYER
//		bprint(strcat(self.netname, " has disconnected.\n"));	
//	#endif
	
	SH_RemoveEnt(self);
	
	UpdateVoteStatsForDisconnectingPlayer();
}
	
void Respawn() =
{
	if(!self.isdead)
		return;

	if(!(self.health <= 0))
		return;

	if(GameMode_PlayerHasLives(gamemode))
	if(!global_lives)
		return;
	
	if(GameMode_HasRespawnTime(gamemode))
	if(time < self.deathtime+RESPAWNTIME)
		return;
	
	self.flags = self.flags | FL_REVIVE;
	ResetWeaponStats();
	PutClientInServer();
}	
	
void PlayerDeathThink() =
{
}

//string sprintf(string format, ...) = #627

/*  string GetTextureName (vector org) =
  {

	  local float surfnum;
	  local string s;

	  print(vtos(org));print("\n");
	  
	  surfnum = getsurfacenearpoint(world, org);

	  if (surfnum >= 0)
	  {
		  s = getsurfacetexture(world, surfnum);
		  return s;
	  }    
		  return "";
  }*/

void ButtonChat() =
{
	local float buttonchat_new;

	if(self.buttonchat || self.menus_opened)
		buttonchat_new = TRUE;
	else
		buttonchat_new = FALSE;

	if((buttonchat_new && !self.buttonchat_old)
	|| (!buttonchat_new && self.buttonchat_old))
		self.SendFlags = self.SendFlags | SFL_STATE;	

	self.buttonchat_old = buttonchat_new;
}
  
float	globalsendpingtime;
.float	sendpingtime; 
void PlayerPreThink() =
{
	local float f;

	if(!(self.SendFlags & SFL_SCORE))
		self.ScoreFlags = FALSE;
	
	if(self.sendpingtime < time)
	if(globalsendpingtime < time)
	{
		self.SendFlags = self.SendFlags | SFL_PING;
		globalsendpingtime = time + 0.5;
		self.sendpingtime = time + 5;
	}
	
	ButtonChat();	
	
	self.maptime_start = mission_maptime_start;
	self.maptime_total = mission_maptime_total;
	if(self.team > 0)
	{
		f = globalitem_datakeys[self.team-1];
		self.glitem_datakeys = f;
		f = globalitem_corruptfusioncores[self.team-1];
		self.glitem_corruptfusioncores = f;		
	}
	self.stat_vote_tally_yes = vote_tally_yes;
	self.stat_vote_tally_no = vote_tally_no;	
	
	if(vote_applysettingstime)
		self.stat_vote_applysettingstime = vote_applysettingstime;
		
	if(vote_tallytime)	
		self.stat_vote_tallytime = vote_tallytime;
	
	if(server_restarttime)
		self.restarttime = server_restarttime;
		
	if(!singleplayer)
	if(showingmissionscores)
	if(self.scoreviewingtime != -1)
	{
		self.scoreviewingtime = server_scoreviewingtime;
		if(server_scoreviewingtime <= time)
			PlayerFinishedViewingMissionScores(TRUE, FALSE);
	}

	if(self.requestingjoinpassword)
	{
		self.joinpasswordtime = self.jointime+30;	
		if(self.joinpasswordtime <= time)
			dropclient(self);
		
		return;
	}	
	
	RemoveExpiredEffects();
	
	if(self.max_health)
	{
		local float oldspeed, newspeed;
		
		oldspeed = vlen(self.oldvelocity);
		newspeed = vlen(self.velocity);
		self.oldvelocity = self.velocity;
		
		if(newspeed >= oldspeed-35 && newspeed <= oldspeed+35)
			self.constantspeedtime += frametime;
		else
			self.constantspeedtime = 0;	
	
		if(GameMode_CanSpawnEnemies(gamemode))
		{
			AI_Wake();
		
			UnmarkGrid(self, FALSE, TRUE);
			MarkGrid(self, FALSE, TRUE, self.gridpos);
		}
		
	//	if(self.max_health)
	//	if(self.health <= 0)
	//		PlayerDeathThink();

	//	RechargeShields();
			
		if(self.stuntime > time)
			ApplyInertia(frametime);
		else
			PlayerInput();		
	}
	
//	PlayerInput_Misc();
}
	
void PlayerPostThink() =
{
	WeaponAutoFire(self.items1, self.items2);
	
	if((self.flags & FL_ONGROUND) && !(self.health <= 0))
	{
		if(self.fallvelocity < -350)
			SetEventFlag_Sound(self, SOUND_PLAYER_LAND);
	
		if(self.fallvelocity < -650)
			Damage(world, self, world, (self.fallvelocity+650)*0.3);
	}
	
	self.fallvelocity = self.velocity_z;	
	self.impulse = 0;	
//	BindToWorld(self);	
}
	
void SelectSecondary() =
{
	if(!HasSecondaryType(self, 0))
		self.secondarywep = 1;
		
	if(!HasSecondaryType(self, 1))
		self.secondarywep = 0;
}	
	
float PlayerInLocation(vector org) =
{
	local entity e;
	local vector diff;
	local float rad;
	
	rad = self.maxs_x;
	
	for(e = findradius(org, rad); e; e = e.chain)
	{
		diff = e.origin - org;
		if(diff*diff <= rad*rad)	
		if(e.class == CLASS_PLAYER)
		if(e != self)
			return TRUE;
	}
	
	return FALSE;
}
	
vector GetSafeSpawnLocationForPlayer(vector org, vector ang) =
{
	local float count, numpositions;
	local vector pos, posang;

	if(!PlayerInLocation(org))
		return org;
		
	numpositions = 8;	
	posang = ang;	
	
	for(count = 0; count < numpositions; count++)
	{
		posang_y = ang_y + 90 + count*(360/numpositions);
		makevectors(posang);
		pos = org+v_forward*self.maxs_x*4;
		if(!PlayerInLocation(pos))
			return pos;
	}

	return org;
}
/*

	local entity e;
	local vector altorg, diff;
	local float playernum, row, col, spawn_sector_gridsize, findneworg;
	
	spawn_sector_gridsize = self.maxs_x*4;	
	
	for(e = findradius(org, self.maxs_x); e; e = e.chain)
	{
		diff = e.origin - org;
		if(diff*diff <= self.maxs_x*self.maxs_x)	
		if(e.class == CLASS_PLAYER)
		if(e != self)
		{
			findneworg = TRUE;
			break;
		}
	}
	
	if(!findneworg)
		return org;
	
	
	
	
	
	
	
	playernum = 0;
	for(e = list_playerchain; e; e = e.playerchain)
	{
		playernum++;
		if(e == self)
			break;
	}
	
	playernum = ((playernum/8) - floor(playernum/8))*8;
	
	if(playernum <= 2)
		row = 2;
	else
	if(playernum <= 5)
		row = 3;
	else
	if(playernum <= 8)
		row = 1;
	
	if(playernum > 1)
		playernum++;
	
	col = ((playernum/3) - floor(playernum/3))*3;

	makevectors(ang);	
	altorg += v_right*(((col-1)*spawn_sector_gridsize)-spawn_sector_gridsize);
	altorg += v_forward*(((row-1)*spawn_sector_gridsize)-spawn_sector_gridsize);
	altorg += org;
	
	for(e = findradius(altorg, self.maxs_x); e; e = e.chain)
	{
		diff = e.origin - altorg;
		if(diff*diff <= spawn_sector_gridsize*spawn_sector_gridsize)
		if(e.class == CLASS_PLAYER)
		if(e != self)
		{
			altorg = org;
			break;
		}
	}		
	
	return altorg;
}	*/
	
void PutClientInServer() =
{
	if(self.requestingepisodenum)
		return;

	if(server_loadingobjectsfromfile)
		return;

	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_MISSIONTRACK);
	WriteString(MSG_ONE, mission_track);		

	if(self.requestingjoinpassword)
		return;
	
//	if(!self.initialized)
//		GetClientItems();

//		AnnounceConnection();
	
	if(showingmissionscores)
	{
		MissionScores(MSG_ONE);
		PlayerFinishedViewingMissionScores(FALSE, FALSE);	
		return;
	}		
	
	if(mission_maptime_total == -1)
	{
		MissionTimeUp(MSG_ONE);
		return;
	}
	
	if(GameMode_PlayerHasLives(gamemode))
	{
		// if new to server and there are no lives in the pool, make the player wait for more lives to be aquired
/*		if(!self.flags & FL_REVIVE)
		if(!global_lives)
		{
			UpdateClientGameStatus(self);
			return;
		}*/
		
		// subtract 1 life from the pool when players spawn or respawn (except in offline editor mode)
//		if(!(maxplayers <= 1 && !singleplayer))
//		{
		//	local entity e;
			UpdateLives(global_lives - 1);
		//	for(e = list_playerchain; e; e = e.playerchain)
		//	{
		//		if(e != self)
		//			UpdateClientGameStatus(e);
		//	}
//		}	
	}
	
	if(GameMode_HasTeams(gamemode))
	if(self.team == -1)
		return;
	
//	self.button0 = FALSE;
//	self.button2 = FALSE;
//	self.button7 = FALSE;
	
	TutorialFlags(self, FALSE);
	UpdateBindMap();
	
	self.think = SUB_Null;
	self.nextthink = 0;
	
	self.flags = self.flags - self.flags & FL_REVIVE;
		
	local entity list_spawnpads, pad, lastpad;
	local vector org;
	local float numspawnpads, count, r;
	
	self.lastkillwep = 0;
	self.consecutivewepkillcount = 0;
	self.isdead = FALSE;
	self.health = self.max_health = 100;
	self.armorvalue = self.maxshields = 100;
	self.movementinertia = 0.4;

	if(GameMode_PlayerHasLives(gamemode))
		self.lives = global_lives;	

//	DecodeLevelParms();	
	
	SelectSecondary();
	
	for(pad = findchainfloat(objclass, OBJ_SPAWNPAD); pad; pad = pad.chain)
	{
		if(GameMode_HasTeams(gamemode))
		if(pad.variant != self.team)
		{
			if(lastpad)
				lastpad.chain = pad.chain;
			continue;
		}
	
		if(!list_spawnpads)
			list_spawnpads = pad;

		lastpad = pad;	
			
		numspawnpads++;
	}
		
	r = bound(0, floor(random()*numspawnpads), numspawnpads-1);
	
	for(pad = list_spawnpads; count < r; count++)
		pad = pad.chain;
	
	self.class = CLASS_PLAYER;
	SetOwner(self, self);
	SetParent(self, self);
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	
	self.mobile = TRUE;
	MobileEntChain_Add(self);	
	
	SetObjectAppearance(self, 0, 0);

	if(pad)
	{
		org = pad.origin;
		org = GetSafeSpawnLocationForPlayer(org, pad.angles_base);
		org_z += pad.maxs_z+1;
	}
	
	self.angles = pad.angles_base;
	self.fixangle = TRUE;
	self.oldorigin = org;
	setorigin(self, org);
	self.velocity = '0 0 0';	
	self.teleporttouchtime = time+1;
//	self.SendEntity = SendPlayer;	
	self.SendFlags = self.SendFlags | SFL_ORIGIN | SFL_ANGLES | SFL_RESET | SFL_TELEPORT;
//	self.effects = self.effects | EF_NODEPTHTEST;
	self.damage_effects = self.damage_effects | DMGEF_BURN;
	
//	if(GameMode_CanSpawnEnemies(gamemode))
//	if(self.gridpos == '0 0 0')
//		MarkGrid(self, TRUE, TRUE, self.gridpos);
	
	self.shootfrom_index = gettagindex(self, "tag_cannon.R");
	self.firingpos = self.maxfiringpos = 5;
}

/*void InitializePlayer() =
{
	if(self.initialized)
		return;

	ChooseTeam();
}*/

void AssignPlayerColors(float playercolor_r, float playercolor_g, float playercolor_b) =
{
	self.player_colors_x = playercolor_r;
	self.player_colors_y = playercolor_g;
	self.player_colors_z = playercolor_b;
	self.SendFlags = self.SendFlags | SFL_BASEDATA;	
}

void AssignClientItems(string s) =
{
	local float minepisode, numepisode, globalclientitems1, globalclientitems2, clientitems1, clientitems2;

	if(!singleplayer || self.initializeditems)
		return;
	
	numepisode = stof(argv(1));
	clientitems1 = stof(argv(2));
	
	minepisode = 2;
	if(numepisode >= 2)
	if(EPISODE >= minepisode)
		clientitems2 = stof(argv(3));

/*	globalclientitems1 = stof(argv(numepisode+2));
	
	minepisode = 2;
	if(EPISODE >= minepisode)
		globalclientitems2 = stof(argv(numepisode+3));		*/
		
/*	if(singleplayer)		
	if(globalclientitems1 || globalclientitems2)
	{
		self.globalitems1 = globalclientitems1;
		self.globalitems2 = globalclientitems2;
	}
	else
		self.globalitems1 = WEP1_MINIGUN;*/

	if(clientitems1 & WEP1_MINIGUN)
		clientitems2 -= clientitems2 & WEP2_FLACKGUN;

	if(clientitems1 & WEP1_STORMPLOW)
	{
		clientitems2 -= clientitems2 & WEP2_STORMSPREAD;
		clientitems2 -= clientitems2 & WEP2_STORMSHIELD;
	}

	if(clientitems2 & WEP2_STORMSPREAD)
		clientitems2 -= clientitems2 & WEP2_STORMSHIELD;
	
	if(clientitems1 & WEP1_BEAMCANNON)
		clientitems2 -= clientitems2 & WEP2_THUNDERBOLT;
	
	if(clientitems1 & WEP1_ROCKETPOD)
	{
		clientitems2 -= clientitems2 & WEP2_HOMINGMISSILES;
		clientitems2 -= clientitems2 & WEP2_MIRVMORTAR;
	}

	if(clientitems2 & WEP2_HOMINGMISSILES)
		clientitems2 -= clientitems2 & WEP2_MIRVMORTAR;
	
	self.items1 = clientitems1;
	self.items2 = clientitems2;

	if(!(self.items1 & WEP1_MINIGUN)
	&& !(self.items2 & WEP2_FLACKGUN))
		self.items1 = self.items1 | WEP1_MINIGUN;
		
	self.earneditems1 = self.items1;
	self.earneditems2 = self.items2;
		
	self.initializeditems = TRUE;
//	SetLoadedParms();
	SelectSecondary();
	
	TutorialFlags(self, FALSE);
}