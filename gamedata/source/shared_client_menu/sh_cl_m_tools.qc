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
void RestoreMenuSetting_body_alignment_horizontal() =
{
	body_alignment_x = body_alignment_horizontal_old;
	body_alignment_horizontal_old = 0;
}

void RestoreMenuSetting_option_size_width() =
{
	option_size_x = option_size_width_old;
	option_size_width_old = 0;
}

void RestoreMenuSetting_option_size_height() =
{
	option_size_y = option_size_height_old;
	option_size_height_old = 0;
}

void RestoreMenuSetting_option_spacing() =
{
	option_spacing = option_spacing_old;
	option_spacing_old = 0;
}

void RestoreMenuSetting_option_textalignment() =
{
	option_textalignment = option_textalignment_old;
	option_textalignment_old = '0 0 0';
}

void RestoreMenuSetting_option_fontsize() =
{
	option_fontsize = option_fontsize_old;
	option_fontsize_old = '0 0 0';
}

void RestoreMenuSetting_option_image() =
{
	option_image = option_image_old;
	option_image_old = "";
}

void RestoreMenuSetting_option_image_highlight() =
{
	option_image_highlight = option_image_highlight_old;
	option_image_highlight_old = "";
}

void RestoreMenuSetting_body_fontsize() =
{
	body_fontsize = body_fontsize_old;
	body_fontsize_old = '0 0 0';
}

void RestoreMenuSetting_body_fontcolor() =
{
	body_fontcolor = body_fontcolor_old;
	body_fontcolor_old = '0 0 0';
}

void RestoreMenuSetting_body_textalignment() =
{
	body_textalignment = body_textalignment_old;
	body_textalignment_old = '0 0 0';
}

void RestoreMenuSetting_body_textbordersize() =
{
	body_textbordersize = body_textbordersize_old;
	body_textbordersize_old = '0 0 0';
}

void RestoreMenuSetting_body_imagealpha() =
{
	body_imagealpha = body_imagealpha_old;
	body_imagealpha_old = 0;
}

void TempMenuSetting_body_alignment_horizontal(float algn) =
{
	body_alignment_horizontal_old = body_alignment_x;
	body_alignment_x = algn;
}

void TempMenuSetting_option_textalignment(vector algn) =
{
	option_textalignment_old = option_textalignment;
	option_textalignment = algn;
}

void TempMenuSetting_option_size_width(float width) =
{
	option_size_width_old = option_size_x;
	option_size_x = width;
}

void TempMenuSetting_option_size_height(float height) =
{
	option_size_height_old = option_size_y;
	option_size_y = height;
}

void TempMenuSetting_option_spacing(float tempspacing) =
{
	option_spacing_old = option_spacing;
	option_spacing = tempspacing;
}

void TempMenuSetting_option_fontsize(vector tempfontsize) =
{
	option_fontsize_old = option_fontsize;
	option_fontsize = tempfontsize;//*fontsize_multiplier;
}

void TempMenuSetting_option_image(string s) =
{
	option_image_old = option_image;
	option_image = s;
}

void TempMenuSetting_option_image_highlight(string s) =
{
	option_image_highlight_old = option_image_highlight;
	option_image_highlight = s;
}

void TempMenuSetting_body_fontsize(vector tempfontsize) =
{
	body_fontsize_old = body_fontsize;
	body_fontsize = tempfontsize;
	
	if(body_fontsize_x < 14 || body_fontsize_y < 14)
	body_fontsize = body_fontsize*languagefontscale;
}

void TempMenuSetting_body_fontcolor(vector tempfontcolor) =
{
	body_fontcolor_old = body_fontcolor;
	body_fontcolor = tempfontcolor;
}

void TempMenuSetting_body_textalignment(vector temptextalignment) =
{
	body_textalignment_old = body_textalignment;
	body_textalignment = temptextalignment;
}

void TempMenuSetting_body_textbordersize(vector tempbordersize) =
{
	body_textbordersize_old = body_textbordersize;
	body_textbordersize = tempbordersize;
}

void TempMenuSetting_body_imagealpha(float tempimagealpha) =
{
	body_imagealpha_old = body_imagealpha;
	body_imagealpha = tempimagealpha;
}

/*void DrawString(vector pos, string text, vector fontsize, vector rgb, float alph, float flag) =
{
	pos = DrawFontPosition(pos, fontsize);
	fontsize = DrawFontSize(fontsize);
	drawstring(pos, text, fontsize, rgb, alph, flag);
}*/

void ESCFunc_Ignore() =	{}

void ESCFunc_AllowESCMenu() =	{}

void SetCurrentMenu(void() drawfunc) = // creates a new menu and sets is as the current menu being viewed
{
	local entity lastcurrentmenu;

	ClearAllInputValues();
	lastcurrentmenu = currentmenu;
//	cl_button = 0;
	currentmenu = SpawnMenu(drawfunc);
	if(lastcurrentmenu)
		currentmenu.parentmenu = lastcurrentmenu;
//	currentmenu.scrollbar_alignment = ALIGN_TOP;
	arrowkeymovement = TRUE;
	NegateAxisSettings();
}

void SetPulldownMenu(entity m_parentmenu, void() drawfunc) =
{
	pulldownmenu = SpawnMenu(drawfunc);
	//pulldownmenu.pulldownparent = m_parentmenu;
}

vector GetLastButtonPos() = // gets the top left position of the last button based on option_pos
{
		local vector pos, outersize, innersize;

//	local vector pos;
	pos = option_pos;
	pos_y -= option_size_y + option_spacing;
	

		
		outersize_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2;
		outersize_y = option_size_y;
		innersize = option_size;
		
		pos = AlignmentPos(pos, outersize, innersize, body_alignment, '0 0 0');	
	
	
	return pos;
}

vector GetLastLinePos() = // gets the top left position of the last line based on option_pos
{
	local vector pos;
	pos = option_pos;
	if(lastimagesize == '0 0 0')
		pos_y -= option_size_y + option_spacing;
	else
		pos_y = lastimagesize_y;
	return pos;
}

vector GetInputBoxSize(string s) =
{
	local vector inputboxsize;
	s = strcat(s, " ");
	inputboxsize_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - stringwidth(s, false, body_fontsize);
	inputboxsize_x = floor(inputboxsize_x/input_fontsize_x)*input_fontsize_x;
	return inputboxsize;
}

string GetFilenameFromPath(string filepath, float param, float removeprefix) =
{
	local string s;
	tokenizebyseparator(filepath, "/", ".");
	s = argv(param);
	if(removeprefix)
		s = substring(s, 1, strlen(s)-1);
	s = uri_unescape(s);
	return s;
}

void GoToBottomOfImage() =	{	option_pos_y += lastimagesize_y + option_spacing;	}

void Menu_DisplayCvarBooleanStatusOnLastLine(string cv) =
{
	local vector pos;
	local string s;
	
	pos = GetLastLinePos();
	pos_x += 100; // fix this
	
	if(cvar(cv) > 0)
		s = "ON";
	else
		s = "OFF";
		
	drawstring(pos, s, '5 7 0'*languagefontscale, option_fontcolor_highlight, option_fontalpha, option_fontflags);	
}

void BR() =	{	option_pos_y += option_size_y+option_spacing;	}	// line break

void SetBaseFontSizes() =
{
	if(title_fontsize_base != '0 0 0')
		return;

	title_fontsize_base = title_fontsize;
	body_fontsize_base = body_fontsize;
	option_fontsize_base = option_fontsize;
	input_fontsize_base = input_fontsize;
}

/*void SetFontSizes(float texttype, float fontnum) =
{
//	SetBaseFontSizes();
	
//	drawfont = fontnum;
	
	if(fontnum == FONT_DEFAULT)
	{
		fontsize_multiplier = fontsize_multiplier_default;
		fontlinespacing = fontlinespacing_default;
	}
	else
	if(fontnum == FONT_MENU)
	{
		fontsize_multiplier = fontsize_multiplier_menu;
		fontlinespacing = fontlinespacing_menu;
	}
	else
	if(fontnum == FONT_USER0)
	{
		fontsize_multiplier = fontsize_multiplier_user0;
		fontlinespacing = fontlinespacing_user0;
	}
	
	if(texttype == TEXT_TITLE)
		title_fontsize = title_fontsize_base*fontsize_multiplier;
	else
	if(texttype == TEXT_BODY)
		body_fontsize = body_fontsize_base*fontsize_multiplier;
	else
	if(texttype == TEXT_OPTION)
		option_fontsize = option_fontsize_base*fontsize_multiplier;
	else
	if(texttype == TEXT_INPUT)
		input_fontsize = input_fontsize_base*fontsize_multiplier;
}*/

void EscapeMenuBranch(float depth) =
{
	while(depth >= 0)
	{
		if(IsAssignedFunction(currentmenu.ESCFunc))
		{
			if(currentmenu.ESCFunc == ESCFunc_AllowESCMenu)
				CloseMenu();
			else
				currentmenu.ESCFunc();
		}
		else
			CloseMenu();
			
		depth -= 1;
	}
}

void CloseMenuBranch(float depth) =	// closes menus tracing back a number of times equal to depth
{
	ClearAllInputValues();
	arrowkeymovement = TRUE; // so the mouse doesn't automatically select any buttons that appear underneath it if a window closes while it's idle
	
	while(depth >= 0)
	{
		GoToNextCurrentMenu();
		depth -= 1;
	}
}

void CloseMenu() =
{
	if(currentmenu.menu_style & STYLE_FASTCLOSE)
		menu_closing = true;

	if(currentmenu.drawinglist)
	{
		currentmenu.drawinglist = false;
		UpdateBindMap();
	}

	CloseMenuBranch(0);
}

void ClosePulldownMenu() =
{
	RemoveMenuEnt(pulldownmenu);
	UpdateMenuChain();	
}

void ClearMenus() = // closes all menus except the starting menu, or menu with the lowest draworder
{
	local entity menu, nextmenu;

	menu = list_menuchain.menuchain;
	while(menu)
	{
		nextmenu = menu.menuchain;
		ClearMenuData(menu);
		remove(menu);
		menu = nextmenu;
	}
	
	active_menu = world;
	currentmenu = list_menuchain;
	menu_count = 1;
	UpdateMenuChain();
}

