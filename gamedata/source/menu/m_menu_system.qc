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
vector	system_res;

float	system_res_num;
float	system_res_current;

vector	system_consize;
float	system_fullscreen;

float	system_brightness;
//float	system_gamma;
float	system_texturequality;
//float system_anisotropy;
float	system_antialiasing;
float	system_particlequality;

float	system_shadows;
float	system_dlights;
float	system_bloom;
//float	system_motionblur;

float	system_intelgfx;

float	system_vsync;

float	system_gibs;

float	system_volume;
float	system_bgmvolume;
float	system_ambient_level;
float	system_mastervolume;	

vector	system_con_chatrect;

string	system_join_password;
string	system_admin_password;

float	system_language;

void SetSystemResCurrentValue() =
{
	local vector res;

	for(system_res_num = 0; ; system_res_num++)
	{
		res = getresolution(system_res_num);
		if(res_x == system_res_x)
		if(res_y == system_res_y)
			system_res_current = system_res_num;
		
		if(!res_x)
		if(!res_y)
			break;
	}
}

void PreserveSystemSettings() =
{
	system_res_x				= cvar("vid_width");
	system_res_y				= cvar("vid_height");	
	
	SetSystemResCurrentValue();
	
	system_vsync				= cvar("vid_vsync");	
	system_fullscreen			= cvar("vid_fullscreen");
	system_antialiasing			= cvar("vid_samples");
	system_texturequality		= 3 - cvar("gl_picmip");
	
	system_consize_x			= cvar("vid_conwidth");
	system_consize_y			= cvar("vid_conheight");

	system_brightness			= cvar("v_brightness");
//	system_gamma				= cvar("v_gamma");
//	system_anisotropy			= cvar("gl_texture_anisotropy");
	system_particlequality		= cvar("cl_particles_quality");
	if(cvar("r_shadows"))
		system_shadows			= true;
	else
		system_shadows			= false;
	system_dlights				= cvar("r_shadow_realtime_dlight");
	system_bloom				= cvar("r_bloom");
//	system_motionblur			= cvar("r_motionblur");
	system_intelgfx				= !cvar("vid_gl20");
	system_gibs					= cvar("cl_gibs");
	
	system_volume				= cvar("volume");
	system_bgmvolume			= cvar("bgmvolume");
	system_ambient_level		= cvar("ambient_level");
	system_mastervolume			= cvar("mastervolume");	
	
	system_con_chatrect_x		= cvar("con_chatrect_x");
	system_con_chatrect_y		= cvar("con_chatrect_y");

	system_join_password		= zonecpy(system_join_password, cvar_string("sv_join_password"));	
	system_admin_password		= zonecpy(system_admin_password, cvar_string("sv_admin_password"));
	
	system_language				= cvar("localize_language");
}

void RestoreSystemSettings(float applynewsettings) =
{
	cvar_set("vid_width",				ftos(system_res_x));
	cvar_set("vid_height",				ftos(system_res_y));
//	cvar_set("vid_pixelheight",			ftos(system_res_z));	
	cvar_set("vid_vsync",				ftos(system_vsync));			
	cvar_set("vid_fullscreen",			ftos(system_fullscreen));
		
	cvar_set("vid_samples",				ftos(system_antialiasing));		
	cvar_set("gl_picmip",				ftos(3 - system_texturequality));
		
	cvar_set("vid_gl20",				ftos(!system_intelgfx));
	cvar_set("mod_q3bsp_nolightmaps",	ftos(system_intelgfx));
		
	if(!applynewsettings)
	{
		cvar_set("vid_conwidth",			ftos(system_consize_x));
		cvar_set("vid_conheight",			ftos(system_consize_y));

		cvar_set("v_brightness",			ftos(system_brightness));
//		cvar_set("v_gamma",					ftos(system_gamma));

//	cvar_set("gl_texture_anisotropy",	ftos(system_anisotropy));	

		cvar_set("cl_particles_quality",	ftos(system_particlequality));	
		
		cvar_set("r_shadows",							ftos(system_shadows*2));
		cvar_set("r_shadow_realtime_world_shadows",		ftos(system_shadows));
		
		cvar_set("r_shadow_realtime_dlight",			ftos(system_dlights));
		cvar_set("r_shadow_realtime_dlight_shadows",	ftos(system_dlights));
		
		cvar_set("r_bloom",					ftos(system_bloom));
//		cvar_set("r_motionblur",			ftos(system_motionblur));		
		cvar_set("cl_gibs",					ftos(system_gibs));
		
		cvar_set("volume",					ftos(system_volume));
		cvar_set("bgmvolume",				ftos(system_bgmvolume));
		cvar_set("ambient_level",			ftos(system_ambient_level));
		cvar_set("mastervolume",			ftos(system_mastervolume));
		
		cvar_set("con_chatrect_x", 			ftos(system_con_chatrect_x));
		cvar_set("con_chatrect_y", 			ftos(system_con_chatrect_y));
	
		cvar_set("sv_join_password",			system_join_password);
		system_join_password = freezone(system_join_password);	
		cvar_set("sv_admin_password",			system_admin_password);
		system_admin_password = freezone(system_admin_password);
		
		cvar_set("localize_language",		ftos(system_language));
	}
}

