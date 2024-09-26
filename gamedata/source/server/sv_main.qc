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
void main() = {}

void precaches() =
{
	Precache_Models();
	Precache_Sounds();
}

string GetLocalCampaign(float language) =
{
	local float file;
	local string filename, cname, line;
	
	filename = strcat("campaign/_", uri_escape(campaign), "/local/", GetLanguageName(language), "/local.txt");
	file = FileOpen(filename, FILE_READ);
	
	if(file == -1)
		cname = campaign;
	else
	{
		fgets(file);
		cname = fgets(file);
		fclose(file);
	}
	
	return cname;
}

string GetLocalMission(float language) =
{
	local float file;
	local string filename, mname, line;
	
	filename = GetMissionFilename(gamemode, campaign, mission, TRUE, language);
	
	file = FileOpen(filename, FILE_READ);
	
	mname = mission;
	
	if(file != -1)
	{
		for(line = fgets(file); line && mname == mission; line = fgets(file))
		{
			tokenize(line);
			
			if(argv(0) == "MISSION")
				mname = argv(1);
		}
		
		fclose(file);
	}
	
	return mname;
}

void SetServerStats() =
{
	local string mode, mode_items, s, f, t, sep;
	local float f_mode, count;
	
	mission_locked = cvar("mission_locked_default");
	gamemode = cvar("sv_gamemode");
	singleplayer = cvar("singleplayer");
	allowvoting = cvar("sv_multiplayer_allowvoting");
	alloweditorinmultiplayer = cvar("sv_multiplayer_alloweditor");	
	publicguesteditoraccess = cvar("sv_multiplayer_publicguesteditoraccess");	
	dropitemsinmultiplayer = cvar("sv_multiplayer_dropitems");	
//	itemsmode = cvar("sv_itemsmode");
	itemrespawndelay = cvar("sv_itemrespawndelay");	
	weaponrespawndelay = cvar("sv_weaponrespawndelay");
	maxscoreviewingtime = cvar("sv_maxscoreviewingtime");	
	teamplay = cvar("teamplay");
	fraglimit = cvar("fraglimit");	
	capturelimit = cvar("capturelimit");
	gameskill = cvar("skill");
	
	if(gamemode < 0 || gamemode > 2)
		gamemode = 0;
	
	if(gameskill == 0)
		skillmultiple = 0.5;
	else
		skillmultiple = 1;
	
/*	if(itemsmode == 0)
		mode_items = "Earned";
	else
	if(itemsmode == 1)
		mode_items = "Basic";*/
	
	if(gamemode == GAMEMODE_CAMPAIGN)
		campaign = zonecpy(campaign, UnderscoreString(cvar_string("campaign")));
	mission = zonecpy(mission, UnderscoreString(cvar_string("mission")));
	
	if(gamemode == GAMEMODE_CAMPAIGN)	
	for(count = 0; count < NUMLANGUAGES; count++)
	{
		s = campaign[count+1];
		s = zonecpy(s, GetLocalCampaign(count));
		campaign[count+1] = s;	
	}

	for(count = 0; count < NUMLANGUAGES; count++)
	{
		s = mission[count+1];
		s = zonecpy(s, GetLocalMission(count));
		mission[count+1] = s;
	}	
	
	s = ftos(gamemode);
//	s = AppendToken(s, SEP_A, ftos(itemsmode));	

	if(gamemode == GAMEMODE_CAMPAIGN)
	{
		t = campaign[currentlanguage+1];
		s = strcat(s, SEP_A, ConvertToQCStatusString(t, QCSF_CAMPAIGN));
	}

	t = mission[currentlanguage+1];
	s = strcat(s, SEP_A, ConvertToQCStatusString(t, QCSF_MISSION));

	f = ftos(EPISODE);
	s = AppendToken(s, SEP_A, ConvertToQCStatusString(f, QCSF_EPISODE));	
	s = AppendToken(s, SEP_A, ftos(gameskill));
	
//	if(GameMode_AllowMinPlayers(gamemode))
//		s = AppendToken(s, SEP_A, ftos(minplayers));
	worldstatus = zonecpy(worldstatus, s);
	
	if(GameMode_PlayerHasLives(gamemode))	
		global_lives = 3+maxplayers;	
	else
		global_lives = 0;
}

