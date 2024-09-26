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
void SH_MenuControls() =	{}
void SH_PreMenuControls() =	{}

void UpdateBindMap() =
{
//	ClearAllInputValues();

	if(adminmode)
	{
		if(currentmenu.drawinglist)
		{
		//	print("bm 0\n");
			setbindmaps('0 0 0');
			}
		else
		{
		//	print("bm 2\n");
			setbindmaps('2 0 0');
			}
	}
	else
	{
	//	print("bm 1\n");
		setbindmaps('1 0 0');
		}
}

float ServerKeys(float key) =
{
	local float overridemenu, ctrlid, bindmap, count;

	if(active_vkb)
	if(GameControl(CTRL_ESCAPE, 0))
	{
		if(key != K_ESCAPE && keynumtostring(key) != "X360_BACK")
			return false;
		else
		if(currentmenu.ESCFunc == ESCFunc_AllowESCMenu)
		{
			ClearInput();
			return true;
		}
	}
	
	if(active_input || active_textblock)
		return false;

	if(GameControl(CTRL_VOTEYES, 0))	{	localcmd("cmd vote_yes\n");		return false;	}
	else		
	if(GameControl(CTRL_VOTENO, 0))		{	localcmd("cmd vote_no\n");		return false;	}
	else		
	if(GameControl(CTRL_TALK, 0))		{	localcmd("messagemode\n");		return false;	}
	else
	if(GameControl(CTRL_TALK_TEAM, 0))	{	localcmd("messagemode2\n");		return false;	}		
		
	if(currentmenu)
	{
		if(!GameControl(CTRL_ESCAPE, 0))
			return false;

		if(currentmenu.ESCFunc != ESCFunc_AllowESCMenu)
			return false;
	}
	
	return true;
}

/*float ButtonClick(float button, float CLICKTYPE) =
{
	if(CLICKTYPE == CLICK_HOLD)
	if(cl_buttondown[button])
	if(!clicktime)
		return TRUE;
	else
		return FALSE;
		
	local float currentbutton;
	currentbutton = cl_button;

	if(CLICKTYPE == CLICK_SINGLE)
	if(cl_button < 0)
		currentbutton = -currentbutton;

	if(clicktime && clicktime < time)
	{
		lastbuttonclick = 0;
		clicktime = 0;
	}
	else
	if(currentbutton == button)
	{
		if(lastbuttonclick == button)
		{
			lastbuttonclick = 0;
			clicktime = 0;
			return TRUE;
		}
	
		lastbuttonclick = cl_button;
		if(CLICKTYPE == CLICK_DOUBLE)
			clicktime = time + 0.3;
		else
			clicktime = time + 0.2;
	}
	
	return FALSE;
}*/

float InterfacingWithGUI() =
{
//	if(admin_editingent && !updatingentyaw)
//		return true;
	if(currentmenu.menu_style & STYLE_PRIORITY)
		return true;

	if(CURSOROVERMENU)
		return true;
//	if(IsAssignedFunction(pulldown_mainfunc))
//		return true;

	return false;
}



//void ClearColormodY() = {	self.colormod_y = 0;	}

/*void EntitySelection(entity e) =
{
	if(e.alpha)
	if(e.alpha != 1)
		return;

	if(hover_ent != admin_editingent)
	if(e != hover_ent || CURSOROVERMENU)
	if(!IsAssignedFunction(pulldown_mainfunc))
	if(hover_ent != world)
	{
		DeselectEntity(hover_ent);
		hover_ent = world;			
	}

	if(!CURSOROVERMENU)
	if(e != world)
	if(menubar_openmenu)
	if(!mouseoverpulldownmenu)
		Clear_PullDownMenu();
	
	if(InterfacingWithGUI())
		return;
	
	if(e != hover_ent)
	if(e != world)
	{
		hover_ent = e;
		SelectEntity(hover_ent);
	}*/
	
