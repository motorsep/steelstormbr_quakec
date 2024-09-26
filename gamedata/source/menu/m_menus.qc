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
/*string GetMissionFilename(string missionname, float local, float language) =
{
	local string filename;
	
	filename = strcat(GetGameMode_String(gamemode, true), "/");
	
	if(gamemode == GAMEMODE_CAMPAIGN)// || gametype == GAMETYPE_SINGLEPLAYER)
	{
		filename = strcat(filename, "_");
		filename = strcat(filename, uri_escape(UnderscoreString(cvar_string("campaign"))));
		filename = strcat(filename, "/");
	}
		
	filename = strcat(filename, "_");
	filename = strcat(filename, uri_escape(missionname));
	
	if(local)
		filename = strcat(filename, "/_", uri_escape(missionname), "/local/", GetLanguageName(language), "/local.txt");
	else
		filename = strcat(filename, ".mission");

	return filename;
}*/

void Draw_ErrorMenu() =
{
	local vector size;
//	local string imgname;
	
	body_alignment = '1 0 0';
	
	size_x = strlen(active_menu.bodystring)*body_fontsize_x + body_margin_x*2 + border_size_x*2;
	if(size_x < 200)
		size_x = 200;
		
	Menu_Start("Error!", POS_AUTO, size, __FUNC__);
	
/*	imgname = strcat("gfx/gui/error", ftos(active_menu.errorimgnum));
	imgname = strcat(imgname, ".jpg");
	Menu_Image_Stretch(imgname, '200 0 0', '0 0 0');
	GoToBottomOfImage();*/
	
	local string s, str_missingmissionfile, str_cantfindvalidmap;
	
	str_missingmissionfile	= Translate("Missing mission file.");
	str_cantfindvalidmap	= Translate("Can't find valid map filename.");
	
	switch(active_menu.bodystring)
	{
		case "NOMISSIONFILE":	s = str_missingmissionfile;		break;
		case "NOVALIDMAP":		s = str_cantfindvalidmap;		break;
	}	
	
	skiptranslation = true;
	Menu_Text(s); BR();
	skiptranslation = false;
	Menu_Option_Text_Cancel("Back", CloseMenu);
	Menu_End();
}

void Call_ErrorMenu(string s) =
{
	SetCurrentMenu(Draw_ErrorMenu);
	currentmenu.bodystring = s;
//	currentmenu.errorimgnum = bound(0, floor(random()*(maximgnum+1)), maximgnum);
}

void LoadMap() =
{
	local string s;
	
	cvar_set("episode", ftos(EPISODE));
	cvar_set("gameversion", ftos(EPISODE));
	cvar_set("chase_fpscam", ftos(unlocked_fpscamera));
	
	if(gametype == GAMETYPE_HOSTMULTIPLAYER)
		s = "changelevel ";
	else
		s = "map ";
	
	s = strcat(s, mission_map);
	s = strcat(s, "\n");	
	mission_map = freezone(mission_map);

	cmd(s);	
	
	gametype = GAMETYPE_HOSTMULTIPLAYER;	
	
	m_hide();	
}

void UpdateGameMode() =	{	cvar_set("sv_gamemode", ftos(gamemode));	}

void UpdateGameType() =
{
	if(gametype == GAMETYPE_SINGLEPLAYER)
		cvar_set("singleplayer", "1");
	else
		cvar_set("singleplayer", "0");
}

void UpdateMaxPlayers() =
{
	local string s;
	s = strcat("maxplayers ", cvar_string("menu_maxplayers"));
	s = strcat(s, "\n");
	localcmd(s);
}

//void UpdateItemsMode() =	{	cvar_set("sv_itemsmode", ftos(itemsmode));	}



void StartMission() =//Confirmed() =
{
//		CloseMenuBranch(menu_count-2);

//	if(gametype == GAMETYPE_MULTIPLAYER)
//	{
//		gametype = GAMETYPE_HOSTMULTIPLAYER;
//		CloseMenuBranch(menu_count-2);
//	}
//	else
	if(gametype == GAMETYPE_SINGLEPLAYER)
	{
		cvar_set("skill", ftos(cvar("profileskill")));
		cvar_set("menu_maxplayers", "1");	
	//	if(gamemode != GAMEMODE_CAMPAIGN)
	//		print("CAMPAIGN MODE WASN'T SET FOR SINGLEPLAYER!\n");
	}
	else
	if(gametype == GAMETYPE_OFFLINEMISSIONEDITOR)
	{
		cvar_set("skill", ftos(cvar("profileskill")));
		cvar_set("menu_maxplayers", "1");
	}

	UpdateGameMode();
	UpdateGameType();
	UpdateMaxPlayers();
//	UpdateItemsMode();
	
	if(gametype != GAMETYPE_SINGLEPLAYER)
	if(gamemode != GAMEMODE_CAMPAIGN)
		cvar_set("campaign", "");
	
	SetName();	
	LoadMap();
}

/*void StartMission() =
{
	local string filename, line;
	local float file, count, minversion;

	minversion = 1.5;
	if(gametype == GAMETYPE_OFFLINEMISSIONEDITOR
	|| (gametype != GAMETYPE_SINGLEPLAYER && cvar("sv_multiplayer_alloweditor")))
	if(EPISODE < minversion)	
	{
		filename = GetBufferString(active_menu.buf_items, 0);
		filename = GetMissionFilename(cvar_string("mission"));
	
		file = FileOpen(filename, FILE_READ);
		if(file == -1)
		{
			Call_ErrorMenu("Missing mission file.");
			return;
		}

		for(line = fgets(file); line && line != "ENTITIES"; line = fgets(file))
		{}


		if(line == "ENTITIES")
		{
			for(count = 0; line && count <= 200; count++)
				line = fgets(file);

			if(count > 200)	
			{
				fclose(file);
				SetCurrentMenu(Draw_LimitedVersion_EntCount);
			//	currentmenu.buf_items = CreateBuffer();
			//	SetBufferString(currentmenu.buf_items, 0, GetBufferString(active_menu.buf_items, 0));
			//	SetBufferString(currentmenu.buf_items, 1, GetBufferString(active_menu.buf_items, 1));
				return;
			}
		}

		fclose(file);	
	}
	
	StartMissionConfirmed();
}*/

void CloseHostMenu() =
{
	mission_map = freezone(mission_map);
	CloseMenu();
//	Call_MissionMenu();	
}

void SetHostName() =
{
	cvar_set("hostname", GetBufferString(active_menu.buf_list, 0));
	CloseMenu();
}

void Draw_InputHostName() =
{
	Menu_Start_ConfirmationMenu("Host Name", '300 0 0', __FUNC__);
	Menu_AlignedText("Host Name:", ALIGN_LEFT);
	Menu_Input_All('180 0 0', cvar_string("hostname"), ALIGN_RIGHT, 0, SetHostName);	
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Set", SetHostName, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();			
	
	Menu_End();		
}

void InputHostName() =
{
	SetCurrentMenu(Draw_InputHostName);
	active_input = 1;
}

void Toggle_PublicServer() = {	cvar_set("sv_public", ftos(!cvar("sv_public")));	}

void Toggle_AllowEditorInMultiplayer() = {	cvar_set("sv_multiplayer_alloweditor", ftos(!cvar("sv_multiplayer_alloweditor")));	}

void Toggle_PiblicGuestEditorAccess() = {	cvar_set("sv_multiplayer_publicguesteditoraccess", ftos(!cvar("sv_multiplayer_publicguesteditoraccess")));	}

void Toggle_DropItemsInMultiplayer() =	{	cvar_set("sv_multiplayer_dropitems", ftos(!cvar("sv_multiplayer_dropitems")));	}

void Toggle_ItemsMode() =	{	cvar_set("sv_itemsmode", ftos(!cvar("sv_itemsmode")));	}

void SliderRules_MinMaxPlayers() =
{
	local float f_minplayers, f_maxplayers;

	f_minplayers = cvar("minplayers");
	f_maxplayers = cvar("menu_maxplayers");

	if(f_minplayers > f_maxplayers)
	if(slider_cvar == "minplayers")	
		cvar_set("menu_maxplayers", ftos(f_minplayers));
	else	
	if(slider_cvar == "menu_maxplayers")
		cvar_set("minplayers", ftos(f_maxplayers));
}

void Toggle_AllowVoting() =	{	cvar_set("sv_multiplayer_allowvoting", ftos(!cvar("sv_multiplayer_allowvoting")));	}

void Toggle_MapRotation() =	{	cvar_set("sv_manualmissionrotation", ftos(!cvar("sv_manualmissionrotation")));	}

void Toggle_Teamplay() =	{	cvar_set("teamplay", ftos(!cvar("teamplay")));	}

void SetJoinPassword() =
{
	local string password;
	
	password = GetBufferString(active_menu.buf_list, 0);
	
	cvar_set("sv_join_password", password);
	CloseMenu();
}

