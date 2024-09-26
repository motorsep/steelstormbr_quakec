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
void Draw_WaitingForServerMenu() =
{
	Menu_Start_Generic("Please Wait", '250 0 0', __FUNC__);
	Menu_Text("Waiting for server response.");
	BR();
	Menu_End();
}

void Call_WaitingForServerMenu() =
{
	SetCurrentMenu(Draw_WaitingForServerMenu);
	currentmenu.ESCFunc = ESCFunc_AllowESCMenu;
	currentmenu.menu_drawaftertime = time+1;
}

void DrawEntConnections() =
{
	if(!admin_editingent)
		return;

	local vector ofs;
	local entity e;
	
	ofs = '0 0 32';

//	if(admin_editingent.owner.targetentid || admin_editingent.owner.triggerentid)
//	{
		e = list_controlentchain;
		while(e)
		{
			if(e.owner.entid)
			if(e.owner.entid == admin_editingent.owner.associationentid)
				DrawPolygonBeam(admin_editingent.origin+ofs, e.origin+ofs, linklineimage, '1 1 0', 1);
				
			if(admin_editingent.owner.entid)
			if(admin_editingent.owner.entid == e.owner.associationentid)
				DrawPolygonBeam(e.origin+ofs, admin_editingent.origin+ofs, linklineimage, '1 1 0', 2);
		
			if(e.owner.entid)
			if(e.owner.entid == admin_editingent.owner.targetentid)
				DrawPolygonBeam(admin_editingent.origin+ofs, e.origin+ofs, linklineimage, '0 1 0', 1);
			
			if(admin_editingent.owner.entid)			
			if(admin_editingent.owner.entid == e.owner.triggerentid)	
				DrawPolygonBeam(admin_editingent.origin+ofs, e.origin+ofs, linklineimage, '0 1 0', 2);
				
			if(e.owner.entid)
			if(e.owner.entid == admin_editingent.owner.triggerentid)
				DrawPolygonBeam(e.origin+ofs, admin_editingent.origin+ofs, linklineimage, '0 1 0', 1);	
				
			if(admin_editingent.owner.entid)				
			if(admin_editingent.owner.entid == e.owner.targetentid)	
				DrawPolygonBeam(e.origin+ofs, admin_editingent.origin+ofs, linklineimage, '0 1 0', 2);	

			if(admin_editingent.owner.entid)				
			if(admin_editingent.owner.entid == e.owner.targetstagetwoentid)	
				DrawPolygonBeam(e.origin+ofs, admin_editingent.origin+ofs, linklineimage, '1 0.5 1', 2);
				
			if(e.owner.entid)
			if(e.owner.entid == admin_editingent.owner.targetstagetwoentid)
				DrawPolygonBeam(admin_editingent.origin+ofs, e.origin+ofs, linklineimage, '1 0.5 1', 1);	
				
			if(admin_editingent.owner.entid)				
			if(admin_editingent.owner.entid == e.owner.targetstagethreeentid)	
				DrawPolygonBeam(e.origin+ofs, admin_editingent.origin+ofs, linklineimage, '1 0 1', 2);
				
			if(e.owner.entid)
			if(e.owner.entid == admin_editingent.owner.targetstagethreeentid)
				DrawPolygonBeam(admin_editingent.origin+ofs, e.origin+ofs, linklineimage, '1 0 1', 1);				
				
			e = e.controlentchain;
		}
//	}
}

void UnsetAdminModeAlpha(entity e) =
{
	if(!(e.isdead && e.deadmodels == -1))
		e.drawmask = MASK_NORMAL;
}

void SetAdminModeAlpha(entity e) =
{
//	e.alpha = 0.5;
	e.drawmask = FALSE;
	e = e.list_childchain;
	while(e)
	{
		if(e.class == CLASS_OBJECT)
			e.drawmask = FALSE;
		//	e.alpha = 0.2;
		e = e.childchain;
	}
}

void RemoveMarkerAndCloseMenu() =
{
	RemoveMarker();
	CloseMenu();
}

void DeselectAdminEditingent() =
{
	DeselectEntity(admin_editingent);
	admin_editingent = world;	
	
	if(movingent)
		CancelEntityMove();
}

void DeselectAdminEditingentAndCloseMenu() =
{
	DeselectAdminEditingent();
	CloseMenu();
}

/*void SetMovementBehaviorStationary() =
{
	admin_editingent.owner.movement_behavior = MB_STATIONARY;
//	admin_editingent.owner.pathgroupid = 0;
	CommitObject(admin_editingent);
}

void SetMovementBehaviorRoam() =
{
	admin_editingent.owner.movement_behavior = MB_ROAM;
//	admin_editingent.owner.pathgroupid = 0;
	CommitObject(admin_editingent);
}

void SetMovementBehaviorPatrol() =
{
	admin_editingent.owner.movement_behavior = MB_PATROL;
	CommitObject(admin_editingent);
}*/

void Object_RollMovementType() =
{
	admin_editingent.owner.movement_behavior = admin_editingent.owner.movement_behavior + 1;
	if(admin_editingent.owner.movement_behavior >= 3)
		admin_editingent.owner.movement_behavior = 0;
	CommitObject(admin_editingent);
}

string TranslateElement_GetMovementType(float translation) =
{
	local string s;
	
	switch(translation)
	{
		case 0:		s = Translate("Stationary");	break;
		case 1:		s = Translate("Roam");			break;
		case 2:		s = Translate("Patrol");		break;
	}
	
	return s;
}

string GetMovementType(float ttype, string str_stationary, string str_roam, string str_patrol) =
{
	local string s;

	switch(ttype)
	{
		case 0:		s = str_stationary;		break;
		case 1:		s = str_roam;			break;
		case 2:		s = str_patrol;			break;	
	}
	
	return s;
}

void Admin_UnmarkForDeletion() =	{	UnmarkForDeletion(admin_editingent);	}

void Admin_MarkForDeletion() =	{	MarkForDeletion(admin_editingent);	}

/*void CommitPathsAndObject() =
{
	local string cmd;
	
	cmd = strcat(GetCommitEntityString(), GetCommitPathsString());
	localcmd(cmd);

	if(!admin_editingent.owner.id)
		SH_RemoveEnt(admin_editingent);	
}

void Draw_CommitPathsWithObjectConfirmation() =
{
	Menu_Start_ConfirmationMenu("There Are Associated Paths", '300 0 0');
	
	Menu_Text("The paths associated with this object");
	BR();
	Menu_Text("have been modified or do not exist on");
	BR();
	Menu_Text("the server. If you continue, all modified");
	BR();
	Menu_Text("paths will be commited as well.");
	BR();
	
	Menu_Option_Text("Continue", CommitPathsAndObject);	
	Menu_Option_Text("Cancel", CloseMenu);
	
	Menu_End();	
}*/

/*void CheckCommitObjectAssociation() =
{
	if(admin_editingent.owner.pathgroupid < 0)
	if(!admin_editingent.markedfordeletion)
	{
		SetCurrentMenu(Draw_CommitPathsWithObjectConfirmation);		
		return;
	}
		
	CommitObject();
}*/

/*void Draw_EditSpawnerSettings() =
{
	local vector input_size;

	Menu_Start_MissionEditor("Max Spawner Settings");
	
	input_size_x = input_fontsize_x*2+4;
		
	Menu_AlignedText("Ents Per Spawn:", ALIGN_LEFT);
	BR();	
	Menu_Input_Numerical(input_size, "3", true, true, true, 0, 6, SUB_Null);
	BR();

	Menu_AlignedText("Light Tanks:", ALIGN_LEFT);
	BR();	
	Menu_Slider_Text("", admin_editingent.spawner_max_lighttanks, "", 0, 10, 11);
	admin_editingent.spawner_max_lighttanks = GetSliderValue();
//	Menu_Input_Numerical(input_size, "3", true, true, true, 0, 6, SUB_Null);
	
	Menu_End();
}

void Call_EditSpawnerSettings() =
{
	SetCurrentMenu(Draw_EditSpawnerSettings);
	active_input = 1;
//	currentmenu.buf_list = CreateBuffer();	
//	SetBufferString(currentmenu.buf_list, 0, TitleString(mission_campaign));
//	SetBufferString(currentmenu.buf_list, 1, TitleString(mission_name));	
}*/

void UndeleteSelectedObject() =
{
	UndeleteObject(admin_editingent);
}

void DeleteSelectedObject() =
{
	DeleteObject(admin_editingent);
	if(admin_editingent.objclass != OBJ_TRAIN)
		CloseMenu();
}

void ToggleMapIcon() =
{
	admin_editingent.owner.mapicon = !admin_editingent.owner.mapicon;
	CommitObject(admin_editingent);
}

/*void SliderRules_FlagTeam() =
{
	admin_editingent.variant = GetSliderValue();
	CommitObject(admin_editingent);
}*/

void ToggleFlagNoFlag() =
{
	admin_editingent.owner.noflag = !admin_editingent.owner.noflag;
	CommitObject(admin_editingent);
}

void ToggleStartStateOff() =
{
	admin_editingent.owner.startstateoff = !admin_editingent.owner.startstateoff;
	CommitObject(admin_editingent);
}

void ToggleMultiplayerOnly() =
{
	admin_editingent.owner.multiplayeronly = !admin_editingent.owner.multiplayeronly;
	CommitObject(admin_editingent);
}

void ToggleTouchTrigger() =
{
	admin_editingent.owner.touchtrigger = !admin_editingent.owner.touchtrigger;
	CommitObject(admin_editingent);
}

void ToggleIndestructible() =
{
	admin_editingent.owner.indestructible = !admin_editingent.owner.indestructible;
	CommitObject(admin_editingent);
}

void ToggleRequiresKey() =
{
	admin_editingent.owner.requireskey = !admin_editingent.owner.requireskey;
	CommitObject(admin_editingent);
}

void SetActivationTime() =
{
	admin_editingent.owner.object_activationtime = stof(GetBufferString(active_menu.buf_list, 0))*60;
	admin_editingent.owner.object_activationtime = admin_editingent.owner.object_activationtime + stof(GetBufferString(active_menu.buf_list, 1));
	CommitObject(admin_editingent);
	CloseMenu();
}

void Draw_MissionEditor_SetActivationTime() =
{
	Menu_Start_MissionEditor("Activation Time", __FUNC__);
	Menu_Input_Time("Time:", admin_editingent.object_activationtime, SetActivationTime);
	BR();
	
	Menu_Option_Text_Confirm("Confirm", SetActivationTime);	
	Menu_Option_Text_Cancel("Cancel", CloseMenu);
	
	Menu_End();	
}

void SetTriggerDelayTime() =
{
	admin_editingent.owner.triggerdelaytime = stof(GetBufferString(active_menu.buf_list, 0))*60;
	admin_editingent.owner.triggerdelaytime = admin_editingent.owner.triggerdelaytime + stof(GetBufferString(active_menu.buf_list, 1));
	CommitObject(admin_editingent);
	CloseMenu();
}

void Draw_MissionEditor_SetTriggerDelayTime() =
{
	Menu_Start_MissionEditor("Trigger Delay", __FUNC__);
	Menu_Input_Time("Delay:", admin_editingent.owner.triggerdelaytime, SetTriggerDelayTime);
	BR();
	
	Menu_Option_Text_Confirm("Confirm", SetTriggerDelayTime);	
	Menu_Option_Text_Cancel("Cancel", CloseMenu);
	
	Menu_End();	
}

void SetMaxTriggers() =
{
	admin_editingent.owner.maxtriggers = stof(GetBufferString(active_menu.buf_list, 0));
	CommitObject(admin_editingent);
	CloseMenu();
}

void Draw_MissionEditor_SetMaxTriggers() =
{
	Menu_Start_MissionEditor("Max Triggers", __FUNC__);
	Menu_Input_NumericalIncrement("Max Triggers:", admin_editingent.owner.maxtriggers, SetMaxTriggers);
	BR();
	
	Menu_Option_Text_Confirm("Confirm", SetMaxTriggers);	
	Menu_Option_Text_Cancel("Cancel", CloseMenu);
	
	Menu_End();	
}

string TranslateElement_Triggers(float translation) =
{
	local string s;
	
	switch(translation)
	{
		case 0:		s = Translate("Set Trigger");	break;
		case 1:		s = Translate("Clear Trigger");	break;
		case 2:		s = Translate("Delay");			break;
		case 3:		s = Translate("Max Triggers");	break;		
	}

	return s;
}

void DrawElement_Triggers(string str_settrigger, string str_cleartrigger, string str_delay, string str_maxtriggers) =
{
	local float time_total, time_minutes, time_seconds;
	local string s;

	Menu_Option_Text(str_settrigger, Object_ChooseTrigger_Object);
	Menu_Option_Text(str_cleartrigger, Object_ClearTrigger);	
	
	time_total = admin_editingent.owner.triggerdelaytime;

	time_minutes = floor(time_total/60);
	time_seconds = time_total - time_minutes*60;
	
	s = strcat(ftos(time_minutes), ":");
	s = strcat(s, TimeString_Seconds(time_seconds));
	
	skiptranslation = true;
	Menu_AlignedText(s, ALIGN_RIGHT);	
	
	TempMenuSetting_body_alignment_horizontal(-1);
	TempMenuSetting_option_size_width(60);	
	Menu_CallSubMenu_Text(str_delay, Draw_MissionEditor_SetTriggerDelayTime);	
	RestoreMenuSetting_body_alignment_horizontal();
	RestoreMenuSetting_option_size_width();
	BR();
	
	skiptranslation = true;	
	Menu_AlignedText(ftos(admin_editingent.owner.maxtriggers), ALIGN_RIGHT);	
	TempMenuSetting_body_alignment_horizontal(-1);
	TempMenuSetting_option_size_width(60);	
	Menu_CallSubMenu_Text(str_maxtriggers, Draw_MissionEditor_SetMaxTriggers);	
	RestoreMenuSetting_body_alignment_horizontal();
	RestoreMenuSetting_option_size_width();
	BR();	
}

void Object_RollTriggerType() =
{
	admin_editingent.owner.triggertype = admin_editingent.owner.triggertype + 1;
	if(admin_editingent.owner.triggertype >= 3)
		admin_editingent.owner.triggertype = 0;
	CommitObject(admin_editingent);
}

string TranslateElement_GetTriggerType(float translation) =
{
	local string s;
	
	switch(translation)
	{
		case 0:		s = Translate("Toggle");		break;
		case 1:		s = Translate("Turn Off");		break;
		case 2:		s = Translate("Turn On");		break;		
	}
	
	return s;
}

