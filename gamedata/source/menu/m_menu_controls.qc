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
void UpdateBindMap() =
{
	ClearAllInputValues();
//	localcmd("in_bindmap 0 0\n");
	setbindmaps('0 0 0');
}

void ToggleMouseInversion() =
{
	local float m_pitch;
	m_pitch = cvar("m_pitch");
	m_pitch = -m_pitch;
	cvar_set("m_pitch", ftos(m_pitch));
}

void ClearBindsForControl(float ctrlid, float blockdefaultbind) =
{
	local float bindmap, count, keynum, emptybindcount;
	local string keynums, key, bindstring, blankbindstring;

	bindmap = GetBindMapForControlID(ctrlid);
	bindstring = GetBindForControlID(ctrlid);
	
	if(blockdefaultbind)
		blankbindstring = " ";
	else
		blankbindstring = "";
	
	for(keynums = findkeysforcommand(bindstring, bindmap); emptybindcount < 5; keynums = findkeysforcommand(bindstring, bindmap))
	{
		emptybindcount = 0;
		tokenize(keynums);
		for(count = 0; count < 5; count++)
		{
			keynum = stof(argv(count));

			if(keynum != -1)
				setkeybind_bindmap(keynum, blankbindstring, bindmap);	
			else
				emptybindcount++;
		}	
	}
}

void SetNewControlKey() =
{
	local string bind;
	local float bindmap;

	if(cl_button <= 0)
		return;
		
	if(GameControl(CTRL_BACKSPACE, -1))		
		return;

	if(cl_button == stringtokeynum("JOY_UP"))					return;
	if(cl_button == stringtokeynum("JOY_DOWN"))					return;
	if(cl_button == stringtokeynum("JOY_LEFT"))					return;
	if(cl_button == stringtokeynum("JOY_RIGHT"))				return;
	if(cl_button == stringtokeynum("X360_BACK"))				return;	
	if(cl_button == stringtokeynum("X360_LEFT_THUMB_UP"))		return;
	if(cl_button == stringtokeynum("X360_LEFT_THUMB_DOWN"))		return;
	if(cl_button == stringtokeynum("X360_LEFT_THUMB_LEFT"))		return;
	if(cl_button == stringtokeynum("X360_LEFT_THUMB_RIGHT"))	return;
	if(cl_button == stringtokeynum("X360_RIGHT_THUMB_UP"))		return;
	if(cl_button == stringtokeynum("X360_RIGHT_THUMB_DOWN"))	return;
	if(cl_button == stringtokeynum("X360_RIGHT_THUMB_LEFT"))	return;
	if(cl_button == stringtokeynum("X360_RIGHT_THUMB_RIGHT"))	return;	
		
	if(GameControl(CTRL_BACKSPACE, 0))
		ClearBindsForControl(active_menu.listid, true);
	else
	{
		bind = GetBindForControlID(active_menu.listid);
		bindmap = GetBindMapForControlID(active_menu.listid);
		
		setkeybind_bindmap(cl_button, bind, bindmap);
		CloseMenu();
	//	settingkeybind = false;
	}

	SaveProfileConfig();
}

void SetDefaultControl(float ctrlid, float keynum, float clearcontrol) =
{
	local float bindmap;
	local string bind;

	if(clearcontrol)
		ClearBindsForControl(ctrlid, false);
	bind = GetBindForControlID(ctrlid);
	bindmap = GetBindMapForControlID(ctrlid);
	setkeybind_bindmap(keynum, bind, bindmap);
}

void ControlsPostReset() =
{
	SaveProfileConfig();
	CloseMenu();
}

void ResetEditorControls_Apply() =
{
	SetDefaultControl(CTRL_EDITORMOVEFORWARD, stringtokeynum("w"), true);
	SetDefaultControl(CTRL_EDITORMOVELEFT, stringtokeynum("a"), true);
	SetDefaultControl(CTRL_EDITORMOVERIGHT, stringtokeynum("d"), true);
	SetDefaultControl(CTRL_EDITORMOVEBACK, stringtokeynum("s"), true);
	SetDefaultControl(CTRL_OBJECTPITCHSUBTRACT, stringtokeynum(","), true);
	SetDefaultControl(CTRL_OBJECTPITCHADD, stringtokeynum("."), true);
	SetDefaultControl(CTRL_OBJECTYAWSUBTRACT, stringtokeynum("]"), true);
	SetDefaultControl(CTRL_OBJECTYAWADD, stringtokeynum("["), true);
	SetDefaultControl(CTRL_RESETOBJECTPITCH, stringtokeynum("/"), true);
	SetDefaultControl(CTRL_ZOOMIN, K_MWHEELUP, true);
	SetDefaultControl(CTRL_ZOOMOUT, K_MWHEELDOWN, true);
	SetDefaultControl(CTRL_EDITORBUTTON1, K_MOUSE1, true);
	SetDefaultControl(CTRL_EDITORBUTTON2, K_MOUSE2, true);	
}

void ResetEditorControls() =
{
	ResetEditorControls_Apply();
	ControlsPostReset();
}

void ResetInputSettings_Apply() =
{
	cvar_set("sensitivity", "5");
//	cvar_set("joy_sensitivityforward", "-1");
//	cvar_set("joy_sensitivityside", "1");
	cvar_set("joy_sensitivityyaw", "-1");
	cvar_set("joy_deadzoneforward", "0.266");
	cvar_set("joy_deadzoneside", "0.266");
	cvar_set("joy_deadzoneyaw", "0.266");	
	cvar_set("joy_axisforward", "1");
	cvar_set("joy_axisside", "0");
	cvar_set("joy_axisyaw", "2");
	
	cvar_set("joy_x360_sensitivityyaw", "-1");
	cvar_set("joy_x360_deadzoneforward", "0.266");
	cvar_set("joy_x360_deadzoneside", "0.266");
	cvar_set("joy_x360_deadzoneyaw", "0.266");	
	cvar_set("joy_x360_axisforward", "1");
	cvar_set("joy_x360_axisside", "0");
	cvar_set("joy_x360_axisyaw", "2");
}

