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
void Menu_Defaults() =
{
	local vector imgsize;

	menu_appearance				= HIDE_BRIGHTNESS | HIDE_ALPHA;
//	menu_background				= "";
	menu_hidebrightness			= 0.5;
	menu_hidealpha				= 0.75;
	
	border_size					= '12 13 0';
	border_appearance			= IMAGE;// | BACKGROUND;// | IMAGE_STRETCH;// | TITLE_FOOTER;
	border_image_topleft		= "gfx/menu/gen_left_top_corner.tga";//"gfx/menu/slider.tga";
	border_image_topright		= "gfx/menu/gen_right_top_corner.tga";//"gfx/menu/slider.tga";
	border_image_bottomleft		= "gfx/menu/gen_left_bottom_corner.tga";//"gfx/menu/slider.tga";
	border_image_bottomright	= "gfx/menu/gen_right_bottom_corner.tga";//"gfx/menu/slider.tga";
	border_image_top			= "gfx/menu/gen_top_border.tga";
	border_image_bottom			= "gfx/menu/gen_bottom_border.tga";
//	border_size = drawgetimagesize(border_image_topleft);
	
	// use the following if TITLE_FOOTER is not used
		border_image_left				= "gfx/menu/gen_left_border.tga";
		border_image_right				= "gfx/menu/gen_right_border.tga";
	
	// use the following if TITLE_FOOTER is used
		border_image_titleleft			= "";
		border_image_titleright			= "";
		border_image_titlefooterleft	= "";
		border_image_titlefooterright	= "";
		border_image_titlefooter		= "";
		border_image_bodyleft			= "";
		border_image_bodyright			= "";
		
	border_imagecolor			= '1 1 1';
	border_bgcolor				= '0.1 0.1 0.2';
	border_imagealpha			= 1;
	border_bgalpha				= 1;
	border_imageflags			= DRAWFLAG_ADDITIVE;
	border_bgflags				= DRAWFLAG_NORMAL;
	
	title_appearance			= BACKGROUND | IMAGE_STRETCH;
	title_image					= "gfx/menu/gen_title_mid.tga";		
	title_image_left			= "gfx/menu/gen_title_left.tga";
	title_image_right			= "gfx/menu/gen_title_right.tga";
	title_image_offset			= '0 0 0';
	title_size					= '0 20 0';
	title_bgspread				= '0 0 0';
	title_font					= FONT_MENU;
	title_textalignment			= '0 0 0';	// Range is -1 to 1, positive is up & right, negative is down & left, 0 is center.
	title_textbordersize		= '4 4 0';
	title_fontsize				= '12 12 0';	
	title_fontcolor				= '0.8 0.8 0.9';
	title_imagecolor			= '1 1 1';
	title_bgcolor				= '0 0 0.2';	
	title_fontalpha				= 1;
	title_imagealpha			= 1;
	title_bgalpha				= 0.5;
	title_fontflags				= DRAWFLAG_ADDITIVE;
	title_imageflags			= DRAWFLAG_ADDITIVE;
	title_bgflags				= DRAWFLAG_NORMAL;
	
	body_appearance				= BACKGROUND | IMAGE_STRETCH;
	body_bgimage				= "";	
	body_bgspread				= '0 0 0';
	body_margin					= '8 8 0';
	body_alignment				= '0 0 0';	// affects buttons and images
	body_font					= FONT_MENU;
	body_textalignment			= '0 0 0';
	body_textbordersize			= '4 4 0';
	body_fontsize				= '8 8 0';
	body_fontcolor				= '0.9 0.9 1';
	body_imagecolor				= '1 1 1';
	body_imagebgcolor			= '0.2 0.2 0.2';
	body_bgcolor				= '0 0 0.2';	
	body_bgimagecolor			= '1 1 1';		
	body_fontalpha				= 1;
	body_imagealpha				= 1;
	body_imagebgalpha			= 1;
	body_bgalpha				= 0.5;
	body_bgimagealpha			= 0.5;	
	body_fontflags				= DRAWFLAG_ADDITIVE;
	body_imageflags				= DRAWFLAG_NORMAL;
	body_imagebgflags			= DRAWFLAG_NORMAL;
	body_bgflags				= DRAWFLAG_NORMAL;	
	body_bgimageflags			= DRAWFLAG_NORMAL;	
	
	option_appearance			= BACKGROUND | IMAGE_STRETCH;	// add LIST_HORIZONTAL
	option_image				= "gfx/menu/rm_button_mid_hl.tga";		
	option_image_left			= "gfx/menu/rm_button_left_hl.tga";
	option_image_right			= "gfx/menu/rm_button_right_hl.tga";	
	option_image_highlight		= "gfx/menu/rm_button_mid_hl.tga";
	option_image_left_highlight	= "gfx/menu/rm_button_left_hl.tga";
	option_image_right_highlight = "gfx/menu/rm_button_right_hl.tga";	
	option_image_selected		= "";
	option_image_selected_offset = '0 0 0';	
	option_size					= '0 22 0';
	option_size_selectionbox	= '0 0 0';
	option_spacing				= 2;	
	option_infospacing			= 150;
	option_sliderimage			= "gfx/menu/slider_big_rail.tga";
	option_sliderhandleimage	= "gfx/menu/slider_big.tga";
	option_sliderspacing		= 188;
	option_sliderinfospacing	= 350;
	option_font					= FONT_MENU;
	option_textalignment		= '0 0 0';	// Range is -1 to 1, positive is up & right, negative is down & left, 0 is center.
	option_textbordersize		= '4 4 0';
	option_fontsize				= '10 10 0';		
	option_fontcolor			= '0.3 0.3 0.7';
	option_imagecolor			= '0.3 0.3 0.4';
	option_slider_fontsize		= '8 8 0';
	option_slidercolor			= '1 1 1';
	option_sliderhandlecolor	= '1 1 1';
	option_bgcolor				= '0 0 0';//'0.1 0.1 0.2';
	option_fontcolor_highlight	= '0.65 0.65 1';
	option_imagecolor_highlight	= '0.3 0.3 0.5';
	option_slidercolor_highlight =	'1 1 1';
	option_sliderhandlecolor_highlight = '1 1 1';
	option_bgcolor_highlight	= '0 0 0';//'0.1.5 0.1.5 0.4';
	option_fontalpha			= 1;
	option_imagealpha			= 0.5;
	option_imagealpha_highlight	= 1;
	option_slideralpha			= 0.25;
	option_slideralpha_highlight = 0.5;
	option_sliderhandlealpha	= 0.5;
	option_sliderhandlealpha_highlight = 1;
	option_slider_alignment		= '0 0 0';
	option_bgalpha				= 1;
	option_fontflags			= DRAWFLAG_ADDITIVE;
	option_imageflags			= DRAWFLAG_NORMAL;
	option_bgflags				= DRAWFLAG_NORMAL;	
	
	scrollbar_toparrowimage		= "gfx/menu/vert_slider_aup.tga";
	scrollbar_bottomarrowimage	= "gfx/menu/vert_slider_adown.tga";
	scrollbar_image				= "gfx/menu/vert_slider_rail.tga";
	scrollbar_handleimage		= "gfx/menu/vert_slider.tga";
	imgsize = drawgetimagesize(scrollbar_image);
	scrollbar_width				= imgsize_x;
	
	bottombutton_ofs			= '0 0 0';	
	
	input_font					= FONT_DEFAULT;
	input_fontsize				= '6 8 0';	
	input_fontcolor				= '1 1 1';
	incrementcontrol_fontsize	= '6 6 0';
}