float InFocus(entity menu) =
{
	if(active_menu == currentmenu)
	if(!(pulldownmenu && active_menu != pulldownmenu))
		return true;

	return false;
}

void Menu_Start(string title, vector pos, vector bsize, string filename) = // call at the start of each menu
{
	active_menu.m_filename = zonecpy(active_menu.m_filename, filename);
	
	if(title_fontsize_x < 14 || title_fontsize_y < 14)
		title_fontsize = title_fontsize*languagefontscale*0.8;	
	
	if(option_fontsize_x < 14 || option_fontsize_y < 14)
		option_fontsize = option_fontsize*languagefontscale;
	
	if(body_fontsize_x < 14 || body_fontsize_y < 14)
		body_fontsize = body_fontsize*languagefontscale;
	
	if(LOCALIZE_GENERATING)
		filetextline = 1;
	else
		filetextline = 0;
//	SetBaseFontSizes();
//	SetFontSizes(TEXT_TITLE, title_font);
//	SetFontSizes(TEXT_BODY, body_font);
//	SetFontSizes(TEXT_OPTION, option_font);
//	SetFontSizes(TEXT_INPUT, input_font);

	local float presetpos, file;
	local string line;

	active_menu.skippedoptionslots = 0;

	if(InFocus(active_menu))
		SH_PreMenuControls();

//	ApplyHideValues();

	if(active_menu.menu_style & STYLE_TOOLBAR)
	if(active_menu == currentmenu)
		active_menu.user_current_selection = 0;	
	
	if(bsize_y)
		menu_appearance = menu_appearance | SIZE_MANUAL;
	
	if(pos_x < 0 || pos_y < 0)
	if(pos != POS_AUTO)
		presetpos = true;
	
	if(active_menu.menusize != '0 0 0')
	{
		if(!menu_appearance & SIZE_MANUAL)
			bsize = active_menu.menusize;

		if(!presetpos)
			pos = active_menu.menupos;
	}
		
	if(pos != POS_AUTO)
	{
		if(pos_x == -3)
			pos_x = vid_size_x - bsize_x;
			
		if(pos_y == -1)
			pos_y = (vid_size_y - bsize_y)*0.5;
	}
	
	if(active_menu.menusize_x == 0)	
	{
		menu_initializing = true;	
	//	if(active_menu.menu_style & STYLE_SLOWOPEN)
	//		menu_initializing += 1;
			
		active_menu.menusize_x = bsize_x;
	
		if(menu_appearance & SIZE_MANUAL)
			active_menu.menusize_y = bsize_y;
			
		active_menu.menupos = pos;		
	}	
	
	if(!presetpos)
		pos_x = pos_x + (vid_size_x - vid_size_norm_x)*0.5;

//	filetextline = 1;		
		
	if(!menu_initializing)
	{
		if(active_menu == currentmenu)
		if(active_menu.menu_style & STYLE_PRIORITY)
		if(!active_menu.menu_style & STYLE_NODIM)
			drawfill('0 0 0', vid_size, '0 0 0', 0.9, 0);	
	
		if(!(active_menu != currentmenu && !menu_hidealpha))// && active_menu.linkcontrolstomenu != currentmenu)) // is not hidden
		if(CursorInsideBox(pos, bsize_x, bsize_y))
		{
			CURSOROVERMENU = true;

			if(!(pulldownmenu && active_menu != pulldownmenu))
			if(active_menu.menu_style & STYLE_SELECTABLE) // if menu can be clicked on to be made active
			if(!(currentmenu && currentmenu != active_menu && currentmenu.menu_style & STYLE_PRIORITY)) // don't let the user hide prompts behind selectable menus
			{
			//	if(cl_button == K_MOUSE1 || cl_button == K_MOUSE2 || cl_button == -K_MOUSE1 || cl_button == -K_MOUSE2)
				if(GameControl(CTRL_MENUBUTTON1, 0) || GameControl(CTRL_MENUBUTTON1, -1) || GameControl(CTRL_MENUBUTTON2, 0) || GameControl(CTRL_MENUBUTTON2, -1))
					currentmenu = active_menu;
				
				if(currentmenu == active_menu)
					SH_MenuControls();
			}
		}
	
		Menu_Borders(pos, bsize);
		title = Translate(title);
		skiptranslation = true;
		Menu_Title(title, pos, bsize);
		skiptranslation = false;
	}
	else
	{
		if(!active_menu.buf_translation)
		if(cvar("localize_enable"))
		{
			active_menu.buf_translation = CreateBuffer();
			InitializeTranslations(active_menu.buf_translation, active_menu.m_filename, false);
			Translate(title);
		}

	//	if(menu_initializing == 1)
	//	{
			active_menu.m_appearance = menu_appearance;
			active_menu.m_hidealpha = menu_hidealpha;
	//	}
	}
	
	if(border_appearance & TITLE_FOOTER)
		pos_y += border_size_y;
	else
		bsize_y += border_size_y;

	drawfont = body_font;		
	if(!menu_initializing)
		Menu_Body(pos, bsize);
	
	option_current = 0;
	option_pos_x = pos_x + border_size_x + body_margin_x;
	option_pos_y = pos_y + title_size_y+border_size_y + body_margin_y;	
	if(!option_size_x || option_size_x > bsize_x - border_size_x*2 - body_margin_x*2)
		option_size_x = bsize_x - border_size_x*2 - body_margin_x*2;	

	if(menu_initializing)
		drawsetcliparea(0, 0, 0, 0);
}

void Menu_End() = // call at the end of each menu
{
	if(currentmenu == active_menu)// || currentmenu.linkcontrolstomenu == active_menu)
		MenuControls(active_menu);

	option_pos_y += body_margin_y;
	
	if(active_menu)
	if(!menu_appearance & SIZE_MANUAL)
		active_menu.menusize_y = GetMenuSize(active_menu.menupos);	
		
	if(menu_initializing)
	{
		if(active_menu.menupos == POS_AUTO)
			active_menu.menupos = GetMenuPosition(active_menu.menusize);
		
		if(active_menu.menu_style & STYLE_STARTFROM_BOTTOMLEFT)
			active_menu.menupos_y -= active_menu.menusize_y;
	}
	
	if(LOCALIZE_GENERATING)
	{
		WriteTranslations(active_menu.buf_translation, active_menu.m_filename, false);
		ClearMenuData(active_menu);
	}
	
	skiptranslation				= false;
	viewingtextlist				= false;
	selectedtextlist			= false;
	option_current				= 0;
	input_current				= 0;
	slider_current				= 0;
	option_pos					= '0 0 0';

	lastimagesize = '0 0 0';
	lastimagepos = '0 0 0';
	active_image_pos = '0 0 0';	
	
	filetextline = 0;
	current_optionalt_up = 0;
	current_optionalt_down = 0;
	current_optionalt_left = 0;
	current_optionalt_right = 0;
	current_optionselection_horizontal = false;	
	
	optionnum_min = 0;
	optionnum_max = 0;	
	
	SliderRules = SUB_Null;
	
//	fontsize_multiplier = 0;
//	title_fontsize_base = '0 0 0';
//	body_fontsize_base = '0 0 0';
//	option_fontsize_base = '0 0 0';
//	input_fontsize_base = '0 0 0';
//	fontlinespacing = 0;
	
	if(menu_initializing)
	{
		drawresetcliparea();
		if(IsAssignedFunction(active_menu.DrawMenu))
		{
			menu_initializing = false;
			
		//	if(!menu_initializing)
			if(!(active_menu.menu_style & STYLE_SLOWOPEN))
			if(!LOCALIZE_GENERATING)
				active_menu.DrawMenu();
		}
	}
	
	if(menu_resetlanguagebuffers)
	{
		menu_resetlanguagebuffers = false;
		ResetLanguageBuffers();
	}
	
	menu_closing = false;
}

void SetDrawFunc(entity menu, void() func, float clearinput) =
{
	if(clearinput)
		ClearAllInputValues();
	active_menu.DrawMenu = func;
	menu_resetlanguagebuffers = true;
	
//	active_menu.menusize = '0 0 0';
//	active_menu.menu_style = active_menu.menu_style | STYLE_FASTCLOSE;
//	CloseMenu();
//	SetCurrentMenu(func);
}

float	BTTN_ROLL 		= 4;
float	BTTN_SLIDE		= 3;
float	BTTN_SUBMENU	= 2;
float	BTTN_MENU		= 1;

