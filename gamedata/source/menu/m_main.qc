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
vector	WINDOWSIZE_BR	= '445 120 0';
float	buf_MOTD;

void PacifyCompiler_Menu() =
{
	null_entity = null_entity;
	drawfont = drawfont;
}

float	saveprofiletime;
void GameCommand(string strMessage) =
{
	if(isdemo())
		return;	

	local string s, rev;
	tokenize(strMessage);
	s = argv(0);
	
	switch(s)
	{
	//	case "mousepos":
	//		mousepos = stov(argv(1));
	//		DRAWMOUSE = true;
	//		break;
	//	case "mergemissionfiles":	MergeMissionFiles(argv(1), argv(2), argv(3));	break;
	
		case "callupdatemenus":	
			if(cvar("profile_updateflag_controls"))
				SetCurrentMenu(Draw_ProfileUpdated);		
			cvar_set("profile_updateflag_controls", "0");
			saveprofiletime = time+1;
			break;
	
		case "requestingjoinpassword":	requestingjoinpassword = stof(argv(1));		break;

		case "localize_generate":	GenerateMenuFiles();		break;
	
		case "admintoggle_maxents":	SetCurrentMenu(Draw_AdminToggle_MaxEnts);	break;
	
		case "restoresystem":
			RestoreSystemSettings(false);
			
			#ifndef COMPILE_SERVICE_ONLIVE
				cvar_set("profile", profile_active);
			#endif
			
			cvar_set("chase_fpscam", ftos(unlocked_fpscamera));
			UpdateProfileRevision();
			break;
	
		case "mission_editor_on":	missioneditor_enabled = true;	/*m_hide();*/		break;
		case "mission_editor_off":	missioneditor_enabled = false;	/*m_hide();	*/	break;
	
		case "game_init":	
			m_hide();
			
			if(!profile_active)
				PlayAsDefault();
				
			local float mode;
			gamemode = stof(argv(1));
			singleplayer = stof(argv(2));
			maxplayers = stof(argv(3));
			alloweditorinmultiplayer = stof(argv(4));
				
		/*	deathmatch = false;
			coop = false;
				
			if(mode & 1)
				deathmatch = true;
			if(mode & 2)
				coop = true;*/
				
		/*	if(deathmatch)
				gamemode = GAMEMODE_DEATHMATCH;
			else
				gamemode = GAMEMODE_CAMPAIGN;*/

			if(singleplayer)//!coop && !deathmatch)
			{
				missioneditor_enabled = false;
				SetGameTypeSinglePlayer();
			}
			else				
			if(maxplayers > 1)
			{
				missioneditor_enabled = false;
				if(isserver())
					SetGameTypeHostMultiPlayer();
				else
					SetGameTypeMultiPlayer();
			}
			else
			{
				missioneditor_enabled = true;
				SetGameTypeOfflineMissionEditor();
			}
				
			break;
		
		case "mission_finished":

		//	if(clientstate() == CS_DEDICATED
		//	|| (gametype == GAMETYPE_HOSTMULTIPLAYER && cvar("sv_missionrotation")))
		//		RotateMission();
		
			if(gametype == GAMETYPE_OFFLINEMISSIONEDITOR)
				m_display();
		
			if(gametype == GAMETYPE_HOSTMULTIPLAYER || gametype == GAMETYPE_SINGLEPLAYER)
			{
				m_display();
				if(!cvar("menu_drawscene"))
				{
					currentmenu.user_current_selection = 1;	
					
					#ifndef COMPILE_GAMEPLAYOPTIONS_SINGLEPLAYER
						SetCurrentMenu(Draw_MultiPlayerMenu);
					#endif
					
					Call_MissionMenu(0);
				}
			}
				
			if(gametype == GAMETYPE_SINGLEPLAYER)	
			{
				localcmd("disconnect\n");//;cd loop music/ss_theme.ogg\n");	
				LoadProfile();
				PlayMenuMusic();
			}
				
			if(gametype == GAMETYPE_HOSTMULTIPLAYER)
				mission_finished = true;	
				
			ResetConnectionValues();	
				
			break;
		
//		case "mission_finished":	mission_finished = true;					break;
	
	}
}

/*float checkupdatetime;
void CheckUpdates() =
{
	local float file;
	file = FileOpen("ep2.ver", FILE_READ);
	if(file == -1)
	{
		print("FILE NOT FOUND\n");
		return;
	}
		
	print("FOUND EP2.TXT!!!!!!!!!!!!!!!!!!!!\n");
		
	fclose(file);
	
	checkupdatetime = 0;
}*/