void DefaultVideoSettings() =
{
//	system_res										= '800 600 0';
		cvar_set("vid_width",						"800");
		cvar_set("vid_height",						"600");	
//	system_vsync									= false;	
		cvar_set("vid_vsync",						"0");
//	system_fullscreen								= true;
		cvar_set("vid_fullscreen",					"0");
//	system_antialiasing								= 1;
		cvar_set("vid_samples",						"1");		
//	system_texturequality							= 3;
		cvar_set("gl_picmip",						"0");
//	system_intelgfx									= false;
		cvar_set("vid_gl20",						"1");
		cvar_set("mod_q3bsp_nolightmaps",			"0");
	
	
	cvar_set("v_brightness",						"0");
//	cvar_set("v_gamma",								"0"		);
	cvar_set("cl_particles_quality",				"2");	
	
	cvar_set("r_shadows",							"2");
	cvar_set("r_shadow_realtime_world_shadows",		"1");
	
	cvar_set("r_shadow_realtime_dlight",			"0");
	cvar_set("r_shadow_realtime_dlight_shadows",	"0");
	
	cvar_set("r_bloom",								"0");
//	cvar_set("r_motionblur",						"0"		);	
	cvar_set("cl_gibs",								"1");

	PreserveSystemSettings();
}

void DefaultAudioSettings() =
{
	cvar_set("volume",			"1");
	cvar_set("bgmvolume",		"0.3");
	cvar_set("ambient_level",	"0.3");
	cvar_set("mastervolume",	"0.7");
	
	PreserveSystemSettings();
}

/*vector GetResolution(float slot) =
{
	local vector res;
	
	switch(slot)
	{
		case 0:		res = '640 480 0';		break;
		case 1: 	res = '800 600 0';		break;
	//	case 0:		res = '960 600 0';		break;
		case 2: 	res = '1024 768 0';		break;
		case 3:		res = '1152 864 0';		break;
		case 4:		res = '1280 720 0';		break;
		case 5:		res = '1280 768 0';		break;
	//	1280 800
		case 6:		res = '1280 960 0';		break;
		case 7: 	res = '1280 1024 0';	break;
		case 8:		res = '1360 768 0';		break;
		case 9:		res = '1440 900 0';		break;
		case 10:		res = '1600 900 0';		break;
		case 11:	res = '1600 1200 0';	break;
		case 12:	res = '1680 1050 0';	break;
		case 13:	res = '1920 1200 0';		break; 		
		case 14:	res = '1980 1080 0';		break; 
		case 15:	res = '2560 1600 0';		break; 
	//	1920 1200
	//	1920 1440
	//	2048 1536
	}
	
	return res;
}*/

/*void Roll_Resolution() =
{
	local vector res;
	
	res = GetRollValue_vec(vid_res, 13, GetResolution);
	
	cvar_set("vid_width", ftos(res_x));
	cvar_set("vid_height", ftos(res_y));
}*/

void SetConSize(vector res) =
{
	local vector consize;

	consize = GetConSizeForResolution(res);

	cvar_set("vid_conwidth", ftos(consize_x));
	cvar_set("vid_conheight", ftos(consize_y));
}

void SliderRules_Resolution() =
{
	system_res_current = GetSliderValue();
	system_res = getresolution(system_res_current);
}
//void SliderRules_Brightness() =			{	system_brightness		= GetSliderValue();					}
//void SliderRules_Gamma() =				{	system_gamma			= GetSliderValue();					}
void SliderRules_TextureQuality() =
{	system_texturequality	= GetSliderValue();		}//	cvar_set("gl_picmip", ftos(3 - system_texturequality));		}
//void SliderRules_Anisotropy() =			{	system_anisotropy		= GetSliderValue();					}
void SliderRules_Antialiasing() =		{	system_antialiasing		= GetSliderValue();					}
//void SliderRules_ParticleQuality() =	{	system_particlequality	= GetSliderValue();					}
//void SliderRules_MotionBlur() =			{	system_motionblur		= GetSliderValue();					}

