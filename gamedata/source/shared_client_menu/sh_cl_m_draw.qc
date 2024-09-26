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
void Video_Update() =
{
//	local float intended_vidwidth
	
	vid_res_x =		cvar("vid_width");
	vid_res_y = 	cvar("vid_height");
//	vid_res_z =		cvar("vid_pixelheight");

	vid_size_x =	cvar("vid_conwidth");
	vid_size_y = 	cvar("vid_conheight");
	
//	intended_vidwidth = vid_size_y / (vid_res_y / vid_res_x);
//	if(vid_size_x != intended_vidwidth)
//	{print("setting width\n");
//		cvar_set("vid_conwidth", ftos(intended_vidwidth));
//		vid_size_x = intended_vidwidth;
//	}

	vid_size_norm = '800 600 0';

	SIZE_MAIN_RIGHTPANE_x = SIZE_MAIN_RIGHTPANE_BOTTOMLESS_x = 420;//vid_size_x - 310 - 25*2;
	SIZE_MAIN_RIGHTPANE_y = 350;
}

void BindMap_Update() =
{
	local vector bindmaps;
//	s = cvar_string("in_currentbindmap");
//	tokenize(s);
	bindmaps = getbindmaps();
	bindmap_foreground = bindmaps_x;//stof(argv(0));
	bindmap_background = bindmaps_y;//stof(argv(1));
}

void Font_Init(float LANGUAGE) =
{
	local string s, font_chat, font_user0, font_user1, font_user2, font_console, font_menu;
	local float font_chat_scale, font_user0_scale, font_user1_scale, font_user2_scale, font_console_scale, font_menu_scale;
	
	if(LANGUAGE == LANGUAGE_JAPANESE)
	{
		if(currentfontlanguage == LANGUAGE_JAPANESE+1)
			return;

		currentfontlanguage = LANGUAGE_JAPANESE+1;
			
		font_chat			= "gfx/fonts/japanese-p.ttf";
		font_chat_scale		= 1;
		font_user0			= "gfx/fonts/title";
		font_user0_scale	= 1.1;
		font_user1			= "gfx/fonts/japanese-p.ttf";
		font_user1_scale	= 1;
		font_user2			= "gfx/fonts/japanese-p.ttf";
		font_user2_scale	= 1;
		font_console		= "gfx/fonts/menus.otf";
		font_console_scale	= 1.4;
		font_menu			= "gfx/fonts/japanese-p.ttf";	
		font_menu_scale		= 1;
	}
	else
	{
		if(currentfontlanguage == LANGUAGE_ENGLISH+1)
			return;
	
		currentfontlanguage = LANGUAGE_ENGLISH+1;
	
		font_chat			= "gfx/fonts/menus.otf";
		font_chat_scale		= 1.4;
		font_user0			= "gfx/fonts/title";
		font_user0_scale	= 1.1;
		font_user1			= "gfx/fonts/bitmap.ttf";
		font_user1_scale	= 1;
		font_user2			= "gfx/fonts/menus.otf";
		font_user2_scale	= 1.4;
		font_console		= "gfx/fonts/menus.otf";
		font_console_scale	= 1.4;
		font_menu			= "gfx/fonts/menus";
		font_menu_scale		= 1.4;
	}
	
	s =				"set _rfo $r_font_postprocess_outline;";
	s = strcat(s,	"set _rfb $r_font_postprocess_blur;");
	s = strcat(s,	"r_font_postprocess_outline 2;");
	s = strcat(s,	"r_font_postprocess_blur 4;");
	
	s = strcat(s,	"loadfont chat ", font_chat, " scale ", ftos(font_chat_scale), " 12;");
	s = strcat(s,	"loadfont user1 ", font_user1, " scale ", ftos(font_user1_scale), " 12;");
	s = strcat(s,	"loadfont user2 ", font_user2, " scale ", ftos(font_user2_scale), " 12;");
	
	s = strcat(s,	"loadfont user3 gfx/fonts/bitmap.ttf scale 1 12;");	// numerical	
	
	s = strcat(s,	"r_font_postprocess_outline $_rfo;");
	s = strcat(s,	"r_font_postprocess_blur $_rfb;");
	s = strcat(s,	"set r_font_compress 1;");
	s = strcat(s,	"set r_font_disable_freetype 0;");

	s = strcat(s,	"loadfont console ", font_console, " scale ", ftos(font_console_scale), " 12;");
	s = strcat(s,	"loadfont menu ", font_menu, " scale ", ftos(font_menu_scale), " 12;");
	s = strcat(s,	"loadfont user0 ", font_user0, " scale ", ftos(font_user0_scale), " 12;");
	
	localcmd(s);
}

void Menu_Init() =
{
//	Font_Init();
	Sound_Init();
	Menu_Defaults();	
}

void Hide_Brightness() =
{
	border_imagecolor			= menu_hidebrightness*border_imagecolor;
	border_bgcolor				= menu_hidebrightness*border_bgcolor;
	
	title_fontcolor				= menu_hidebrightness*title_fontcolor;
	title_imagecolor			= menu_hidebrightness*title_imagecolor;
	title_bgcolor				= menu_hidebrightness*title_bgcolor;		
	
	body_fontcolor				= menu_hidebrightness*body_fontcolor;
	body_imagecolor				= menu_hidebrightness*body_imagecolor;
	body_imagebgcolor			= menu_hidebrightness*body_imagebgcolor;
	body_bgcolor				= menu_hidebrightness*body_bgcolor;	
	
	option_fontcolor			= menu_hidebrightness*option_fontcolor;
	option_imagecolor			= menu_hidebrightness*option_imagecolor;
	option_bgcolor				= menu_hidebrightness*option_bgcolor;
	option_fontcolor_highlight	= menu_hidebrightness*option_fontcolor_highlight;
	option_imagecolor_highlight	= menu_hidebrightness*option_imagecolor_highlight;
	option_bgcolor_highlight	= menu_hidebrightness*option_bgcolor_highlight;	
}

void Hide_Alpha() =
{
	border_imagealpha			= menu_hidealpha*border_imagealpha;
	border_bgalpha				= menu_hidealpha*border_bgalpha;
	
	title_fontalpha				= menu_hidealpha*title_fontalpha;
	title_imagealpha			= menu_hidealpha*title_imagealpha;
	title_bgalpha				= menu_hidealpha*title_bgalpha;
	
	body_fontalpha				= menu_hidealpha*body_fontalpha;
	body_imagealpha				= menu_hidealpha*body_imagealpha;
	body_imagebgalpha			= menu_hidealpha*body_imagealpha;
	body_bgalpha				= menu_hidealpha*body_bgalpha;	
	
	option_fontalpha			= menu_hidealpha*option_fontalpha;
	option_imagealpha			= menu_hidealpha*option_imagealpha;
	option_bgalpha				= menu_hidealpha*option_bgalpha;	
}

/*vector DrawFontSize(vector fontsize) =
{
	local float multiple;

	if(drawfont == FONT_DEFAULT)
		multiple = fontsize_multiplier_default;	
	else
	if(drawfont == FONT_MENU)
		multiple = fontsize_multiplier_menu;
	else	
	if(drawfont == FONT_USER0)
		multiple = fontsize_multiplier_user0;
	
	return fontsize*multiple;
}

vector DrawFontPosition(vector pos, vector fontsize) =
{
	local float ofs, height, multiple;

	if(drawfont == FONT_DEFAULT)
		ofs = fontoffset_default;
	else
	if(drawfont == FONT_MENU)
		ofs = fontoffset_menu;
	else	
	if(drawfont == FONT_USER0)
		ofs = fontoffset_user0;
	
	fontsize = DrawFontSize(fontsize);
	multiple = fontsize_y;
	
	pos_y += ofs*multiple/10;
	
	return pos;
}*/

string Translate(string text) =	{	return Localize(text, active_menu.buf_translation);	}

void SkipTranslations(float numlines) =
{
	local float count;
	for(count = 0; count < numlines; count+=1)
		Translate(string_null);
}