void Menu_Main(string title, vector pos, vector bsize, string filename) =
{
	Menu_Defaults();

	active_menu.menu_style		= active_menu.menu_style | STYLE_TOOLBAR;

	menu_appearance				= false;//SIZE_MANUAL;
	menu_background				= "gfx/menu/main_backgrnd_motd.tga";//"gfx/menu/main_backgrnd.tga";
	menu_drawMOTD				= true;
	
	border_size					= '0 0 0';
	border_appearance			= false;	
	
	title_image					= "gfx/menu/menu_logo.tga";		
	title_image_left			= "";
	title_image_right			= "";	
	title_image_offset			= '40 0 0';
	title_size					= drawgetimagesize(title_image);
	title_font					= FONT_USER0;
	title_fontsize				= '20 20 0';
	title_bgcolor				= '0 0 0';
	title_bgalpha				= 0;
	
	body_margin					= '0 0 0';
//	body_bgcolor				= '0 0 0';
	body_bgalpha				= 0;	
	body_alignment				= '-1 0 0';	
	
	option_image				= "gfx/menu/lm_button_big.tga";
	option_image_left			= "";
	option_image_right			= "";
	option_image_highlight		= "gfx/menu/lm_button_big_hover.tga";
	option_image_left_highlight = "";
	option_image_right_highlight = "";	
	option_image_selected		= "gfx/menu/lm_button_big_active.tga";	
//	option_image_selected_offset = '-23 -24 0';
	option_size					= drawgetimagesize(option_image);
	option_textalignment		= '1 0 0';
	option_textbordersize		= '16 2 0';
	option_fontsize				= '14 11 0';	
	option_imagecolor			= '1 1 1';
	option_fontcolor			= '1 1 1';
	option_fontcolor_highlight	= '0 0 0';	
	option_imagecolor_highlight	= '1 1 1';	
	option_spacing				= 20;	
	option_imagealpha			= 1;
	option_bgalpha				= 0;	
	option_bgcolor				= '0 0 0';
//	option_bgcolor_highlight	= '0 0 0';

	option_fontflags			= DRAWFLAG_NORMAL;	
	
	Menu_Start(title, pos, bsize, filename);
}