void Draw_UpdatesAvailable() =
{
	local string s;
	local vector textblocksize;
	
	Menu_Start_ConfirmationMenu("Updates Available", '0 0 0', __FUNC__);

	textblocksize_x = 380 - border_size_x*2 - body_margin_x*2;	
	textblocksize_y = 50;		
	
	Menu_Text("New updates are available at www.steel-storm.com.");
	BR();
	
	skiptranslation = true;
	s = GetBufferString(active_menu.buf_contents, 0);
	active_menu.buf_textblock = DrawTextBlock(active_menu.buf_textblock, option_pos, -1, textblocksize, s, body_fontsize, body_fontcolor, body_fontalpha, body_fontflags);
	skiptranslation = false;
	
	BeginBottomButtons(1);	
	DrawElement_BottomButton("Close", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();	
	
	Menu_End();
}

vector GetMOTD_fontsize() =	{	return '8 8 0'*languagefontscale;		}

void URI_Get_Callback(float id, float status, string data) =
{
	local float current_rev, new_rev, buf, count;
	local vector fontsize;
	
	if(status)
		return;

	data = substring(data, 0, strlen(data)-1); // hack to remove line break at eof
		
	if(id == 0) // updates message
	{
		buf = CreateBuffer();
		tokenizebyseparator(data, "\n");
		for(count = 0; argv(count); count++)
			AddBufferString(buf, argv(count), 0);
		
		tokenizebyseparator(REVISION, "v", ".");
		current_rev = stof(argv(3));	
		new_rev = stof(GetBufferString(buf, 0));
	
		if(new_rev > current_rev)
		{
			updatesavailable = true;
			SetCurrentMenu(Draw_UpdatesAvailable);
			currentmenu.buf_contents = CreateBuffer();
			AddBufferString(currentmenu.buf_contents, GetBufferString(buf, 1), 0);
		}
		
		DeleteBuffer(buf);	
	}
	else
	if(id == 1) // message of the day
	{
		fontsize = GetMOTD_fontsize();
		Menu_Defaults();
		drawfont = body_font;
	//	body_textbordersize_y = 0;
	//	buf_MOTD = DrawTextBlock(buf_MOTD, '0 0 0', -1, WINDOWSIZE_BR, data, MOTD_fontsize, '0 0 0', 0, 0);	// prepares block of text for later
		buf_MOTD = GenerateTextBlock(buf_MOTD, WINDOWSIZE_BR, data, fontsize);
	}		
}

void StopGameIntro() =
{
	// start music if intro hasn't actually started yet
	if(!game_intro_starttime)
		PlayMenuMusic();

	game_intro_playing = false;
	game_intro_starttime = 0;
	ClearAllInputValues();
}

void DrawGameIntro() =
{
	local vector pos, imgsize;
	local float alph, elapsedtime, fadetime, endtime_kia, endtime_ss, fadeouttime_kia, fadeouttime_ss;
	local string imgname;
	
	if(!time)
		return;
	
	if(!game_intro_playing)
		return;
		
	if(!game_intro_starttime)
	{
		PlayMenuMusic();
		game_intro_starttime = time;
	}
	
	elapsedtime = time - game_intro_starttime;
	fadetime = 1.5;	
	fadeouttime_kia = 1.5;
	fadeouttime_ss = 2.7;
	endtime_kia = 4;
	endtime_ss = 10.6;

//	fadetime = 1.5;	
//	fadeouttime_kia = 3;
//	fadeouttime_ss = 3;
//	endtime_kia = 10.6;
//	endtime_ss = 20;
	
	if(elapsedtime < endtime_kia)
	{
		if(elapsedtime < fadetime)
			alph = elapsedtime/fadetime;
		else
		if(elapsedtime >= endtime_kia-fadeouttime_kia)
			alph = 1-(elapsedtime-(endtime_kia-fadeouttime_kia))/fadeouttime_kia;
		else
			alph = 1;	

		imgname = "gfx/intro_kia_logo.tga";
	}
	else
	if(elapsedtime < endtime_ss)
	{
		if(elapsedtime < endtime_kia+fadetime)
			alph = (elapsedtime-endtime_kia)/fadetime;
		else
		if(elapsedtime >= endtime_ss-fadeouttime_ss)
			alph = 1-(elapsedtime-(endtime_ss-fadeouttime_ss))/fadeouttime_ss;
		else
			alph = 1;
			
		imgname = "gfx/intro_ss_logo.tga";
	}
	else
	{
		StopGameIntro();
		return;
	}
	
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
	drawpic(pos, imgname, imgsize, '1 1 1', alph, 0);
}

void PlayGameIntro() =
{
	game_intro_playing = true;
//	game_intro_starttime = time;
}

void GetMOTD() =
{
	#ifdef COMPILE_SERVICE_ONLIVE
		uri_get("http://www.steel-storm.com/motd/motd_onlive.txt", 1);	
	#else
		if(currentlanguage == LANGUAGE_JAPANESE)
			uri_get("http://www.steel-storm.com/motd/motd_japanese.txt", 1);			
		else
			uri_get("http://www.steel-storm.com/motd/motd.txt", 1);				
	#endif
}

void m_init() =
{
	CODEBASE = MENUCODE;

	cvar_set("episode", ftos(EPISODE));
	cvar_set("gameversion", ftos(EPISODE));
	
	currentlanguage = cvar("localize_language");
	SetLanguageFontScale();
	
	Font_Init(currentlanguage);
	Menu_Init();
	
	Video_Update(); // this is needed to set con size with vid_res
	SetConSize(vid_res);	
	
	PlayGameIntro();
	SpawnMainMenu();
	LoadDefaultProfile();
	
	menucredits_scrollpos_y = -150;
	
//	localcmd("cd loop music/ss_theme.ogg\n");

	uri_get(strcat("http://www.steel-storm.com/latestversions/ep", ftos(EPISODE), ".txt"), 0);

	GetMOTD();
}

//float	cl_buttondown;
void m_keyup(float key, float ascii) =
{
//	if(key == cl_buttondown)
//		cl_buttondown = 0;

//	if(key == K_MOUSE1)
//		mousedrag = 2;

//	cl_button = -key;

	InterfaceKeys(true, key, ascii);
}

void m_keydown(float key, float ascii) =
{
//	if(key == cl_buttondown)
//		return;

//	if(key == K_MOUSE1)
//		mousedrag = TRUE;

	if(videoplaying())
	{
		if(key)
			cmd("stopvideo\n");
		return;
	}

	if(quitalpha)
	{
		if(quitalpha == 1)
		if(key)
			cmd("quit\n");
		return;
	}

	if(game_intro_playing)
	{
		if(key)
			StopGameIntro();
			
		return;
	}

	InterfaceKeys(false, key, ascii);	
	
//	if(GetControlIDForKeyNumber(key, -1) == CTRL_ESCAPE)
	if(GameControl(CTRL_ESCAPE, 0))
	if(!(settingkeybind && (key != K_ESCAPE)))
//	if(key == K_ESCAPE)
	{
				if(IsAssignedFunction(currentmenu.ESCFunc))
					currentmenu.ESCFunc();
				else
					CloseMenu();
	//	else	
	//	if(connected == CS_CONNECTED)
	//		m_toggle();
		MenuSound(SOUND_CANCELCLICK);
	}
	
//	if(key == K_MOUSE1)
//	if(GetControlIDForKeyNumber(key, -1) == CTRL_MENUBUTTON1)
	if(GameControl(CTRL_MENUBUTTON1, 0))
		arrowkeymovement = FALSE;	
	
	
//	cl_buttondown = key;
//	cl_button = key;
}

// ================================================================
//	Main drawing procedure
// ================================================================

float	scrollingbgtext_starttime;
float Draw_ScrollingBGText(float buf, string text) =
{
	local vector credboxsize, scrollspeed, pos;

	scrollspeed = '-70 -20 0';		
		
	if(scrollingbgtext_starttime <= time)
	{
		scrollingbgtext_starttime = 0;
		menucredits_scrollpos_y += scrollspeed_y*frametime;		
	}
	
	pos = menucredits_scrollpos;
	pos_y += vid_size_y;
	pos_x = ((vid_size_x-800)*0.5)+POS_MAIN_TR_x;

	menucredits_scrollpos_x = pos_x;
	
	credboxsize = WINDOWSIZE_RIGHTPANE;
	credboxsize_y = 0;

	Menu_Defaults();
	buf = DrawTextBlock(buf, pos, 0, credboxsize, text, '10 10 0'*languagefontscale, '1 1 1', 0.5, 0);
	
	return buf;
}

void DrawCredits() =
{
	local vector pos, imgpos, imgsize;
	local string s, spacer, separator, imgname, filename;
	local float creditheight, buffersize, translate;
		
	imgname = "gfx/menu/kia_logo.tga";
	imgsize = drawgetimagesize(imgname)*0.75;		
		
	translate = skiptranslation;
	skiptranslation = false;

	filename = __FUNC__;
	buf_localizecredits = InitializeNonstandardTranslations(buf_localizecredits, filename, false);
	
	if(!buf_credits)// || LOCALIZE_GENERATING)
	{
		spacer = ";;;;;";
		separator = ";";
		
		s = strcat("CREDITS;", spacer);
		
		s = strcat(s, "Game Design;");
		s = strcat(s, separator);
		s = strcat(s, "Alexander \"motorsep\" Zubov;Clay \"daemon\" Cameron;Forest \"LordHavoc\" Hale;");
		s = strcat(s, spacer);		
		
		s = strcat(s, "Art Director / Artist / Level Designer;");
		s = strcat(s, separator);
		s = strcat(s, "Alexander \"motorsep\" Zubov;");
		s = strcat(s, spacer);
		
		s = strcat(s, "Lead Game Logic / In-game Tools Programmer;");
		s = strcat(s, separator);
		s = strcat(s, "Clay \"daemon\" Cameron;");
		s = strcat(s, spacer);
		
		s = strcat(s, "Additional Tools Programmer;");
		s = strcat(s, separator);
		s = strcat(s, "Pavel \"VorteX\" Timofeev;");
		s = strcat(s, spacer);
		
		s = strcat(s, "Darkplaces Engine Support Team;");
		s = strcat(s, separator);
		s = strcat(s, "Forest \"LordHavoc\" Hale;Rudolf \"DivVerent\" Polzer;");
		s = strcat(s, spacer);
		
		s = strcat(s, "Lead Level Designer;");
		s = strcat(s, separator);
		s = strcat(s, "Pawel \"ShadoW\" Chrapka;");
		s = strcat(s, spacer);
		
		s = strcat(s, "World Textures;");
		s = strcat(s, separator);
		s = strcat(s, "Georges \"TraK\" Grondin;Alexander \"motorsep\" Zubov;");
		s = strcat(s, spacer);
		
		s = strcat(s, "Music / Sound Effects Design;");
		s = strcat(s, separator);
		s = strcat(s, "Christian Floisand;Igor Correia;");
		s = strcat(s, spacer);
		
		s = strcat(s, "QA;");
		s = strcat(s, separator);
		s = strcat(s, "Samual Lenks;Michael \"Ratchet\" Lubker;David \"scar3crow\" Queener;Darren T. Priddy;");
		s = strcat(s, spacer);
		
		s = strcat(s, "IT Support;");
		s = strcat(s, separator);
		s = strcat(s, "Paul \"Echon\" Jackson;William Weilep;ply2;");
		s = strcat(s, spacer);
		
		s = strcat(s, "Business Development;");
		s = strcat(s, separator);
		s = strcat(s, "Alexander \"motorsep\" Zubov;Michael \"Ratchet\" Lubker;");
		s = strcat(s, spacer);		
	
		s = strcat(s, "Localizaton Support;");
		s = strcat(s, separator);
		s = strcat(s, "Heber Lima;Pedro Veloso;Arturo Gonzalez Silva;Gian Maria Viglianti;Stephen Kitt;Daniel Halens;Bernd Ritter;Manuel Soukup;Commandline;Reto Schneider;Meldrian;");
		s = strcat(s, spacer);
	
		s = strcat(s, "Special Thank You;");
		s = strcat(s, separator);
		s = strcat(s, "Andreas \"Black\" Kirsch;Lee \"eihrul\" Salzman;Entar;Daniel Salazar;Alex \"Jehar\" Popa;Merlijn Hofstra;Steve Valdez;Michael Hadam;Arturo Gonzalez Silva;Chris Hogan;Adam Stovicek;Sven Arvidsson;");
		s = strcat(s, spacer);
		
		s = strcat(s, "www.steel-storm.com;www.kot-in-action.com");
	}

	s = Localize(s, buf_localizecredits);

	WriteNonstandardTranslations(buf_localizecredits, filename, false, false);		
	
	drawfont = FONT_USER2;
	buf_credits = Draw_ScrollingBGText(buf_credits, s);
	
	buffersize = GetBufferSize(buf_credits);
	creditheight = buffersize*10*languagefontscale + imgsize_y + 80;
	
	pos = menucredits_scrollpos;
	pos_y += vid_size_y + (creditheight - imgsize_y);	
	imgpos = AlignmentPos(pos, WINDOWSIZE_RIGHTPANE, imgsize, '0 1 0', '0 0 0');
	drawpic(imgpos, imgname, imgsize, '1 1 1', 0.5, 0);		
	
	if(menucredits_scrollpos_y <= (vid_size_y+creditheight)*-1)
		menucredits_scrollpos_y = 0;
		
	skiptranslation = translate;	
}

vector menusubbg_scrollpos;
void DrawScrollingBackground() =
{
	if(clientstate() == CS_CONNECTED)
		return;
		
	local vector scrollspeed, pos, imgsize;
	local string imgname;
	
//	scrollspeed = '-70 -20 0';
	scrollspeed = '-1 10 0';
	
	scrollspeed_x = 1 - random()*2;
	
	imgname = "gfx/conback.tga";
	imgsize = drawgetimagesize(imgname);	
	
	menusubbg_scrollpos += scrollspeed*frametime;
	if(menusubbg_scrollpos_x < -imgsize_x || menusubbg_scrollpos_x > imgsize_x)
		menusubbg_scrollpos_x = 0;
	if(menusubbg_scrollpos_y < -imgsize_y || menusubbg_scrollpos_y > imgsize_y)
		menusubbg_scrollpos_y = 0;
		
	pos = menusubbg_scrollpos;
	
//	start = pos;	
//	end = vid_size;
	pos -= imgsize;	
	drawtiledpic(pos, imgname, vid_size+imgsize*2, '1 1 1', 0.5, 0);
	
//	if(!currentmenu)
//		return;

	DrawCredits();
}

void DrawRevision() =
{
	local vector pos, fontsize;
	local string s;
	
	drawfont = FONT_MENU;
	fontsize = '8 8 0'*languagefontscale;
	
	pos_x = 800-stringwidth(REVISION, false, fontsize);
	pos_x += (vid_size_x-800)*0.5;
	pos_y = 600-fontsize_y;
	pos += '-4 -4 0';
	drawstring(pos, REVISION, fontsize, '1 1 1', 1, 0);
	
	if(updatesavailable)
	{
		s = "UPDATES AVAILABLE";
		pos_x = 800-stringwidth(s, false, fontsize);
		pos_x += (vid_size_x-800)*0.5;	
		pos_y = 600-fontsize_y*2-2;
		pos += '-4 -4 0';
		drawstring(pos, s, fontsize, '1 1 0', 1, 0);
	}
}

void DrawScene_Text() =
{
	local string s;
	local float creditheight, buffersize;
		
	s = cvar_string("menu_drawscene_text");
	drawfont = FONT_USER2;
	buf_scenetext = Draw_ScrollingBGText(buf_scenetext, s);
	buffersize = GetBufferSize(buf_scenetext);	
	creditheight = buffersize*10*languagefontscale;	
	
	if(menucredits_scrollpos_y <= (vid_size_y+creditheight)*-1)
	{
		drawscene_stage = 2;
		menucredits_scrollpos_y = 0;
	}
}

void DrawScene() =
{
	local string imgname, s;
	local vector imgsize, pos;
	local float drawscene_runningtime;

//	if(!cvar("menu_drawscene_text"))
	if(!cvar("menu_drawscene"))
		return;
	
	imgname = cvar_string("menu_drawscene_imgname");
	
//	if(!imgname)
//		return;
	
	if(cl_button)
	{
//		drawscene = SUB_Null;
		DeleteBuffer(buf_scenetext);
		buf_scenetext = 0;
		cvar_set("menu_drawscene", "0");
		cvar_set("menu_drawscene_text", "");
		cvar_set("menu_drawscene_imgname", "");
		drawscene_stage = 0;
//		EndMission();
		return;
	}	
	
	if(!drawscene_stage)
	{
		drawscene_stage = 1;
	//	drawscene_starttime = time;
		menucredits_scrollpos_y = -420;
		scrollingbgtext_starttime = time+5;
	//	s = strcat("cd loop ", cvar_string("menu_bgmusic"), "\n");
	//	localcmd(s);
	}
		
//	drawscene_runningtime = time - drawscene_starttime;
	
	if(strlen(imgname))
	{
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

	if(drawscene_stage == 1)
		DrawScene_Text();
	else
	if(drawscene_stage == 2)
		DrawCredits();	
}

void DrawMOTD() =
{
	local vector pos, fontsize;

	if(!menu_drawMOTD)
		return;
	
	if(!buf_MOTD)
		return;
		
	pos_x = vid_size_x*0.5 - 90;
	pos_y = 440;

	Menu_Defaults();
	drawfont = body_font;
	fontsize = GetMOTD_fontsize();
	DrawTextBlock(buf_MOTD, pos, -1, WINDOWSIZE_BR, string_null, fontsize, '0.46 0.62 0.75', 1, 0);	
}

float mouseinit;
void m_draw() =
{
	local float t;
	local vector oldmousepos, mouseofs, bgpos, bgsize;
	
	FastKeyRelease();
	
	UpdateLanguage();
	
	t = gettime();
	frametime = min(0.2, t - menuPrevTime);
	menuPrevTime = t;
	time += frametime;
	time_local = time;
	
	if(!menuActive)
		return;

	if(saveprofiletime)
	if(time >= saveprofiletime)
	{
		saveprofiletime = 0;
		SaveProfileConfig();
	}
		
//	if(checkupdatetime)
//	if(time >= checkupdatetime)
//		CheckUpdates();
		
	Video_Update();
	BindMap_Update();	
//	connected = clientstate();

/*	if(updateconsizeforres != '0 0 0')
//	if(updateconsizeforres == vid_res)
	{
		system_res = vid_res;
		SetConSize(updateconsizeforres);
		updateconsizeforres = '0 0 0';
	}*/

	if(quitalpha < 1)
	if(!videoplaying())
	{
		if(!quitalpha)
		{
			oldmousepos = mousepos;
			mousepos = getmousepos();
			
			if(mousepos != oldmousepos)
				arrowkeymovement = FALSE;
		}
			
		if(!drawscene_stage)
		if(!game_intro_playing)
		{
			DrawScrollingBackground();	
				
			if(strlen(menu_background) > 0)
			{
				bgsize = drawgetimagesize(menu_background);
				bgpos_x = (vid_size_x - bgsize_x)*0.5;
				drawpic(bgpos, menu_background, bgsize, '1 1 1', 1, 0);
			}
			
			DrawRevision();
			DrawMOTD();				
			
			DrawMenus();	
		}
		
		DrawGameIntro();
		DrawScene();
		
		if(!quitalpha)
			drawpic(mousepos + '-1 -1 0', "gfx/gui/cursor.tga", '14 19 0', '1 1 1', 1, 0);
	}

	if(quitalpha)
		FadeToSplashScreen();	

	frametime = 0;
	ClearInput();
	
//	if(mousedrag == 2)
//		mousedrag = FALSE;
	
/*	if(clearmenusatendofframe) // what is up with this?
	{
		if(clearmenusatendofframe < 3)
		{
			if(clearmenusatendofframe == 1)
				ClearMenus();
		
			clearmenusatendofframe++;
		}
		else
		{
			clearmenusatendofframe = FALSE;
//			m_hide();			
			LoadMap();
		}
	}	*/
}

void m_display() =
{
	local string s;

	menuActive = true;
	
	UpdateBindMap();
	
	if(clientstate() == CS_CONNECTED)
		localcmd("cl_cmd escmenu_true\n");
/*	else
	{
		if(cvar_string("menu_bgmusic"))
		{
			s = strcat("cd loop ", cvar_string("menu_bgmusic"), "\n");
			localcmd(s);
		}
		else
			localcmd("cd loop music/ss_theme.ogg\n");
	}*/

	setkeydest(KEY_MENU);
//	setmousetarget(MT_MENU);
}

void m_hide() =
{
	CloseMenuBranch(menu_count-1);
	SpawnMainMenu();

	menuActive = false;
	mission_finished = false;
	
	if(clientstate() == CS_CONNECTED)
		localcmd("cl_cmd escmenu_false\n");

	setkeydest(KEY_GAME);
//	setmousetarget(MT_CLIENT);
}

void m_toggle() =
{
	if(menuActive)
	{
		if(!mission_finished)
			m_hide();
	}
	else
		m_display();
}

void m_shutdown() =
{
	m_hide();
}

void m_quit() =
{
	m_toggle();
}