float GetFloatPolarity(float f) =
{
	if(f < 0)
		f = -1;
	else
	if(f > 0)
		f = 1;
		
	return f;
}

vector AlignmentPos(vector pos, vector outersize, vector innersize, vector malignment, vector bordersize) =
{
	local vector startposbox;

	startposbox = outersize - innersize;
	
	pos += startposbox*0.5;

	malignment_x = GetFloatPolarity(malignment_x);
	malignment_y = GetFloatPolarity(malignment_y);	
	
	pos_x += startposbox_x*malignment_x*0.5;
	pos_y -= startposbox_y*malignment_y*0.5;
	
	if(malignment_x == -1)
		pos_x += bordersize_x;
	else
	if(malignment_x == 1)
		pos_x -= bordersize_x;

	if(malignment_y == -1)
		pos_y -= bordersize_y;
	else
	if(malignment_y == 1)
		pos_y += bordersize_y;
		
	return pos;
}

vector TextAlignmentPos(string o_text, vector pos, vector o_size, vector o_fontsize, vector o_textalignment, vector o_textbordersize) =
{
	local vector textboxsize;
	
	textboxsize_x = stringwidth(o_text, false, o_fontsize);//strlen(o_text)*o_fontsize_x;
	textboxsize_y = o_fontsize_y;

	pos = AlignmentPos(pos, o_size, textboxsize, o_textalignment, o_textbordersize);
	return pos;
}

vector BoxAlignmentPos(vector pos, vector o_boxsize, vector o_alignment, float aligntype, vector o_bordersize) =
{
	local vector outersize;
	
	if(aligntype == 0)
		outersize_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2;
	else
		outersize_x = option_size_x;
		
	outersize_y = option_size_y;	
	
	pos = AlignmentPos(pos, outersize, o_boxsize, o_alignment, o_bordersize);
	return pos;
}

/*string FitFontSizeToWidth(string text, float width, vector t_fontsize) =
{
	while(stringwidth(text, false, t_fontsize) > width && strlen(text) > 0)
		text = substring(text, 0, strlen(text)-1);
	
	return text;
}*/

vector FitFontSizeToWidth(string text, float width, vector t_fontsize) =
{
	if(strlen(text) > 0 && width > 0)
		t_fontsize_x = t_fontsize_x*min(1, width / stringwidth(text, false, t_fontsize));
	
	return t_fontsize;
}

void DrawString(float buf, vector pos, string text, vector fsize, vector rgb, float alph, float fontflags, vector outersize, vector bordersize, vector textalignment ) =
{
	local vector fsize_old;
	local float width;
	fsize_old = fsize;

	text = Localize(text, buf);
	
//	if(strlen(text) > 0 && outersize_x - bordersize_x*2 > 0)
//	while(stringwidth(text, false, fsize) > outersize_x - bordersize_x*2)
//		fsize = fsize - fsize_old*0.01;	
		
//	width = outersize_x - bordersize_x*2;
	fsize = FitFontSizeToWidth(text, outersize_x - bordersize_x*2, fsize);
		
	pos = TextAlignmentPos(text, pos, outersize, fsize, textalignment, bordersize);
	
	drawstring(pos, text, fsize, rgb, alph, fontflags);
}

void DrawString_MenuContents(vector pos, string text, vector fsize, vector rgb, float alph, float fontflags, vector outersize, vector bordersize, vector textalignment) =
{	DrawString(active_menu.buf_translation, pos, text, fsize, rgb, alph, fontflags, outersize, bordersize, textalignment);	}

float AllSpaces(string s) =
{
	local string t;
	local float count, slen;
	
	slen = strlen(s);
	
	while(count < slen)
	{
		t = strcat(t, " ");
		count++;
	}
	
	if(s == t)
		return TRUE;
	
	return FALSE;
	
}

void UpdateMenuChain() =
{
	local float count;
	local entity menu, nextmenu;
	count = 1;
	list_menuchain = menu = findfloat(world, draworder, count);
	for(count = 1; count <= menu_count; count++)
	{
		nextmenu = findfloat(world, draworder, count+1);
		menu.menuchain = nextmenu;
		menu = nextmenu;
	}	
}

void ApplyHideValues() = 
{
	if(active_menu == currentmenu || (currentmenu && active_menu.linkcontrolstomenu == currentmenu)) // Don't apply hide values to the top menu
		return;

	if(menu_appearance & HIDE_BRIGHTNESS)
		Hide_Brightness();

	if(menu_appearance & HIDE_ALPHA)
		Hide_Alpha();
}

float GetMenuSize(vector startpos) = // this is used at the end of the menu on the first frame to determine the size of the background (the menu is not drawn on the first frame)
{
	local vector bsize, pos;
	pos = option_pos;
	pos_y -= option_spacing;
	pos_y += border_size_y;
	bsize = pos - startpos;
	return bsize_y;
}

float IsInsideBox(vector pos, vector bpos, vector bsize) =
{
	if(pos_x >= bpos_x)
	if(pos_x < bpos_x + bsize_x)
	if(pos_y >= bpos_y)
	if(pos_y < bpos_y + bsize_y)
		return true;

	return false;

}

float CursorInsideBox(vector pos, float width, float height) =
{
	local vector bsize;
	bsize_x = width;
	bsize_y = height;

	return IsInsideBox(mousepos, pos, bsize);
}

vector GetMenuPosition(vector box) =	{	return ('800 600 0' - box)*0.5; 	};

vector MenuPosition() =
{
	local vector pos;
	pos = active_menu.menupos;
	pos_x += (vid_size_x - 800)*0.5;
	return pos;
}

float MenuColumn() =	{	return active_menu.menupos_x + (vid_size_x-800)*0.5;	}

void ClearMenuData(entity menu) =
{
	if(menu.buf_translation)
	{
		DeleteBuffer(menu.buf_translation);
		menu.buf_translation = 0;
	}	

	if(menu.buf_contents)
	{
		DeleteBuffer(menu.buf_contents);
		menu.buf_contents = 0;
	}

	if(menu.buf_list)
	{
		DeleteBuffer(menu.buf_list);
		menu.buf_list = 0;
	}
	
	if(menu.buf_items)
	{
		DeleteBuffer(menu.buf_items);
		menu.buf_items = 0;	
	}
	
	if(menu.buf_textblock)
	{
		DeleteBuffer(menu.buf_textblock);
		menu.buf_textblock = 0;
	}
	
	if(menu.buf_display)
	{
		DeleteBuffer(menu.buf_display);
		menu.buf_display = 0;
	}	
	
	menu.parentmenu = world;
	menu.m_filename = freezone(menu.m_filename);
	menu.targetent = world;
//	menu.liststring = freezone(menu.liststring); 
//	menu.liststring2 = freezone(menu.liststring2);
}

void RemoveMenuEnt(entity menu) =
{
	local entity e;
	e = list_menuchain;//findchainfloat(guiclass, GUI_MENU);
	while(e)
	{
		if(e != menu)
		if(e.draworder > menu.draworder)
			e.draworder-=1;
			
		e = e.menuchain;
	}

	if(menu == pulldownmenu)
		pulldownmenu = world;
	
	if(menu.CloseMenuFunc)
		Func_oself(menu, menu.CloseMenuFunc);
	ClearMenuData(menu);
	remove(menu);

	menu_count -= 1;
	
	
}

float	server_inmenu;
void RestoreAxisSettings() =
{
	if(CODEBASE != CLIENTCODE)
		return;

	if(menu_count)
		return;
	
	server_inmenu = false;
	localcmd("cmd menus_closed\n");
}

void NegateAxisSettings() =
{
	if(CODEBASE != CLIENTCODE)
		return;

	if(server_inmenu)
		return;
		
	server_inmenu = true;
	localcmd("cmd menus_opened\n");
}