entity	wall;
void worldspawn() =
{
	local entity e;
	
	CODEBASE = SERVERCODE;
	
	cvar_set("gameversion", ftos(EPISODE));
	
	currentlanguage = cvar("localize_language");	
	SetLanguageFontScale();
	
//	SetUpSectorGrid();
	
	e = nextent(world);
	while(e != world)
	{
		e = nextent(e);
		maxplayers++;
	}

	#ifdef COMPILE_GAMEPLAYOPTIONS_SINGLEPLAYER
		if(maxplayers > 1)
			localcmd("quit\n");
	#endif
	
	SetServerStats();	
	
	cvar_set("menu_maxplayers", ftos(maxplayers));
	minplayers = cvar("minplayers");	
	
	CELL_MAXS_x			= BASE_CELL_MAXS_x*CELL_SCALE;
	CELL_MAXS_y			= BASE_CELL_MAXS_y*CELL_SCALE;
	CELL_MINS_x			= BASE_CELL_MINS_x*CELL_SCALE;
	CELL_MINS_y			= BASE_CELL_MINS_y*CELL_SCALE;	
	CELLBBOX_MAXS_x		= BASE_CELLBBOX_MAXS_x*CELL_SCALE;
	CELLBBOX_MAXS_y		= BASE_CELLBBOX_MAXS_y*CELL_SCALE;	
	CELLBBOX_MINS_x		= BASE_CELLBBOX_MINS_x*CELL_SCALE;
	CELLBBOX_MINS_y		= BASE_CELLBBOX_MINS_y*CELL_SCALE;

	wall = spawn();
	
	precaches();
	LightStyles_setup();
	
	addstat(42, 2, items1);
	addstat(43, 2, items2);	
	addstat(61, 2, lives);
	
	addstat(32, 8, (attack_finished[0])); // minigun
	addstat(33, 8, (attack_finished[1])); // shockwave	
	addstat(34, 8, (attack_finished[2])); // storm	
	addstat(35, 8, (attack_finished[3])); // energy
	addstat(36, 8, (attack_finished[4])); // missile weapon
	addstat(50, 8, globalcooldown);
	
	addstat(59, 2, secondarywep);
	
	addstat(58, 8, maptime_start);
	addstat(60, 8, maptime_total);	

//	addstat(63, 2, scoreplacing);
	
	addstat(64, 2, enemyhealth);
	addstat(65, 2, enemyhealth_max);
	addstat(66, 2, enemyobjclass);
	addstat(67, 2, enemyvariant);
	
	addstat(70, 8, scoreviewingtime);
	addstat(71, 8, restarttime);
	
	addstat(80, 2, glitem_datakeys);
	addstat(81, 2, glitem_corruptfusioncores);
	
	addstat(90, 2, stat_vote_tally_yes);
	addstat(91, 2, stat_vote_tally_no);	
	addstat(92, 8, stat_vote_applysettingstime);
	addstat(93, 8, stat_vote_tallytime);
	addstat(94, 2, vote_ballot);
	
	addstat(100, 8, joinpasswordtime);
	
	LoadEntities();	
}

void SetNewParms() =
{
	parm1 = 1;
	parm2 = 0;
}

/*void SetLoadedParms() =
{
	parm1 = self.items1;
	parm2 = self.items2;
}*/

void DecodeLevelParms() =
{
	self.items1 = parm1;
	self.items2 = parm2;
}

void SetChangeParms() =
{
	if(GameMode_AlwaysCarryWeaponsToNextMap(gamemode))
	{
		parm1 = self.items1;
		parm2 = self.items2;
	}
	else
		SetNewParms();
}

/*void SetMapStartParms() = // only happens first time client connects to server
{
	parm1 = self.items1;
	parm2 = self.items2;
	parm3 = self.earneditems1;
	parm4 = self.earneditems2;
	parm5 = TRUE;
}

void DecodeLevelParms() =
{
	local float startitems1, startitems2, newearneditems1, newearneditems2;

	if(self.initializeditems)
	{print("DECODE 1\n");
		if((!self.items1 && !self.items2)				// initial spawn
//		|| GameMode_AlwaysResetItemsOnRespawn(gamemode) // game mode forces item reset
		|| itemsmode == ITEMSMODE_BASIC					// basic items mode respawn
		|| singleplayer)								// singleplayer mode respawn
		{
		print("DECODE 1 B\n");
			self.items1 = self.earneditems1;		
			self.items2 = self.earneditems2;
		}

		return;	
	}
	
	print("DECODE 2\n");
	
	startitems1 = parm1;
	startitems2 = parm2;
	newearneditems1 = parm3;
	newearneditems2 = parm4;
	self.initializeditems = parm5;

//	print("DecodeLevelParmsB!\n startitems: ");print(ftos(startitems));
//	print(" newearneditems: ");	print(ftos(newearneditems));
//	print(" initializeditems: "); print(ftos(self.initializeditems));print("\n");
	
	if(!self.initializeditems)
		return;
		
	print("DECODE 3\n");	
		
	// set items to stored setting if
	if((!self.items1 && !self.items2)				// initial spawn
//	|| GameMode_AlwaysResetItemsOnRespawn(gamemode) // game mode forces item reset
	|| itemsmode == ITEMSMODE_BASIC					// basic items mode respawn
	|| singleplayer)								// singleplayer mode respawn
	{
		print("DECODE 3 B\n");
		self.items1 = startitems1;
		self.items2 = startitems2;
	}
	
	self.earneditems1 = newearneditems1;
	self.earneditems2 = newearneditems2;
}	
	
void SetChangeParms() =
{
	local float carryitems1, carryitems2;


	// reset weapons before map change if
//	if((!coop && !deathmatch)			// single player manual map change
	if(!GameMode_AlwaysCarryWeaponsToNextMap(gamemode) && itemsmode == ITEMSMODE_BASIC)	// deathmatch and basic items mode
	{print("SETCHANGE 1\n");
	//	SetNewParms();
		carryitems1 = WEP1_MINIGUN;
	}
	else
	// start next map with weapons players had at the start of current map
	if(!showingmissionscores)	// forced map change via changlevel command	
	{
	print("SETCHANGE 2\n");
		carryitems1 = WEP1_MINIGUN;
		}
	else
	{
		print("SETCHANGE 3\n");
		carryitems1 = self.items1;
		carryitems2 = self.items2;
	}
		
	parm1 = carryitems1;
	parm2 = carryitems2;
	parm3 = self.earneditems1;
	parm4 = self.earneditems2;
	parm5 = self.initializeditems;	
}*/
	