void Menu_Start_Generic(string title, vector bsize, string filename) =
{
	Menu_Defaults();
	
	menu_hidebrightness			= 0;
	menu_hidealpha				= 0;	
	
	title_fontsize				= '8 8 0';
	title_textbordersize_x		= 16;
	option_size					= '100 20 0';	
	
	if(bsize == '0 0 0')
	{
		bsize_x = stringwidth(title, false, title_fontsize) + title_textbordersize_x*2 + border_size_x*2;
		if(bsize_x < 150)
			bsize_x = 150;
	}

	Menu_Start(title, POS_AUTO, bsize, filename);
}

void Menu_Start_ESCMenu(string title, vector pos, vector bsize, string filename) =
{
	Menu_Defaults();

	menu_appearance				= menu_appearance | SIZE_MANUAL | HIDE_ALPHA;
	menu_background				= "gfx/menu/rm_backgrnd.tga";
	menu_drawMOTD				= true;	

	menu_hidealpha				= 0;	
	
	border_size					= '0 0 0';
	border_appearance			= false;	

	title_image					= "";		
	title_image_left			= "";
	title_image_right			= "";		
	title_size					= '0 35 0';
	title_textalignment			= '0 1 0';
	title_textbordersize		= '0 0 0';		
	title_fontsize				= '14 12 0';
	title_bgcolor				= '0 0 0';
	title_bgalpha				= 0;	
	
	body_margin					= '0 0 0';
	body_bgcolor				= '0 0 0';
	body_bgalpha				= 0;		
	body_alignment				= '-1 0 0';
	body_textalignment			= '1 0 0';

	option_size					= '250 22 0';
	option_spacing				= 6;

	option_textalignment		= '-1 0 0';
	option_textbordersize		= '12 7 0';
	option_fontsize				= '11 8 0';	

	option_fontcolor			= '1 1 1';		
	option_imagecolor			= '1 1 1';

	option_fontcolor_highlight	= '0 0 0';
	option_imagecolor_highlight	= '1 1 1';

//	option_imagealpha			= 1;
	option_bgalpha				= 0;	

	option_fontflags			= DRAWFLAG_NORMAL;		
	
	bottombutton_ofs			= '-12 -28 0';
	
	Menu_Start(title, pos, bsize, filename);
}

