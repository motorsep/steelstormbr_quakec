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
void CampaignEdit_SetTierName() =
{
	local string tiername, newtierstring, s;
	local float count;
	
	tiername = GetBufferString(active_menu.buf_list, 0);
	tiername = UnderscoreString(tiername);	
	
	newtierstring = "TIER";

	s = GetBufferString(active_menu.parentmenu.buf_list, active_menu.parentmenu.user_current_selection-1);
	tokenize(s);
	
	for(count = 0; count < NUMLANGUAGES; count++)
	{
		if(count == currentlanguage)
			newtierstring = strcat(newtierstring, " \"", tiername, "\"");
		else
			newtierstring = strcat(newtierstring, " \"", argv(count+1), "\"");
	}
	
	SetBufferString(active_menu.parentmenu.buf_list, active_menu.parentmenu.user_current_selection-1, newtierstring);
	CloseMenu();
}

void Draw_CampaignEdit_EditTierName() =
{
	local string s, d;

	Menu_Start_ConfirmationMenu("Tier Name", '300 0 0', __FUNC__);

	s = Translate("Tier Name:");
	skiptranslation = true;
	d = GetBufferString(active_menu.parentmenu.buf_list, active_menu.parentmenu.user_current_selection-1);
	tokenize(d);
	d = TitleString(argv(1+currentlanguage));
	
	Menu_AlignedText(s, ALIGN_LEFT);
	Menu_Input_Text(GetInputBoxSize(s), d, ALIGN_RIGHT, 0, CampaignEdit_SetTierName);
	
	skiptranslation = false;
	BeginBottomButtons(2);
	DrawElement_BottomButton("Set", CampaignEdit_SetTierName, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();	
}

void CampaignEdit_EditTierName() =
{
	SetCurrentMenu(Draw_CampaignEdit_EditTierName);
	active_input = 1;	
}

void CampaignEdit_MoveMissionUp() =
{
	local float selectionnum, destination, spacesmoved;
	local string previtem;
	
	selectionnum = active_menu.user_current_selection-1;
	destination = selectionnum - 1;
	spacesmoved = 1;
	
	if(selectionnum > 0)
		previtem = GetBufferString(active_menu.buf_list, selectionnum-1);

	if(previtem)
	{
		tokenizebyseparator(previtem, SEP_SPACE, SEP_TAB);
		if(argv(0) == "TIER")
		{
			destination -= 1;
			spacesmoved	++;
		}
	}
	
	if(destination < 0)
		return;
	
	MoveBufferItem(active_menu.buf_list, selectionnum, destination);
	
	active_menu.user_current_selection = destination+1;	
	
	scrollwindow_up = spacesmoved;
}

void CampaignEdit_MoveMissionDown() =
{
	local float selectionnum, destination, buffersize, spacesmoved;
	local string nextitem;
	
	selectionnum = active_menu.user_current_selection-1;
	destination = selectionnum + 1;	
	spacesmoved = 1;
	
	nextitem = GetBufferString(active_menu.buf_list, destination);
	
	if(!nextitem)
		return;
		
	buffersize = GetBufferSize(active_menu.buf_list);	

	tokenizebyseparator(nextitem, SEP_SPACE, SEP_TAB);
	
	if(nextitem == "ENDTIER")
	{
		destination++;
		spacesmoved ++;
	}
	
	if(destination >= buffersize)
		return;
	
	MoveBufferItem(active_menu.buf_list, selectionnum, destination);
	
	active_menu.user_current_selection = destination+1;

	scrollwindow_down = spacesmoved;
}

void CampaignEdit_MoveTierUp() =
{
	local float count, start, destination, buffersize, tiersize;
	local string bufferstring;
	
	if(active_menu.user_current_selection == 1)
		return;

	buffersize = GetBufferSize(active_menu.buf_list);		
	start =	active_menu.user_current_selection-1;

	for(tiersize = 0; tiersize <= buffersize; tiersize++)
	{
		bufferstring = GetBufferString(active_menu.buf_list, start+tiersize);
		if(bufferstring == "ENDTIER")
			break;
	}
	
	for(count = start-1; count >= 0; count -= 1)
	{
		bufferstring = GetBufferString(active_menu.buf_list, count);
		tokenizebyseparator(bufferstring, SEP_SPACE, SEP_TAB);
		if(argv(0) == "TIER")
		{
			destination = count;
			break;
		}
	}
	
	for(count = 0; count <= tiersize; count++)
		MoveBufferItem(active_menu.buf_list, start+tiersize, destination);
	
	active_menu.user_current_selection = destination+1;
	scrollwindow_up = tiersize-1;	
}

void CampaignEdit_MoveTierDown() =
{
	local float count, start, destination, buffersize, tiersize;
	local string bufferstring;
	
	buffersize = GetBufferSize(active_menu.buf_list);
	start =	active_menu.user_current_selection-1;
	
	for(tiersize = 0; tiersize <= buffersize; tiersize++)
	{
		bufferstring = GetBufferString(active_menu.buf_list, start+tiersize);
		if(bufferstring == "ENDTIER")
			break;
	}	

	for(count = start+tiersize+1; count <= buffersize; count++)
	{
		bufferstring = GetBufferString(active_menu.buf_list, count);
		tokenizebyseparator(bufferstring, SEP_SPACE, SEP_TAB);
		if(bufferstring == "ENDTIER")
		{
			destination = count;
			break;
		}
	}

	if(count > buffersize)
		return;

	for(count = 0; count <= tiersize; count++)
		MoveBufferItem(active_menu.buf_list, start, destination);
	
	active_menu.user_current_selection = destination-tiersize+1;
	scrollwindow_down = destination-start-tiersize;	
}

void CampaignEdit_AddTier() =
{
	local string tierstring;
	local float count;

	tierstring = "TIER ";
	for(count = 0; count < NUMLANGUAGES; count++)
		tierstring = strcat(tierstring, " \"new_tier\"");

	AddBufferString(active_menu.buf_list, tierstring, 0);
	AddBufferString(active_menu.buf_list, "ENDTIER", 0);	
	GoToBottomOfScrollingWindow();
}

void AddMissionToTier() =
{
	local float str_index, buffersize, tiersize;
	local string bufferstring, mission_name;

	mission_name = GetBufferString(active_menu.buf_items, 0);

	str_index = active_menu.parentmenu.user_current_selection-1;
	buffersize = GetBufferSize(active_menu.parentmenu.buf_list);

	for(tiersize = 0; str_index+tiersize <= buffersize; tiersize++)
	{
		bufferstring = GetBufferString(active_menu.parentmenu.buf_list, str_index+tiersize);	
		if(bufferstring == "ENDTIER")	
			break;
	}
	
	AddBufferString(active_menu.parentmenu.buf_list, mission_name, 0);
	MoveBufferItem(active_menu.parentmenu.buf_list, buffersize, str_index+tiersize);
	CloseMenu();
}

void Call_MissionMenu_CampignEdit() =
{
	local string pathstring;

	pathstring = strcat("data/campaign/_", uri_escape(UnderscoreString(cvar_string("campaign"))));
	pathstring = strcat(pathstring, "/");
	Call_MissionMenu_NonTiered(pathstring, 3, 0);
}

void CampaignEdit_AddMission() =
{
	Call_MissionMenu_CampignEdit();
	currentmenu.editingcampaign = 2;
}

void CampaignEdit_Remove_Tier() =
{
	local float str_index, tiersize, count, buffersize;
	local string bufferstring;

	str_index = active_menu.user_current_selection-1;
	buffersize = GetBufferSize(active_menu.buf_list);
	
	for(tiersize = 0; str_index+tiersize <= buffersize; tiersize++)
	{
		MoveBufferItem(active_menu.buf_list, str_index, buffersize);
		bufferstring = GetBufferString(active_menu.buf_list, buffersize);	
		if(bufferstring == "ENDTIER")	
			break;
	}

	for(count = 0; count <= tiersize; count++)
		FreeBufferString(active_menu.buf_list, buffersize-count);
}

void CampaignEdit_Remove_Mission() =
{
	local float buffersize;
	local string s;
	
	buffersize = GetBufferSize(active_menu.buf_list);
	MoveBufferItem(active_menu.buf_list, active_menu.user_current_selection-1, buffersize);
	FreeBufferString(active_menu.buf_list, buffersize);
}

void CampaignEdit_SaveCampaign() =
{
	local float file, str_index, buffersize;
	local string filename, bufferstring;
	
	filename = strcat("campaign/_", uri_escape(UnderscoreString(cvar_string("campaign"))));
	filename = strcat(filename, "/missions.txt");
	file = FileOpen(filename, FILE_WRITE);

	buffersize = GetBufferSize(active_menu.buf_list);
	
	for(str_index = 0; str_index <= buffersize; str_index++)
	{
		bufferstring = GetBufferString(active_menu.buf_list, str_index);
		
		if(strlen(bufferstring))
		{
			tokenize(bufferstring);
			if(argv(0) == "TIER")
				bufferstring = strcat("TIER ", argv(currentlanguage+1));
			else
				bufferstring = argv(0);
			NewFileLine(file, bufferstring);
		}
	}
	
	fclose(file);
	CloseMenu();
}

void Draw_CampaignEditMenu() =
{
	local float nummissions, numlistoptions, windowwidth, buttonwidth, lastoptnum;
	local vector option_pos_start, backbuttonpos;
	local string listitem;
	
	windowwidth = 260;
	
	Menu_Start_ESCMenu("Campaign Editor", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	
	local string str_campaign, str_tier, str_mission, str_settiername, str_moveup, str_movedown, str_addtier, str_addmission, str_remove, str_save, str_cancel;
	str_campaign	= Translate("Campaign:");
	str_tier		= Translate("Tier:");
	str_mission		= Translate("Mission:");
	str_settiername	= Translate("Set Tier Name");
	str_moveup		= Translate("Move Up");
	str_movedown	= Translate("Move Down");
	str_addtier		= Translate("Add Tier");
	str_addmission	= Translate("Add Mission");
	str_remove		= Translate("Remove");
	str_save		= Translate("Save");
	str_cancel		= Translate("Cancel");
	skiptranslation = true;
	
	body_alignment = '-1 0 0';
	body_textalignment = '-1 0 0';
	
	option_pos_start = option_pos;

	nummissions = max(0, GetBufferSize(active_menu.buf_list)-1);
	
	if(nummissions > 0)
	{
		if(!active_menu.user_current_selection)
			active_menu.user_current_selection = 1;
	
		listitem = GetBufferString(active_menu.buf_list, active_menu.user_current_selection-1);
		tokenizebyseparator(listitem, SEP_SPACE, SEP_TAB);	

		if(argv(0) == "TIER")
			lastoptnum = 18;	
		else
			lastoptnum = 16;
	}
	else
	if(active_menu.user_current_selection)
		active_menu.user_current_selection = 0;
		
	if(nummissions > 0)
			numlistoptions = Draw_ScollingList(nummissions, 10, 0, windowwidth, lastoptnum-1, 10, SUB_Null, ListOption_Mission);
	else
		option_pos_y += 10*(option_size_y+option_spacing);
		
	BR();

	if(active_menu.user_current_selection-1 > nummissions)
		active_menu.user_current_selection = nummissions+1;
	else
	if(nummissions > 0)
	{
		if(GetBufferString(active_menu.buf_list, active_menu.user_current_selection-1) == "ENDTIER")
			active_menu.user_current_selection = max(1, active_menu.user_current_selection-1);
	}	

	option_textalignment = '0 0 0';

	backbuttonpos = option_pos;
	buttonwidth = 150;
	
	body_fontsize = option_fontsize;

	option_pos = option_pos_start;	
	option_pos_x += windowwidth + 15;	
	option_size_x = 170;
		
	TempMenuSetting_body_fontcolor('0.46 0.62 0.75');
	Menu_Text(str_campaign);
	RestoreMenuSetting_body_fontcolor();
	option_pos_y += body_fontsize_y + option_spacing;	
	tokenize(GetBufferString(active_menu.buf_contents, 0));
	Menu_Text(TitleString(argv(currentlanguage)));
	option_pos_y += body_fontsize_y + option_spacing;			
	
	if(nummissions > 0)
	{
		listitem = GetBufferString(active_menu.buf_list, active_menu.user_current_selection-1);
		tokenize(listitem);	
		
		if(argv(0) == "TIER")
		{
			TempMenuSetting_body_fontcolor('0.46 0.62 0.75');
			Menu_Text(str_tier);
			RestoreMenuSetting_body_fontcolor();
			option_pos_y += body_fontsize_y + option_spacing;
			Menu_Text(TitleString(argv(currentlanguage+1)));
			option_pos_y += body_fontsize_y + option_spacing;
			BR();
		}
		else
		{	
			TempMenuSetting_body_fontcolor('0.46 0.62 0.75');	
			Menu_Text(str_mission);
			RestoreMenuSetting_body_fontcolor();		
			option_pos_y += body_fontsize_y + option_spacing;
			Menu_Text(TitleString(argv(currentlanguage+1)));
			option_pos_y += body_fontsize_y + option_spacing;
			BR();
		}
		
	//	option_pos_x = option_pos_start_x;
	//	option_pos_x += windowwidth + (active_menu.menusize_x - windowwidth - border_size_x*2 - body_margin_x*2 - buttonwidth)*0.5 ;

		listitem = GetBufferString(active_menu.buf_list, active_menu.user_current_selection-1);
		tokenize(listitem);	
		
		if(argv(0) == "TIER")
		{
			HorizontalListButton(0, buttonwidth, str_settiername, CampaignEdit_EditTierName, 1, 0, 1, lastoptnum-1, MBT_BASIC);
			BR();
			HorizontalListButton(0, buttonwidth, str_moveup, CampaignEdit_MoveTierUp, 0, 0, 1, lastoptnum-1, MBT_BASIC);
			BR();
			HorizontalListButton(0, buttonwidth, str_movedown, CampaignEdit_MoveTierDown, 0, 0, 1, lastoptnum-1, MBT_BASIC);
		}
		else
		{	
			BR();
			HorizontalListButton(0, buttonwidth, str_moveup, CampaignEdit_MoveMissionUp, 1, 0, 1, lastoptnum-1, MBT_BASIC);
			BR();
			HorizontalListButton(0, buttonwidth, str_movedown, CampaignEdit_MoveMissionDown, 0, 0, 1, lastoptnum-1, MBT_BASIC);
		}

		BR();BR();

		HorizontalListButton(0, buttonwidth, str_addtier, CampaignEdit_AddTier, 0, 0, 1, lastoptnum-1, MBT_BASIC);
		BR();

		if(argv(0) == "TIER")	
		{
			HorizontalListButton(0, buttonwidth, str_addmission, CampaignEdit_AddMission, 0, 0, 1, lastoptnum-1, MBT_BASIC);
			BR();
			HorizontalListButton(0, buttonwidth, str_remove, CampaignEdit_Remove_Tier, 0, lastoptnum-1, 1, lastoptnum-1, MBT_BASIC);
		}
		else
		{
			BR();
			HorizontalListButton(0, buttonwidth, str_remove, CampaignEdit_Remove_Mission, 0, lastoptnum-1, 1, lastoptnum-1, MBT_BASIC);	
		}
	
	//	buttonwidth = 120;
	//	option_pos = backbuttonpos;
	//	HorizontalListButton(0, buttonwidth, "Save", CampaignEdit_SaveCampaign, numlistoptions, 1, 0, 0, MBT_CONFIRM);
	//	HorizontalListButton(buttonwidth+option_spacing, buttonwidth, "Cancel", CloseMenu, numlistoptions, 0, 0, 0, MBT_CANCEL);	

		option_pos = option_pos_start;
		BeginBottomButtons(2);
		DrawElement_BottomButton(str_save, CampaignEdit_SaveCampaign, 0, 0, 0, 0, MBT_CONFIRM);	
		DrawElement_BottomButton(str_cancel, CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
		EndBottomButtons();			
	}	
	else
	{
	//	option_pos_x = option_pos_start_x;
	//	option_pos_x += windowwidth + (active_menu.menusize_x - windowwidth - border_size_x - body_margin_x - buttonwidth)*0.5 ;	
		option_pos_y += (body_fontsize_y + option_spacing)*2;
		BR();

		HorizontalListButton(0, buttonwidth, str_addtier, CampaignEdit_AddTier, 3, 0, 0, 0, MBT_BASIC);
		
	//	buttonwidth = 120;
	//	option_pos = backbuttonpos;
	//	HorizontalListButton(0, buttonwidth, "Save", CampaignEdit_SaveCampaign, 0, 0, 0, 0, MBT_CONFIRM);
	//	HorizontalListButton(buttonwidth+option_spacing, buttonwidth, "Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
		
		option_pos = option_pos_start;
		BeginBottomButtons(2);
		DrawElement_BottomButton(str_save, CampaignEdit_SaveCampaign, 0, 0, 0, 0, MBT_CONFIRM);	
		DrawElement_BottomButton(str_cancel, CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
		EndBottomButtons();		
	}		
	
	Menu_End();
}

void EditCampaign() =
{
	Call_CampaignMenu();
	currentmenu.editingcampaign = 1;
}

void CampaignEdit_SetCampaignName() =
{
	local string campaignname, filename;
	local float file;
	
	if(InvalidInputString(0))
		return;
	
	campaignname = UnderscoreString(GetBufferString(active_menu.buf_list, 0));
	filename = strcat("campaign/_", uri_escape(campaignname));
	filename = strcat(filename, "/missions.txt");

	file = FileOpen(filename, FILE_READ);
	if(file == -1)
	{
	//	filename = uri_escape(filename);
		file = FileOpen(filename, FILE_WRITE);
		NewFileLine(file, "TIER new_tier");
		NewFileLine(file, "ENDTIER");
		fclose(file);		
		CloseMenu();
		cvar_set("campaign", campaignname);
		Call_MissionMenu_Campaign(1);
	}
	else
	{
		fclose(file);
		currentmenu.bodystring = "CAMPAIGNEXISTS";	
	}
}

void Draw_CampaignEdit_NewCampaign() =
{
	local string s, d;

	Menu_Start_ConfirmationMenu("New Campaign", '300 0 0', __FUNC__);

	Menu_InputWarnings();
	
	s = Translate("Campaign Name:");
	skiptranslation = true;
	Menu_AlignedText(s, ALIGN_LEFT);
	Menu_Input_All(GetInputBoxSize(s), string_null, ALIGN_RIGHT, 0, CampaignEdit_SetCampaignName);
	
	skiptranslation = false;
	BeginBottomButtons(2);
	DrawElement_BottomButton("Create", CampaignEdit_SetCampaignName, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();	
}

void NewCampaign() =
{
	SetCurrentMenu(Draw_CampaignEdit_NewCampaign);
	active_input = 1;	
}

void DisableMissionEditor() =
{
	m_hide();
	missioneditor_enabled = false;
	localcmd("cmd missioneditor\n");
}

void EnableMissionEditor() =
{
//	cvar_set("missioneditor", "1");
	m_hide();
	localcmd("cmd missioneditor\n");
//	m_toggle();
}

/*void TestMission() =
{
	DisableMissionEditor();
//	m_toggle();
}*/

void NewCampaignMission() =
{
	SetGameMode_Campaign();
	Call_MapMenu();
}

void NewDeathmatchMission() =
{
	SetGameMode_Deathmatch();
	Call_MapMenu();
}

void NewCTFMission() =
{
	SetGameMode_CTF();
	Call_MapMenu();
}

void EditCampaignMission() =
{
	active_menu.editingcampaign = 3;
	GetCampaignList();
}

void Draw_OfflineMissionEditor_Campaign() =
{
	Menu_Start_ESCMenu("Mission Editor", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);

	DrawElement_OptionTitle("Campaign");		
	
	Menu_Option_Text("New Campaign", NewCampaign);	
	Menu_Option_Text("Edit Campaign", EditCampaign);		
	BR();
	
	Menu_Option_Text("New Campaign Mission", NewCampaignMission);
	Menu_Option_Text("Edit Campaign Mission", EditCampaignMission);
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();	
}

void Draw_OfflineMissionEditor_Deathmatch() =
{
	Menu_Start_ESCMenu("Mission Editor", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);

	DrawElement_OptionTitle("Deathmatch");		
	
	Menu_Option_Text("New", NewDeathmatchMission);
	Menu_Option_Text("Edit", GetDeathmatchMissionList);	
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();	
}

void Draw_OfflineMissionEditor_CTF() =
{
	Menu_Start_ESCMenu("Mission Editor", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);

	DrawElement_OptionTitle("Capture the Flag");		
	
	Menu_Option_Text("New", NewCTFMission);
	Menu_Option_Text("Edit", GetCTFMissionList);
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();	
}

void Draw_OfflineMissionEditor() =
{
	local float minversion;

	Menu_Start_ESCMenu("Mission Editor", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	
	local string str_capturetheflag, str_chooseagamemode, str_campaign, str_deathmatch;
	str_capturetheflag	= Translate("Capture the Flag");
	str_chooseagamemode	= Translate("Choose a Game Mode");
	str_campaign		= Translate("Campaign");
	str_deathmatch		= Translate("Deathmatch");

	skiptranslation = true;
	
	DrawElement_OptionTitle(str_chooseagamemode);		
	
	Menu_CallSubMenu_Text(str_campaign, Draw_OfflineMissionEditor_Campaign);	
	
	#ifdef COMPILE_GAMEPLAYOPTIONS_SINGLEPLAYER
		OPTION_EPISODE_MIN = 999;
	#endif
	
	Menu_CallSubMenu_Text(str_deathmatch, Draw_OfflineMissionEditor_Deathmatch);	
	Menu_CallSubMenu_Text(str_capturetheflag, Draw_OfflineMissionEditor_CTF);		
	OPTION_EPISODE_MIN = false;

	skiptranslation = false;
	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();
}

void Call_OfflineMissionEditor() =
{
	SetGameTypeOfflineMissionEditor();
	SetCurrentMenu(Draw_OfflineMissionEditor);
}