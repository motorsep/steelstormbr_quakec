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
void ClearAdminEditValues() =
{
	admin_editingent = world;
	menu_missioneditor = world;
}

void CloseAdminMenu() =
{
//	CloseWindow();
	ClearAdminEditValues();
}

/*void CloseAdminInputMenu() =
{
	CloseInputMenu();
	ClearAdminEditValues();
}*/

/*void WipeClass() =
{
	local entity e, nexte;
	local float CLASS;
	CLASS = ReadByte();
	
	e = findchainfloat(class, CLASS);
	while(e)
	{
		nexte = e.chain;
		if(!e.flags & FL_SHARED)
		if(e != marker)
			SH_RemoveEnt(e);
		e = nexte;
	}
}*/

/*void ClaimEditingRights() =
{
	if(!hover_ent.owner.isshared)
		hover_ent.allowediting = !hover_ent.allowediting;
	else
	{
		hover_ent.allowediting = false;
		local string cmd;
		cmd = strcat("cmd toggleeditingrights ", ftos(hover_ent.owner.id));
		cmd = strcat(cmd, "\n");
		localcmd(cmd);
	}
}*/

void GrantEditingRights() =
{
	local float e_id;
	local entity e;
	
	e_id = ReadShort();
	e = findfloat(world, id, e_id);
	
	if(e)
		e.allowediting = !e.allowediting;
	else
		dprint("Invalid entity.\n");
}

void SetAdminEditingEnt(entity e) =
{
	if(e == admin_editingent)
		return;
	
	if(admin_editingent)	
		CloseMenu();

	admin_editingent = e;
	
	if(e)
	{
		if(e.owner.objclass == OBJ_PATH)
			editingpaths = true;
			
		SelectEntity(e);
		SetCurrentMenu(Draw_MissionEditorEntityOptions);
		currentmenu.CloseMenuFunc = DeselectAdminEditingent;
	}
}

void CancelEntityMove() =
{
	setorigin(movingent, movingent.oldorigin);
	movingent.angles = movingent.oldangles;

	if(badmarkerplacement)
	{
//		movingent.colormod += '0 1 1';
		SubtractColorMod(movingent, '1 0 0');
		badmarkerplacement = false;
	}
	
	movingent.solid = 5;
	movingent = world;		
	MarkerPlacedFunc = SUB_Null;	
	
	CloseMenu();	
}

void PlaceMovingEntAtLocation() =
{
	if(badmarkerplacement)	
		return;
		
	if(IsAssignedFunction(MarkerPlacedFunc))
		MarkerPlacedFunc();

	movingent.solid = 5;

	if(movingent.objclass == OBJ_PATH)
	{
		if(hover_ent.objclass == OBJ_PATH
		&& ( (movingent.prevpathpoint && !movingent.nextpathpoint)
		  || (movingent.nextpathpoint && !movingent.prevpathpoint && !hover_ent.nextpathpoint)))
		{
			PathChain_Remove(movingent);
		
			if(movingent.prevpathpoint) // is end of path
			{
			//	connectingpathfrom = movingent.prevpathpoint;
			//	LinkToHoverEntPath();
				movingent.nextpathpoint = hover_ent;
			}
			else // is begenning of path
			{
			//	ReversedLinkToHoverEntPath();	
				movingent.prevpathpoint = hover_ent;
			}
		
			pathfunctions = PATHFUNC_CONNECT;
		
			if(movingent.isshared)
			{
			//	movingent.pathgroupid = hover_ent.pathgroupid;
			//	DeletedPathChain_Add(movingent);
				movingent.markedfordeletion = true;
				movingent.drawmask = false;
			//	movingent.alpha = 0.5;
				setorigin(movingent, movingent.oldorigin);
			}
			else
				SH_RemoveEnt(movingent);

			ClearPointer_Entfield(nextpathpoint, movingent);
			ClearPointer_Entfield(prevpathpoint, movingent);
	//		UpdateDeletedPathIDs(movingent.pathgroupid, hover_ent.pathgroupid);
			admin_editingent = hover_ent;
		}
		else
		{
			SetPathModelForOrientation(movingent);	
			SetPathModelForOrientationLead(movingent);	
		}
	}
	
	CommitObject(movingent);
	
	movingent = world;
	MarkerPlacedFunc = SUB_Null;
//	cl_button = 0; // Don't 
	CloseMenu();
}