/*void Menu_Start_ESCMenuList(string title, vector pos, vector bsize) =
{
	menu_appearance				= menu_appearance | SIZE_MANUAL;
	menu_background				= "gfx/menu/rm_backgrnd.tga";
	
	border_size					= '0 0 0';
	border_appearance			= false;	

	title_image					= "";		
	title_size					= '0 35 0';
	title_textalignment			= '0 1 0';
	title_textbordersize		= '0 0 0';		
	title_fontsize				= '16 11.5 0';
	title_bgcolor				= '0 0 0';
	title_bgalpha				= 0;	
	
	body_margin					= '0 0 0';
	body_bgcolor				= '0 0 0';
	body_bgalpha				= 0;		
	body_alignment				= '-1 0 0';

	option_size					= '160 20 0';
	option_spacing				= 8;

	option_textalignment		= '1 -1 0';
	option_textbordersize		= '12 6 0';
	option_fontsize				= '11 8 0';	

	option_fontcolor			= '1 1 1';		
	option_imagecolor			= '1 0 0';

	option_fontcolor_highlight	= '0 0 0';
	option_imagecolor_highlight	= '1 1 1';

	option_imagealpha			= 0.75;
	option_bgalpha				= 0;	

	option_fontflags			= DRAWFLAG_NORMAL;		
	
	Menu_Start(title, pos, bsize);
}*/

void Menu_Start_ESCMenu_ServerList(string title, vector pos, vector bsize, string filename) =
{
	Menu_Defaults();

	menu_appearance				= menu_appearance | SIZE_MANUAL;
	menu_background				= "";
	title_size					= '0 40 0';
	title_fontsize				= '14 14 0';
	title_textalignment			= '0 1 0';
	title_textbordersize		= '4 8 0';	
	
	body_textbordersize			= '6 6 0';
	body_fontsize				= '8 8 0';	
	body_alignment				= '-1 0 0';	
	
	option_appearance			= IMAGE_STRETCH;	
	option_textalignment		= '-1 1 0';
	
	option_size					= '0 24 0';
	option_textbordersize		= '6 6 0';
	option_fontsize				= '10 10 0';	
	
	Menu_Start(title, pos, bsize, filename);
}

void Menu_Start_ConfirmationMenu(string title, vector bsize, string filename) =
{
	Menu_Defaults();

	active_menu.menu_style		= active_menu.menu_style | STYLE_PRIORITY;
	menu_appearance				= menu_appearance | SIZE_MANUAL;
	
	border_size					= '0 0 0';
	border_appearance			= false;	

	title_appearance			= BACKGROUND | IMAGE_FULLMENU;
	title_image					= "gfx/menu/popup_menu.tga";
	title_image_left			= "";
	title_image_right			= "";		
	
	title_size					= '0 30 0';
	title_textalignment			= '0 -1 0';
	title_textbordersize		= '0 0 0';		
	title_fontsize				= '14 12 0';
	title_bgcolor				= '0 0 0';
	title_bgalpha				= 0;	
	
//	body_appearance				= false;	
//	body_bgimage				= "gfx/menu/popup_menu.tga";	
	body_margin					= '30 20 0';
	body_bgcolor				= '0 0 0';
	body_bgalpha				= 0;		
	body_alignment				= '0 0 0';
	body_textbordersize			= '0 0 0';

	option_size					= '168 22 0';
	option_spacing				= 6;

	option_textalignment		= '0 0 0';
	option_textbordersize		= '12 7 0';
	option_fontsize				= '11 8 0';	

	option_fontcolor			= '1 1 1';		
	option_imagecolor			= '1 1 1';

	option_fontcolor_highlight	= '0 0 0';
	option_imagecolor_highlight	= '1 1 1';

//	option_imagealpha			= 1;
	option_bgalpha				= 0;	

	option_fontflags			= DRAWFLAG_NORMAL;		

	bottombutton_ofs			= '-73 -54 0';	
	
	if(bsize == '0 0 0')
	{
		drawfont = title_font;
		bsize_x = stringwidth(title, false, title_fontsize) + title_textbordersize_x*2 + border_size_x*2;
		if(bsize_x < 150)
			bsize_x = 150;
	}	
	
	Menu_Start(title, POS_AUTO, drawgetimagesize(title_image), filename);
}