void GoToNextCurrentMenu() =
{
	local entity menu, highestpriority;
	local float clearactivemenu;

	ClearAllInputValues();
	
	menu = list_menuchain;
	while(menu)
	{
		if(menu != currentmenu)
		if(menu.draworder)
		if(!highestpriority || (menu.draworder && menu.draworder > highestpriority.draworder))
			highestpriority = menu;
		
		menu = menu.menuchain;
	}
	
	if(currentmenu)
	{
		if(currentmenu == active_menu)
			clearactivemenu = true;
		RemoveMenuEnt(currentmenu);
	}
	
	UpdateMenuChain();
	
	if(clearactivemenu)
		active_menu = world;	
	currentmenu = highestpriority;
	
	RestoreAxisSettings();
}

void MoveMenuToTop(entity topmenu) =
{
	local float newdraworder;
	local entity menu;

	menu = list_menuchain;
	while(menu)
	{
		if(menu != topmenu)
		{
			if(list_menuchain == topmenu)
				list_menuchain = menu;
		
			newdraworder++;
			menu.draworder = newdraworder;
			
			if(menu.menuchain == topmenu)
				menu.menuchain = menu.menuchain.menuchain;
		
			if(!menu.menuchain)
				menu.menuchain = topmenu;
		}
		
		menu = menu.menuchain;
		
		if(menu == topmenu)
			break;
	}

	topmenu.draworder = menu_count;
	topmenu.menuchain = world;
	currentmenu = topmenu;
}

void MoveMenuToBottom(entity menu) =
{
	local entity e;

	for(e = list_menuchain; e && e != menu; e = e.menuchain)
	{
		e.draworder++;

		if(e.menuchain == menu)
		{
			e.menuchain = menu.menuchain;
			menu.menuchain = list_menuchain;
			menu.draworder = 1;
			list_menuchain = menu;
			break;
		}
	}
}

entity SpawnMenu(void() DrawCmd) =
{
	local entity menu;

	menu_count++;	
	menu = spawn();
	menu.guiclass = GUI_MENU;
	menu.draworder = menu_count;
	menu.DrawMenu = DrawCmd;

	UpdateMenuChain();

	return menu;
}

void DrawMenus() =
{
	local entity menu;

//	drawinglist = false;
	menu_drawMOTD				= false;	
	
	CURSOROVERMENU = false;	
	
	menu = list_menuchain;
	while(menu)
	{
		if(menu.mflags & MF_HIDDEN)	// not used
		{
			menu = menu.menuchain;
			continue;
		}

		if(!(!currentmenu.menu_style & STYLE_PRIORITY && menu != currentmenu && menu.m_appearance & HIDE_ALPHA && menu.m_hidealpha == 0)
		&& !(menu == menu_death && adminmode))
		{
			active_menu = menu;
			if(menu.menu_drawaftertime <= time)
				menu.DrawMenu();
			else
			if(menu == currentmenu)
				drawfill('0 0 0', vid_size, '0 0 0', 0.9, 0);
		}
	
		menu = menu.menuchain;
	}
	
//	if(pulldownmenu)
//	if(!CursorInsideBox(pulldownmenu.menupos, pulldownmenu.menusize_x, pulldownmenu.menusize_y))
//	if(cl_button == K_MOUSE1 || cl_button == K_MOUSE2 || cl_button == K_ESCAPE)
//	if(GameControl(CTRL_MENUBUTTON1, 0) || GameControl(CTRL_MENUBUTTON2, 0) || GameControl(CTRL_ESCAPE, 0))
//		ClosePulldownMenu();
	
	active_menu = world;
}

void MenuControls(entity menu) =
{
	local float mutesound;

	if(GameControl(CTRL_MENUBUTTON1, 1))
		return;

	if(active_input)
	if(!active_vkb)
		return;
		
	local float controlkeyused, ctrl_up, ctrl_down, ctrl_left, ctrl_right;
		
	ctrl_up = GameControl(CTRL_MENUNAVIGATEUP, 0);
	ctrl_down = GameControl(CTRL_MENUNAVIGATEDOWN, 0);
	ctrl_left = GameControl(CTRL_MENUNAVIGATELEFT, 0);
	ctrl_right = GameControl(CTRL_MENUNAVIGATERIGHT, 0);
		
	if(ctrl_up || (current_optionselection_horizontal /*&& current_optionalt_left*/ && ctrl_left && (!input_current || active_vkb)))
	{
		if(!(ctrl_up
		&& menu.user_current_option == optionnum_min-1))
		{
	//	|| (menu.user_current_option == optionnum_min && menu.user_current_selection-menu.skippedoptionslots-1 == optionnum_min-1 && optionnum_min))
	//		return;
		
			if(ctrl_up && current_optionalt_up)
				menu.user_current_option = current_optionalt_up - 1;
			else
			if(ctrl_left && current_optionalt_left)
					menu.user_current_option = current_optionalt_left - 1;
			else
			if(menu.user_current_option <= 0)
			{
				menu.user_current_option = option_current-1;
			}
			else
				menu.user_current_option = menu.user_current_option - 1;

			controlkeyused = true;
		}
		else
		if(ctrl_up)
		{
			if(menu.oldscrollbar_ofs != '0 0 0')
				controlkeyused = true;
		}
	}
	else
	if(ctrl_down || (current_optionselection_horizontal /*&& current_optionalt_right*/ && ctrl_right && (!input_current || active_vkb)))
	{
		if(ctrl_down)
		if(menu.user_current_option == optionnum_max - 1)
	//	|| (menu.user_current_option == optionnum_max - 2 && menu.user_current_selection-menu.skippedoptionslots-1 == optionnum_max-1 && optionnum_max))		
			return;
	
		if(ctrl_down && current_optionalt_down)
			menu.user_current_option = current_optionalt_down - 1;
		else
		if(ctrl_right && current_optionalt_right)
				menu.user_current_option = current_optionalt_right - 1;
		else
		if(menu.user_current_option >= option_current-1)
			menu.user_current_option = 0;
		else
			menu.user_current_option = menu.user_current_option + 1;

		controlkeyused = true;
	}
	
	if(controlkeyused)
	{
//		if(menu.user_current_option == menu.user_current_selection-menu.skippedoptionslots-1)
//		{
//			print("TRIED TO loop menucontrols...\n");
//			MenuControls(menu);
//			return;
//		}
			
		MenuSound(SOUND_MOUSEOVERCLICK);
		arrowkeymovement = TRUE;	
	}
	
//	if(menu == currentmenu)
//	if(menu.linkcontrolstomenu)
//		MenuControls(menu.linkcontrolstomenu);
}

/*vector TextAlignmentPos(string o_text, vector pos, vector o_size, vector o_fontsize, vector o_textalignment, vector o_textbordersize) =
{
	local vector textstartbox;
	
	textstartbox_x = o_size_x - strlen(o_text)*o_fontsize_x;
	textstartbox_y = o_size_y - o_fontsize_y;
	
	pos += textstartbox*0.5;
	
	o_textalignment_x = GetFloatPolarity(o_textalignment_x);
	o_textalignment_y = GetFloatPolarity(o_textalignment_y);	
	
	pos_x += textstartbox_x*o_textalignment_x*0.5;
	pos_y -= textstartbox_y*o_textalignment_y*0.5;
	
	if(o_textalignment_x == -1)
		pos_x += o_textbordersize_x;
	else
	if(o_textalignment_x == 1)
		pos_x -= o_textbordersize_x;

	if(o_textalignment_y == -1)
		pos_y -= o_textbordersize_y;
	else
	if(o_textalignment_y == 1)
		pos_y += o_textbordersize_y;
		
	return pos;
}*/

/*void drawpolygonpic(vector pos, string imagename, vector size, vector color, float ALPHA, float FLAGS) =
{
		local vector topleftvert, toprightvert, bottomrightvert, bottomleftvert;

		topleftvert			= pos;
		toprightvert_x		= pos_x+size_x;
		toprightvert_y		= pos_y;
		bottomrightvert 	= pos + size;
		bottomleftvert_x 	= pos_x;
		bottomleftvert_y	= pos_y+size_y;
		
		R_BeginPolygon(imagename, FLAGS);
		R_PolygonVertex(topleftvert, '0 0 0', color, ALPHA);	
		R_PolygonVertex(toprightvert, '1 0 0', color, ALPHA);
		R_PolygonVertex(bottomrightvert, '1 1 0', color, ALPHA);
		R_PolygonVertex(bottomleftvert, '0 1 0', color, ALPHA);	
		R_EndPolygon();	
}*/