void ResetInputSettings() =
{
	ResetInputSettings_Apply();
	ControlsPostReset();
}

void ResetMiscControls_Apply() =
{
	SetDefaultControl(CTRL_TOGGLELIVESCORES, K_TAB, true);
	SetDefaultControl(CTRL_TOGGLEMISSIONMAP, stringtokeynum("M"), true);
	SetDefaultControl(CTRL_TOGGLEMISSIONBRIEFING, stringtokeynum("I"), true);
	SetDefaultControl(CTRL_TOGGLEMISSIONBRIEFING, stringtokeynum("B"), false);
	SetDefaultControl(CTRL_VOTEYES, stringtokeynum("9"), true);
	SetDefaultControl(CTRL_VOTENO, stringtokeynum("0"), true);
	SetDefaultControl(CTRL_TALK, stringtokeynum("T"), true);
	SetDefaultControl(CTRL_TALK_TEAM, stringtokeynum("Y"), true);	
	SetDefaultControl(CTRL_TOGGLECAMMODE, stringtokeynum("Q"), true);

	#ifndef COMPILE_SERVICE_ONLIVE
		SetDefaultControl(CTRL_TOGGLELIVESCORES, stringtokeynum("JOY10"), false);	
		SetDefaultControl(CTRL_TOGGLEMISSIONMAP, stringtokeynum("JOY4"), false);
		SetDefaultControl(CTRL_TOGGLEMISSIONBRIEFING, stringtokeynum("JOY1"), false);	
		SetDefaultControl(CTRL_TOGGLEMISSIONBRIEFING, stringtokeynum("JOY3"), false);	
		SetDefaultControl(CTRL_TOGGLECAMMODE, stringtokeynum("JOY11"), false);	
	#endif	
	
	SetDefaultControl(CTRL_TOGGLELIVESCORES, stringtokeynum("X360_START"), false);		
	SetDefaultControl(CTRL_TOGGLEMISSIONMAP, stringtokeynum("X360_Y"), false);	
	SetDefaultControl(CTRL_TOGGLEMISSIONBRIEFING, stringtokeynum("X360_B"), false);		
	SetDefaultControl(CTRL_TOGGLEMISSIONBRIEFING, stringtokeynum("X360_X"), false);	
	SetDefaultControl(CTRL_TOGGLECAMMODE, stringtokeynum("X360_LEFT_THUMB"), false);	
}

void ResetMiscControls() =
{
	ResetMiscControls_Apply();
	ControlsPostReset();
}

void ResetPlayerControls_Apply() =
{
	SetDefaultControl(CTRL_FIREPRIMARY, K_MOUSE1, true);	
	SetDefaultControl(CTRL_FIRESECONDARY, K_MOUSE2, true);	
	SetDefaultControl(CTRL_FIRESHOCKWAVE, K_SPACE, true);	
	SetDefaultControl(CTRL_TOGGLESECONDARY, K_SHIFT, true);	
	SetDefaultControl(CTRL_MOVEFORWARD, stringtokeynum("W"), true);	
	SetDefaultControl(CTRL_MOVELEFT, stringtokeynum("A"), true);	
	SetDefaultControl(CTRL_MOVERIGHT, stringtokeynum("D"), true);	
	SetDefaultControl(CTRL_MOVEBACK, stringtokeynum("S"), true);

	#ifndef COMPILE_SERVICE_ONLIVE
		SetDefaultControl(CTRL_FIREPRIMARY, stringtokeynum("JOY8"), false);		
		SetDefaultControl(CTRL_FIRESECONDARY, stringtokeynum("JOY7"), false);	
		SetDefaultControl(CTRL_FIRESHOCKWAVE, stringtokeynum("JOY6"), false);	
		SetDefaultControl(CTRL_TOGGLESECONDARY, stringtokeynum("JOY2"), false);
		SetDefaultControl(CTRL_TOGGLESECONDARY, stringtokeynum("JOY5"), false);		
	#endif
	
	SetDefaultControl(CTRL_FIREPRIMARY, stringtokeynum("X360_RIGHT_TRIGGER"), false);	
	SetDefaultControl(CTRL_FIRESECONDARY, stringtokeynum("X360_LEFT_TRIGGER"), false);	
	SetDefaultControl(CTRL_FIRESHOCKWAVE, stringtokeynum("X360_RIGHT_THUMB"), false);	
	SetDefaultControl(CTRL_FIRESHOCKWAVE, stringtokeynum("X360_RIGHT_SHOULDER"), false);
	SetDefaultControl(CTRL_TOGGLESECONDARY, stringtokeynum("X360_LEFT_SHOULDER"), false);	
	SetDefaultControl(CTRL_TOGGLESECONDARY, stringtokeynum("X360_A"), false);		
}

void ResetPlayerControls() =
{
	ResetPlayerControls_Apply();
	ControlsPostReset();
}

void ResetControlSettingsAll() =
{
	ResetPlayerControls_Apply();		
	ResetMiscControls_Apply();		
	ResetEditorControls_Apply();	
	ResetInputSettings_Apply();
	ControlsPostReset();
}

void Draw_ResetControlSettings() =
{
	Menu_Start_OptionMenu("Reset?", '230 230 0', __FUNC__);	
	Menu_Option_Text("Reset Player Controls", ResetPlayerControls);		
	Menu_Option_Text("Reset Misc Controls", ResetMiscControls);

	#ifdef COMPILE_SERVICE_ONLIVE
		SkipTranslations(1);
	#else
		Menu_Option_Text("Reset Editor Controls", ResetEditorControls);	
	#endif
	
	Menu_Option_Text("Reset Input Settings", ResetInputSettings);
	Menu_Option_Text("Reset All", ResetControlSettingsAll);		
	BeginBottomButtons(1);
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_BASIC);		
	EndBottomButtons();
	
	Menu_End();	
}

