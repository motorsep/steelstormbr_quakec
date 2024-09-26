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
string	scoreinfo_token;
string	scoreinfo_title;
float	scoreinfo_width;
float	scoreinfo_value;
float	scoreboard_place_width	= 30;
float	scoreboard_name_width	= 120;
float	scoreboard_ping_width	= 30;
float	scoreboard_page_width;

void ClearScoreInfo() =
{
	scoreinfo_token = string_null;
	scoreinfo_title = string_null;
	scoreinfo_width = 0;
	scoreinfo_value = 0;
}

void CloseScoreboard() =
{
	menu_scores = world;
	menu_chooseteam = world;
	menu_endscores = world;
	ClearScoreInfo();
}

void SetScoreDisplayInfo(entity menu, entity e, float stat, float mode, float text) =
{
	local .float value;
	local float translation, missionend, width;
	local string filename, token, title;
	local vector fontsize;
	
	width = 0;
	token = string_null;
	title = string_null;
	
	ClearScoreInfo();	
	
	if(menu == menu_endscores)
		missionend = true;	
	
//	if(text)
//	{
		filename = __FUNC__;	
		translation = skiptranslation;
		skiptranslation = false;
		
		buf_localizescorestats = InitializeNonstandardTranslations(buf_localizescorestats, filename, false);
		
		local string str_score, str_captures, str_returns, str_playerkills, str_aikills, str_misckills, str_deaths, str_suicides, str_damagedealt, str_timeleft, str_timetaken, str_timebonus, str_accuracy;
		str_score					= Localize("Score", buf_localizescorestats);
		str_captures				= Localize("Captures", buf_localizescorestats);
		str_returns					= Localize("Returns", buf_localizescorestats);
		str_playerkills				= Localize("Player Kills", buf_localizescorestats);
		str_aikills					= Localize("AI Kills", buf_localizescorestats);
		str_misckills				= Localize("Misc Kills", buf_localizescorestats);
		str_deaths					= Localize("Deaths", buf_localizescorestats);
		str_suicides				= Localize("Suicides", buf_localizescorestats);
		str_damagedealt				= Localize("Damage Dealt", buf_localizescorestats);	
		str_timeleft				= Localize("Time Left", buf_localizescorestats);
		str_timetaken				= Localize("Time Taken", buf_localizescorestats);
		str_timebonus				= Localize("Time Bonus", buf_localizescorestats);
		str_accuracy				= Localize("Accuracy", buf_localizescorestats);

		WriteNonstandardTranslations(buf_localizescorestats, filename, true, false);
		skiptranslation = translation;	
//	}
	
	if(LOCALIZE_GENERATING)
		return;
	
	switch(stat)
	{
		case SCORESTAT_SCORE:			if(GameMode_ShowScore_Score(mode))
		{ token = "SCORE";				title = str_score;			width = 75;		value = points;			}	break;

		case SCORESTAT_TIME_TAKEN:		if(GameMode_ShowScore_Time_Taken(mode))	if(missionend)
		{ token = "TIME_TAKEN";			title = str_timetaken;		width = 30;								}	break;	

	//	case SCORESTAT_TIME_LEFT:		if(GameMode_ShowScore_TimeLeft(mode))	if(missionend)	if()
	//	{ token = "TIME_LEFT";			title = str_timeleft;		width = 30;								}	break;
		
		case SCORESTAT_TIME_BONUS:		if(GameMode_ShowScore_TimeBonus(mode))	if(missionend)
		{ token = "TIME_BONUS";			title = str_timebonus;		width = 75;								}	break;
		
		case SCORESTAT_CAPTURES:		if(GameMode_ShowScore_Captures(mode))
		{ token = "CAPTURES";			title = str_captures;		width = 30;		value = captures;		}	break;

		case SCORESTAT_RETURNS:			if(GameMode_ShowScore_Returns(mode))
		{ token = "RETURNS";			title = str_returns;		width = 30;		value = returns;		}	break;

		case SCORESTAT_FRAGS_PLAYER:	if(GameMode_ShowScore_Frags_Player(mode))	if(!singleplayer)
		{ token = "FRAGS_PLAYER";		title = str_playerkills;	width = 30;		value = frags;			}	break;

		case SCORESTAT_FRAGS_AI:		if(GameMode_ShowScore_Frags_AI(mode))
		{ token = "FRAGS_NPC";			title = str_aikills;		width = 30;		value = frags_npc;		}	break;

		case SCORESTAT_FRAGS_OTHER:		if(GameMode_ShowScore_Frags_Other(mode))
		{ token = "FRAGS_OTHER";		title = str_misckills;		width = 30;		value = frags_other;	}	break;
		
		case SCORESTAT_DEATHS:			if(GameMode_ShowScore_Deaths(mode))
		{ token = "DEATHS";				title = str_deaths;			width = 30;		value = deaths;			}	break;
	
		case SCORESTAT_SUICIDES:		if(GameMode_ShowScore_Suicides(mode))
		{ token = "SUICIDES";			title = str_suicides;		width = 30;		value = suicides;		}	break;
		
		case SCORESTAT_ACCURACY:		if(GameMode_ShowScore_Accuracy(mode))
		{ token = "ACCURACY";			title = str_accuracy;		width = 30;		value = accuracy;		}	break;
	
		case SCORESTAT_DAMAGE_DEALT:	if(GameMode_ShowScore_Damage_Dealt(mode))
		{ token = "DAMAGE";				title = str_damagedealt;	width = 75;		value = damagedealt;	}	break;		
	}

	if(width)
	{
		fontsize = body_fontsize;//*languagefontscale;
		width = max(width, stringwidth(title, false, fontsize)+10);
	}
	
	scoreinfo_token = token;
	scoreinfo_title = title;
	scoreinfo_width = width;
	
	if(width)
	if(e)
		scoreinfo_value = e.value;	
}