void drawtiledpic(vector pos, string imagename, vector bsize, vector mcolor, float ALPHA, float FLAGS) =
{
	local vector start, end, tilesize, ratio, imgsize;

	start = pos;
	end = pos+bsize;

	imgsize = drawgetimagesize(imagename);
	
//	drawsetcliparea(start_x, start_y, bsize_x, bsize_y);	
	
	while(pos_y < end_y)
	{
		tilesize_x = min(imgsize_x, end_x - pos_x);
		tilesize_y = min(imgsize_y, end_y - pos_y);
		ratio_x = tilesize_x / imgsize_x;
		ratio_y = tilesize_y / imgsize_y;
	
		drawsubpic(pos, tilesize, imagename, '0 0 0', ratio, mcolor, ALPHA, FLAGS);
		
		pos_x += imgsize_x;
		if(pos_x >= end_x)
		{
			pos_x = start_x;
			pos_y += imgsize_y;
		}
	}
	
//	drawresetcliparea();
}

void drawmenupic(vector pos, string imagename, vector bsize, vector mcolor, float ALPHA, float FLAGS, float appearance) =
{
	if(!imagename || imagename == "" || menu_closing)
		return;

	if(appearance & IMAGE_STRETCH)
		drawpic(pos, imagename, bsize, mcolor, ALPHA, FLAGS);
	else
		drawtiledpic(pos, imagename, bsize, mcolor, ALPHA, FLAGS);
}

float NumericalKey(float keynum) =
{
	if(keynum >= 48 && keynum <=57)
		return true;
		
	if(keynum == 46) // period
		return true;

	return false;
}

float TextKey(float keynum) =
{
	if(NumericalKey(keynum))
		return true;

	if(keynum >= 65 && keynum <=122)
		return true;
		
	if(keynum == K_SPACE)
		return true;
	
	return false;	
}

string GetChrUCS(float keynum) =
{
	local string newchar;
			
	newchar = keynumtostring(keynum);
			
	switch(newchar)
	{
		case "ENTER":				newchar = SEP_BR;	break;
		case "SPACE":				newchar = " ";		break;
	//	case "QUOTE":				newchar = "\"";		break;
		case "SEMICOLON":			newchar = ";";		break;
		case "TILDE":				newchar = "~";		break;
		case "BACKQUOTE":			newchar = "`";		break;
		case "BACKSLASH":			newchar = "\\";		break;
		case "APOSTROPHE":			newchar = "'";		break;
		case "<UNKNOWN KEYNUM>":	newchar = "";		break;
	}

	return newchar;
}

string GetSymbolForKey(float keynum) =
{
	local string c;
	
	switch(keynum)
	{
		case 48:	c = "-";	break;
		case 49:	c = "+";	break;
		case 50:	c = "!";	break;
		case 51:	c = "@";	break;
		case 52:	c = "#";	break;
		case 53:	c = "$";	break;
		case 54:	c = "&";	break;
		case 55:	c = "*";	break;
		case 56:	c = "(";	break;
		case 57:	c = ")";	break;
	}

	return c;
}

void SetTextFormatting(vector fontsize) =
{

}

void DrawTextCursor(vector pos) =
{
	pos_x = pos_x + input_cursorscreenpos_x*input_fontsize_x;
	pos_y = pos_y + input_cursorscreenpos_y*input_fontsize_y;

	if(textcursor_blinktime < time)
	{
		textcursor_blinktime = time + 0.5;
		textcursor_nodraw = !textcursor_nodraw;
	}
		
	if(!textcursor_nodraw)
	{
		local vector cursorsize;
		cursorsize_x = 1;
		cursorsize_y = input_fontsize_y;
		pos_x -= cursorsize_x*0.5;
		drawfill(pos, cursorsize, '1 1 1', 1, 0);
	}
}

float GetLineNumber(float cursorpos) =
{
	local string line;
	local float count, buffersize, startchar, endchar;
	
	buffersize = GetBufferSize(active_menu.buf_textblock);
	for(count = 0; count < buffersize; count++)
	{
		line = GetBufferString(active_menu.buf_textblock, count);
		startchar = stof(substring(line, 0, 7));
		if(startchar > cursorpos)
			return count-1;
	}

	return max(0, buffersize-1);
}

float GetLineStartCharacterNumber(float linenum) =
{
	local string line;
	line = GetBufferString(active_menu.buf_textblock, linenum);
	return stof(substring(line, 0, 7));
}

void UpdateInputCursorPos(float newcursorpos) =
{
	local float linenum, linestartchar;

	input_cursorpos = newcursorpos;
	
	if(active_textblock)
	if(active_menu.buf_textblock)
	{
		linenum = GetLineNumber(newcursorpos);
		linestartchar = GetLineStartCharacterNumber(linenum);
	}

	input_cursorscreenpos_y = linenum;
	input_cursorscreenpos_x = newcursorpos - linestartchar;
	
	textcursor_blinktime = time + 0.5;
	textcursor_nodraw = false;	
}

float GenerateTextBlock(float buffer, vector blocksize, string text, vector font_size) =
{
	local float count, chars, breaks, totalchars, wordsinline, wordsinline2, testlinewidth, splitword;
	local string word, line, testline;
	
	if(font_size_x)
		blocksize_x = floor(blocksize_x/font_size_x)*font_size_x;	
	if(font_size_y)
		blocksize_y = floor(blocksize_y/font_size_y)*font_size_y;	

	if(buffer)
		DeleteBuffer(buffer);
	
	buffer = CreateBuffer();
	
	totalchars = strlen(text);
	text = strcat(text, " ");
	
	while(chars < totalchars)
	{
		if(chars) // add chars for spaces
			chars += 1 - splitword;
	
		if(!chars)
			chars += breaks;
	
		splitword = false;
	
		line = substring(text, chars, strlen(text)-chars);
		breaks = tokenizebyseparator(line, SEP_BR)-1;
		
		if(breaks)
		{
			breaks = 1;
			line = argv(0);
			testlinewidth = stringwidth(line, false, font_size);
			if(testlinewidth >= blocksize_x)
				breaks = 0;
		}
		
		testline = strcat(line, " ");
		wordsinline = tokenizebyseparator(testline, SEP_SPACE);
		
		word = argv(0);
		
		line = word;
		testlinewidth = stringwidth(line, 0, font_size);
		if(testlinewidth > blocksize_x)
		{
			for(count = 0; testlinewidth > blocksize_x; count++)
			{
				line = substring(line, 0, strlen(line) - count);
				testlinewidth = stringwidth(line, 0, font_size);
			}
			splitword = true;
		}
		else
		{
			count = 1;
			while(count < wordsinline)
			{
				testline = strcat(line, " ");
				word = argv(count);
				
				testline = strcat(testline, word);
				testlinewidth = stringwidth(testline, false, font_size);

				if(testlinewidth > blocksize_x)
					break;
				
				line = testline;
				count++;
			}
		}

		chars += strlen(line);	
		
		line = AppendToken(PrefixZerosToNumString(ftos(chars-strlen(line)), 7), SEP_SPACE, line);
		AddBufferString(buffer, line, 0);
	}
	
	return buffer;
}

void Menu_Text(string text);