void Call_ResetControlSettings() =	{	SetCurrentMenu(Draw_ResetControlSettings);	}

void CloseMenuFunc_GetNewControlKey() =
{
	settingkeybind = false;
}

void Draw_GetNewControlKey() =
{
	Menu_Start_ConfirmationMenu("Set Control", '0 0 0', __FUNC__);
	
	body_fontsize = '14 14 0';//*languagefontscale;
	body_fontcolor = '1 1 1';	
	
	skiptranslation = true;
	Menu_Text(GetBufferString(active_menu.buf_list, 0));//active_menu.listitemstring);	
	BR();
	
	body_fontsize = '10 10 0'*languagefontscale;
	body_fontcolor = '0.5 0.5 0.5';	
	
	Menu_Text(GetKeyForControlID(active_menu.listid));	
	skiptranslation = false;
	BR();
	
	body_fontsize = '14 14 0';
	body_fontcolor = '1 1 1';
	Menu_Text("PRESS NEW KEY");
	BR();
	
	SetNewControlKey();
	
	Menu_End();
}

void Call_GetNewControlKey() =
{
	SetCurrentMenu(Draw_GetNewControlKey);
	currentmenu.CloseMenuFunc = CloseMenuFunc_GetNewControlKey;
	currentmenu.listid = currentmenu.parentmenu.listid;
	currentmenu.buf_list = CreateBuffer();
	AddBufferString(currentmenu.buf_list, currentmenu.parentmenu.listitemstring, 0);
	settingkeybind = true;
//	currentmenu.listitemstring = currentmenu.parentmenu.listitemstring;
}

/*void DrawElement_ControlKeySettingOld(string controlname, float ctrlid) =
{
	active_menu.listid = ctrlid;
	active_menu.listitemstring = controlname;
	
	Menu_Option_Text(controlname, Call_GetNewControlKey);
	option_pos = GetLastLinePos();
	option_pos_x += option_infospacing;
	Menu_Text(GetKeyForControlID(ctrlid));//GetKeyForBind(GetBindForControlID(ctrlid)));
	option_pos_x -= option_infospacing;
	BR();	
}*/

void DrawElement_ControlTitle(string title, float width, float ALIGN) =
{
	local vector size, option_size_old, oldbody_imagecolor;
	local float oldbody_imagealpha;
	
	size_y = option_size_y;
	size_x = width;

	oldbody_imagealpha = body_imagealpha;
	oldbody_imagecolor = body_imagecolor;
	
//	if(active_menu.user_current_option >= optionhighlightrange_low && active_menu.user_current_option <= optionhighlightrange_high)
//	{
//		body_imagealpha = option_imagealpha_highlight;
//		body_imagecolor = option_imagecolor_highlight;
//	}
//	else
//	{
		body_imagealpha = option_imagealpha;
		body_imagecolor = option_imagecolor;
//	}

	Menu_Image_Bordered_Body("gfx/menu/rm_underlay_left.tga", "gfx/menu/rm_underlay_right.tga", "gfx/menu/rm_underlay_mid.tga", size);
	
	body_imagealpha = oldbody_imagealpha;
	body_imagecolor = oldbody_imagecolor;
	
	option_size_old = option_size;
	option_size_x = width;
	TempMenuSetting_body_textbordersize('12 0 0');
	Menu_AlignedText(title, ALIGN);
	RestoreMenuSetting_body_textbordersize();
	option_size = option_size_old;
	BR();
}

void DrawElement_ControlKeySetting(float ctrlid, string ctrlname, float width) =
{
	option_size_x = width;
	active_menu.listid = ctrlid;
	active_menu.listitemstring = ctrlname;
	Menu_Option_Text(GetShortKeyListForControlID(ctrlid, true), Call_GetNewControlKey);
}

void SetControlsMenuTabSelectionColors() =
{
	option_fontcolor_highlight	= '0 1 1';
	option_fontcolor			= '0 0.8 0.8';
	option_imagecolor			= '0 0.8 0.8';
	option_imagecolor_highlight	= '0 1 1';
}

void ResetControlsMenuTabSelectionColors() =
{
	option_fontcolor_highlight	= '1 1 1';
	option_fontcolor			= '0.8 0.8 0.8';
	option_imagecolor			= '1 1 1';
	option_imagecolor_highlight	= '1 1 1';	
}