/*	if(e.class == CLASS_CELL)
	{
		local float count, connection_id;
		local entity connection;
		for(count = 0; count < 4; count++)
		{
			connection_id = e.(cellconnection_id[count]);
			if(connection_id)
			{
				connection = findfloat(world, id, connection_id);
				if(!connection)
					print("bad connection id\n");
				else
				{
					if(connection.colormod_y != 5)
						connection.colormod_y = 5;

					connection.think = ClearColormodY;
					connection.nextthink = time+0.1;
				}
			}
		}
	}*/
	
/*	if(e != world)
	{
		if(ButtonClick(K_MOUSE1, CLICK_SINGLE))
		{
			if(linkingportal)
			{
				if(e == selectedlinkobject)
					print("Can't link to self\n");
				else
				if(e.objclass == CLASS_TELEPORTER)
					Portal_ChooseDestinationConfirm();
				else
					print("Not a portal.\n");
	//	}		
		
	//	if(ButtonClick(K_MOUSE2, CLICK_SINGLE))
	//	{
			}
			else
			{
				if(IsAssignedFunction(e.PullDownMenuFunc))
				if(!admin_editingent)
				{
				//	Toggle_PullDown(e.PullDownMenuFunc, false, e, 0, 0);
					admin_editingent = e;
					SetCurrentMenu(e.PullDownMenuFunc);
					currentmenu.CloseMenuFunc = CloseMenu_AdminMenu_Object;
				}
					
				if(!currentmenu)
					ClearPortalLinkingData();
			}
		}
	}
}*/

vector GetPlacementPosition(entity e, vector start, vector end) =
{
	local vector e_min, e_max, pos;
	local float count;
	
	e_min = e.mins;
	e_max = e.maxs;

	traceline(start, end, TRUE, self);
	
	if(trace_fraction < 1)
	{
		pos = trace_endpos;
		pos_z -= e.mins_z;
		
		while((trace_fraction == 1 && count < 125) || !count)
		{
			count++;
			pos = pos + normalize(start-pos)*8;
			tracebox(pos, e_min, e_max, pos + normalize(pos-start)*16, 4, self);
		}
		
		if(count == 125)
			pos = e.origin;
	}
	else
		pos = e.origin;
	
	tracebox(pos, e_min, e_max, trace_endpos + '0 0 -1000', 4, e);
	
	return trace_endpos;
}

void ClearMarkerPlacementValues() =
{
	defaultemittereffectname = freezone(defaultemittereffectname);
	defaultambientsoundname = freezone(defaultambientsoundname);	
}

void RemoveMarker() =
{
	if(!marker)
		return;

	badmarkerplacement = false;
	MarkerPlacedFunc = SUB_Null;
	PostMarkerPlacedFunc = SUB_Null;
	
	if(admin_editingent.prevpathpoint)
		admin_editingent.prevpathpoint.temppathconnection = world;
	if(connectingpathfrom)
		connectingpathfrom.temppathconnection = world;
	connectingpathfrom = world;
	
	SH_RemoveEnt(marker);
	marker = world;
}