void ToggleFullscreen() =		{	system_fullscreen = !system_fullscreen;	}

void ToggleVSync() =			{	system_vsync = !system_vsync;	}

void ToggleShadows() =
{
	local float t_shadows;
	t_shadows = bound(0, cvar("r_shadows"), 1);
	cvar_set("r_shadows", ftos((!t_shadows)*2));
	cvar_set("r_shadow_realtime_world_shadows",	ftos(!t_shadows));
}//system_shadows = !system_shadows;	}

void ToggleDynamicLights() =
{
	local float t_dlights;
	t_dlights = cvar("r_shadow_realtime_dlight");
	cvar_set("r_shadow_realtime_dlight", ftos(!t_dlights));
	cvar_set("r_shadow_realtime_dlight_shadows", ftos(!t_dlights));	
}//system_dlights = !system_dlights;	}

void ToggleBloom() =
{
	local float t_bloom;
	t_bloom = cvar("r_bloom");
	cvar_set("r_bloom", ftos(!t_bloom));
}//system_bloom = !system_bloom;	}

void ToggleMotionBlur() =
{
	local float t_motionblur;
	t_motionblur = cvar("r_motionblur");
	
	if(t_motionblur)
		cvar_set("r_motionblur", "0");
	else
		cvar_set("r_motionblur", "0.2");
}

void ToggleIntelGfx() =
{
	if(system_intelgfx)
	{
		system_intelgfx = false;
		cvar_set("vid_gl20", "1");
		cvar_set("mod_q3bsp_nolightmaps", "0");
	}
	else
	{
		system_intelgfx = true;
		cvar_set("vid_gl20", "0");
		cvar_set("mod_q3bsp_nolightmaps", "1");	
	}
}

void ToggleGibs() =	{	cvar_set("cl_gibs", ftos(!cvar("cl_gibs")));	}

void ToggleShowFPS() = {	cvar_set("showfps", ftos(!cvar("showfps")));	}

void ConfirmResolutionChange() =
{
	vid_res_safe = '0 0 0';
	resetresolutiontime = 0;	
	CloseMenu();
}

void CancelResolutionChange() =
{
	system_res = vid_res_safe;
	SetSystemResCurrentValue();
	ApplyVideoSettings(false);
	
	ConfirmResolutionChange();
}

void Draw_ConfirmResolution() =
{
	if(!LOCALIZE_GENERATING)
	if(time >= resetresolutiontime)
	{

		CancelResolutionChange();
		return;
	}

	Menu_Start_ConfirmationMenu("CONFIRM", '0 0 0', __FUNC__);

	Menu_Text("Continue using this resolution?");
	BR();
	
	skiptranslation = true;
	Menu_Text(ftos(floor(resetresolutiontime - time)));
	skiptranslation = false;	
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Yes", ConfirmResolutionChange, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("No", CancelResolutionChange, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();	
	
	Menu_End();
}

void ApplyVideoSettings(float needsconfirmation) =
{
	if(needsconfirmation)
	if(system_res_x == vid_res_x)
	if(system_res_y == vid_res_y)
		needsconfirmation = false;

	if(needsconfirmation)
		vid_res_safe = vid_res;
		
	ClearAllInputValues();
	RestoreSystemSettings(true);
	cmd("vid_restart\n");
	SetConSize(system_res);
//	updateconsizeforres = system_res;//true;	
	
	if(needsconfirmation)
	{
		SetCurrentMenu(Draw_ConfirmResolution);
		currentmenu.ESCFunc = CancelResolutionChange;
		resetresolutiontime = time+15;
	}
}

void ApplyNewVideoSettings() =	{	ApplyVideoSettings(true);	}

void SetSystemOptionColors(vector optcolor) =
{
	option_imagecolor = option_imagecolor_highlight = option_slidercolor = option_slidercolor_highlight = option_sliderhandlecolor = option_sliderhandlecolor_highlight = optcolor;
}

void SetSystemMenuTabSelectionColors() =
{
	option_fontcolor_highlight	= '0 1 1';
	option_fontcolor			= '0 0.8 0.8';
	option_imagecolor			= '0 0.8 0.8';
	option_imagecolor_highlight	= '0 1 1';
}