void Menu_Option(string text, string imagename, string imagename_highlight, void() func, float buttontype) =
// creates a button on the current menu line.
// buttontype specifies that the button should create a menu and use func as it's draw function (you can also open new menus manually with SetCurrentMenu)
{
	local float imagealpha;
	local string imagename_left, imagename_right;
	local vector startpos, imgsize, centerimgsize, centerimg_ofs, selectable_option_size;
	
	if(option_size_selectionbox != '0 0 0')
		selectable_option_size = option_size_selectionbox;
	else
		selectable_option_size = option_size;
	
//	SetFont(option_font);
	drawfont = option_font;

	lastimagesize = '0 0 0';
	lastimagepos = '0 0 0';
	active_image_pos = '0 0 0';

	imagename = option_image;
	imagename_left = option_image_left;
	imagename_right = option_image_right;
	
	if(!menu_initializing || LOCALIZE_GENERATING)
	{
		local vector pos, textcolor, imagecolor, bgcolor, outersize, innersize;
		local float selected, inbox, SOUNDTYPE;
		
		if(active_menu.user_current_option == option_current)
		{
			current_optionalt_up = optionalt_up;
			current_optionalt_down = optionalt_down;
			current_optionalt_left = optionalt_left;
			current_optionalt_right = optionalt_right;
			current_optionselection_horizontal = optionselection_horizontal;
		}

		outersize_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2;
		outersize_y = option_size_y;
		innersize = option_size;
		
		pos = AlignmentPos(option_pos, outersize, innersize, body_alignment, '0 0 0');

	//	if(EPISODE >= OPTION_EPISODE_MIN)
		if(option_current != -1)	
		if(!(active_menu.menu_style & STYLE_TOOLBAR) || ((active_menu.menu_style & STYLE_TOOLBAR) && active_menu.user_current_selection-1 - active_menu.skippedoptionslots != option_current))
		if(!dontclearbuttons)
		if(!arrowkeymovement)
	//	if(!(cl_buttondown[K_MOUSE1] && !(cl_button == K_MOUSE1 && !keyrepeating) && !activatebuttononmousedown))
		if(!(option_lastclick && option_lastclick != option_current+1))
		if(!(GameControl(CTRL_MENUBUTTON1, -1) && active_menu.user_current_option != option_current))
	//	if(active_menu == currentmenu || active_menu.linkcontrolstomenu == currentmenu)
		if(CursorInsideBox(pos, selectable_option_size_x, selectable_option_size_y))
			inbox = TRUE;
			
	//	if(EPISODE >= OPTION_EPISODE_MIN)	
		if((((active_menu == currentmenu
				|| (currentmenu	&& active_menu.linkcontrolstomenu == currentmenu))
			&& (inbox
				|| active_menu.user_current_option == option_current))
		|| (inbox
			&& active_menu.menu_style & STYLE_TOOLBAR
			&& !currentmenu.menu_style & STYLE_PRIORITY))
		&& !option_current_sendtobottomoflist)
		{
			if(GameControl(CTRL_MENUBUTTON1, -1))
		//	if(!activatebuttononmousedown)
				arrowkeymovement = true;
		
			selected = TRUE;
			
			if(active_menu.user_current_option != option_current)
				MenuSound(SOUND_MOUSEOVERCLICK);
			
			active_menu.user_current_option = option_current;
			if(active_menu.linkcontrolstomenu)
				active_menu.linkcontrolstomenu.user_current_option = option_current;
				
			if(EPISODE < OPTION_EPISODE_MIN)
			{
				textcolor = '0.3 0.3 0.3';
				imagecolor = '0.3 0.3 0.3';
				imagealpha = 0.8;
				bgcolor = '0 0 0';
			}		
			else
			{			
				textcolor = option_fontcolor_highlight;
				imagecolor = option_imagecolor_highlight;
				imagealpha = option_imagealpha_highlight;
				bgcolor = option_bgcolor_highlight;
			}
			
			imagename = imagename_highlight;
			imagename_left = option_image_left_highlight;
			imagename_right = option_image_right_highlight;
			
			if(inbox)
			if(GameControl(CTRL_MENUBUTTON1, 0))
			if(!keyrepeating)
				option_lastclick = option_current+1;
			
			if(EPISODE >= OPTION_EPISODE_MIN)	
			if(func && func != SUB_Null)
			if(
				(buttontype >= BTTN_SLIDE && (GameControl(CTRL_MENUNAVIGATELEFT, 0) || GameControl(CTRL_MENUNAVIGATERIGHT, 0)))
				|| (GameControl(CTRL_CONFIRM, 0) && (!active_input || active_vkb))
				|| (inbox && option_lastclick == option_current+1 && ((!activatebuttononmousedown && GameControl(CTRL_MENUBUTTON1, -1)) || (activatebuttononmousedown && GameControl(CTRL_MENUBUTTON1, 0))))
				)
			{
				if(allowoptionselection)
					active_menu.user_current_selection = option_current+1;
			
				if(collapsemenusonaction)
					EscapeMenuBranch(menu_count-2);
			
			//	if(buttontype == BTTN_ROLL)
			//		UseRollButton(func);
			//	else
			//	if(buttontype == BTTN_SLIDE)
			//
			//	else
				if(buttontype == BTTN_MENU)
				//	active_menu.DrawMenu = func;
					SetDrawFunc(active_menu, func, true);
				else
				{
					if(active_menu == pulldownmenu)
						ClosePulldownMenu();
				
					if(buttontype == BTTN_SUBMENU)
						SetCurrentMenu(func);
					else
					if(!(buttontype == BTTN_SLIDE && GameControl(CTRL_MENUBUTTON1, -1)))
						func();
				}
				
				if(buttontype != BTTN_SLIDE)
				{
					if(menubuttontype == MBT_BASIC)
						SOUNDTYPE = SOUND_BASICCLICK;
					else
					if(menubuttontype == MBT_CONFIRM)
						SOUNDTYPE = SOUND_CONFIRMCLICK;
					else
					if(menubuttontype == MBT_CANCEL)
						SOUNDTYPE = SOUND_CANCELCLICK;
				//	else
				//	if(menubuttontype == MBT_BACK)
				//		SOUNDTYPE = SOUND_BACKCLICK;
					else
					if(menubuttontype == MBT_QUIT)
						SOUNDTYPE = SOUND_QUITCLICK;					
						
					MenuSound(SOUNDTYPE);
				}
			//	cl_button = 0;
			}
			
			
			
		//	if(cl_button == K_ENTER || (inbox && cl_button == -K_MOUSE1))
		//	if(!buttontype)
		//		func();
		//	else
		//	if(func != SUB_Null)
		//		SetCurrentMenu(func);
		}
		else
		{
			if(EPISODE < OPTION_EPISODE_MIN)
			{
				textcolor = '0.2 0.2 0.2';
				imagecolor = '0.2 0.2 0.2';
				imagealpha = 0.8;
				bgcolor = '0 0 0';
			}		
			else
			{
				textcolor = option_fontcolor;
				imagecolor = option_imagecolor;
				imagealpha = option_imagealpha;
				bgcolor = option_bgcolor;
			}
		}
		
	//	outersize_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2;
	//	outersize_y = option_size_y;
	//	innersize = option_size;
		
	//	pos = AlignmentPos(option_pos, outersize, innersize, body_alignment, '0 0 0');
		
		if((option_appearance & BACKGROUND) || (selected && option_appearance & BACKGROUND_HIGHLIGHTONLY))
			drawfill(pos, option_size, bgcolor, option_bgalpha, option_bgflags);	
		
		Menu_Image_Bordered(pos, imagename_left, imagename_right, imagename, option_size, imagecolor, imagealpha, option_imageflags, option_appearance);
		
	/*	if(imagename != "")
		{
			startpos = pos;
			centerimgsize = option_size;
		
			if(imagename_left != "")
			{
				imgsize = drawgetimagesize(imagename_left);
				imgsize_x = imgsize_x * (option_size_y/imgsize_y);
				imgsize_y = option_size_y;
				centerimg_ofs_x = imgsize_x;
				centerimgsize_x -= imgsize_x;
				drawmenupic(pos, imagename_left, imgsize, imagecolor, imagealpha, option_imageflags, option_appearance);	
				pos_x += imgsize_x;
			}
			
			if(imagename_right != "")
			{
				imgsize = drawgetimagesize(imagename_right);
				imgsize_x = imgsize_x * (option_size_y/imgsize_y);
				imgsize_y = option_size_y;
				centerimgsize_x -= imgsize_x;
				pos_x = startpos_x + option_size_x - imgsize_x;
				drawmenupic(pos, imagename_right, imgsize, imagecolor, imagealpha, option_imageflags, option_appearance);
			}
			
			pos_x = startpos_x + centerimg_ofs_x;
			drawmenupic(pos, imagename, centerimgsize, imagecolor, imagealpha, option_imageflags, option_appearance);
			pos = startpos;
		}*/

		if(active_menu.user_current_selection-1 - active_menu.skippedoptionslots == option_current)
		if(strlen(option_image_selected) > 0)	
		{
			imagename = option_image_selected;	
			imgsize = drawgetimagesize(imagename);
			drawmenupic(pos + option_image_selected_offset, imagename, imgsize, option_imagecolor, option_imagealpha, option_imageflags, option_appearance);
		}
		
		if(text != "")
		{
//			text = FitStringToWidth(text, option_size_x - option_textbordersize_x*2, option_fontsize);
//			text = substring(text, 0, floor((option_size_x - option_textbordersize_x*2)/option_fontsize_x));
//			pos = TextAlignmentPos(text, pos, option_size, option_fontsize, option_textalignment, option_textbordersize);
//			drawfill(pos, option_fontsize, '1 0 0', 1, 0);	
			DrawString_MenuContents(pos, text, option_fontsize, textcolor, option_fontalpha, option_fontflags, option_size, option_textbordersize, option_textalignment);
		//	drawstring(pos, text, option_fontsize, textcolor, option_fontalpha, option_fontflags);
		}
	}		
			
	option_pos_y += option_spacing+option_size_y;
	
	if(active_menu == currentmenu)
	if(option_current_sendtobottomoflist)
		active_menu.user_current_option = option_current;	
	
	if(!option_off)
		option_current++;
		
	allowoptionselection = false;
	collapsemenusonaction = false;
	menubuttontype = 0;	
	optionalt_up = 0;
	optionalt_down = 0;
	optionalt_left = 0;
	optionalt_right = 0;	
//	optionselection_horizontal = false;	

//	SetFont(body_font);
	drawfont = body_font;
}

float Roll_Controls(float currentslot, float totalslots) =
{
	if(GameControl(CTRL_MENUNAVIGATELEFT, 0))
		currentslot -= 1;
	else
		currentslot += 1;
		
	if(currentslot >= totalslots)
		currentslot = 0;
	else
	if(currentslot < 0)
		currentslot = totalslots-1;
		
	return currentslot;
}

float GetCurrentValueSlot_vec(vector currentval, float totalslots, vector(float f) getvalfunc) =
{
	local float currentslot;

	for(currentslot = 0; currentslot < totalslots; currentslot++)
	{
		if(currentval == getvalfunc(currentslot))
			break;
	}

	return currentslot;
}

vector GetRollValue_vec(vector currentval, float totalslots, vector(float f) getvalfunc) =
{
	local float currentslot;

//	for(currentslot = 0; currentslot < totalslots; currentslot++)
//	{
//		if(currentval == getvalfunc(currentslot))
//			break;
//	}

	currentslot = GetCurrentValueSlot_vec(currentval, totalslots, getvalfunc);
	currentslot = Roll_Controls(currentslot, totalslots);
	currentval = getvalfunc(currentslot);
	
	return currentval;
}

float GetCurrentValueSlot_float(float currentval, float totalslots, float(float f) getvalfunc) =
{
	local float currentslot;

	for(currentslot = 0; currentslot < totalslots; currentslot++)
	{
		if(currentval == getvalfunc(currentslot))
			break;
	}

	return currentslot;
}

