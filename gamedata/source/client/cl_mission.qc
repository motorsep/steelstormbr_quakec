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
string GenerateProfileGlobalItemsString(entity e, float f1, float f2) =	{	return string_null;	}
string GenerateProfileItemString(entity e) =	{	return string_null;	}

void ReceiveChallenges() =
{
	local string challenges;
	challenges = ReadString();

	GenerateChallenges(challenges, false, false);	
}

void SaveChallenges() =
{
	local string challenges;
	challenges = ReadString();

	if(!player)
		return;
	
	GenerateChallenges(challenges, false, false);	
	SaveProfile(player, challenges, false);
}

float GetTimeBonus(entity e) =	{	return 0;	}
float GetStatFromScoreString(string s, string stat) =	{	return	0;	}

void PlayersFinishedViewingMissionScores() =
{
	localcmd("menu_cmd mission_finished\n");
	waitingonplayers = -1;
}

/*float EndMission_EditorMode() =
{
	if(maxplayers == 1)
	if(!singleplayer)//coop || deathmatch)
	{
		CloseMenu();
		localcmd("cmd missioneditor\n");
		return true;
	}

	return false;
}*/

void EndMission() =
{
//	if(EndMission_EditorMode())
//		return;

	if(singleplayer)
		CloseMenu();
//	DRAWMOUSE = false;
	waitingonplayers = true;
	localcmd("cmd endmission\n");
}

void NextMission() =	{	localcmd("cmd nextmission\n");	}

void AbortMission() =
{
	localcmd("menu_cmd mission_finished\n");
	localcmd("disconnect\n");
}

void Respawn() =
{
	player_hittime = 0;
	player_hittime_total = 0;
	CloseMenu();
	localcmd("cmd respawn\n");
}

void Close_DeathMenu() =
{
	menu_death = world;
}

void Draw_DeathMenu() =
{
	local float numitems;
	
	Menu_Start_Scoreboard("You're Dead", '300 0 0', __FUNC__);

	local string s, str_canrespawninxseconds, str_respawn, str_destroyedweapons;
	str_canrespawninxseconds	= Translate("Can respawn in %s seconds.");
	str_respawn 				= Translate("Respawn");
	str_destroyedweapons		= Translate("You have lost weapons!");
	skiptranslation = true;

	if(singleplayer)
	{
		numitems = GetBufferSize(active_menu.buf_items);	
		
		if(numitems)
		{
			Menu_Text(str_destroyedweapons);
			BR();
			DrawItemIcons(option_pos, active_menu.buf_items, true);
			BR();
			BR();
		}
	}
	
	if(GameMode_HasRespawnTime(gamemode) && time < deathtime+RESPAWNTIME)
	{
		s = sprintf(str_canrespawninxseconds, ftos(ceil(deathtime+RESPAWNTIME-time)));
		Menu_Text(s);
		BR();
	}
	else
		Menu_Option_Text(str_respawn, Respawn);
		
	Menu_End();
}

void Call_DeathMenu() =
{
	local float items1, items2, wep;
	local entity menu;
	
	items1 = ReadLong();
	items2 = ReadLong();

	if(menu_death)
	{
		CloseMenu();
		menu_death = world;
	}

	if(list_menuchain)
	{
		menu = SpawnMenu(Draw_DeathMenu);
		MoveMenuToBottom(menu);		
	}
	else
	{
		SetCurrentMenu(Draw_DeathMenu);
		menu = currentmenu;
	}
	
	menu.ESCFunc = ESCFunc_AllowESCMenu;
	menu.CloseMenuFunc = Close_DeathMenu;
	menu.buf_items = CreateBuffer();
	menu_death = menu;
	deathtime = time;
	
	if(singleplayer)
	{
		for(wep = 1; wep <= 16777215; wep = wep*2)
		{
			if(items1 & wep)
				AddBufferString(menu.buf_items, GetItemIcon(1, wep), 0);
		}
		
		for(wep = 1; wep <= 16777215; wep = wep*2)
		{
			if(items2 & wep)
				AddBufferString(menu.buf_items, GetItemIcon(2, wep), 0);
		}	
	}
}

void Draw_GameOver_Player() =
{
	Menu_Start_Scoreboard("", '300 0 0', __FUNC__);

	Menu_Text("GAME OVER");
	BR();

	Menu_Text("There are no more ships in the hangar.");
	BR();

	Menu_End();
}