void Draw_SetJoinPassword() =
{
	local vector input_size;
	local string s;

	Menu_Start_ConfirmationMenu("Join Password", '300 0 0', __FUNC__);

	Menu_InputWarnings();
	
	s = Translate("Password:");
	skiptranslation = true;
	Menu_AlignedText(s, ALIGN_LEFT);
	input_size_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - stringwidth(s, false, body_fontsize) - body_fontsize_x;
	Menu_Input_All(input_size, string_null, ALIGN_RIGHT, 0, SetJoinPassword);
	
	skiptranslation = false;
	BeginBottomButtons(2);
	DrawElement_BottomButton("Set", SetJoinPassword, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();	
}

void Call_SetJoinPassword() =
{
	SetCurrentMenu(Draw_SetJoinPassword);
	active_input = 1;
}

void SetServerPassword() =
{
	local string password;
	
	password = GetBufferString(active_menu.buf_list, 0);
	
	cvar_set("sv_admin_password", password);
	CloseMenu();
}

void Draw_SetServerPassword() =
{
	local vector input_size;
	local string s;

	Menu_Start_ConfirmationMenu("Server Password", '300 0 0', __FUNC__);

	Menu_InputWarnings();
	
	s = Translate("Password:");
	skiptranslation = true;
	Menu_AlignedText(s, ALIGN_LEFT);
	input_size_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - stringwidth(s, false, body_fontsize) - body_fontsize_x;
	Menu_Input_All(input_size, string_null, ALIGN_RIGHT, 0, SetServerPassword);
	
	skiptranslation = false;
	BeginBottomButtons(2);
	DrawElement_BottomButton("Set", SetServerPassword, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();	
}

void Call_SetServerPassword() =
{
	SetCurrentMenu(Draw_SetServerPassword);
	active_input = 1;
}

void Draw_HostGameOptions_Advanced() =
{
	Menu_Start_ESCMenu("Advanced Host Options", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	
	option_size_x = 168;	
	option_spacing = 4;
		
	local string str_allowvoting, str_votetime, str_alloweditor, str_manualrotation, str_itemrespawndelay, str_weaponrespawndelay, str_scoreviewingtime, str_joinpassword, str_adminpassword, str_guesteditoraccess;
	str_allowvoting			= Translate("Allow Voting");
	str_votetime			= Translate("Vote Time Allowed");
	str_alloweditor			= Translate("Allow Editor");
	str_manualrotation		= Translate("Manual Rotation");
	str_itemrespawndelay	= Translate("Item Respawn Delay");
	str_weaponrespawndelay	= Translate("Weapon Respawn Delay");
	str_scoreviewingtime	= Translate("Score Viewing Time");
	str_joinpassword		= Translate("Join Password");
	str_adminpassword		= Translate("Admin Password");
	str_guesteditoraccess	= Translate("Public Guest Editor Access");
	skiptranslation = true;

	Menu_Option_Text(str_joinpassword, Call_SetJoinPassword);
	option_pos = GetLastLinePos();
	option_pos_x += option_sliderspacing;
	Menu_AlignedText(cvar_string("sv_join_password"), ALIGN_LEFT);
	option_pos_x -= option_sliderspacing;
	BR();
	
	Menu_Option_Text(str_adminpassword, Call_SetServerPassword);		
	option_pos = GetLastLinePos();
	option_pos_x += option_sliderspacing;
	Menu_AlignedText(cvar_string("sv_admin_password"), ALIGN_LEFT);
	option_pos_x -= option_sliderspacing;
	BR();
	
	option_size_selectionbox = option_size;
	option_size_selectionbox_x = option_sliderspacing+36;
	
	Menu_Option_Text(str_alloweditor, Toggle_AllowEditorInMultiplayer);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("sv_multiplayer_alloweditor"));	
	BR();
	
	if(cvar("sv_multiplayer_alloweditor"))
	{
		Menu_Option_Text(str_guesteditoraccess, Toggle_PiblicGuestEditorAccess);
		option_pos = GetLastLinePos();
		DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("sv_multiplayer_publicguesteditoraccess"));	
		BR();	
	}	

	Menu_Option_Text(str_allowvoting, Toggle_AllowVoting);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("sv_multiplayer_allowvoting"));	
	BR();	
	
	option_size_selectionbox = option_size;	
	option_size_selectionbox_x = 407;		
	Menu_Slider_Text(str_votetime, 0, "sv_votetallytime", 10, 120, 111, 3);	

	option_size_selectionbox = option_size;
	option_size_selectionbox_x = option_sliderspacing+36;	
	
	Menu_Option_Text(str_manualrotation, Toggle_MapRotation);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("sv_manualmissionrotation"));	
	BR();	
	
	option_size_selectionbox = option_size;	
	option_size_selectionbox_x = 407;		

	if(gamemode != GAMEMODE_CAMPAIGN)
	{	
		Menu_Slider_Text(str_itemrespawndelay, 0, "sv_itemrespawndelay", 0, 100, 101, 3);	
		Menu_Slider_Text(str_weaponrespawndelay, 0, "sv_weaponrespawndelay", 0, 100, 101, 3);	
	}
	
	Menu_Slider_Text(str_scoreviewingtime, 0, "sv_maxscoreviewingtime", 10, 120, 111, 3);	
	
	option_size_selectionbox = '0 0 0';
	
	skiptranslation = false;	
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();	
	
	option_size_selectionbox = option_size;	
	
	Menu_End();
}

void Call_HostGameOptions_Advanced() =	{	SetCurrentMenu(Draw_HostGameOptions_Advanced);	}

void SetHostDifficultyMode_Arcade() =	{	cvar_set("skill", "0");		}
void SetHostDifficultyMode_Classic() =	{	cvar_set("skill", "1");		}

void Draw_HostGameOptions() =
{
	local string s;
	local vector option_pos_start;
	
	Menu_Start_ESCMenu("Host Options", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	
	local string str_friendlyfire, str_fraglimit, str_capturelimit, str_minplayers, str_difficultysetting, str_arcade, str_easy, str_classic, str_hard;
	
	option_size_x = 168;	
	option_spacing = 4;
	option_pos_start = option_pos;	
		
	Menu_Option_Text("Host Name", InputHostName);	
	option_pos = GetLastLinePos();	
	option_pos_x += option_sliderspacing;
	s = cvar_string("hostname");
	skiptranslation = true;
	Menu_AlignedText(s, ALIGN_LEFT);
	skiptranslation = false;
	option_pos_x -= option_sliderspacing;
	BR();
	
	option_size_selectionbox = option_size;
	option_size_selectionbox_x = option_sliderspacing+36;	
	
	Menu_Option_Text("Public", Toggle_PublicServer);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("sv_public"));	
	BR();		
	
	Menu_Option_Text("Drop Items", Toggle_DropItemsInMultiplayer);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("sv_multiplayer_dropitems"));	
	BR();		
	
	Translate("Earned Items");
//	Menu_Option_Text("Earned Items", Toggle_ItemsMode);
//	option_pos = GetLastLinePos();
//	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("sv_itemsmode"));	
//	BR();		

	str_friendlyfire	= Translate("Friendly Fire");
	str_fraglimit		= Translate("Frag Limit");
	str_capturelimit	= Translate("Capture Limit");
	str_minplayers		= Translate("Min Players");
	skiptranslation = true;
	
	if(!GameMode_PlayerVSPlayer(gamemode) || GameMode_HasTeams(gamemode))
	{
		Menu_Option_Text(str_friendlyfire, Toggle_Teamplay);
		option_pos = GetLastLinePos();
		DrawElement_CheckBox(option_pos, option_sliderspacing, !cvar("teamplay"));	
		BR();	
	}	
	
	option_size_selectionbox = option_size;	
	option_size_selectionbox_x = 407;		

	if(GameMode_HasFragLimit(gamemode))
		Menu_Slider_Text(str_fraglimit, 0, "fraglimit", 0, 100, 101, 3);		

	if(GameMode_HasFlags(gamemode))
		Menu_Slider_Text(str_capturelimit, 0, "capturelimit", 0, 100, 101, 3);
		
	if(GameMode_AllowMinPlayers(gamemode))
	{
		SliderRules = SliderRules_MinMaxPlayers;
		Menu_Slider_Text(str_minplayers, 0, "minplayers", 1, 16, 16, 2);	
	}
	skiptranslation = false;
	
	Menu_Slider_Text("Max Players", 0, "menu_maxplayers", 2, 16, 15, 2);	
	option_size_selectionbox = '0 0 0';	
	SliderRules = SUB_Null;
	BR();
	
	str_difficultysetting	= Translate("DIFFICULTY SETTING");
	str_arcade				= Translate("Arcade");
	str_easy				= Translate("(EASY)");
	str_classic				= Translate("Classic");
	str_hard				= Translate("(HARD)");
	skiptranslation = true;
	
	if(!GameMode_PlayerVSPlayer(gamemode))
	{
		DrawElement_OptionTitle(str_difficultysetting);	
		
		option_size_selectionbox = option_size;
		option_size_selectionbox_x = option_sliderspacing+36;
		
		Menu_Option_Text(str_arcade, SetHostDifficultyMode_Arcade);
		option_pos = GetLastLinePos();
		DrawElement_CheckBox(option_pos, option_sliderspacing, !cvar("skill"));
		option_pos_x += 110;
		Menu_Text(str_easy);
		option_pos_x = option_pos_start_x;
		BR();
		
		Menu_Option_Text(str_classic, SetHostDifficultyMode_Classic);
		option_pos = GetLastLinePos();
		DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("skill"));	
		option_pos_x += 110;
		Menu_Text(str_hard);
		option_pos_x = option_pos_start_x;
		
		option_size_selectionbox = '0 0 0';		
	}
	skiptranslation = false;	
	
	BeginBottomButtons(3);
	DrawElement_BottomButton("Start", StartMission, 0, 0, 0, 0, MBT_BASIC);	
	DrawElement_BottomButton("Advanced", Call_HostGameOptions_Advanced, 0, 0, 0, 0, MBT_BASIC);	
	DrawElement_BottomButton("Back", CloseHostMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();	
	
	option_size_selectionbox = option_size;	
	
	Menu_End();
}

void Call_HostGameOptions() =
{
//	if(cvar("menu_maxplayers") == 1)
//	{
		if(gamemode == GAMEMODE_CAMPAIGN)
			cvar_set("menu_maxplayers", "2");
		else
			cvar_set("menu_maxplayers", "8");			
//	}
	
	cvar_set("skill", "1");
	
	SetCurrentMenu(Draw_HostGameOptions);
	currentmenu.ESCFunc = CloseHostMenu;	
}