void DrawControlsMenuHeader(float menunum, float lastbutton, float lastheaderoption) =
{
	if(LOCALIZE_GENERATING)
	if(menunum)
		return;

	local float buttonwidth, translate, spacemultiple;
	local string filename;
	
	translate = skiptranslation;
	skiptranslation = false;
	
	filename = __FUNC__;
	buf_localizecontrolsmenuheader = InitializeNonstandardTranslations(buf_localizecontrolsmenuheader, filename, false);
	
	local string str_player, str_misc, str_gamepad, str_editor;
	
	str_player	= Localize("Player", buf_localizecontrolsmenuheader);
	str_misc	= Localize("Misc", buf_localizecontrolsmenuheader);
	str_editor	= Localize("Editor", buf_localizecontrolsmenuheader);
	str_gamepad	= Localize("Input", buf_localizecontrolsmenuheader);	
	WriteNonstandardTranslations(buf_localizecontrolsmenuheader, filename, false, false);
	
	skiptranslation = true;
	
	buttonwidth = 80;
	
	SetOptionImages_AltSettings_1();
	ResetControlsMenuTabSelectionColors();	
	option_spacing = 2;	
	
	if(menunum == 1)	SetControlsMenuTabSelectionColors();
	HorizontalListButton(0, buttonwidth, str_player, Call_ControlsMenu_Player, lastbutton, lastheaderoption+1, lastheaderoption, 0, MBT_BASIC);
	ResetControlsMenuTabSelectionColors();
	
	if(menunum == 2)	SetControlsMenuTabSelectionColors();	
	HorizontalListButton(buttonwidth+option_spacing, buttonwidth, str_misc, Call_ControlsMenu_Misc, lastbutton, lastheaderoption+1, 0, 0, MBT_BASIC);	
	ResetControlsMenuTabSelectionColors();

	#ifndef COMPILE_SERVICE_ONLIVE
		if(menunum == 3)	SetControlsMenuTabSelectionColors();
		HorizontalListButton((buttonwidth+option_spacing)*2, buttonwidth, str_editor, Call_ControlsMenu_Editor, lastbutton, lastheaderoption+1, 0, 0, MBT_BASIC);
		ResetControlsMenuTabSelectionColors();
	#endif	
	
	if(menunum == 4)	SetControlsMenuTabSelectionColors();
	if(lastheaderoption == 3)
		spacemultiple = 2;
	else
		spacemultiple = 3;
	HorizontalListButton((buttonwidth+option_spacing)*spacemultiple, buttonwidth, str_gamepad, Call_ControlsMenu_Input, lastbutton, lastheaderoption+1, 0, 1, MBT_BASIC);	
	ResetControlsMenuTabSelectionColors();
	
	option_fontcolor			= '1 1 1';
	SetOptionImages_Settings_Default();
	
	BR();
	drawline(1, option_pos, option_pos + '420 0 0', '0 0.4 0.4', 0.8, 0);
	option_pos_y += 10;
	
	skiptranslation = translate;
}

void Draw_ControlsMenu_Editor() =
{
	local vector option_pos_start, imgsize, bgimgofs_cam, bgimgofs_rot, line_point1, line_point2;
	local float buttontitlewidth, controlbuttonwidth, linealpha, linewidth;
	local string imgname;
	
	linewidth = 2;
	
	buttontitlewidth = 160;
	controlbuttonwidth = 110;
	
	Menu_Start_ESCMenu("Editor Controls", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	
	DrawControlsMenuHeader(3, 19, 4);
	
	option_pos_start = option_pos;

	bgimgofs_cam = MenuPosition() + '130 87 0';
	bgimgofs_rot = MenuPosition() + '147 228 0';
	
	imgname = "gfx/menu/icon_move_camera.tga";
	imgsize = drawgetimagesize(imgname);
	drawpic(bgimgofs_cam, imgname, imgsize, body_imagecolor, body_imagealpha, body_imageflags);

	imgname = "gfx/menu/icon_rotate_object.tga";
	imgsize = drawgetimagesize(imgname);
	drawpic(bgimgofs_rot, imgname, imgsize, body_imagecolor, body_imagealpha, body_imageflags);	
	
//	body_textbordersize			= '12 0 0';	
	option_image				= "gfx/menu/rm_field_mid_hl.tga";		
	option_image_left			= "gfx/menu/rm_field_left_hl.tga";
	option_image_right			= "gfx/menu/rm_field_right_hl.tga";	
	option_image_highlight		= "gfx/menu/rm_field_mid_hl.tga";
	option_image_left_highlight	= "gfx/menu/rm_field_left_hl.tga";
	option_image_right_highlight = "gfx/menu/rm_field_right_hl.tga";	
	option_spacing = 2;

	option_fontcolor_highlight	= '0 1 1';
	option_imagecolor = option_imagecolor_highlight = '0.34 0.66 0.72';		
	DrawElement_ControlTitle("Camera Movement", buttontitlewidth, ALIGN_LEFT);
	optionalt_up = 3;
	DrawElement_ControlKeySetting(CTRL_EDITORMOVEFORWARD, "Move Camera Forward", controlbuttonwidth);
	optionalt_up = 0;	
		if(active_menu.user_current_option == option_current-1)
			linealpha = option_imagealpha_highlight;
		else
			linealpha = option_imagealpha;		
		line_point1 = option_pos; line_point1_x += option_size_x; line_point1_y -= option_size_y;			
		line_point2 = line_point1; line_point2_x += 40;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point1 = bgimgofs_cam + '39 12 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);		
	
	DrawElement_ControlKeySetting(CTRL_EDITORMOVELEFT, "Move Camera Left", controlbuttonwidth);	
		if(active_menu.user_current_option == option_current-1)
			linealpha = option_imagealpha_highlight;
		else
			linealpha = option_imagealpha;		
		line_point1 = option_pos; line_point1_x += option_size_x; line_point1_y -= option_size_y;			
		line_point2 = line_point1; line_point2_x += 20;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point1 = bgimgofs_cam + '12 48 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);	
	
	DrawElement_ControlKeySetting(CTRL_EDITORMOVERIGHT, "Move Camera Right", controlbuttonwidth);	
		if(active_menu.user_current_option == option_current-1)
			linealpha = option_imagealpha_highlight;
		else
			linealpha = option_imagealpha;		
		line_point1 = option_pos; line_point1_x += option_size_x; line_point1_y -= option_size_y;			
		line_point2 = line_point1; line_point2_x += 5;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point1 = line_point2 + '20 20 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);	
		line_point2 = line_point1; line_point2_x += 75;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);	
		line_point1 = bgimgofs_cam + '90 66 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);	
	
	DrawElement_ControlKeySetting(CTRL_EDITORMOVEBACK, "Move Camera Back", controlbuttonwidth);		
		if(active_menu.user_current_option == option_current-1)
			linealpha = option_imagealpha_highlight;
		else
			linealpha = option_imagealpha;		
		line_point1 = option_pos; line_point1_x += option_size_x; line_point1_y -= option_size_y;			
		line_point2 = line_point1; line_point2_x += 5;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point1 = line_point2 + '20 0 0'; line_point1_y = bgimgofs_cam_y + 93;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);	
		line_point2 = bgimgofs_cam + '40 93 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);	
		
	option_imagecolor = option_imagecolor_highlight = '0.86 0.24 0.24';		
	DrawElement_ControlTitle("Rotate Object", buttontitlewidth, ALIGN_LEFT);
	DrawElement_ControlKeySetting(CTRL_OBJECTPITCHSUBTRACT, "Rotate Forward", controlbuttonwidth);		
		if(active_menu.user_current_option == option_current-1)
			linealpha = option_imagealpha_highlight;
		else
			linealpha = option_imagealpha;		
		line_point1 = option_pos; line_point1_x += option_size_x; line_point1_y -= option_size_y;			
		line_point2 = line_point1; line_point2_x += 50;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point1 = bgimgofs_rot + '32 0 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);			
	
	DrawElement_ControlKeySetting(CTRL_OBJECTPITCHADD, "Rotate Back", controlbuttonwidth);	
		if(active_menu.user_current_option == option_current-1)
			linealpha = option_imagealpha_highlight;
		else
			linealpha = option_imagealpha;		
		line_point1 = option_pos; line_point1_x += option_size_x; line_point1_y -= option_size_y;			
		line_point2 = line_point1; line_point2_x += 40;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point1 = bgimgofs_rot + '20 20 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);	
		
	option_imagecolor = option_imagecolor_highlight = '0.23 0.53 1';		
	DrawElement_ControlKeySetting(CTRL_OBJECTYAWSUBTRACT, "Rotate Right", controlbuttonwidth);	
		if(active_menu.user_current_option == option_current-1)
			linealpha = option_imagealpha_highlight;
		else
			linealpha = option_imagealpha;		
		line_point1 = option_pos; line_point1_x += option_size_x; line_point1_y -= option_size_y;			
		line_point2 = line_point1; line_point2_x += 30;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point1 = bgimgofs_rot + '9 21 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);	
	
	DrawElement_ControlKeySetting(CTRL_OBJECTYAWADD, "Rotate Left", controlbuttonwidth);		
		if(active_menu.user_current_option == option_current-1)
			linealpha = option_imagealpha_highlight;
		else
			linealpha = option_imagealpha;		
		line_point1 = option_pos; line_point1_x += option_size_x; line_point1_y -= option_size_y;			
		line_point2 = line_point1; line_point2_x += 50;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point1 = bgimgofs_rot + '54 72 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);	
		line_point2 = bgimgofs_rot + '75 58 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);	
		line_point1 = bgimgofs_rot + '55 32 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);			

	
	option_imagecolor = option_imagecolor_highlight = '0.86 0.24 0.24';	
	DrawElement_ControlTitle("Reset Pitch", buttontitlewidth, ALIGN_RIGHT);