float DrawTextBlock(float buffer, vector pos, float alignment, vector blocksize, string text, vector font_size, vector font_color, float font_alpha, float font_flags) =
{
	local vector startpos, align;
	local float count, buffersize, prefixlen, linewidth;
	local string line;
	
	if(font_size_x)
		blocksize_x = floor((blocksize_x-body_textbordersize_x)/font_size_x)*font_size_x;	
	if(font_size_y)
	if(blocksize_y)
		blocksize_y = floor((blocksize_y-body_textbordersize_y)/font_size_y)*font_size_y;
		
	align_x = alignment;
	align = AlignmentPos(pos, option_size, font_size, align, body_textbordersize);	
	pos_y = align_y;
		
	startpos = pos;
	
	if(!buffer)
		buffer = GenerateTextBlock(buffer, blocksize, text, font_size);
		
	buffersize = GetBufferSize(buffer);
		
	for(count = 0; count < buffersize; count++)
	{
		line = GetBufferString(buffer, count);
		line = substring(line, 8, strlen(line)-8);
		
		if(alignment != -1)
		{
			linewidth = stringwidth(line, false, font_size);
			if(alignment == 0)
				pos_x += (blocksize_x - linewidth)*0.5; 
			else
			if(alignment == 1)
				pos_x += blocksize_x - linewidth;
		}
		
		drawstring(pos, line, font_size, font_color, font_alpha, font_flags);
		pos_x = startpos_x;
		pos_y += font_size_y;
		if(blocksize_y)
		if(pos_y - startpos_y >= blocksize_y)
			break;
	}
	
	option_pos_y = pos_y;
	
	return buffer;
} 

string DrawInputBox(vector pos, vector inputsize, /*float INPUTCLASS,*/ float INPUTTYPE, string inputstring, void() InputFunc, float CLEARINPUT/*, float BOXNUM*/) =
{
	local vector inputboxsize, inputboxpos, drawstringpos, largeboxpos, posalign, option_pos_start;
	local float stringpos, init, charlen;
	local string s, c, inpstr;
	
	local float totallines, startchar, curline, curlinelen;
	local string curlinestr;	
	
//	pos_y -= linespace;
	
	if(active_input == input_current)
	{
		if(input_cursorpos > strlen(inputstring))
			UpdateInputCursorPos(strlen(inputstring));
		
		stringpos = inputstring_shift;//inputstring_pos[INPUTCLASS-1];
	}
	
//	if(logged)
	if((GameControl(CTRL_ESCAPE, 0) && !active_vkb) || active_menu != currentmenu)// && active_menu != nextfocusmenu))
	if(active_input == input_current)//ACTIVE_INPUT == INPUTCLASS)
	{
	/*	if(GameControl(CTRL_ESCAPE, 0))
		if(active_input == input_current)//ACTIVE_INPUT == INPUT_CURRENTMENU)
		{
		//	inputstring = freezone(inputstring);
			inputstring = string_null;
			if(IsAssignedFunction(active_menu.CloseMenuFunc))
				active_menu.CloseMenuFunc();//CloseCurrentMenu();			
		}*/
		
		input_cursorpos = 0;		
		input_cursorscreenpos = '0 0 0';
		active_input = false;//ACTIVE_INPUT = false;	
		active_textblock = false;
	//	if(active_menu == focusmenu)
	//		focusmenu = world;
	}	

	inputboxsize_x = inputsize_x;
	inputboxpos = pos;
	
	if(!inputsize_y)
		inputboxsize_y = body_fontsize_y + body_fontsize_y*0.4;//option_size_y;
	else
		inputboxsize_y = inputsize_y;
	
	drawfill(pos, inputboxsize, '0 0 0', 1, 0);
//	SetTextFormatting(FONTSIZE);	
	
	largeboxpos_x = pos_x;
	
	pos_x += body_fontsize_y*0.2; // linespace
	pos_y += body_fontsize_y*0.2; // linespace
	
	largeboxpos_y = pos_y;

	inputboxsize_x -= body_fontsize_y*0.4;
	inputboxsize_y -= body_fontsize_y*0.4;
	
	drawstringpos = pos;
//	posalign = AlignmentPos(pos, inputboxsize, input_fontsize, '0 0 0', '2 2 0');
//	drawstringpos_y = posalign_y;

	inpstr = substring(inputstring, stringpos, inputboxsize_x/input_fontsize_x);
	
//	drawstring(drawstringpos, inpstr, FONTSIZE, COLOR_CHAT_INPUT, ALPHA_CHAT, SFLAGS_CHAT);
	
	if(!pulldownmenu)
	if(GameControl(CTRL_MENUBUTTON1, 0))
	{	
		if(CursorInsideBox(largeboxpos, inputboxsize_x+body_fontsize_x*0.4, inputboxsize_y) && active_menu == currentmenu)// && cl_button == 512)
		{
			active_input = input_current;//ACTIVE_INPUT = INPUTCLASS;
			
			if(inputsize_y)
				active_textblock = true;
			
			input_cursorpos = (mousepos_x - pos_x)/input_fontsize_x - floor((mousepos_x - pos_x)/input_fontsize_x);
			
			if(input_cursorpos <= 0.5)
				input_cursorpos = floor((mousepos_x - pos_x)/input_fontsize_x);
			else
				input_cursorpos = ceil((mousepos_x - pos_x)/input_fontsize_x);
				
			if(inputsize_y)
			{
				totallines = GetBufferSize(active_menu.buf_textblock)-1;
				curline = min(totallines, floor((mousepos_y-pos_y)/input_fontsize_y));
				curlinestr = GetBufferString(active_menu.buf_textblock, curline);
				curlinelen = max(0, strlen(curlinestr)-8);
				startchar = GetLineStartCharacterNumber(curline);
				
				if(input_cursorpos > curlinelen)
					input_cursorpos = curlinelen;
				
				input_cursorpos += startchar;
				
				if(input_cursorpos > strlen(inputstring))
					input_cursorpos = strlen(inputstring);
			}
			else
			if(mousepos_x - pos_x > strlen(inpstr)*input_fontsize_x)
				input_cursorpos = strlen(inpstr);
							
			UpdateInputCursorPos(input_cursorpos + stringpos);
		}
		else
		if(active_input == input_current)//ACTIVE_INPUT == INPUTCLASS)
	//	if(logged)
		if(!active_vkb)
		{
			active_input = false;
			active_textblock = false;
			input_cursorpos = 0;
			input_cursorscreenpos = '0 0 0';
		}
	}
	
//	THIS IS FOR TEXT BLOCK INPUT
//	if(inputsize_y)
//		DrawTextBlock(largeboxpos, inputstring, inputsize, SCROLLTYPE_CURRENTMENU, INPUTCLASS, BOXNUM);
		
	
//	else
	if(active_menu == currentmenu && active_input == input_current)//ACTIVE_INPUT == INPUTCLASS && !(currentmenu && active_menu != currentmenu))
	{
		if(GameControl(CTRL_CONFIRM, 0) && !active_textblock)
		{
		//	tokenize(inputstring);
		//	if(argv(0) || substring(inputstring, 0, 2) == "//")
		//	{
			//	if(INPUTCLASS == INPUT_CHAT)
			//		SendChatInput(inputstring);
			//	else

				local float sentcmd;
				
			//	if(INPUTCLASS == INPUT_CHAT)
			//		sentcmd = ParseSlashCommands(inputstring);
				
			//	if(!sentcmd)
				if(IsAssignedFunction(InputFunc))
				{
					InputFunc();
					MenuSound(SOUND_CONFIRMCLICK);	
				}

				if(CLEARINPUT)
					inputstring = string_null;
				//	inputstring = freezone(inputstring);
				
			//	active_input = false;
		//	}

		/*	else // THIS IS FOR TEXT BLOCKS
			{
				s = strcat(substring(inputstring, 0, input_cursorpos), SEP_BR);
				s = strcat(s, substring(inputstring, input_cursorpos, strlen(inputstring) - input_cursorpos));
				input_cursorpos++;
				inputstring = zonecpy(inputstring, s);
			//	print(ftos(input_cursorpos));	print(" - ");	print(ftos(strlen(inputstring)));	print("\n");
				if(input_cursorpos == strlen(inputstring))
					active_menu.(scrollbar_alignment[BOXNUM]) = ALIGN_SENDTOBOTTOM;
			}*/
		}
		else
		if(GameControl(CTRL_MENUNAVIGATEUP, 0) && !active_vkb)
		{
			if(active_textblock)
			if(input_cursorscreenpos_y > 0)
			{
				curline = input_cursorscreenpos_y-1;
				startchar = GetLineStartCharacterNumber(curline);
				s = GetBufferString(active_menu.buf_textblock, curline);
				input_cursorpos = startchar + min(input_cursorscreenpos_x, strlen(s)-8);
				UpdateInputCursorPos(input_cursorpos);
			}				
		}
		else
		if(GameControl(CTRL_MENUNAVIGATEDOWN, 0) && !active_vkb)
		{
			if(active_textblock)
			if(input_cursorscreenpos_y < GetBufferSize(active_menu.buf_textblock)-1)
			{
				curline = input_cursorscreenpos_y+1;
				startchar = GetLineStartCharacterNumber(curline);
				s = GetBufferString(active_menu.buf_textblock, curline);
				input_cursorpos = startchar + min(input_cursorscreenpos_x, strlen(s)-8);
				UpdateInputCursorPos(input_cursorpos);
			}	
		}
		else
		if(GameControl(CTRL_MENUNAVIGATELEFT, 0) && !active_vkb)
		{
			if(input_cursorpos > 0)
				UpdateInputCursorPos(input_cursorpos-1);
		}
		else
		if(GameControl(CTRL_MENUNAVIGATERIGHT, 0) && !active_vkb)
		{
			if(input_cursorpos < strlen(inputstring))
				UpdateInputCursorPos(input_cursorpos+1);
		}
		else
		if(GameControl(CTRL_BACKSPACE, 0) || GameControl(CTRL_ESCAPE, 0))
		{
			if(input_cursorpos > 0)
			{
				s = substring(inputstring, 0, input_cursorpos - 1);
				s = strcat(s, substring(inputstring, input_cursorpos, strlen(inputstring) - input_cursorpos));
				inputstring = s;
		//		input_cursorpos -= 1;
				active_menu.buf_textblock = GenerateTextBlock(active_menu.buf_textblock, inputboxsize, inputstring, input_fontsize);				
				UpdateInputCursorPos(input_cursorpos-1);
				MenuSound(SOUND_TYPECLICK);
			}
		}
		else
		if(GameControl(CTRL_DELETE, 0))
		{
			s = substring(inputstring, 0, input_cursorpos);
			s = strcat(s, substring(inputstring, input_cursorpos + 1, strlen(inputstring) - input_cursorpos - 1));
			inputstring = s;
			if(active_textblock)
				active_menu.buf_textblock = GenerateTextBlock(active_menu.buf_textblock, inputboxsize, inputstring, input_fontsize);
			UpdateInputCursorPos(input_cursorpos);
			MenuSound(SOUND_TYPECLICK);
		}
		else
		if(cl_button_ucs > 0)
		if(!(INPUTTYPE == INPUTTYPE_NUMERICAL && !NumericalKey(cl_button_ucs)))
		if(!(INPUTTYPE == INPUTTYPE_TEXT && !TextKey(cl_button_ucs)))
		if(cl_button != K_BACKSPACE)
	//	if(cl_button_ucs != K_SEMICOLON)
		if(cl_button_ucs != K_ESCAPE)
		if(cl_button_ucs != K_TAB)
		if(cl_button_ucs != K_ENTER || active_textblock)
		if(cl_button_ucs != 94)// carrot
		if(cl_button_ucs != 37)// percent		
		if(cl_button_ucs != 34)//K_QUOTE)
	//	if(cl_button_ucs != K_TILDE)
		if(!(maxinputchars && strlen(inputstring) >= maxinputchars))
		{
			c = GetChrUCS(cl_button_ucs);
			
			if(vkb_uppercase)
			if(cl_button_ucs >= 48 && cl_button_ucs <= 57)
				c = GetSymbolForKey(cl_button_ucs);
			else
				c = strtoupper(c);
				
			charlen = strlen(c);
			s = strcat(substring(inputstring, 0, input_cursorpos), c);//InputChr(cl_button));
			s = strcat(s, substring(inputstring, input_cursorpos, strlen(inputstring) - input_cursorpos));
			inputstring = s;
			if(active_textblock)
				active_menu.buf_textblock = GenerateTextBlock(active_menu.buf_textblock, inputboxsize, inputstring, input_fontsize);
			UpdateInputCursorPos(input_cursorpos+charlen);
			MenuSound(SOUND_TYPECLICK);

		/*	if(BOXNUM >= 0)	//THIS IS FOR TEXT BLOCKS
			if(input_cursorpos == strlen(inputstring))
				active_menu.(scrollbar_alignment[BOXNUM]) = ALIGN_SENDTOBOTTOM;*/
		}
		
		if(!inputsize_y)
		{
			if(!inputstring_shift_disable)
			if(input_cursorpos > floor(inputboxsize_x/input_fontsize_x) - 1 + stringpos)
				stringpos = input_cursorpos - floor(inputboxsize_x/input_fontsize_x) + 1;
			else
			if(input_cursorpos < stringpos)
				stringpos = input_cursorpos;
				
			inpstr = substring(inputstring, stringpos, inputboxsize_x/input_fontsize_x);
		}		
	}
	else
	if(!active_textblock)
		inpstr = substring(inputstring, stringpos, inputboxsize_x/input_fontsize_x);

	if(inputsize_y)
	{
		if(!active_menu.buf_textblock)
			init = true;
	
		option_pos_start = option_pos;
	
		active_menu.buf_textblock = DrawTextBlock(active_menu.buf_textblock, option_pos, -1, inputboxsize, inputstring, input_fontsize, input_fontcolor, option_fontalpha, option_fontflags);
		
		option_pos = option_pos_start;
		
		if(init)
			UpdateInputCursorPos(input_cursorpos);
	}
	else
		drawstring(drawstringpos, inpstr, input_fontsize, input_fontcolor, option_fontalpha, option_fontflags);

	if(active_menu == currentmenu && active_input == input_current)
	{
		pos_x -= stringpos*input_fontsize_x;
		DrawTextCursor(pos);	
	}			
		
	if(!inputstring_shift_disable)
		inputstring_shift = stringpos;
	
	return inputstring;
}