void RestrictMarkerPlacement(entity e, entity trace_e, vector planes, float len) =
{
	local float nearflat;
	
	if(e.objclass == OBJ_PARTICLEEMITTER
	|| e.objclass == OBJ_AMBIENTSOUND)
		return;
	
	trace_plane_normal = planes;
//	print(vtos(planes));print("\n");
	if(trace_plane_normal_x > -0.99999)
	if(trace_plane_normal_x < 0.00001)
	if(trace_plane_normal_y > -0.99999)
	if(trace_plane_normal_y < 0.00001)
	if(trace_plane_normal_z > 0.99999)
	if(trace_plane_normal_z < 1.00001)	
		nearflat = true;

//	if(e.objclass == OBJ_PATH)
//	if(trace_ent.objclass == OBJ_PATH)
//	{
//		print(ftos(trace_ent.objclass)); print(" trace ent objclass!!!!!!!!!!!!!!\n");
//	}
		
	if((InterfacingWithGUI() || nearflat != true /*|| trace_e.class != CLASS_CONTROLENT*/ || len > 1 || (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOSTEPS) || trace_fraction == 1)
	&& !(e.objclass == OBJ_PATH && trace_e.objclass == OBJ_PATH))
	{
/*		if(InterfacingWithGUI())
			print("GUI\n");
		if(nearflat != true)
			print("!nearflat\n");
		if(!trace_e && len > 1)
		{
			print(ftos(len));print(" : len\n");}
		if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOSTEPS)
			print("nosteps\n");
		if(trace_fraction == 1)	
			print("trace_fraction == 1\n");*/
	
		if(!badmarkerplacement)
		{
			badmarkerplacement = true;
			AddColorMod(e, '1 0 0');
		}
		return;
	}
	else
	if(badmarkerplacement)
	{
		badmarkerplacement = false;
		SubtractColorMod(e, '1 0 0');
	}
}

void UpdateMarker(vector start, vector end, vector planes) =
{
	local entity e;
	local vector m_mins, m_maxs, firsttraceend;
	local float restrict;
	
	if(!marker)
		return;

	EntAngleControls(marker);

	if(GameControl(CTRL_EDITORBUTTON2, -1))
	{
		MissionEditorPlacingEntityESCFunc();
		return;
	}

	if(marker.objclass == OBJ_NPC)
	{
		m_mins = marker.mins;
		m_maxs = marker.maxs;
	}
	else
	{
		m_mins = '-16 -16 0';
		m_maxs = '16 16 32';
	}
	
	marker.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP | DPCONTENTS_MONSTERCLIP | Q3SURFACEFLAG_NOSTEPS;
	tracebox(start, m_mins, m_maxs, end, 4, marker);
//	marker.dphitcontentsmask = 0;
	
	e = trace_ent;
	
	if(!e)
	{
		tracebox(start, m_mins, m_maxs, end, 0, movingent);
		e = trace_ent;
	}	
	
	firsttraceend = trace_endpos;	
	
	traceline(trace_endpos, trace_endpos + '0 0 -10000', 4, marker);	
	marker.dphitcontentsmask = 0;		
	
	RestrictMarkerPlacement(marker, e, trace_plane_normal, vlen(trace_endpos - firsttraceend));
	
	setorigin(marker, firsttraceend);
}

void Draw_LimitedVersion_EntCount() =
{
	Menu_Start_ConfirmationMenu("Max Object Limit!", '0 0 0', __FUNC__);
	option_size_y = body_fontsize_y;
	
	Menu_Text("You have reached the limit of 200 objects.");
	BR();
	BR();
	Menu_Text("Purchase Steel Storm: Burning Retribution to accesss");
	BR();
	Menu_Text("Sand Storm's nearly unlimited object capacity.");
	BR();
//	Menu_Text("but it will not be available until Episode II.");
//	BR();
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Close", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();
}