void Draw_MissionEditorMovingEntity() =
{
	Menu_Start_MissionEditor("Moving Entity", __FUNC__);
	
	Menu_Option_Text("Place", PlaceMovingEntAtLocation);	
	Menu_Option_Text_Cancel("Cancel", CancelEntityMove);
	
	Menu_End();	
}

void Init_MoveEntity(entity e) =
{
	movingent = e;
	oldmousepos = mousepos;
	movingent.oldorigin = movingent.origin;
	movingent.oldangles = movingent.angles;
	movingent.solid = 0;	
	
	
	
	SetCurrentMenu(Draw_MissionEditorMovingEntity);
	currentmenu.ESCFunc = CancelEntityMove;
}

void MoveEntity(vector start, vector end, vector planes) =//vector start, vector end) =
{
	local entity e;
	local vector m_mins, m_maxs, firsttraceend;	
	local float restrict;

	if(!movingent)
	{
		if(GameControl(CTRL_EDITORBUTTON2, -1))
		if(!marker)
		if(hover_ent)
		if(!hover_ent.owner.cantbemoved)
		{
			SetAdminEditingEnt(hover_ent);			
			Init_MoveEntity(hover_ent);
		}
	
		return;	
	}

	if(movingent.objclass == OBJ_NPC)
	{
		m_mins = movingent.mins;
		m_maxs = movingent.maxs;
	}
	else
	{
		m_mins = '-16 -16 0';
		m_maxs = '16 16 32';
	}		

	movingent.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP | DPCONTENTS_MONSTERCLIP | Q3SURFACEFLAG_NOSTEPS;
	tracebox(start, m_mins, m_maxs, end, 4, movingent);
//	movingent.dphitcontentsmask = 0;	

		
	e = trace_ent;
	
	if(!e)
	{
//		movingent.dphitcontentsmask = 0;
		tracebox(start, m_mins, m_maxs, end, 0, movingent);
		e = trace_ent;
	}

	firsttraceend = trace_endpos;
	
//	traceline(trace_endpos, trace_endpos + '0 0 -10000', 4, movingent);
//	}
		
	traceline(trace_endpos, trace_endpos + '0 0 -10000', 4, movingent);	
	movingent.dphitcontentsmask = 0;	

//		trace_ent = e;

	RestrictMarkerPlacement(movingent, e, trace_plane_normal, vlen(trace_endpos - firsttraceend));	
	
	setorigin(movingent, firsttraceend);		
	
//	if(cl_button == -K_MOUSE2
	if(GameControl(CTRL_EDITORBUTTON2, -1)
//	|| cl_button == K_ESCAPE
	|| (GameControl(CTRL_EDITORBUTTON1, -1) && movingent.objclass == OBJ_PATH && hover_ent.nextpathpoint == movingent))
	{
		CancelEntityMove();
		return;
	}		
		

//	if(mousepos != oldmousepos)
//	if(cl_button == -K_MOUSE1)
	if(GameControl(CTRL_EDITORBUTTON1, -1))
		PlaceMovingEntAtLocation();
}

float HoverEntOldOrgDifference() =
{
	if(hover_ent.oldorigin)
	if(hover_ent.oldorigin != hover_ent.origin)
		return true;
		
	return false;
}

void UndoHoverEntMove() =
{
	setorigin(hover_ent, hover_ent.oldorigin);
//	UpdateWaypointToServer(hover_ent);	
}

void MoveHoverEnt() = 	{	Init_MoveEntity(hover_ent);	}

void MoveAdminEnt() = 	{	Init_MoveEntity(admin_editingent);	}

void DeleteObjectFromServer(entity e) =
{
	local string cmd;
	
	cmd = strcat("cmd remove_ent ", ftos(e.owner.id));
	cmd = strcat(cmd, "\n");
	localcmd(cmd);
}

/*void CommitObject() =
{
	if(admin_editingent.markedfordeletion)
		DeleteObjectFromServer(admin_editingent);
	else
		Commit_Entity();
	
	if(!admin_editingent.owner.id)
		SH_RemoveEnt(admin_editingent);
//	active_menu.CloseMenuFunc();
	CloseMenu();
}*/