void Menu_Borders(vector pos, vector bsize) =
{
	if(!border_size_x && !border_size_y)
		return;

	local vector barpos, barsize;

	if(border_appearance & BACKGROUND)
	{
		barpos = pos;
		barsize_x = bsize_x;
		barsize_y = border_size_y;
		drawfill(barpos, barsize, border_bgcolor, border_bgalpha, border_bgflags);
		barpos_y += bsize_y - border_size_y;
		drawfill(barpos, barsize, border_bgcolor, border_bgalpha, border_bgflags);
		barpos = pos;
		barpos_y += border_size_y;
		barsize_x = border_size_x;
		barsize_y = bsize_y - border_size_y*2;
		drawfill(barpos, barsize, border_bgcolor, border_bgalpha, border_bgflags);
		barpos_x += bsize_x - border_size_x;
		drawfill(barpos, barsize, border_bgcolor, border_bgalpha, border_bgflags);
		
		if(border_appearance & TITLE_FOOTER)
		{
			barpos = pos + border_size;
			barpos_y += title_size_y;
			barsize_x = bsize_x - border_size_x*2;
			barsize_y = border_size_y;
			drawfill(barpos, barsize, border_bgcolor, border_bgalpha, border_bgflags);
		}
	}

	if(border_appearance & IMAGE)
	{
		barpos = pos;
		barsize = border_size;	

		barsize_x = bsize_x;
		Menu_Image_Bordered(barpos, border_image_topleft, border_image_topright, border_image_top, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);		
		
/*		drawmenupic(barpos, border_image_topleft, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);
		barpos_x += barsize_x;
		barsize_x = bsize_x - border_size_x*2;
		drawmenupic(barpos, border_image_top, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);
		barpos_x += barsize_x;
		barsize = border_size;
		drawmenupic(barpos, border_image_topright, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);*/
		
		barpos_x = pos_x;
		barpos_y += barsize_y;		
		
		if(border_appearance & TITLE_FOOTER)
		{
			barsize = border_size;
			barsize_y = title_size_y;
			drawmenupic(barpos, border_image_titleleft, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);
			barpos_x += bsize_x - border_size_x;
			drawmenupic(barpos, border_image_titleright, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);
			barpos_x = pos_x;
			barpos_y += barsize_y;
			barsize = border_size;
			
			barsize_x = bsize_x;
			Menu_Image_Bordered(barpos, border_image_titlefooterleft, border_image_titlefooterright, border_image_titlefooter, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);		
			
/*			drawmenupic(barpos, border_image_titlefooterleft, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);
			barpos_x += barsize_x;
			barsize_x = bsize_x - border_size_x*2;
			drawmenupic(barpos, border_image_titlefooter, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);
			barpos_x += barsize_x;
			barsize_x = border_size_x;
			drawmenupic(barpos, border_image_titlefooterright, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);*/
			
			barpos_x = pos_x;
			barpos_y += barsize_y;
			barsize = border_size;
			barsize_y = bsize_y - border_size_y*3 - title_size_y;
			drawmenupic(barpos, border_image_bodyleft, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);
			barpos_x += bsize_x - border_size_x;
			drawmenupic(barpos, border_image_bodyright, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);
		}
		else
		{		
			barsize = border_size;
			barsize_y = bsize_y - border_size_y*2;
			drawmenupic(barpos, border_image_left, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);
			barpos_x += bsize_x - border_size_x;
			drawmenupic(barpos, border_image_right, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);
		}
		
		barpos_x = pos_x;
		barpos_y += barsize_y;
		barsize = border_size;
		
		barsize_x = bsize_x;
		Menu_Image_Bordered(barpos, border_image_bottomleft, border_image_bottomright, border_image_bottom, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);		
		
/*		drawmenupic(barpos, border_image_bottomleft, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);
		barpos_x += barsize_x;
		barsize_x = bsize_x - border_size_x*2;
		drawmenupic(barpos, border_image_bottom, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);
		barpos_x += barsize_x;
		barsize_x = border_size_x;
		drawmenupic(barpos, border_image_bottomright, barsize, border_imagecolor, border_imagealpha, border_imageflags, border_appearance);*/
	}
}