string GetTriggerType(float ttype, string str_toggle, string str_turnoff, string str_turnon) =
{
	local string s;

	switch(ttype)
	{
		case 0:		s = str_toggle;		break;
		case 1:		s = str_turnoff;	break;
		case 2:		s = str_turnon;		break;	
	}
	
	return s;
}

string TranslateElement_Targets(float translation) =
{
	local string s;
	
	switch(translation)
	{
		case 0: s = Translate("Set Target");				break;
		case 1: s = Translate("Clear Target");				break;
		case 2: s = Translate("Set Association");			break;
		case 3: s = Translate("Clear Association");			break;
		case 4:	s = Translate("Trigger Type");				break;
		case 5:	s = Translate("Objective");					break;		
		case 6:	s = Translate("Set Stage Two Target");		break;	
		case 7:	s = Translate("Set Stage Three Target");	break;	
		case 8:	s = Translate("Clear Stage Two Target");	break;
		case 9: s = Translate("Clear Stage Three Target");	break;
	}
	
	return s;
}

void DrawElement_Targets(string str_settarget, string str_cleartarget, string str_setassociation, string str_clearassociation, string str_triggertype, string str_toggle, string str_turnoff, string str_turnon, string str_settarget_stagetwo, string str_settarget_stagethree, string str_cleartarget_stagetwo, string str_cleartarget_stagethree) =
{
	local string s;

	Menu_Option_Text(str_settarget, Object_ChooseTriggerTarget);		
	Menu_Option_Text(str_cleartarget, Object_ClearTriggerTarget);				
	
//	Menu_Option_Text(str_triggertype, Object_RollTriggerType);
//	s = GetTriggerType(admin_editingent.owner.triggertype, str_toggle, str_turnoff, str_turnon);
//	Menu_Text(s);

	if(admin_editingent.owner.hashealth || admin_editingent.owner.objclass == OBJ_TERMINAL)
	{
		Menu_Option_Text(str_settarget_stagetwo, Object_ChooseTriggerTarget_StageTwo);
		Menu_Option_Text(str_cleartarget_stagetwo, Object_ClearTriggerTargetStageTwo);
		Menu_Option_Text(str_settarget_stagethree, Object_ChooseTriggerTarget_StageThree);	
		Menu_Option_Text(str_cleartarget_stagethree, Object_ClearTriggerTargetStageThree);
	}

	Menu_Option_Text(str_setassociation, Object_ChooseTriggerAssociation);		
	Menu_Option_Text(str_clearassociation, Object_ClearTriggerAssociation);	
}

void DrawElement_ToggleStartStateOff(string str_startoff) =
{
	Menu_Option_CheckBox(str_startoff, ToggleStartStateOff, admin_editingent.owner.startstateoff);
}

void SpawnerSettingsSliderRules() =
{
	local float isportal;

	if(admin_editingent.owner.objclass == OBJ_PORTAL)
		isportal = 1;

	if(slider_current == 0+isportal)
		admin_editingent.spawner_max_areaents = GetSliderValue();
	else
	if(slider_current == 1+isportal)
		admin_editingent.spawner_max_ents = GetSliderValue();
	else
	if(slider_current == 2+isportal)
		admin_editingent.spawner_max_lighttanks = GetSliderValue();	
	else
	if(slider_current == 3+isportal)
		admin_editingent.spawner_max_mediumtanks = GetSliderValue();
	else
	if(slider_current == 4+isportal)
		admin_editingent.spawner_max_lightningtanks = GetSliderValue();	
	else
	if(slider_current == 5+isportal)	
		admin_editingent.spawner_max_heavytanks = GetSliderValue();	
	
	CommitObject(admin_editingent);
}

string TranslateElement_SpawnerSettings(float translation) =
{
	local string s;
	
	switch(translation)
	{
		case 0:		s = Translate("Max Spawner Settings");	break;
		case 1:		s = Translate("Ents in Area:");			break;
		case 2:		s = Translate("Ents Per Spawn:");		break;		
		case 3:		s = Translate("Light Tanks:");			break;	
		case 4:		s = Translate("Medium Tanks:");			break;	
		case 5:		s = Translate("Lightning Tanks:");		break;	
		case 6:		s = Translate("Heavy Tanks:");			break;	
	}

	return s;
}

void DrawElement_SpawnerSettings(string str_maxspawnersettings, string str_entsinarea, string str_entsperspawn, string str_lighttanks, string str_mediumtanks, string str_lightningtanks, string str_heavytanks) =
{
	local float maxents;

	if(admin_editingent.owner.objclass == OBJ_ENEMYSPAWN)
		maxents = 4;
	else
	if(admin_editingent.owner.objclass == OBJ_PORTAL)
		maxents = 8;

	DrawElement_OptionTitle(str_maxspawnersettings);

	SliderRules = SpawnerSettingsSliderRules;
	
	if(admin_editingent.owner.objclass == OBJ_PORTAL)
	{
		TempMenuSetting_body_fontcolor(option_fontcolor);
		Menu_AlignedText(str_entsinarea, ALIGN_LEFT);
		RestoreMenuSetting_body_fontcolor();
		skiptranslation = true;
		Menu_AlignedText(ftos(admin_editingent.spawner_max_areaents), ALIGN_RIGHT);		
		BR();
		skiptranslation = true;
		Menu_Slider_Simple(admin_editingent.spawner_max_areaents, "", 1, 20, 20, option_size_x);			
	}

	TempMenuSetting_body_fontcolor(option_fontcolor);
	Menu_AlignedText(str_entsperspawn, ALIGN_LEFT);
	RestoreMenuSetting_body_fontcolor();
	skiptranslation = true;
	Menu_AlignedText(ftos(admin_editingent.spawner_max_ents), ALIGN_RIGHT);		
	BR();
	Menu_Slider_Simple(admin_editingent.spawner_max_ents, "", 1, maxents, maxents, option_size_x);
	
	TempMenuSetting_body_fontcolor(option_fontcolor);
	Menu_AlignedText(str_lighttanks, ALIGN_LEFT);
	RestoreMenuSetting_body_fontcolor();
	skiptranslation = true;
	Menu_AlignedText(ftos(admin_editingent.spawner_max_lighttanks), ALIGN_RIGHT);		
	BR();	
	Menu_Slider_Simple(admin_editingent.spawner_max_lighttanks, "", 0, maxents, maxents+1, option_size_x);
	
	TempMenuSetting_body_fontcolor(option_fontcolor);
	Menu_AlignedText(str_mediumtanks, ALIGN_LEFT);
	RestoreMenuSetting_body_fontcolor();
	skiptranslation = true;
	Menu_AlignedText(ftos(admin_editingent.spawner_max_mediumtanks), ALIGN_RIGHT);		
	BR();
	Menu_Slider_Simple(admin_editingent.spawner_max_mediumtanks, "", 0, maxents, maxents+1, option_size_x);
	
OPTION_EPISODE_MIN = 2;	
	TempMenuSetting_body_fontcolor(option_fontcolor);
	Menu_AlignedText(str_lightningtanks, ALIGN_LEFT);
	RestoreMenuSetting_body_fontcolor();
	skiptranslation = true;
	Menu_AlignedText(ftos(admin_editingent.spawner_max_lightningtanks), ALIGN_RIGHT);		
	BR();
	Menu_Slider_Simple(admin_editingent.spawner_max_lightningtanks, "", 0, maxents, maxents+1, option_size_x);
OPTION_EPISODE_MIN = false;	
	
	TempMenuSetting_body_fontcolor(option_fontcolor);
	Menu_AlignedText(str_heavytanks, ALIGN_LEFT);
	RestoreMenuSetting_body_fontcolor();
	skiptranslation = true;
	Menu_AlignedText(ftos(admin_editingent.spawner_max_heavytanks), ALIGN_RIGHT);		
	BR();
	Menu_Slider_Simple(admin_editingent.spawner_max_heavytanks, "", 0, maxents, maxents+1, option_size_x);
	
	BR();
	
	SliderRules = SUB_Null;
}

void ObjectScaleSliderRules() =
{
	admin_editingent.scale = GetSliderValue();
	CommitObject(admin_editingent);
}

void SetTerminalType_Hack() =		{	admin_editingent.owner.terminaltype = 0;	CommitObject(admin_editingent);	}
void SetTerminalType_Upload() =		{	admin_editingent.owner.terminaltype = 1;	CommitObject(admin_editingent);	}
void SetTerminalType_Download() =	{	admin_editingent.owner.terminaltype = 2;	CommitObject(admin_editingent);	}
void SetTerminalType_Activate() =	{	admin_editingent.owner.terminaltype = 3;	CommitObject(admin_editingent);	}
void SetTerminalType_Deactivate() =	{	admin_editingent.owner.terminaltype = 4;	CommitObject(admin_editingent);	}

void RotateTeam() =
{
	local float t;
	t = admin_editingent.owner.team;
	if(t == TEAMS_MAX)
		t = 0;
	else
		t++;
		
	admin_editingent.owner.team = t;
	CommitObject(admin_editingent);
}