void RevertEntity() =
{
	local string cmd;
	
	cmd = strcat("cmd revert_ent ", ftos(admin_editingent.owner.id));
	cmd = strcat(cmd, "\n");
	localcmd(cmd);
	
	active_menu.CloseMenuFunc();
}

void Admin_RemoveEnt() =
{
	if(admin_editingent.owner.id)
		DeleteObjectFromServer(admin_editingent);
	else
		SH_RemoveEnt(admin_editingent);
		
	admin_editingent = world;
	CloseMenu();
}

/*void Menu_ConfirmCommitEntity() =
{	DrawConfirmationMenu("Are you sure you want to commit this entity?\n", CommitEntity);	}

void ConfirmCommitEntity() =
{
	admin_editingent = hover_ent;
	SetCurrentWindow('220 107.7 0', Menu_ConfirmCommitEntity, CloseAdminMenu, MF_CLOSEABLE | MF_CONFIRMATION | MF_ADMIN);
}

void Menu_ConfirmRevertEntity() =
{	DrawConfirmationMenu("Are you sure you want to revert this entity?\n", RevertEntity);	}

void ConfirmRevertEntity() =
{
	admin_editingent = hover_ent;
	SetCurrentWindow('220 107.7 0', Menu_ConfirmRevertEntity, CloseAdminMenu, MF_CLOSEABLE | MF_CONFIRMATION | MF_ADMIN);
}

void Menu_ConfirmDeleteEntity() =
{	DrawConfirmationMenu("Are you sure you want to delete this entity?\n", Admin_RemoveEnt);	}

void ConfirmDeleteEntity() =
{
	admin_editingent = hover_ent;
	SetCurrentWindow('220 107.7 0', Menu_ConfirmDeleteEntity, CloseAdminMenu, MF_CLOSEABLE | MF_CONFIRMATION | MF_ADMIN);
}

void PullDown_EntityOptions() =
{
	pulldown_option[0] = "Commit";
	pulldown_func[0] = ConfirmCommitEntity;

	pulldown_option[1] = "Revert";
	pulldown_func[1] = ConfirmRevertEntity;	
	CheckPullDownAvailability(1, hover_ent.owner.id);
	
	pulldown_option[2] = "Delete";
	pulldown_func[2] = ConfirmDeleteEntity;
}

void UpdateYawToCursor() =
{
	if(!updatingentyaw)
		return;

	if(!DRAWMOUSE)
		return;

	local vector org, start, end, ang;
	org = getmousepos();
	start = unproject(org);
	end = unproject(org + '0 0 10000');
	traceline(start, end, 1, NULL_Ent);	
	
	ang = vectoangles(trace_endpos - admin_editingent.origin);
	admin_editingent.angles_y = ang_y;
	
	if(cl_button)
	if(InterfacingWithGUI() || cl_button == K_MOUSE2)
	{
		admin_editingent.angles = oldangles;
		ClearAdminEditValues();
		updatingentyaw = false;
	}
	else
	if(cl_button == K_MOUSE1)
	{
		ClearAdminEditValues();
		updatingentyaw = false;
	}
}

void AdjustEntYaw() =
{
	admin_editingent = hover_ent;
	admin_EditingFunc = UpdateYawToCursor;
	oldangles = hover_ent.angles;
	updatingentyaw = true;
}

void MovePulldownEnt() =
{
//	MarkerPlacedFunc = UpdateMovingEntWaypointToServer;
	Init_MoveEntity(pulldown_ent);
}

void SV_ToggleNavigationCells() =	{	localcmd("cmd viewnavigationcells\n");	}
*/
/*void Set_PullDown_Admin_Navigation() =
{
	pulldown_option[0] = "Display Navigation Cells";
	pulldown_func[0] = SV_ToggleNavigationCells;
	MarkPullDown(0, viewingnavigationcells);*/
	