void Menu_Title(string title, vector pos, vector bsize) =
{
	if(!title_size_y)
		return;
		
	local vector imgsize, bgsize, bgpos;

//	SetFont(title_font);	
	drawfont = title_font;
		
	title_size_x = bsize_x - border_size_x*2;
	pos += border_size + title_image_offset;
	if(title_appearance & BACKGROUND)
	{
		bgsize_x = title_size_x;
		bgsize_y = title_size_y;
		bgsize_x += title_bgspread_x;
		bgsize_y += title_bgspread_y*0.5;
		bgpos = pos;
		bgpos -= title_bgspread*0.5;		
	
		drawfill(bgpos, bgsize, title_bgcolor, title_bgalpha, title_bgflags);
	}

	if(title_image != "")
	{
		if(title_appearance & IMAGE_FULLMENU)
			imgsize = active_menu.menusize;
		else
			imgsize = title_size;
		
		Menu_Image_Bordered(pos, title_image_left, title_image_right, title_image, imgsize, title_imagecolor, title_imagealpha, title_imageflags, title_appearance);		
	//	drawmenupic(pos, title_image, imgsize, title_imagecolor, title_imagealpha, title_imageflags, title_appearance);
	}

	if(title != "")
	{
	//	pos = TextAlignmentPos(title, pos, title_size, title_fontsize, title_textalignment, title_textbordersize);	
	//	drawfill(pos, title_fontsize, '1 0 0', 1, 0);
		DrawString_MenuContents(pos, title, title_fontsize, title_fontcolor, title_fontalpha, title_fontflags, title_size, title_textbordersize, title_textalignment);
	}
}

void Menu_Body(vector pos, vector bsize) =
{
//	SetFont(body_font);
//	drawfont = body_font;

	bsize_x -= border_size_x*2;
	bsize_y -= title_size_y + border_size_y*3;
	pos_x += border_size_x;
	pos_y += title_size_y+border_size_y;
	
	bsize_x += body_bgspread_x;
	bsize_y += body_bgspread_y*0.5;
	pos_x -= body_bgspread_x*0.5;
	
	if(body_appearance & BACKGROUND)
		drawfill(pos, bsize, body_bgcolor, body_bgalpha, body_bgflags);	

	if(body_appearance & IMAGE || body_appearance & IMAGE_STRETCH)
	if(body_bgimage != "")
		drawmenupic(pos, body_bgimage, bsize, body_bgimagecolor, body_bgimagealpha, body_bgimageflags, body_appearance);	
}

float BeginScrollingWindow(vector vec, vector scrollboxsize, float SCROLLTYPE, float BOXNUM) =
{
	local vector pos, scrollbarpos, scrollbarhandlesize, scrollbarsize, scrollbarhandle_ofs, vecalign, toparrowimagesize, bottomarrowimagesize, scrollbarimagesize, scrollbarhandleimagesize;
	local float scrollheight, scrollbarhandle_align, height;
	
	vecalign = BoxAlignmentPos(vec, scrollboxsize, body_alignment, 0, '0 0 0');
	vec_x = vecalign_x;
	
	scrollheight = active_menu.(scrollbar_height[BOXNUM]);
	scrollbarhandle_align = active_menu.(scrollbar_alignment[BOXNUM]);
	scrollbarsize = active_menu.(scrollbar_size[BOXNUM]);
	scrollbarhandle_ofs = active_menu.(scrollbar_ofs[BOXNUM]);
	
	if(scrollheight > scrollboxsize_y)
	{
		toparrowimagesize = drawgetimagesize(scrollbar_toparrowimage);
		bottomarrowimagesize = drawgetimagesize(scrollbar_bottomarrowimage);
		scrollbarimagesize = drawgetimagesize(scrollbar_image);
		scrollbarhandleimagesize = drawgetimagesize(scrollbar_handleimage);
		scrollbarpos = vec;// + '0 10 0';
		scrollbarpos_y += toparrowimagesize_y;
		scrollbarpos_x += scrollboxsize_x;
		scrollbarsize_x = scrollbarimagesize_x;
		scrollbarsize_y = scrollboxsize_y - toparrowimagesize_y - bottomarrowimagesize_y;
		
		scrollbarhandlesize_x = scrollbarhandleimagesize_x;
		scrollbarhandlesize_y = scrollboxsize_y/scrollheight*scrollbarsize_y;

		if(scrollbarhandle_align) //prime this the first time the menu is called
		{
			scrollbarhandle_ofs_x = 0;
			
			if(scrollbarhandle_align == ALIGN_TOP)
				scrollbarhandle_ofs_y = 0;
			else
			if(scrollbarhandle_align == ALIGN_BOTTOM)
				scrollbarhandle_ofs_y = scrollbarsize_y - scrollbarhandlesize_y;

			if(scrollbarhandle_align == ALIGN_SENDTOBOTTOM)
				scrollbarhandle_align = ALIGN_BOTTOM;
			else
				scrollbarhandle_align = false;
		}
	}
	
	if(scrollbarhandle_ofs_y >= scrollbarsize_y - scrollbarhandlesize_y || gotobottomofscrollingwindow)
	{
		if(gotobottomofscrollingwindow)
			gotobottomofscrollingwindow -= 1;
		atbottomofscrollingwindow = true;
		scrollbarhandle_ofs_y = scrollbarsize_y - scrollbarhandlesize_y;
	}
	else
		atbottomofscrollingwindow = false;

//	drawfill(vec, scrollboxsize, '0 0 0', body_bgalpha, 0);
//	drawfill(scrollbarpos, scrollbarsize, '0.5 0 0', 1, 0);	
	if(scrollbarsize != '0 0 0')
	{
		pos = scrollbarpos;
		pos_y -= toparrowimagesize_y;
		drawpic(pos, scrollbar_toparrowimage, toparrowimagesize, '1 1 1', 1, 0);
		drawpic(scrollbarpos, scrollbar_image, scrollbarsize, '1 1 1', 1, 0);
		pos = scrollbarpos;
		pos_y += scrollbarsize_y;
		drawpic(pos, scrollbar_bottomarrowimage, bottomarrowimagesize, '1 1 1', 1, 0);

		
	}

	drawsetcliparea(vec_x, vec_y, scrollboxsize_x, scrollboxsize_y);
	
	local float scrollspace, scrollofs, scrollpercent;
	scrollspace = scrollbarsize_y - scrollbarhandlesize_y;
	scrollofs = scrollbarhandle_ofs_y;
	if(scrollspace)
		scrollpercent = scrollofs/scrollspace;
	
	active_menu.(scrollbar_boxpos[BOXNUM]) = vec;
	active_menu.(scrollbar_boxsize[BOXNUM]) = scrollboxsize;
	active_menu.(scrollbar_pos[BOXNUM]) = scrollbarpos;
	active_menu.(scrollbar_handlesize[BOXNUM]) = scrollbarhandlesize;
	active_menu.(scrollbar_size[BOXNUM]) = scrollbarsize;
	active_menu.(scrollbar_ofs[BOXNUM]) = scrollbarhandle_ofs;
	active_menu.(scrollbar_height[BOXNUM]) = scrollheight;
	active_menu.(scrollbar_alignment[BOXNUM]) = scrollbarhandle_align;
	
	height = vec_y - (scrollheight-scrollboxsize_y)*scrollpercent;
	height = rint(height*100)/100;
	
	return height;
}

