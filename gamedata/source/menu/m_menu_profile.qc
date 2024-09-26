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
void SetName() =
{
	local string s;
	
	#ifndef COMPILE_SERVICE_ONLIVE
		s = strcat("name ", SEP_QUOTE);
		s = strcat(s, profile_active);
		s = strcat(s, SEP_QUOTE);
		s = strcat(s, "\n");
		localcmd(s);
	#endif
}

void PlayAsDefault() =
{
	#ifdef COMPILE_SERVICE_ONLIVE
		profile_active = zonecpy(profile_active, "player");
	#else
		profile_active = zonecpy(profile_active, "default");
	#endif
	
	SetName();
}

void BackToProfileMenu() =
{
	CloseMenu();
	Call_ProfileMenu();
}

void SaveProfileConfig() =
{
	if(!profile_active)
		return;

	#ifdef COMPILE_SERVICE_ONLIVE
		localcmd("saveconfig\n");
	#else
		local string s;
		s = strcat("saveconfig data/profiles/_", strtolower(uri_escape(profile_active)));
		s = strcat(s, ".cfg\n");
		localcmd(s);
	#endif
}

float	colorselection_hue;
float	colorselection_value;
float	colorselection_saturation;
vector	colorselection;

float	playercolor_hue;
float	playercolor_value;
float	playercolor_saturation;
vector	player_colors;

float	reticlecolor_hue;
float	reticlecolor_value;
float	reticlecolor_saturation;

void SaveProfile(float PROFILEFILEVERSION) =
{
	local float count, file, buffer_size, fileversion;
	local string filename, line, t;
	
	if(!profile_active)
		return;
	
	filename = strcat("profiles/_", uri_escape(profile_active));
	filename = strcat(filename, ".profile");

	file = FileOpen(filename, FILE_READ);	
	if(file == -1)
	{
	//	print("Profile does not exist.\n");
		return;
	}	

	active_menu.buf_list = CreateBuffer();

	for(line = fgets(file); line; line = fgets(file))
	{
		tokenizebyseparator(line, SEP_SPACE);
		t = argv(0);	
		
		if(t == "VERSION")
			fileversion = stof(argv(1));
	
		if(t == "RETICLE")
			break;	
	}

	for(line = fgets(file); line; line = fgets(file))		
	{
		if(PROFILEFILEVERSION == 1.1)
		{
			tokenizebyseparator(line, SEP_SPACE);
			if(argv(0) == "episode_2:_burning_retribution")
				line = substring(line, 11, strlen(line)-11);
		}
		
		AddBufferString(active_menu.buf_list, line, 0);	
	}
	
	fclose(file);
	
//	filename = uri_escape(filename);
	file = FileOpen(filename, FILE_WRITE);

	line = strcat("VERSION ", ftos(PROFILEFILEVERSION));
	NewFileLine(file, line);
	
	line = strcat("NAME ", profile_active);
	NewFileLine(file, line);
	
	line = strcat("COLORS ", ftos(player_colors_x));
	line = strcat(line, " ");
	line = strcat(line, ftos(player_colors_y));
	line = strcat(line, " ");
	line = strcat(line, ftos(player_colors_z));
	line = strcat(line, " ");
	line = strcat(line, ftos(playercolor_hue));
	line = strcat(line, " ");
	line = strcat(line, ftos(playercolor_value));
	line = strcat(line, " ");
	line = strcat(line, ftos(playercolor_saturation));
	NewFileLine(file, line);	
	
	line = strcat("RETICLE ", ftos(reticlecolor_hue));
	line = strcat(line, " ");
	line = strcat(line, ftos(reticlecolor_value));
	line = strcat(line, " ");
	line = strcat(line, ftos(reticlecolor_saturation));
	NewFileLine(file, line);		
	
	buffer_size = GetBufferSize(active_menu.buf_list);
	for(count = 0; count < buffer_size; count++)
		NewFileLine(file, GetBufferString(active_menu.buf_list, count));

	fclose(file);	
	
	SaveProfileConfig();
}

void Close_PlayerChallengesForGameMode() =
{
	if(buf_list_challenges)
	{
		DeleteBuffer(buf_list_challenges);
		buf_list_challenges = 0;
	}
}

void Draw_PlayerChallengesForGameMode() =
{
	Menu_Start_ESCMenu("CHALLENGES", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	
	local string str_nochallenges;
	
	str_nochallenges = Translate("You have not completed any challenges.");
	
	#ifndef COMPILE_SERVICE_ONLIVE
		skiptranslation = true;
		DrawElement_OptionTitle(strtoupper(currentmenu.bodystring));	
		skiptranslation = false;
	#endif
	
	skiptranslation = true;
	
	if(buf_list_challenges)
		DrawChallenges(5, false);
	else
		Menu_Text(str_nochallenges);
	
	skiptranslation = false;
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_BASIC);	
	EndBottomButtons();
	
	Menu_End();
}

void Call_PlayerChallengesForGameMode(float challenge_gamemode) =
{
	local float file, challenge_gamemode_string_len;
	local string filename, line, challenge_gamemode_string;

	filename = strcat("profiles/_", uri_escape(profile_active));
	filename = strcat(filename, ".profile");

	file = FileOpen(filename, FILE_READ);	
	if(file == -1)
	{
	//	print("Profile does not exist.\n");
		return;
	}	
	
	challenge_gamemode_string = GetGameMode_String(challenge_gamemode, true);
	challenge_gamemode_string_len = strlen(challenge_gamemode_string);	
	
	for(line = fgets(file); line && !buf_list_challenges && line != "GAMEPROGRESS"; line = fgets(file))
	{
		if(line == "ACHIEVEMENTS")
		{
			for(line = fgets(file); line && line != "GAMEPROGRESS"; line = fgets(file))
			{
				tokenizebyseparator(line, SEP_SPACE);
				if(argv(0) == challenge_gamemode_string)
				{
					line = substring(line, challenge_gamemode_string_len+1, strlen(line) - challenge_gamemode_string_len - 1);
					GenerateChallenges(line, true, false);
					break;
				}
			}
		}
	}
	
	fclose(file);
	
	SetCurrentMenu(Draw_PlayerChallengesForGameMode);
	currentmenu.CloseMenuFunc = Close_PlayerChallengesForGameMode;
	currentmenu.bodystring = GetGameMode_String(challenge_gamemode, false);
}