/*	pulldown_option[0] = "Edit Waypoints";
	pulldown_func[0] = SV_ToggleWaypointEditingMode;
	MarkPullDown(0, editingwaypoints);
	
	pulldown_option[1] = "Place Waypoints";
	pulldown_func[1] = PlaceWaypoints;
	CheckPullDownAvailability(1, editingwaypoints);
	
	pulldown_option[2] = "Links";
	pulldown_sub[2] = Set_Pulldown_WaypointLinks;
	
	pulldown_option[3] = "Save Waypoints";
	pulldown_func[3] = ConfirmSaveWaypoints;
	CheckPullDownAvailability(3, editingwaypoints);
	
	pulldown_option[4] = "Reload Waypoints";
	pulldown_func[4] = ConfirmReloadWaypoints;
	CheckPullDownAvailability(4, editingwaypoints);

	pulldown_option[5] = "Clear Waypoints";
	pulldown_func[5] = ConfirmDeleteWaypoints;
	CheckPullDownAvailability(5, editingwaypoints);	*/
//}

/*void Set_PullDown_Admin_Entities();
void Set_PullDown_Admin_Navigation();
void PullDown_Admin_Entities() =		{	Toggle_PullDown(Set_PullDown_Admin_Entities, true, world, 0, 1);	}
void PullDown_Admin_Navigation() =		{	Toggle_PullDown(Set_PullDown_Admin_Navigation, true, world, 0, 2);	}
void PullDown_Admin_PlayerOptions() =	{	Toggle_PullDown(Set_PullDown_Admin_PlayerOptions, true, world, 0, 3);	}

void Hud_AdminTools() =
{
	menubar_option_name[0] = "Entities";
	menubar_option_func[0] = PullDown_Admin_Entities;	
	menubar_option_name[1] = "Navigation";
	menubar_option_func[1] = PullDown_Admin_Navigation;		
	menubar_option_name[2] = "Temp_Player_Options";
	menubar_option_func[2] = PullDown_Admin_PlayerOptions;		
	Draw_MenuBar('0 0 0');
}*/

void ToggleAdminMode() =
{
	local entity e, nexte;

	adminmode = !adminmode;

	if(!adminmode)
	{
	//	print("ADMIN MODE OFF - CSQC\n");
		
		maptime_total_new = 0;
		maptime_total_ismodified = false;
		
		e = list_controlentchain;//findchainfloat(class, CLASS_CONTROLENT);
		while(e)
		{
			nexte = e.controlentchain;
			if(e.owner == e)
				e.drawmask = false;
			else
				SH_RemoveEnt(e);

			e = nexte;
		}
	
		e = findchainfloat(class, CLASS_OBJECT);
		while(e)
		{
		//	e.alpha = 0;
			UnsetAdminModeAlpha(e);
		
			if(e.onlydrawforadmins)
				e.drawmask = false;
		
			// hhm
			if(e.id)
			{
				e.allowediting = false;
				
			/*	if(e.origin_base != '0 0 0')
				{
					setorigin(e, e.origin_base);
					e.angles = e.angles_base;
				}*/
			}
			else
				e.drawmask = false;	// hides new uncommited ents
			
			e = e.chain;
		}
	
		ExitEditor();
		localcmd("menu_cmd mission_editor_off\n");//;r_novis 0\n");
	
//		setwantsmousemove(false);
//		DRAWMOUSE = false;	
	
//		if(pulldown_attached)
//		if(!pulldown_parent)
//			Clear_PullDownMenu();	
	
		
		for(e = findchainflags(mflags, MF_ADMIN); e; e = e.chain)
			e.CloseMenuFunc();
			
		ClearAdminEditValues();
		
		if(GameMode_HasTeams(gamemode))
		if(player.team < 1)
			Call_ChooseTeam();
	}
	else
	{
	//	print("ADMIN MODE ON - CSQC\n");
	
		e = findchainfloat(class, CLASS_OBJECT);
		while(e)
		{
		//	SetAdminModeAlpha(e);

			if(e.onlydrawforadmins || !e.id)
				e.drawmask = MASK_NORMAL;		
			else
				e.drawmask = false;
				
			e = e.chain;
		}
			
		for(e = list_controlentchain; e; e = e.controlentchain)
			e.drawmask = true;
			
		if(menu_chooseteam)
		{
			currentmenu = menu_chooseteam;
			CloseMenu();
		}
			
	//	if(cl_menutype)	
	//	if(!currentmenu)
		if(!menu_missioneditor)
		{
		//	if(currentmenu)
		//		CloseMenu();
			SetCurrentMenu(Draw_MissionEditor);	
			currentmenu.ESCFunc = ESCFunc_AllowESCMenu;//Call_EditorExitConfirmation;
			menu_missioneditor = currentmenu;
		}
			
		localcmd("menu_cmd mission_editor_on\n");//;r_novis 1\n");	
			
//		setwantsmousemove(true);
//		DRAWMOUSE = true;
	}
}