float GetRollValue_float(float currentval, float totalslots, float(float f) getvalfunc) =
{
	local float currentslot;

//	for(currentslot = 0; currentslot < totalslots; currentslot++)
//	{
//		if(currentval == getvalfunc(currentslot))
//			break;
//	}

	currentslot = GetCurrentValueSlot_float(currentval, totalslots, getvalfunc);
	currentslot = Roll_Controls(currentslot, totalslots);
	currentval = getvalfunc(currentslot);
	
	return currentval;
}

void Menu_Roll(string text, string imagename, string imagename_highlight, void() func) =
{
	Menu_Option(text, imagename, imagename_highlight, func, BTTN_ROLL);
	
	// draw roller status here
}

float GetSliderValue() = {	return slider_min + slider_currentpos*slider_incrementsize;	}

void Slider_Controls() =
{
	local float svalue;
	
	if(GameControl(CTRL_MENUNAVIGATELEFT, 0))
		slider_currentpos -= 1;
	else
		slider_currentpos += 1;
		
	if(slider_currentpos >= slider_increments)
		slider_currentpos = 0;
	else
	if(slider_currentpos < 0)
		slider_currentpos = slider_increments-1;

	svalue = GetSliderValue();
	
	if(strlen(slider_cvar) > 0)
		cvar_set(slider_cvar, ftos(svalue));
		
	if(IsAssignedFunction(SliderRules))
		SliderRules();
}

void Menu_Slider(string text, string imagename, string imagename_highlight, float svalue, string cvarname, float value_min, float value_max, float num_increments, float sliderwidth, float readout) =
{
	local vector pos, boxpos, sboxsize, slider_imagesize, sliderhandle_imagesize, readoutsize, slidercolor, sliderhandlecolor, textcolor;
	local float svalue_start, slider_border, slider_notchsize, mousedrag, imagealpha, sliderhandlealpha;

	slider_current++;
	
	if(strlen(cvarname) > 0)
	{
		svalue = cvar(cvarname);	
		slider_cvar = zonecpy(slider_cvar, cvarname);
	}
		
	svalue_start = svalue;
	
	slider_min = value_min;
//	slider_max = value_max;
	slider_increments = num_increments;
	slider_incrementsize = (value_max-slider_min)/(slider_increments-1);
	slider_currentpos = (svalue-slider_min)/slider_incrementsize;
	
	Menu_Option(text, imagename, imagename_highlight, Slider_Controls, BTTN_SLIDE);

	pos = GetLastLinePos();
	pos_x += option_sliderspacing;
	
//	slider_border = 2;
	slider_imagesize = drawgetimagesize(option_sliderimage);
	
	if(option_slider_alignment_y == -1)
		pos_y += option_size_y - slider_imagesize_y;	
	
//	slider_imagesize = * (option_size_y/20);
//	if(sliderwidth)
//		slider_imagesize_x = sliderwidth;
	sliderhandle_imagesize = drawgetimagesize(option_sliderhandleimage);//'10 20 0' * (option_size_y/20);
//	slider_notchsize = (slider_imagesize_x-slider_border*2)/(slider_increments-1);

	if(sliderwidth)
	{
		sliderhandle_imagesize = sliderhandle_imagesize*(sliderwidth/slider_imagesize_x);	
		slider_imagesize = slider_imagesize*(sliderwidth/slider_imagesize_x);
	}

	boxpos = pos;
//	boxpos_x += slider_border + sliderhandle_imagesize_x*0.5;
	sboxsize = slider_imagesize;
	sboxsize_x -= slider_border*2 + sliderhandle_imagesize_x;

	slider_notchsize = sboxsize_x/(slider_increments-1);
	boxpos_x += slider_border + sliderhandle_imagesize_x*0.5 - slider_notchsize*0.5;
	sboxsize_x += slider_notchsize;

	
	//	drawfill(boxpos, slider_imagesize, '1 0 0', 0.25, 0);
	
//	mousedrag = cl_buttondown[K_MOUSE1];
	
	if(GameControl(CTRL_MENUBUTTON1, -1))
		slider_active = 0;
//		slider_currentcvar = freezone(slider_currentcvar);	
	
	if(EPISODE >= OPTION_EPISODE_MIN)
	if(GameControl(CTRL_MENUBUTTON1, 1) || GameControl(CTRL_MENUBUTTON1, -1))// || mousedrag)
	if(!arrowkeymovement)
	if(active_menu == currentmenu)
	{
		if(GameControl(CTRL_MENUBUTTON1, 0) && !keyrepeating)
		if(CursorInsideBox(pos, slider_imagesize_x, option_size_y))
			slider_active = slider_current;
//			slider_currentcvar = zonecpy(slider_currentcvar, slider_cvar);
	
//		if(slider_currentcvar == slider_cvar)
		if(slider_active == slider_current)
		{
			if(mousepos_x <= boxpos_x)//+slider_border)
			{
				slider_currentpos = 0;
				svalue = slider_min;		
			}
			else
			if(mousepos_x >= boxpos_x+sboxsize_x)//slider_imagesize_x-slider_border)
			{
				slider_currentpos = slider_increments-1;
				svalue = value_max;
			}
			else
			{
				slider_currentpos = mousepos_x - boxpos_x;// - (sliderhandle_imagesize_x - slider_notchsize)*0.5;
				slider_currentpos = floor(slider_currentpos/slider_notchsize);
				svalue = slider_min + slider_currentpos*slider_incrementsize;			
			}

			if(svalue_start != svalue)
//			if(cvar(slider_cvar) != svalue)
			{
				if(strlen(cvarname) > 0)
					cvar_set(slider_cvar, ftos(svalue));
				if(IsAssignedFunction(SliderRules))
					SliderRules();
			}
		}		
	}

	if(strlen(cvarname) > 0)
		slider_cvar = freezone(slider_cvar);
	
	if(active_menu.user_current_option == option_current-1)
	{
		if(EPISODE < OPTION_EPISODE_MIN)
		{
				slidercolor = '0.3 0.3 0.3';
				sliderhandlecolor = '0.3 0.3 0.3';
				imagealpha = 0.8;
				sliderhandlealpha = 0.8;
				textcolor = '0.3 0.3 0.3';
		}		
		else
		{	
			imagealpha = option_slideralpha_highlight;
			slidercolor = option_slidercolor_highlight;
			sliderhandlealpha = option_sliderhandlealpha_highlight;
			sliderhandlecolor = option_sliderhandlecolor_highlight;	
			textcolor = option_slidercolor;			
		}
	}
	else
	{
		if(EPISODE < OPTION_EPISODE_MIN)
		{
				slidercolor = '0.2 0.2 0.2';
				sliderhandlecolor = '0.2 0.2 0.2';
				imagealpha = 0.8;
				sliderhandlealpha = 0.8;
				textcolor = '0.2 0.2 0.2';
		}
		else
		{	
			imagealpha = option_slideralpha;
			slidercolor = option_slidercolor;
			sliderhandlealpha = option_sliderhandlealpha;
			sliderhandlecolor = option_sliderhandlecolor;
			textcolor = option_slidercolor;
		}
	}		

	drawpic(pos, option_sliderimage, slider_imagesize, slidercolor, imagealpha, option_imageflags);

	if(EPISODE >= OPTION_EPISODE_MIN)
	{
		pos_x += slider_border+(slider_currentpos*slider_notchsize);//-sliderhandle_imagesize_x*0.5;
		drawpic(pos, option_sliderhandleimage, sliderhandle_imagesize, sliderhandlecolor, sliderhandlealpha, option_imageflags);
	}
	
	if(readout)
	{
		if(readout < 0)
		{
			readout = readout*-1;
			svalue = svalue*-1;
		}
	
		local string readouttext;
		pos = GetLastLinePos();
		pos_x += option_size_selectionbox_x + 4;
	//	pos_x += option_sliderinfospacing ;
	
		if(ReadoutRules && ReadoutRules != SUB_Null)
			readouttext = ReadoutRules(svalue);
		else
			readouttext = ftos(svalue);
	
		readouttext = substring(readouttext, 0, readout);
		readoutsize_x = stringwidth(readouttext, false, option_slider_fontsize);
		readoutsize_y = option_size_y;
		pos = TextAlignmentPos(readouttext, pos, readoutsize, option_slider_fontsize, '0 0 0', '0 0 0');
		drawstring(pos, readouttext, option_slider_fontsize, textcolor, option_fontalpha, option_fontflags);	
	}
}

// a short version of Menu_Option for buttons with text
void Menu_Option_Text(string text, void() func) =
{	Menu_Option(text, option_image, option_image_highlight, func, 0);	}

void Menu_Option_Text_Confirm(string text, void() func) =
{	menubuttontype = MBT_CONFIRM;	Menu_Option_Text(text, func);	}

void Menu_Option_Text_Cancel(string text, void() func) =
{	menubuttontype = MBT_CANCEL;	Menu_Option_Text(text, func);	}

//void Menu_Option_Text_Back(string text, void() func) =
//{	menubuttontype = MBT_BACK;	Menu_Option_Text(text, func);	}


// a short version of Menu_Option for buttons with images
void Menu_Option_Image(string imagename, string imagename_highlight, void() func) =
{	Menu_Option("", imagename, imagename_highlight, func, 0);	}

void Menu_Option_Image_Confirm(string imagename, string imagename_highlight, void() func) =
{	menubuttontype = MBT_CONFIRM;	Menu_Option_Image(imagename, imagename_highlight, func);	}

void Menu_Option_Image_Cancel(string imagename, string imagename_highlight, void() func) =
{	menubuttontype = MBT_CANCEL;	Menu_Option_Image(imagename, imagename_highlight, func);	}

//void Menu_Option_Image_Back(string imagename, string imagename_highlight, void() func) =
//{	menubuttontype = MBT_BACK;	Menu_Option_Image(imagename, imagename_highlight, func);	}

// changes the current menu's draw function (.DrawMenu) and keeps all properties saved on the menu
void Menu_CallMenu_Text(string text, void() func) =
{	Menu_Option(text, option_image, option_image_highlight, func, BTTN_MENU);	}

void Menu_CallMenu_Text_Confirm(string text, void() func) =
{	menubuttontype = MBT_CONFIRM;	Menu_CallMenu_Text(text, func);	}

void Menu_CallMenu_Text_Cancel(string text, void() func) =
{	menubuttontype = MBT_CANCEL;	Menu_CallMenu_Text(text, func);	}