void Call_PlayerChallenges_Campaign() =	{	Call_PlayerChallengesForGameMode(GAMEMODE_CAMPAIGN);	}
void Call_PlayerChallenges_Deathmatch() =	{	Call_PlayerChallengesForGameMode(GAMEMODE_DEATHMATCH);	}
void Call_PlayerChallenges_CTF() =		{	Call_PlayerChallengesForGameMode(GAMEMODE_CTF);	}

void Draw_PlayerChallenges() =
{
	local float minepisode;

	Menu_Start_ESCMenu("CHALLENGES", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);

	local string str_capturetheflag, str_gamemodes, str_campaign, str_deathmatch;
	str_capturetheflag	= Translate("Capture the Flag");
	str_gamemodes		= Translate("GAME MODES");
	str_campaign		= Translate("Campaign");
	str_deathmatch		= Translate("Deathmatch");
	
	skiptranslation = true;
	
	DrawElement_OptionTitle(str_gamemodes);		

	Menu_Option_Text(str_campaign, Call_PlayerChallenges_Campaign);	

	#ifdef COMPILE_GAMEPLAYOPTIONS_SINGLEPLAYER
		OPTION_EPISODE_MIN = 999;
	#endif
	
	Menu_Option_Text(str_deathmatch, Call_PlayerChallenges_Deathmatch);
	Menu_Option_Text(str_capturetheflag, Call_PlayerChallenges_CTF);
	OPTION_EPISODE_MIN = false;

	skiptranslation = false;
	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_BASIC);	
	EndBottomButtons();
	
	Menu_End();
}

vector HueToRGB(float clr) =
{
	local vector rgb;
	local float gspan;

	gspan = 255/6;

	if(clr <= 1*gspan)
	{
		rgb_x = gspan;
		rgb_y = clr;
	}
	else	
	if(clr > 1*gspan && clr <= 2*gspan)
	{
		rgb_x = gspan - (clr - 1*gspan);
		rgb_y = gspan;
	}
	else
	if(clr > 2*gspan && clr <= 3*gspan)
	{
		rgb_y = gspan;
		rgb_z = clr-2*gspan;
	}
	else
	if(clr > 3*gspan && clr <= 4*gspan)
	{
		rgb_y = gspan - (clr-3*gspan);
		rgb_z = gspan;
	}
	else
	if(clr > 4*gspan && clr <= 5*gspan)
	{
		rgb_x = clr-4*gspan;
		rgb_z = gspan;
	}
	else
	if(clr > 5*gspan && clr <= 6*gspan)
	{
		rgb_x = gspan;
		rgb_z = gspan - (clr-5*gspan);
	}
	
	rgb = rgb*(1/gspan);
	
	return rgb;
}

void ApplyPlayerColor() =
{
	local string s;
	local vector rgb;
	
	rgb = HueToRGB(colorselection_hue);
	rgb = rgb*colorselection_value;
	rgb = rgb+('1 1 1'-rgb)*colorselection_saturation;	
	
	playercolor_hue = colorselection_hue;
	playercolor_value = colorselection_value;
	playercolor_saturation = colorselection_saturation;
	player_colors = rgb;

	SaveProfile(PROFILE_FILEVERSION_CURRENT);
	CloseMenu();
	
	if(clientstate() == CS_CONNECTED)
	{
		s = strcat("cmd playercolors ", ftos(player_colors_x));
		s = strcat(s, " ");
		s = strcat(s, ftos(player_colors_y));
		s = strcat(s, " ");
		s = strcat(s, ftos(player_colors_z));	
		s = strcat(s, "\n");
		localcmd(s);
	}
}

void ApplyReticleColor() =
{
	local string s;
	local vector rgb;
	
	rgb = HueToRGB(colorselection_hue);
	rgb = rgb*colorselection_value;
	rgb = rgb+('1 1 1'-rgb)*colorselection_saturation;
	
	reticlecolor_hue = colorselection_hue;
	reticlecolor_value = colorselection_value;
	reticlecolor_saturation = colorselection_saturation;	
	
	s = strcat(ftos(rgb_x), " ");
	s = strcat(s, ftos(rgb_y));
	s = strcat(s, " ");
	s = strcat(s, ftos(rgb_z));	
	
	cvar_set("cl_reticles_color", s);
	SaveProfileConfig();
	CloseMenu();
}

void DrawElement_ColorBox_Hue(float color_hue, float color_value, float color_saturation) =
{
	local float clr, count, total_colors, darkness, brightness, pallettewidth, colorincrementsize, numincrements;
	local vector rgb, fullrgb, ofs, colorsize, sliderimgsize, sliderhandleimgsize;

	sliderimgsize = drawgetimagesize(option_sliderimage);	
	sliderhandleimgsize = drawgetimagesize(option_sliderhandleimage);
	
	total_colors = 255;
	
	pallettewidth = sliderimgsize_x-sliderhandleimgsize_x;
	
	colorsize_x = 3;
	colorsize_y = 10;

	numincrements = pallettewidth/colorsize_x;	
	colorincrementsize = total_colors/numincrements;
	
	for(count = 0; count < numincrements; count++)
	{
		clr = count*colorincrementsize;
		ofs = '0 0 0';
		ofs_x = option_sliderspacing+sliderhandleimgsize_x*0.5;
		ofs_x += count*colorsize_x;
		
		rgb = HueToRGB(clr);
		rgb = rgb*color_value;
		rgb = rgb+('1 1 1'-rgb)*color_saturation;
		
		drawfill(option_pos+ofs, colorsize, rgb, 1, 0);
	}
}