void SetScoreboardPages(entity menu) =
{
	local float count, total_width, missionend;

//	drawfont = FONT_MENU;
	
	if(menu == menu_endscores)
		missionend = true;	
	
	scoreboard_page_width = 720 - 54;
	if(!(singleplayer && !missionend))
		scoreboard_page_width -= scoreboard_place_width + scoreboard_name_width;	
	
	menu.page_total = 1;
	for(count = 0; count < SCORESTATS_TOTAL; count++)
	{
		SetScoreDisplayInfo(menu, world, count, gamemode, false);
		total_width += scoreinfo_width;
		
		if(total_width > scoreboard_page_width - scoreboard_ping_width + scoreboard_ping_width*singleplayer)
		{
			total_width = 0;
			menu.page_total++;
			count -= 1;
		}
	}
	
	if(menu.page_current > menu.page_total-1)
		menu.page_current = menu.page_total-1;
}

void ListOption_MissionScores(float count) =
{
	local float option_pos_colstart, col_ofs, displayonpage, scount, tcount, missionend, numstats, total_width, page, skipfirsttcount;
	local string line, stat, s, pname;
	local vector highlightcolor, opsize, scoredisplayinfo, highlight_self, highlight_ally, rgb;
	local entity e;
	
	if(active_menu == menu_scores)
		missionend = false;
	else
	if(active_menu == menu_endscores)
		missionend = true;
	
	if(missionend)
	{
		for(e = list_playerchain; e && e.scoreplacing != count+1; e = e.playerchain)
		{}		
	}	
	else
	{
		e = list_playerchain;
		for(tcount = 0; tcount < count; tcount++)
			e = e.playerchain;		
	}
	
	highlight_self ='0 0.3 1';
	highlight_ally ='0 0.1 0.6';	
	
	opsize_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - body_fontsize_x*2 - option_spacing*2 - scrollbar_width*active_menu.drawingscrollbar;
	opsize_y = option_size_y;
	
	option_pos_colstart = option_pos_x;

	if(!(singleplayer & !missionend))
		option_pos_x += body_fontsize_x;
	
	if(missionend)
	{
		line = GetBufferString(active_menu.buf_list, count);
		tokenizebyseparator(line, SEP_QUOTE);
		
		if(argv(0) == "MISSIONSCORE")
		{
			skipfirsttcount = true;
			if(e == player)
				highlightcolor = highlight_self;
			else
				highlightcolor = highlight_ally;
		
			drawfill(option_pos, opsize, highlightcolor, 0.5, 0);
		}			
	}
	
	if(!(singleplayer & !missionend))
	{
		Menu_AlignedText(ftos(count+1), ALIGN_LEFT);	
		option_pos_x += scoreboard_place_width-body_fontsize_x;
	}
	
	if(missionend)
	{
		line = GetBufferString(active_menu.buf_list, count);
		tokenizebyseparator(line, SEP_QUOTE);		
		
		tcount = skipfirsttcount;
		for(stat = argv(tcount); stat; stat = argv(tcount))	
		{
			if(stat == "NAME")
			{	
				pname = argv(tcount+1);
				Menu_AlignedText(pname, ALIGN_LEFT);
				
				if(!singleplayer)
				if(skipfirsttcount)
				{
					option_pos_x += scoreboard_name_width;
					Menu_AlignedText(ftos(e.ping), ALIGN_LEFT);
					option_pos_x -= scoreboard_name_width;
				}
				
				break;
			}
			tcount+=2;
		}
		
		option_pos_x += scoreboard_name_width + scoreboard_ping_width - scoreboard_ping_width*singleplayer;		
		
		page = 0;
		for(scount = 0; scount < SCORESTATS_TOTAL && page <= active_menu.page_current; scount++)
		{
			SetScoreDisplayInfo(active_menu, world, scount, gamemode, false);		

			if(!scoreinfo_width)
				continue;

			total_width += scoreinfo_width;
			
			if(total_width > scoreboard_page_width - scoreboard_ping_width + scoreboard_ping_width*singleplayer)
			{
				page++;
				total_width = 0;
				scount-=1;
				continue;
			}			

			if(page < active_menu.page_current)
				continue;				
		
			tcount = skipfirsttcount;
			for(stat = argv(skipfirsttcount); stat; stat = argv(tcount))	
			{
				if(scoreinfo_token == stat)
				{
					s = argv(tcount+1);				
					if(scount == SCORESTAT_ACCURACY)
					{
						s = ftos(floor(stof(s)*100));
						s = strcat(s, "%");
					}
					
					Menu_AlignedText(s, ALIGN_LEFT);
					
					break;
				}
				
				tcount+=2;
			}

			option_pos_x += scoreinfo_width;
		}
	}
	else
	{
		if(GameMode_HasTeams(gamemode))
		{
			rgb = GetTeamColor(e.team);	
			drawfill(option_pos+'50 4 0', '12 12 0', rgb, 1, 0);
		}
			
		if(!(singleplayer && !missionend))
		{
			Menu_AlignedText(e.netname, ALIGN_LEFT);
			option_pos_x += scoreboard_name_width;
		}
		
		if(!singleplayer)
		{
			Menu_AlignedText(ftos(e.ping), ALIGN_LEFT);
			option_pos_x += scoreboard_ping_width;		
		}
		
		page = 0;
		for(scount = 0; scount < SCORESTATS_TOTAL && page <= active_menu.page_current; scount++)
		{
			SetScoreDisplayInfo(active_menu, e, scount, gamemode, false);
			
			if(!scoreinfo_width)
				continue;

			total_width += scoreinfo_width;
				
			if(total_width > scoreboard_page_width - scoreboard_ping_width + scoreboard_ping_width*singleplayer)
			{
				page++;
				total_width = 0;
				scount -= 1;
				continue;
			}
			
			if(page < active_menu.page_current)
				continue;
			
			if(scount == SCORESTAT_ACCURACY)
			{
				s = ftos(floor(scoreinfo_value*100));
				s = strcat(s, "%");	
			}	
			else
				s = ftos(scoreinfo_value);

			Menu_AlignedText(s, ALIGN_LEFT);
			option_pos_x += scoreinfo_width;
		}
	}
	option_pos_x = option_pos_colstart;
	BR();
}