//void Menu_CallMenu_Text_Back(string text, void() func) =
//{	menubuttontype = MBT_BACK;	Menu_CallMenu_Text(text, func);	}


// changes the current menu's draw function (.DrawMenu) and keeps all properties saved on the menu
void Menu_CallMenu_Image(string imagename, string imagename_highlight, void() func) =
{	Menu_Option("", imagename, imagename_highlight, func, BTTN_SUBMENU);	}

void Menu_CallMenu_Image_Confirm(string imagename, string imagename_highlight, void() func) =
{	menubuttontype = MBT_CONFIRM;	Menu_CallMenu_Image(imagename, imagename_highlight, func);	}

void Menu_CallMenu_Image_Cancel(string imagename, string imagename_highlight, void() func) =
{	menubuttontype = MBT_CANCEL;	Menu_CallMenu_Image(imagename, imagename_highlight, func);	}

//void Menu_CallMenu_Image_Back(string imagename, string imagename_highlight, void() func) =
//{	menubuttontype = MBT_BACK;	Menu_CallMenu_Image(imagename, imagename_highlight, func);	}


// draws a text button that creates new menu using func as it's draw function
void Menu_CallSubMenu_Text(string text, void() func) =
{	Menu_Option(text, option_image, option_image_highlight, func, BTTN_SUBMENU);	}

void Menu_CallSubMenu_Text_Confirm(string text, void() func) =
{	menubuttontype = MBT_CONFIRM;	Menu_CallSubMenu_Text(text, func);	}

void Menu_CallSubMenu_Text_Cancel(string text, void() func) =
{	menubuttontype = MBT_CANCEL;	Menu_CallSubMenu_Text(text, func);	}

//void Menu_CallSubMenu_Text_Back(string text, void() func) =
//{	menubuttontype = MBT_BACK;	Menu_CallSubMenu_Text(text, func);	}


// draws an image button that creates a new menu using func as it's draw function
void Menu_CallSubMenu_Image(string imagename, string imagename_highlight, void() func) =
{	Menu_Option("", imagename, imagename_highlight, func, BTTN_SUBMENU);	}

void Menu_CallSubMenu_Image_Confirm(string imagename, string imagename_highlight, void() func) =
{	menubuttontype = MBT_CONFIRM;	Menu_CallSubMenu_Image(imagename, imagename_highlight, func);	}

void Menu_CallSubMenu_Image_Cancel(string imagename, string imagename_highlight, void() func) =
{	menubuttontype = MBT_CANCEL;	Menu_CallSubMenu_Image(imagename, imagename_highlight, func);	}

//void Menu_CallSubMenu_Image_Back(string imagename, string imagename_highlight, void() func) =
//{	menubuttontype = MBT_BACK;	Menu_CallSubMenu_Image(imagename, imagename_highlight, func);	}


void Menu_Roll_Text(string text, void() func) =
{	Menu_Option(text, option_image, option_image_highlight, func, BTTN_ROLL);	}

void Menu_Roll_Image(string imagename, string imagename_highlight, void() func) =
{	Menu_Option("", imagename, imagename_highlight, func, BTTN_ROLL);	}

void Menu_Slider_Simple(float svalue, string cvarname, float value_min, float value_max, float num_increments, float sliderwidth) =
{	Menu_Slider("", option_image, option_image_highlight, svalue, cvarname, value_min, value_max, num_increments, sliderwidth, false);	}

void Menu_Slider_Text(string text, float svalue, string cvarname, float value_min, float value_max, float num_increments, float readoutlen) =
{	Menu_Slider(text, option_image, option_image_highlight, svalue, cvarname, value_min, value_max, num_increments, 0, readoutlen);	}

void Menu_Slider_NoReadout_Text(string text, float svalue, string cvarname, float value_min, float value_max, float num_increments) =
{	Menu_Slider(text, option_image, option_image_highlight, svalue, cvarname, value_min, value_max, num_increments, 0, false);	}

void Menu_Slider_Image(string imagename, string imagename_highlight, float svalue, string cvarname, float value_min, float value_max, float num_increments, float sliderwidth) =
{	Menu_Slider("", imagename, imagename_highlight, svalue, cvarname, value_min, value_max, num_increments, sliderwidth, true);	}

// draws text on the current menu line
void Menu_TextPrint(string text, vector textalignment) = 
{
	local vector textcolor;

	if((!menu_initializing && !menu_closing) || LOCALIZE_GENERATING)
	{
		local vector pos, outersize;
		
		if(textalignment_x)
			outersize_x = option_size_x;//active_menu.menusize_x - border_size_x*2 - body_margin_x*2;
		else
			outersize_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2;
		outersize_y = option_size_y;
		
	//	if(!LOCALIZE_GENERATING)
	//		text = FitStringToWidth(text, outersize_x, body_fontsize);
		
	//	option_fontsize_old = option_fontsize;
	//	if(strlen(text) > 0 && option_size_x - option_textbordersize_x*2 > 0)
	//	while(stringwidth(text, false, option_fontsize) > option_size_x - option_textbordersize_x*2)
	//		option_fontsize = option_fontsize - option_fontsize_old*0.01;
		
//		pos = TextAlignmentPos(text, option_pos, outersize, body_fontsize, textalignment, body_textbordersize);
//		drawfill(pos, body_fontsize, '1 0 1', 1, 0);

		if(EPISODE < OPTION_EPISODE_MIN)
			textcolor = '0.3 0.3 0.3';
		else
			textcolor = body_fontcolor;

		DrawString_MenuContents(option_pos, text, body_fontsize, textcolor, body_fontalpha, body_fontflags, outersize, body_textbordersize, textalignment);
	//	drawstring(pos, text, body_fontsize, body_fontcolor, body_fontalpha, body_fontflags);
	}
}

void Menu_Text(string text) =	{	Menu_TextPrint(text, body_textalignment);	}

void Menu_AlignedText(string text, float ALIGN) =
{
	local vector textalignment;

	if(ALIGN == ALIGN_TOPLEFT)
		textalignment = '-1 1 0';
	else
	if(ALIGN == ALIGN_LEFT)
		textalignment_x = -1;
	else
	if(ALIGN == ALIGN_RIGHT)
		textalignment_x = 1;
	
	Menu_TextPrint(text, textalignment);
}

void Menu_Image_Bordered(vector pos, string imgleft, string imgright, string imgcenter, vector imgboxsize, vector imgcolor, float imgalpha, float imgflags, float imgappearance) =
{
	local vector startpos, imgsize, centerimg_ofs, centerimgsize;
	
	if(imgboxsize == SIZE_AUTO)
		imgboxsize = option_size;	
	
	startpos = pos;
	centerimgsize = imgboxsize;	
	
	if(imgleft != "")
	{
		imgsize = drawgetimagesize(imgleft);
		imgsize_x = imgsize_x * (imgboxsize_y/imgsize_y);
		imgsize_y = imgboxsize_y;
		centerimg_ofs_x = imgsize_x;
		centerimgsize_x -= imgsize_x;
		drawmenupic(pos, imgleft, imgsize, imgcolor, imgalpha, imgflags, imgappearance);	
		pos_x += imgsize_x;
	}
	
	if(imgright != "")
	{
		imgsize = drawgetimagesize(imgright);
		imgsize_x = imgsize_x * (imgboxsize_y/imgsize_y);
		imgsize_y = imgboxsize_y;
		centerimgsize_x -= imgsize_x;
		pos_x = startpos_x + imgboxsize_x - imgsize_x;
		drawmenupic(pos, imgright, imgsize, imgcolor, imgalpha, imgflags, imgappearance);
	}
	
	if(imgcenter != "")
	{
		pos_x = startpos_x + centerimg_ofs_x;
		drawmenupic(pos, imgcenter, centerimgsize, imgcolor, imgalpha, imgflags, imgappearance);
	}
}

void Menu_Image_Bordered_Body(string imgleft, string imgright, string imgcenter, vector imgboxsize) =
{
	local vector outersize, pos;

	if(imgboxsize == SIZE_AUTO)
		imgboxsize = option_size;
	
	outersize_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2;
	outersize_y = imgboxsize_y;
	pos = AlignmentPos(option_pos, outersize, imgboxsize, body_alignment, '0 0 0');

	Menu_Image_Bordered(pos, imgleft, imgright, imgcenter, imgboxsize, body_imagecolor, body_imagealpha, body_imageflags, body_appearance);
}

// draws a stretched image on the current menu line
void Menu_Image_Stretch(string image, vector bsize, vector offset) =
{
	local vector pos, imgsize, outersize, innersize, active_image_difference;
	local float differencefromorigional;
	
	imgsize = drawgetimagesize(image);

	outersize_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2;
	
	if(bsize == SIZE_DEFAULT)
		bsize = imgsize;//drawgetimagesize(image);
	else
	if(bsize == SIZE_AUTO)
		bsize = option_size;
	else
	if(bsize == SIZE_FITWIDTH)
		bsize = bsize*(outersize_x/bsize_x);
	else
	if(!bsize_y)
	{
		differencefromorigional = bsize_x/imgsize_x;
		bsize_y = imgsize_y*differencefromorigional;
	}
	
	if(bsize_x > outersize_x)
		bsize = bsize*(outersize_x/bsize_x);	

//	if(active_image_pos == '0 0 0')
//	{
		if(body_alignment_x == 1)
		{
			active_image_pos_x = option_pos_x + (active_menu.menusize_x-border_size_x*2-body_margin_x*2)-bsize_x;
			active_image_pos_y = option_pos_y;
		}
		else
			active_image_pos = option_pos;
//	}

	if(body_alignment_x == 1)
		active_image_difference_x = outersize_x - bsize_x;
	else
	if(body_alignment_x == -1)
		active_image_difference_x = active_image_pos_x - option_pos_x;
	
	outersize -= active_image_difference;
		
	innersize_x = bsize_x;
	pos = AlignmentPos(active_image_pos, outersize, innersize, body_alignment, '0 0 0')+offset;

	if(!menu_initializing)
	{	
		drawfill(pos, bsize, body_imagebgcolor, body_imagebgalpha, body_imagebgflags);
		drawpic(pos, image, bsize, body_imagecolor, body_imagealpha, body_imageflags);
	}

	if(body_alignment_x == 1)
		active_image_pos_x -= bsize_x+option_spacing;	
	else
	if(body_alignment_x == -1)
		active_image_pos_x += bsize_x+option_spacing;	

	lastimagepos = pos;
	lastimagesize = bsize;
//	option_pos_y += size_y+option_spacing;
}

