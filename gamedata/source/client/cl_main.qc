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
// --------------------------------------------------------------------------
// BEGIN REQUIRED CSQC FUNCTIONS

// CSQC_Init : Called every time the CSQC code is initialized (essentially at map load)
void RequestEpisode() =	{	localcmd(strcat("cmd episode ", ftos(cvar("episode")), "\n"));	}

void CSQC_Init(void)
{
	CODEBASE = CLIENTCODE;

	local float file, mapheight;
	local string mapimgname;

	currentlanguage = cvar("localize_language");
	SetLanguageFontScale();
	unlocked_fpscamera = cvar("chase_fpscam");

	mapwidth = max(world.maxs_x*GetFloatPolarity(world.maxs_x), world.mins_x*GetFloatPolarity(world.mins_x));
	mapheight = max(world.maxs_y*GetFloatPolarity(world.maxs_y), world.mins_y*GetFloatPolarity(world.mins_y));	
	
	if(mapheight > mapwidth*0.75)
		mapwidth = mapheight/0.75;
		
	mapwidth = mapwidth*3;	
	
	mapimgname = substring(mapname, 0, strlen(mapname)-3);
	mapimgname = strcat(mapimgname, "tga");
	
	file = FileOpen(mapimgname, FILE_READ);
	if(file != -1)
	{
		mapimageexists = true;
		fclose(file);
	}
	else
	{
	//	print("Missing radar image: ");
	//	print(mapimgname);
	//	print("\n");
	
		
	
	}
	
	if(mapimageexists)
		precache_pic(mapimgname);

//	Precache_Models();
//	Precache_Sounds();

	Video_Update();
	Effect_Init();
	Waypoint_Init();
	Menu_Init();
	
	randomscale_min = 0.9;
	randomscale_max = 1.1;
	
//	playerviewsetting_fpscam = cvar("chase_fpscam");
}
// CSQC_Shutdown : Called every time the CSQC code is shutdown (changing maps, quitting, etc)
void CSQC_Shutdown(void)
{
}
// CSQC_ConsoleCommand : Used to parse commands in the console that have been registered with the "registercmd" function
// Return value should be 1 if CSQC handled the command, otherwise return 0 to have the engine handle it.
float CSQC_ConsoleCommand(string strMessage)
{
	local float nReturn;
		nReturn = true;
	
	// Tokenize String
	tokenize(strMessage);
	
	// Acquire Command
	local string strCmd;
		strCmd = argv(0);
	
	switch(strCmd)
	{
		default:
			nReturn = false;
			break;
	}
	
	return nReturn;
}
// CSQC_InputEvent : Used to perform actions based on any key pressed or released by the client.
// Return value should be 1 if CSQC handled the key press, otherwise return 0 to have the key passed to the engine.
float CSQC_InputEvent(float inputstate, float f1, float f2)
{
	local float skipkey, keyreleased, key, ucskey;
	
	skipkey = false;
	
	if(keyreleased >= 0 && keyreleased <= 1)
	{
		keyreleased = inputstate;
		key = f1;
		ucskey = f2;
		
		InterfaceKeys(keyreleased, key, ucskey);

		if(!keyreleased)
			skipkey = !ServerKeys(key);	
	}
	
	return skipkey;
}

// END REQUIRED CSQC FUNCTIONS
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// BEGIN OPTIONAL CSQC FUNCTIONS

//#ifdef USE_CSQC_OPTIONALFUNCTIONS
// CSQC_Ent_Update : Called every frame that the server has indicated an update to the SSQC / CSQC entity has occured.
// The only parameter reflects if the entity is "new" to the client, meaning it just came into the client's PVS.
void CSQC_Ent_Update(float isnew)
{
	float i;
	i = ReadByte();
	
	self.isshared = true;
	
//	if(i != CLASS_CELL)
//		NotCellChain_Add(self);
	
//	if(i == CLASS_CELL)
//		UpdateCell(isnew);//, ReadByte());
//	else
	if(i == ENT_PATH)
		UpdatePath(isnew);
	else
	if(i == ENT_PARTICLEEMITTER)
		UpdateParticleEmitter(isnew);
	else
	if(i == ENT_AMBIENTSOUND)
		UpdateAmbientSound(isnew);		
	else
	if(i == ENT_OBJECT)
		UpdateObject(isnew);
	else
	if(i == ENT_PROJECTILE)
		UpdateProjectile(isnew);
	else
	if(i == ENT_BULLET)
		UpdateBullet(isnew);		
	else
	if(i == ENT_BEAM)
		UpdateBeam(isnew);
	else
	if(i == ENT_PLAYER)
		UpdatePlayer(isnew);
	else
	if(i == ENT_NPC)
		UpdateNPC(isnew);
	else
	if(i == ENT_TRAIN)
		UpdateTrain(isnew);
	else
	if(i == ENT_TEAM)
		UpdateTeam(isnew);
	else
	if(i == ENT_OBJECTIVE)
		UpdateObjective(isnew);
}
// CSQC_Ent_Remove : Called when the server requests a SSQC / CSQC entity to be removed.  Essentially call remove(self) as well.
void CSQC_Ent_Remove()
{
//	if(IsAssignedFunction(self.RemoveFunc))

	self.isshared = false;

	if(self.RemoveFunc && self.RemoveFunc != SUB_Null)
		self.RemoveFunc(self);
	else
		SH_RemoveEnt(self);
}