void DrawElement_ColorBox_Value(float color_hue, float color_saturation) =
{
	local float clr, count, total_colors, darkness, brightness, pallettewidth, colorincrementsize, numincrements;
	local vector rgb, fullrgb, ofs, colorsize, sliderimgsize, sliderhandleimgsize;

	sliderimgsize = drawgetimagesize(option_sliderimage);	
	sliderhandleimgsize = drawgetimagesize(option_sliderhandleimage);
	
	total_colors = 255;
	
	pallettewidth = sliderimgsize_x-sliderhandleimgsize_x;
	
	colorsize_x = 3;
	colorsize_y = 10;

	numincrements = pallettewidth/colorsize_x;	
	colorincrementsize = total_colors/numincrements;
	
	for(count = 0; count < numincrements; count++)
	{
		clr = count*colorincrementsize;
		ofs = '0 0 0';
		ofs_x = option_sliderspacing+sliderhandleimgsize_x*0.5;
		ofs_x += count*colorsize_x;	

		rgb = HueToRGB(color_hue);
		rgb = rgb*(clr/total_colors);
		rgb = rgb+('1 1 1'-rgb)*color_saturation;
	
		drawfill(option_pos+ofs, colorsize, rgb, 1, 0);
	}
	
//	option_pos_y += colorsize_y+option_spacing;	
}

void DrawElement_ColorBox_Saturation(float color_hue, float color_value) =
{
	local float clr, count, total_colors, darkness, brightness, pallettewidth, colorincrementsize, numincrements;
	local vector rgb, fullrgb, ofs, colorsize, sliderimgsize, sliderhandleimgsize;

	sliderimgsize = drawgetimagesize(option_sliderimage);	
	sliderhandleimgsize = drawgetimagesize(option_sliderhandleimage);
	
	total_colors = 255;
	
	pallettewidth = sliderimgsize_x-sliderhandleimgsize_x;
	
	colorsize_x = 3;
	colorsize_y = 10;

	numincrements = pallettewidth/colorsize_x;	
	colorincrementsize = total_colors/numincrements;
	
	for(count = 0; count < numincrements; count++)
	{
		clr = count*colorincrementsize;
		ofs = '0 0 0';
		ofs_x = option_sliderspacing+sliderhandleimgsize_x*0.5;
		ofs_x += count*colorsize_x;

		rgb = HueToRGB(color_hue);
		rgb = rgb*color_value;
		rgb = rgb+('1 1 1'-rgb)*(clr/total_colors);
		
		drawfill(option_pos+ofs, colorsize, rgb, 1, 0);
	}
	
//	option_pos_y += colorsize_y+option_spacing;	
}