// draws a tiled image on the current menu line
void Menu_Image_Tile(string image, vector bsize, vector offset) =
{
	if(bsize == SIZE_DEFAULT)
		bsize = drawgetimagesize(image);
	else
	if(bsize == SIZE_AUTO)
		bsize = option_size;

	if(!menu_initializing)
	{
		drawfill(option_pos+offset, bsize, body_imagebgcolor, body_imagebgalpha, body_imagebgflags);
		drawmenupic(option_pos+offset, image, bsize, body_imagecolor, body_imagealpha, body_imageflags, body_appearance);
	}
}

/*void Menu_Image_TextOverlay(string text, vector malignment) = 
{
	if(!menu_initializing)
	{
		local vector pos;
		pos = TextAlignmentPos(text, lastimagepos, lastimagesize, body_fontsize, malignment, body_textbordersize);
		drawstring(pos, text, body_fontsize, body_fontcolor, body_fontalpha, body_fontflags);
	}
}*/

void Menu_InputWarnings_Local() =
{
	local string s, filename, str_invalidinput, str_invalidname, str_profileexists, str_campaignexists, str_invalidpassword;
	local float translate;
	
	filename = __FUNC__;
	
	translate = skiptranslation;
	skiptranslation = false;
	
	buf_localizemenuinputwarnings = InitializeNonstandardTranslations(buf_localizemenuinputwarnings, filename, true);
	str_invalidinput	= Localize("Invalid input.", buf_localizemenuinputwarnings);
	str_invalidname		= Localize("Invalid name.", buf_localizemenuinputwarnings);
	str_profileexists	= Localize("Profile already exists.", buf_localizemenuinputwarnings);
	str_campaignexists	= Localize("Campaign already exists.", buf_localizemenuinputwarnings);
	str_invalidpassword = Localize("Invalid password.", buf_localizemenuinputwarnings);
	WriteNonstandardTranslations(buf_localizemenuinputwarnings, filename, false, true);

	switch(active_menu.bodystring)
	{
		case "INVALIDINPUT":	s = str_invalidinput;		break;
		case "INVALIDNAME":		s = str_invalidname;		break;
		case "PROFILEEXISTS":	s = str_profileexists;		break;
		case "CAMPAIGNEXISTS":	s = str_campaignexists;		break;
		case "INVALIDPASSWORD":	s = str_invalidpassword;	break;
	}
	
	skiptranslation = true;
	if(s)
		Menu_Text(s);
	skiptranslation = false;
	BR();
	
	skiptranslation = translate;
}

void Menu_InputWarnings() =
{
	if(LOCALIZE_GENERATING)
		return;
		
	Menu_InputWarnings_Local();
}

float InvalidInputString(float strindex) =
{
	local string s;

	s = GetBufferString(active_menu.buf_list, strindex);
	
	if(strlen(s) <= 0)
	{
		active_menu.bodystring = "INVALIDINPUT";
		return true;
	}
		
	return false;
}

void Menu_Input(vector inputboxsize, string defualtinputstr, float ALIGN, float aligntype, void() func, float INPUTTYPE) =
{
	local vector startpos, pos;
	local string s;
//	Menu_Text(inputtitle);
	
//	startpos = option_pos;
//	option_pos_x += 150;

//	SetFont(input_font);
	drawfont = input_font;

	input_current++;	
	
	s = defualtinputstr;
	
	if(!active_menu.buf_list)
		active_menu.buf_list = CreateBuffer();

		if(strlen(s) > 0)
		if(GetBufferSize(active_menu.buf_list) < input_current+1)
		{
			SetBufferString(active_menu.buf_list, input_current-1, s);
			SetBufferString(active_menu.buf_list, input_current, "TAIL");
			
			if(input_current == active_input)
			//	input_cursorpos = strlen(s);
				UpdateInputCursorPos(strlen(s));
		}
//	}
	
	s = GetBufferString(active_menu.buf_list, input_current-1);
	
//	if(ALIGN == ALIGN_RIGHT)
//	{
		local vector o_boxsize, v_align;

		o_boxsize_x = inputboxsize_x;
		o_boxsize_y = body_fontsize_y + body_fontsize_y*0.4;
		v_align_x = ALIGN;
		pos = BoxAlignmentPos(option_pos, o_boxsize, v_align, aligntype, '0 0 0');
	//	if(aligntype == 1)
	//		pos_x += option_spacing + border_size_x;
//	}
//	else
//		pos = option_pos;
		
	s = DrawInputBox(pos, inputboxsize, INPUTTYPE, s, func, false);
	
	if(cl_button_ucs || cl_button > 0)
		SetBufferString(active_menu.buf_list, input_current-1, s);
	
//	option_pos = startpos;
	if(!inputboxsize_y)
		option_pos_y += option_size_y + option_spacing;
	else
		option_pos_y += inputboxsize_y + option_spacing;
		
//	option_current++;

//	SetFont(body_font);
	drawfont = body_font;
}

void Menu_Input_Text(vector inputboxsize, string defualtinputstr, float ALIGN, float aligntype, void() func) =
{	Menu_Input(inputboxsize, defualtinputstr, ALIGN, aligntype, func, INPUTTYPE_TEXT);		}

void Menu_Input_All(vector inputboxsize, string defualtinputstr, float ALIGN, float aligntype, void() func) =
{	Menu_Input(inputboxsize, defualtinputstr, ALIGN, aligntype, func, INPUTTYPE_ALL);		}

void Menu_IncreaseValue() =
{
	local string s;
	local float f;
	
	s = GetBufferString(active_menu.buf_list, input_current-1);
	f = stof(s);
	
	if(!(numericalincrementhasmax && f >= numericalincrementmax))
	if(keyrepeating)
		f += 5;
	else
		f++;
	
	if(numericalincrementhasmax)
	if(f > numericalincrementmax)
		f = numericalincrementmax;
	
	s = ftos(f);
	SetBufferString(active_menu.buf_list, input_current-1, s);
}

void Menu_DecreaseValue() =
{
	local string s;
	local float f;
	
	s = GetBufferString(active_menu.buf_list, input_current-1);
	f = stof(s);
	
	if(!(numericalincrementhasmin && f <= numericalincrementmin))
	if(keyrepeating)
		f -= 5;
	else
		f -= 1;
	
	if(numericalincrementhasmin)
	if(f < numericalincrementmin)
		f = numericalincrementmin;
	
	s = ftos(f);
	SetBufferString(active_menu.buf_list, input_current-1, s);
}

void FixNumericalMinMaxValue() =
{
	local string s;
	local float f;

	s = GetBufferString(active_menu.buf_list, input_current-1);	
	f = stof(s);
	
	if(numericalincrementhasmax)
	if(f > numericalincrementmax)
		f = numericalincrementmax;
		
	if(numericalincrementhasmin)
	if(f < numericalincrementmin)
		f = numericalincrementmin;

	s = ftos(f);
	SetBufferString(active_menu.buf_list, input_current-1, s);	
}

void Menu_Input_Numerical(vector inputboxsize, string defaultinputstr, float incrementcontrols, float hasmin, float hasmax, float nummin, float nummax, void() func) =
{
	local float translate, incrementbuttonwidth, tms_body_alignment_horizontal, tms_option_size_width, tms_option_size_height;
	local string s;
	local vector oldoptionpos, tms_option_fontsize;

	translate = skiptranslation;
	skiptranslation = true;
	
	incrementbuttonwidth = 20;	
	
//	TempMenuSetting_body_alignment_horizontal(-1);
	tms_body_alignment_horizontal = body_alignment_x;
	body_alignment_x = -1;
//	TempMenuSetting_option_size_width(option_size_x - incrementbuttonwidth - option_spacing);
	tms_option_size_width = option_size_x;
	option_size_x = option_size_x - incrementbuttonwidth - option_spacing;

	Menu_Input(inputboxsize, defaultinputstr, ALIGN_RIGHT, 1, func, INPUTTYPE_NUMERICAL);

	oldoptionpos = option_pos;
	option_pos_x += option_size_x + option_spacing;	
	
//	RestoreMenuSetting_body_alignment_horizontal();
//	RestoreMenuSetting_option_size_width();
	option_size_x = tms_option_size_width;
	
	option_pos_y -= option_spacing+option_size_y;
	
//	TempMenuSetting_body_alignment_horizontal(1);
//	TempMenuSetting_option_size_width(incrementbuttonwidth);
	tms_option_size_width = option_size_x;
	option_size_x = incrementbuttonwidth;
//	TempMenuSetting_option_size_height(option_size_y*0.5-option_spacing*0.5);
	tms_option_size_height = option_size_y;
	option_size_y = option_size_y*0.5-option_spacing*0.5;
//	TempMenuSetting_option_fontsize(incrementcontrol_fontsize);
	tms_option_fontsize = option_fontsize;
	option_fontsize = incrementcontrol_fontsize;
	
	numericalincrementhasmin = hasmin;
	numericalincrementhasmax = hasmax;
	numericalincrementmin = nummin;
	numericalincrementmax = nummax;

	FixNumericalMinMaxValue();	
	
	activatebuttononmousedown = true;
	Menu_Option_Text("+", Menu_IncreaseValue);
	Menu_Option_Text("-", Menu_DecreaseValue);
	activatebuttononmousedown = false;
	numericalincrementhasmin = 0;
	numericalincrementhasmax = 0;
	numericalincrementmin = 0;
	numericalincrementmax = 0;
	
//	option_pos_x -= inputboxsize_x + option_spacing;
	option_pos_x = oldoptionpos_x;
	
//	RestoreMenuSetting_body_alignment_horizontal();
	body_alignment_x = tms_body_alignment_horizontal;
//	RestoreMenuSetting_option_size_width();	
	option_size_x = tms_option_size_width;
//	RestoreMenuSetting_option_size_height();
	option_size_y = tms_option_size_height;
//	RestoreMenuSetting_option_fontsize();
	option_fontsize = tms_option_fontsize;
	
	skiptranslation = translate;
}