void EndScrollingWindow(float dist, float SCROLLTYPE, float BOXNUM) =
{
	local vector pos, scrollbarpos, scrollbarhandlesize, scrollbarsize, scrollbarhandle_ofs, toparrowimagesize, bottomarrowimagesize, scrollbarboxpos, scrollbarboxsize;
	local float scrollheight;
	
	if(active_menu)
	{
		scrollbarboxpos = active_menu.(scrollbar_boxpos[BOXNUM]);
		scrollbarboxsize = active_menu.(scrollbar_boxsize[BOXNUM]);
		scrollbarpos = active_menu.(scrollbar_pos[BOXNUM]);
		scrollbarhandlesize = active_menu.(scrollbar_handlesize[BOXNUM]);
		scrollbarsize = active_menu.(scrollbar_size[BOXNUM]);
		scrollbarhandle_ofs = active_menu.(scrollbar_ofs[BOXNUM]);
	}
	
	drawresetcliparea();	

	scrollheight = dist;
	
	if(active_menu == currentmenu)
	if(!WINDOWSCROLL)
	{
		if(scrollbar_incrementsize)
		{
			local float percent, scrollbarplay, inbox;
			
			percent = scrollbar_incrementsize/dist;
		//	scrollbarplay = scrollbarsize_y - scrollbarhandlesize_y;
			scrollbar_incrementsize = scrollbarsize_y*percent;

			inbox = CursorInsideBox(scrollbarboxpos, scrollbarboxsize_x, scrollbarboxsize_y);
		//	if()
		//	{
		//		print("down a\n");
			if((GameControl(CTRL_MENUSCROLLWINDOWUP, 0) && inbox) || (GameControl(CTRL_MENUNAVIGATEUP, 0) && (active_menu.user_current_option == optionnum_min-1 || selectedtextlist)) || scrollwindow_up)
			{
				scrollbarhandle_ofs_y -= scrollbar_incrementsize*max(scrollwindow_up, 1);
			//	if(!scrollwindow_up)
			//		MenuSound(SOUND_SCROLLBARCLICK);
			}
			else
			if((GameControl(CTRL_MENUSCROLLWINDOWDOWN, 0) && inbox) || (GameControl(CTRL_MENUNAVIGATEDOWN, 0) && (active_menu.user_current_option == optionnum_max-1 || selectedtextlist)) || scrollwindow_down)
			{
				scrollbarhandle_ofs_y += scrollbar_incrementsize*max(scrollwindow_down, 1);
			//	if(!scrollwindow_down)
			//		MenuSound(SOUND_SCROLLBARCLICK);
			}
			

			toparrowimagesize = drawgetimagesize(scrollbar_toparrowimage);
			bottomarrowimagesize = drawgetimagesize(scrollbar_bottomarrowimage);			
			
			pos = scrollbarpos;
			pos_y -= toparrowimagesize_x;
			if(CursorInsideBox(pos, toparrowimagesize_x, toparrowimagesize_y))
			if(GameControl(CTRL_MENUBUTTON1, -1))
				scrollbarhandle_ofs_y -= scrollbar_incrementsize*max(scrollwindow_up, 1);
	
			pos = scrollbarpos;
			pos_y += scrollbarsize_y;
			if(CursorInsideBox(pos, bottomarrowimagesize_x, bottomarrowimagesize_y))
			if(GameControl(CTRL_MENUBUTTON1, -1))
				scrollbarhandle_ofs_y += scrollbar_incrementsize*max(scrollwindow_down, 1);
		}
	
		if(CursorInsideBox(scrollbarpos + scrollbarhandle_ofs, scrollbarsize_x, scrollbarhandlesize_y))
		{
		//	if(active_menu == menuundercursor)
//			if(cl_button == K_MOUSE1)
			if(GameControl(CTRL_MENUBUTTON1, 0))
			{
				WINDOWSCROLL = BOXNUM+1;
				mousedrag_ofs_y = mousepos_y - scrollbarpos_y - scrollbarhandle_ofs_y;
			}
		}
	}
	else
	{
		if(!GameControl(CTRL_MENUBUTTON1, 1))
		{
			WINDOWSCROLL = false;
			mousedrag_ofs = '0 0 0';
		}
		else
		if(WINDOWSCROLL-1 == BOXNUM)
			scrollbarhandle_ofs_y = mousepos_y - mousedrag_ofs_y - scrollbarpos_y;
	}

	if(scrollbarhandle_ofs_y < 0)
		scrollbarhandle_ofs_y = 0;
	else
	if(scrollbarhandle_ofs_y+scrollbarhandlesize_y > scrollbarsize_y)
		scrollbarhandle_ofs_y = scrollbarsize_y-scrollbarhandlesize_y;	
	
	if(active_menu)
	{
		active_menu.oldscrollbar_ofs = active_menu.(scrollbar_ofs[BOXNUM]);
		active_menu.(scrollbar_ofs[BOXNUM]) = scrollbarhandle_ofs;
		active_menu.(scrollbar_height[BOXNUM]) = scrollheight;	
	}
	
	scrollbarhandle_ofs_x += (scrollbarsize_x - scrollbarhandlesize_x)*0.5;
	drawpic(scrollbarpos + scrollbarhandle_ofs, "gfx/menu/vert_slider.tga", scrollbarhandlesize, '1 1 1', 1, 0);
	
	scrollbar_incrementsize = 0;
	scrollwindow_up = scrollwindow_down = false;	
}

void ResetScrollingWindow() =
{
	currentmenu.scrollbar_boxpos = '0 0 0';
	currentmenu.scrollbar_boxsize = '0 0 0';
	currentmenu.scrollbar_pos = '0 0 0';
	currentmenu.scrollbar_handlesize = '0 0 0';
	currentmenu.scrollbar_size = '0 0 0';
	currentmenu.scrollbar_ofs = '0 0 0';
	currentmenu.scrollbar_height = 0;
	currentmenu.scrollbar_alignment = 0;
	atbottomofscrollingwindow = false;
	gotobottomofscrollingwindow = false;
}

void PrevMenuPage() =
{
	active_menu.page_current = active_menu.page_current - 1;
	
	if(active_menu.page_current < 0)
		active_menu.page_current = active_menu.page_total-1;
}

void NextMenuPage() =
{
	active_menu.page_current = active_menu.page_current + 1;
	
	if(active_menu.page_current > active_menu.page_total-1)
		active_menu.page_current = 0;
}