void Menu_Start_OptionMenu(string title, vector bsize, string filename) =
{
	Menu_Defaults();

	active_menu.menu_style		= active_menu.menu_style | STYLE_PRIORITY;

	menu_hidebrightness			= 0;
	menu_hidealpha				= 0;
	
	title_fontsize				= '8 8 0';
	title_textbordersize		= '16 4 0';
	title_textalignment			= '0 1 0';
	title_bgcolor				= '0 0 0.2';		
	
	option_appearance			= IMAGE_STRETCH;
	option_size					= '0 22 0';	
	option_textalignment		= '-1 0 0';
	option_textbordersize		= '12 7 0';
	body_alignment				= '-1 0 0';	
	body_textalignment			= '-1 0 0';

	bottombutton_ofs			= '-63 -50 0';	
	
	Menu_Start(title, POS_AUTO, bsize, filename);
}

void Menu_Start_MissionMap(string title, vector bsize, string filename) =
{
	Menu_Defaults();

	active_menu.menu_style		= active_menu.menu_style | STYLE_PRIORITY | STYLE_NODIM;

	menu_hidebrightness			= 0;
	menu_hidealpha				= 0;
	
	border_appearance			= IMAGE;

	border_size					= '12 13 0';
	border_appearance			= IMAGE;
	border_imagecolor			= '1 1 1';
	border_imagealpha			= 1;
	border_imageflags			= DRAWFLAG_ADDITIVE;		
	
	body_appearance				= false;
	
	title_fontsize				= '8 8 0';
	title_textbordersize		= '16 4 0';
	title_textalignment			= '0 1 0';
	title_bgcolor				= '0 0 0.2';		
	
	option_appearance			= IMAGE_STRETCH;
	option_size					= '0 20 0';	
	option_textalignment		= '-1 0 0';
	body_alignment				= '-1 0 0';	

	bottombutton_ofs			= '-63 -50 0';	
	
	Menu_Start(title, POS_AUTO, bsize, filename);
}

void Menu_Start_MissionEditor(string title, string filename) =
{
	local vector bsize;

	Menu_Defaults();

//	active_menu.menu_style		= STYLE_PRIORITY | STYLE_NODIM;	
	
	menu_hidebrightness			= 0;
	menu_hidealpha				= 0;
	
	title_fontsize				= '9 9 0';
	title_textbordersize		= '0 4 0';
	title_textalignment			= '0 1 0';
	title_bgspread				= '6 6.5 0';
	
	body_fontsize				= '8 8 0';	
	body_bgspread				= '6 6.5 0';
	body_alignment				= '-1 0 0';
	body_margin					= '4 8 0';
	
	option_appearance			= IMAGE_STRETCH;	
	option_size					= '0 14 0';
	option_fontsize				= '8 8 0';
	option_sliderspacing		= 0;
	
	option_sliderimage			= "gfx/menu/slider_small_rail.tga";
	option_sliderhandleimage	= "gfx/menu/slider_small.tga";	

	bsize_x = 150;
	bsize_y = vid_size_y;
	
	Menu_Start(title, POS_TOP_RIGHT, bsize, filename);
}