void Menu_Input_NumericalIncrement(string optitle, float num, void() func) =
{
	local float time_minutes, time_seconds, option_colstart;
	local vector input_size;

	Menu_AlignedText(optitle, ALIGN_LEFT);	
	
	input_size_x = input_fontsize_x*2+4;
	
//	TempMenuSetting_option_size_width(option_size_x - input_size_x - 20);
	inputstring_shift_disable = true;
	Menu_Input_Numerical(input_size, ftos(num), true, true, true, 0, 99, func);
//	RestoreMenuSetting_option_size_width();	
	inputstring_shift_disable = false;
}

void Menu_Input_Time(string optitle, float time_total, void() func) =
{
	local float translate, time_minutes, time_seconds, option_colstart;
	local vector input_size;

	Menu_AlignedText(optitle, ALIGN_LEFT);	
	
	translate = skiptranslation;
	skiptranslation = true;
	
	input_size_x = input_fontsize_x*2+4;

	time_minutes = floor(time_total/60);
	time_seconds = time_total - time_minutes*60;
	
	TempMenuSetting_option_size_width(option_size_x - input_size_x - 20 - option_spacing*3 - body_fontsize_x);
	inputstring_shift_disable = true;
	Menu_Input_Numerical(input_size, ftos(time_minutes), true, true, true, 0, 99, func);
	RestoreMenuSetting_option_size_width();	
	option_pos = GetLastLinePos();	

	option_colstart = option_pos_x;
	option_pos_x += option_size_x - input_size_x - 20 - option_spacing*4 - body_fontsize_x;
	Menu_AlignedText(":", ALIGN_LEFT);
	option_pos_x = option_colstart;
	
	Menu_Input_Numerical(input_size, ftos(time_seconds), true, true, true, 0, 59, func);	
	inputstring_shift_disable = false;
	
	skiptranslation = translate;
}

float GetOffsetForCenteredHoriontalListButtons(float numbuttons, float buttonwidth) = {	return (active_menu.menusize_x - border_size_x*2 - body_margin_x*2)*0.5 - ((buttonwidth+option_spacing)*numbuttons - option_spacing)*0.5;	}

void HorizontalListButton(float xpos, float opt_width, string text, void() func, float altoption_up, float altoption_down, float altoption_left, float altoption_right, float BUTTONTYPE) =
{
	local float t_width;
	local vector t_option_pos;

	optionalt_up = altoption_up;
	optionalt_down = altoption_down;
	optionalt_left = altoption_left;
	optionalt_right = altoption_right;	
	optionselection_horizontal = true;

	t_option_pos = option_pos;
	option_pos_x += xpos;
	t_width = option_size_x;
	option_size_x = opt_width;
	menubuttontype = BUTTONTYPE;
	Menu_Option_Text(text, func);
	option_size_x = t_width;
	option_pos = t_option_pos;
	optionselection_horizontal = false;
}

void DrawElement_SliderMinMaxLabels(string s_min, string s_max) =
{
	local vector pos, sliderimgsize;

	pos = option_pos;
	sliderimgsize = drawgetimagesize(option_sliderimage);
	
	option_pos = GetLastLinePos();
	option_pos_x += option_sliderspacing;
	option_pos_y += 5;
	Menu_AlignedText(s_min, ALIGN_LEFT);
	option_pos_x += sliderimgsize_x - stringwidth(s_max, false, body_fontsize) - 4;
	Menu_AlignedText(s_max, ALIGN_LEFT);
	option_pos = pos;
}

void DrawElement_OptionTitle(string text) =
{
	local float width, translate;
	local vector fontsize;
	
	translate = skiptranslation;
	
	fontsize = '12 9 0' * (option_size_y/16);//*languagefontscale;
	
	TempMenuSetting_body_fontsize(fontsize);
	TempMenuSetting_body_textalignment('-1 0 0');
	TempMenuSetting_body_textbordersize('12 0 0');
	TempMenuSetting_body_imagealpha(0.4);
	width = active_menu.menusize_x - border_size_x*2 - body_margin_x*2;
	
	if(active_menu.scrollboxmeasurement == 2)
		width -= scrollbar_width + body_margin_x;
	
	TempMenuSetting_option_size_width(width);
	Menu_Image_Bordered_Body("gfx/menu/rm_underlay_left.tga", "gfx/menu/rm_underlay_right.tga", "gfx/menu/rm_underlay_mid.tga", SIZE_AUTO);
	TempMenuSetting_body_fontcolor('0.46 0.62 0.75');	
	text = Translate(text);
	skiptranslation = true;
	Menu_Text(text);
	skiptranslation = translate;
	RestoreMenuSetting_body_fontcolor();
	RestoreMenuSetting_option_size_width();
	RestoreMenuSetting_body_fontsize();
	RestoreMenuSetting_body_textalignment();
	RestoreMenuSetting_body_textbordersize();
	RestoreMenuSetting_body_imagealpha();
	BR();
}

void DrawElement_CheckBox(vector pos, float checkboxspacing, float ischecked) =
{
	local float imagealpha, proportion;
	local string box_imgname, check_imgname;
	local vector box_imgsize, check_imgsize, boxcolor;
	
	pos_x += checkboxspacing;
	
	if(active_menu.user_current_option == option_current-1)
	{
		if(EPISODE < OPTION_EPISODE_MIN)
		{
			boxcolor = '0.3 0.3 0.3';
			imagealpha = 0.8;
		}		
		else
		{
			imagealpha = option_imagealpha_highlight;
			boxcolor = option_imagecolor_highlight;
		}
	}
	else
	{
		if(EPISODE < OPTION_EPISODE_MIN)
		{
			boxcolor = '0.2 0.2 0.2';
			imagealpha = 0.8;
		}
		else
		{
			imagealpha = option_imagealpha;
			boxcolor = option_imagecolor;
		}
	}
	
	box_imgname = "gfx/menu/check_box.tga";
	check_imgname = "gfx/menu/check_mark.tga";
	box_imgsize = drawgetimagesize(box_imgname);
	check_imgsize = drawgetimagesize(check_imgname);
	
	proportion = option_size_y/box_imgsize_y;
	box_imgsize = box_imgsize*proportion;
	check_imgsize = check_imgsize*proportion;
	
	drawpic(pos, box_imgname, box_imgsize, boxcolor, imagealpha, option_imageflags);
	
	if(ischecked)
		drawpic(pos+'10 6 0'*proportion, check_imgname, check_imgsize, boxcolor, imagealpha, option_imageflags);
}

void Menu_Option_CheckBox(string text, void() func, float status) =
{
	local string box_imgname;
	local vector box_imgsize;
	local float proportion;

	option_size_selectionbox = option_size;
	
	box_imgname = "gfx/menu/check_box.tga";
	box_imgsize = drawgetimagesize(box_imgname);
	proportion = option_size_y/box_imgsize_y;
	box_imgsize = box_imgsize*proportion;
	
	TempMenuSetting_option_size_width(option_size_x - box_imgsize_x - 10);
	Menu_Option_Text(text, func);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_size_x+10, status);
	RestoreMenuSetting_option_size_width();
	option_size_selectionbox = '0 0 0';
	BR();
}

void DrawElement_BottomButton(string text, void() func, float altoption_up, float altoption_down, float altoption_left, float altoption_right, float BUTTONTYPE) =
{
	local float t_width;//, translate;
	local vector t_option_pos, imgsize, option_ofs;
	local string imgname;
	
	option_ofs = '8 8 0';	
	
	optionalt_up = altoption_up;
	optionalt_down = altoption_down;
	optionalt_left = altoption_left;
	optionalt_right = altoption_right;	
	
	imgname = "gfx/menu/small_button_border.tga";
	imgsize = drawgetimagesize(imgname);

	drawpic(option_pos, imgname, imgsize, body_bgimagecolor, body_imagealpha, body_imageflags);
	option_pos += option_ofs;
	menubuttontype = BUTTONTYPE;
	
//	text = Translate(text);
//	translate = skiptranslation;
//	skiptranslation = true;
	
//	option_fontsize_old = option_fontsize;
//	if(strlen(text) > 0 && option_size_x - option_textbordersize_x*2 > 0)
//	while(stringwidth(text, false, option_fontsize) > option_size_x - option_textbordersize_x*2)
//		option_fontsize = option_fontsize - option_fontsize_old*0.01;
	Menu_Option_Text(text, func);
//	option_fontsize = option_fontsize_old;
//	option_fontsize_old = '0 0 0';
	
	option_pos -= option_ofs;
	option_pos = GetLastLinePos();
	option_pos_x += option_size_x + option_spacing;
	
//	skiptranslation = translate;
}

void BeginBottomButtons(float numbuttons) =
{
	option_pos_y += 40;
	bottombutton_pre_option_pos = option_pos;
	body_alignment = '-1 0 0';
	optionselection_horizontal = true;
	TempMenuSetting_option_spacing(23);//option_spacing = 23;
	option_image = "gfx/menu/small_button.tga";
	option_image_left = "";
	option_image_right = "";
	option_image_highlight = "gfx/menu/small_button_hover.tga";
	option_image_left_highlight = "";
	option_image_right_highlight = "";
	option_fontsize = '14 12 0';//*languagefontscale;
	option_textalignment = '1 -1 0';
	option_textbordersize = '8 2 0';
	option_size = drawgetimagesize(option_image);	
	option_pos_x += active_menu.menusize_x - (option_size_x+option_spacing)*numbuttons + option_spacing + bottombutton_ofs_x;//12;
	option_pos_y = active_menu.menupos_y + active_menu.menusize_y + bottombutton_ofs_y;//- 28;
}

void EndBottomButtons() =
{
	RestoreMenuSetting_option_spacing();
	option_pos = bottombutton_pre_option_pos;
	optionselection_horizontal = false;
}

void CompensateForSpaceInList() =
{
	if(optionnum_max)
	{
		if(option_current < active_menu.user_current_selection - 1 - active_menu.skippedoptionslots)
			active_menu.skippedoptionslots = active_menu.skippedoptionslots + 1;

		optionnum_max -= 1;
		if(GameControl(CTRL_MENUNAVIGATEDOWN, 0))
		if(!atbottomofscrollingwindow)
		if(active_menu.user_current_option >= optionnum_max-1)
			option_current_sendtobottomoflist = 2;
	}
}