/*float activestartframe;
void FirstStartFrame() =
{
	activestartframe = TRUE;
//	InitializeTrains();	
//	InitializeNavigationCells();
}*/

float	autosavemissiontime;
.vector	lastorigin;
void StartFrame() =
{
//	world.maxscoreviewingtime = cvar("sv_maxscoreviewingtime");
//	PrintNumEntsInList("BEGIN START FRAME");	

	local float minutes;
	local entity e;
	
	#ifdef COMPILE_SERVICE_ONLIVE
		if(savescorestime)
		if(savescorestime <= time)
		{
			SaveScores(TRUE);
			SendMissionScores(MSG_ALL);		
			savescorestime = 0;
		}
	#endif
	
/*	minutes = cvar("editor_autosaveminutes");
	
	// only autosave in offline editor mode or multiplayer while editor is running
	if(autosavemissiontime <= time-minutes*60)
	if((!singleplayer && maxplayers == 1)	// offline editor mode
	|| (maxplayers > 1 && adminmodeactive))	// multiplayer with editor on
	{
		SaveEntities(TRUE);
		autosavemissiontime = time;
		bprint("Autosaving mission backup.\n(");
		bprint(ftos(minutes));
		bprint(" minutes until next autosave.)\n");
	}*/

	UpdateLanguage();

	if(cvar("sv_allowdownloads"))
		cvar_set("sv_allowdownloads", "0");

	if(server_loadingobjectsfromfile)
	{
		ParseObjectsFromFile();
		return;
	}
	
	if(server_bottleneck_ent)
		SendBottleNeckedAdminEnts();

//	if(!adminmodeactive)
//		ManageSectors();		
		
//	if(list_loadingsectorentchain)
//		SendBottleNeckedSectorEnts();
		
	local vector ang, sorg;
	
	e = list_mobileentchain;
	while(e)
	{
		e.lastorigin = e.origin;
	
		if(IsAssignedFunction(e.FastThink))
			Func_oself(e, e.FastThink);
	
		if(e.tag_entity)
			Func_oself(e, AI_TurretMove);
			
		if(e.facetarget)
	//	if(e.waittomovetime < time)
		{
			if(IsAttachedAIClass(e.npcclass))// == NPC_TURRET)
				sorg = e.owner.origin;
			else
				sorg = e.origin;
		
//			ang = vectoangles(e.facetarget.origin - sorg);

			ang = GetLeadAngle(sorg, e.facetarget, e.weapon);
			
			e.ideal_yaw = ang_y;
		}
			
		if(e.ideal_yaw)
		if((!e.tag_entity && e.stuntime <= time)
		|| (e.tag_entity && e.tag_entity.stuntime <= time))
			Func_oself(e, ChangeYaw);
		
		if(e.ideal_yaw)
		if(e.class == CLASS_SHOT)
		{
			ang = e.angles;
			ang_x = -ang_x;
			makevectors(ang);
			e.velocity = v_forward*vlen(e.velocity);
		}
			
	//	print(ftos(e.angles_y));print(" update in main\n");	
		
		UpdateSharedEnt(e);	
			
		e = e.mobileentchain;
	}
	
/*	if(!activatedtrains)
	if(time > 5)
		InitializeTrains();
	
	if(!activestartframe)
		FirstStartFrame();*/
	
	if(vote_applysettingstime)
	{
		if(time > vote_applysettingstime)
		{
			ApplyVoteSettings();
			return;
		}
	}
	else
	if(vote_tallytime)
	{
		if(time >= vote_tallytime)
		{
			CountVotes();
			return;
		}
	}
		
	if((server_restarttime && time > server_restarttime)
	|| (emptyserver_restarttime && time > emptyserver_restarttime + cvar("sv_emptyserverrestarttime")*60))
	{
		localcmd("restart\n");
		return;
	}
		
	if(!activityhalted)
	if(mission_maptime_total > 0)
	if(time > mission_maptime_start + mission_maptime_total)
	if(!adminmodeactive)
	if(!(maxplayers <= 1 && !singleplayer)) // offline editor mode
		MissionTimeUp(MSG_ALL);
		
//	PrintNumEntsInList("END START FRAME");			
}