void Draw_MissionEditorEntityOptions() =
{
	local string s;
	local vector scrollboxsize;
	local float option_pos_start, windowheight;

	local string str_title, str_moveobject, str_touchtrigger, str_pickupoptions, str_effectname, str_seteffect, str_soundname, str_setsound, str_trainoptions, str_needstargetname, str_forcefieldoptions, str_teleporteroptions, str_setdestination, str_settarget, str_settarget_stagetwo, str_settarget_stagethree, str_cleartarget, str_cleartarget_stagetwo, str_cleartarget_stagethree, str_setassociation, str_clearassociation, str_triggertype, str_objective, str_toggle, str_turnoff, str_turnon, str_settrigger, str_cleartrigger, str_delay, str_maxtriggers, str_startoff, str_maxspawnersettings, str_entsinarea, str_entsperspawn, str_lighttanks, str_mediumtanks, str_lightningtanks, str_heavytanks, str_movementtype, str_setpatrolpath, str_stationary, str_roam, str_patrol, str_pathoptions, str_extendpath, str_hasflag, str_mapicon, str_scale, str_multiplayeronly, str_servercommands, str_undelete, str_delete, str_deselect, str_activationtime, str_terminaltype, str_hack, str_upload, str_download, str_activate, str_deactivate, str_requireskey, str_indestructible, str_team;
	
	Menu_Start_MissionEditor("Entity Options", __FUNC__);

	str_moveobject			= Translate("Move Object");
	str_touchtrigger		= Translate("Touch Trigger");
	str_pickupoptions		= Translate("Pickup Options");
	str_effectname			= Translate("Effect Name:");
	str_seteffect			= Translate("Set Effect");
	str_soundname			= Translate("Sound Name:");
	str_setsound			= Translate("Set Sound");
	str_trainoptions		= Translate("Train Options");
	str_needstargetname		= Translate("This object needs a targetname to be manipulated.");
	str_forcefieldoptions	= Translate("Forcefield Options");
	str_teleporteroptions	= Translate("Teleporter Options");
	str_setdestination		= Translate("Set Destination");	
	str_settrigger			= TranslateElement_Triggers(0);
	str_cleartrigger		= TranslateElement_Triggers(1);
	str_delay				= TranslateElement_Triggers(2);
	str_maxtriggers			= TranslateElement_Triggers(3);	
	str_settarget			= TranslateElement_Targets(0);
	str_cleartarget			= TranslateElement_Targets(1);
	str_setassociation		= TranslateElement_Targets(2);
	str_clearassociation	= TranslateElement_Targets(3);
	str_triggertype			= TranslateElement_Targets(4);
	str_objective			= TranslateElement_Targets(5);
	str_settarget_stagetwo	= TranslateElement_Targets(6);
	str_settarget_stagethree	= TranslateElement_Targets(7);
	str_cleartarget_stagetwo	= TranslateElement_Targets(8);
	str_cleartarget_stagethree	= TranslateElement_Targets(9);
	str_toggle				= TranslateElement_GetTriggerType(0);
	str_turnoff				= TranslateElement_GetTriggerType(1);
	str_turnon				= TranslateElement_GetTriggerType(2);
	str_startoff			= Translate("Start Off");
	str_maxspawnersettings	= TranslateElement_SpawnerSettings(0);
	str_entsinarea			= TranslateElement_SpawnerSettings(1);
	str_entsperspawn		= TranslateElement_SpawnerSettings(2);
	str_lighttanks			= TranslateElement_SpawnerSettings(3);
	str_mediumtanks			= TranslateElement_SpawnerSettings(4);
	str_lightningtanks		= TranslateElement_SpawnerSettings(5);
	str_heavytanks			= TranslateElement_SpawnerSettings(6);
	str_movementtype		= Translate("Movement Type");
	str_setpatrolpath		= Translate("Set Patrol Path");
	str_stationary			= TranslateElement_GetMovementType(0);
	str_roam				= TranslateElement_GetMovementType(1);
	str_patrol				= TranslateElement_GetMovementType(2);
	str_pathoptions			= Translate("Path Options");
	str_extendpath			= Translate("Extend Path");
	str_hasflag				= Translate("Has Flag");
	str_mapicon				= Translate("Map Icon");
	str_scale				= Translate("Scale:");
	str_multiplayeronly		= Translate("Multiplayer Only");
	str_servercommands		= Translate("Server Commands");
	str_undelete			= Translate("Undelete");
	str_delete				= Translate("Delete");
	str_deselect			= Translate("Deselect");
	str_activationtime		= Translate("Activation Time");
	str_terminaltype		= Translate("Terminal Type");
	str_hack				= Translate("Hack");
	str_upload				= Translate("Upload");
	str_download			= Translate("Download");
	str_activate			= Translate("Activate");
	str_deactivate			= Translate("Deactivate");
	str_requireskey			= Translate("Requires Key");
	str_indestructible		= Translate("Indestructible");
	str_team				= Translate("Team");
	skiptranslation			= true;
	
	scrollboxsize_x = option_size_x - scrollbar_width;//150 - border_size_x*2 - body_margin_y*2;
	scrollboxsize_y = vid_size_y - title_size_y - border_size_y*2 - body_margin_y*2;
	
	if(active_menu.scrollboxmeasurement == 2)
	{
		scrollbar_incrementsize = option_size_y + option_spacing;
		option_pos_y = BeginScrollingWindow(option_pos, scrollboxsize, 0, 0);
		option_size_x -= scrollbar_width + option_spacing;
	}

	option_pos_start = option_pos_y;
	
	
	if(cvar("editor_showentid"))
	{
		s = strcat(".entid: ", ftos(admin_editingent.owner.entid));
		Menu_Text(s);
		BR();
		BR();
	}
	
	
	if(admin_editingent.objclass != OBJ_TRAIN)
	{
		Menu_Option_Text(str_moveobject, MoveAdminEnt);
		BR();	
	}
	
	if(GameMode_HasTeams(gamemode))
	if(admin_editingent.owner.canhaveteam)
	{
		Menu_Option_Text(str_team, RotateTeam);
		s = GetTeamName(admin_editingent.owner.team);
		Menu_Text(s);
		BR();BR();
	}
	
	if(admin_editingent.objclass == OBJ_STRUCTURE
	&& admin_editingent.variant == STRUCTURE_REFINERY)
	{
		Menu_Option_CheckBox(str_indestructible, ToggleIndestructible, admin_editingent.indestructible);
		BR();
	}
	else
	if(admin_editingent.objclass == OBJ_TERMINAL)
	{
		local float time_total, time_minutes, time_seconds;
		time_total = admin_editingent.object_activationtime;

		time_minutes = floor(time_total/60);
		time_seconds = time_total - time_minutes*60;

		s = strcat(ftos(time_minutes), ":");
		s = strcat(s, TimeString_Seconds(time_seconds));

		skiptranslation = true;
		Menu_AlignedText(s, ALIGN_RIGHT);	
	
		TempMenuSetting_body_alignment_horizontal(-1);
		TempMenuSetting_option_size_width(60);	
		Menu_CallSubMenu_Text(str_activationtime, Draw_MissionEditor_SetActivationTime);	
		RestoreMenuSetting_body_alignment_horizontal();
		RestoreMenuSetting_option_size_width();
		BR();	
		
		Menu_Text(str_terminaltype);
		BR();
		Menu_Option_CheckBox(str_hack, SetTerminalType_Hack, admin_editingent.owner.terminaltype == 0);
		Menu_Option_CheckBox(str_upload, SetTerminalType_Upload, admin_editingent.owner.terminaltype == 1);
		Menu_Option_CheckBox(str_download, SetTerminalType_Download, admin_editingent.owner.terminaltype == 2);
		Menu_Option_CheckBox(str_activate, SetTerminalType_Activate, admin_editingent.owner.terminaltype == 3);
		Menu_Option_CheckBox(str_deactivate, SetTerminalType_Deactivate, admin_editingent.owner.terminaltype == 4);
		BR();
		
		Menu_Option_CheckBox(str_requireskey, ToggleRequiresKey, admin_editingent.owner.requireskey);		
		BR();
	}
	else
	if(admin_editingent.objclass == OBJ_TRIGGERRELAY)
	{
		Menu_Option_CheckBox(str_touchtrigger, ToggleTouchTrigger, admin_editingent.owner.touchtrigger);
		BR();
	}
	else
	if(admin_editingent.owner.flags & FL_ITEM)
		DrawElement_OptionTitle(str_pickupoptions);
	else		
	if(admin_editingent.owner.objclass == OBJ_PARTICLEEMITTER)
	{
		TempMenuSetting_body_fontcolor(option_fontcolor);
		Menu_AlignedText(str_effectname, ALIGN_LEFT);
		RestoreMenuSetting_body_fontcolor();
		option_pos_y += body_fontsize_y;
		skiptranslation = true;
		Menu_AlignedText(admin_editingent.particleemittereffect, ALIGN_LEFT);		
		option_pos_y += body_fontsize_y + 4;		
		BR();
		
		Menu_Option_Text(str_seteffect, Call_SetParticleEffect);
		BR();
	}
	else
	if(admin_editingent.owner.objclass == OBJ_AMBIENTSOUND)
	{
		TempMenuSetting_body_fontcolor(option_fontcolor);
		Menu_AlignedText(str_soundname, ALIGN_LEFT);
		RestoreMenuSetting_body_fontcolor();
		option_pos_y += body_fontsize_y;
		skiptranslation = true;
		Menu_AlignedText(admin_editingent.ambientsoundeffect, ALIGN_LEFT);		
		option_pos_y += body_fontsize_y + 4;		
		BR();
		
		Menu_Option_Text(str_setsound, Call_SetAmbientSound);
		BR();
		
//		DrawElement_Triggers();
	}	
	else
	if(admin_editingent.objclass == OBJ_TRAIN)
	{
		if(admin_editingent.owner.targetname)
		{	
			if(!admin_editingent.owner.isdeletedformission)
				DrawElement_OptionTitle(str_trainoptions);
		}
		else
		{
			s = str_needstargetname;
			active_menu.buf_textblock = DrawTextBlock(active_menu.buf_textblock, option_pos, -1, '120 0 0', s, body_fontsize, body_fontcolor, body_fontalpha, body_fontflags);
		}
	}
	else	
	if(admin_editingent.owner.objclass == OBJ_FORCEFIELD)
		DrawElement_OptionTitle(str_forcefieldoptions);
	else
	if(admin_editingent.owner.objclass == OBJ_TELEPORTER)
	{
		DrawElement_OptionTitle(str_teleporteroptions);
		Menu_Option_Text(str_setdestination, Portal_ChooseDestination);
		BR();
	}
	else
	if(admin_editingent.owner.objclass == OBJ_PORTAL)
	{
		DrawElement_SpawnerSettings(str_maxspawnersettings, str_entsinarea, str_entsperspawn, str_lighttanks, str_mediumtanks, str_lightningtanks, str_heavytanks); // +6
	}
	else
	if(admin_editingent.owner.objclass == OBJ_ENEMYSPAWN)
	{
		DrawElement_SpawnerSettings(str_maxspawnersettings, str_entsinarea, str_entsperspawn, str_lighttanks, str_mediumtanks, str_lightningtanks, str_heavytanks);// +6
	}
	else
	if(admin_editingent.owner.objclass == OBJ_NPC)
	{
		local string s_stationary, s_roam, s_patrol;
//		DrawElement_Triggers();
//		DrawElement_Targets();
//		BR();
//		DrawElement_TriggerOptions();		
//		BR();
	//	Menu_Option_Text("Objective", Call_EditObjectives);
		
		Menu_Option_Text(str_movementtype, Object_RollMovementType);
		s = GetMovementType(admin_editingent.owner.movement_behavior, str_stationary, str_roam, str_patrol);
		Menu_Text(s);
		BR();
		if(admin_editingent.owner.movement_behavior == MB_PATROL)
			Menu_Option_Text(str_setpatrolpath, CallSetAIPatrolPath);
		BR();
		}
	else
	if(admin_editingent.owner.objclass == OBJ_PATH)
	{
		if(!admin_editingent.markedfordeletion)
		{	
			DrawElement_OptionTitle(str_pathoptions);
	
			if(!admin_editingent.owner.nextpathpoint)
				Menu_Option_Text(str_extendpath, ExtendPath);
	/*		else
			if(admin_editingent.owner.nextpathpoint)
			if(admin_editingent.owner.prevpathpoint)
			{
				Menu_Option_Text("Split Path From Next", SplitPathFromNext);
				Menu_Option_Text("Split Path From Prev", SplitPathFromPrev);
			}*/
			
	/*		if(admin_editingent.nextpathpoint)
			if(admin_editingent.pathgroupid != admin_editingent.nextpathpoint.pathgroupid)
			if(admin_editingent.nextpathpoint.prevpathpoint != admin_editingent)
				Menu_Option_Text("Transfer Splice", SplicePaths);*/

			BR();
		//	Menu_Option_Text("Delete Point", DeleteSelectedObject);//DeletePoint);
		//	BR();		
//			DrawElement_Targets();
		}
	}
	else
	if(admin_editingent.owner.objclass == OBJ_FLAGBASE)
	{
	/*	SliderRules = SliderRules_FlagTeam;
		TempMenuSetting_body_fontcolor(option_fontcolor);
		Menu_AlignedText("Team:", ALIGN_LEFT);
		RestoreMenuSetting_body_fontcolor();
		skiptranslation = true;
		Menu_AlignedText(ftos(admin_editingent.variant), ALIGN_RIGHT);		
		BR();	
		Menu_Slider_Simple(admin_editingent.variant, "", 0, 4, 5, 0);
		SliderRules = SUB_Null;*/
	
		if(admin_editingent.owner.variant != 0)
			Menu_Option_CheckBox(str_hasflag, ToggleFlagNoFlag, !admin_editingent.owner.noflag);
	}		

	if(!(admin_editingent.objclass == OBJ_TRAIN && !admin_editingent.owner.targetname))	
	if(admin_editingent.objclass == OBJ_TRIGGERRELAY
	|| admin_editingent.objclass == OBJ_PARTICLEEMITTER
	|| admin_editingent.objclass == OBJ_TRAIN
	|| admin_editingent.objclass == OBJ_FORCEFIELD
	|| admin_editingent.objclass == OBJ_PORTAL
	|| admin_editingent.objclass == OBJ_PRESSUREPLATE
	|| (admin_editingent.objclass == OBJ_STRUCTURE
		&& (admin_editingent.variant == STRUCTURE_INCINERATOR
			|| admin_editingent.variant == STRUCTURE_PYLON
			|| admin_editingent.variant == STRUCTURE_REFINERY
		//	|| admin_editingent.variant == STRUCTURE_EVAPORATOR
			|| admin_editingent.variant == STRUCTURE_GASPUMP) ) )
	{
		DrawElement_ToggleStartStateOff(str_startoff);
		BR();
	}	
	
	if(LinkRules_Targets(admin_editingent))
//	&& !admin_editingent.owner.objclass == OBJ_NPC)
	{
		DrawElement_Triggers(str_settrigger, str_cleartrigger, str_delay, str_maxtriggers);
	//	DrawElement_TriggerOptions();		
	}
	
	if(LinkRules_Object(admin_editingent.owner))
//	&& !admin_editingent.owner.objclass == OBJ_NPC)
	{
		DrawElement_Targets(str_settarget, str_cleartarget, str_setassociation, str_clearassociation, str_triggertype, str_toggle, str_turnoff, str_turnon, str_settarget_stagetwo, str_settarget_stagethree, str_cleartarget_stagetwo, str_cleartarget_stagethree);
	}
	
	if(LinkRules_Objective(admin_editingent.owner))
		Menu_Option_Text(str_objective, Call_EditObjectives);

	BR();	
	
	if(LinkRules_Object(admin_editingent.owner)
	|| admin_editingent.owner.objclass == OBJ_FORCEFIELD
	|| admin_editingent.owner.objclass == OBJ_TELEPORTER
	|| admin_editingent.owner.objclass == OBJ_STRUCTURE)
	if(admin_editingent.owner.objclass != OBJ_CRYSTAL)
	if(admin_editingent.owner.objclass != OBJ_PATH)
	if(admin_editingent.owner.objclass != OBJ_TRIGGERRELAY)
		Menu_Option_CheckBox(str_mapicon, ToggleMapIcon, admin_editingent.owner.mapicon);
	
/*	if(admin_editingent.owner.allowrandomscale)
	{
		SliderRules = ObjectScaleSliderRules;
		TempMenuSetting_body_fontcolor(option_fontcolor);
		Menu_AlignedText(str_scale, ALIGN_LEFT);
		RestoreMenuSetting_body_fontcolor();
		skiptranslation = true;
		Menu_AlignedText(substring(ftos(admin_editingent.scale), 0, 3), ALIGN_RIGHT);		
		BR();
		Menu_Slider_Simple(admin_editingent.scale, "", 0.1, 5, 50, option_size_x);	
		SliderRules = SUB_Null;
		BR();
	}*/
	
	if(!(admin_editingent.objclass == OBJ_TRAIN && !admin_editingent.owner.targetname))	
	{
		Menu_Option_CheckBox(str_multiplayeronly, ToggleMultiplayerOnly, admin_editingent.owner.multiplayeronly);	
		BR();
	}
	
	if(!(admin_editingent.objclass == OBJ_TRAIN && !admin_editingent.owner.targetname))	
	{
		DrawElement_OptionTitle(str_servercommands);
		
		if(admin_editingent.owner.isdeletedformission)
			Menu_Option_Text(str_undelete, UndeleteSelectedObject);
		else
			Menu_Option_Text(str_delete, DeleteSelectedObject);
	}
	
//	BR();
	Menu_Option_Text(str_deselect, DeselectAdminEditingentAndCloseMenu);
//	BR();
//	if(active_menu.menusize_y >= vid_size_y)

		windowheight = option_pos_y - option_pos_start;

		if(active_menu.scrollboxmeasurement == 2)
			EndScrollingWindow(windowheight, 0, 0);		

		if(active_menu)			
		if(windowheight > scrollboxsize_y)
		{
			if(!active_menu.scrollboxmeasurement)
				active_menu.scrollboxmeasurement = 2;
		}
		else
		{
			active_menu.scrollboxmeasurement = 0;
			ResetScrollingWindow();
		}

//		active_menu.menusize_y = vid_size_y;
	
//	option_pos_y = windowstart_y + (option_pos_y - option_pos_start) + option_spacing;	
	
	Menu_End();
}

/*void EntHeightControls(entity e) =
{
	if(!e.allowheightadjustment)
		return;
		
	local float bd_minus, bd_plus;

	if(cl_buttondown[45])
		bd_minus = true;
	if(cl_buttondown[170])
		bd_minus = true;
	if(cl_buttondown[61])
		bd_plus = true;
	if(cl_buttondown[171])
		bd_plus = true;	

	if(cl_buttondown[K_SHIFT])
	if(bd_plus)
		currentplacementheight += 5;
	else
	if(bd_minus)
		currentplacementheight = max(0, currentplacementheight - 5);
	else
	if(cl_button == 48 || cl_button == 169)
	{
		print("Reset height.\n");
		currentplacementheight = 0;
	}
}*/

float AllowRandomYaw(entity e) =
{
	if(e.modelflags & MF_ROTATE)
		return false;
		
	if(e.objclass == OBJ_PATH)
		return false;
		
	return true;
}