//	option_pos_x += buttontitlewidth - controlbuttonwidth;
	option_pos_x += 30;
	DrawElement_ControlKeySetting(CTRL_RESETOBJECTPITCH, "Reset Pitch", controlbuttonwidth);	

	option_pos = option_pos_start;
	option_pos_x = MenuColumn() + active_menu.menusize_x - buttontitlewidth;

	option_imagecolor = option_imagecolor_highlight = '0.35 0.33 0.78';		
	DrawElement_ControlTitle("Zoom In", buttontitlewidth, ALIGN_RIGHT);
	option_pos_x += buttontitlewidth - controlbuttonwidth;
	DrawElement_ControlKeySetting(CTRL_ZOOMIN, "Zoom In", controlbuttonwidth);	
	option_pos_x -= buttontitlewidth - controlbuttonwidth;
	
	DrawElement_ControlTitle("Zoom Out", buttontitlewidth, ALIGN_RIGHT);
	option_pos_x += buttontitlewidth - controlbuttonwidth;
	DrawElement_ControlKeySetting(CTRL_ZOOMOUT, "Zoom Out", controlbuttonwidth);	
	option_pos_x -= buttontitlewidth - controlbuttonwidth;	
	BR();
	
	option_imagecolor = option_imagecolor_highlight = '0.78 0.62 0.33';		
	DrawElement_ControlTitle("Select Object", buttontitlewidth, ALIGN_RIGHT);
	option_pos_x += buttontitlewidth - controlbuttonwidth;
	DrawElement_ControlKeySetting(CTRL_EDITORBUTTON1, "Select Object", controlbuttonwidth);	
	option_pos_x -= buttontitlewidth - controlbuttonwidth;	

	DrawElement_ControlTitle("Grab Object", buttontitlewidth, ALIGN_RIGHT);
	option_pos_x += buttontitlewidth - controlbuttonwidth;
	DrawElement_ControlKeySetting(CTRL_EDITORBUTTON2, "Grab Object", controlbuttonwidth);
	option_pos_x -= buttontitlewidth - controlbuttonwidth;	
	
	option_fontcolor_highlight	= '0 0 0';
	option_imagecolor = option_imagecolor_highlight = '1 1 1';	
	option_pos = option_pos_start;
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Reset", Call_ResetControlSettings, 0, 0, 0, 0, MBT_BASIC);
	DrawElement_BottomButton("Back", CloseMenu, 0, 3, 0, 0, MBT_CANCEL);
	EndBottomButtons();
	
	Menu_End();
	
//		drawstring(getmousepos()+'20 0 0', vtos(getmousepos()-bgimgofs_rot), '10 10 0', '1 1 1', 1, 0);
}

void Call_ControlsMenu_Editor() =	{	SetDrawFunc(active_menu, Draw_ControlsMenu_Editor, false);		}

void Toggle_EnableGamepad() =	{	cvar_set("joy_enable", ftos(!cvar("joy_enable")));	}