void Draw_LimitedVersion_EntCount() =
{
	Menu_Start_ConfirmationMenu("Max Object Limit!", '0 0 0', __FUNC__);
	option_size_y = body_fontsize_y;
	
	Menu_Text("This mission exceeds the limit of 200 objects.");
	BR();
//	Menu_Text("Disable the 'allow editor' option in host settings"); 
	BR();
	Menu_Text("Purchase Steel Storm: Burning Retribution to accesss");
	BR();
	Menu_Text("Sand Storm's nearly unlimited object capacity.");
	BR();
	Menu_Text("Contine to load the mission anyway without objects.");
	BR();
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Continue", StartMission, 0, 0, 0, 0, MBT_CONFIRM);
	DrawElement_BottomButton("Close", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();
}

void ChooseMission() =
{
	local string partialfilename, filename, line, loadmap;
	local float file, count, minversion;
	
//	filename = GetMissionFilename(active_menu.listitemstring);
	filename = GetBufferString(active_menu.buf_items, 0);
	filename = GetMissionFilename(gamemode, UnderscoreString(cvar_string("campaign")), filename, false, false);
	
	file = FileOpen(filename, FILE_READ);
	if(file == -1)
	{
		Call_ErrorMenu("NOMISSIONFILE");
		return;
	}

	for(line = fgets(file); line && line != "ENTITIES"; line = fgets(file))
	{
		tokenizebyseparator(line, SEP_SPACE);
		if(argv(0) == "MAP")
		{
			loadmap = argv(1);
		//	break;
		}
	}
		
	if(!loadmap || AllSpaces(loadmap))
	{
		fclose(file);
		Call_ErrorMenu("NOVALIDMAP");
		return;
	}	
	
	cvar_set("mission", GetBufferString(active_menu.buf_items, 0));	
//	SetBufferString(active_menu.buf_items, 1, loadmap);
	mission_map = zonecpy(mission_map, loadmap);
	
		minversion = 1.5;
		if(EPISODE < minversion)	
		if(gametype == GAMETYPE_OFFLINEMISSIONEDITOR)		
		if(line == "ENTITIES")
		{
			for(count = 0; line && count <= 200; count++)
				line = fgets(file);

			if(count > 200)	
			{
				fclose(file);
				SetCurrentMenu(Draw_LimitedVersion_EntCount);
				currentmenu.buf_items = CreateBuffer();
				SetBufferString(currentmenu.buf_items, 0, GetBufferString(active_menu.buf_items, 0));
				SetBufferString(currentmenu.buf_items, 1, GetBufferString(active_menu.buf_items, 1));
				return;
			}
		}	
	
	fclose(file);

//	CloseMenu();
	
	if(gametype == GAMETYPE_MULTIPLAYER && clientstate() != CS_DEDICATED)
		Call_HostGameOptions();
	else
		StartMission();
}

void CloseMissionBriefing() =
{
	local float buf, count;

	if(active_menu.buf_objectives_primary)
	{
		DeleteBuffer(active_menu.buf_objectives_primary);
		active_menu.buf_objectives_primary = 0;
	}
	if(active_menu.buf_objectives_secondary)
	{
		DeleteBuffer(active_menu.buf_objectives_secondary);
		active_menu.buf_objectives_secondary = 0;
	}
		
	ClearObjectiveBuffers(active_menu);
/*	for(count = 0; count < 20; count++)
	{
		buf = active_menu.(buf_textblock_objectives_primary[count]);
		if(buf)
			DeleteBuffer(buf);
		buf = active_menu.(buf_textblock_objectives_secondary[count]);
		if(buf)
			DeleteBuffer(buf);			
	}*/
}

void Draw_MissionBriefing() =
{
	local string s;
	local vector textblocksize;
	local float buf, count, buffersize, numprimaryobjectives, numsecondaryobjectives, indentsize, option_pos_start, scrollboxheight;
	
	Menu_Start_OptionMenu("Mission Briefing", '400 0 0', __FUNC__);

	local string str_primaryobjectives, str_secondaryobjectives;
	str_primaryobjectives		= Translate("PRIMARY OBJECTIVES");
	str_secondaryobjectives		= Translate("SECONDARY OBJECTIVES");
	skiptranslation = true;
	
	indentsize = 14;
	textblocksize_x = 400 - border_size_x*2 - body_margin_x*2;
	textblocksize_y = 400;	
	
//	indentsize = 14;
//	body_textalignment = '-1 0 0';
//	//body_textbordersize = '4 10 0';
	
//	textblocksize_x = 400 - border_size_x*2 - body_margin_x*2;	
//	textblocksize_y = scrollboxheight = 300;
	
//	if(active_menu.scrollboxmeasurement == 2)
//	{
//		textblocksize_x -= scrollbar_width;
//		scrollbar_incrementsize = option_size_y + option_spacing;
//		option_pos_y = BeginScrollingWindow(option_pos, textblocksize, 0, 0);
//	}
	
	option_pos_start = option_pos_y;
	
	s = GetBufferString(active_menu.buf_items, 1);
	tokenize(s);
	s = argv(currentlanguage);
	active_menu.buf_textblock = DrawTextBlock(active_menu.buf_textblock, option_pos, -1, textblocksize, s, body_fontsize, body_fontcolor, body_fontalpha, body_fontflags);

	BR();
	
	textblocksize_x -= indentsize;
	textblocksize_y = 0;
	
	numprimaryobjectives = GetBufferSize(active_menu.buf_objectives_primary);
	numsecondaryobjectives = GetBufferSize(active_menu.buf_objectives_secondary);
	
	if(numprimaryobjectives)
	{
		DrawElement_OptionTitle(str_primaryobjectives);		
		
		for(count = 0; count < numprimaryobjectives; count++)
		{
			Menu_Text("-");
			option_pos_x += indentsize;
		
			s = GetBufferString(active_menu.buf_objectives_primary, count);
			tokenize(s);
			s = argv(currentlanguage);
			buf = active_menu.(buf_textblock_objectives_primary[count]);
			active_menu.(buf_textblock_objectives_primary[count]) = DrawTextBlock(buf, option_pos, -1, textblocksize, s, body_fontsize, '0.46 0.62 0.75', body_fontalpha, body_fontflags);	
			
			option_pos_x -= indentsize;
		}
	}
	
	if(numsecondaryobjectives)
	{
		if(numprimaryobjectives)
			BR();
			
		DrawElement_OptionTitle(str_secondaryobjectives);		
		
		for(count = 0; count < numsecondaryobjectives; count++)
		{
			Menu_Text("-");
			option_pos_x += indentsize;
		
			s = GetBufferString(active_menu.buf_objectives_secondary, count);
			tokenize(s);
			s = argv(currentlanguage);
			buf = active_menu.(buf_textblock_objectives_secondary[count]);
			active_menu.(buf_textblock_objectives_secondary[count]) = DrawTextBlock(buf, option_pos, -1, textblocksize, s, body_fontsize, '0.46 0.62 0.75', body_fontalpha, body_fontflags);	
			
			option_pos_x -= indentsize;
		}
	}	
	skiptranslation = false;
	
//	if(active_menu.scrollboxmeasurement == 2)	
//		EndScrollingWindow(option_pos_y - option_pos_start, 0, 0);		

//	if(!active_menu.scrollboxmeasurement)		
//	if(option_pos_y - option_pos_start > scrollboxheight)
//	{
//		active_menu.scrollboxmeasurement = 2;	
//		DeleteBuffer(active_menu.buf_textblock);
//		active_menu.buf_textblock = 0;
//	}
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Accept", ChooseMission, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();		

	Menu_End();			
}

void Call_MissionBriefing() =
{
	local float file, count, objectivepriority, buf, buf_base, bufsize, bufcount, objid, local_buf_objectives_primary, MISSION_LANGUAGE, local_buf_objectives_secondary, numloadedlanguages;
	local string filename, localizefilename, line, briefing, base_briefing, objectivetext, s, objectiveid;

	filename = GetBufferString(active_menu.buf_items, 0);
	filename = GetMissionFilename(gamemode, UnderscoreString(cvar_string("campaign")), filename, false, false);
	
	file = FileOpen(filename, FILE_READ);
	if(file == -1)
	{
		Call_ErrorMenu("NOMISSIONFILE");
		return;
	}	
	
	SetCurrentMenu(Draw_MissionBriefing);
	currentmenu.CloseMenuFunc = CloseMissionBriefing;
	currentmenu.buf_items = CreateBuffer();
	currentmenu.buf_objectives_primary = CreateBuffer();
	currentmenu.buf_objectives_secondary = CreateBuffer();
	
	local_buf_objectives_primary = CreateBuffer();
	local_buf_objectives_secondary = CreateBuffer();
	
	for(line = fgets(file); line; line = fgets(file))
	{
		tokenize(line);
		for(count = 0; argv(count); count++)
		{
			if(argv(0) == "LANGUAGE")
				MISSION_LANGUAGE = stof(argv(1));
			else
			if(argv(0) == "BRIEFING")
			{
				count++;
				base_briefing = strcat("\"", argv(count), "\"");
			}
			else
			if(argv(count) == "OBJCLASS")
			{
				count++;
				if(stof(argv(count)) == OBJ_OBJECTIVE)
				{
					count++;
					for(;argv(count); count++)
					{
						if(argv(count) == "OBJECTIVETEXT")
						{
							count++;
							objectivetext = strcat("\"", argv(count), "\"");
						}
						
						if(argv(count) == "ENTID")
						{
							count++;
							objectiveid = argv(count);
						}
						
						if(argv(count) == "PRIORITY")
						{
							count++;
							objectivepriority = stof(argv(count));
						}
					}
					
					if(objectivepriority == 0)
						AddBufferString(local_buf_objectives_primary, strcat(objectiveid, " ", objectivetext), 0);
					else
					if(objectivepriority == 1)
						AddBufferString(local_buf_objectives_secondary, strcat(objectiveid, " ", objectivetext), 0);
				}
				else
					break;
			}
		}
	}	

	fclose(file);	
	
	if(!base_briefing)
		base_briefing = "\"<NO BRIEFING YET>;Go kill stuff.\"";
	
	for(count = 0; count < NUMLANGUAGES; count++)
	{
		localizefilename = substring(filename, 0, strlen(filename)-8);
		localizefilename = strcat(localizefilename, "/local/", GetLanguageName(count), "/local.txt");
		file = FileOpen(localizefilename, FILE_READ);
		
		if(file != -1 && count != MISSION_LANGUAGE)
		{
			for(line = fgets(file); line; line = fgets(file))
			{
				tokenize(line);
				if(argv(0) == "BRIEFING")
				{
					if(briefing)
						briefing = strcat(briefing, " ");
					briefing = strcat(briefing, "\"", argv(1), "\"");
				}
				else
				if(argv(0) == "OBJECTIVE")
				{
					if(argv(1) == "1")
					{
						buf_base = local_buf_objectives_primary;
						buf = currentmenu.buf_objectives_primary;
					}
					else
					if(argv(1) == "2")
					{
						buf_base = local_buf_objectives_secondary;
						buf = currentmenu.buf_objectives_secondary;
					}
				
					objid = stof(argv(2));
				
					bufsize = GetBufferSize(buf_base);
					for(bufcount = 0; bufcount < bufsize; bufcount++)
					{
						s = GetBufferString(buf_base, bufcount);
						tokenize(s);
						if(stof(argv(0)) == objid)
						{
							tokenize(line);
							s = GetBufferString(buf, bufcount);
							if(s)
								s = strcat(s, " ");
							s = strcat(s, "\"", argv(3), "\"");
							SetBufferString(buf, bufcount, s);
							break;
						}
					}
				}
			}
			fclose(file);
		}
		
		numloadedlanguages = tokenize(briefing);
		if(numloadedlanguages <= count)
		{
			if(briefing)
				briefing = strcat(briefing, " ");
			briefing = strcat(briefing, base_briefing);
		}
		
		bufsize = GetBufferSize(local_buf_objectives_primary);
		for(bufcount = 0; bufcount < bufsize; bufcount++)
		{
			s = GetBufferString(currentmenu.buf_objectives_primary, bufcount);
			numloadedlanguages = tokenize(s);
			if(numloadedlanguages <= count)
			{
				s = GetBufferString(local_buf_objectives_primary, bufcount);
				tokenize(s);
				s = GetBufferString(currentmenu.buf_objectives_primary, bufcount);
				if(s)
					s = strcat(s, " ");
				s = strcat(s, "\"", argv(1), "\"");
				SetBufferString(currentmenu.buf_objectives_primary, bufcount, s);
			}
		}
			
		bufsize = GetBufferSize(local_buf_objectives_secondary);
		for(bufcount = 0; bufcount < bufsize; bufcount++)
		{
			s = GetBufferString(currentmenu.buf_objectives_secondary, bufcount);
			numloadedlanguages = tokenize(s);
			if(numloadedlanguages <= count)
			{
				s = GetBufferString(local_buf_objectives_secondary, bufcount);
				tokenize(s);
				s = GetBufferString(currentmenu.buf_objectives_secondary, bufcount);
				if(s)
					s = strcat(s, " ");
				s = strcat(s, "\"", argv(1), "\"");
				SetBufferString(currentmenu.buf_objectives_secondary, bufcount, s);
			}
		}
	}
	
	filename = GetBufferString(active_menu.buf_items, 0);
	AddBufferString(currentmenu.buf_items, filename, 0);
	AddBufferString(currentmenu.buf_items, briefing, 0);
	
	DeleteBuffer(local_buf_objectives_primary);
	DeleteBuffer(local_buf_objectives_secondary);	
}

void Draw_LockedMission() =
{
	Menu_Start_ConfirmationMenu("Locked Mission", '0 0 0', __FUNC__);
	
	Menu_Text("Complete missions in the previous tier first.");
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Close", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();	
	
	Menu_End();
}

void Call_LockedMission() =	{	SetCurrentMenu(Draw_LockedMission);	}

//void Close_MissionMenu() =
//{
//	missionid = 0;
//}

void SelectCampaignItem() =
{
	active_menu.user_current_selection = active_menu.listid+1;
}

void ListOption_Mission_Local(float count) =
{
	local string status, line, mname, s;
	local float optionstart, dist;
	local vector option_size_old;
	local void() func;
	
	local string filename, str_tier, str_complete, str_locked;
	skiptranslation = false;
	filename = __FUNC__;
	buf_localizemissionstatustokens = InitializeNonstandardTranslations(buf_localizemissionstatustokens, filename, false);
	str_tier		= Localize("Tier", buf_localizemissionstatustokens);
	str_complete	= Localize("COMPLETE", buf_localizemissionstatustokens);	
	str_locked		= Localize("LOCKED", buf_localizemissionstatustokens);	
	WriteNonstandardTranslations(buf_localizemissionstatustokens, filename, false, false);
	skiptranslation = true;
	
	if(LOCALIZE_GENERATING)
		return;
	
	line = GetBufferString(active_menu.buf_list, count);
	tokenize(line);//, SEP_SPACE, SEP_TAB);	

	active_menu.listid = count;	

	optionstart = option_pos_x;
	
	if(argv(0) == "TIER")
	{
		line = TitleString(argv(1+currentlanguage));//GetBufferString(active_menu.buf_list, count);

		if(active_menu.editingcampaign)
			Menu_Option_Text(strcat("  ", str_tier, ": ", line), SelectCampaignItem);
		else
		{
		//	Menu_Image_Stretch("gfx/menu/slider.tga", SIZE_AUTO, '0 0 0');
			Menu_Image_Bordered_Body("gfx/menu/rm_underlay_left.tga", "gfx/menu/rm_underlay_right.tga", "gfx/menu/rm_underlay_mid.tga", SIZE_AUTO);
			TempMenuSetting_body_fontcolor('0.46 0.62 0.75');			
			Menu_Text(line);
			RestoreMenuSetting_body_fontcolor();			
			BR();
		}
		
		if(!active_menu.editingcampaign)
			CompensateForSpaceInList();
	}
	else
	if(line == "ENDTIER")
	{
		CompensateForSpaceInList();
		BR();
		return;
	}
	else
	{
		option_size_old = option_size;
		if(gametype != GAMETYPE_OFFLINEMISSIONEDITOR)
		{
			option_pos_x += option_size_x - 250;
			option_size_x = 250;
		}
		
		tokenize(line);
		
		if(active_menu.editingcampaign == 2)	// adding mission
		{
		//	active_menu.listitemstring = line;
			SetBufferString(active_menu.buf_items, 0, line);
			Menu_Option_Text(TitleString(argv(currentlanguage+1)), AddMissionToTier);
		}
		else
		if(active_menu.editingcampaign == 1)	// editing campaign
			Menu_Option_Text(strcat("  ", TitleString(argv(currentlanguage+1))), SelectCampaignItem);
		else
		{
			if(gametype == GAMETYPE_SINGLEPLAYER)
			{
				status = argv(0);
				line = argv(1);
				mname = argv(2+currentlanguage);
				
				if(status != "INCOMPLETE")
				{
					if(status == "COMPLETE")
						s = str_complete;
					else
						s = str_locked;
					dist = stringwidth(s, false, body_fontsize) + body_textbordersize_x + option_spacing*2;
					option_pos_x -= dist;
					Menu_AlignedText(s, ALIGN_LEFT);
					option_pos_x += dist;
				}
			}
			else
			{
				line = argv(0);
				mname = argv(1+currentlanguage);
			}
		
			if(status == "LOCKED")
				func = Call_LockedMission;
			else
			if(gametype == GAMETYPE_OFFLINEMISSIONEDITOR || gametype == GAMETYPE_MULTIPLAYER || gametype == GAMETYPE_HOSTMULTIPLAYER)
				func = ChooseMission;
			else
				func = Call_MissionBriefing;//ChooseMission;
				
		//	active_menu.listitemstring = line;

			SetBufferString(active_menu.buf_items, 0, line);
			Menu_Option_Text(TitleString(mname), func);
		}
		
		option_size = option_size_old;
	}

	if(active_menu.editingcampaign == 1)
	if(active_menu.user_current_selection-1 == count)//-1)
	{
		option_pos = GetLastLinePos();
		TempMenuSetting_body_fontcolor('0 1 1');
		Menu_AlignedText(" ->", ALIGN_LEFT);	
		RestoreMenuSetting_body_fontcolor();
		BR();
	}	
	
	option_pos_x = optionstart;	
}

void ListOption_Mission(float count) =
{
	if(LOCALIZE_GENERATING)
		return;
		
	ListOption_Mission_Local(count);
}

void MissionMenuESCFunc() =
{
	CloseMenu();
	if(collapsemenusonaction)
		return;
	Call_CampaignMenu();
}

void Draw_MissionMenu() =
{
	local float numlistitems, numlistoptions;
	local string s;
	
	Menu_Start_ESCMenu("Missions", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	
	local string str_missions, str_nomissionsincampaign, str_nomissionfiles;
	str_missions				= Translate("Missions");
	str_nomissionsincampaign	= Translate("No missions specified in campaign file.");
	str_nomissionfiles			= Translate("No mission files found.");	
	skiptranslation = true;
	
	body_fontsize				= '12 9 0';
	body_textalignment			= '1 -1 0';
	body_textbordersize			= '12 8 0';
	body_imagealpha				= 0.4;
	option_size_x				= WINDOWSIZE_RIGHTPANE_x;
	
	if(gamemode == GAMEMODE_CAMPAIGN)
	{
		s = GetBufferString(active_menu.buf_contents, 0);
		tokenize(s);
		Menu_Text(TitleString(argv(currentlanguage)));
	}
	else
		Menu_Text(strcat(TitleString(GetGameMode_String(gamemode, false)), SEP_SPACE, str_missions));	
	
	BR();
	
	if(active_menu.bodystring)
	{
		switch(active_menu.bodystring)
		{
			case "NOMISSIONSINCAMPAIGN":	s = str_nomissionsincampaign;	break;
			case "NOMISSIONFILES":			s = str_nomissionfiles;			break;
		}
	
		BR();
		Menu_Text(s);
	}
	else
	{
		numlistitems = GetBufferSize(active_menu.buf_list);
		if(gamemode == GAMEMODE_CAMPAIGN && !active_menu.editingcampaign)
			numlistitems -= 1;
			
		numlistoptions = Draw_ScollingList(numlistitems, 9, 0, WINDOWSIZE_RIGHTPANE_x, 9, 9, SUB_Null, ListOption_Mission);
	}
	
	if(active_menu.buf_display)
		DrawItemIcons(option_pos+'26 0 0', active_menu.buf_display, false);
	
	skiptranslation = false;
	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", active_menu.ESCFunc, numlistoptions, 0, numlistoptions, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();
}

void GenerateMissionStatusTokens() =
{
	local string filename, t, t2, campaignline, line;
	local float file, count, buflinecount, lockmissions, langcount, wep1, wep2, wep, ep;
	
	filename = strcat("profiles/_", uri_escape(profile_active));
	filename = strcat(filename, ".profile");

	file = FileOpen(filename, FILE_READ);	
	if(file == -1)
	{
	//	print("Profile does not exist.\n");
		return;
	}	
	
	for(campaignline = fgets(file); campaignline && campaignline != "GAMEPROGRESS"; campaignline = fgets(file))
	{}
	
	campaignline = fgets(file);
	while(campaignline)
	{
		tokenizebyseparator(campaignline, SEP_SPACE);
		t = argv(0);
		if(t == cvar_string("campaign"))
			break;
		campaignline = fgets(file);
	}	
	
	fclose(file);

	if(t == cvar_string("campaign"))
	{
		count = 1;
		
		if(argv(count) == "EPISODE")
		{
			count++;
			ep = stof(argv(count));

			if(ep >= 1)
			{
				count++;
				wep1 = stof(argv(count));
				for(wep = 1; wep <= 16777215; wep = wep*2)
				{
					if(wep1 & wep)
						AddBufferString(currentmenu.buf_display, GetItemIcon(1, wep), 0);
				}				
			}
			
			if(ep >= 2)
			{
				count++;
				wep2 = stof(argv(count));
				for(wep = 1; wep <= 16777215; wep = wep*2)
				{
					if(wep2 & wep)
						AddBufferString(currentmenu.buf_display, GetItemIcon(2, wep), 0);
				}				
			}
			

		

		}

		count++;
		
		for(t = argv(count); t; t = argv(count))
		{
			
		
			buflinecount = 0;
			for(line = GetBufferString(currentmenu.buf_list, buflinecount); line; line = GetBufferString(currentmenu.buf_list, buflinecount))
			{
				tokenize(line);
				t2 = argv(1);
				if(argv(0) == "INCOMPLETE")
				if(t == t2)
				{
					line = "COMPLETE";
					for(langcount = 0; langcount < NUMLANGUAGES+1; langcount++)
						line = strcat(line, " \"", argv(langcount+1), "\"");
					SetBufferString(currentmenu.buf_list, buflinecount, line);
				}
				buflinecount++;
			}
			
			tokenizebyseparator(campaignline, SEP_SPACE);
			count++;
		}
	}
	else
		AddBufferString(currentmenu.buf_display, GetItemIcon(1, 1), 0);

	buflinecount = 0;
	for(line = GetBufferString(currentmenu.buf_list, buflinecount); line; line = GetBufferString(currentmenu.buf_list, buflinecount))
	{
		tokenize(line);
		t = argv(0);

		if(lockmissions == 2)
		if(t != "TIER")
		if(t != "ENDTIER")
		if(strlen(t))
		{
			line = "LOCKED";
			for(langcount = 0; langcount < NUMLANGUAGES+1; langcount++)
				line = strcat(line, " \"", argv(langcount+1), "\"");
			SetBufferString(currentmenu.buf_list, buflinecount, line);
		}
		
		if(lockmissions < 2)
		if(t == "INCOMPLETE")
			lockmissions = 1;
		else
		if(t == "ENDTIER")
		if(lockmissions == 1)
			lockmissions = 2;
			
		buflinecount++;
	}	
}

void Call_MissionMenu_Campaign(float editingcampaignval) =
{
	if(cvar_string("campaign") == string_null)
	{
	//	print("No campaign selected.\n");
		return;	
	}

	local string line, campaign_path, base_campaign_path, t, s, filename, mname, tierpath, campaignname;
	local float file, count, listcount, langcount, basetierbuff, tierbuff, totaltiers;
	
	if(editingcampaignval)
	{
		SetCurrentMenu(Draw_CampaignEditMenu);
		currentmenu.ESCFunc = CloseMenu;
	}
	else
	{
		SetCurrentMenu(Draw_MissionMenu);	
		currentmenu.ESCFunc = MissionMenuESCFunc;
	}
//	currentmenu.CloseMenuFunc = Close_MissionMenu;
	currentmenu.editingcampaign = editingcampaignval;
	currentmenu.buf_list = CreateBuffer();	
	currentmenu.buf_items = CreateBuffer();
	currentmenu.buf_contents = CreateBuffer();
	currentmenu.buf_display = CreateBuffer();
	
	campaign_path = strcat("campaign/_", uri_escape(UnderscoreString(cvar_string("campaign"))));
	base_campaign_path = strcat(campaign_path, "/missions.txt");
	
	tierbuff = CreateBuffer();
	basetierbuff = CreateBuffer();
	
	// count tiers and set up default tiernames
	file = FileOpen(base_campaign_path, FILE_READ);
	for(line = fgets(file); line; line = fgets(file))
	{
		tokenize(line);
		if(argv(0) == "TIER")
		{
			s = substring(line, 5, strlen(line)-5);
			AddBufferString(basetierbuff, s, 0);
		}
	}
	fclose(file);

	// translate tiernames
	totaltiers = GetBufferSize(basetierbuff);
	for(langcount = 0; langcount < NUMLANGUAGES; langcount++)
	{
		tierpath = strcat(campaign_path, "/local/");
		tierpath = strcat(tierpath, GetLanguageName(langcount));
		tierpath = strcat(tierpath, "/local.txt");
		file = FileOpen(tierpath, FILE_READ);

		if(campaignname)
			campaignname = strcat(campaignname, SEP_SPACE);
		
		if(file != -1)
		{
			line = fgets(file);
			line = fgets(file);
			campaignname = strcat(campaignname, "\"", line, "\"");
			
			count = 0;
			for(line = fgets(file); line; line = fgets(file))
			{
				s = GetBufferString(tierbuff, count);
				if(s)
					s = strcat(s, SEP_SPACE);
				s = strcat(s, "\"", line, "\"");
				SetBufferString(tierbuff, count, s);
				count++;
			}
			fclose(file);
		}
		else
		{
			campaignname = strcat(campaignname, "\"", cvar_string("campaign"), "\"");
			
			for(count = 0; count < totaltiers; count++)
			{
				s = GetBufferString(tierbuff, count);
				if(s)
					s = strcat(s, SEP_SPACE);
				s = strcat(s, "\"", GetBufferString(basetierbuff, count), "\"");
				SetBufferString(tierbuff, count, s);
			}
		}
	}
	
	AddBufferString(currentmenu.buf_contents, campaignname, 0);
	
	file = FileOpen(base_campaign_path, FILE_READ);
	
	count = 0;
	line = fgets(file);
	while(line)
	{
		if(!AllSpaces(line))
		{
			tokenizebyseparator(line, SEP_SPACE);
			t = argv(0);
		
		//	if(!editingcampaignval)
		//	if(gametype == GAMETYPE_SINGLEPLAYER)
			if(t == "TIER")
			{
				line = strcat("TIER ", GetBufferString(tierbuff, count));
				count++;
			}
			else
			if(t != "ENDTIER")
			{
			
				if(gametype == GAMETYPE_SINGLEPLAYER)
					s = "INCOMPLETE "; 
				else
					s = string_null;
					
				s = strcat(s, "\"", line, "\"");
				
				for(langcount = 0; langcount < NUMLANGUAGES; langcount++)
				{
					filename = strcat("campaign/_", uri_escape(UnderscoreString(cvar_string("campaign"))));
					filename = strcat(filename, "/_", uri_escape(line));
					filename = strcat(filename, "/local/", GetLanguageName(langcount));
					filename = strcat(filename, "/local.txt");
					mname = GetLocalMissionName(filename);
					if(mname == "DEFAULT")
						mname = line;
						
					s = strcat(s, " \"", mname, "\"");
				}			

				line = s;
			}

			AddBufferString(currentmenu.buf_list, line, 0);
			listcount++;
		}
	
		line = fgets(file);
	}
	
	DeleteBuffer(basetierbuff);	
	DeleteBuffer(tierbuff);
	
	if(!listcount)
	if(!editingcampaignval)
		currentmenu.bodystring = "NOMISSIONSINCAMPAIGN";
	
	fclose(file);
	
	if(!editingcampaignval)
	if(gametype == GAMETYPE_SINGLEPLAYER)
		GenerateMissionStatusTokens();
}

void Call_MissionMenu_NonTiered(string searchpath, float filenamenum, float editingcampaignval) =
{
	local float file, searchhandle, numfiles, count, namenum, langcount;
	local string mission_title, filename, s, line, mname, campaign_path, campaignname;

	SetCurrentMenu(Draw_MissionMenu);
	currentmenu.ESCFunc = CloseMenu;
	currentmenu.editingcampaign = editingcampaignval;

	searchpath = strcat(strtolower(searchpath), "*.mission");
	searchhandle = search_begin(searchpath, TRUE, TRUE);
	if(searchhandle == -1)
	{
		currentmenu.bodystring = "NOMISSIONFILES";
		return;
	}
	
	currentmenu.buf_list = CreateBuffer();
	currentmenu.buf_items = CreateBuffer();
	numfiles = search_getsize(searchhandle);	

	if(gamemode == GAMEMODE_CAMPAIGN)
	{
		currentmenu.buf_contents = CreateBuffer();	
		campaign_path = strcat("campaign/_", uri_escape(UnderscoreString(cvar_string("campaign"))));	
		
		for(langcount = 0; langcount < NUMLANGUAGES; langcount++)
		{
			filename = strcat(campaign_path, "/local/");
			filename = strcat(filename, GetLanguageName(langcount));
			filename = strcat(filename, "/local.txt");
			file = FileOpen(filename, FILE_READ);

			if(campaignname)
				campaignname = strcat(campaignname, SEP_SPACE);
			
			if(file != -1)
			{
				line = fgets(file);
				line = fgets(file);
				campaignname = strcat(campaignname, "\"", line, "\"");
				fclose(file);
			}
			else
				campaignname = strcat(campaignname, "\"", cvar_string("campaign"), "\"");
		}
		
		if(!HasDuplicateStringInList(currentmenu.buf_contents, campaignname))
			AddBufferString(currentmenu.buf_contents, campaignname, 0);	
	}
	
	for(count = 0; count < numfiles; count++)
	{
		mission_title = search_getfilename(searchhandle, count);
	//	mission_title = GetFilenameFromPath(mission_title, filenamenum, true);
	
		s = strcat("\"", GetFilenameFromPath(mission_title, filenamenum, true), "\"");
		
		for(langcount = 0; langcount < NUMLANGUAGES; langcount++)
		{
			filename = mission_title;
			filename = substring(filename, 0, strlen(filename)-8);
			filename = strcat(filename, "/local/");
			filename = strcat(filename, GetLanguageName(langcount));
			filename = strcat(filename, "/local.txt");
			mname = GetLocalMissionName(filename);
			if(mname == "DEFAULT")
				mname = GetFilenameFromPath(mission_title, filenamenum, true);
			s = strcat(s, " \"", mname, "\"");
		}
	
		if(!HasDuplicateStringInList(currentmenu.buf_list, s))
			AddBufferString(currentmenu.buf_list, s, 0);
	}	
	
	search_end(searchhandle);
	SortBuffer(currentmenu.buf_list, 99, FALSE);
	
/*	for(count = 0; count < NUMLANGUAGES*numfiles; count++)
		AddBufferString(currentmenu.buf_list, "NULL", 0);
	
	for(count = (numfiles*NUMLANGUAGES+1); count >= 0; count-=1)
	{
		fnum = floor(count/(NUMLANGUAGES+1));
		mission_title = GetBufferString(currentmenu.buf_list, fnum);

		if(fnum == count/(NUMLANGUAGES+1))
			s = GetFilenameFromPath(mission_title, filenamenum, true);
		else
		{
			filename = mission_title;
			filename = substring(filename, 0, strlen(filename)-12);
			filename = strcat(filename, "local/");
			s = GetLanguageName(count - fnum*(NUMLANGUAGES+1) - 1);
			filename = strcat(filename, s);
			filename = strcat(filename, "/local.txt");
			s = GetLocalMissionName(filename);
			if(s == "DEFAULT")
				s = GetFilenameFromPath(mission_title, 2, true);
		}

		SetBufferString(currentmenu.buf_list, count, s);
	}	*/	
}

//void Call_MissionMenu_Deathmatch() =	{	Call_MissionMenu_NonTiered("data/deathmatch/");	}

void Call_MissionMenu(float editingcampaignval) =
{
	local string pathstring;
	local float filenamenum;

	if(gamemode == GAMEMODE_CAMPAIGN && editingcampaignval != 3)
		Call_MissionMenu_Campaign(0);
	else
//	if(gamemode == GAMEMODE_DEATHMATCH)
//		Call_MissionMenu_Deathmatch();
	{
		pathstring = strcat("data/", GetGameMode_String(gamemode, true));
		pathstring = strcat(pathstring, "/");
		
		if(gamemode == GAMEMODE_CAMPAIGN)
		{
			filenamenum = 3;
			pathstring = strcat(pathstring, "_", uri_escape(UnderscoreString(cvar_string("campaign"))), "/");
		}
		else
			filenamenum = 2;

		Call_MissionMenu_NonTiered(pathstring, filenamenum, editingcampaignval);
	}
}

void ChooseCampaign() =
{
	local float editingcampaignval;
	local string campaignname;
	
	editingcampaignval = active_menu.editingcampaign;
	campaignname = GetFilenameFromPath(active_menu.listitemstring, 2, true);
	cvar_set("campaign", campaignname);
	CloseMenu();
	
	if(editingcampaignval == 3)
		Call_MissionMenu(editingcampaignval);
	else
	{
		Call_MissionMenu_Campaign(editingcampaignval);	
		currentmenu.editingcampaign = editingcampaignval;
	}
	
	if(!editingcampaignval)
		campaign_active = true;		
}

void ListOption_Campaign(float count) =
{
	local string campaignname;
	local vector option_size_old, option_pos_start;
	
	campaignname = GetBufferString(active_menu.buf_list, count);//*(NUMLANGUAGES+1)+currentlanguage+1);
	
	tokenize(campaignname);
	
	if(argv(0) == "TITLE")
	{
		Menu_Image_Bordered_Body("gfx/menu/rm_underlay_left.tga", "gfx/menu/rm_underlay_right.tga", "gfx/menu/rm_underlay_mid.tga", SIZE_AUTO);
		TempMenuSetting_body_fontcolor('0.46 0.62 0.75');			
		Menu_Text(argv(currentlanguage+1));
		RestoreMenuSetting_body_fontcolor();			
		BR();

		CompensateForSpaceInList();
	}
	else
	{
		active_menu.listitemstring = argv(0);//GetBufferString(active_menu.buf_list, count*(NUMLANGUAGES+1));	
		campaignname = argv(currentlanguage+1);
		
		option_size_old = option_size;
		option_pos_start = option_pos;
		option_pos_x += option_size_x - 250;
		option_size_x = 250;		
		Menu_Option_Text(TitleString(campaignname), ChooseCampaign);
		option_size = option_size_old;
		option_pos_x = option_pos_start_x;
	}
}

void Draw_CampaignMenu() =
{
	local float count, numlistitems, numlistoptions;
	
	Menu_Start_ESCMenu("Choose a Campaign", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);

	local string str_back;
	
	body_fontsize				= '12 9 0';
	body_textalignment			= '1 -1 0';
	body_textbordersize			= '12 8 0';
	body_imagealpha				= 0.4;
	option_size_x				= WINDOWSIZE_RIGHTPANE_x;	
	
	Menu_Text("Campaigns");
	BR();
	
	local string str_nocampaignfiles;
	str_nocampaignfiles		= Translate("No campaign files found.");
	
	if(active_menu.bodystring == "NOCAMPAIGNFILES")
	{
		skiptranslation = true;
		BR();
		Menu_Text(str_nocampaignfiles);
		skiptranslation = false;
	}
	else
	{
		numlistitems = GetBufferSize(active_menu.buf_list);///(NUMLANGUAGES+1);
		numlistoptions = Draw_ScollingList(numlistitems, 9, 0, WINDOWSIZE_RIGHTPANE_x, 9, 9, SUB_Null, ListOption_Campaign);		
	}
	
	str_back	= Translate("Back");
	skiptranslation = true;

//	if(gametype != GAMETYPE_SINGLEPLAYER)
//	{	
		BeginBottomButtons(1);
		DrawElement_BottomButton(str_back, CloseMenu, numlistoptions, 0, numlistoptions, 0, MBT_CANCEL);	
		EndBottomButtons();	
//	}
	
	Menu_End();
}

void Call_CampaignMenu() =
{
	local float file, searchhandle, buffersize, numfiles, count, fnum, langcount, titlebuff, basetitlebuff, totaltitles, listcount, campaignlistlines, listedcampaign, customcampaignsbuff;
	local string campaign_title, short_campaign_title, filename, s, cname, base_title_path, line, campaignlistpath, campaignlisttitlename, t, mname, listedcampaignname;

	SetCurrentMenu(Draw_CampaignMenu);
	currentmenu.editingcampaign = active_menu.editingcampaign;
	
	searchhandle = search_begin("data/campaign/*/missions.txt", TRUE, TRUE);
	if(searchhandle == -1)
	{
		currentmenu.bodystring = "NOCAMPAIGNFILES";
		return;
	}
	
	currentmenu.buf_list = CreateBuffer();
	numfiles = search_getsize(searchhandle);	

	titlebuff = CreateBuffer();
	basetitlebuff = CreateBuffer();	
	base_title_path = "data/campaign/campaigns.txt";
	
	file = FileOpen(base_title_path, FILE_READ);
	if(file != -1)
	{
		for(line = fgets(file); line; line = fgets(file))
		{
			tokenize(line);
			if(argv(0) == "TITLE")
			{
				s = substring(line, 6, strlen(line)-6);
				AddBufferString(basetitlebuff, s, 0);
			}	
		//	else
		}
		
		fclose(file);
	}	
	
	// translate titlenames
	totaltitles = GetBufferSize(basetitlebuff);
	for(langcount = 0; langcount < NUMLANGUAGES; langcount++)
	{
		campaignlistpath = strcat("campaign/local/", GetLanguageName(langcount));
		campaignlistpath = strcat(campaignlistpath, "/campaigns.txt");
		file = FileOpen(campaignlistpath, FILE_READ);

		if(campaignlisttitlename)
			campaignlisttitlename = strcat(campaignlisttitlename, SEP_SPACE);
		
		if(file != -1)
		{
			line = fgets(file);
			campaignlisttitlename = strcat(campaignlisttitlename, "\"", line, "\"");
			
			count = 0;
			for(line = fgets(file); line; line = fgets(file))
			{
				s = GetBufferString(titlebuff, count);
				if(s)
					s = strcat(s, SEP_SPACE);
				s = strcat(s, "\"", line, "\"");
				SetBufferString(titlebuff, count, s);
				count++;
			}
			fclose(file);
		}
		else
		{
			s = GetBufferString(basetitlebuff, 0);
			campaignlisttitlename = strcat(campaignlisttitlename, "\"", s, "\"");
			
			for(count = 0; count < totaltitles; count++)
			{
				s = GetBufferString(titlebuff, count);
				if(s)
					s = strcat(s, SEP_SPACE);
				s = strcat(s, "\"", GetBufferString(basetitlebuff, count), "\"");
				SetBufferString(titlebuff, count, s);
			}
		}
	}
	
	AddBufferString(currentmenu.buf_contents, campaignlisttitlename, 0);
	
	file = FileOpen(base_title_path, FILE_READ);
	
	if(file != -1)
	{
		count = 0;
		for(line = fgets(file); line; line = fgets(file))
		{
			if(!AllSpaces(line))
			{
				tokenizebyseparator(line, SEP_SPACE);
				t = argv(0);
			
				if(t == "TITLE")
				{
					line = strcat("TITLE ", GetBufferString(titlebuff, count));
					count++;
				}
				else
				{
					s = strcat("\"", line, "\"");
	/*				
					for(langcount = 0; langcount < NUMLANGUAGES; langcount++)
					{
						filename = strcat("campaign/local/", GetLanguageName(langcount));
						filename = strcat(filename, "/missions.txt");
						mname = GetLocalCampaignName(filename); // FIXME : copy GetLocalMissionName
						if(mname == "DEFAULT")
							mname = line;
							
						s = strcat(s, " \"", mname, "\"");
					}		*/	

					line = s;
				}

				AddBufferString(currentmenu.buf_list, line, 0);
				campaignlistlines++;
			}
		}
	
		fclose(file);	
	}
	
	DeleteBuffer(basetitlebuff);	
	DeleteBuffer(titlebuff);	
	customcampaignsbuff = CreateBuffer();
	
	for(count = 0; count < numfiles; count++)
	{
		listedcampaign = false;
	
		campaign_title = search_getfilename(searchhandle, count);
		for(listcount = 0; listcount < campaignlistlines; listcount+=1)
		{
			listedcampaignname = GetBufferString(currentmenu.buf_list, listcount);
			tokenize(listedcampaignname);
			listedcampaignname = argv(0);
			short_campaign_title = GetFilenameFromPath(campaign_title, 2, true);
			if(short_campaign_title == listedcampaignname)
			{
				listedcampaign = true;
				break;
			}
		}
		
		s = strcat("\"", campaign_title, "\"");
		
		for(langcount = 0; langcount < NUMLANGUAGES; langcount++)
		{
			filename = campaign_title;
			filename = substring(filename, 0, strlen(filename)-12);
			filename = strcat(filename, "local/");
			filename = strcat(filename, GetLanguageName(langcount));
			filename = strcat(filename, "/local.txt");
			cname = GetLocalCampaignName(filename);
			if(cname == "DEFAULT")
				cname = GetFilenameFromPath(campaign_title, 2, true);
			s = strcat(s, " \"", cname, "\"");
		}
		
		if(listedcampaign)
			SetBufferString(currentmenu.buf_list, listcount, s);
		else
		if(!HasDuplicateStringInList(currentmenu.buf_list, s)) // move this to new buffer and sort then append
			AddBufferString(customcampaignsbuff, s, 0);
	}	
	
	search_end(searchhandle);
	
	SortBuffer(customcampaignsbuff, 99, FALSE);
	
	buffersize = GetBufferSize(customcampaignsbuff);
	for(count = 0; count < buffersize; count+=1)
	{
		s = GetBufferString(customcampaignsbuff, count);
		AddBufferString(currentmenu.buf_list, s, 0);
	}
	
	DeleteBuffer(customcampaignsbuff);
}

void ClearCampaignValues() =
{
	campaign_active = FALSE;//freezone(campaign_active);
	cvar_set("campaign", "");//campaign_path = freezone(campaign_path);
}

void LeaveCampaign() =
{
	ClearCampaignValues();
	CloseMenu();
}

void Draw_LeaveCampaignConfirmationMenu() =
{
	Menu_Start_ConfirmationMenu("Leave Campaign?", '0 0 0', __FUNC__);
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Leave", LeaveCampaign, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();			
	
	Menu_End();
}

void ChooseMap() =
{
	cvar_set("campaign", "");
	cvar_set("mission", "");
	active_menu.listitemstring = substring(active_menu.listitemstring, 5, strlen(active_menu.listitemstring) - 9);
	mission_map = zonecpy(mission_map, active_menu.listitemstring);
//	CloseMenu();
	StartMission();
}

void ListOption_MapMenu(float count) =
{
	if(active_menu.user_current_option == option_current)
		active_menu.listid = count+1;
/*	local string mapimgname, s;
	local vector mapimgsize, mapimgpos;
	
	mapimgpos = active_menu.menupos + '100 0 0';
	
	if(active_menu.user_current_option == count)
	{
		s = GetBufferString(active_menu.buf_list, count);

		if(substring(s, strlen(s)-1, 1) == "1")
		{
			s = substring(s, 0, strlen(s)-4);
			mapimgname = strcat(s, "tga");
		}
				
		if(mapimgname)
		{
			mapimgsize = drawgetimagesize(mapimgname);
			mapimgsize = mapimgsize*(200/mapimgsize_x);
		//	if(mapimgsize_y > windowsize_y)
		//		mapimgsize = mapimgsize*(windowsize_y/mapimgsize_y);	

			drawpic(mapimgpos, mapimgname, mapimgsize, '1 1 1', 1, 0);	
		}
	}*/

	active_menu.listitemstring = GetBufferString(active_menu.buf_list, count);
	active_menu.listitemstring = substring(active_menu.listitemstring, 0, strlen(active_menu.listitemstring)-1);			
	Menu_Option_Text(GetFilenameFromPath(active_menu.listitemstring, 1, false), ChooseMap);
}

void Draw_MapMenu() =
{
	local float count, listitems, listslots, firstlistoption, lastlistoption, opsize, ofs, dist;
	local vector windowstart, windowsize, option_pos_start, mapimgsize, mapimgpos;
	local string mapimgname, s;
	
	Menu_Start_ESCMenu("Choose a Map", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	
	local string str_nomapfiles;
	
	str_nomapfiles		= Translate("No map files found.");
	
	if(active_menu.bodystring == "NOMAPFILES")
	{
		skiptranslation = true;
		BR();
		Menu_Text(str_nomapfiles);
		skiptranslation = false;
	}
	else
	{
		listslots = 10;		
		listitems = GetBufferSize(active_menu.buf_list);
		opsize = option_size_y + option_spacing;
		windowstart = option_pos;
		windowsize_x = SIZE_MAIN_RIGHTPANE_x - 200 - 20;
		windowsize_y = opsize*listslots - option_spacing;
		
		mapimgpos = windowstart;
		mapimgpos_x += windowsize_x + 25;				

		drawfill(mapimgpos, '200 200 0', '0 0 0', body_imagealpha, body_imageflags);
		
		listitems = Draw_ScollingList(listitems, listslots, 0, windowsize_x, listslots, listslots, SUB_Null, ListOption_MapMenu);
	
		
		if(active_menu.user_current_option < listitems)
		{
			s = GetBufferString(active_menu.buf_list, active_menu.listid-1);

			if(substring(s, strlen(s)-1, 1) == "1")
			{
				s = substring(s, 0, strlen(s)-4);
				mapimgname = strcat(s, "tga");
			}
					
			if(mapimgname)
			{
				mapimgsize = drawgetimagesize(mapimgname);
				mapimgsize = mapimgsize*(200/mapimgsize_x);
				if(mapimgsize_y > windowsize_y)
					mapimgsize = mapimgsize*(windowsize_y/mapimgsize_y);	

				drawpic(mapimgpos, mapimgname, mapimgsize, '1 1 1', 1, 0);	
			}
		}
	}
	
	BR();
	
//	optionselection_horizontal = true;
//	option_textalignment = '0 0 0';	
//	Menu_Option_Text_Cancel("Back", CloseMenu);
//	optionselection_horizontal = false;
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_BASIC);	
	EndBottomButtons();	

	Menu_End();
}

void Call_MapMenu() =
{
	local float searchhandle, numfiles, count, file;
	local string map_name, map_imgname, hasimage;

	SetCurrentMenu(Draw_MapMenu);

	searchhandle = search_begin("maps/*.bsp", TRUE, TRUE);
	if(searchhandle == -1)
	{
		currentmenu.bodystring = "NOMAPFILES";
		return;
	}
	
	currentmenu.buf_list = CreateBuffer();
	numfiles = search_getsize(searchhandle);	

	for(count = 0; count < numfiles; count++)
	{
		map_name = search_getfilename(searchhandle, count);
		
		map_imgname = map_name;
		map_imgname = substring(map_imgname, 0, strlen(map_imgname)-3);
		map_imgname = strcat(map_imgname, "tga");	

		file = FileOpen(map_imgname, FILE_READ);
		if(file == -1)
			hasimage = "0";
		else
		{
			precache_pic(map_imgname);
			fclose(file);
			hasimage = "1";
		}
				
		map_name = strcat(map_name, hasimage);
		
		if(!HasDuplicateStringInList(currentmenu.buf_list, map_name))
			AddBufferString(currentmenu.buf_list, map_name, 0);
	}	
	
	search_end(searchhandle);
	SortBuffer(currentmenu.buf_list, 99, FALSE);
}

void Draw_RestartMapConfirmationMenu() =
{
	Menu_Start_ConfirmationMenu("Restart mission?", '0 0 0', __FUNC__);

	Menu_Text("Are you sure?");
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Restart", RetryMission, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();
}

void PlayMenuMusic() =
{
	local string s;

	if(cvar_string("menu_bgmusic"))
	{
		s = strcat("cd loop ", cvar_string("menu_bgmusic"), "\n");
		localcmd(s);
	}
	else
		localcmd("cd loop music/ss_theme.ogg\n");
}

void ResetConnectionValues() =
{
	cvar_set("join_password", "");
}

void AbortMission() =
{
	missioneditor_enabled = false;
	mission_finished = false;
	if(gametype == GAMETYPE_HOSTMULTIPLAYER)
		gametype = GAMETYPE_MULTIPLAYER;
	ClearCampaignValues();
	CloseMenu();
	cmd("disconnect\n");
	PlayMenuMusic();
	ResetConnectionValues();
}

void Draw_CloseMapConfirmationMenu() =
{
	local string s;

	Menu_Start_ConfirmationMenu("", '0 0 0', __FUNC__);

	local string str_closeeditor, str_closeserver, str_leaveserver, str_abortmission;
	
	str_closeeditor		= Translate("Close Editor?");
	str_closeserver		= Translate("Close Server?");
	str_leaveserver		= Translate("Leave Server?");
	str_abortmission	= Translate("Abort Mission?");
	skiptranslation = true;
	
	if(gametype == GAMETYPE_OFFLINEMISSIONEDITOR)
		s = str_closeeditor;
	else
	if(gametype == GAMETYPE_HOSTMULTIPLAYER)
		s = str_closeserver;
	else
	if(gametype == GAMETYPE_MULTIPLAYER)
		s = str_leaveserver;
	else
	if(gametype == GAMETYPE_SINGLEPLAYER)
		s = str_abortmission;	
	
	Menu_Text(s);
//	BR();
	
	skiptranslation = false;
//	Menu_Text("Are you sure?");
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Confirm", AbortMission, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();
}

//void Call_AbortMissionConfirmationMenu() =	{	SetCurrentMenu(Draw_AbortMissionConfirmationMenu);	}

void SetGameTypeOfflineMissionEditor() =	{	gametype = GAMETYPE_OFFLINEMISSIONEDITOR;	}

void SetGameTypeSinglePlayer() =			{	gametype = GAMETYPE_SINGLEPLAYER;		}

void SetGameTypeMultiPlayer() =				{	gametype = GAMETYPE_MULTIPLAYER;		}

void SetGameTypeHostMultiPlayer() =			{	gametype = GAMETYPE_HOSTMULTIPLAYER;	}

void SetGameMode(float GAMEMODE) =
{
	gamemode = GAMEMODE;

/*	if(newmission)//active_menu.creatingnewmission)
		Call_MapMenu();
	else
	if(gamemode == GAMEMODE_CAMPAIGN)
		Call_CampaignMenu();
	else
		Call_MissionMenu();*/
}

void SetGameMode_Campaign() =	{	gamemode = GAMEMODE_CAMPAIGN;	}

void SetGameMode_Deathmatch() =	{	gamemode = GAMEMODE_DEATHMATCH;	}

void SetGameMode_CTF() =		{	gamemode = GAMEMODE_CTF;	}

/*void Draw_ChooseGameMode() =
{
	Menu_Start_ESCMenu("Choose Game Mode", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE);
		
	Menu_Option_Text("Campaign", SetGameMode_Campaign);	
	Menu_Option_Text("Deathmatch", SetGameMode_Deathmatch);	
	BR();
	Menu_Option_Text_Cancel("Cancel", CloseMenu);	
	
	Menu_End();
}

void HostServer() =
{
//	SetGameTypeHostMultiPlayer();
	CloseMenu();
	SetCurrentMenu(Draw_ChooseGameMode);
//	Call_CampaignMenu();
}*/

void StartSinglePlayerGame() =
{
	SetGameMode_Campaign();
	SetGameTypeSinglePlayer();
	Call_CampaignMenu();
}

void GetCampaignList() =
{
	SetGameMode_Campaign();
	Call_CampaignMenu();
}

void GetDeathmatchMissionList() =
{
	SetGameMode_Deathmatch();
	Call_MissionMenu(0);
}

void GetCTFMissionList() =
{
	SetGameMode_CTF();
	Call_MissionMenu(0);
}

void Draw_MultiPlayerMenu() =
{
	local float minversion;

	Menu_Start_ESCMenu("Multiplayer", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);

	local string str_joinserver, str_hostctf;
	
	str_joinserver	= Translate("Join Server");
	skiptranslation = true;
	
	if(gametype != GAMETYPE_HOSTMULTIPLAYER)
		Menu_Option_Text(str_joinserver, ShowServerList);
		
	skiptranslation = false;
	Menu_Option_Text("Host Campaign", GetCampaignList);
	Menu_Option_Text("Host Deathmatch", GetDeathmatchMissionList);
	
	str_hostctf		= Translate("Host Capture the Flag");
	skiptranslation = true;
	
	minversion = 2;
	if(EPISODE >= minversion)
		Menu_Option_Text(str_hostctf, GetCTFMissionList);

	skiptranslation = false;
	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();			
		
	Menu_End();
}

void Call_MultiPlayerMenu() =
{
	SetGameTypeMultiPlayer();
	SetCurrentMenu(Draw_MultiPlayerMenu);
}

void FadeToSplashScreen() =
{
	local vector pos, imgsize;
	local float minepisode;
	local string imgname;
	
	if(quitalpha < 1)
	{
		quitalpha = min(1, quitalpha + (1/3)*frametime);
		drawfill('0 0 0', vid_size, '0 0 0', quitalpha, 0);
		return;
	}
	
	minepisode = 2;
	if(EPISODE >= minepisode)
	{
		cmd("quit\n");
		return;
	}
	
	imgname = "gfx/splash_screen01.tga";
	imgsize = drawgetimagesize(imgname);

	if(imgsize_x > vid_size_x)
	{
		imgsize_y = imgsize_y*(vid_size_x/imgsize_x);
		imgsize_x = vid_size_x;
	}

	if(imgsize_y > vid_size_y)
	{
		imgsize_x = imgsize_x*(vid_size_y/imgsize_y);
		imgsize_y = vid_size_y;		
	}
	
	pos = vid_size*0.5 - imgsize*0.5;
	drawpic(pos, imgname, imgsize, '1 1 1', 1, 0);
}

void Quit() =
{
	localcmd("disconnect\n");
	SaveProfileConfig();
	quitalpha = 0.01;
}

void Draw_QuitConfirmationMenu() =
{
	Menu_Start_ConfirmationMenu("Quit?", '0 0 0', __FUNC__);
	
	Menu_Text(GetBufferString(active_menu.buf_contents, 0));
//	Menu_Text(active_menu.bodystring);
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Quit", Quit, 0, 0, 0, 0, MBT_QUIT);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();	
	
	Menu_End();
}

void Call_QuitConfirmationMenu() =
{
	SetCurrentMenu(Draw_QuitConfirmationMenu);
	currentmenu.buf_contents = CreateBuffer();
	AddBufferString(currentmenu.buf_contents, RandomQuitMessage(), 0);
//	currentmenu.bodystring = RandomQuitMessage();
}

void ClearGameType() = {	ClearCampaignValues();	gametype = 0;	}

/*void StartQuickMission() =
{
	SetGameTypeHostMultiPlayer();

	if(!profile_active)
		PlayAsAnonymous();

	campaign_active = true;

	UpdateMaxPlayers();
	LoadMap();
}

void escaping_the_base() =
{
	cvar_set("sv_gamemode", "0");
	cvar_set("campaign", "testing_the_waters");
	cvar_set("mission", "escaping_the_base");
	mission_map = zonecpy(mission_map, "level1a");
	
	StartQuickMission();
}

void total_annihilation() =
{
	cvar_set("sv_gamemode", "0");
	cvar_set("campaign", "burning_sand");
	cvar_set("mission", "total_annihilation");
	mission_map = zonecpy(mission_map, "level2a");
	
	StartQuickMission();	
}*/

void Draw_AdminToggle_MaxEnts() =
{
	Menu_Start_ConfirmationMenu("Max Object Limit!", '0 0 0', __FUNC__);
	option_size_y = body_fontsize_y;
	
	Menu_Text("This mission exceeds the limit of 200 objects.");
	BR();
	BR();
	Menu_Text("Purchase Steel Storm: Burning Retribution to accesss");
	BR();
	Menu_Text("Sand Storm's nearly unlimited object capacity.");
	BR();
	
	BeginBottomButtons(1);
//	DrawElement_BottomButton("Continue", StartMissionConfirmed, 0, 0, 0, 0, MBT_CONFIRM);
	DrawElement_BottomButton("Close", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();
}

void InitiateVote() =
{
	m_toggle();
	localcmd("cmd votemenu\n");	
}

void MainMenuESCFunc() =
{
	if(clientstate() == CS_CONNECTED)
		m_toggle();
	else
		Call_QuitConfirmationMenu();
}

void DrawElement_MainMenuOption(string borderimg, vector bgoffset, void(string, void()) optiontypefunc, string bttntext, void() func, float selectable, float collapse) =
{
	local vector imgsize, option_ofs;
	local string imgname;
	
	option_ofs = '11 10 0';
	
	imgname = borderimg;
	imgsize = drawgetimagesize(imgname);

	option_pos += bgoffset;
	drawpic(option_pos, imgname, imgsize, body_bgimagecolor, body_imagealpha, body_imageflags);
	option_pos -= bgoffset;
	
	option_pos += option_ofs;
	allowoptionselection = selectable;
	collapsemenusonaction = collapse;
	optiontypefunc(bttntext, func);
	option_pos -= option_ofs;
}

void MainMenuOption(void(string, void()) optiontypefunc, string bttntext, void() func, float selectable, float collapse) =
{	DrawElement_MainMenuOption("gfx/menu/lm_button_big_border.tga", '0 0 0', optiontypefunc, bttntext, func, selectable, collapse);	}

void MainMenuOption_Small(void(string, void()) optiontypefunc, string bttntext, void() func, float selectable, float collapse) =
{
	local float horizontal_ofs;
	local vector temp_size;
	
	horizontal_ofs = 77;
	
	TempMenuSetting_option_image("gfx/menu/lm_button_small.tga");
	temp_size = drawgetimagesize(option_image);
	TempMenuSetting_option_size_width(temp_size_x);
	
	option_pos_x += horizontal_ofs;
	DrawElement_MainMenuOption("gfx/menu/lm_button_small_border.tga", '0 2 0', optiontypefunc, bttntext, func, selectable, collapse);
	option_pos_x -= horizontal_ofs;
	
	RestoreMenuSetting_option_image();
	RestoreMenuSetting_option_size_width();
}

void Draw_MainMenu() =
{
	local vector pos, imgsize, vertical_bar_ofs, vertical_bar_imgsize;
	local float frame_gametype;
	local string imgname, vertical_bar_imgname, s;
	
	vertical_bar_ofs = '231 2 0';
	vertical_bar_imgname = "gfx/menu/lm_vertical_bar.tga";
	vertical_bar_imgsize = drawgetimagesize(vertical_bar_imgname);
			
	frame_gametype = gametype;

	Menu_Main("", '25 25 0', '200 350 0', __FUNC__);
	
	local string str_profile, str_returntogame, str_closeeditor, str_restartmission, str_abortmission, str_changemission, str_closeserver, str_leaveserver, str_testmission, str_endtest, str_missioneditor, str_singleplayer, str_multiplayer, str_editor, str_controls, str_system, str_language, str_quit, str_initiatevote, str_challenges, str_settings, str_startgame;
	
	str_profile			= Translate("Profile");
	str_returntogame	= Translate("Return to Game");
	str_closeeditor		= Translate("Close Editor");
	str_restartmission	= Translate("Restart Mission");
	str_abortmission	= Translate("Abort Mission");
	str_changemission	= Translate("Change Mission");
	str_closeserver		= Translate("Close Server");
	str_leaveserver		= Translate("Leave Server");
	str_testmission		= Translate("Test Mission");
	str_endtest			= Translate("End Test");
	str_missioneditor	= Translate("Mission Editor");
	str_singleplayer	= Translate("Single Player");
	str_multiplayer		= Translate("Multi-Player");
	str_editor			= Translate("Editor");
	str_controls		= Translate("Controls");
	str_system			= Translate("System");
	str_language		= Translate("Language");
	str_quit			= Translate("Quit");
	str_initiatevote	= Translate("Initiate Vote");
	str_challenges		= Translate("Challenges");
	str_settings		= Translate("Settings");
	str_startgame		= Translate("Start Game");
	skiptranslation = true;
	
	#ifndef COMPILE_SERVICE_ONLIVE
		if(profile_active)
		{
			pos = MenuPosition() + '270 -16 0';
			s = strcat(str_profile, ":");
			drawstring(pos, s, '8 8 0'*languagefontscale, '0.46 0.62 0.75', option_fontalpha, option_fontflags);
			pos_x += stringwidth(s, false, '8 8 0'*languagefontscale) + 5;
			drawstring(pos, profile_active, '8 8 0'*languagefontscale, '1 1 1', option_fontalpha, option_fontflags);
		}			
	#endif
	
	option_pos_y -= 4;
	drawpic(option_pos + vertical_bar_ofs, vertical_bar_imgname, vertical_bar_imgsize, body_bgimagecolor, body_imagealpha, body_imageflags);		
	
	if(clientstate() == CS_CONNECTED && !isdemo())
	{
		if(!mission_finished)
			MainMenuOption(Menu_Option_Text, str_returntogame, m_toggle, false, false);
			
		if(missioneditorenabled)
		if(!singleplayer)
		if(!mission_finished)
		{
			if(gametype == GAMETYPE_OFFLINEMISSIONEDITOR)
			{
				if(missioneditor_enabled)
					MainMenuOption(Menu_Option_Text, str_testmission, DisableMissionEditor, false, false);
				else
					MainMenuOption(Menu_Option_Text, str_endtest, EnableMissionEditor, false, false);
			}
			else
			if(!requestingjoinpassword)
			{
				if(missioneditor_enabled)
					MainMenuOption(Menu_Option_Text, str_closeeditor, DisableMissionEditor, false, false);
				else
				if(missioneditorenabled) // bad variable naming >.<
				if(alloweditorinmultiplayer)
					MainMenuOption(Menu_Option_Text, str_missioneditor, EnableMissionEditor, false, false);
			}
		}						
			
		if(gametype == GAMETYPE_OFFLINEMISSIONEDITOR)
			MainMenuOption(Menu_CallSubMenu_Text, str_closeeditor, Draw_CloseMapConfirmationMenu, false, false);
		else
		if(gametype == GAMETYPE_SINGLEPLAYER || !gametype)
		{
			MainMenuOption(Menu_CallSubMenu_Text, str_restartmission, Draw_RestartMapConfirmationMenu, false, false);
			MainMenuOption(Menu_CallSubMenu_Text, str_abortmission, Draw_CloseMapConfirmationMenu, false, false);
		}
		else
		if(gametype == GAMETYPE_HOSTMULTIPLAYER)
		{
		//	MainMenuOption(Menu_CallSubMenu_Text, str_changemission, Draw_MultiPlayerMenu, true, true);
			if(mission_finished)
				MainMenuOption(Menu_CallSubMenu_Text, str_changemission, Draw_MultiPlayerMenu, true, true);
			else
				MainMenuOption(Menu_CallSubMenu_Text, str_initiatevote, InitiateVote, false, false);			
			MainMenuOption(Menu_CallSubMenu_Text, str_closeserver, Draw_CloseMapConfirmationMenu, false, false);
		}
		else
		if(gametype == GAMETYPE_MULTIPLAYER)
		{
			if(!requestingjoinpassword)
				MainMenuOption(Menu_CallSubMenu_Text, str_initiatevote, InitiateVote, false, false);		
			MainMenuOption(Menu_CallSubMenu_Text, str_leaveserver, Draw_CloseMapConfirmationMenu, false, false);
		}
	}
	else
	{
		#ifdef COMPILE_SERVICE_ONLIVE
			MainMenuOption(Menu_Option_Text, str_startgame, StartSinglePlayerGame, true, true);	// CLOSE_RIGHT_PANE		
		#else
			if(profile_active)
			{
				MainMenuOption(Menu_Option_Text, str_singleplayer, StartSinglePlayerGame, true, true);	// CLOSE_RIGHT_PANE
				
				#ifdef COMPILE_GAMEPLAYOPTIONS_SINGLEPLAYER
					OPTION_EPISODE_MIN = 999;
				#endif

				MainMenuOption(Menu_Option_Text, str_multiplayer, Call_MultiPlayerMenu, true, true);	// CLOSE_RIGHT_PANE
				OPTION_EPISODE_MIN = false;
			
				if(missioneditorenabled)
					MainMenuOption(Menu_Option_Text, str_editor, Call_OfflineMissionEditor, true, true);	// CLOSE_RIGHT_PANE
			}
		#endif	
	}

	if(profile_active)
	{
	//	if(option_current >= 4)
	//		imgname = "gfx/menu/lm_separator.tga";
	//	else
			imgname = "gfx/menu/lm_separator_short.tga";
		imgsize = drawgetimagesize(imgname);			
		drawpic(option_pos + '-13 1 0', imgname, imgsize, body_bgimagecolor, body_imagealpha, body_imageflags);			
		
		option_pos_y += 30;			
		drawpic(option_pos + vertical_bar_ofs, vertical_bar_imgname, vertical_bar_imgsize, body_bgimagecolor, body_imagealpha, body_imageflags);			
	}	
	
	#ifdef COMPILE_SERVICE_ONLIVE
		MainMenuOption(Menu_Option_Text, str_challenges, Call_PlayerChallenges_Campaign, true, true);	// CLOSE_RIGHT_PANE
		MainMenuOption(Menu_Option_Text, str_controls, Call_ControlsMenu, true, true);		// CLOSE_RIGHT_PANE
		MainMenuOption(Menu_Option_Text, str_settings, Call_ProfileOptions, true, true);	// CLOSE_RIGHT_PANE
	#else
		MainMenuOption(Menu_Option_Text, str_profile, Call_ProfileOptions, true, true);	// CLOSE_RIGHT_PANE
	
		if(profile_active)
			MainMenuOption(Menu_Option_Text, str_controls, Call_ControlsMenu, true, true);		// CLOSE_RIGHT_PANE
		
		MainMenuOption(Menu_Option_Text, str_system, Call_SystemMenu, true, true);		// CLOSE_RIGHT_PANE
		MainMenuOption(Menu_Option_Text, str_language, Call_LanguageMenu, true, true);
	#endif
		
	MainMenuOption_Small(Menu_Option_Text, str_quit, Call_QuitConfirmationMenu, false, false);
	
	Menu_End();
}

void CloseMainMenu() =
{
	menu_main = world;
}

void SpawnMainMenu() =
{
	SetCurrentMenu(Draw_MainMenu);
	currentmenu.ESCFunc = MainMenuESCFunc;
	menu_main = currentmenu;
	currentmenu.CloseMenuFunc = CloseMainMenu;
}