void Menu_Start_Scoreboard(string title, vector bsize, string filename) =
{
	Menu_Defaults();

	active_menu.menu_style		= active_menu.menu_style | STYLE_NODIM | STYLE_SLOWOPEN;
	body_alignment				= '-1 0 0';	
	
	title_fontsize				= '8 8 0';
	title_textbordersize		= '16 4 0';
	title_textalignment			= '0 1 0';
	title_bgcolor				= '0 0 0.2';		
	
	body_bgalpha				= 0.9;	
	
	if(currentlanguage == LANGUAGE_JAPANESE)
		body_fontsize				= '8 8 0';	
	else
		body_fontsize				= '6 6 0';
	
	option_appearance			= IMAGE_STRETCH;
	option_size					= '0 20 0';	
	option_textalignment		= '0 0 0';
	option_bgalpha				= 0.5;
	option_bgcolor				= '0.15 0.15 0.15';
	option_bgcolor_highlight	= '0.3 0.3 0.6';//'0.15 0.15 0.4';	
	
	bottombutton_ofs			= '-63 -50 0';	
	
	Menu_Start(title, POS_AUTO, bsize, filename);
}

#ifdef COMPILE_SERVICE_ONLIVE
	void Menu_Start_ConfirmationMenu_RealArcade(string title, vector bsize, string filename) =
	{
		local vector pos;
	
		Menu_Defaults();

		active_menu.menu_style		= active_menu.menu_style | STYLE_NODIM | STYLE_PRIORITY | STYLE_FASTCLOSE;
		menu_appearance				= menu_appearance | SIZE_MANUAL;
		
		border_size					= '0 0 0';
		border_appearance			= false;	

		title_appearance			= BACKGROUND | IMAGE_FULLMENU;
		title_image					= "";
		title_image_left			= "";
		title_image_right			= "";		
		
		title_size					= '0 30 0';
		title_textalignment			= '0 -1 0';
		title_textbordersize		= '0 0 0';		
		title_fontsize				= '14 12 0';
		title_bgcolor				= '0 0 0';
		title_bgalpha				= 0;	
		
	//	body_appearance				= false;	
	//	body_bgimage				= "gfx/menu/popup_menu.tga";	
		body_margin					= '30 20 0';
		body_bgcolor				= '0 0 0';
		body_bgalpha				= 0;		
		body_alignment				= '0 0 0';
		body_textbordersize			= '0 0 0';
		body_fontsize				= '24 20 0';

		option_size					= '168 35 0';
		option_spacing				= 6;

		option_textalignment		= '0 0 0';
		option_textbordersize		= '12 7 0';
		option_fontsize				= '14 14 0';	

		option_fontcolor			= '1 1 1';		
		option_imagecolor			= '1 1 1';

		option_fontcolor_highlight	= '0 0 0';
		option_imagecolor_highlight	= '1 1 1';

	//	option_imagealpha			= 1;
		option_bgalpha				= 0;	

		option_fontflags			= DRAWFLAG_NORMAL;		

		input_fontsize				= '16 16 0';	
		input_fontcolor				= '1 1 1';		
		
		bottombutton_ofs			= '-73 -54 0';	
		
		if(bsize == '0 0 0')
		{
			drawfont = title_font;
			bsize_x = stringwidth(title, false, title_fontsize) + title_textbordersize_x*2 + border_size_x*2;
			if(bsize_x < 150)
				bsize_x = 150;
		}	
		
		Menu_Start(title, POS_AUTO, bsize, filename);
	}
#endif

void SetOptionImages_AltSettings_1() =
{
	option_image				= "gfx/menu/rm_field_mid_hl.tga";		
	option_image_left			= "gfx/menu/rm_field_left_hl.tga";
	option_image_right			= "gfx/menu/rm_field_right_hl.tga";	
	option_image_highlight		= "gfx/menu/rm_field_mid_hl.tga";
	option_image_left_highlight	= "gfx/menu/rm_field_left_hl.tga";
	option_image_right_highlight = "gfx/menu/rm_field_right_hl.tga";	
}

void SetOptionImages_Settings_Default() =
{
	option_image				= "gfx/menu/rm_button_mid_hl.tga";		
	option_image_left			= "gfx/menu/rm_button_left_hl.tga";
	option_image_right			= "gfx/menu/rm_button_right_hl.tga";	
	option_image_highlight		= "gfx/menu/rm_button_mid_hl.tga";
	option_image_left_highlight	= "gfx/menu/rm_button_left_hl.tga";
	option_image_right_highlight = "gfx/menu/rm_button_right_hl.tga";	
}