void Call_GameOver_Player() =
{
	if(menu_death)
	{
		CloseMenu();
		menu_death = world;
	}
	
	SetCurrentMenu(Draw_GameOver_Player);
	currentmenu.ESCFunc = ESCFunc_AllowESCMenu;
	currentmenu.CloseMenuFunc = Close_DeathMenu;	
	menu_death = currentmenu;
}

void Draw_GameOver_All() =
{
	local string s, str_gameover, str_outoftime, str_outofships, str_retry, str_abort, str_restartinginxseconds, str_restarting;
	local float restarttime;
	
	restarttime = getstatf(STAT_RESTARTTIME);
	restarttime = restarttime - time;
	
	Menu_Start_Scoreboard("", '300 0 0', __FUNC__);

	str_gameover				= Translate("GAME OVER");
	str_outoftime				= Translate("Out of time.");
	str_outofships				= Translate("Out of ships.");
	str_retry					= Translate("Retry");
	str_abort					= Translate("Abort");
	str_restartinginxseconds	= Translate("Restarting in %s seconds.");
	str_restarting				= Translate("Restarting...");
	skiptranslation = true;
		
	Menu_Text(str_gameover);
	BR();

	if(active_menu.listid)
		s = str_outoftime;
	else
		s = str_outofships;

	Menu_Text(s);
	BR();
	
	if(singleplayer)
	{
		Menu_Option_Text(str_retry, RetryMission);		
		Menu_Option_Text(str_abort, AbortMission);
	}
	else
	{
		if(restarttime > 0)
			s = sprintf(str_restartinginxseconds, ftos(ceil(restarttime)));
		else
			s = str_restarting;

		Menu_Text(s);
		BR();
	}			

	Menu_End();
}

void Call_GameOver_All() =
{
	local float msgtype;

	if(menu_death)
	{
		CloseMenu();
		menu_death = world;
	}
	
	SetCurrentMenu(Draw_GameOver_All);
	currentmenu.ESCFunc = ESCFunc_AllowESCMenu;
	currentmenu.CloseMenuFunc = Close_DeathMenu;	
	menu_death = currentmenu;
	
	currentmenu.listid = ReadByte();
}

/*void DrawScene() =
{
	if(!IsAssignedFunction(drawscene))
		return;

	drawscene();
}*/

void ShowScene(string imgname, string musictrack, string text) =
{
//	switch(scenename)
//	{
//		case "EPISODE2":
			cvar_set("menu_drawscene_imgname", imgname);
			cvar_set("menu_bgmusic", musictrack);//"music/ss_outpost_env.ogg");
			cvar_set("menu_drawscene_text", text);
			cvar_set("menu_drawscene", "1");
//			break;
//	}
	
//	CloseMenu();
}

void EndGame() =
{
	CloseMenu();

	local float file;
	local string filename, line, t;
	
	if(cvar("localize_enable"))
	{
		filename = strcat("campaign/_", uri_escape(campaign));
		filename = strcat(filename, "/local/");
		filename = strcat(filename, GetLanguageName(currentlanguage));
		filename = strcat(filename, "/campaignend.txt");
		file = FileOpen(filename, FILE_READ);	
	}
	else
		file = -1;
		
	if(file == -1)
	{
		filename = strcat("campaign/_", uri_escape(campaign));
		filename = strcat(filename, "/campaignend.txt");
		file = FileOpen(filename, FILE_READ);
	}
	
	if(file != -1)
	{
		for(line = fgets(file); line; line = fgets(file))
		{
			tokenize(line);
			t = argv(0);
			switch(t)
			{
				case "SHOW_SCENE":		ShowScene(argv(1), argv(2), argv(3));		break;
			}
		}
		
		fclose(file);
	}
	
	EndMission();
}

void JoinTeam(string s_team) =
{
	localcmd(strcat("cmd jointeam ", s_team, "\n"));
	CloseMenu();
}

void JoinTeam_Red() =	{	JoinTeam("1");	}
void JoinTeam_Blue() =	{	JoinTeam("2");	}

void CloseMissionBriefing() =
{
	menu_missionbriefing = world;
	ClearObjectiveBuffers(active_menu);
	
	if(singleplayer)
	if(timestopped)
	{
//		maptime_current = time;
		timestopped = false;
		localcmd("cmd closemissionbriefing\n");	
	}
}