void EntAngleControls(entity e) =
{
	if(!AllowRandomYaw(e))
		return;
		
	local vector oldang;
	oldang = e.angles;

	if(e.allowpitchadjustment)
	{
		if(GameControl(CTRL_OBJECTPITCHADD, 1))
			e.angles_x += 100*frametime;
		else
		if(GameControl(CTRL_OBJECTPITCHSUBTRACT, 1))
			e.angles_x -= 100*frametime;
		else
		if(GameControl(CTRL_RESETOBJECTPITCH, 0))
			e.angles_x = 0;
			
		e.angles_x = BindAngle(0, e.angles_x, 360);		
	}
	
	if(e.chullrotation >= CHULLROT_ALL)
	{
		if(GameControl(CTRL_OBJECTYAWADD, 1))
			e.angles_y += 100*frametime;
		else
		if(GameControl(CTRL_OBJECTYAWSUBTRACT, 1))
			e.angles_y -= 100*frametime;
	}
	else
	{
		if(GameControl(CTRL_OBJECTYAWADD, 0))
			e.angles_y += 45;
		else
		if(GameControl(CTRL_OBJECTYAWSUBTRACT, 0))
			e.angles_y -= 45;		
	}	
	
	e.angles_y = BindAngle(0, e.angles_y, 360);	
		
	if(oldang != e.angles)
	{
		modifyingentangles = true;
	
		if(!placedent_randomyaw)
			defaultentangles_y = e.angles_y;
		
		defaultentangles_x = e.angles_x;
	}
	else
	if(modifyingentangles)
	{
		modifyingentangles = false;
		if(!movingent)
		if(!marker)
			CommitObject(e);
	}
}

void Draw_MisionEditor_LinkMessage_LinkSuccessful() =
{
	Menu_Start_ConfirmationMenu("", '300 0 0', __FUNC__);
	Menu_Text("Link successfull.");
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Continue", CloseMenu, 0, 0, 0, 0, MBT_BASIC);
	EndBottomButtons();
	Menu_End();
}

void Draw_MisionEditor_LinkMessage_CantLinkToSelf() =
{
	Menu_Start_ConfirmationMenu("", '300 0 0', __FUNC__);
	Menu_Text("Cannot link to self.");
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Continue", CloseMenu, 0, 0, 0, 0, MBT_BASIC);
	EndBottomButtons();
	Menu_End();
}

/*void Draw_MisionEditor_TeleporterLinkError_DestinationDoesntExist() =
{
	Menu_Start_ConfirmationMenu("", '300 0 0');
	Menu_Text("Destination does not exist on the server.");
	BR();
	Menu_Text("Commit destination teleporter and try again.");
	BR();
	Menu_Option_Text("Continue", CloseMenu);
	Menu_End();
}*/

void ObjectMouseControls(entity e) =
{
	if(marker || movingent)
		return;
		
	if(linkingobj)
	{
		if(GameControl(CTRL_EDITORBUTTON1, -1) && !CURSOROVERMENU && LinkRules(hover_ent))
			ObjectLinkFunc();
		else
		if(GameControl(CTRL_EDITORBUTTON2, -1))
			CloseMenu();
		return;
	}
	
	if(GameControl(CTRL_EDITORBUTTON1, -1))// || GameControl(CTRL_EDITORBUTTON2, -1))
		SetAdminEditingEnt(e);
}

void ObjectKeyControls() =
{
	if(!admin_editingent || linkingobj)
//	|| linkingportal
//	|| linkingforcefield
//	|| assigningaipatrolpath)
		return;
		
	EntAngleControls(admin_editingent);
//	EntHeightControls(admin_editingent);
	
	if(!movingent)
	if(!admin_editingent.owner.isdeletedformission)
	if(!(admin_editingent.objclass == OBJ_TRAIN && !admin_editingent.owner.targetname))
	//	if(cl_button == K_DEL)
		if(GameControl(CTRL_DELETE, 0))
		{
		/*	if(admin_editingent.owner.objclass == CLASS_PATH)
			{
				pathfunctions = PATHFUNC_DELETE;
				CommitObject(admin_editingent);
			}
			else
			if(admin_editingent.owner.isshared)*/
				DeleteObject(admin_editingent);
//			else
//				Admin_RemoveEnt();
				
			CloseMenu();
		}
}

void Draw_MissionEditorSetTeleporterDestination() =
{
	Menu_Start_MissionEditor("Select Destination", __FUNC__);
	
	Menu_Option_Text("Select", ObjectLinkFunc);	
	Menu_Option_Text_Cancel("Cancel", CloseMenu);
	
	Menu_End();	
}

void Draw_MissionEditorSetTrigger() =
{
	Menu_Start_MissionEditor("Select Trigger", __FUNC__);
	
	Menu_Option_Text("Select", ObjectLinkFunc);	
	Menu_Option_Text_Cancel("Cancel", CloseMenu);
	
	Menu_End();	
}

void Draw_MissionEditorSetTriggerTarget() =
{
	Menu_Start_MissionEditor("Select Target", __FUNC__);
	
	Menu_Option_Text("Select", ObjectLinkFunc);	
	Menu_Option_Text_Cancel("Cancel", CloseMenu);
	
	Menu_End();	
}

void Draw_MissionEditorSetTriggerAssociation() =
{
	Menu_Start_MissionEditor("Select Association", __FUNC__);
	
	Menu_Option_Text("Select", ObjectLinkFunc);	
	Menu_Option_Text_Cancel("Cancel", CloseMenu);
	
	Menu_End();	
}

void MissionEditorPlacingEntityESCFunc() =
{
	ClearMarkerPlacementValues();
	CloseMenu();
}

void Draw_MissionEditorPlacingEntity() =
{
	Menu_Start_MissionEditor("Placing Entity", __FUNC__);
	
	Menu_Option_Text("Place", PlaceMarkerAtLocation);	
	Menu_Option_Text_Cancel("Cancel", MissionEditorPlacingEntityESCFunc);
	
	Menu_End();	
}

/*void CloseMenu_AdminMenu_Object() =	{	admin_editingent = world;	}

void Draw_AdminMenu_Object() =
{
	Menu_Start_MissionEditor("Edit Object");
	
	Menu_Option_Text("Edit", SUB_Null);
	Menu_Option_Text("Configure", SUB_Null);
	Menu_Option_Text("Options", SUB_Null);	
	BR();
	Menu_Option_Text_Back("Back", CloseMenu);
	
	Menu_End();	
}*/

void Draw_MissionEditor_Crystals() =
{
	Menu_Start_MissionEditor("Crystals", __FUNC__);
	
	Menu_Option_Text("Red", PlaceCrystal_Red);
	Menu_Option_Text("Green", PlaceCrystal_Green);
	Menu_Option_Text("Blue", PlaceCrystal_Blue);	
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();	
}

void Draw_MissionEditor_Weapons() =
{
	Menu_Start_MissionEditor("Weapons", __FUNC__);

OPTION_EPISODE_MIN = 2;
	Menu_Option_Text("Miniguns", PlaceMiniguns);
	Menu_Option_Text("Flack Guns", PlaceFlackGuns);
	Menu_Option_Text("Shockwave Device", PlaceShockwaveDevice);
OPTION_EPISODE_MIN = false;	
	Menu_Option_Text("Storm Plow", PlaceStormPlow);
OPTION_EPISODE_MIN = 2;	
	Menu_Option_Text("Storm Spread", PlaceStormSpread);
	Menu_Option_Text("Storm Shield", PlaceStormShield);
	Menu_Option_Text("Thunderbolt", PlaceThunderbolt);
OPTION_EPISODE_MIN = false;	
	Menu_Option_Text("Beam Cannon", PlaceBeamCannon);	
	Menu_Option_Text("Rocket Pod", PlaceRocketPod);
OPTION_EPISODE_MIN = 2;	
	Menu_Option_Text("Homing Missiles", PlaceHomingMissiles);
	Menu_Option_Text("MIRV Mortar", PlaceMIRVMortar);	
OPTION_EPISODE_MIN = false;	
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();	
}