void Draw_MissionScores() =
{
	local float maxnumplaces, count, page, total_width, playerplace, scoreviewingtime, windowwidth, numplaces, buttonwidth, firstoptnum, lastoptnum, prev_down, next_down, prev_up, next_up, end_down, listslots, buttonofs, missionend, choosingteam, players_max, allowed_difference, players_red, players_blue;
	local string s;
	local vector mboxsize, option_pos_start, scrollboxsize;
	local entity e;
	
	if(active_menu == menu_chooseteam)
	{
		choosingteam = true;
		
		for(e = list_playerchain; e; e = e.playerchain)
		{
			if(e.team == 1)
				players_red++;
			else
			if(e.team == 2)
				players_blue++;
		
			players_max++;
		}
		
		allowed_difference = floor(players_max/12)*2;
		players_max = (players_max-allowed_difference)/2;
		players_max = players_max + allowed_difference;
		if(allowed_difference)
			players_max = floor(players_max);		
	}
	else
	if(active_menu == menu_endscores)
		missionend = true;
	
	local string str_youplaced, str_tryharder, str_place, str_name, str_prevpage, str_nextpage, str_timeleftxseconds, str_retry, str_missionlist, str_nextmission, str_done, str_waitingonplayers, str_waitingonserver, str_joinred, str_joinblue, str_close, str_endgame, str_ping;
	
	mboxsize_x = 720;
	
	Menu_Start_Scoreboard("Scoreboard", mboxsize, __FUNC__);
	
	str_youplaced				= Translate("You placed #");
	str_tryharder				= Translate("Try harder.");
	str_place					= Translate("Place");
	str_name					= Translate("Name");	
	str_ping					= Translate("Ping");
	str_prevpage				= Translate("< Page");
	str_nextpage				= Translate("Page >");
	str_timeleftxseconds		= Translate("Time Left: %s seconds");
	str_retry					= Translate("Retry");
	str_missionlist				= Translate("Mission List");
	str_nextmission				= Translate("Next Mission");
	str_done					= Translate("Done");
	str_waitingonplayers		= Translate("Waiting on players ...");
	str_waitingonserver			= Translate("Waiting on server ...");
	str_joinred					= Translate("Join Red");
	str_joinblue				= Translate("Join Blue");
	str_close					= Translate("Close");
	str_endgame					= Translate("End Game");
	skiptranslation = true;
	
	SetScoreboardPages(active_menu);
	
	if(missionend && !GameMode_HasTeams(gamemode))
	{
		TempMenuSetting_body_fontsize('14 14 0');
	//	playerplace = getstati(63);
		if(player.scoreplacing)
			s = strcat(str_youplaced, ftos(player.scoreplacing));
		else
			s = str_tryharder;

		Menu_Text(s);
		RestoreMenuSetting_body_fontsize();
		BR();
	}
	
	windowwidth = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - 10 - option_spacing*2;
	buttonwidth = 120;	

	optionselection_horizontal = true;
	if(missionend && !GameMode_HasTeams(gamemode))
		numplaces = GetBufferSize(active_menu.buf_list);
	else
	{
		for(e = list_playerchain; e; e = e.playerchain)
			numplaces++;
	}
	
	#ifdef COMPILE_SERVICE_ONLIVE
		maxnumplaces = 20;
	#else
		maxnumplaces = 10;
	#endif
	
	listslots = bound(1, numplaces, maxnumplaces);
	
	if(numplaces > listslots)
	{
		if(active_menu.user_current_option == 0)
			selectedtextlist = true;
	}
	
	viewingtextlist = true;

	option_pos_start = option_pos;
	option_size	= '0 12 0';	

	if(!(singleplayer && !missionend))
	{
		Menu_AlignedText(str_place, ALIGN_LEFT);
		option_pos_x += scoreboard_place_width;
	
		Menu_AlignedText(str_name, ALIGN_LEFT);
		option_pos_x += scoreboard_name_width;	
	}
	
	if(!singleplayer)
	{
		Menu_AlignedText(str_ping, ALIGN_LEFT);
		option_pos_x += scoreboard_ping_width;		
	}
	
	page = 0;
	for(count = 0; count < SCORESTATS_TOTAL && page <= active_menu.page_current; count++)
	{
		SetScoreDisplayInfo(active_menu, world, count, gamemode, true);
		
		if(!scoreinfo_width)
			continue;
		
		total_width += scoreinfo_width;
		
		if(total_width > scoreboard_page_width - scoreboard_ping_width + scoreboard_ping_width*singleplayer)
		{
			total_width = 0;
			page++;
			count -= 1;
			continue;
		}
		
		if(page < active_menu.page_current)
			continue;
		
		Menu_AlignedText(scoreinfo_title, ALIGN_LEFT);
		option_pos_x += scoreinfo_width;
	}
	
	if(numplaces > listslots)
	{
		option_pos = option_pos_start;
		option_pos_y -= option_spacing;
		BR();	
	
		firstoptnum = 1;	
		TempMenuSetting_option_size_height(listslots*(option_size_y+option_spacing)+option_spacing);

		option_appearance = option_appearance | BACKGROUND;
		option_image				= "";		
		option_image_left			= "";
		option_image_right			= "";	
		option_image_highlight		= "";
		option_image_left_highlight	= "";
		option_image_right_highlight = "";	
		
		TempMenuSetting_option_size_width(windowwidth+10+option_spacing*2);
		Menu_Option_Text("", SUB_Null);
		
		RestoreMenuSetting_option_size_height();
		RestoreMenuSetting_option_size_width();
		
		option_appearance = option_appearance - option_appearance & BACKGROUND;
		option_image				= "gfx/menu/rm_button_mid_hl.tga";		
		option_image_left			= "gfx/menu/rm_button_left_hl.tga";
		option_image_right			= "gfx/menu/rm_button_right_hl.tga";	
		option_image_highlight		= "gfx/menu/rm_button_mid_hl.tga";
		option_image_left_highlight	= "gfx/menu/rm_button_left_hl.tga";
		option_image_right_highlight = "gfx/menu/rm_button_right_hl.tga";	
	}
	
	option_pos = option_pos_start;
	BR();
	option_pos_x += option_spacing;
	
	scrollboxsize_x = windowwidth + 10;
	scrollboxsize_y = listslots*(option_size_y+option_spacing)-option_spacing;
	
	drawfill(option_pos, scrollboxsize, '0 0 0', 0.5, 0);
	
	option_pos_x = option_pos_start_x + option_spacing;
	Draw_ScollingList(numplaces, listslots, 0, scrollboxsize_x, 2, 1, SUB_Null, ListOption_MissionScores);
	option_pos_x = option_pos_start_x;
	
	option_size	= '0 20 0';		

	if(missionend)
		option_pos_y += 10;
	
	if(buf_list_challenges)
	{
		DrawChallenges(6, true);
		option_pos_y += 10;
	}

	buttonofs = GetOffsetForCenteredHoriontalListButtons(2, buttonwidth);

	if(active_menu.page_total > 1)
	{
		HorizontalListButton(buttonofs, buttonwidth, str_prevpage, PrevMenuPage, 0, 0, 0, 0, MBT_BASIC);	
		HorizontalListButton(buttonofs + buttonwidth+option_spacing, buttonwidth, str_nextpage, NextMenuPage, 0, 0, 0, 0, MBT_BASIC);
		BR();
	}
	
	if(missionend)
	{
		if(!singleplayer)
		{
			scoreviewingtime = getstatf(STAT_SCOREVIEWINGTIME);	
			scoreviewingtime = max(0, scoreviewingtime - time);
			s = sprintf(str_timeleftxseconds, ftos(ceil(scoreviewingtime)));
			Menu_Text(s);
			BR();
		}
		
		if(!waitingonplayers)
		{
			if(singleplayer)
			{
				buttonofs = GetOffsetForCenteredHoriontalListButtons(3-active_menu.flags, buttonwidth);
				if(active_menu.flags == 1)		
				{				
					HorizontalListButton(buttonofs, buttonwidth, str_endgame, EndGame, 0, 0, 0, 0, MBT_BASIC);
					HorizontalListButton(buttonofs+buttonwidth+option_spacing, buttonwidth, str_retry, RetryMission, 0, 0, 0, 0, MBT_BASIC);
				}
				else
				{
					HorizontalListButton(buttonofs, buttonwidth, str_nextmission, NextMission, 0, 0, 0, 0, MBT_BASIC);
					HorizontalListButton(buttonofs+buttonwidth+option_spacing, buttonwidth, str_retry, RetryMission, 0, 0, 0, 0, MBT_BASIC);
					HorizontalListButton(buttonofs+(buttonwidth+option_spacing)*2, buttonwidth, str_missionlist, EndMission, 0, 0, 0, 0, MBT_BASIC);
									
				}
			}
			else
			{
				buttonofs -= (buttonwidth+option_spacing)*0.5;
				HorizontalListButton(buttonofs+buttonwidth+option_spacing, buttonwidth, str_done, EndMission, 0, 0, 0, 0, MBT_BASIC);
			}
			BR();
		}
		else
		if(!singleplayer)
		{
			if(active_menu.user_current_option > 1+firstoptnum)
				active_menu.user_current_option = 1+firstoptnum;
		
			if(waitingonplayers > 0)
				Menu_Text(str_waitingonplayers);
			else
			if(waitingonplayers < 0)
				Menu_Text(str_waitingonserver);
			BR();
		}		
	}
	else
	if(choosingteam)
	{
		BR();BR();

		if(players_red < players_max)
			HorizontalListButton(buttonofs, buttonwidth, str_joinred, JoinTeam_Red, 0, 0, 0, 0, MBT_BASIC);
		
		if(players_blue < players_max)
			HorizontalListButton(buttonofs + buttonwidth+option_spacing, buttonwidth, str_joinblue, JoinTeam_Blue, 0, 0, 0, 0, MBT_BASIC);		
		BR();
	}
	else
	{
		BeginBottomButtons(1);
		DrawElement_BottomButton(str_close, CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
		EndBottomButtons();
	}
	
	Menu_End();	
}

void ShowMissionScores() =
{
	local string s, stats;
	local float count, endgame, total_width;
	
	endgame = ReadByte();
	s = ReadString();

	timestopped = true;
	
	if(menu_death)
		CloseMenu();
		
	if(menu_scores)
		CloseMenu();
		
	if(menu_missionbriefing)
		CloseMenu();
	
	SetCurrentMenu(Draw_MissionScores);	
	menu_endscores = currentmenu;
	currentmenu.ESCFunc = ESCFunc_AllowESCMenu;
	currentmenu.CloseMenuFunc = CloseScoreboard;
	currentmenu.flags = endgame;
	
	pointsound('0 0 0', "sounds/equipment/ss_exitpad.wav", 1, ATTN_NONE);	
	
	if(GameMode_HasTeams(gamemode))
	{
		dprint("ShowMissionScores: is this used?\n");
		return;
	}
	
	currentmenu.buf_list = CreateBuffer();	
	tokenizebyseparator(s, SEP_QUOTE);
	
	for(count = 0; argv(count); count++)
	{
		if(argv(count) == "ENDSCORE")
		{
			AddBufferString(currentmenu.buf_list, stats, 0);
			stats = string_null;
		}
		else
		if(strlen(stats) < 1)
			stats = argv(count);
		else
			stats = AppendToken(stats, SEP_QUOTE, argv(count));
	}
}

void Call_LiveScores() =
{
	local float count, total_width;

	SetCurrentMenu(Draw_MissionScores);	
	menu_scores = currentmenu;
	currentmenu.CloseMenuFunc = CloseScoreboard;
//	SetScoreboardPages(currentmenu);
}

void Call_ChooseTeam() =
{
	SetCurrentMenu(Draw_MissionScores);	
	menu_chooseteam = currentmenu;
	currentmenu.ESCFunc = ESCFunc_AllowESCMenu;
	currentmenu.CloseMenuFunc = CloseScoreboard;
//	SetScoreboardPages(currentmenu);
}

void Toggle_LiveScores() =
{
	if(timestopped)
		return;

	if(menu_chooseteam)
		return;
		
	if(menu_missionbriefing)
	{
		currentmenu = menu_missionbriefing;
		CloseMenu();
	}
		
	if(menu_scores)
	{
		currentmenu = menu_scores;
		CloseMenu();
	}
	else
		Call_LiveScores();
}

#ifdef COMPILE_SERVICE_ONLIVE
	void SubmitPlayerName() =
	{
		local string playername, s;

		playername = GetBufferString(active_menu.buf_list, 0);
		
		if(AllSpaces(playername))
		{
			currentmenu.bodystring = "INVALIDNAME";
			return;
		}
		
		player.netname = zonecpy(player.netname, playername);
		s = strcat("cmd submitplayername ", SEP_QUOTE, playername, SEP_QUOTE, "\n");
		localcmd(s);
		CloseMenu();
	}

	void Draw_AskForPlayerName() =
	{
		local vector input_size;
		local string s;
		local float maxnamelength;
		
		maxnamelength = 26;
		
		Menu_Start_ConfirmationMenu_RealArcade("", '400 400 0', __FUNC__);

		option_size_y = 24;
		
		local string str_youplaced, str_enteryourname;
		
		str_youplaced				= Translate("You placed #");
		str_enteryourname			= Translate("ENTER YOUR NAME");
		skiptranslation = true;

		input_size_x = (maxnamelength+1)*input_fontsize_x+option_spacing*2;
		
		s = strcat(str_youplaced, ftos(player.scoreplacing));
		Menu_Text(s);
		BR();
		
		Menu_Text(str_enteryourname);
		BR();

		option_size_y = 12;
		body_fontsize = '10 10 0'*languagefontscale;
		skiptranslation = false;		
		Menu_InputWarnings();
		skiptranslation = true;	
		body_fontsize = '24 20 0';//*languagefontscale;		
		option_size_y = 24;
		
		maxinputchars = maxnamelength;
		Menu_Input_All(input_size, player.netname, 0, 0, SUB_Null);//SubmitPlayerName);
		maxinputchars = 0;
		skiptranslation = false;
		
		option_pos_y += 12;
		
	//	option_size_y = 35;
		
		Draw_VirtualKeyboard(SubmitPlayerName);
		
	//	Menu_Option_Text("CONTINUE", SubmitPlayerName);
	
		Menu_End();	
	}

	void AskForPlayerName() =
	{
		pointsound('0 0 0', "sounds/equipment/ss_exitpad.wav", 1, ATTN_NONE);	
		SetCurrentMenu(Draw_AskForPlayerName);
		currentmenu.ESCFunc = ESCFunc_AllowESCMenu;
		active_input = 1;
		active_vkb = 1;
		currentmenu.user_current_option = 36;
	}
	
	void GetScoresFromServer() =
	{
		CloseMenu();
	
		if(player.scoreplacing)
			AskForPlayerName();
		else
			localcmd("cmd getscoresfromserver_realarcade\n");
	}
	
	void Draw_MissionComplete_RealArcade() =
	{
		Menu_Start_ConfirmationMenu_RealArcade("", '400 300 0', __FUNC__);

		Menu_Text("MISSION COMPLETE");
		BR();
		
		Menu_Option_Text("CONTINUE", GetScoresFromServer);
		
		Menu_End();		
	}
	
	void MissionComplete_RealArcade() =
	{
		pointsound('0 0 0', "sounds/equipment/ss_exitpad.wav", 1, ATTN_NONE);	
		SetCurrentMenu(Draw_MissionComplete_RealArcade);
		currentmenu.ESCFunc = ESCFunc_AllowESCMenu;
	}
#endif