void Draw_MissionBriefing() =
{
	local float blockheight, count, buf, numprimaryobjectives, numsecondaryobjectives, indentsize;
	local vector textblocksize;
	local string s;
	local entity e;
	
	Menu_Start_OptionMenu("Mission Briefing", '400 0 0', __FUNC__);

	local string str_primaryobjectives, str_secondaryobjectives, str_complete;
	str_primaryobjectives		= Translate("PRIMARY OBJECTIVES");
	str_secondaryobjectives		= Translate("SECONDARY OBJECTIVES");
	str_complete				= Translate("(COMPLETE)");
	skiptranslation = true;
	
	indentsize = 14;
	textblocksize_x = 400 - border_size_x*2 - body_margin_x*2;
	textblocksize_y = 400;

	s = mission_briefing[currentlanguage];
	active_menu.buf_textblock = DrawTextBlock(active_menu.buf_textblock, option_pos, -1, textblocksize, s, body_fontsize, body_fontcolor, body_fontalpha, body_fontflags);

	BR();
	textblocksize_x -= indentsize;
	textblocksize_y = 0;

	for(e = list_objectivechain; e; e = e.objectivechain)
	{
		if(e.objectivepriority == 0)
			numprimaryobjectives++;
		else
		if(e.objectivepriority == 1)
			numsecondaryobjectives++;	
	}
	
	if(numprimaryobjectives)
	{
		DrawElement_OptionTitle(str_primaryobjectives);
		
		for(e = list_objectivechain; e; e = e.objectivechain)
		{
			if(e.objectivepriority != 0)
				continue;
		
			Menu_Text("-");
			option_pos_x += indentsize;
		
			s = e.objectivetext[currentlanguage];
			if(e.istoggled)
				s = strcat(str_complete, SEP_SPACE, s);
			buf = active_menu.(buf_textblock_objectives_primary[count]);
			active_menu.(buf_textblock_objectives_primary[count]) = DrawTextBlock(buf, option_pos, -1, textblocksize, s, body_fontsize, '0.46 0.62 0.75', body_fontalpha, body_fontflags);
			count++;
			
			option_pos_x -= indentsize;
		}
	}
	
	if(numsecondaryobjectives)
	{
		if(numprimaryobjectives)
			BR();
	
		DrawElement_OptionTitle(str_secondaryobjectives);
		
		for(e = list_objectivechain; e; e = e.objectivechain)
		{
			if(e.objectivepriority != 1)
				continue;
		
			Menu_Text("-");
			option_pos_x += indentsize;
		
			s = e.objectivetext[currentlanguage];
			if(e.istoggled)
				s = strcat(str_complete, SEP_SPACE, s);			
			buf = active_menu.(buf_textblock_objectives_secondary[count]);
			active_menu.(buf_textblock_objectives_secondary[count]) = DrawTextBlock(buf, option_pos, -1, textblocksize, s, body_fontsize, '0.46 0.62 0.75', body_fontalpha, body_fontflags);
			count++;
			
			option_pos_x -= indentsize;
		}
	}	
	
	skiptranslation = false;
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Close", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();		

	Menu_End();			
}

void ToggleMissionBriefing() =
{
	if(menu_scores)
	{
		currentmenu = menu_scores;
		CloseMenu();
	}		

	if(!menu_missionbriefing && !currentmenu.menu_style & STYLE_PRIORITY)
	{
		SetCurrentMenu(Draw_MissionBriefing);
		menu_missionbriefing = currentmenu;
		currentmenu.CloseMenuFunc = CloseMissionBriefing;
	}
	else
	if(currentmenu == menu_missionbriefing)
		CloseMenu();
}

void SetMissionBriefingFromServer() =
{
	local float count;
	local string s;

	s = ReadString();
	tokenize(s);
	for(count = 0; count < NUMLANGUAGES; count++)
	{
		s = mission_briefing[count];
		s = zonecpy(s, argv(count));
		mission_briefing[count] = s;
	}
}

float	vote_force;
float	vote_gamemode_t;
float	server_allowgamemode_campaign;
float	server_allowgamemode_deathmatch;
float	server_allowgamemode_ctf;	

float	vote_current_type;
float	vote_current_kickplayer;
float	vote_current_force;
float	vote_current_gamemode;
string	vote_current_campaign;
string	vote_current_mission;
float	vote_current_fraglimit;
float	vote_current_capturelimit;	