void ResetSystemMenuTabSelectionColors() =
{
	option_fontcolor_highlight	= '1 1 1';
	option_fontcolor			= '0.8 0.8 0.8';
	option_imagecolor			= '1 1 1';
	option_imagecolor_highlight	= '1 1 1';	
}

void DrawSystemMenuHeader(float menunum, float lastbutton) =
{
	if(LOCALIZE_GENERATING)
	if(menunum)
		return;

	local float buttonwidth, translate;
	local string filename;
	
	translate = skiptranslation;
	skiptranslation = false;
	
	filename = __FUNC__;
	buf_localizesystemmenuheader = InitializeNonstandardTranslations(buf_localizesystemmenuheader, filename, false);
	
	local string str_system, str_sound;
	
	str_system	= Localize("System", buf_localizesystemmenuheader);
	str_sound	= Localize("Sound", buf_localizesystemmenuheader);
	WriteNonstandardTranslations(buf_localizesystemmenuheader, filename, false, false);
	
	skiptranslation = true;
	
	buttonwidth = 80;

	SetOptionImages_AltSettings_1();
	ResetSystemMenuTabSelectionColors();	
	option_spacing = 2;	
	
	if(menunum == 1)	SetSystemMenuTabSelectionColors();
	HorizontalListButton(0, buttonwidth, str_system, Call_SystemOptions, lastbutton, 3, 2, 0, MBT_BASIC);
	ResetSystemMenuTabSelectionColors();
	
	if(menunum == 2)	SetSystemMenuTabSelectionColors();	
	HorizontalListButton(buttonwidth+option_spacing, buttonwidth, str_sound, Call_SoundOptions, lastbutton, 3, 0, 1, MBT_BASIC);	
	ResetSystemMenuTabSelectionColors();

	option_fontcolor			= '1 1 1';
	option_fontcolor_highlight	= '0 0 0';
	SetOptionImages_Settings_Default();
	
	BR();
	drawline(1, option_pos, option_pos + '420 0 0', '0 0.4 0.4', 0.8, 0);
	option_pos_y += 20;
	
	skiptranslation = translate;
}