void Draw_MissionEditor_Pickups() =
{
	Menu_Start_MissionEditor("Pickups", __FUNC__);
	
	Menu_CallSubMenu_Text("Crystals", Draw_MissionEditor_Crystals);
	Menu_Option_Text("Armor Plate", PlaceArmorShard);
	Menu_Option_Text("Full Armor", PlaceArmorShell);
	Menu_Option_Text("Shield", PlaceShield);
	Menu_Option_Text("Extra Life", PlaceExtraLife);
	Menu_CallSubMenu_Text("Weapons", Draw_MissionEditor_Weapons);
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

/*void Draw_MissionEditor_EnemiesSingleUnit_Infantry() =
{
	Menu_Start_MissionEditor("Infantry");

	Menu_Option_Text("Light Tank", PlaceEnemy_LightTank);
	Menu_Option_Text("Medium Tank", PlaceEnemy_MediumTank);
	Menu_Option_Text("Heavy Tank", PlaceEnemy_HeavyTank);
	Menu_Option_Text("Lightning Tank", PlaceEnemy_LightningTank);	
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}*/

/*void Draw_MissionEditor_EnemiesSingleUnit_Turrets() =
{
	Menu_Start_MissionEditor("Turrets");

	Menu_Option_Text("Light Plasma", PlaceTurret_LightPlasma);
	Menu_Option_Text("Heavy Beam", PlaceTurret_HeavyBeam);
	Menu_Option_Text("Rocket", PlaceTurret_Rocket);
	Menu_Option_Text("Repair", PlaceTurret_Repair);	
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}*/

/*void Draw_MissionEditor_EnemiesSingleUnit_Bosses() =
{
	Menu_Start_MissionEditor("Bosses");

	Menu_Option_Text("Carrier Tank", PlaceEnemy_CarrierTank);
	Menu_Option_Text("Destroyer Tank", PlaceEnemy_DestroyerTank);
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}*/

/*void Draw_MissionEditor_EnemiesSingleUnits() =
{
	Menu_Start_MissionEditor("Enemies: Single Unit");
	
	Menu_CallSubMenu_Text("Infantry", Draw_MissionEditor_EnemiesSingleUnit_Infantry);
	Menu_CallSubMenu_Text("Turrets", Draw_MissionEditor_EnemiesSingleUnit_Turrets);
	Menu_CallSubMenu_Text("Bosses", Draw_MissionEditor_EnemiesSingleUnit_Bosses);	
	BR();
	Menu_Option_Text_Back("Back", CloseMenu);
	
	Menu_End();
}*/

void Draw_MissionEditor_Enemies() =
{
	Menu_Start_MissionEditor("Enemies", __FUNC__);
	
	DrawElement_OptionTitle("Turrets");
	
	Menu_Option_Text("Light Plasma", PlaceTurret_LightPlasma);
OPTION_EPISODE_MIN = 2;	
	Menu_Option_Text("Heavy Beam", PlaceTurret_HeavyBeam);
	Menu_Option_Text("Rocket", PlaceTurret_Rocket);
OPTION_EPISODE_MIN = false;
	Menu_Option_Text("Repair", PlaceTurret_Repair);		
	BR();	
	
	DrawElement_OptionTitle("Infantry");
	
	Menu_Option_Text("Light Tank", PlaceEnemy_LightTank);
	Menu_Option_Text("Medium Tank", PlaceEnemy_MediumTank);
OPTION_EPISODE_MIN = 2;
	Menu_Option_Text("Lightning Tank", PlaceEnemy_LightningTank);
OPTION_EPISODE_MIN = false;
	BR();	
	
	DrawElement_OptionTitle("Minibosses");
	
	Menu_Option_Text("Heavy Tank Proton", PlaceEnemy_HeavyTank_Proton);	
	Menu_Option_Text("Heavy Tank Minigun", PlaceEnemy_HeavyTank_Minigun);	
	BR();
	
	DrawElement_OptionTitle("Bosses");
	
OPTION_EPISODE_MIN = 2;
	Menu_Option_Text("Carrier Tank", PlaceEnemy_CarrierTank);
	Menu_Option_Text("Destroyer Tank", PlaceEnemy_DestroyerTank);
OPTION_EPISODE_MIN = false;
	BR();
	
	DrawElement_OptionTitle("Multiple Unit");
	
	Menu_Option_Text("Group Spawn", PlaceGroupSpawn);
OPTION_EPISODE_MIN = 2;
	Menu_Option_Text("Enemy Portal", PlacePortal);
OPTION_EPISODE_MIN = false;	
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void Draw_MissionEditor_Friendlies() =
{
	Menu_Start_MissionEditor("Friendlies", __FUNC__);
	
	DrawElement_OptionTitle("Infantry");
	
	Menu_Option_Text("F. Light Tank", PlaceAI_FriendlyLightTank);
	BR();	

	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void Draw_MissionEditor_Objects() =
{
	Menu_Start_MissionEditor("Utilities", __FUNC__);
	
	local string str_spawnpad, str_exitpad;
	str_spawnpad	= Translate("Spawn Pad");
	str_exitpad		= Translate("Exit Pad");
	skiptranslation = true;
	
	if(!GameMode_HasTeams(gamemode))
		Menu_Option_Text(str_spawnpad, PlaceSpawnPad);
	if(GameMode_CanSpawnEnemies(gamemode))
		Menu_Option_Text(str_exitpad, PlaceExitPad);
		
	skiptranslation = false;
	Menu_Option_Text("Force Field 1", PlaceForceField);
	Menu_Option_Text("Force Field 2", PlaceForceFieldT);
	Menu_Option_Text("Pressure Plate", PlacePressurePlate);
	Menu_Option_Text("Teleporter", PlaceTeleporter);
	Menu_Option_Text("Obelisk", PlaceObelisk_1);
	
OPTION_EPISODE_MIN = 2;
	Menu_Option_Text("Terminal", PlaceTerminal);
	Menu_Option_Text("Small Terminal", PlaceTerminal_Small);	
	Menu_Option_Text("Data Key", PlaceDataKey);
	Menu_Option_Text("Pylon", PlacePylon_1);	
	Menu_Option_Text("Relidium-3 Pump", PlaceGasPump);
	Menu_Option_Text("Refinery", PlaceRefinery);
	Menu_Option_Text("Evaporator", PlaceEvaporator);
	Menu_Option_Text("Corrupt Fusion Core", PlaceCorruptFusionCore);
	Menu_Option_Text("Fusion Core Rack", PlaceFusionCoreRack);	
	Menu_Option_Text("BBoss Building", PlaceBBoss);
	Menu_Option_Text("Small BBoss Building", PlaceBBoss_Small);	
OPTION_EPISODE_MIN = false;	
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void Draw_MissionEditor_Stones() =
{
	Menu_Start_MissionEditor("Stones", __FUNC__);
	
	Menu_Option_Text("Stone 1", PlaceStone_1);
	Menu_Option_Text("Stone 2", PlaceStone_2);
	Menu_Option_Text("Stone 3", PlaceStone_3);
	Menu_Option_Text("Stone 4", PlaceStone_4);
	Menu_Option_Text("Stone 1 big", PlaceStone_5);
	Menu_Option_Text("Stone 2 big", PlaceStone_6);
	Menu_Option_Text("Stone 3 big", PlaceStone_7);
	Menu_Option_Text("Stone 4 big", PlaceStone_8);
	Menu_Option_Text("Stone 1 small", PlaceStone_9);
	Menu_Option_Text("Stone 3 small", PlaceStone_10);
	Menu_Option_Text("Stone remains", PlaceStone_11);
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void Draw_MissionEditor_EnvCrystals() =
{
	Menu_Start_MissionEditor("Crystal Formations", __FUNC__);
	
	Menu_Option_Text("Blue Crystals", PlaceEnvCrystals_Blue);
	Menu_Option_Text("Green Crystals", PlaceEnvCrystals_Green);
	Menu_Option_Text("Purple Crystals", PlaceEnvCrystals_Purple);
	Menu_Option_Text("Red Crystals", PlaceEnvCrystals_Red);
	Menu_Option_Text("Turquoise Crystals", PlaceEnvCrystals_Turquoise);
	Menu_Option_Text("Yellow Crystals", PlaceEnvCrystals_Yellow);
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void Draw_MissionEditor_Stalagmites() =
{
	Menu_Start_MissionEditor("Stalagmites", __FUNC__);
	
	Menu_Option_Text("Stalagmites 1", PlaceStalagmites1);
	Menu_Option_Text("Stalagmites 2", PlaceStalagmites2);
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void Draw_MissionEditor_Volcanoes() =
{
	Menu_Start_MissionEditor("Volcanoes", __FUNC__);
	
	Menu_Option_Text("Volcano 1", PlaceVolcano1);
	Menu_Option_Text("Volcano 1 medium", PlaceVolcano1_medium);
	Menu_Option_Text("Volcano 1 small", PlaceVolcano1_small);
	Menu_Option_Text("Volcano 2", PlaceVolcano2);
	Menu_Option_Text("Volcano 2 medium", PlaceVolcano2_medium);
	Menu_Option_Text("Volcano 2 small", PlaceVolcano2_small);
	Menu_Option_Text("Volcano 3", PlaceVolcano3);
	Menu_Option_Text("Volcano 3 medium", PlaceVolcano3_medium);
	Menu_Option_Text("Volcano 3 small", PlaceVolcano3_small);
	Menu_Option_Text("Volcano 4", PlaceVolcano4);
	Menu_Option_Text("Volcano 4 medium", PlaceVolcano4_medium);
	Menu_Option_Text("Volcano 4 small", PlaceVolcano4_small);
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void Draw_MissionEditor_Roadblocks() =
{
	Menu_Start_MissionEditor("Roadblocks", __FUNC__);
	
	Menu_Option_Text("Roadblock 1", PlaceRoadblock1);
	Menu_Option_Text("Roadblock 1 dropped", PlaceRoadblock1_dropped);
	Menu_Option_Text("Roadblock 2", PlaceRoadblock2);
	Menu_Option_Text("Roadblock 2 dropped", PlaceRoadblock2_dropped);
	Menu_Option_Text("Roadblock 3", PlaceRoadblock3);
	Menu_Option_Text("Roadblock 4", PlaceRoadblock4);
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void Draw_MissionEditor_RockFormations() =
{
	Menu_Start_MissionEditor("Rock Formations", __FUNC__);
	
	Menu_Option_Text("Rock Formation 1", PlaceRockFormation1);
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void Draw_MissionEditor_Trees() =
{
	Menu_Start_MissionEditor("Trees", __FUNC__);
	
	Menu_Option_Text("Palm Tree 1", PlacePalmtree1);
	Menu_Option_Text("Palm Tree 2", PlacePalmtree2);
	Menu_Option_Text("Palm Tree 3", PlacePalmtree3);
	BR();	
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void Draw_MissionEditor_Grass() =
{
	Menu_Start_MissionEditor("Grass", __FUNC__);
	
OPTION_EPISODE_MIN = 2;	
	Menu_Option_Text("Grass Patch 1", PlaceGrass1);
	Menu_Option_Text("Grass Patch 2", PlaceGrass2);
	Menu_Option_Text("Grass Patch 3 (dry)", PlaceGrass3);
OPTION_EPISODE_MIN = false;	
	BR();	
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void Draw_MissionEditor_Plants() =
{
	Menu_Start_MissionEditor("Plants", __FUNC__);
	
	Menu_Option_Text("Plant 1 (with flowers)", PlacePlant1);
	Menu_Option_Text("Plant 1 (no flowers)", PlacePlant1_NoFlowers);
	Menu_Option_Text("Plant 2", PlacePlant2);
	Menu_Option_Text("Plant 3", PlacePlant3);
	Menu_Option_Text("Cactus 1", PlaceCactus1);
	Menu_Option_Text("Cactus 2", PlaceCactus2);
	Menu_Option_Text("Cactus 3", PlaceCactus3);
	Menu_Option_Text("Cactus 4", PlaceCactus4);	
	BR();	
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void Draw_MissionEditor_Equipment() =
{
	Menu_Start_MissionEditor("Equipment", __FUNC__);
	
	Menu_Option_Text("Tech. Barrel", PlaceBarrel_1);
	Menu_Option_Text("Barrel", PlaceBarrel_2);
	Menu_Option_Text("Barrel (dropped)", PlaceBarrel_3);
	Menu_Option_Text("Container 1 (brown)", PlaceContainer_1);
	Menu_Option_Text("Container 1 (blue)", PlaceContainer_1a);
	Menu_Option_Text("Container 2", PlaceContainer_2);
	Menu_Option_Text("Container 3", PlaceContainer_3);
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void Draw_MissionEditor_Structures() =
{
	Menu_Start_MissionEditor("Structures", __FUNC__);
	
	Menu_Option_Text("Incinerator", PlaceBuilding_1);
	Menu_Option_Text("Bunker", PlaceBuilding_2);	
	Menu_Option_Text("Hangar", PlaceBuilding_3);	
	Menu_Option_Text("Barracks", PlaceBuilding_4);	
	Menu_Option_Text("Cooling Tower", PlaceCoolingTower_1);	
	Menu_Option_Text("Cooling Twin Tower", PlaceCoolingTower_2);
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void Draw_MissionEditor_Vehicles() =
{
	Menu_Start_MissionEditor("Vehicles", __FUNC__);
	Menu_Option_Text("Dead Player", PlaceDPlayerTank);	
	BR();
	
	DrawElement_OptionTitle("Destroyed Enemy Tanks");	
	Menu_Option_Text("Dead Light Tank", PlaceDLightTank);
	Menu_Option_Text("Dead Medium Tank", PlaceDMediumTank);
	Menu_Option_Text("Dead Lightning Tank", PlaceDLightningTank);	
	Menu_Option_Text("Dead Heavy Tank", PlaceDHeavyTank);
OPTION_EPISODE_MIN = 2;
	Menu_Option_Text("Dead Carrier Tank", PlaceDCarrierTank);
	Menu_Option_Text("Dead Destroyer Tank", PlaceDDestroyerTank);
OPTION_EPISODE_MIN = false;
	BR();

	DrawElement_OptionTitle("Destroyed Turrets");		
	Menu_Option_Text("Dead Plasma Turret", PlaceDPlasmaTurret);
	Menu_Option_Text("Dead Rocket Turret", PlaceDRocketTurret);
	Menu_Option_Text("Dead Beam Turret", PlaceDBeamTurret);
	Menu_Option_Text("Dead Repair Turret", PlaceDRepairTurret);	
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void Draw_MissionEditor_Environment() =
{
	Menu_Start_MissionEditor("Environment", __FUNC__);
	
	Menu_CallSubMenu_Text("Trees", Draw_MissionEditor_Trees);
	Translate("Grass"); // hack to avoid having to edit translation files
//OPTION_EPISODE_MIN = 2;
//	Menu_CallSubMenu_Text("Grass", Draw_MissionEditor_Grass);
//OPTION_EPISODE_MIN = false;
	Menu_CallSubMenu_Text("Plants", Draw_MissionEditor_Plants);
	Menu_CallSubMenu_Text("Stones", Draw_MissionEditor_Stones);
	Menu_CallSubMenu_Text("Crystal Formations", Draw_MissionEditor_EnvCrystals);	
	Menu_CallSubMenu_Text("Stalagmites", Draw_MissionEditor_Stalagmites);
	Menu_CallSubMenu_Text("Volcanoes", Draw_MissionEditor_Volcanoes);
	Menu_CallSubMenu_Text("Vehicles", Draw_MissionEditor_Vehicles);
	Translate("Rubble"); // hack to avoid having to edit translation files
//	Menu_Option_Text("Rubble", SUB_Null);
	Menu_CallSubMenu_Text("Equipment", Draw_MissionEditor_Equipment);
	Menu_CallSubMenu_Text("Structures", Draw_MissionEditor_Structures);
	Menu_CallSubMenu_Text("Roadblocks", Draw_MissionEditor_Roadblocks);
	Menu_CallSubMenu_Text("Huge Rock Formations", Draw_MissionEditor_RockFormations);
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void Draw_MissionEditor_CTF() =
{
	Menu_Start_MissionEditor("CTF Objects", __FUNC__);

	Menu_Option_Text("Neutral Flag", PlaceFlag_Neutral);
	Menu_Option_Text("Red Flag", PlaceFlag_Red);
	Menu_Option_Text("Blue Flag", PlaceFlag_Blue);	
	BR();
	
	Menu_Option_Text("Red Spawn Pad", PlaceSpawnPad_Red);	
	Menu_Option_Text("Blue Spawn Pad", PlaceSpawnPad_Blue);	
	BR();
	
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

/*void Draw_MissionEditor_Entities() =
{
	local vector pos, fontsize;
	local string s;

	Menu_Start_MissionEditor("Entities");
	
	Menu_CallSubMenu_Text("Pickups", Draw_MissionEditor_Pickups);
	Menu_CallSubMenu_Text("Enemies", Draw_MissionEditor_Enemies);
	Menu_CallSubMenu_Text("Objects", Draw_MissionEditor_Objects);
	Menu_CallSubMenu_Text("Environment", Draw_MissionEditor_Environment);
	BR();
	Menu_Option_Text("Random Yaw", TogglePlacedEntRandomYaw);
	
	fontsize = '4 4 0';
	if(placedent_randomyaw)
		s = "ON";
	else
		s = "OFF";	
	
	pos = GetLastButtonPos();
	pos_x += (option_size_x - strlen(s)*fontsize_x)*0.5;
	pos_y += option_size_y - fontsize_y - 2;
	
	drawstring(pos, s, fontsize, option_fontcolor_highlight, option_fontalpha, option_fontflags);
	
	BR();
	Menu_Option_Text_Back("Back", CloseMenu);
	
	Menu_End();
}*/

/*void Draw_CommitAllConfirmation() =
{
	Menu_Start_ConfirmationMenu("Commit", '0 0 0');

	Menu_Text("Commit all entities?");
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Commit", CommitEntities, 0, 0, 0, 0, MBT_CONFIRM);
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();	
	
	Menu_End();
}*/

void Draw_SaveMissionConfirmation() =
{
	Menu_Start_ConfirmationMenu("Save", '0 0 0', __FUNC__);

	Menu_Text("Save mission?");
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Save", SaveEntities, 0, 0, 0, 0, MBT_CONFIRM);
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();
}

void AllowMissionSave() =
{
	if(!IsWaitingForServerResponse(WFSR_ENTITYSAVEALLASCHECK))
		return;

	CloseMenuBranch(2);
}

void SendSaveMissionAsCommand(entity listent, string cmdstr) =
{
	local string s;
	
	s = AppendToken("cmd", SEP_SPACE, cmdstr);
	s = AppendToken(s, SEP_SPACE, ftos(gamemode_new));
	s = AppendToken(s, SEP_SPACE, SEP_QUOTE);
	
	if(gamemode_new == GAMEMODE_CAMPAIGN)
		s = strcat(s, UnderscoreString(GetBufferString(listent.buf_list, 0)));

	s = AppendToken(s, SEP_QUOTE, SEP_SPACE);
	s = AppendToken(s, SEP_QUOTE, UnderscoreString(GetBufferString(listent.buf_list, 1)));
	s = AppendToken(s, SEP_QUOTE, "\n");

	localcmd(s);
} 

void OverwriteMissionConfirmation_ESCFunc() =	{	CloseMenuBranch(1);	}

void OverwriteMission() =
{
	SendSaveMissionAsCommand(active_menu.parentmenu.parentmenu, "entity_saveallas");
	CloseMenuBranch(2);
}

void Draw_OverwriteMissionConfirmation() =
{
	local string s;

	Menu_Start_ConfirmationMenu("Overwrite Mission?", '500 0 0', __FUNC__);
	
	local string str_exists;
	str_exists	= Translate("exists.");
	skiptranslation = true;
	
	if(gamemode_new == GAMEMODE_CAMPAIGN)
		s = strcat(GetBufferString(active_menu.parentmenu.parentmenu.buf_list, 0), " : ");
	s = strcat(s, GetBufferString(active_menu.parentmenu.parentmenu.buf_list, 1));
	s = strcat(s, SEP_SPACE, str_exists);
	
	Menu_Text(s);
	BR();
	skiptranslation = false;
	Menu_Text("Are you sure you want to overwrite it?");
	BR();BR();
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Save", OverwriteMission, 0, 0, 0, 0, MBT_CONFIRM);
	DrawElement_BottomButton("Cancel", currentmenu.ESCFunc, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();
}

void Call_OverwriteMissionConfirmation() =
{
	if(!IsWaitingForServerResponse(WFSR_ENTITYSAVEALLASCHECK))
		return;

	CloseMenu();
	SetCurrentMenu(Draw_OverwriteMissionConfirmation);
	currentmenu.ESCFunc = OverwriteMissionConfirmation_ESCFunc;
}

void SaveEntitiesAs() =
{
	Call_WaitingForServerMenu();
	waitingforserverresponse = WFSR_ENTITYSAVEALLASCHECK;
	
	SendSaveMissionAsCommand(active_menu.parentmenu, "entity_saveallas_check");
}

void Draw_SaveMissionAs_MissingCampaign() =
{
	Menu_Start_ConfirmationMenu("Missing Campaign", '250 0 0', __FUNC__);

	Menu_Text("You must choose a campaign.");

	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();			
	
	Menu_End();
}

void Draw_SaveMissionAs_MissingMission() =
{
	Menu_Start_ConfirmationMenu("Missing Mission", '300 0 0', __FUNC__);

	Menu_Text("You must enter a mission name.");

	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();
}

void Draw_SaveMissionAsConfirmation() =
{
	local string s_gamemode;

	Menu_Start_OptionMenu("Save Mission?", '300 0 0', __FUNC__);
	
	local string str_gamemode, str_campaign, str_mission;
	str_gamemode	= Translate("Game Mode:");
	str_campaign	= Translate("Campaign:");
	str_mission		= Translate("Mission:");
	skiptranslation = true;
	
	s_gamemode = TitleString(GetGameMode_String(gamemode_new, false));
	
	TempMenuSetting_body_fontcolor(option_fontcolor);
	Menu_AlignedText(str_gamemode, ALIGN_LEFT);
	RestoreMenuSetting_body_fontcolor();
	option_pos_y += body_fontsize_y;
	Menu_AlignedText(s_gamemode, ALIGN_LEFT);		
	option_pos_y += body_fontsize_y + 4;
	
	if(gamemode_new == GAMEMODE_CAMPAIGN)
	{
		TempMenuSetting_body_fontcolor(option_fontcolor);	
		Menu_AlignedText(str_campaign, ALIGN_LEFT);
		RestoreMenuSetting_body_fontcolor();	
		option_pos_y += body_fontsize_y;
		Menu_AlignedText(GetBufferString(active_menu.parentmenu.buf_list, 0), ALIGN_LEFT);	
		option_pos_y += body_fontsize_y + 4;
	}
	
	TempMenuSetting_body_fontcolor(option_fontcolor);	
	Menu_AlignedText(str_mission, ALIGN_LEFT);
	RestoreMenuSetting_body_fontcolor();	
	option_pos_y += body_fontsize_y;
	Menu_AlignedText(GetBufferString(active_menu.parentmenu.buf_list, 1), ALIGN_LEFT);		
	option_pos_y += body_fontsize_y + 4;
	BR();	
	
	option_size_x = 100;
	option_textalignment		= '0 0 0';
	body_alignment				= '0 0 0';	
	
	skiptranslation = false;
	BeginBottomButtons(2);
	DrawElement_BottomButton("Save", SaveEntitiesAs, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();			
	
	Menu_End();	
}

void Call_SaveMissionAsConfirmation() =
{
	if(gamemode_new == GAMEMODE_CAMPAIGN && !GetBufferString(active_menu.buf_list, 0))
		SetCurrentMenu(Draw_SaveMissionAs_MissingCampaign);
	else
	if(!GetBufferString(active_menu.buf_list, 1))
		SetCurrentMenu(Draw_SaveMissionAs_MissingMission);
	else
		SetCurrentMenu(Draw_SaveMissionAsConfirmation);
}

//void CampaignListESCFunc() =	{	CloseMenuBranch(1);		}

void SetNewCampaignName() =
{
	if(!IsWaitingForServerResponse(WFSR_CREATECAMPAIGNECHECK))
		return;

	SetBufferString(currentmenu.parentmenu.parentmenu.parentmenu.buf_list, 0, GetBufferString(currentmenu.parentmenu.buf_list, 0));
	CloseMenuBranch(2);
}

void SetNewCampaignName_CampaignExists() =
{
	local string filename;

	if(!IsWaitingForServerResponse(WFSR_CREATECAMPAIGNECHECK))
		return;
		
	CloseMenu();
	
	currentmenu.bodystring	= "CAMPAIGNEXISTS";
}

void SetNewCampaignName_Check() =
{
	if(InvalidInputString(0))
		return;

	Call_WaitingForServerMenu();
	waitingforserverresponse = WFSR_CREATECAMPAIGNECHECK;
		
	local string s;
	s = strcat("cmd createcampaign_check ", UnderscoreString(GetBufferString(active_menu.buf_list, 0)));
	s = strcat(s, "\n");
	localcmd(s);
}

void Draw_SetNewCampaignName() =
{
	local vector inputboxsize;
	local string s;
	
	Menu_Start_ConfirmationMenu("New Campaign", '300 0 0', __FUNC__);
	
	local string str_campaign;
	str_campaign	= Translate("Campaign:");
	skiptranslation = true;
	
	Menu_InputWarnings();
	
	s = strcat(str_campaign, SEP_SPACE);
	Menu_AlignedText(s, ALIGN_LEFT);
	inputboxsize_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - stringwidth(s, false, body_fontsize);//body_fontsize_x*10;
	Menu_Input_All(inputboxsize, string_null, ALIGN_RIGHT, 0, SetNewCampaignName_Check);	
	
	skiptranslation = false;
	BeginBottomButtons(2);
	DrawElement_BottomButton("Create", SetNewCampaignName_Check, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();		
	
	Menu_End();	
}

void Call_SetNewCampaignName() =
{
	SetCurrentMenu(Draw_SetNewCampaignName);
	active_input = 1;
}

void ChooseCampaign() =
{
	if(active_menu.parentmenu.parentmenu == menu_votemenu)
		RequestFromServer_MissionList_Campaign(active_menu.listitemstring);
	else
		SetBufferString(active_menu.parentmenu.buf_list, 0, active_menu.listitemstring);
	CloseMenu();
}

void ListOption_CampaignList(float count) =
{
	active_menu.listitemstring = TitleString(GetFilenameFromPath(GetBufferString(active_menu.buf_list, count), 2, true));
	Menu_Option_Text(active_menu.listitemstring, ChooseCampaign);
}

void Draw_CampaignList() =
{
	local float editing, numcampaigns, numlistoptions, count, windowwidth, listslots;
	
	Menu_Start_OptionMenu("Select a Campaign", '400 450 0', __FUNC__);

	local string str_nocampaignfiles, str_new, str_cancel;
	str_nocampaignfiles		= Translate("No campaign files found.");
	str_new					= Translate("New");
	str_cancel				= Translate("Cancel");
	skiptranslation = true;
	
	windowwidth = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - 10;
	listslots = 15;
	numcampaigns = GetBufferSize(active_menu.buf_list);
	
	if(!numcampaigns)
	{
		BR();
		Menu_Text(str_nocampaignfiles); BR();
	}
	else
		numlistoptions = Draw_ScollingList(numcampaigns, listslots, 0, windowwidth, listslots+1, listslots, SUB_Null, ListOption_CampaignList);

	BR();
	option_textalignment = '0 0 0';		
	
	if(active_menu.parentmenu.parentmenu != menu_votemenu)
		editing = true;
	
	BeginBottomButtons(1+editing);
	if(editing)
		DrawElement_BottomButton(str_new, Call_SetNewCampaignName, numlistoptions, 1, numlistoptions, 0, MBT_BASIC);	
	DrawElement_BottomButton(str_cancel, CloseMenu, numlistoptions, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();			

	skiptranslation = false;
	
	Menu_End();
}

void Call_CampaignList() =
{
	local string s;
	local float buf;
	
	buf = CreateBuffer();

	s = ReadString();
	while(s != "LIST_END")
	{
		AddBufferString(buf, s, 0);
		s = ReadString();
	}	
	
	if(!IsWaitingForServerResponse(WFSR_REQUESTLISTCAMPAIGNS))
	{
		DeleteBuffer(buf);
		return;
	}
	
	CloseMenu();
	
	SetCurrentMenu(Draw_CampaignList);	
	currentmenu.buf_list = buf;
	SortBuffer(currentmenu.buf_list, 99, FALSE);	
}

void RequestFromServer_CampaignList() =
{
	Call_WaitingForServerMenu();	
	waitingforserverresponse = WFSR_REQUESTLISTCAMPAIGNS;
	
	localcmd("cmd requestlist_campaigns\n");
}

void Roll_GameMode() =
{
	#ifdef COMPILE_GAMEPLAYOPTIONS_SINGLEPLAYER
		gamemode_new = Roll_Controls(gamemode_new, 1);
	#else
		gamemode_new = Roll_Controls(gamemode_new, 3);
	#endif
}

void SetMissionName() =
{
	if(InvalidInputString(0))
		return;

	SetBufferString(active_menu.parentmenu.buf_list, 1, GetBufferString(active_menu.buf_list, 0));
	CloseMenu();
}

void Draw_SetMissionName() =
{
	local vector inputboxsize;
	local string s;
	
	Menu_Start_ConfirmationMenu("Mission Name", '300 0 0', __FUNC__);

	local string str_mission;
	str_mission		= Translate("Mission:");
	skiptranslation = true;
	
	Menu_InputWarnings();
	
	s = strcat(str_mission, SEP_SPACE);
	Menu_AlignedText(s, ALIGN_LEFT);
	inputboxsize_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - stringwidth(s, false, body_fontsize);
	Menu_Input_Text(inputboxsize, GetBufferString(active_menu.parentmenu.buf_list, 1), ALIGN_RIGHT, 0, SetMissionName);	
	
	skiptranslation = false;
	BeginBottomButtons(2);
	DrawElement_BottomButton("Set", SetMissionName, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();			
	
	Menu_End();	
}

void Call_SetMissionName() =
{
	SetCurrentMenu(Draw_SetMissionName);
	active_input = 1;
}

void Draw_SaveMissionAs() =
{
	local string s_gamemode;

	Menu_Start_OptionMenu("Save As...", '400 0 0', __FUNC__);

	local string str_gamemode, str_campaign, str_mission;
	str_gamemode		= Translate("Game Mode");
	str_campaign		= Translate("Campaign:");
	str_mission			= Translate("Mission:");
	skiptranslation = true;		
	
	Menu_Roll_Text(str_gamemode, Roll_GameMode);

	s_gamemode = TitleString(GetGameMode_String(gamemode_new, false));	
		
	option_pos = GetLastLinePos();	
	option_pos_x += option_infospacing;
	Menu_AlignedText(s_gamemode, ALIGN_LEFT);
	option_pos_x -= option_infospacing;
	BR();	
	
	if(gamemode_new == GAMEMODE_CAMPAIGN)
	{
		Menu_Option_Text(str_campaign, RequestFromServer_CampaignList);	
		option_pos = GetLastLinePos();
		option_pos_x += option_infospacing;
		Menu_AlignedText(GetBufferString(active_menu.buf_list, 0), ALIGN_LEFT);
		option_pos_x -= option_infospacing;
	}
	
	BR();
	
	Menu_Option_Text(str_mission, Call_SetMissionName);	
	option_pos = GetLastLinePos();
	option_pos_x += option_infospacing;
	Menu_AlignedText(GetBufferString(active_menu.buf_list, 1), ALIGN_LEFT);
	option_pos_x -= option_infospacing;
	BR();BR();
	
	option_size_x = 100;
	option_textalignment = '0 0 0';
	
	skiptranslation = false;
	BeginBottomButtons(2);
	DrawElement_BottomButton("Save", Call_SaveMissionAsConfirmation, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();		

	Menu_End();		
}

void Call_SaveMissionAs() =
{
	SetCurrentMenu(Draw_SaveMissionAs);
/*	if(deathmatch)
		gamemode = 0;
	else
		gamemode = 1;*/
	gamemode_new = gamemode;
	currentmenu.buf_list = CreateBuffer();	
	SetBufferString(currentmenu.buf_list, 0, TitleString(campaign));
	SetBufferString(currentmenu.buf_list, 1, TitleString(mission));
}

void Call_SaveMission() =
{
	if((gamemode == GAMEMODE_CAMPAIGN && !campaign)
	|| !mission)
	{
		Call_SaveMissionAs();
		return;
	}	
	
	SetCurrentMenu(Draw_SaveMissionConfirmation);
}

void Draw_ReloadAllConfirmation() =
{
	Menu_Start_ConfirmationMenu("Reload Mission?", '0 0 0', __FUNC__);

	Menu_Text("Reload mission from saved file?");
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Reload", ReloadEntities, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();			
	
	Menu_End();
}

void Draw_DeleteAllConfirmation() =
{
	Menu_Start_ConfirmationMenu("Clear Objects?", '0 0 0', __FUNC__);

	Menu_Text("Are you sure you want to remove all objects?");
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Delete", DeleteEntities, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();		
	
	Menu_End();
}

void ExitEditor() =
{
	local float noneditormenucount;

	if(menu_death)
		noneditormenucount++;

	EscapeMenuBranch(menu_count-1-noneditormenucount);
//	RemoveMarker();
//	localcmd("cmd missioneditor\n");
}

/*void Draw_EditorExitConfirmation() =
{
	Menu_Start_ConfirmationMenu("Exit Mission Editor?", '300 0 0');
	Menu_Text("Uncommited changes will be lost!");
	BR();
	Menu_Option_Text_Confirm("Yes", ExitEditor);	
	Menu_Option_Text_Cancel("No", CloseMenu);
	Menu_End();
}*/

//void Call_EditorExitConfirmation() =	{	SetCurrentMenu(Draw_EditorExitConfirmation);	}

/*void Draw_MissionEditor_GameModeError_CantToggleInMultiplayer() =
{
	Menu_Start_ConfirmationMenu("", '400 0 0');
	Menu_Text("Cannot toggle game mode while server is active.");
	BR();
	Menu_Option_Text("Continue", CloseMenu);
	Menu_End();
}*/

/*void ToggleGameMode() =
{
	if(maxplayers > 1)
	{
		SetCurrentMenu(Draw_MissionEditor_GameModeError_CantToggleInMultiplayer);
		return;
	}
	
	mission_gamemode = !mission_gamemode;
}*/

void SetMissionBriefing() =
{
	local string s;
	s = strcat("cmd setmissionbriefing ", SEP_QUOTE);
	s = strcat(s, GetBufferString(active_menu.buf_list, 0));
	s = strcat(s, SEP_QUOTE);
	s = strcat(s, "\n");
	localcmd(s);
	CloseMenu();
}

void Draw_EditMissionBriefing() =
{
	local vector textblocksize;
	local string s;
	
	Menu_Start_OptionMenu("Mission Briefing", '400 0 0', __FUNC__);

	textblocksize_x = 400 - border_size_x*2 - body_margin_x*2;	
	textblocksize_y = 350;
	
	s = mission_briefing[currentlanguage];
	Menu_Input_All(textblocksize, s, ALIGN_LEFT, 0, SUB_Null);
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Set", SetMissionBriefing, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();		

	Menu_End();		
}

void Call_EditMissionBriefing() =
{
	SetCurrentMenu(Draw_EditMissionBriefing);
	active_input = active_textblock = 1;
}

void SetObjectiveData() =
{
	local entity e;
	local float count;
	local string s, filename;
	
	s = GetBufferString(active_menu.buf_list, 0);
	
	if(InvalidInputString(0))
		return;
	
	if(active_menu.listid == -1)
	{
		e = spawn();
		e.buf_contents = CreateBuffer();
		e.class = CLASS_OBJECT;
		e.objclass = OBJ_OBJECTIVE;
		e.entid = -1;
	}
	else
	for(e = list_objectivechain; count < active_menu.listid; e = e.objectivechain)
		count++;

	e.objectivetext = zonecpy(e.objectivetext, s);
	e.objectivepriority = active_menu.objectivepriority-1;
	CommitObject(e);
	CloseMenu();
}

void SetObjectivePriority_Primary() =	{	active_menu.objectivepriority = 1;	}
void SetObjectivePriority_Secondary() =	{	active_menu.objectivepriority = 2;	}

void DeleteObjective() =
{
	local entity e;
	local float count;
	
	for(e = list_objectivechain; count < active_menu.listid; e = e.objectivechain)
		count++;	

	DeleteObject(e);
	CloseMenu();
}

void Draw_EditObjective() =
{
	local vector inputboxsize;
	local string s, objectivestring;
	local entity e;
	local float count, bottombuttons, obj_priority;
	
	if(active_menu.listid == -1)
	{
//		s = "New Objective";
		if(!active_menu.objectivepriority)
			active_menu.objectivepriority = 1;
	}
	else
	{
//		s = "Edit Objective";
		for(e = list_objectivechain; count < active_menu.listid; e = e.objectivechain)
			count++;
		
		objectivestring = e.objectivetext[currentlanguage];
		
		if(!active_menu.objectivepriority)
			active_menu.objectivepriority = e.objectivepriority+1;
	}
	
	obj_priority = active_menu.objectivepriority-1;
	
	Menu_Start_OptionMenu("Objective", '400 275 0', __FUNC__);
	
	option_size_x = 168;
	
	Menu_InputWarnings();	
	
	DrawElement_OptionTitle("DESCRIPTION");		
//	s = "Objective: ";
	Menu_AlignedText("Objective:", ALIGN_LEFT);
	inputboxsize_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - stringwidth(s, false, body_fontsize);//body_fontsize_x*10;
	Menu_Input_All(inputboxsize, objectivestring, ALIGN_RIGHT, 0, SUB_Null);	
	BR();
	
	DrawElement_OptionTitle("PRIORITY");		
	
	option_size_selectionbox = option_size;
	option_size_selectionbox_x = option_sliderspacing+36;
	
	Menu_Option_Text("Primary", SetObjectivePriority_Primary);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, !obj_priority);
	BR();
	
	Menu_Option_Text("Secondary", SetObjectivePriority_Secondary);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, obj_priority);	
	
	option_size_selectionbox = '0 0 0';		
	
	if(active_menu.listid == -1)
		bottombuttons = 2;
	else
		bottombuttons = 3;
	
	BeginBottomButtons(bottombuttons);
	DrawElement_BottomButton("Accept", SetObjectiveData, 0, 0, 0, 0, MBT_CONFIRM);
	
	local string str_delete;
	str_delete	= Translate("Delete");
	skiptranslation = true;
	if(active_menu.listid != -1)
		DrawElement_BottomButton(str_delete, DeleteObjective, 0, 0, 0, 0, MBT_CONFIRM);	
	skiptranslation = false;
		
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();		
	
	Menu_End();	
}

void Call_EditObjective() =
{
	SetCurrentMenu(Draw_EditObjective);
	currentmenu.listid = active_menu.listid;
	active_input = 1;
}

void Call_CreateNewObjective() =
{
	active_menu.listid = -1;
	Call_EditObjective();
}

void AssignObjectToObjective() =
{
	local entity e;
	local float count;
	
	for(e = list_objectivechain; count < active_menu.listid; e = e.objectivechain)
		count++;	
	
	if(e.objectivepriority == 0)
	if(admin_editingent.owner.flags & FL_ITEM)
	{
	//	print("Cannot assign weapon pickups to primary objectives.\n");		// FIXME TRANSLATE
		return;
	}
	
	admin_editingent.owner.triggerobjectiveentid = e.entid;
	CommitObject(admin_editingent);
}

void UnassignObjectiveTrigger() =
{
	admin_editingent.owner.triggerobjectiveentid = 0;
	CommitObject(admin_editingent);
}

void ListOption_ObjectiveList(float count) =
{
	local entity e;
	local float ocount;
	local string s;
	local void() func;
	
	for(e = list_objectivechain; ocount < count; e = e.objectivechain)
		ocount++;
	
	active_menu.listid = count;
	s = e.objectivetext[currentlanguage];
	
	if(admin_editingent)
		func = AssignObjectToObjective;
	else
		func = Call_EditObjective;
	
	Menu_Option_Text(s, func);
}

void Draw_ObjectiveList() =
{
	local entity e;
	local float numobjectives, numlistoptions, count, windowwidth, listslots;
	local string s;
	
	Menu_Start_OptionMenu("Objectives", '400 450 0', __FUNC__);

	local string str_currenttrigger, str_noexistingobjectives, str_unassign, str_new, str_close;
	str_currenttrigger			= Translate("Current Trigger:");
	str_noexistingobjectives	= Translate("No existing objectives.");
	str_unassign				= Translate("Unassign");
	str_new						= Translate("New");
	str_close					= Translate("Close");
	
	skiptranslation = true;
	
	windowwidth = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - 10;
	
	for(e = list_objectivechain; e; e = e.objectivechain)
		numobjectives++;
	
	if(admin_editingent)
	{
		listslots = 12;
		for(e = list_objectivechain; e && e.entid != admin_editingent.owner.triggerobjectiveentid; e = e.objectivechain)
		{}
		s = strcat(str_currenttrigger, e.objectivetext);
		Menu_Text(s);
		BR();BR();
	}
	else
		listslots = 14;
		
	if(!numobjectives)
	{
		BR();
		Menu_Text(str_noexistingobjectives); BR();
	}
	else
		numlistoptions = Draw_ScollingList(numobjectives, listslots, 0, windowwidth, listslots+1, listslots, SUB_Null, ListOption_ObjectiveList);

	BR();
	option_textalignment = '0 0 0';		
	
	BeginBottomButtons(2);
	if(admin_editingent)
		DrawElement_BottomButton(str_unassign, UnassignObjectiveTrigger, numlistoptions, 1, numlistoptions, 0, MBT_BASIC);
	else
		DrawElement_BottomButton(str_new, Call_CreateNewObjective, numlistoptions, 1, numlistoptions, 0, MBT_BASIC);	
	DrawElement_BottomButton(str_close, CloseMenu, numlistoptions, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();			
	
	Menu_End();
}

void Call_EditObjectives() =
{
	SetCurrentMenu(Draw_ObjectiveList);	
	currentmenu.buf_list = CreateBuffer();
}

void SetMapTime() =
{
	local string cmd;

	maptime_total_new = stof(GetBufferString(active_menu.buf_list, 0))*60;
	maptime_total_new += stof(GetBufferString(active_menu.buf_list, 1));
	maptime_total_ismodified = true;

	cmd = strcat("cmd setmaptime ", ftos(maptime_total_new));
	cmd = strcat(cmd, "\n");
	localcmd(cmd);
		
	CloseMenu();
}

void Draw_MissionEditor_SetMapTime() =
{
	local float time_total, time_minutes, time_seconds, option_colstart;
	local vector input_size;
	
	if(maptime_total_ismodified)
		time_total = maptime_total_new;
	else
		time_total = maptime_total;

	Menu_Start_MissionEditor("Map Time", __FUNC__);
	Menu_Input_Time("Time:", time_total, SetMapTime);
	BR();
	
	Menu_Option_Text_Confirm("Confirm", SetMapTime);	
	Menu_Option_Text_Cancel("Cancel", CloseMenu);
	
	Menu_End();	
}

void RandomScaleSliderRules() =
{
	if(slider_current == 1)
		randomscale_min = GetSliderValue();	
	else
		randomscale_max = GetSliderValue();	

	if(randomscale_min > randomscale_max)
	if(slider_current == 1)
		randomscale_max = randomscale_min;
	else
		randomscale_min = randomscale_max;
}

void SetRandomScaleMin() =	{	randomscale_min = stof(GetBufferString(active_menu.buf_list, 0));	}
void SetRandomScaleMax() =	{	randomscale_max = stof(GetBufferString(active_menu.buf_list, 1));	}

string TranslateElement_ScaleInput(float translation) =
{
	local string s;
	
	switch(translation)
	{
		case 0:		s = Translate("Min Scale:");	break;
		case 1:		s = Translate("Max Scale:");			break;
	}
	
	return s;
}

void DrawElement_ScaleInput(string str_minscale, string str_maxscale) =
{
	SliderRules = RandomScaleSliderRules;
	
	TempMenuSetting_body_fontcolor(option_fontcolor);
	Menu_AlignedText(str_minscale, ALIGN_LEFT);
	RestoreMenuSetting_body_fontcolor();
	Menu_AlignedText(substring(ftos(randomscale_min), 0, 3), ALIGN_RIGHT);		
	BR();
	Menu_Slider_Simple(randomscale_min, "", 0.8, 1.2, 50, option_size_x);

	TempMenuSetting_body_fontcolor(option_fontcolor);
	Menu_AlignedText(str_maxscale, ALIGN_LEFT);
	RestoreMenuSetting_body_fontcolor();
	Menu_AlignedText(substring(ftos(randomscale_max), 0, 3), ALIGN_RIGHT);		
	BR();
	Menu_Slider_Simple(randomscale_max, "", 0.8, 1.2, 50, option_size_x);
	
	SliderRules = SUB_Null;
}

void Draw_AdminAccessDenied() =
{
	Menu_Start_ConfirmationMenu("Access Denied", '250 0 0', __FUNC__);

	Menu_Text("Invalid password.");

	BeginBottomButtons(1);
	DrawElement_BottomButton("Close", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();			
	
	Menu_End();
}

void AdminAccessGranted() =
{
	if(!IsWaitingForServerResponse(WFSR_REQUESTADMINACCESS))
		return;
	
//	if(!(menu_votemenu && active_menu.parentmenu == menu_votemenu))	
		CloseMenuBranch(1);
//	else
//		CloseMenu();	
}

void AdminAccessDenied() =
{
	if(!IsWaitingForServerResponse(WFSR_REQUESTADMINACCESS))
		return;

	CloseMenu();
	currentmenu.bodystring = "INVALIDPASSWORD";
}

void CheckServerPassword() =
{
	local string cmd, password;
	
	Call_WaitingForServerMenu();	
	waitingforserverresponse = WFSR_REQUESTADMINACCESS;	
	
	password = GetBufferString(active_menu.buf_list, 0);
	cmd = strcat("cmd grantadminaccess ", password); 
	
	if(!(menu_votemenu && active_menu.parentmenu == menu_votemenu))
		cmd = strcat(cmd, " starteditor");
		
	cmd = strcat(cmd, "\n");
	localcmd(cmd);
}

void RequestGuestEditorAccess() =
{
	localcmd("cmd requestguesteditoraccess\n");
	CloseMenu();
}

void Draw_GetServerPassword() =
{
	local vector input_size;
	local float buttons, showguestbutton;
	local string str_password, str_guest, str_continue, str_cancel;

	Menu_Start_ConfirmationMenu("Server Password", '300 0 0', __FUNC__);

	Menu_InputWarnings();
	
	str_password = 	Translate("Password:");
	str_guest = 	Translate("Guest");
	str_continue =	Translate("Continue");
	str_cancel =	Translate("Cancel");
	
	skiptranslation = true;

	Menu_AlignedText(str_password, ALIGN_LEFT);
	input_size_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - stringwidth(str_password, false, body_fontsize) - body_fontsize_x;
	Menu_Input_All(input_size, string_null, ALIGN_RIGHT, 0, CheckServerPassword);
	
	if((publicguesteditoraccess || player.hasguestaccess) && !(menu_votemenu && active_menu.parentmenu == menu_votemenu))
		showguestbutton = true;
		
	if(showguestbutton)
		buttons = 3;
	else
		buttons = 2;
	
	BeginBottomButtons(buttons);
	DrawElement_BottomButton(str_continue, CheckServerPassword, 0, 0, 0, 0, MBT_CONFIRM);	
	if(showguestbutton)
		DrawElement_BottomButton(str_guest, RequestGuestEditorAccess, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton(str_cancel, CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		

	skiptranslation = false;	
	Menu_End();	
}

void Call_GetServerPassword() =
{
	SetCurrentMenu(Draw_GetServerPassword);
	active_input = 1;
}

void Toggle_PlayerEditorAccess() =
{
	local entity e;
	local float count;
	local string s;
	
	count = 0;
	for(e = list_playerchain; count < active_menu.listid; e = e.playerchain)
		count++;
		
//	if(e == player)
//		return;
		
	s = strcat("cmd toggleeditoraccess ", ftos(e.id), "\n");
	localcmd(s);
}

void ListOption_AdminPlayerList_Local(float count) =
{
	local entity e;
	local float ocount;
	local string s;
	local vector osize;
	
	local string filename, str_admin;
	skiptranslation = false;
	filename = __FUNC__;
	buf_localizeadminplayerlist = InitializeNonstandardTranslations(buf_localizeadminplayerlist, filename, false);
	str_admin		= Localize("admin", buf_localizeadminplayerlist);
	WriteNonstandardTranslations(buf_localizeadminplayerlist, filename, false, false);
	skiptranslation = true;
	
	if(LOCALIZE_GENERATING)
		return;	
	
	for(e = list_playerchain; ocount < count; e = e.playerchain)
		ocount++;
	
	active_menu.listid = count;
	s = e.netname;//e.objectivetext[currentlanguage];

	if(e.hasadminaccess)
		s = strcat(s, " (", str_admin, ")");
	
	osize = option_size;
	
	option_size_x = option_size_x - 20 - 36;
	
	option_size_selectionbox = osize;
	
	if(e.hasadminaccess || publicguesteditoraccess)
	{
		Menu_Text(s);
		CompensateForSpaceInList();
	}
	else
	{
		Menu_Option_Text(s, Toggle_PlayerEditorAccess);	
		option_pos = GetLastLinePos();
	}

	if(!e.hasadminaccess)
		DrawElement_CheckBox(option_pos, option_size_x + 20, e.hasguestaccess || publicguesteditoraccess);	
	BR();	
	
	option_size = osize;
}

void ListOption_AdminPlayerList(float count) =
{
	if(LOCALIZE_GENERATING)
		return;
		
	ListOption_AdminPlayerList_Local(count);
}

void Draw_AdminPlayerList() =
{
	local float numplayers, numlistoptions, windowwidth;
	local entity e;
	local vector opos;
//	local vector option_pos_start, backbuttonpos;
//	local string listitem;
	
	Menu_Start_OptionMenu("Players", '600 500 0', __FUNC__);

	local string str_playselectedtrack;

	windowwidth = 300;
	
	opos = option_pos;
	
	option_pos_x += windowwidth - 36;
	Menu_Text("Editor Access");
	BR();
	
	option_pos_x = opos_x;
	
//	option_size_x = 300;
	
//	option_pos_start = option_pos;

	for(e = list_playerchain; e; e = e.playerchain)
		numplayers++;
		
//	if(numtracks > 0)
//		lastoptnum = 16;
		
//	if(numtracks > 0)
			numlistoptions = Draw_ScollingList(numplayers, 10, 0, windowwidth, 10, 10, SUB_Null, ListOption_AdminPlayerList);
//	else
//		option_pos_y += 10*(option_size_y+option_spacing);
		
	BR();

	option_textalignment = '0 0 0';

/*	backbuttonpos = option_pos;
	buttonwidth = 150;
	
	body_fontsize = option_fontsize;

	option_pos = option_pos_start;	
	option_pos_x += windowwidth + 20;	
	
	TempMenuSetting_body_fontcolor(option_fontcolor);
	Menu_Text("Current Mission Track:");
	RestoreMenuSetting_body_fontcolor();
	option_pos_y += body_fontsize_y + option_spacing;	
	skiptranslation = true;
	Menu_Text(mission_track);
	skiptranslation = false;
	option_pos_y += body_fontsize_y + option_spacing;			
	
	str_playselectedtrack	= Translate("Play Selected Track");
	
	skiptranslation = true;
	if(numtracks > 0)
	{
		if(!active_menu.user_current_selection)
			active_menu.user_current_selection = 1;
	
		firstoptnum = 1;
	
		option_pos_x = option_pos_start_x;
		option_pos_x += windowwidth + (active_menu.menusize_x - windowwidth - border_size_x - body_margin_x - buttonwidth)*0.5 ;	
		BR();

		HorizontalListButton(0, buttonwidth, str_playselectedtrack, MusicTrackList_PlayTrack, 1, 0, 1, 0, MBT_BASIC);		
	}	
	else
	{
		firstoptnum = 0;
		numlistoptions = 0;
	}

	skiptranslation = false;
	
	option_pos = backbuttonpos;
	*/
	BeginBottomButtons(1);
//	DrawElement_BottomButton("Confirm", SetMusicTrack, numlistoptions, firstoptnum, 0, 0, MBT_CANCEL);	
	DrawElement_BottomButton("Close", CloseMenu, numlistoptions, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();			
	
	Menu_End();
}

void ToggleLockMission() =
{
	local string s;
	
	s = "cmd mission_lock ";

	if(mission_locked)
		s = strcat(s, "0");
	else
		s = strcat(s, "1");
		
	localcmd(s);
}

void Draw_EditorOptions() =
{
	Menu_Start_OptionMenu("Editor Options", '400 450 0', __FUNC__);

	local string str_playerpermissions, str_lockmission, str_close;
	str_playerpermissions		= Translate("Player Permissions");
	str_lockmission				= Translate("Lock Mission");
	str_close					= Translate("Close");
	
	skiptranslation = true;

	Menu_CallSubMenu_Text(str_playerpermissions, Draw_AdminPlayerList);
	Menu_Option_CheckBox(str_lockmission, ToggleLockMission, mission_locked);	
	
	BeginBottomButtons(1);
	DrawElement_BottomButton(str_close, CloseMenu, 0, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();			
	
	Menu_End();
}

void LightEditor() =	{	localcmd("lightseditor\n");	}

void Draw_LightEditorConfirmation() =
{
	local vector input_size;
	local string s;

	Menu_Start_ConfirmationMenu("LIGHT EDITOR", '300 0 0', __FUNC__);

	s = Translate("You will lose all unsaved information if you continue. Please save your mission first to avoid losing data.");
	
	active_menu.buf_textblock = DrawTextBlock(active_menu.buf_textblock, option_pos, -1, '320 100 0', s, body_fontsize, body_fontcolor, body_fontalpha, body_fontflags);		
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Continue", LightEditor, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();	
}

void Draw_MissionEditor() =
{
	local string s;
	local float time_total, time_minutes, time_seconds, option_pos_start, windowheight;
	local vector scrollboxsize;
	
	Menu_Start_MissionEditor("Mission Editor", __FUNC__);

	local string str_campaign, str_enemies, str_friendlies, str_ctfobjects, str_hidepathing, str_showpathing, str_newpath, str_disablerandomyaw, str_enablerandomyaw, str_disablerandomscale, str_enablerandomscale, str_minscale, str_maxscale, str_editoroptions, str_mapsettings, str_lighting;
	
	scrollboxsize_x = option_size_x - scrollbar_width;//150 - border_size_x*2 - body_margin_y*2;
	scrollboxsize_y = vid_size_y - title_size_y - border_size_y*2 - body_margin_y*2;
	
	if(active_menu.scrollboxmeasurement == 2)
	{
		scrollbar_incrementsize = option_size_y + option_spacing;
		option_pos_y = BeginScrollingWindow(option_pos, scrollboxsize, 0, 0);
		option_size_x -= scrollbar_width + option_spacing;
	}

	option_pos_start = option_pos_y;	

	DrawElement_OptionTitle("Mission Info");		
	
	s = TitleString(GetGameMode_String(gamemode, false));
	
	TempMenuSetting_body_fontcolor(option_fontcolor);
	Menu_AlignedText("Game Mode:", ALIGN_LEFT);
	RestoreMenuSetting_body_fontcolor();
	option_pos_y += body_fontsize_y;
	skiptranslation = true;
	Menu_AlignedText(s, ALIGN_LEFT);		
	skiptranslation = false;
	option_pos_y += body_fontsize_y + 4;
	
	str_campaign	= Translate("Campaign:");
	skiptranslation = true;
	
	if(gamemode == GAMEMODE_CAMPAIGN)
	{
		TempMenuSetting_body_fontcolor(option_fontcolor);	
		Menu_AlignedText(str_campaign, ALIGN_LEFT);
		RestoreMenuSetting_body_fontcolor();	
		option_pos_y += body_fontsize_y;
		Menu_AlignedText(TitleString(campaign), ALIGN_LEFT);	
		option_pos_y += body_fontsize_y + 4;
	}
	
	skiptranslation = false;
	TempMenuSetting_body_fontcolor(option_fontcolor);	
	Menu_AlignedText("Mission:", ALIGN_LEFT);
	RestoreMenuSetting_body_fontcolor();	
	option_pos_y += body_fontsize_y;
	skiptranslation = true;
	Menu_AlignedText(TitleString(mission), ALIGN_LEFT);		
	option_pos_y += body_fontsize_y + 4;
	BR();
	
	skiptranslation = false;
	DrawElement_OptionTitle("Objects");	
	
	str_enemies		= Translate("Enemies");
	str_friendlies	= Translate("Friendlies");
	str_ctfobjects	= Translate("CTF Objects");
	skiptranslation = true;
	if(GameMode_CanSpawnEnemies(gamemode))
	{
		Menu_CallSubMenu_Text(str_enemies, Draw_MissionEditor_Enemies);
OPTION_EPISODE_MIN = 2;
		Menu_CallSubMenu_Text(str_friendlies, Draw_MissionEditor_Friendlies);
OPTION_EPISODE_MIN = false;			
	}
		
OPTION_EPISODE_MIN = 2;
	if(gamemode == GAMEMODE_CTF)
		Menu_CallSubMenu_Text(str_ctfobjects, Draw_MissionEditor_CTF);
OPTION_EPISODE_MIN = false;	
		
	skiptranslation = false;	
	Menu_CallSubMenu_Text("Utilities", Draw_MissionEditor_Objects);
	Menu_CallSubMenu_Text("Pickups", Draw_MissionEditor_Pickups);	
	Menu_CallSubMenu_Text("Environment", Draw_MissionEditor_Environment);
	Menu_CallSubMenu_Text("Effects", Draw_MissionEditor_Effects);	
	Menu_Option_Text("Trigger Relay", PlaceTriggerRelay);
	BR();

	DrawElement_OptionTitle("Navigation");		
	
	str_hidepathing		= Translate("Hide Pathing");
	str_newpath			= Translate("New Path");
	str_showpathing		= Translate("Show Pathing");
	skiptranslation = true;
	if(editingpaths)
	{
		Menu_Option_Text(str_hidepathing, Toggle_MissionEditor_Pathing);
		Menu_Option_Text(str_newpath, CreateNewPath);
	}
	else
		Menu_Option_Text(str_showpathing, Toggle_MissionEditor_Pathing);

	skiptranslation = false;
	BR();
	
	DrawElement_OptionTitle("Mission Settings");		
	
	Menu_Option_Text("Briefing", Call_EditMissionBriefing);
	
	Menu_Option_Text("Objectives", Call_EditObjectives);

	if(maptime_total_ismodified)
		time_total = maptime_total_new;
	else
		time_total = maptime_total;

	time_minutes = floor(time_total/60);
	time_seconds = time_total - time_minutes*60;
	
	s = strcat(ftos(time_minutes), ":");
	s = strcat(s, TimeString_Seconds(time_seconds));
	
	skiptranslation = true;
	Menu_AlignedText(s, ALIGN_RIGHT);
	skiptranslation = false;

	TempMenuSetting_body_alignment_horizontal(-1);
	TempMenuSetting_option_size_width(60);
	
	Menu_CallSubMenu_Text("Timer", Draw_MissionEditor_SetMapTime);	
	
	RestoreMenuSetting_body_alignment_horizontal();
	RestoreMenuSetting_option_size_width();
	
	Menu_Option_Text("Music Track", Call_MusicTrackList);
	
//	Menu_CallSubMenu_Text("Commit Changes", Draw_CommitAllConfirmation);	
//	Menu_Input_Text('50 0 0', ftos(99), ALIGN_RIGHT, SUB_Null);
	BR();
	
	str_mapsettings		= Translate("Map Settings");
	str_lighting		= Translate("Lighting");	
	skiptranslation = true;	
	
	if(maxplayers <= 1)
	{
		DrawElement_OptionTitle(str_mapsettings);		
		
OPTION_EPISODE_MIN = 2;
		Menu_CallSubMenu_Text(str_lighting, Draw_LightEditorConfirmation);
OPTION_EPISODE_MIN = false;
		BR();
	}
	
	skiptranslation = false;
	
	DrawElement_OptionTitle("Options");			

	str_disablerandomyaw	= Translate("Disable Random Yaw");
	str_enablerandomyaw		= Translate("Enable Random Yaw");
	str_disablerandomscale	= Translate("Disable Random Scale");
	str_enablerandomscale	= Translate("Enable Random Scale");
	str_editoroptions		= Translate("Admin Options");	
	skiptranslation = true;
	if(placedent_randomyaw)
		Menu_Option_Text(str_disablerandomyaw, TogglePlacedEntRandomYaw);
	else
		Menu_Option_Text(str_enablerandomyaw, TogglePlacedEntRandomYaw);

	str_minscale = TranslateElement_ScaleInput(0);
	str_maxscale = TranslateElement_ScaleInput(1);
		
/*	if(placedent_randomscale)
	{
		Menu_Option_Text(str_disablerandomscale, TogglePlacedEntRandomScale);
		DrawElement_ScaleInput(str_minscale, str_maxscale);	
	}
	else
		Menu_Option_Text(str_enablerandomscale, TogglePlacedEntRandomScale);*/
		
	if(player.hasadminaccess)
		Menu_CallSubMenu_Text(str_editoroptions, Draw_EditorOptions);	
//		Menu_CallSubMenu_Text(str_editoroptions, Draw_AdminPlayerList);	
		
	BR();
	skiptranslation = false;	
	
	local string str_servercommands, str_savemission, str_savemissionas, str_reloadmission, str_clearall;
	
	str_servercommands	= Translate("Server Commands");
	str_savemission		= Translate("Save Mission");
	str_savemissionas	= Translate("Save As...");
	str_reloadmission	= Translate("Reload Mission");
	str_clearall		= Translate("Clear All");
	
	skiptranslation = true;
	
	if(player.hasadminaccess)
	{
		DrawElement_OptionTitle(str_servercommands);	
//	Menu_CallSubMenu_Text("Commit Changes", Draw_CommitAllConfirmation);
		Menu_Option_Text(str_savemission, Call_SaveMission);//Draw_SaveMissionConfirmation);
		Menu_Option_Text(str_savemissionas, Call_SaveMissionAs);
		Menu_CallSubMenu_Text(str_reloadmission, Draw_ReloadAllConfirmation);
		Menu_CallSubMenu_Text(str_clearall, Draw_DeleteAllConfirmation);
	}
//	BR();	
//	Menu_CallSubMenu_Text("Exit Editor", Draw_EditorExitConfirmation);	
	
	skiptranslation = false;
	
		windowheight = option_pos_y - option_pos_start;

		if(active_menu.scrollboxmeasurement == 2)
			EndScrollingWindow(windowheight, 0, 0);		
		
		if(windowheight > scrollboxsize_y)
		{
			if(!active_menu.scrollboxmeasurement)
				active_menu.scrollboxmeasurement = 2;
		}
		else
		{
			active_menu.scrollboxmeasurement = 0;
			ResetScrollingWindow();
		}
	
	Menu_End();	
	
/*	if(active_menu == currentmenu)
	if(cl_button == KEY_ESC)
	{
	//	cl_button = 0;	// CL_BUTTONTEST
		SetCurrentMenu(Draw_EditorExitConfirmation);
	}*/
}