void SliderRules_Sensitivity() =	{	cvar_set("joy_x360_sensitivityyaw", ftos(GetSliderValue()));	}

void SliderRules_AxisForward() =	{	cvar_set("joy_x360_axisforward", ftos(GetSliderValue()));	}

void SliderRules_AxisSide() =	{	cvar_set("joy_x360_axisside", ftos(GetSliderValue()));	}

void SliderRules_AxisYaw() =	{	cvar_set("joy_x360_axisyaw", ftos(GetSliderValue()));	}

void SliderRules_DeadZone() =
{
	local float deadzone;
	
	deadzone = GetSliderValue();
	
	cvar_set("joy_deadzoneforward", ftos(deadzone));
	cvar_set("joy_deadzoneside", ftos(deadzone));
	cvar_set("joy_deadzoneyaw", ftos(deadzone));	
	cvar_set("joy_x360_deadzoneforward", ftos(deadzone));
	cvar_set("joy_x360_deadzoneside", ftos(deadzone));
	cvar_set("joy_x360_deadzoneyaw", ftos(deadzone));	
}

string ReadoutRules_JoyAxis(float val) =
{
	local string s;

	if(val == -1)
		s = "off";
	else
		s = ftos(val);
		
	return s;
}

void Draw_ControlsMenu_Input() =
{
	local vector option_pos_start, imgsize;
	local float buttontitlewidth, controlbuttonwidth, menunum;
	local string imgname;
	
	buttontitlewidth = 160;
	controlbuttonwidth = 110;
	
	Menu_Start_ESCMenu("Input Settings", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);

//	body_textbordersize			= '12 0 0';

	#ifdef COMPILE_SERVICE_ONLIVE
		menunum = 3;
		DrawControlsMenuHeader(4, 9, 3);
	#else
		menunum = 4;
		DrawControlsMenuHeader(4, 13, 4);
	#endif	
	
	option_pos_start = option_pos;
	
	option_size_x = 168;	
	option_spacing = 4;

	option_fontcolor_highlight	= '0 0 0';	
	option_imagecolor = option_imagecolor_highlight = '0.34 0.66 0.72';		

	DrawElement_OptionTitle("Mouse");	
	
	option_size_selectionbox = option_size;
	option_size_selectionbox_x = 407;
	optionalt_up = menunum;
	Menu_Slider_Text("Mouse Speed", 0, "sensitivity", 0.5, 9, 171, 4);
	optionalt_up = 0;
	
	option_size_selectionbox = option_size;
	option_size_selectionbox_x = option_sliderspacing+36;

	BR();
	
	DrawElement_OptionTitle("Gamepad");
	
	Menu_Option_Text("Enable Gamepad", Toggle_EnableGamepad);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("joy_enable"));	
	BR();	

	option_size_selectionbox = option_size;	
	option_size_selectionbox_x = 407;		
	
	SliderRules = SliderRules_Sensitivity;	
	Menu_Slider_Text("Sensitivity", 0, "joy_sensitivityyaw", -0.05, -6, 120, -4);	
	DrawElement_SliderMinMaxLabels("min", "max");
	SliderRules = SUB_Null;	
	
	SliderRules = SliderRules_DeadZone;
	Menu_Slider_Text("Dead Zone", 0, "joy_deadzoneforward", 0, 1, 101, 4);	
	DrawElement_SliderMinMaxLabels("small", "large");
	SliderRules = SUB_Null;
	
	#ifndef COMPILE_SERVICE_ONLIVE
		ReadoutRules = ReadoutRules_JoyAxis;
		SliderRules = SliderRules_AxisForward;
		Menu_Slider_Text("Forward/Back Axis", 0, "joy_axisforward", -1, 9, 11, 3);	
		SliderRules = SliderRules_AxisSide;	
		Menu_Slider_Text("Strafe Axis", 0, "joy_axisside", -1, 9, 11, 3);	
		SliderRules = SliderRules_AxisYaw;	
		Menu_Slider_Text("Turn Axis", 0, "joy_axisyaw", -1, 9, 11, 3);	
		SliderRules = SUB_Null;	
		ReadoutRules = SUB_Null;
	#endif
	
	option_size_selectionbox = '0 0 0';		

	option_imagecolor = option_imagecolor_highlight = '1 1 1';	
	option_pos = option_pos_start;

	BeginBottomButtons(2);
	DrawElement_BottomButton("Reset", Call_ResetControlSettings, 0, 0, 0, 0, MBT_BASIC);
	DrawElement_BottomButton("Back", CloseMenu, 0, menunum, 0, 0, MBT_CANCEL);
	EndBottomButtons();
	
	Menu_End();
}

void Call_ControlsMenu_Input() =	{	SetDrawFunc(active_menu, Draw_ControlsMenu_Input, false);		}