void Draw_SoundOptions() =
{
	local float shortbuttonwidth, selectionsize_short, selectionsize_med, selectionsize_long, checkboxspacing, checkboxspacing_short;
	local vector pos, sliderimgsize, opsize, imgsize, screensize;
	local string s, imgname;
	
	#ifdef COMPILE_SERVICE_ONLIVE
		Menu_Start_ESCMenu("SOUND OPTIONS", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	#else
		Menu_Start_ESCMenu("SYSTEM SETTINGS: SOUND", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
		DrawSystemMenuHeader(2, 8);	
	#endif
	
	option_size					= '168 22 0';
	
//	menu_background				= "gfx/menu/rm_backgrnd_cut.tga";	
	
	shortbuttonwidth = 112;	
	selectionsize_short = option_size_x;
	selectionsize_med = 224;	
	selectionsize_long = 407;	
	checkboxspacing = option_size_x + 20;
	checkboxspacing_short = shortbuttonwidth + 20;
	
	SetSystemOptionColors('0.34 0.66 0.72');
	
	option_size_selectionbox = option_size;	
	option_size_selectionbox_x = selectionsize_long;

	SetSystemOptionColors('0.34 0.66 0.72');
	
	option_size_selectionbox_x = selectionsize_long;	
	
	#ifndef COMPILE_SERVICE_ONLIVE
		optionalt_up = 2;
	#endif
	Menu_Slider_Text("Effects Volume", 0, "volume", 0, 1, 101, 4);
	optionalt_up = 0;
	
	DrawElement_SliderMinMaxLabels("min", "max");

	Menu_Slider_Text("Ambient Volume", 0, "ambient_level", 0, 1, 101, 4);	
	DrawElement_SliderMinMaxLabels("min", "max");
	
	Menu_Slider_Text("Music Volume", 0, "bgmvolume", 0, 1, 101, 4);	
	DrawElement_SliderMinMaxLabels("min", "max");

	SetSystemOptionColors('0.34 0.72 0.41');	
	
	Menu_Slider_Text("Master Volume", 0, "mastervolume", 0, 1, 101, 4);	
	DrawElement_SliderMinMaxLabels("min", "max");	
	
	SetSystemOptionColors('1 1 1');
	option_size_selectionbox = '0 0 0';

	BeginBottomButtons(2);	
	DrawElement_BottomButton("Reset", DefaultAudioSettings, 0, 0, 0, 0, MBT_BASIC);
	#ifdef COMPILE_SERVICE_ONLIVE
		DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);
	#else
		DrawElement_BottomButton("Back", CloseMenu, 0, 2, 0, 0, MBT_CANCEL);
	#endif
	EndBottomButtons();
	
	Menu_End();
}

void Call_SoundOptions() =	{	SetDrawFunc(currentmenu, Draw_SoundOptions, false);	}

void Draw_SystemMenu() =
{
	local float shortbuttonwidth, selectionsize_short, selectionsize_med, selectionsize_long, checkboxspacing, checkboxspacing_short, firstsystemoptnum;
	local vector pos, sliderimgsize, opsize, imgsize, screensize;
	local string s, imgname;
	
	Menu_Start_ESCMenu("SYSTEM SETTINGS: VIDEO", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	DrawSystemMenuHeader(1, 17);

	firstsystemoptnum = 2;
	
	option_size					= '168 22 0';
	
//	menu_background				= "gfx/menu/rm_backgrnd_cut.tga";	
	
	shortbuttonwidth = 112;	
	selectionsize_short = option_size_x;
	selectionsize_med = 224;	
	selectionsize_long = 407;	
	checkboxspacing = option_size_x + 20;
	checkboxspacing_short = shortbuttonwidth + 20;
	
	SetSystemOptionColors('0.34 0.66 0.72');
	
	option_size_selectionbox = option_size;	
	option_size_selectionbox_x = selectionsize_long;
	
	option_sliderimage = "gfx/menu/slider_medium_rail.tga";
	SliderRules = SliderRules_Resolution;
	optionalt_up = 1;	
	Menu_Slider_NoReadout_Text("Screen Resolution", system_res_current, "", 0, system_res_num-1, system_res_num);
	optionalt_up = 0;
//	Menu_Slider_NoReadout_Text("Screen Resolution", GetCurrentValueSlot_vec(system_res, 16, GetResolution), "", 0, 15, 16);
	sliderimgsize = drawgetimagesize(option_sliderimage);
	pos = option_pos;
	s = strcat(ftos(system_res_x), " x ");
	s = strcat(s, ftos(system_res_y));
	option_pos = GetLastLinePos();
	option_pos_x += option_sliderspacing + (sliderimgsize_x - stringwidth(s, false, body_fontsize))*0.5;
	option_pos_y -= sliderimgsize_y;
	Menu_AlignedText(s, ALIGN_LEFT);
	option_sliderimage = "gfx/menu/slider_big_rail.tga";
	option_pos = pos;
	SliderRules = SUB_Null;
	
	pos = GetLastLinePos();
	screensize = GetConSizeForResolution(system_res);
	if(screensize_x > 800)
		imgname = "gfx/menu/icon_widescreen.tga";
	else
		imgname = "gfx/menu/icon_letterboxscreen.tga";
	imgsize = drawgetimagesize(imgname);
	pos_x += option_sliderspacing + sliderimgsize_x + 32 - imgsize_x*0.5;
	pos_y -= 10;
	drawpic(pos, imgname, imgsize, '1 1 1', body_imagealpha, body_imageflags);

	option_size_selectionbox_x = selectionsize_short;	
	HorizontalListButton(0, shortbuttonwidth, "V-Sync", ToggleVSync, 0, 4+firstsystemoptnum, 3+firstsystemoptnum, 0, MBT_BASIC);
	DrawElement_CheckBox(option_pos, checkboxspacing_short, system_vsync);	
	
	option_size_selectionbox_x = selectionsize_med - 6;	
	HorizontalListButton(option_sliderspacing, option_size_x, "Fullscreen", ToggleFullscreen, 1+firstsystemoptnum, 4+firstsystemoptnum, 0, 2+firstsystemoptnum, MBT_BASIC);	
	DrawElement_CheckBox(option_pos, option_sliderspacing + checkboxspacing - 6, system_fullscreen);
	BR();

	option_size_selectionbox_x = selectionsize_long;	
	optionalt_up = 2+firstsystemoptnum;
	Menu_Slider_Text("Brightness", 0, "v_brightness", 0, 0.8, 10, 4);	
	DrawElement_SliderMinMaxLabels("min", "max");
	optionalt_up = 0;
	
//	Menu_Slider_Text("Gamma", system_gamma, "v_gamma", 0.1, 5, 10, 4);
//	DrawElement_SliderMinMaxLabels("min", "max");

	SetSystemOptionColors('0.34 0.72 0.41');
	
	SliderRules = SliderRules_TextureQuality;
	Menu_Slider_Text("Texture Quality", system_texturequality, "", 0, 3, 4, 4);
	DrawElement_SliderMinMaxLabels("low", "ultra");
	SliderRules = SUB_Null;
	
	SliderRules = SliderRules_Antialiasing;
	Menu_Slider_Text("Antialiasing", system_antialiasing, "", 1, 4, 4, 1);	
	DrawElement_SliderMinMaxLabels("off", "ultra");
	SliderRules = SUB_Null;
	
	SetSystemOptionColors('0.87 0.51 0.19');
	
	Menu_Slider_Text("Particle Quality", 0, "cl_particles_quality", 0, 4, 5, 1);	
	DrawElement_SliderMinMaxLabels("off", "ultra");
	
	SetSystemOptionColors('0.19 0.87 0.8');
	
	option_size_selectionbox_x = selectionsize_short;
	HorizontalListButton(0, shortbuttonwidth, "Shadows", ToggleShadows, 0, 10+firstsystemoptnum, 9+firstsystemoptnum, 0, MBT_BASIC);
	DrawElement_CheckBox(option_pos, checkboxspacing_short, cvar("r_shadows"));
		
	option_size_selectionbox_x = selectionsize_med - 6;
	HorizontalListButton(option_sliderspacing, option_size_x, "Dynamic Lights (slow)", ToggleDynamicLights, 7+firstsystemoptnum, 11+firstsystemoptnum, 0, 8+firstsystemoptnum, MBT_BASIC);
	DrawElement_CheckBox(option_pos, option_sliderspacing + checkboxspacing - 6, cvar("r_shadow_realtime_dlight"));
	BR();

	option_size_selectionbox_x = selectionsize_short;	
	HorizontalListButton(0, shortbuttonwidth, "Gibs", ToggleGibs, 8+firstsystemoptnum, 12+firstsystemoptnum, 11+firstsystemoptnum, 0, MBT_BASIC);
	DrawElement_CheckBox(option_pos, checkboxspacing_short, cvar("cl_gibs"));	
	
//	option_size_selectionbox_x = selectionsize_short;	
//	HorizontalListButton(0, shortbuttonwidth, "Bloom", ToggleBloom, 9, 13, 12, 0, MBT_BASIC);
//	DrawElement_CheckBox(option_pos, checkboxspacing_short, cvar("r_bloom"));

//	option_size_selectionbox_x = selectionsize_med - 6;
//	HorizontalListButton(option_sliderspacing, option_size_x, "Motion Blur", ToggleMotionBlur, 10, 0, 0, 11, MBT_BASIC);
//	DrawElement_CheckBox(option_pos, option_sliderspacing + checkboxspacing - 6, cvar("r_motionblur"));
//	BR();

	option_size_selectionbox_x = selectionsize_med - 6;
	HorizontalListButton(option_sliderspacing, option_size_x, "NetBook Mode", ToggleIntelGfx, 9+firstsystemoptnum, 0, 0, 10+firstsystemoptnum, MBT_BASIC);
	DrawElement_CheckBox(option_pos, option_sliderspacing + checkboxspacing - 6, system_intelgfx);
	BR();	

	option_size_selectionbox_x = selectionsize_short;	
	HorizontalListButton(0, shortbuttonwidth, "Show FPS", ToggleShowFPS, 10+firstsystemoptnum, 0, 0, 0, MBT_BASIC);
	DrawElement_CheckBox(option_pos, checkboxspacing_short, cvar("showfps"));	
	
	SetSystemOptionColors('1 1 1');
	option_size_selectionbox = '0 0 0';

	BeginBottomButtons(3);
	DrawElement_BottomButton("Apply", ApplyNewVideoSettings, 0, 0, 0, 0, MBT_BASIC);	
	DrawElement_BottomButton("Reset", DefaultVideoSettings, 0, 0, 0, 0, MBT_BASIC);	
	DrawElement_BottomButton("Back", CloseMenu, 0, 1, 0, 0, MBT_CANCEL);
	EndBottomButtons();
	
	Menu_End();
}

void Call_SystemOptions() = {	SetDrawFunc(currentmenu, Draw_SystemMenu, false);	}

void Call_SystemMenu() =
{
	PreserveSystemSettings();
	SetCurrentMenu(Draw_SystemMenu);
}