void Draw_PlayerColorMenu() =
{
	local vector rgb, ofs;
	local float extraoptionspace, optionadjustspace, windowwidth;
	
	Menu_Start_ESCMenu("PLAYER COLOR", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	option_size_x = 168;
	option_textalignment = '-1 0 0';
	extraoptionspace = 8;
	optionadjustspace = 2;
	
	rgb = HueToRGB(colorselection_hue);
	rgb = rgb*colorselection_value;
	rgb = rgb+('1 1 1'-rgb)*colorselection_saturation;
	
	windowwidth = active_menu.menusize_x - border_size_x*2 - body_margin_x*2;
	ofs_x = windowwidth*0.5 - 80*0.5;
	
//	drawfill(option_pos+ofs, '80 80 0', rgb, 1, 0);
	drawpic(option_pos+ofs, "gfx/menu/icon_player_color_picker.tga", '80 80 0', rgb, 1, 0);
	option_pos_y += 96;
	
	TempMenuSetting_option_size_height(32);
	TempMenuSetting_option_fontsize('14 12 0');
	option_slider_alignment = '0 -1 0';

	option_size_selectionbox = option_size;	
	option_size_selectionbox_x = 407;	
	
	DrawElement_ColorBox_Hue(colorselection_hue, colorselection_value, colorselection_saturation);
	option_pos_y -= optionadjustspace;
	Menu_Slider_Text("Hue", colorselection_hue, "", 0, 255, 256, 3);	
	colorselection_hue = GetSliderValue();
	option_pos_y += extraoptionspace;
	
	DrawElement_ColorBox_Value(colorselection_hue, colorselection_saturation);
	option_pos_y -= optionadjustspace;	
	Menu_Slider_Text("Value", colorselection_value, "", 0.10, 1, 91, 4);	
	colorselection_value = GetSliderValue();
	option_pos_y += extraoptionspace;
	
	DrawElement_ColorBox_Saturation(colorselection_hue, colorselection_value);	
	option_pos_y -= optionadjustspace;	
	Menu_Slider_Text("Saturation", colorselection_saturation, "", 0, 1, 101, 4);	
	colorselection_saturation = GetSliderValue();
	option_pos_y += extraoptionspace;
	
	option_size_selectionbox = '0 0 0';	
	
	RestoreMenuSetting_option_size_height();
	RestoreMenuSetting_option_fontsize();
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Accept", ApplyPlayerColor, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();	
	
	Menu_End();
}

void Draw_ReticleColorMenu() =
{
	local vector rgb, ofs;
	local float extraoptionspace, optionadjustspace, windowwidth;

	Menu_Start_ESCMenu("RETICLE COLOR", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	option_size_x = 168;
	option_textalignment = '-1 0 0';
	extraoptionspace = 8;
	optionadjustspace = 2;
	
	rgb = HueToRGB(colorselection_hue);
	rgb = rgb*colorselection_value;
	rgb = rgb+('1 1 1'-rgb)*colorselection_saturation;
	
	windowwidth = active_menu.menusize_x - border_size_x*2 - body_margin_x*2;
	ofs_x = windowwidth*0.5 - 80*0.5;
	
	drawfill(option_pos+ofs, '80 80 0', rgb, 1, 0);
	option_pos_y += 96;
	
	TempMenuSetting_option_size_height(32);
	TempMenuSetting_option_fontsize('14 12 0');
	option_slider_alignment = '0 -1 0';

	option_size_selectionbox = option_size;	
	option_size_selectionbox_x = 407;	
	
	DrawElement_ColorBox_Hue(colorselection_hue, colorselection_value, colorselection_saturation);
	option_pos_y -= optionadjustspace;
	Menu_Slider_Text("Hue", colorselection_hue, "", 0, 255, 256, 3);	
	colorselection_hue = GetSliderValue();
	option_pos_y += extraoptionspace;
	
	DrawElement_ColorBox_Value(colorselection_hue, colorselection_saturation);
	option_pos_y -= optionadjustspace;	
	Menu_Slider_Text("Value", colorselection_value, "", 0, 1, 101, 4);	
	colorselection_value = GetSliderValue();
	option_pos_y += extraoptionspace;
	
	DrawElement_ColorBox_Saturation(colorselection_hue, colorselection_value);	
	option_pos_y -= optionadjustspace;	
	Menu_Slider_Text("Saturation", colorselection_saturation, "", 0, 1, 101, 4);	
	colorselection_saturation = GetSliderValue();
	option_pos_y += extraoptionspace;
	
	option_size_selectionbox = '0 0 0';	
	
	RestoreMenuSetting_option_size_height();
	RestoreMenuSetting_option_fontsize();
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Accept", ApplyReticleColor, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();	
	
	Menu_End();
}

void Call_PlayerColorMenu() =
{
	colorselection_hue = playercolor_hue;
	colorselection_value = playercolor_value;
	colorselection_saturation = playercolor_saturation;
	SetCurrentMenu(Draw_PlayerColorMenu);
}

void Call_ReticleColorMenu() =
{
	colorselection_hue = reticlecolor_hue;
	colorselection_value = reticlecolor_value;
	colorselection_saturation = reticlecolor_saturation;
	SetCurrentMenu(Draw_ReticleColorMenu);
}

void CloseProfileOptions() =
{
	SaveProfileConfig();
}

void Roll_ReticlesMode() =	{	cvar_set("cl_reticles", ftos(Roll_Controls(cvar("cl_reticles"), 3)));	}

void ToggleColorCodedReticles() =	{	cvar_set("cl_reticles_colorcoded", ftos(!cvar("cl_reticles_colorcoded")));	}

void Draw_ReticleOptions() =
{
	local string s;
	local float cl_reticles;
	local vector colorboxofs, colorboxsize;
	
	colorboxofs_x = option_sliderspacing;
	colorboxofs_y = 0;
	colorboxsize_x = colorboxsize_y = option_size_y;
	
	cl_reticles = cvar("cl_reticles");

	Menu_Start_ESCMenu("RETICLE OPTIONS", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	
	local string str_off, str_single, str_all, str_transparency, str_customcolor, str_color, str_draw, str_back, str_transparent, str_opaque;
	str_off				= Translate("Off");
	str_single			= Translate("Single");
	str_all				= Translate("All");
	str_transparency	= Translate("Transparency");
	str_customcolor		= Translate("Custom Color");
	str_color			= Translate("Color");
	str_draw			= Translate("Draw");
	str_back			= Translate("Back");
	str_transparent		= Translate("transparent");
	str_opaque			= Translate("opaque");

	skiptranslation = true;
	
	option_size_x = 168;
	
	Menu_Option_Text(str_draw, Roll_ReticlesMode);
	
	if(cl_reticles == 0)
		s = str_off;
	else
	if(cl_reticles == 1)
		s = str_single;	
	else
	if(cl_reticles == 2)
		s = str_all;
	option_pos = GetLastLinePos();	
	option_pos_x += option_sliderspacing;
	Menu_AlignedText(s, ALIGN_LEFT);
	option_pos_x -= option_sliderspacing;	
	BR();	
	
	option_size_selectionbox = option_size;		
	
	if(cl_reticles)
	{
		option_size_selectionbox_x = 407;		
		Menu_Slider_Text(str_transparency, 0, "cl_reticles_alpha", 0, 1, 101, 4);
		DrawElement_SliderMinMaxLabels(str_transparent, str_opaque);		
	
		option_size_selectionbox_x = option_sliderspacing+36;
		Menu_Option_Text(str_customcolor, ToggleColorCodedReticles);
		option_pos = GetLastLinePos();
		DrawElement_CheckBox(option_pos, option_sliderspacing, !cvar("cl_reticles_colorcoded"));
		option_size_selectionbox_x = option_size_x;	
		BR();
		
		if(!cvar("cl_reticles_colorcoded"))
		{
			drawfill(option_pos+colorboxofs, colorboxsize, stov(cvar_string("cl_reticles_color")), 1, 0);
			Menu_Option_Text(str_color, Call_ReticleColorMenu);
		}
		else
			BR();
	}

	option_size_selectionbox = '0 0 0';
	
	BeginBottomButtons(1);
	DrawElement_BottomButton(str_back, CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();

	skiptranslation = false;
	
	Menu_End();
}

void UpdateLockedCameraStatus() =
{
	if(clientstate() == CS_CONNECTED)
		localcmd(strcat("cmd lockcamera ", ftos(cvar("chase_lockyaw")), "\n"));
}

//void ToggleFPSCamera() =	{	cvar_set("chase_fpscam", ftos(!cvar("chase_fpscam")));	}

void ToggleFPSCamera_LowQual() =	{	cvar_set("chase_fpscam_lowqual", ftos(!cvar("chase_fpscam_lowqual")));	}


void ToggleLockCameraYaw() =
{
	cvar_set("chase_lockyaw", ftos(!cvar("chase_lockyaw")));
//	UpdateLockedCameraStatus();
}

void SetCameraSettings_Default() =
{
	cvar_set("chase_cameraspeed", "1");
	cvar_set("chase_yawspeed", "1");
	cvar_set("chase_pitchangle", "90");
	cvar_set("chase_back", "-500");
	cvar_set("chase_lockyaw", "0");	
//	UpdateLockedCameraStatus();
}

void SetCameraSettings_Cinematic() =
{
	cvar_set("chase_cameraspeed", "0.05");
	cvar_set("chase_yawspeed", "0.5");
	cvar_set("chase_pitchangle", "90");
	cvar_set("chase_back", "-500");
	cvar_set("chase_lockyaw", "0");	
//	UpdateLockedCameraStatus();
}

void SetCameraSettings_Perspective() =
{
	cvar_set("chase_cameraspeed", "1");
	cvar_set("chase_yawspeed", "1");
	cvar_set("chase_pitchangle", "75");
	cvar_set("chase_back", "0");
	cvar_set("chase_lockyaw", "0");	
//	UpdateLockedCameraStatus();
}

void SetCameraSettings_Oldschool() =
{
	cvar_set("chase_cameraspeed", "0.5");
	cvar_set("chase_yawspeed", "1");
	cvar_set("chase_pitchangle", "90");
	cvar_set("chase_back", "-250");
	cvar_set("chase_lockyaw", "1");	
//	UpdateLockedCameraStatus();
}

void SliderRules_ChasePitchAngle() =
{
	local float viewpitch, chase_back, chase_back_min;

	viewpitch = GetSliderValue();

	chase_back_min = -500 + ((90-viewpitch)/15)*500;
	chase_back = cvar("chase_back");	
	chase_back = ceil(bound(chase_back_min, chase_back, 0));
	cvar_set("chase_back", ftos(chase_back));
}

void SliderRules_ChaseBack() =
{
	local float viewpitch, chase_back, viewpitch_min;

	chase_back = GetSliderValue();

	viewpitch_min = 75 + ((0-chase_back)/500)*15;
	viewpitch = cvar("chase_pitchangle");	
	viewpitch = ceil(bound(viewpitch_min, viewpitch, 90));
	cvar_set("chase_pitchangle", ftos(viewpitch));
}

void Draw_PlayerCameraOptions() =
{
	local string s;
	local float cl_reticles, predefbuttonsize, UNLOCKED;
	local vector colorboxofs, colorboxsize;
	
	Menu_Start_ESCMenu("CAMERA OPTIONS", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	option_size_x = 168;	
	predefbuttonsize = 205;
	
	DrawElement_OptionTitle("PREDEFINED SETTINGS");
	HorizontalListButton(0, predefbuttonsize, "Top-Down", SetCameraSettings_Default, 0, 3, 2, 0, MBT_BASIC);	
	HorizontalListButton(predefbuttonsize+option_spacing, predefbuttonsize, "Cinematic", SetCameraSettings_Cinematic, 0, 4, 0, 1, MBT_BASIC);
	BR();
	HorizontalListButton(0, predefbuttonsize, "Perspective", SetCameraSettings_Perspective, 1, 5, 4, 0, MBT_BASIC);
	HorizontalListButton(predefbuttonsize+option_spacing, predefbuttonsize, "Oldschool", SetCameraSettings_Oldschool, 2, 0, 0, 3, MBT_BASIC);
	BR();BR();
	
	DrawElement_OptionTitle("CUSTOM OPTIONS");		

	OPTION_EPISODE_MIN = 2;
	
	option_size_selectionbox = option_size;
	option_size_selectionbox_x = option_sliderspacing+36;
	Menu_Option_Text("Low Quality Camera", ToggleFPSCamera_LowQual);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("chase_fpscam_lowqual"));
	option_pos_x += option_size_selectionbox_x + 16;
	Menu_Text("(Shorter viewing distance)");
	option_pos_x -= option_size_selectionbox_x + 16;
	BR();		
	
	OPTION_EPISODE_MIN = false;
	
	optionalt_up = 3;
	option_size_selectionbox = option_size;
	option_size_selectionbox_x = 407;		
	Menu_Slider_Text("Center Speed", 0, "chase_cameraspeed", 0, 1, 21, 4);
	DrawElement_SliderMinMaxLabels("slow", "fast");
	
	Menu_Slider_Text("Turn Speed", 0, "chase_yawspeed", 0, 1, 21, 4);
	DrawElement_SliderMinMaxLabels("slow", "fast");	
	
//	Menu_Slider_Text("Boundary Size", 0, "chase_boundary", 0, 1, 21, 4);
//	DrawElement_SliderMinMaxLabels("slow", "fast");	

	SliderRules = SliderRules_ChasePitchAngle;
	Menu_Slider_Text("Pitch", 0, "chase_pitchangle", 75, 90, 16, 2);
	DrawElement_SliderMinMaxLabels("tilted", "perpendicular");		
	SliderRules = SUB_Null;
	
	SliderRules = SliderRules_ChaseBack;
	Menu_Slider_Text("Position", 0, "chase_back", 0, -500, 501, -3);
	DrawElement_SliderMinMaxLabels("center", "forward");	
	SliderRules = SUB_Null;
	
	option_size_selectionbox_x = option_sliderspacing+36;
	Menu_Option_Text("Lock Camera Angle", ToggleLockCameraYaw);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("chase_lockyaw"));
	option_size_selectionbox_x = option_size_x;	

	option_size_selectionbox = '0 0 0';
	
//	OPTION_EPISODE_MIN = false;	
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();
	
	Menu_End();
}

void ToggleShowObjectives() =	{	cvar_set("cl_hud_showobjectives", ftos(!cvar("cl_hud_showobjectives")));	}

void Draw_HUDOptions() =
{
	Menu_Start_ESCMenu("HUD OPTIONS", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	option_size_x = 168;
	
	option_size_selectionbox = option_size;
	option_size_selectionbox_x = option_sliderspacing+36;

	Menu_Option_Text("Show Objectives", ToggleShowObjectives);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("cl_hud_showobjectives"));
	BR();


	option_size_selectionbox = '0 0 0';
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();
	
	Menu_End();
}

void SetDifficultyMode_Arcade() =	{	cvar_set("profileskill", "0");	}
void SetDifficultyMode_Classic() =	{	cvar_set("profileskill", "1");	}

void Draw_DifficultyOptions() =
{
	local vector option_pos_start;
	
	Menu_Start_ESCMenu("DIFFICULTY OPTIONS", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	option_size_x = 168;
	option_pos_start = option_pos;
	
	option_size_selectionbox = option_size;
	option_size_selectionbox_x = option_sliderspacing+36;
	
	Menu_Option_Text("Arcade", SetDifficultyMode_Arcade);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, !cvar("profileskill"));
	option_pos_x += 110;
	Menu_Text("(EASY)");
	option_pos_x = option_pos_start_x;
	BR();
	
	Menu_Option_Text("Classic", SetDifficultyMode_Classic);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("profileskill"));	
	option_pos_x += 110;
	Menu_Text("(HARD)");
	option_pos_x = option_pos_start_x;
	
	option_size_selectionbox = '0 0 0';	
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();
	
	Menu_End();
}

#ifdef COMPILE_SERVICE_ONLIVE
	void Draw_SoundOptions();
#endif

void Draw_ProfileOptions() =
{
	local string s;
	local float cl_reticles, drawprofilebutton;
	local vector colorboxofs, colorboxsize;
	
	colorboxofs_x = option_sliderspacing;
	colorboxofs_y = 0;
	colorboxsize_x = colorboxsize_y = option_size_y;
	
	cl_reticles = cvar("cl_reticles");

	#ifdef COMPILE_SERVICE_ONLIVE
		Menu_Start_ESCMenu("SETTINGS", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	#else
		Menu_Start_ESCMenu("PROFILE", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	#endif
	
	local string str_difficulty, str_profiles, str_back;
	
	option_size_x = 168;
	
	#ifdef COMPILE_SERVICE_ONLIVE
		SkipTranslations(3);
	#else
		DrawElement_OptionTitle("PLAYER STATS");
		Menu_CallSubMenu_Text("Challenges", Draw_PlayerChallenges);	
		BR();
		DrawElement_OptionTitle("PLAYER SETTINGS");		
	#endif
		
//	drawfill(option_pos+colorboxofs, colorboxsize, player_colors, 1, 0);
	drawpic(option_pos+colorboxofs, "gfx/menu/icon_player_color_picker.tga", colorboxsize, player_colors, 1, 0);
	Menu_Option_Text("Player Color", Call_PlayerColorMenu);
	
	Menu_CallSubMenu_Text("Camera Options", Draw_PlayerCameraOptions);

	Menu_CallSubMenu_Text("Reticle Options", Draw_ReticleOptions);
	
	Menu_CallSubMenu_Text("HUD Options", Draw_HUDOptions);
	
	str_difficulty	= Translate("Difficulty");

	skiptranslation = true;
	
	if(clientstate() != CS_CONNECTED)	
		Menu_CallSubMenu_Text(str_difficulty, Draw_DifficultyOptions);	
	
	skiptranslation = false;
	
	str_profiles	= Translate("Profiles");
	str_back		= Translate("Back");
	
	#ifdef COMPILE_SERVICE_ONLIVE
		Menu_CallSubMenu_Text("Sound Options", Draw_SoundOptions);
	#else
		if(clientstate() != CS_CONNECTED)
			drawprofilebutton = true;
	#endif

	skiptranslation = true;	
	BeginBottomButtons(1+drawprofilebutton);
	if(drawprofilebutton)
		DrawElement_BottomButton(str_profiles, BackToProfileMenu, 0, 0, 0, 0, MBT_BASIC);
	DrawElement_BottomButton(str_back, CloseMenu, 0, 0, 0, 0, MBT_CANCEL);
	EndBottomButtons();	
		
	Menu_End();
}

void Call_ProfileOptions() =
{
	if(!profile_active)
	{
		Call_ProfileMenu();
		return;
	}

	CloseMenuBranch(menu_count-2);
//	currentmenu.user_current_selection = 3 + missioneditorenabled;	
	SetCurrentMenu(Draw_ProfileOptions);
	currentmenu.CloseMenuFunc = CloseProfileOptions;
}

void Draw_ProfileUpdated() =
{
	local string s;

	#ifdef COMPILE_SERVICE_ONLIVE
		Menu_Start_ConfirmationMenu("Config Updated", '300 0 0', __FUNC__);
		s = Translate("Your config files have been updated. You may need to rebind your keys, or reconfigure your gamepad settings in the Controls menu if you have any issues.");	
	#else
		Menu_Start_ConfirmationMenu("Profile Updated", '300 0 0', __FUNC__);
		s = Translate("Your profile has been updated. You may need to rebind your keys, or reconfigure your gamepad settings in the Controls menu if you have any issues.");
	#endif
	
	active_menu.buf_textblock = DrawTextBlock(active_menu.buf_textblock, option_pos, -1, '320 100 0', s, body_fontsize, body_fontcolor, body_fontalpha, body_fontflags);	
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Close", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();	
}

float PUF_CONTROLS	= 1;

void UpdateProfileRevision() =
{
	local string path, filename, s;
	local float count, buf, searchhandle, numfiles, buffersize, rev, rev_p, rev_f;
	
	tokenizebyseparator(REVISION, "v", ".");
	rev = stof(argv(3));	
	rev_p = cvar("ssrevision");
	
	if(rev <= rev_p)
		return;
	
	searchhandle = search_begin("default_*.cfg", TRUE, TRUE);
	
	if(searchhandle == -1)
		return;

	buf = CreateBuffer();
	numfiles = search_getsize(searchhandle);	
	for(count = 0; count < numfiles; count++)
	{
		filename = search_getfilename(searchhandle, count);
		rev_f = stof(substring(filename, 8, strlen(filename)-12));

		if(rev_p < rev_f)
			AddBufferString(buf, filename, 0);
	}		
	
	search_end(searchhandle);		
	SortBuffer(buf, 99, FALSE);

	s = string_null;
	buffersize = GetBufferSize(buf);
	for(count = 0; count < buffersize; count++)
		s = strcat(s, "exec ", GetBufferString(buf, count), ";");

	if(!rev_p)
		s = strcat(s, "profile_updateflag_controls 0;");
		
	s = strcat(s, "ssrevision ", ftos(rev), ";menu_cmd callupdatemenus\n");
	localcmd(s);
	
	DeleteBuffer(buf);
}

void LoadProfile() =
{
	local string s, t, filename, line;
	local float file, count, rev, fileversion;
	
	unlocked_fpscamera = false;
	
	filename = strcat("profiles/_", uri_escape(profile_active));
	filename = strcat(filename, ".profile");	
	
	file = FileOpen(filename, FILE_READ);
	
	for(line = fgets(file); line; line = fgets(file))
	{
		tokenizebyseparator(line, SEP_SPACE);
		
		if(argv(0) == "VERSION")
			fileversion = stof(argv(1));		
		
		if(argv(0) == "COLORS")
		{
			player_colors_x = stof(argv(1));
			player_colors_y = stof(argv(2));
			player_colors_z = stof(argv(3));
			playercolor_hue = stof(argv(4));
			playercolor_value = stof(argv(5));
			playercolor_saturation = stof(argv(6));
		}
		
		if(argv(0) == "RETICLE")
		{
			reticlecolor_hue = stof(argv(1));
			reticlecolor_value = stof(argv(2));
			reticlecolor_saturation = stof(argv(3));
		}
		
		if(argv(0) == "ACHIEVEMENTS")
		{
			for(line = fgets(file); line && line != "GAMEPROGRESS"; line = fgets(file))
			{
				tokenize(line);
			
				if(argv(0) == "unlocked")
				for(count = 1; argv(count); count++)
				{
					t = argv(count);
					switch(t)
					{
						case "FPSCAM":		unlocked_fpscamera = true;		break;
					}
				}
			}

			if(line == "GAMEPROGRESS")
				break;
		}
		
		if(argv(0) == "GAMEPROGRESS")
			break;
	}

	fclose(file);
	
	// CONVERT OLD PROFILES
	if(fileversion < 1.1)	// Convert save progress for Burning Retribution campaign name change.
		SaveProfile(1.1);	
	
	#ifdef COMPILE_SERVICE_ONLIVE
		UpdateProfileRevision();
	#else
		PreserveSystemSettings();
		
		//reset unlockables
	//	cvar_set("chase_fpscam", "0");
		
		filename = strcat("data/profiles/_", uri_escape(profile_active));
		filename = strcat(filename, ".cfg");
		
		tokenizebyseparator(REVISION, "v", ".");
		rev = stof(argv(3));		
		
		file = FileOpen(filename, FILE_READ);
		if(file == -1)
		{
			s = strcat("unbindall;cvar_resettodefaults_saveonly;exec default.cfg;ssrevision ", ftos(rev));
			s = strcat(s, ";saveconfig data/profiles/_", strtolower(uri_escape(profile_active)));
			s = strcat(s, ".cfg;menu_cmd restoresystem\n");
		}
		else
		{
			fclose(file);
			s = strcat("unbindall;cvar_resettodefaults_saveonly;exec data/profiles/_", strtolower(uri_escape(profile_active)));
			s = strcat(s, ".cfg;menu_cmd restoresystem\n");
		}
		
		localcmd(s);
	#endif
}

void LoadProfileFromList() =
{
	#ifdef COMPILE_SERVICE_ONLIVE
		profile_active = zonecpy(profile_active, "player");
	#else
		tokenizebyseparator(active_menu.listitemstring, SEP_QUOTE);
		profile_active = zonecpy(profile_active, argv(0));
	#endif
	
	SetName();	
	LoadProfile();
	
	#ifndef COMPILE_SERVICE_ONLIVE
		menu_main.user_current_selection = 4;
		Call_ProfileOptions();
	#endif		
}

/*void Draw_CreateProfileError_ProfileExists() =
{
	Menu_Start_ConfirmationMenu("", '300 0 0');
	Menu_Text("That profile exists.");

	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();
}*/

void SetDefaultDifficultyMode_Arcade() =
{
	SetDifficultyMode_Arcade();
	CloseMenu();
}

void SetDefaultDifficultyMode_Classic() =
{
	SetDifficultyMode_Classic();
	CloseMenu();
}

void Draw_ChooseDefaultDifficulty() =
{
	local string s;

	Menu_Start_ConfirmationMenu("Choose Your Skill", '320 0 0', __FUNC__);

	s = Translate("In Arcade mode enemies have less health, but score is also decreased.;;(Note: You can change this setting later.)");
	
	active_menu.buf_textblock = DrawTextBlock(active_menu.buf_textblock, option_pos, -1, '320 100 0', s, body_fontsize, body_fontcolor, body_fontalpha, body_fontflags);	
	
	option_pos_y += 10;
	
	Menu_Option_Text("Arcade (EASY)", SetDefaultDifficultyMode_Arcade);
	Menu_Option_Text("Classic (HARD)", SetDefaultDifficultyMode_Classic);
	
	Menu_End();
}

void Call_ChooseDefaultDifficulty() =
{
	SetCurrentMenu(Draw_ChooseDefaultDifficulty);
	currentmenu.ESCFunc = ESCFunc_Ignore;
}

void CreateProfile() =
{
	local float file;
	local string filename, s, profilename;
	
	#ifdef COMPILE_SERVICE_ONLIVE
		profilename = "player";
	#else
		profilename = GetBufferString(active_menu.buf_list, 0);
		
		if(AllSpaces(profilename))
		{
			currentmenu.bodystring = "INVALIDNAME";
			return;
		}
	#endif
	
	filename = strcat("profiles/_", uri_escape(profilename));
	filename = strcat(filename, ".profile");

	file = FileOpen(filename, FILE_READ);
	if(file == -1)
	{
		file = FileOpen(filename, FILE_WRITE);
		s = strcat("VERSION ", ftos(PROFILE_FILEVERSION_CURRENT));
		NewFileLine(file, s);
		NewFileLine(file, AppendToken("NAME", SEP_SPACE, profilename));
		NewFileLine(file, "COLORS 1 1 1 0 1 1"); // DEFAULT COLOR VALUES
		NewFileLine(file, "RETICLE 0 1 1"); // DEFAULT COLOR VALUES
		fclose(file);
		
		active_menu.listitemstring = profilename;
		LoadProfileFromList();
		
		#ifndef COMPILE_SERVICE_ONLIVE
			Call_ChooseDefaultDifficulty();
		#endif
		
	//	Call_ProfileOptions();
	}
	else
	{
		fclose(file);
		
		#ifndef COMPILE_SERVICE_ONLIVE
			currentmenu.bodystring = "PROFILEEXISTS";
		#endif
	}
}

void Draw_CreateNewProfileMenu() =
{
	local vector input_size;
	local string s;

	Menu_Start_ConfirmationMenu("New Profile", '300 0 0', __FUNC__);

	Menu_InputWarnings();
	
	s = Translate("Name:");
	skiptranslation = true;
	Menu_AlignedText(s, ALIGN_LEFT);
	input_size_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - stringwidth(s, false, body_fontsize) - body_fontsize_x;
	Menu_Input_All(input_size, string_null, ALIGN_RIGHT, 0, CreateProfile);
	
	skiptranslation = false;
	BeginBottomButtons(2);
	DrawElement_BottomButton("Create", CreateProfile, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();	
}

void Call_CreateNewProfileMenu() =
{
	SetCurrentMenu(Draw_CreateNewProfileMenu);
	active_input = 1;
}

void ListOption_Profile(float count) =
{
	local string profile_name;
	
	active_menu.listitemstring = GetBufferString(active_menu.buf_list, count);
	tokenizebyseparator(active_menu.listitemstring, SEP_QUOTE);
	profile_name = argv(0);
	Menu_Option_Text(profile_name, LoadProfileFromList);
}

void Draw_ProfileMenu() =
{
	local float numprofiles, numlistoptions, count, windowwidth, bottombuttons;
	
	Menu_Start_ESCMenu("PROFILES", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);

	local string str_back;
	
	windowwidth = WINDOWSIZE_RIGHTPANE_x;//active_menu.menusize_x - border_size_x*2 - body_margin_x*2;
	
	local string str_noprofiles;
	str_noprofiles	= Translate("No existing profiles.");
	
	if(active_menu.bodystring == "NOPROFILES")
	{
		skiptranslation = true;
		BR();
		Menu_Text(str_noprofiles); BR();
		skiptranslation = false;
	}
	else
	{	
		numprofiles = GetBufferSize(active_menu.buf_list);
		numlistoptions = Draw_ScollingList(numprofiles, 10, 0, windowwidth, 10, 10, SUB_Null, ListOption_Profile);
		
/*		for(count = 0; count < numprofiles && active_menu; count++)
		{
			active_menu.listitemstring = GetBufferString(active_menu.buf_list, count);
			Menu_Option_Text(TitleString(GetFilenameFromPath(active_menu.listitemstring, 2)), LoadProfile);
		}	*/				
	}

	BR();
	
	option_textalignment = '0 0 0';		
	
	if(profile_active)
	{
		bottombuttons = 2;
//		button_new_down = 1;
//		button_new_up
//		button_new_left
	}
	else
	{
		bottombuttons = 1;
//		button_new_up = numlistoptions;
//		button_new_left	= numlistoptions;
	}
	
	str_back	= Translate("Back");
	
	BeginBottomButtons(bottombuttons);
	DrawElement_BottomButton("New", Call_CreateNewProfileMenu, numlistoptions, bottombuttons-1, numlistoptions, 0, MBT_BASIC);
	skiptranslation = true;
	if(bottombuttons == 2)
		DrawElement_BottomButton(str_back, Call_ProfileOptions, numlistoptions, 0, 0, 0, MBT_CANCEL);
	EndBottomButtons();
	
//	HorizontalListButton(0, option_size_x, "New Profile", Call_CreateNewProfileMenu, numlistoptions, 1, numlistoptions, 0, MBT_BASIC);
//	HorizontalListButton(option_size_x+option_spacing, option_size_x, "Back", CloseMenu, numlistoptions, 0, 0, 0, MBT_BACK);
	
	Menu_End();
}

void ProfileMenuEscFunc() =
{
	if(profile_active)
		Call_ProfileOptions();
	else
		CloseMenu();
}

void Call_ProfileMenu() =
{	
	local float searchhandle, numfiles, count, file;
	local string filename, profile_name, profile_data, line;
	
	SetCurrentMenu(Draw_ProfileMenu); // drawfunc
	currentmenu.ESCFunc = ProfileMenuEscFunc;
//	currentmenu.CloseMenuFunc = ClearFilenames;
	
	searchhandle = search_begin("data/profiles/*.profile", TRUE, TRUE); // path
	if(searchhandle == -1)
	{
		currentmenu.bodystring = "NOPROFILES"; // none found
		return;
	}
	
	currentmenu.buf_list = CreateBuffer();
	
	numfiles = search_getsize(searchhandle);	
	
	for(count = 0; count < numfiles; count++)
	{
		filename = search_getfilename(searchhandle, count);
		file = FileOpen(filename, FILE_READ);
		for(line = fgets(file); line; line = fgets(file))
		{
			tokenizebyseparator(line, SEP_SPACE);
			if(argv(0) == "NAME")
			{
				profile_name = line;
				profile_name = substring(profile_name, 5, strlen(profile_name)-5);
				break;
			}
		}
		fclose(file);
		profile_data = strcat(profile_name, SEP_QUOTE);
		profile_data = strcat(profile_data, filename);
		
		if(!HasDuplicateStringInList(currentmenu.buf_list, profile_data))
			AddBufferString(currentmenu.buf_list, profile_data, 0);
	}	
	
/*	for(count = 0; count < numfiles; count++)
	{
		profile_name = search_getfilename(searchhandle, count);

		if(gliststring_filenames)
			gliststring_filenames = zonecpy(gliststring_filenames, strcat(gliststring_filenames, SEP_A));	
		gliststring_filenames = zonecpy(gliststring_filenames, strcat(gliststring_filenames, profile_name));		
	
		profile_name = GetFilenameFromPath(profile_name, 2);
		profile_name = TitleString(profile_name);
		
		if(currentmenu.liststring)
			currentmenu.liststring = zonecpy(currentmenu.liststring, strcat(currentmenu.liststring, SEP_A));	
		currentmenu.liststring = zonecpy(currentmenu.liststring, strcat(currentmenu.liststring, profile_name));			
		
		profile_name = "";			
	}*/
	
	search_end(searchhandle);	
	SortBuffer(currentmenu.buf_list, 99, FALSE);
}

void LoadDefaultProfile() =
{
	local string defaultprofile, filename;
	local float file;
	
	defaultprofile = cvar_string("profile");
	
	filename = strcat("profiles/_", uri_escape(defaultprofile));
	filename = strcat(filename, ".profile");
	file = FileOpen(filename, FILE_READ);
	
	if(file != -1)
	{
		fclose(file);
		profile_active = zonecpy(profile_active, defaultprofile);
		SetName();
		LoadProfile();
	}	
	else
	{
		currentmenu.user_current_selection = 1;
	
		#ifdef COMPILE_SERVICE_ONLIVE
			CreateProfile();
		#else
		//	currentmenu.user_current_selection = 1;	
			Call_ProfileMenu();
		#endif	
	}

}