void Draw_ControlsMenu_Misc() =
{
	local vector option_pos_start, imgsize;
	local float buttontitlewidth, controlbuttonwidth;
	local string imgname;
	
	buttontitlewidth = 160;
	controlbuttonwidth = 110;
	
	Menu_Start_ESCMenu("Misc Controls", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	
//	body_textbordersize			= '12 0 0';
	
	#ifdef COMPILE_SERVICE_ONLIVE
		DrawControlsMenuHeader(2, 9, 3);
	#else
		#ifdef COMPILE_GAMEPLAYOPTIONS_SINGLEPLAYER
			DrawControlsMenuHeader(2, 10, 4);
		#else
			DrawControlsMenuHeader(2, 14, 4);
		#endif
	#endif
	
//	skiptranslation = true;	

	option_pos_start = option_pos;
	
	SetOptionImages_AltSettings_1();
	
	option_fontcolor_highlight	= '0 1 1';	
	option_imagecolor = option_imagecolor_highlight = '0.34 0.66 0.72';		
	
	DrawElement_ControlTitle("Toggle Scoreboard", buttontitlewidth, ALIGN_LEFT);
	optionalt_up = 2;
	DrawElement_ControlKeySetting(CTRL_TOGGLELIVESCORES, "Toggle Scoreboard", controlbuttonwidth);	
	optionalt_up = 0;
		
	DrawElement_ControlTitle("Toggle Map", buttontitlewidth, ALIGN_LEFT);
	DrawElement_ControlKeySetting(CTRL_TOGGLEMISSIONMAP, "Toggle Map", controlbuttonwidth);	

	DrawElement_ControlTitle("Toggle Briefing", buttontitlewidth, ALIGN_LEFT);	
	DrawElement_ControlKeySetting(CTRL_TOGGLEMISSIONBRIEFING, "Toggle Briefing", controlbuttonwidth);		
	
	#ifdef COMPILE_GAMEPLAYOPTIONS_SINGLEPLAYER
		SkipTranslations(4);
	#else
		DrawElement_ControlTitle("Chat", buttontitlewidth, ALIGN_LEFT);	
		DrawElement_ControlKeySetting(CTRL_TALK, "Chat", controlbuttonwidth);		

		DrawElement_ControlTitle("Team Chat", buttontitlewidth, ALIGN_LEFT);	
		DrawElement_ControlKeySetting(CTRL_TALK_TEAM, "Team Chat", controlbuttonwidth);	
	#endif
	
	option_pos = option_pos_start;
	option_pos_x = MenuColumn() + active_menu.menusize_x - buttontitlewidth;	
	
	#ifdef COMPILE_GAMEPLAYOPTIONS_SINGLEPLAYER
		SkipTranslations(4);	
	#else
		DrawElement_ControlTitle("Vote Yes", buttontitlewidth, ALIGN_LEFT);	
		option_pos_x += buttontitlewidth - controlbuttonwidth;
		DrawElement_ControlKeySetting(CTRL_VOTEYES, "Vote Yes", controlbuttonwidth);		
		option_pos_x -= buttontitlewidth - controlbuttonwidth;	
		
		DrawElement_ControlTitle("Vote No", buttontitlewidth, ALIGN_LEFT);	
		option_pos_x += buttontitlewidth - controlbuttonwidth;	
		DrawElement_ControlKeySetting(CTRL_VOTENO, "Vote No", controlbuttonwidth);		
		option_pos_x -= buttontitlewidth - controlbuttonwidth;	
	#endif
	
	DrawElement_ControlTitle("Toggle Camera", buttontitlewidth, ALIGN_LEFT);	
	option_pos_x += buttontitlewidth - controlbuttonwidth;	
	DrawElement_ControlKeySetting(CTRL_TOGGLECAMMODE, "Toggle Camera", controlbuttonwidth);	
	
	option_pos_x -= buttontitlewidth - controlbuttonwidth;		
	
	option_fontcolor_highlight	= '0 0 0';	
	option_imagecolor = option_imagecolor_highlight = '1 1 1';	
	option_pos = option_pos_start;

	BeginBottomButtons(2);
	DrawElement_BottomButton("Reset", Call_ResetControlSettings, 0, 0, 0, 0, MBT_BASIC);
	DrawElement_BottomButton("Back", CloseMenu, 0, 2, 0, 0, MBT_CANCEL);
	EndBottomButtons();
	
	Menu_End();
}

void Call_ControlsMenu_Misc() =	{	SetDrawFunc(active_menu, Draw_ControlsMenu_Misc, false);		}

void Draw_ControlsMenu_Player() =
{
	local vector option_pos_start, imgsize, bgimgofs, line_point1, line_point2;
	local string imgname;
	local float buttontitlewidth, controlbuttonwidth, linealpha, linewidth;
	
	linewidth = 2;
	
	buttontitlewidth = 160;
	controlbuttonwidth = 110;
	
	Menu_Start_ESCMenu("Player Tank Controls", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	
	local string str_fireprimaryweapon, str_firesecondaryweapon, str_fireshockwave, str_togglesecondary, str_moveforward, str_moveback, str_moveleft, str_moveright;
	
	str_fireprimaryweapon	= Translate("Fire Primary Weapon");
	str_firesecondaryweapon = Translate("Fire Secondary Weapon");
	str_fireshockwave		= Translate("Fire Shockwave");
	str_togglesecondary		= Translate("Toggle Secondary");
	str_moveforward			= Translate("Move Forward");
	str_moveback			= Translate("Move Back");
	str_moveleft			= Translate("Move Left");
	str_moveright			= Translate("Move Right");
	
	option_size					= '168 22 0';
	option_size_x = buttontitlewidth;
	
	option_pos_start = option_pos;
	
	imgname = "gfx/menu/player_outline.tga";
	imgsize = drawgetimagesize(imgname);
	bgimgofs = MenuPosition() + '82 103 0';
	drawpic(bgimgofs, imgname, imgsize, body_imagecolor, body_imagealpha, body_imageflags);
	
//	body_textbordersize			= '12 0 0';
	
	#ifdef COMPILE_SERVICE_ONLIVE
		DrawControlsMenuHeader(1, 13, 3);
	#else
		DrawControlsMenuHeader(1, 14, 4);
	#endif	

	skiptranslation = true;	
	
	SetOptionImages_AltSettings_1();

	option_imagecolor = option_imagecolor_highlight = '0.84 0.26 0.26';	
	option_fontcolor_highlight	= '0 1 1';
	
	DrawElement_ControlTitle(str_fireprimaryweapon, buttontitlewidth, ALIGN_LEFT);
		line_point1 = option_pos; line_point1_x += buttontitlewidth - 15; line_point1_y -= 4;
	optionalt_up = 1;
	DrawElement_ControlKeySetting(CTRL_FIREPRIMARY, str_fireprimaryweapon, controlbuttonwidth);	
	optionalt_up = 0;
	
		if(active_menu.user_current_option == option_current-1)
			linealpha = option_imagealpha_highlight;
		else
			linealpha = option_imagealpha;
		line_point2 = bgimgofs + '92 4 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point2_x = bgimgofs_x + 145;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point2 = line_point1; line_point2_x = option_pos_x + option_size_x + 2;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point1 = line_point2; line_point1_y += option_size_y + 5;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point2 = line_point1; line_point2_x -= 30;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
	
	option_pos_y -= (option_size_y+option_spacing)*2;
	option_pos_x = MenuColumn() + active_menu.menusize_x - buttontitlewidth;
	

	DrawElement_ControlTitle(str_firesecondaryweapon, buttontitlewidth, ALIGN_RIGHT);
		line_point1 = option_pos; line_point1_x -= 1;
	option_pos_x += buttontitlewidth - controlbuttonwidth;
	DrawElement_ControlKeySetting(CTRL_FIRESECONDARY, str_firesecondaryweapon, controlbuttonwidth);	

		if(active_menu.user_current_option == option_current-1)
			linealpha = option_imagealpha_highlight;
		else
			linealpha = option_imagealpha;	
		line_point2 = bgimgofs + '170 17 0';//'163 68 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point2 = bgimgofs+'165 4 0';
		drawline(linewidth, bgimgofs+'154 52 0', line_point2, option_imagecolor, linealpha, 0);
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point2 = line_point1; line_point2_y -= option_size_y + 5;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point1 = line_point2; line_point1_x += 30;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
	
	option_pos_x = option_pos_start_x;
	option_pos_y += 100;
	
		line_point1_x = option_pos_x + option_size_x + 2;
	DrawElement_ControlKeySetting(CTRL_FIRESHOCKWAVE, str_fireshockwave, controlbuttonwidth);	
		line_point1_y = option_pos_y - 4;
	DrawElement_ControlTitle(str_fireshockwave, buttontitlewidth, ALIGN_LEFT);	

		if(active_menu.user_current_option == option_current-1)
			linealpha = option_imagealpha_highlight;
		else
			linealpha = option_imagealpha;	
		line_point2 = bgimgofs + '59 93 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point2 = bgimgofs + '70 121 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point2 = line_point1; line_point2_y -= 15;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point1 = line_point2; line_point1 += '-5 -5 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point2 = line_point1; line_point2_x -= 30;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);	
	
	option_imagecolor = option_imagecolor_highlight = '0.72 0.56 0.51';	
	DrawElement_ControlTitle(str_togglesecondary, buttontitlewidth, ALIGN_LEFT);		
	DrawElement_ControlKeySetting(CTRL_TOGGLESECONDARY, str_togglesecondary, controlbuttonwidth);		
	
	
	option_pos = option_pos_start + '298 172 0';//'260 172 0';
	option_imagecolor = option_imagecolor_highlight = '0.49 0.8 0.8';	
		line_point1 = option_pos;	line_point1_y += 5;
	DrawElement_ControlKeySetting(CTRL_MOVEFORWARD, str_moveforward, 80);	
		if(active_menu.user_current_option == option_current-1)
			linealpha = option_imagealpha_highlight;
		else
			linealpha = option_imagealpha;	
		line_point2 = bgimgofs + '128 78 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);	
		line_point1 = bgimgofs + '118 40 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);	
		
	option_pos_x -= (option_size_x + option_spacing)*0.5;
		line_point1 = option_pos;	line_point1_y += 5;
	DrawElement_ControlKeySetting(CTRL_MOVELEFT, str_moveleft, 80);	
		if(active_menu.user_current_option == option_current-1)
			linealpha = option_imagealpha_highlight;
		else
			linealpha = option_imagealpha;		
		line_point2 = bgimgofs + '90 61 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);	
		line_point1 = bgimgofs + '53 56 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);	
		
	option_pos = GetLastLinePos();
	option_pos_x += option_size_x + option_spacing;
		line_point1 = option_pos; line_point1_x += option_size_x - 5;
	DrawElement_ControlKeySetting(CTRL_MOVERIGHT, str_moveright, 80);
		if(active_menu.user_current_option == option_current-1)
			linealpha = option_imagealpha_highlight;
		else
			linealpha = option_imagealpha;		
		line_point2 = bgimgofs + '294 70 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point1 = bgimgofs + '213 50 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);	
	
	option_pos_x -= (option_size_x + option_spacing)*0.5;
		line_point1 = option_pos; line_point1_y += 5;
	DrawElement_ControlKeySetting(CTRL_MOVEBACK, str_moveback, 80);	
		if(active_menu.user_current_option == option_current-1)
			linealpha = option_imagealpha_highlight;
		else
			linealpha = option_imagealpha;		
		line_point2 = line_point1; line_point2_x -= option_size_x*0.5;
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);
		line_point1 = bgimgofs + '128 137 0';
		drawline(linewidth, line_point1, line_point2, option_imagecolor, linealpha, 0);			
	

	option_fontcolor_highlight	= '0 0 0';	
	option_imagecolor = option_imagecolor_highlight = '1 1 1';	
	option_pos = option_pos_start;
	skiptranslation = false;

	BeginBottomButtons(2);
	DrawElement_BottomButton("Reset", Call_ResetControlSettings, 0, 0, 0, 0, MBT_BASIC);
	DrawElement_BottomButton("Back", CloseMenu, 0, 1, 0, 0, MBT_CANCEL);
	EndBottomButtons();
	
	Menu_End();
}

void Call_ControlsMenu_Player() =	{	SetDrawFunc(active_menu, Draw_ControlsMenu_Player, false);		}

void Call_ControlsMenu() =
{
	SetCurrentMenu(Draw_ControlsMenu_Player);
//	RefreshControlKeyList(currentmenu);
}