void ClearVoteStats() =
{
	vote_current_type = 0;
	vote_current_force = false;
	vote_current_gamemode = 0;
	vote_current_campaign = freezone(vote_current_campaign);
	vote_current_mission = freezone(vote_current_mission);
	vote_current_fraglimit = 0;
	vote_current_capturelimit = 0;	
}

void DrawElement_VoteStat(vector pos, string s, string s_stat) =
{
	local float colwidth1, colwidth2;
	local vector pos_stat_ofs, fontsize, fsize;

	fontsize = '9 9 0'*languagefontscale;	
	colwidth1 = 100;
	colwidth2 = 250 - colwidth1 - 8 - 16;
	pos_stat_ofs_x = colwidth1 + 8;

	fsize = FitFontSizeToWidth(s, colwidth1, fontsize);
	drawstring(pos, s, fsize, '1 1 1', 1, 0);	
	fsize = FitFontSizeToWidth(s_stat, colwidth2, fontsize);	
	drawstring(pos+pos_stat_ofs, s_stat, fsize, '1 1 1', 1, 0);
}

void Draw_VoteStats() =
{
	local float vote_applysettingstime, vote_tallytime, ballot, tally_yes, tally_no, col1width, linespacing, timeleft;
	local vector pos, bgsize, fontsize, fsize;
	local string s, keyname;
	local entity e;
	
	vote_applysettingstime = getstatf(92);	
	vote_tallytime = getstatf(93);

	if(!vote_applysettingstime)
	if(!vote_tallytime)
	if(!LOCALIZE_GENERATING)
	{
		if(vote_current_type)
			ClearVoteStats();
		return;
	}
		
	local string filename, str_voteinprogress, str_applyingsettings, str_gamemode, str_campaign, str_mission, str_fraglimit, str_capturelimit, str_kick, str_timeleft, str_voteyes, str_voteno, str_tally, str_yes, str_no, str_youvoted;
	local float translate;
	translate = skiptranslation;
	skiptranslation = false;	
	filename = __FUNC__;
	buf_localizevotestats = InitializeNonstandardTranslations(buf_localizevotestats, filename, false);
	str_voteinprogress			= Localize("Vote In Progress", buf_localizevotestats);
	str_applyingsettings		= Localize("Applying Settings", buf_localizevotestats);
	str_gamemode				= Localize("Game Mode:", buf_localizevotestats);
	str_campaign				= Localize("Campaign:", buf_localizevotestats);
	str_mission					= Localize("Mission:", buf_localizevotestats);
	str_fraglimit				= Localize("Frag Limit:", buf_localizevotestats);
	str_capturelimit			= Localize("Capture Limit:", buf_localizevotestats);
	str_kick					= Localize("Kick:", buf_localizevotestats);
	str_timeleft				= Localize("Time Left:", buf_localizevotestats);
	str_voteyes					= Localize("To Vote Yes Press:", buf_localizevotestats);
	str_voteno					= Localize("To Vote No Press:", buf_localizevotestats);
	str_tally					= Localize("Tally", buf_localizevotestats);
	str_yes						= Localize("YES", buf_localizevotestats);
	str_no						= Localize("NO", buf_localizevotestats);
	str_youvoted				= Localize("You Voted:", buf_localizevotestats);
	WriteNonstandardTranslations(buf_localizevotestats, filename, false, false);
	skiptranslation = translate;		
		
	ballot = getstati(94);
	tally_yes = getstati(90);
	tally_no = getstati(91);
	drawfont = FONT_USER2;
	fontsize = '10 10 0'*languagefontscale;	
	linespacing = 14;	
		
	pos = '10 110 0';
	bgsize = '250 250 0';
	drawfill(pos, bgsize, '0 0 0', 0.5, 0);

	pos += '8 8 0';
	
	if(vote_applysettingstime)
	{
		timeleft = vote_applysettingstime - time;
		s = str_applyingsettings;
	}
	else
	{
		timeleft = vote_tallytime - time;
		s = str_voteinprogress;
	}
		
	fsize = FitFontSizeToWidth(s, bgsize_x-16, fontsize);
	drawstring(pos, s, fsize, '1 1 1', 1, 0);
	pos_y += linespacing*2;	
	
	if(vote_current_type == VOTE_MISSION)
	{
		DrawElement_VoteStat(pos, str_gamemode, TitleString(GetGameMode_String(vote_current_gamemode, false)));
		pos_y += linespacing;

		if(vote_current_gamemode == GAMEMODE_CAMPAIGN)
		{
			DrawElement_VoteStat(pos, str_campaign, TitleString(vote_current_campaign));
			pos_y += linespacing;
		}
		
		DrawElement_VoteStat(pos, str_mission, TitleString(vote_current_mission));
		pos_y += linespacing;

		if(GameMode_HasFragLimit(vote_current_gamemode))
		{
			DrawElement_VoteStat(pos, str_fraglimit, ftos(vote_current_fraglimit));
			pos_y += linespacing;
		}
		
		if(GameMode_HasFlags(vote_current_gamemode))
		{
			DrawElement_VoteStat(pos, str_capturelimit, ftos(vote_current_capturelimit));
			pos_y += linespacing;	
		}
	}
	else
	if(vote_current_type == VOTE_KICK)
	{
		for(e = list_playerchain; e && e.id != vote_current_kickplayer; e = e.playerchain)
		{}
		
		DrawElement_VoteStat(pos, str_kick, e.netname);
		pos_y += linespacing;		
	}
	
	pos_y += linespacing;	
	
	if(!vote_current_force)
	{
		fsize = FitFontSizeToWidth(str_tally, bgsize_x-16, fontsize);
		drawstring(pos, str_tally, fsize, '1 1 1', 1, 0);
		pos_y += linespacing;	
		
		DrawElement_VoteStat(pos, strcat(str_yes, ":"), ftos(tally_yes));
		pos_y += linespacing;	
		DrawElement_VoteStat(pos, strcat(str_no, ":"), ftos(tally_no));
		pos_y += linespacing*4;		
		
		if(!ballot)
		{
			keyname = GetShortKeyListForControlID(CTRL_VOTEYES, false);
			DrawElement_VoteStat(pos, str_voteyes, keyname);
			pos_y += linespacing;
			
			keyname = GetShortKeyListForControlID(CTRL_VOTENO, false);
			DrawElement_VoteStat(pos, str_voteno, keyname);
			pos_y += linespacing*2;	
		}
		else
		{
			if(ballot-1)
				s = str_yes;
			else
				s = str_no;
			DrawElement_VoteStat(pos, str_youvoted, s);
			pos_y += linespacing*3;		
		}
	}
	
	DrawElement_VoteStat(pos, str_timeleft, ftos(ceil(timeleft)));
}