void AdminModeActive() =	{	adminmodeactive = ReadByte();	}

/*void DrawWaypointConnections() =
{
	local float count;
	local entity wp, connection;
	local vector start, end;

	if(hover_ent.class == CLASS_WAYPOINT || showallwplinks)
	if(editingwaypoints)
	{
		if(showallwplinks)
		{
			wp = findchainfloat(class, CLASS_WAYPOINT);
			while(wp)
			{
				start = wp.origin;
				start = project(start);
				
				for(count = 0; wp.wp_connection[count]; count++)
				{
					connection = findfloat(world, wpid, wp.wp_connection[count]);
					end = connection.origin;
					end = project(end);
					drawline(5, start+WAYPOINT_OFS, end+WAYPOINT_OFS, COLOR_RED, 1, 0);
				}				
				wp = wp.chain;
			}
		}
		else
		{
			wp = hover_ent;
			start = wp.origin;
			start = project(start);
			
			for(count = 0; wp.wp_connection[count]; count++)
			{
				connection = findfloat(world, wpid, wp.wp_connection[count]);
				end = connection.origin;
				end = project(end);
				drawline(5, start+WAYPOINT_OFS, end+WAYPOINT_OFS, COLOR_RED, 1, 0);
			}
		}
	}
}*/

void GameJoinGranted() =
{
	if(!IsWaitingForServerResponse(WFSR_REQUESTGAMEJOIN))
		return;
	
	CloseMenuBranch(1);
	localcmd("menu_cmd requestingjoinpassword 0");
}

void GameJoinDenied() =
{
	if(!IsWaitingForServerResponse(WFSR_REQUESTGAMEJOIN))
		return;

	CloseMenu();
	currentmenu.bodystring = "INVALIDPASSWORD";
	localcmd("menu_cmd requestingjoinpassword 0");
}

string CheckJoinPassword(string password) =
{
	local string cmd;
	
	Call_WaitingForServerMenu();	
	waitingforserverresponse = WFSR_REQUESTGAMEJOIN;	
	
	cmd = strcat("cmd joinpassword ", password, "\n");
//	localcmd(cmd);
	
	cvar_set("join_password", password);
	
	return cmd;
}

void SubmitJoinPassword() =
{
	local string password;
	password = GetBufferString(active_menu.buf_list, 0);
	localcmd(CheckJoinPassword(password));
}

void Draw_GetJoinPassword() =
{
	local vector input_size;
	local string s, str_password, str_timeleft, str_continue;
	local float timeleft;
	
	timeleft = getstatf(100);
	timeleft = timeleft - time;
	
	Menu_Start_ConfirmationMenu("Join Password", '300 0 0', __FUNC__);

	Menu_InputWarnings();
	
	str_password = 	Translate("Password:");
	str_timeleft =	Translate("Time Left:");
	str_continue =	Translate("Continue");
	
	skiptranslation = true;

	Menu_AlignedText(str_password, ALIGN_LEFT);
	input_size_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - stringwidth(str_password, false, body_fontsize) - body_fontsize_x;
	Menu_Input_All(input_size, cvar_string("join_password"), ALIGN_RIGHT, 0, SubmitJoinPassword);
	BR();
	
	s = strcat(str_timeleft, SEP_SPACE, ftos(ceil(timeleft)));
	Menu_Text(s);

	BeginBottomButtons(1);
	DrawElement_BottomButton(str_continue, SubmitJoinPassword, 0, 0, 0, 0, MBT_CONFIRM);	
	EndBottomButtons();		

	skiptranslation = false;	
	Menu_End();	

}

void Call_GetJoinPassword() =
{
	local string pass, s;

	s = "menu_cmd requestingjoinpassword 1\n";
	
	SetCurrentMenu(Draw_GetJoinPassword);
	currentmenu.ESCFunc = ESCFunc_AllowESCMenu;	
	active_input = 1;
	
	pass = cvar_string("join_password");
	
	if(strlen(pass))
		s = strcat(s, CheckJoinPassword(pass));
		
	localcmd(s);	
}