float Draw_ScollingList(float listitems, float listslots, float firstlistoption, float listwidth, float op_left, float op_right, void() SkipFunc, void(float f) ListOptionFunc) =
{
	local float count, lastlistoption, opsize, ofs, dist, skipitems, lastdrawnlistoption, translate;
	local vector windowstart, windowsize, option_pos_start, option_size_old, vals;
	
	translate = skiptranslation;
	skiptranslation = true;
	
//	drawinglist = true;
	
	if(!active_menu.drawinglist)
	{
		active_menu.drawinglist = true;
		UpdateBindMap();
	}
	
	optionselection_horizontal = true;
	
	firstlistoption += 1;
	if(viewingtextlist)
		lastlistoption = firstlistoption;
	else
		lastlistoption = firstlistoption + listslots - 1;

	option_size_old = option_size;		
	opsize = option_size_y + option_spacing;
	windowstart = option_pos;
	windowsize_x = listwidth;
	windowsize_y = opsize*listslots - option_spacing;	
	option_size_x = windowsize_x;// - option_spacing*2;
	
//	option_size_prev = option_size;
	//option_size_x = windowsize_x - option_spacing;	
	
	if(listitems <= listslots)
		listslots = listitems;

	if(listitems > listslots)
	{
		active_menu.drawingscrollbar = true;
		option_size_x -= scrollbar_width + option_spacing;
		windowsize_x -= scrollbar_width;
		scrollbar_incrementsize = opsize;
		option_pos_y = BeginScrollingWindow(option_pos, windowsize, 0,0);
		ofs = windowstart_y - option_pos_y;
		option_pos_y += ((ofs/opsize) - floor(ofs/opsize))*opsize;
	}
	else
		active_menu.drawingscrollbar = false;

	if(active_menu.user_current_option >= firstlistoption-1 && active_menu.user_current_option <= lastlistoption-1)
	if(!(viewingtextlist && !selectedtextlist))
	{
		optionnum_min = firstlistoption;
		if(viewingtextlist)
			optionnum_max = optionnum_min;
		else
			optionnum_max = optionnum_min+listslots-1;
	}	

	for(count = 0; count < listitems+skipitems && active_menu; count++)
	{
		if(IsAssignedFunction(SkipFunc))
		if(SkipFunc())
		{
			skipitems++;
			continue;
		}
	
	//	if(count > 0)
	//		BR();	
	
		dist += opsize;
	
		if((option_pos_y + option_spacing < windowstart_y)
			|| (option_pos_y + option_size_y > windowstart_y + windowsize_y + option_spacing))
		{
			BR();
			continue;
		}				
			
	//	option_pos_start = option_pos;	
		
		optionalt_left = op_left+1;
		optionalt_right = op_right+1;	
			
		skiptranslation = true;
		ListOptionFunc(count);	
		
		//option_pos = option_pos_start;
	}		
	
	lastdrawnlistoption = option_current;
	
	if(option_current_sendtobottomoflist)
		option_current_sendtobottomoflist -= 1;
	
	if(!viewingtextlist)
	if(option_current < firstlistoption+listslots)
		option_current = lastlistoption;
		
	if(active_menu.user_current_option > lastlistoption-1 && active_menu.user_current_option < lastlistoption)
		active_menu.user_current_option = op_right;
	
	if(listitems > listslots)
		EndScrollingWindow(dist-option_spacing, 0, 0);		
		
	//option_size = option_size_prev;
	option_pos_y = windowstart_y + windowsize_y + option_spacing;
	
	optionselection_horizontal = false;
	
	option_size = option_size_old;
	
	skiptranslation = translate;
	
	return lastdrawnlistoption;
}

void GoToBottomOfScrollingWindow() =	{	gotobottomofscrollingwindow = 2;	}

void MoveBufferItem(float bufferid, float orgpos, float destpos) =
{
	local float buffersize, bufferpos;
	local string bufferstring, nextstring, prevstring, bufferstring_org;
	
	bufferstring_org = GetBufferString(bufferid, orgpos);	
	
	if(orgpos < destpos)
	{
		for(bufferpos = orgpos; bufferpos < destpos; bufferpos++)
		{
			nextstring = GetBufferString(bufferid, bufferpos+1);
			SetBufferString(bufferid, bufferpos, nextstring);
		}
		
		SetBufferString(bufferid, destpos, bufferstring_org);
	}
	else
	{
		prevstring = GetBufferString(bufferid, destpos);
		SetBufferString(bufferid, destpos, bufferstring_org);
	
		for(bufferpos = destpos+1; bufferpos <= orgpos; bufferpos++)
		{
			if(bufferpos < orgpos)
				nextstring = GetBufferString(bufferid, bufferpos);
			SetBufferString(bufferid, bufferpos, prevstring);
			if(bufferpos < orgpos)
				prevstring = nextstring;
		}
	}
}

string GetKeyForControlID(float ctrlid) =
{
	local float count, keynum, keydest;
	local string keynums, s, key, bindstring;
	
	bindstring = GetBindForControlID(ctrlid);
	
//	s = strcat("cmd in_bindmap ", ftos(GetBindMapForControlID(ctrlid)));
//	s = strcat(s, " 0\n");
//	localcmd(s);
//	s = string_null;

	keynums = findkeysforcommand(bindstring, GetBindMapForControlID(ctrlid));
	tokenize(keynums);
	for(count = 0; count < 5; count++)
	{
		keynum = stof(argv(count));

		if(keynum != -1)
		{
			if(strlen(s) > 0)
				s = strcat(s, " ");		
		
			key = keynumtostring(keynum);
			s = strcat(s, key);
		}
	}	

	if(strlen(s) < 1)
		return "UNBOUND";
	
	return s;
}

string GetShortKeyListForControlID(float ctrlid, float trail) =
{
	local string keys;
	local float numkeys;
	
	keys = GetKeyForControlID(ctrlid);
	numkeys = tokenize(keys);

	if(numkeys > 1)
	{
		keys = argv(0);
		if(trail)
			keys = strcat(keys, " ...");
	}

	return keys;
}

void VKB_Input() =
{
	local string c;

	if(!active_menu.listid)
		return;

	cl_button_ucs_vkb = active_menu.listid;
}

void Draw_VirtualKeyboard(void() func) =
{
	local float count, startchar_n, startchar_c, totalchars_n, totalchars_c, totalchars, totalcols, totalrows, row, col, colpos, buttonwidth, endbuttonwidth, lastrow, upbutton, downbutton, leftbutton, rightbutton, uppercase, vkbwidth, swidth;
	local string c, s;
	
	body_alignment = '-1 0 0';	
	buttonwidth = 32;
	option_size_x = buttonwidth;
	option_size_y = 22;
	option_fontsize = '12 12 0'*languagefontscale;
	
	startchar_n = 48;	// this is the key num for "0"
	totalchars_n = 10;
	startchar_c = 97;	// this is the key num for "a"
	totalchars_c = 26;		
	totalcols = 10;
	
	totalchars = totalchars_n+totalchars_c;
	totalrows = ceil((totalchars_n+totalchars_c)/totalcols);
	
	drawpic(option_pos+'-26 -7 0', "gfx/hud/vkb_background.tga", '390 141.666 0', '1 1 1', 1, 0);
	
	option_pos_x = (vid_size_x - (((buttonwidth+option_spacing)*totalcols)-option_spacing))*0.5;
	
	if(GameControl(CTRL_SHIFT_LEFT, 0))
		vkb_uppercase = !vkb_uppercase;
	else
	if(GameControl(CTRL_SHIFT_RIGHT, 0))
		vkb_uppercase = !vkb_uppercase;	
	
	lastrow = 0;
	for(count = 0; count < totalchars; count+=1)
	{
		if(count < totalchars_n)
			active_menu.listid = startchar_n+count;
		else
			active_menu.listid = startchar_c+count-totalchars_n;
		
		row = floor(count/totalcols);
		col = count - row*totalcols;
		
		if(row > lastrow)
			BR();
		
		colpos = (buttonwidth+option_spacing)*col;
		
		upbutton = option_current - totalcols + 1;
		downbutton = option_current + totalcols + 1;
		leftbutton = 0;
		rightbutton = 0;
		
		if(upbutton < 1)
		{
			upbutton = (totalrows-1)*totalcols + col + 1;
			
			if(upbutton > totalchars)
				upbutton = totalchars+1;
		}
		
		if(downbutton > totalchars)
		if(row == totalrows-2)
			downbutton = totalchars+1;
		else
			downbutton = col + 1;
		
		if(col == totalcols-1 || count == totalchars)
			rightbutton = row*totalcols + 1;
			
		if(col == 0)
			leftbutton = (row+1)*totalcols;
			
		if(leftbutton > totalchars)
			leftbutton = totalchars+1;

		c = keynumtostring(active_menu.listid);
		
		if(vkb_uppercase)
		if(count < totalchars_n)
			c = GetSymbolForKey(startchar_n+count);
		else
			c = strtoupper(c);
		
		HorizontalListButton(colpos, buttonwidth, c, VKB_Input, upbutton, downbutton, leftbutton, rightbutton, MBT_BASIC);	
	
		lastrow = row;
	}

	active_menu.listid = 0;
	
	upbutton = totalcols*(totalrows-1);
	downbutton = totalcols;
	leftbutton = 0;
	rightbutton = upbutton+1;
	
	endbuttonwidth = 50;
	colpos = (buttonwidth+option_spacing)*totalcols - endbuttonwidth - option_spacing;
	HorizontalListButton(colpos, endbuttonwidth, "END", func, upbutton, downbutton, leftbutton, rightbutton, MBT_CONFIRM);
	BR();
	
	body_fontsize = '9 9 0'*languagefontscale;
	body_textalignment = '-1 0 0';
	s = Translate("Triggers: Caps/Symbols, A: Accept, B: Backspace");
	swidth = stringwidth(s, false, body_fontsize);
	vkbwidth = (buttonwidth+option_spacing)*totalcols - option_spacing;
	option_size_x = swidth;	
	option_pos_x += (vkbwidth-swidth)*0.5;
	Menu_Text("Triggers: Caps/Symbols, A: Accept, B: Backspace");
}