void GameCommand(string strMessage) =
{
	switch(strMessage)
	{
		case "localize_generate":	GenerateMenuFiles();		break;
		case "escmenu_true":		ESCMENU = true;								break;
		case "escmenu_false":		ESCMENU = false;	UpdateBindMap();		break;
	}
}

// CSQC_Parse_StuffCmd : Provides the stuffcmd string in the first parameter that the server provided.  To execute standard behavior, simply execute localcmd with the string.
void CSQC_Parse_StuffCmd(string strMessage)
{	
	localcmd(strMessage);
}
// CSQC_Parse_Print : Provides the print string in the first parameter that the server provided.  To execute standard behavior, simply execute print with the string.
void CSQC_Parse_Print(string strMessage)
{
	print(strMessage);
}

void DrawCenterPrintMessages() =
{
	local vector pos, fsize;
	local entity e, nexte;
	local float alph, buffersize, count;
	local string s;
	
	drawfont = FONT_USER2;
	body_fontcolor = '0.46 0.62 0.75';
	body_fontflags = 0;
	
	e = list_centerprintchain;	
	while(e)
	{
		nexte = e.centerprintchain;
	
		if(e.borntime+5 > time)
		{
			alph = 0.7;
		
			if(time < e.borntime+0.5)
				alph = alph - ((e.borntime+0.5-time)/0.5)*0.5;
			else
			if(time > e.borntime+3)
				alph = ((e.borntime+5-time)/2)*0.7;
			
			buffersize = GetBufferSize(e.buf_contents);
//			for(count = buffersize-1; count >= 0; count-=1)
			for(count = 0; count < buffersize; count++)
			{
				s = GetBufferString(e.buf_contents, count);
				fsize = FitFontSizeToWidth(s, vid_size_x-40, '20 20 0');
				pos_x = (vid_size_x-stringwidth(s, 0, fsize))*0.5;
				if(pos_y == 0)
					pos_y = 100;
				else
				if(count == 0)//< buffersize-1 && buffersize > 1)
					pos_y += 30;
				else
					pos_y += 22;
					
				drawstring(pos, s, fsize, e.color, alph, body_fontflags);
			}
		}
		else
		{
			CenterPrintChain_Remove(e);
			DeleteBuffer(e.buf_contents);
			SH_RemoveEnt(e);
		}
			
		e = nexte;
	}
}

void SpawnCenterPrintText(string s, vector rgb) =
{
	local entity p, e;
	local float tokens, count;
	
	p = spawn();
	p.borntime = time;
	p.color = rgb;
	p.buf_contents = CreateBuffer();
	
	tokens = tokenizebyseparator(s, "\n", ";");
	for(count = 0; count < tokens; count++)
		AddBufferString(p.buf_contents, argv(count), 0);
	
	for(e = list_centerprintchain; e.centerprintchain; e = e.centerprintchain)
	{}
	
	if(e)
	{
		e.centerprintchain = p;
		p.centerprintchain_prev = e;
	}
	
	if(!list_centerprintchain)
		list_centerprintchain = p;
	
//	CenterPrintChain_Add(e);
}

string CPM_TutorialKeys(string s, float keynum) =
{
	local string keyname;
	keyname = GetShortKeyListForControlID(keynum, false);
	s = sprintf(s, keyname);
	
	return s;
}

string CPM_ExtendedInfo_Flag(string s) =
{
	local string name, teamname;
	local float t;
	
	name = ReadString();
	t = ReadLong();
	teamname = GetTeamName(t);
	s = sprintf(s, name, teamname);

	return s;
}