void PlaceMarkerAtLocation() =
{
//	print("badmarkerplacement: ");print(ftos(badmarkerplacement));print("\n");
//	print("marker: ");print(ftos(marker.objclass));print("\n");

	if(!marker || badmarkerplacement)
		return;
		
	local entity e;
	local float minversion, totalobjects;
	
	minversion = 1.5;
	if(EPISODE < minversion)
	{
		for(e = list_controlentchain; e; e = e.controlentchain)
			totalobjects += 1;
		if(totalobjects >= 200)
		{
			SetCurrentMenu(Draw_LimitedVersion_EntCount);
			return;
		}
	}		
		
	marker.entid = GetNewEntID();	
		
	if(marker.objclass == OBJ_PATH)
	if(hover_ent.objclass == OBJ_PATH)
	{
		local float oldid;
		oldid = admin_editingent.pathgroupid;
	
		pathfunctions = PATHFUNC_CONNECT;
		marker.nextpathpoint = hover_ent;
		marker.prevpathpoint = connectingpathfrom;
		
	/*	if(PostMarkerPlacedFunc == SetPathSplit_Next)
		{
			if(!hover_ent.nextpathpoint)
			{
				ReversedLinkToHoverEntPath();
				SetNewPathGroupIDForSeveredPath(admin_editingent, false);
				admin_editingent.nextpathpoint = world;
				TransferAIPathIDFromMissingPath(oldid, admin_editingent.pathgroupid);
			}
		}
		else
			LinkToHoverEntPath();*/
			

		CommitObject(marker);	
			
		RemoveMarker();
		CloseMenu();
		return;
	}
		
	placedent = marker;
	
	if(placedent.objclass == OBJ_NPC)
		placedent.solid = SOLID_BBOX;
	else
		placedent.solid = 4;
	
	if(IsAssignedFunction(MarkerPlacedFunc))
	{
		MarkerPlacedFunc();
		MarkerPlacedFunc = SUB_Null;
	}
	
	marker.class = CLASS_CONTROLENT;
	ControlEntChain_Add(marker);
	marker = world;
	CloseMenu();

	if(IsAssignedFunction(PostMarkerPlacedFunc))
		PostMarkerPlacedFunc();

	CommitObject(placedent);		

	placedent = world;
}

void MarkerControls() =
{
//	if(cl_button == K_MOUSE1)
	if(GameControl(CTRL_EDITORBUTTON1, 0))
		PlaceMarkerAtLocation();
//	else
//	if(cl_button == -K_MOUSE2)
//		PostMarkerPlacedFunc = SUB_Null;
}

void SelectEntity(entity e) =	{	AddColorMod(e, '1 1 2');	}// e.colormod += '0 0 1';	}
void DeselectEntity(entity e) =	{	SubtractColorMod(e, '1 1 2');	}//e.colormod += '0 0 -1';	}

void HoverEntSelection(entity e) =
{
	if(InterfacingWithGUI())
		return;
	
//	local entity cursorpath;
	local float allowcursorenttrace, linkrules_allow;
	
/*	if(marker.objclass == CLASS_PATH)
		cursorpath = marker;
	else
	if(movingent.objclass == CLASS_PATH)
		cursorpath = movingent;
	
	if(cursorpath)
	if(!e ||
	(  e.objclass == CLASS_PATH
	&& e.prevpathpoint != cursorpath
	&& e.nextpathpoint != cursorpath
	&& cursorpath.prevpathpoint != e
	&& cursorpath.nextpathpoint != e
	&& e.temppathconnection != cursorpath))
		allowcursorenttrace = true;*/

//	if(marker)
//	if(!allowpathtrace)
//		return;	
		
	if(e != hover_ent)
	{
		if(hover_ent)
	//	if((!(assigningaipatrolpath && hover_ent.objclass != CLASS_PATH)
	//		&& !(linkingportal && e.objclass != CLASS_TELEPORTER))
	//	|| !e)
		{		
			SubtractColorMod(hover_ent, '2 2 2');
			hover_ent = world;
		}

	//	if(!e)
	//		hover_ent = e;
	//	else
	
		if(AllowPathConnection(e))
			allowcursorenttrace = true;	
	
		if(linkingobj)
			linkrules_allow = LinkRules(e);
	
		if(e)
		if(!((movingent || marker) && !allowcursorenttrace))
	//	if(!(assigningaipatrolpath && e.objclass != CLASS_PATH))
	//	if(!(linkingportal && e.objclass != CLASS_TELEPORTER))
	//	if(!(linkingforcefield && e.objclass != CLASS_PRESSUREPLATE))
		if(!(linkingobj && !linkrules_allow))
		{
			AddColorMod(e, '2 2 2');
			hover_ent = e;
		}
	}
	
/*	if(!e)
	{
		hover_ent = e;
		return;
	}
	
	if(( assigningaipatrolpath)
//	if(trace_ent)
	if(e.objclass != CLASS_PATH)
		return;
	
	if(linkingportal)
//	if(trace_ent)
	if(e.objclass != CLASS_TELEPORTER)
		return;	
	
	if(!(movingent && !allowpathtrace))// || !trace_ent)
		hover_ent = e;	*/
}