void SetVoteStats() =
{
	vote_current_type = ReadByte();
	
	if(vote_current_type == VOTE_MISSION)
	{
		vote_current_force = ReadByte();	
		vote_current_gamemode = ReadByte();
		vote_current_campaign = zonecpy(vote_current_campaign, ReadString());
		vote_current_mission = zonecpy(vote_current_mission, ReadString());
		vote_current_fraglimit = ReadShort();
		vote_current_capturelimit = ReadShort();	
	}
	
	if(vote_current_type == VOTE_KICK)
		vote_current_kickplayer = ReadLong();
}

void RequestKick_Submit(float force) =
{
	local string s;
	
	s = "cmd kickplayer ";
	
	if(force)
		s = strcat(s, "force ");
		
	s = strcat(s, ftos(active_menu.targetent.id));
	s = strcat(s, "\n");

	localcmd(s);
	
	if(force)
		CloseMenu();
	else
		CloseMenuBranch(2);
}

void RequestKick_Force() =	{	RequestKick_Submit(true);	}
void RequestKick() 		=	{ 	RequestKick_Submit(false);	}

void Draw_KickConfirm() =
{
	local float buttons, targetisadmin;

	Menu_Start_ConfirmationMenu("Kick Player?", '0 0 0', __FUNC__);

	local string str_areyousure, str_cantkickadmin, str_vote, str_force, str_cancel;
	str_areyousure		= Translate("Are you sure you want to kick %s?");
	str_cantkickadmin	= Translate("Administrators cannot be kicked.");
	str_vote			= Translate("Vote");
	str_force			= Translate("Force");
	str_cancel			= Translate("Cancel");
	skiptranslation = true;
	
	if(active_menu.targetent.hasadminaccess)
		targetisadmin = true;
		
	if(targetisadmin)
		Menu_Text(str_cantkickadmin);
	else
		Menu_Text(sprintf(str_areyousure, active_menu.targetent.netname));
	
	buttons = 1;
	if(!targetisadmin)
	{
		if(!vote_current_type)
			buttons++;
		if(player.hasadminaccess)
			buttons++;	
	}	
	
	BeginBottomButtons(buttons);
	if(!targetisadmin)
	{
		if(!vote_current_type)
			DrawElement_BottomButton(str_vote, RequestKick, 0, 0, 0, 0, MBT_CONFIRM);
		if(player.hasadminaccess)
			DrawElement_BottomButton(str_force, RequestKick_Force, 0, 0, 0, 0, MBT_CONFIRM);	
	}
	DrawElement_BottomButton(str_cancel, CloseMenu, 0, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();		
	
	Menu_End();	
}

void Call_KickConfirm() =
{
	local float count, ocount;
	local entity e;
	
	count = active_menu.listid;
	for(e = list_playerchain; ocount < count; e = e.playerchain)
		ocount++;	
	
	SetCurrentMenu(Draw_KickConfirm);
	currentmenu.targetent = e;
}

void ListOption_KickMenu(float count) =
{
	local float ocount;
	local entity e;
	
	if(LOCALIZE_GENERATING)
		return;	
	
	for(e = list_playerchain; ocount < count; e = e.playerchain)
		ocount++;
		
	active_menu.listid = count;
	Menu_Option_Text(e.netname, Call_KickConfirm);	
}

void Draw_KickMenu() =
{
	local float numplayers, numlistoptions, windowwidth;
	local entity e;
	
	Menu_Start_OptionMenu("Players", '400 500 0', __FUNC__);

	windowwidth = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - 10;
	
	for(e = list_playerchain; e; e = e.playerchain)
		numplayers++;
		
	numlistoptions = Draw_ScollingList(numplayers, 10, 0, windowwidth, 10, 10, SUB_Null, ListOption_KickMenu);

	BR();

	option_textalignment = '0 0 0';

	BeginBottomButtons(1);
	DrawElement_BottomButton("Close", CloseMenu, numlistoptions, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();			
	
	Menu_End();
}

void Call_KickMenu() =	{	SetCurrentMenu(Draw_KickMenu);	}

void CloseVoteMenu() =
{
	vote_gamemode_t = 0;
	vote_gamemode = 0;
	vote_campaign = freezone(vote_campaign);
	vote_mission = freezone(vote_mission);
	vote_fraglimit = 0;
	vote_capturelimit = 0;	
	menu_votemenu = world;
}

void ToggleForceVote() =	{	vote_force = !vote_force;	}

void RequestVote() =
{
	local string s;
	
	s = "cmd vote_submit";
	
	if(vote_force)
		s = strcat(s, " force");
	
	if(vote_gamemode != gamemode)
		s = strcat(s, " gamemode ", ftos(vote_gamemode));
	
	if(vote_campaign != campaign)
		s = strcat(s, " campaign ", vote_campaign);
	
	if(vote_mission != mission)
		s = strcat(s, " mission ", vote_mission);
	
	if(vote_fraglimit != fraglimit)
		s = strcat(s, " fraglimit ", ftos(vote_fraglimit));
	
	if(vote_capturelimit != capturelimit)	
		s = strcat(s, " capturelimit ", ftos(vote_capturelimit));
	
	s = strcat(s, "\n");
	localcmd(s);
	
	CloseMenu();
}

void ChooseMission() =
{
//	SetBufferString(active_menu.parentmenu.buf_list, 0, active_menu.listitemstring);
	
	local float parmnum;
	
	vote_gamemode = vote_gamemode_t;
	
	if(vote_gamemode_t == GAMEMODE_CAMPAIGN)
	{
		vote_campaign = zonecpy(vote_campaign, GetFilenameFromPath(active_menu.listitemstring, 2, true));
		parmnum = 3;
	}
	else
		parmnum = 2;	
	
	vote_mission = zonecpy(vote_mission, GetFilenameFromPath(active_menu.listitemstring, parmnum, true));
	
	CloseMenuBranch(1);
}

void ListOption_MissionList(float count) =
{
	local float parmnum;
	
	if(vote_gamemode_t == GAMEMODE_CAMPAIGN)
		parmnum = 3;
	else
		parmnum = 2;

	active_menu.listitemstring = GetBufferString(active_menu.buf_list, count);
	Menu_Option_Text(TitleString(GetFilenameFromPath(active_menu.listitemstring, parmnum, true)), ChooseMission);
}

void Draw_MissionList() =
{
	local float nummissions, numlistoptions, count, windowwidth, listslots;
	
	Menu_Start_OptionMenu("Select a Mission", '400 450 0', __FUNC__);

	local string str_nomissionfiles;
	str_nomissionfiles		= Translate("No mission files found.");
	skiptranslation = true;
	
	windowwidth = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - 10;
	listslots = 15;
	nummissions = GetBufferSize(active_menu.buf_list);
	
	if(!nummissions)
	{
		BR();
		Menu_Text(str_nomissionfiles); BR();
	}
	else
		numlistoptions = Draw_ScollingList(nummissions, listslots, 0, windowwidth, listslots+1, listslots, SUB_Null, ListOption_MissionList);

	BR();
	option_textalignment = '0 0 0';		
	
	skiptranslation = false;
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Cancel", CloseMenu, numlistoptions, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();			
	
	Menu_End();
}

void Call_MissionList() =
{
	local string s;
	local float buf;
	
	buf = CreateBuffer();

	s = ReadString();
	while(s != "LIST_END")
	{
		AddBufferString(buf, s, 0);
		s = ReadString();
	}	
	
	if(!IsWaitingForServerResponse(WFSR_REQUESTLISTMISSIONS))
	{
		DeleteBuffer(buf);
		return;
	}
	
	CloseMenu();
	
	SetCurrentMenu(Draw_MissionList);	
	currentmenu.buf_list = buf;
	SortBuffer(currentmenu.buf_list, 99, FALSE);	
}

void RequestFromServer_MissionList(float mode, string cname) =
{
	local string s;

	vote_gamemode_t = mode;
	
	Call_WaitingForServerMenu();	
	waitingforserverresponse = WFSR_REQUESTLISTMISSIONS;
	
	s = strcat("cmd requestlist_missions ", ftos(mode));
	s = strcat(s, SEP_SPACE, "\"", cname, "\"/n");
	localcmd(s);
}

void RequestFromServer_MissionList_Campaign(string cname) =		{ 	RequestFromServer_MissionList(GAMEMODE_CAMPAIGN, cname);	}
void RequestFromServer_MissionList_Deathmatch() =				{ 	RequestFromServer_MissionList(GAMEMODE_DEATHMATCH, "");		}
void RequestFromServer_MissionList_CTF() =						{ 	RequestFromServer_MissionList(GAMEMODE_CTF, "");			}

void CloseMenu_GameModeList() =
{
	vote_gamemode_t = vote_gamemode;
	CloseMenu();
}

void Draw_GameModeList() =
{
	Menu_Start_OptionMenu("Server Requests", '480 0 0', __FUNC__);

	option_size_x = 168;	
	option_spacing = 4;	
	
	skiptranslation = true;
	
	if(server_allowgamemode_campaign)
		Menu_Option_Text(GetGameMode_String(GAMEMODE_CAMPAIGN, false), RequestFromServer_CampaignList);
		
	if(server_allowgamemode_deathmatch)
		Menu_Option_Text(GetGameMode_String(GAMEMODE_DEATHMATCH, false), RequestFromServer_MissionList_Deathmatch);
	
	if(server_allowgamemode_ctf)
		Menu_Option_Text(GetGameMode_String(GAMEMODE_CTF, false), RequestFromServer_MissionList_CTF);	
	
	skiptranslation = false;
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Cancel", CloseMenu_GameModeList, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
		
	Menu_End();
}

void Call_GameModeList() =
{
	server_allowgamemode_campaign = ReadByte();
	server_allowgamemode_deathmatch = ReadByte();
	server_allowgamemode_ctf = ReadByte();	

	if(!IsWaitingForServerResponse(WFSR_REQUESTLISTGAMEMODES))
		return;
		
	CloseMenu();
	SetCurrentMenu(Draw_GameModeList);
}

void RequestFromServer_GameModes() =
{
	Call_WaitingForServerMenu();	
	waitingforserverresponse = WFSR_REQUESTLISTGAMEMODES;
	localcmd("cmd requestlist_gamemodes\n");
}

void SliderRules_VoteChange_FragLimit() =		{	vote_fraglimit = GetSliderValue();		}
void SliderRules_VoteChange_CaptureLimit() =	{	vote_capturelimit = GetSliderValue();		}

void Draw_VoteMenu() =
{
	local float vote_applysettingstime, vote_tallytime, allowvote, allowkick;
	
	vote_applysettingstime = getstati(92);	
	vote_tallytime = getstati(93);	
	
	if((allowvoting && !vote_applysettingstime && !vote_tallytime && !mission_locked) || vote_force)
		allowvote = true;
	if((allowvoting && !vote_applysettingstime && !vote_tallytime) || vote_force)	
		allowkick = true;

	Menu_Start_OptionMenu("Server Requests", '480 0 0', __FUNC__);

	option_size_x = 168;	
	option_spacing = 4;	
	
	local string str_gamemode, str_campaign, str_mission, str_changemission, str_fraglimit, str_capturelimit, str_adminpassword, str_force, str_submit, str_kick, str_cancel;
	str_gamemode				= Translate("Game Mode:");
	str_campaign				= Translate("Campaign:");
	str_mission					= Translate("Mission:");
	str_changemission			= Translate("Change Mission");
	str_fraglimit				= Translate("Frag Limit");
	str_capturelimit			= Translate("Capture Limit");
	str_adminpassword			= Translate("Admin Password");
	str_force					= Translate("Force");
	str_submit					= Translate("Submit");
	str_kick					= Translate("Kick");
	str_cancel					= Translate("Cancel");
	skiptranslation = true;

	if(player.hasadminaccess)
	{
		option_size_selectionbox = option_size;
		option_size_selectionbox_x = option_sliderspacing+36;
		Menu_Option_Text(str_force, ToggleForceVote);
		option_pos = GetLastLinePos();
		DrawElement_CheckBox(option_pos, option_sliderspacing, vote_force);	
		option_size_selectionbox = '0 0 0';		
		BR();
	}
	else
		Menu_Option_Text(str_adminpassword, Call_GetServerPassword);	
	
	if(allowvote)
	{
		Menu_Option_Text(str_changemission, RequestFromServer_GameModes);

		Menu_Text(str_gamemode);
		option_pos_x += option_sliderspacing;
		Menu_Text(TitleString(GetGameMode_String(vote_gamemode, false)));
		option_pos_x -= option_sliderspacing;	
		
		if(vote_gamemode == GAMEMODE_CAMPAIGN)
		{
			option_pos_y += body_fontsize_y + 8;
			Menu_Text(str_campaign);
			option_pos_x += option_sliderspacing;
			Menu_Text(TitleString(vote_campaign));
			option_pos_x -= option_sliderspacing;
		}
		
		option_pos_y += body_fontsize_y + 8;
		Menu_Text(str_mission);	
		option_pos_x += option_sliderspacing;	
		Menu_Text(TitleString(vote_mission));
		option_pos_x -= option_sliderspacing;
		BR();
		BR();
		
		option_size_selectionbox = option_size;	
		option_size_selectionbox_x = 407;	
		if(GameMode_HasFragLimit(vote_gamemode))
		{
			SliderRules = SliderRules_VoteChange_FragLimit;
			Menu_Slider_Text(str_fraglimit, vote_fraglimit, "", 0, 100, 101, 3);	
			SliderRules = SUB_Null;
			BR();		
		}

		if(GameMode_HasFlags(vote_gamemode))
		{
			SliderRules = SliderRules_VoteChange_CaptureLimit;
			Menu_Slider_Text(str_capturelimit, vote_capturelimit, "", 0, 100, 101, 3);	
			SliderRules = SUB_Null;
			BR();
		}
		option_size_selectionbox = '0 0 0';		
	}
	
	BeginBottomButtons(1+allowvote+allowkick);
	if(allowvote)
		DrawElement_BottomButton(str_submit, RequestVote, 0, 0, 0, 0, MBT_BASIC);	
	if(allowkick)
		DrawElement_BottomButton(str_kick, Call_KickMenu, 0, 0, 0, 0, MBT_BASIC);
	DrawElement_BottomButton(str_cancel, CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		

	skiptranslation = false;		
	Menu_End();
}

void Call_VoteMenu() =
{
	if(menu_votemenu)
		return;

	SetCurrentMenu(Draw_VoteMenu);
	menu_votemenu = currentmenu;
	currentmenu.CloseMenuFunc = CloseVoteMenu;
	vote_gamemode = vote_gamemode_t = gamemode;
	if(campaign)
		vote_campaign = zonecpy(vote_campaign, campaign);
	vote_mission = zonecpy(vote_mission, mission);
	vote_fraglimit = fraglimit;
	vote_capturelimit = capturelimit;	
}