string GetCenterPrintMessage(float msgid) =
{
	local float translate;
	local string keyname, filename, s, str_cantfinishgamewhileadminisediting, str_cantaccessexitpadswhileadminisediting, str_primaryobjectivesincomplete, str_forcefieldopened, str_findawaytoopenforcefield, str_findadatakey, str_useddatakey, str_usedcorruptfusioncore, str_fusioncoreneeded, str_weaponpickup, str_minigun, str_flackgun, str_beamcannon, str_thunderbolt, str_stormplow,str_stormspread, str_stormshield, str_rocketpod, str_homingmissiles, str_mirv, str_shockwave, str_shockwavepickup, str_secondaryswitch, str_secondaryfire, str_flagdropped, str_flagpickup, str_flagreturn, str_flagcapture;
	
	translate = skiptranslation;
	skiptranslation = false;
	
	filename = __FUNC__;
	buf_localizecenterprintmessages = InitializeNonstandardTranslations(buf_localizecenterprintmessages, filename, false);
	
	str_cantfinishgamewhileadminisediting		= Localize("Cannot finish a game while an administrator is actively editing the mission.", buf_localizecenterprintmessages);
	str_cantaccessexitpadswhileadminisediting	= Localize("Cannot access exit pads while an administrator is actively editing the mission.", buf_localizecenterprintmessages);
	str_primaryobjectivesincomplete				= Localize("You have not finished all of the primary objectives.", buf_localizecenterprintmessages);
	str_forcefieldopened						= Localize("Check your map.", buf_localizecenterprintmessages);
	str_findawaytoopenforcefield				= Localize("You must find a way to open this force field.", buf_localizecenterprintmessages);
	str_findadatakey							= Localize("Find a data key.", buf_localizecenterprintmessages);
	str_useddatakey								= Localize("Data key used.", buf_localizecenterprintmessages);
	str_usedcorruptfusioncore					= Localize("Corrupt fusion core used.", buf_localizecenterprintmessages);
	str_fusioncoreneeded						= Localize("A fusion core can be installed here.", buf_localizecenterprintmessages);
	str_weaponpickup							= Localize("You've picked up %s!", buf_localizecenterprintmessages);
	str_minigun									= Localize("The Minigun", buf_localizecenterprintmessages);
	str_flackgun								= Localize("The Flack Gun", buf_localizecenterprintmessages);
	str_beamcannon								= Localize("The Beam Cannon", buf_localizecenterprintmessages);
	str_thunderbolt								= Localize("The Thunderbolt", buf_localizecenterprintmessages);
	str_stormplow								= Localize("The Storm Plow", buf_localizecenterprintmessages);
	str_stormspread								= Localize("The Storm Spread", buf_localizecenterprintmessages);
	str_stormshield								= Localize("The Storm Shield", buf_localizecenterprintmessages);
	str_rocketpod								= Localize("The Rocket Pod", buf_localizecenterprintmessages);
	str_homingmissiles							= Localize("Homing Missiles", buf_localizecenterprintmessages);
	str_mirv									= Localize("The MIRV", buf_localizecenterprintmessages);
	str_shockwave								= Localize("The Shockwave Device", buf_localizecenterprintmessages);	
	str_shockwavepickup							= Localize("Press %s to use the Shockwave.", buf_localizecenterprintmessages);	
	str_secondaryswitch							= Localize("Press %s to switch secondary weapons.", buf_localizecenterprintmessages);
	str_secondaryfire							= Localize("Press %s to fire your secondary weapon.", buf_localizecenterprintmessages);
	str_flagdropped								= Localize("%s has dropped the %s flag!", buf_localizecenterprintmessages);
	str_flagpickup								= Localize("%s has the %s flag!", buf_localizecenterprintmessages);
	str_flagreturn								= Localize("%s has returned the %s flag!", buf_localizecenterprintmessages);
	str_flagcapture								= Localize("%s has captured the %s flag!", buf_localizecenterprintmessages);
	WriteNonstandardTranslations(buf_localizecenterprintmessages, filename, false, false);	
	
	skiptranslation = translate;
	
	switch(msgid)
	{
		case CPM_CANTFINISHGAMEWILEADMINISEDITING:			s = str_cantfinishgamewhileadminisediting;		break;
		case CPM_CANTACCESSEXITPADSWHILEADMINISEDITING:		s = str_cantaccessexitpadswhileadminisediting;		break;
		case CPM_PRIMARYOBJECTIVESINCOMPLETE:				s = str_primaryobjectivesincomplete;		break;
		case CPM_FORCEFIELDOPENED:							s = str_forcefieldopened;			break;
		case CPM_FINDAWAYTOOPENFORCEFIELD:					s = str_findawaytoopenforcefield;	break;
		case CPM_FINDADATAKEY:								s = str_findadatakey;	break;
		case CPM_USEDDATAKEY:								s = str_useddatakey;	break;
		case CPM_USEDCORRUPTFUSIONCORE:						s = str_usedcorruptfusioncore;	break;
		case CPM_FUSIONCORENEEDED:							s = str_fusioncoreneeded;	break;
		case CPM_PICKUP_MINIGUN:							s = sprintf(str_weaponpickup, str_minigun);	break;
		case CPM_PICKUP_FLACKGUN:							s = sprintf(str_weaponpickup, str_flackgun);	break;
		case CPM_PICKUP_BEAMCANNON:							s = sprintf(str_weaponpickup, str_beamcannon);	break;
		case CPM_PICKUP_THUNDERBOLT:						s = sprintf(str_weaponpickup, str_thunderbolt);	break;
		case CPM_PICKUP_STORMPLOW:							s = sprintf(str_weaponpickup, str_stormplow);	break;
		case CPM_PICKUP_STORMSPREAD:						s = sprintf(str_weaponpickup, str_stormspread);	break;
		case CPM_PICKUP_STORMSHIELD:						s = sprintf(str_weaponpickup, str_stormshield);	break;
		case CPM_PICKUP_ROCKETPOD:							s = sprintf(str_weaponpickup, str_rocketpod);	break;
		case CPM_PICKUP_HOMINGMISSILES:						s = sprintf(str_weaponpickup, str_homingmissiles);	break;
		case CPM_PICKUP_MIRV:								s = sprintf(str_weaponpickup, str_mirv);		break;		
		case CPM_PICKUP_SHOCKWAVE:
			s = sprintf(str_weaponpickup, str_shockwave);
			s = strcat(s, "\n");
			s = strcat(s, CPM_TutorialKeys(str_shockwavepickup, CTRL_FIRESHOCKWAVE));
			break;
		case CPM_SECONDARYSWITCH:							s = CPM_TutorialKeys(str_secondaryswitch, CTRL_TOGGLESECONDARY);	break;
		case CPM_SECONDARYFIRE:								s = CPM_TutorialKeys(str_secondaryfire, CTRL_FIRESECONDARY);	break;
		
		case CPM_FLAG_DROPPED:								s = CPM_ExtendedInfo_Flag(str_flagdropped);		break;
		case CPM_FLAG_PICKUP:								s = CPM_ExtendedInfo_Flag(str_flagpickup);		break;	
		case CPM_FLAG_RETURN:								s = CPM_ExtendedInfo_Flag(str_flagreturn);		break;
		case CPM_FLAG_CAPTURE:								s = CPM_ExtendedInfo_Flag(str_flagcapture);		break;				
	}	
	
	return s;
}