/*float CursorDrag(float DRAGSTATE, float MBUTTON) =
{
	if(cl_button == MBUTTON)
	{
		mousedrag_start = mousepos;
		dragstate = DRAG_START;
	}
	else
	if(cl_buttondown[MBUTTON] && dragstate)
	{
		if(vlen(mousepos - mousedrag_start) > 5)
			dragstate = DRAG_MOVE;
		else
			dragstate = DRAG_STILL;
	}
	else
	if(!cl_buttondown[MBUTTON])
		dragstate = 0;
			
	if(dragstate == DRAGSTATE)
		return TRUE;
	else
		return FALSE;
}*/

float DragState(float MBUTTON) =
{
	if(dragbutton)
	if(dragbutton != MBUTTON)
		return false;

	local vector diff;	
		
	if(GameControl(MBUTTON, 0))
	{
		mousedrag_start = mousepos;
		dragbutton = MBUTTON;
	}
	else
	if(cl_buttondown[MBUTTON] && !dragstate)
	{
		diff = mousepos - mousedrag_start;
		if(diff*diff > 5*5)
			dragstate = true;
	}
	else
	if(dragstate)	
	if(!cl_buttondown[MBUTTON])
	{
		dragbutton = 0;
		mousedrag_start = '0 0 0';
		dragstate = false;
	}

	return dragstate;
}


void Mouse() =
{
	if(DRAWMOUSE)
	{
		local vector lastmousepos;

		lastmousepos = mousepos;
		mousepos = getmousepos();
			
		if(mousepos != lastmousepos)
			arrowkeymovement = FALSE;	

		drawpic(mousepos + '-1 -1 0', "gfx/gui/cursor.tga", '14 19 0', '1 1 1', 1, 0);
			
		if(adminmode)
		{
			local vector org, start, end;
			local float movementtype;
			org = mousepos;//getmousepos();
			start = unproject(org);
			org_z = start_z - player.origin_z - admincamera_ofs_z - editorzoom;//500;

			start = unproject(org);
			end = unproject(org + '0 0 10000');		

		//	if((marker && marker.unstackable) || (admin_editingent && admin_editingent.unstackable)) 
		//		movementtype = 1;
		//	else
		//		movementtype = 4;
			
			traceline(start, end, 4, world);
			
		
			
	//		if((marker && marker.allowheightadjustment) || (admin_editingent && admin_editingent.allowheightadjustment))
	//			trace_endpos_z += currentplacementheight;
			
	//		if(trace_ent.permanent)
	//			trace_ent = world;
		//	if(!trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOSTEPS)
			if(!InterfacingWithGUI())
			{
				HoverEntSelection(trace_ent);
				ObjectMouseControls(trace_ent);	
				MoveEntity(start, end, trace_plane_normal);
				UpdateMarker(start, end, trace_plane_normal);		
				MarkerControls();
			}
				
			ObjectKeyControls();
			
//			if(CursorDrag(DRAG_MOVE, K_MOUSE2))
//			if(cl_buttondown[K_MOUSE2])
			if(DragState(CTRL_MENUBUTTON2))
			{
				DRAWMOUSE_FORCEHIDE = true;
				setwantsmousemove(false);
				DRAWMOUSE = false;
			}
		}
		else
		{
			if(hover_ent)
			{
				SubtractColorMod(hover_ent, '2 2 2');
				hover_ent = world;
			}
		}
	}
	else
	if(adminmode)
	if(dragstate)
	if(!DragState(CTRL_MENUBUTTON2))
	{
			//	dragstate = DRAG_END;
		DRAWMOUSE_FORCEHIDE = false;
		setwantsmousemove(true);
		DRAWMOUSE = true;		
	}
}