void TE_CenterPrintMessage() =
{
	local float msgid;
	local string s;
	
	msgid = ReadByte();
	s = GetCenterPrintMessage(msgid);
	SpawnCenterPrintText(s, '1 1 1');
}

// CSQC_Parse_CenterPrint : Provides the centerprint string in the first parameter that the server provided.  To execute standard behavior, simply execute cprint with the string.
void CSQC_Parse_CenterPrint(string strMessage)
{
//	local float count, tokens;

//	tokens = tokenizebyseparator(strMessage, "\n");
//	for(count = 0; count < tokens; count++)
		SpawnCenterPrintText(strMessage, '1 1 1');
//	cprint(strMessage);
}

/*void RemoveTempEnt() =
{
	local entity e;
	local float e_id;
	e_id = ReadShort();
	e = findfloat(world, id, e_id);
	if(e)
		SH_RemoveEnt(e);
}*/

// CSQC_Parse_TempEntity : Handles all temporary entity network data in the CSQC layer.
// You must ALWAYS first acquire the temporary ID, which is sent as a byte.
// Return value should be 1 if CSQC handled the temporary entity, otherwise return 0 to have the engine process the event.
float CSQC_Parse_TempEntity()
{
	local float bHandled;
		bHandled  = true;
	// Acquire TE ID
	local float nTEID;
		nTEID = ReadByte();
		
	switch(nTEID)
	{
		case TE_MISSIONLOCKSTATUS:			mission_locked = ReadByte();			break;
	
		case TE_REQUESTEPISODENUM:				RequestEpisode();					break;
		case TE_REQUESTJOINPASSWORD:			Call_GetJoinPassword();				break;
		case TE_GAMEJOINGRANTED:				GameJoinGranted();					break;
		case TE_GAMEJOINDENIED:					GameJoinDenied();					break;
	
		case TE_TOGGLEADMINMODE:			ToggleAdminMode();					break;
		case TE_ADMINMODEACTIVE:			AdminModeActive();					break;
		case TE_ADMINMODETOGGLE_MAXENTS:	localcmd("menu_cmd admintoggle_maxents");			break;
	//	case TE_TOGGLEWAYPOINTEDITINGMODE:	CL_ToggleWaypointEditingMode();		break;		
	//	case TE_SENDWAYPOINT:				RecieveWaypoint();					break;		
	//	case TE_REMOVEENT:					RemoveTempEnt();					break;
	//	case TE_WIPECLASS:					WipeClass();						break;	

//		case TE_RADARUPDATE:				RadarUpdate();						break;

//		case TE_BULLET:						NewBullet(TE_BULLET);				break;
//		case TE_MINIGUNBULLETS:				NewMinigunBullets();				break;
//		case TE_BEAM:						NewBullet(TE_BEAM);					break;
//		case TE_BEAM_HIT:					BeamHit();							break;
		case TE_SHOCKWAVE:					Shockwave();						break;
//		case TE_THUNDERBOLT:				NewBullet(TE_THUNDERBOLT);			break;
//		case TE_THUNDERBOLT_SPREAD:			NewBullet(TE_THUNDERBOLT_SPREAD);	break;
		
		case TE_MISSIONTRACK:							SetMissionTrackFromServer();				break;
		case TE_MISSIONBRIEFING:						SetMissionBriefingFromServer();				break;
		
		case TE_ALLOWCAMPAIGNCREATION:					SetNewCampaignName();						break;
		case TE_DENYCAMPAIGNCREATION:					SetNewCampaignName_CampaignExists();		break;
		
		case TE_ALLOWMISSIONSAVE:						AllowMissionSave();							break;
		case TE_OVERWRITEMISSIONCONFIRMATION:			Call_OverwriteMissionConfirmation();		break;

		case TE_GAMEMODELIST:							Call_GameModeList();						break;		
		case TE_CAMPAIGNLIST:							Call_CampaignList();						break;
		case TE_MISSIONLIST:							Call_MissionList();							break;
		
		case TE_DEAD:									Call_DeathMenu();							break;
		case TE_GAMEOVERFORPLAYER:						Call_GameOver_Player();						break;
		case TE_GAMEOVERFORALL:							Call_GameOver_All();						break;
		case TE_SHOWMISSIONSCORES:						ShowMissionScores();						break;
		case TE_PLAYERSFINISHEDVIEWINGMISSIONSCORES:	PlayersFinishedViewingMissionScores();		break;
		case TE_CONNECTED:								Connection_Init();							break;
		case TE_GETCLIENTSTATS:							GetClientStats();							break;
				
		case TE_SENDCHALLENGES:						ReceiveChallenges();						break;
		case TE_SAVECHALLENGES:						SaveChallenges();							break;
				
		case TE_CHOOSETEAM:								Call_ChooseTeam();							break;	

		case TE_OBJECTIVETEXT:							UpdateObjectiveText();						break;
		
		case TE_CENTERPRINT:							TE_CenterPrintMessage();					break;
		
		case TE_TERMINAL_OPEN:							OpenTerminal();								break;
		case TE_TERMINAL_CLOSE:							CloseTerminal();							break;
		
		case TE_GETSERVERPASSWORD:						Call_GetServerPassword();					break;
		case TE_ADMINACCESSDENIED:						AdminAccessDenied();						break;
		case TE_ADMINACCESSGRANTED:						AdminAccessGranted();						break;		
		
		case TE_VOTEMENU:								Call_VoteMenu();							break;
		case TE_VOTESTATS:								SetVoteStats();								break;
		
		#ifdef COMPILE_SERVICE_ONLIVE
			case TE_ASKFORPLAYERNAME:						MissionComplete_RealArcade();							break;
		#endif
		
		default:
			// No special logic for this temporary entity; return 0 so the engine can handle it
			bHandled = false;
			break;
	}
		
	return bHandled;
}
//#endif