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
void DrawModelFlags() =
{
	if(self.modelflags & MF_ROTATE)
		self.angles_y = self.angles_y + BindAngle(0, 90*frametime, 360);
}

void R_AddLights() =
{
	local entity e;
	local vector org, ang;
	local float llev;
	
	for(e = list_dlightchain; e; e = e.dlightchain)
	{
		if(e.tag_entity.isdead)
			continue;
	
		if(adminmode)
		if(e.tag_entity.class != CLASS_CONTROLENT)
		if(e.tag_entity != marker)
			continue;
			
		if(e.tag_entity)
		{		
			if(e.tag_entity.controlent)
				org = gettaginfo(e.tag_entity.controlent, e.tag_index);
			else
				org = gettaginfo(e.tag_entity, e.tag_index);

			ang = vectoangles(e.origin);
			ang_x = ang_x*-1;
			ang_y += e.tag_entity.angles_y;
			ang_x += e.tag_entity.angles_x;
			ang_z += e.tag_entity.angles_z;
			makevectors(ang);
			org += v_forward*vlen(e.origin);
		}
		else
		if(e.light_ofs != '0 0 0')
		{
			ang = vectoangles(e.light_ofs);
			ang_x = ang_x*-1;
			ang_y += e.angles_y;
			ang_x += e.angles_x;
			ang_z += e.angles_z;		
			makevectors(ang);
			org = e.origin + v_forward*vlen(e.light_ofs);
		}
		else
			org = e.origin;

		if(e.light_duration)
		{
			llev = max(0, (e.light_life_endtime-time)/e.light_duration);
			llev = e.light_lev*llev;
		}
		else
			llev = e.light_lev;
		
		if(llev)
			R_AddDynamicLight(org, llev, e.color, e.style, "", e.pflags);
	}
}

vector CameraShake(vector camera_ofs) =
{
	local float maxdist, proximity;

	if(camerashakeintervaltime < time)
		camerashakeofs = '0 0 0';
	
	local entity e;
	e = list_camerashakechain;
	
	if(!e)
	{
		camerashakeintervaltime = 0;
		return camera_ofs;
	}
	
	while(e)
	{
		if(e.camerashake_y < time)
		{
			e.camerashake_x -= e.camerashake_x & CAMFL_SHAKE & CAMFL_SHAKE_REVERSEFADE;
			e.camerashake = '0 0 0';
			e.shakecamera = false;
		//	UpdateCameraShakeChain();
			CameraShakeChain_Remove(e);
		}
		else
		if(camerashakeintervaltime < time)
		{
			maxdist = 600 + (e.camerashake_y-time)*8000;
			proximity = bound(0, 1 - vlen(e.origin - player.origin)/maxdist, 1);
			
			if(e.camerashake_x & CAMFL_SHAKE)
				camerashakeofs += proximity*randomvec()*16*(e.camerashake_y-time);
			else
			if(e.camerashake_x & CAMFL_SHAKE_REVERSEFADE)
				camerashakeofs += proximity*randomvec()*16*((e.camerashake_y-e.camerashake_z)-(e.camerashake_y-time));
		}

		e = e.camerashakechain;
	}

	if(camerashakeofs*camerashakeofs > 100*100)
		camerashakeofs = normalize(camerashakeofs)*100;	
	
	camera_ofs += camerashakeofs;
	
	if(camerashakeintervaltime < time)
		camerashakeintervaltime = time + 1/30;
	
	return camera_ofs;
}

vector CameraEffects(vector camera_ofs) =
{
	camera_ofs = CameraShake(camera_ofs);
	//insert more effects here
	
	return camera_ofs;
}

vector AdminCamera(vector camera_ofs) =
{
	local float cameraspeed, minspeed, maxspeed;
	local vector cameralag;

	if(adminmode)
	{
		local vector ang;
		local float vel;
	
		camera_ofs_z = 1350;
	
		if(admincamera_ofs == '0 0 0')
			admincamera_ofs = player.origin + camera_ofs;	
	
		if(!currentmenu.menu_style & STYLE_PRIORITY)
		{
			if(!CURSOROVERMENU)//InterfacingWithGUI())// && currentmenu.scrollboxmeasurement))
			{
				if(GameControl(CTRL_ZOOMIN, 0))
					editorzoom = bound((admincamera_ofs_z - world.mins_z)*-1, editorzoom-250, world.maxs_z+3000 - admincamera_ofs_z);//bound(0, editorzoom-250, 5000);
				else
				if(GameControl(CTRL_ZOOMOUT, 0))
					editorzoom = bound((admincamera_ofs_z - world.mins_z)*-1, editorzoom+250, world.maxs_z+3000 - admincamera_ofs_z);//bound(0, editorzoom+250, 5000);
			}
			
			ang_y = input_angles_y;
			makevectors(ang);
			vel = 3000+editorzoom;
			
			if(!active_input)
			{
				if(GameControl(CTRL_EDITORMOVEFORWARD, 1))
					admincamera_ofs += v_forward*vel*frametime;
				if(GameControl(CTRL_EDITORMOVEBACK, 1))
					admincamera_ofs += v_forward*vel*frametime*-1;
				if(GameControl(CTRL_EDITORMOVELEFT, 1))
					admincamera_ofs += v_right*vel*frametime*-1;
				if(GameControl(CTRL_EDITORMOVERIGHT, 1))
					admincamera_ofs += v_right*vel*frametime;	
					
				admincamera_ofs_x = bound(world.mins_x+1000, admincamera_ofs_x, world.maxs_x-1000);
				admincamera_ofs_y = bound(world.mins_y+1000, admincamera_ofs_y, world.maxs_y-1000);
			//	admincamera_ofs_z = bound(world.mins_z+128, admincamera_ofs_z, world.maxs_z+250*12);
			}
		}

		camera_ofs = admincamera_ofs;
		camera_ofs_z += editorzoom;
	}
	else
	{
		if(frametime)
			maxspeed = 1/frametime;
		else
			return playercamera_origin;
			
		if(!fpscam)
		{
			minspeed = 1.5;
			cameraspeed = cvar("chase_cameraspeed");
			
			local vector camlagofs;
			local float speedfactor;
			
			camlagofs = playercamera_origin - (player.origin + camera_ofs);
			if(camlagofs != '0 0 0')
				camlagofs = camlagofs*bound(0, (500*(1-cameraspeed))/vlen(camlagofs), 1);
				
			if(cameraspeed == 1)
				speedfactor = 1;
			else
			if(cameraspeed)
				speedfactor = bound(0, (vlen(camlagofs)/(100000-100000*cameraspeed)), 1);

			cameralag = camlagofs - camlagofs*speedfactor;
		}
		
		playercamera_origin = (player.origin + camera_ofs) + cameralag;

		camera_ofs = playercamera_origin;
	}
	
	return camera_ofs;
}

// partially working cell navigation debugger
/*void DrawCellPaths() =
{
	local entity e;
	local vector pos;
	
	e = list_cellchain;
	while(e)
	{
		if(e.pathpattern)
		{
			pos = project(e.origin);
			drawstring(pos, ftos(e.pathpattern), '10 10 0', '1 0.1 0.1', 1, 0);
		}
	
		e = e.cellchain;
	}
}*/

/*void DrawReticlePolygon(vector start, vector end, float maxlen, string texturename) =
{
	local vector texturesize, top_left, top_right;

	texturesize = drawgetimagesize(texturename);
	texturesize = texturesize*(maxlen/texturesize_y);

	top_left_y = top_right_y = 1 - vlen(start-end)/maxlen;
	top_right_x = 1;
	
	makevectors(vectoangles(end-start));

	R_BeginPolygon(texturename, DRAWFLAG_NORMAL);
	R_PolygonVertex(end+v_right*-texturesize_x*0.5, top_left, '1 1 1', 1);	
	R_PolygonVertex(end+v_right*texturesize_x*0.5, top_right, '1 1 1', 1);
	R_PolygonVertex(start+v_right*texturesize_x*0.5, '1 1 0', '1 1 1', 1);
	R_PolygonVertex(start+v_right*-texturesize_x*0.5, '0 1 0', '1 1 1', 1);
	R_EndPolygon();	
}

void DrawReticles() =
{
	local vector start;
	local float si;
	
	if(reticle_mirv)
	{
		start = reticle_mirv.origin;
		traceline(start, start + '0 0 -10000', TRUE, reticle_mirv);
		si = getsurfacenearpoint(trace_ent, trace_endpos);
	
		
	}
}*/

void UpdateTime() =
{
//	local float oldmaptime;
	
//	oldmaptime = maptime_total;
	maptime_total = getstatf(STAT_MAPTIMER);
	maptime_start = getstatf(STAT_MAPTIMESTART);
//	maptime_passed = getstati(STAT_MAPTIMEPASSED);
//	if(oldmaptime != maptime_total)
//		maptime_current = time;
}

void GenerateMiniMap() =
{
	local string s, mapimgname;
	local float mapheight;
	local vector ofs;	
	
//	print(vtos(world.maxs)); print(" - "); print(vtos(world.mins));print("\n");	
	
	ofs_z = mapwidth;
	
	local vector fov;
	fov_y = tan(40*PI/360) * (3/4);
	fov_x = fov_y * vid_res_x / vid_res_y * cvar("vid_pixelheight");
	fov_x = atan(fov_x)*360/PI;
	fov_y = atan(fov_y)*360/PI;
	fov_x = fov_x + mapwidth*0.000008;
	fov_y = fov_y - mapwidth*0.000016;
	
	R_ClearScene();
	R_SetView(VF_DRAWWORLD, 1);
	R_SetView(VF_FOVX, fov_x);
	R_SetView(VF_FOVY, fov_y);	
	R_SetView(VF_ANGLES, '90 90 0');
	R_SetView(VF_ORIGIN, ofs);	
	R_SetView(VF_DRAWENGINESBAR, 0);
	R_RenderScene();
	
	if(mapimageexists == -3)
	{
		mapimgname = substring(mapname, 0, strlen(mapname)-3);
		mapimgname = strcat(mapimgname, "tga");		
	
		s = strcat("screenshot ", mapimgname);
		localcmd(s);
	}
	else
	if(mapimageexists == -100)
	{
	//	cvar_set("r_drawfog", ftos(drawfog));
	//	localcmd("fog 0 0 0 0\n");
		cvar_set("r_useportalculling", "2");
	//	cvar_set("r_novis", ftos(adminmode));		
	//	drawfog = false;		
		mapimageexists = true;	
		return;
	}
	
	mapimageexists -= 1;	
}

void PrepGenerateMiniMap() =
{
	mapimageexists = -2;
	CloseMenu();	
	menu_generateminimap = world;
}

void Draw_MissingMinimapMenu() =
{
	Menu_Start_ConfirmationMenu("Missing Mini-Map", '500 0 0', __FUNC__);
	Menu_Text("Steel Storm needs to generate a mini-map for this map.");

	BeginBottomButtons(1);
	DrawElement_BottomButton("OK", PrepGenerateMiniMap, 0, 0, 0, 0, MBT_BASIC);	
	EndBottomButtons();		
	
	Menu_End();
}

void View_GenerateMiniMap() =
{
	if(mapimageexists <= -2)
		GenerateMiniMap();
	else	
	if(!mapimageexists)
	{
		mapimageexists = -1;
		SetCurrentMenu(Draw_MissingMinimapMenu);
		currentmenu.ESCFunc = ESCFunc_AllowESCMenu;
		menu_generateminimap = currentmenu;
	//	drawfog = cvar("r_drawfog");
	//	cvar_set("r_drawfog", "0");	
	//	localcmd("fog 0.1 0 0 0\n");
		cvar_set("r_useportalculling", "0");
		cvar_set("r_novis", "1");
	}
	else
	if(mapimageexists == -1)
	{
		if(menu_generateminimap.draworder != menu_count)
		{
			dprint("menu_generateminimap: Is this used?\n");
			MoveMenuToTop(menu_generateminimap);
			}
	
		DrawHud();
		Mouse();		
	}
	
	ClearInput();
}

void Toggle_CamMode() =
{
	if(singleplayer)
	if(!unlocked_fpscamera)
//	if(!cvar("chase_fpscam"))
		return;

	playerviewsetting_fpscam = !playerviewsetting_fpscam;
}

void SetNoVisState(float novis, float fog) =
{
	local string s, fog_default;
	local float count, tokens, world_hasfog;
	
	cvar_set("r_novis", ftos(novis));

	if(fog != fog_replaced)
	{
		fog_default = cvar_string("fog_default");	
		tokenize(world_fog);
		world_hasfog = stof(argv(0));

		if(fog)
		{
			if(world_hasfog > 0)
			{
				tokenize(fog_default);
				s = argv(0);
				tokenize(world_fog);
				for(count = 1; count <= 3; count++)
					s = strcat(s, SEP_SPACE, argv(count));
				tokens = tokenize(fog_default);
				for(count = 4; count < tokens; count++)
					s = strcat(s, SEP_SPACE, argv(count));
			}
			else
				s = fog_default;
		}
		else
		if(world_hasfog)
			s = world_fog;
		else
			s = "0";
			
		s = strcat("fog ", s);
		s = strcat(s, "\n");
		localcmd(s);
	}
	
	fog_replaced = fog;
}

// CSQC_UpdateView - Called every rendered frame on the client.  Useful for HUD drawing operations.
void CSQC_UpdateView(void)
{
	local vector viewang, ang;
	local float minversion, devmode, chase_lockyaw, chase_overhead, chase_back, chase_back_min, chase_up, angdiff, yawspeed, viewpitch_min, novis, lowqualfps, lockyaw, fog;
	
	// ALWAYS Clear Current Scene First
	R_ClearScene();	
	
	time_local = gettime(GETTIME_REALTIME);
	
	FastKeyRelease();
	
	UpdateLanguage();
	
	UpdateTime();
	
	Video_Update();
	BindMap_Update();
	
	ClearFreedEnts();

	MobileEntPrediction();
	UpdateAvelocityEnts();
	
	if(mapimageexists <= 0)
	{
		View_GenerateMiniMap();
		return;
	}
	
	// Assign Standard Viewflags
	// Draw the World (and sky)

//	fpscam_prev = fpscam;	
	fpscam = false;
	
//	if(singleplayer)
//	if(!unlockedfpscam)
//	if(!cvar("chase_fpscam"))
//		playerviewsetting_fpscam = false;
	
	if(player || adminmode)
	{
		R_SetView(VF_DRAWWORLD, 1);

		chase_lockyaw = cvar("chase_lockyaw");
		viewang_x = cvar("chase_pitchangle");
		chase_back = cvar("chase_back");
		
		devmode = cvar("developer");
		
		minversion = 2;
		if(EPISODE >= minversion)
		if(!adminmode)
		if(!devmode)
			fpscam = playerviewsetting_fpscam;//cvar("chase_fpscam");		

		lowqualfps = cvar("chase_fpscam_lowqual");
		novis = cvar("r_novis");	
		lockyaw = cvar("chase_lockyaw");
	//	fog = cvar("r_drawfog");	
			
		if(fpscam || adminmode)
		{
			if(lowqualfps)
			if(novis || !fog_replaced)
			if(!adminmode)
				SetNoVisState(false, true);

			if(!novis || fog_replaced)
			if(!lowqualfps || adminmode)
				SetNoVisState(true, false);
				
			if(playerviewsetting_lockyaw)
			{
				localcmd("cmd lockcamera 0\n");
				playerviewsetting_lockyaw = false;
			}
		}
		else
		if(!fpscam && !adminmode)
		{
			if(novis || fog_replaced)
				SetNoVisState(false, false);

			if(playerviewsetting_lockyaw != lockyaw)
			{
				localcmd(strcat("cmd lockcamera ", ftos(cvar("chase_lockyaw")), "\n"));
				playerviewsetting_lockyaw = cvar("chase_lockyaw");
			}
		}		
		
		if(adminmode || fpscam)
		{
			viewang_y = input_angles_y;
			playercamera_angle = viewang_y;
		}
		else
		if(chase_lockyaw)
		{
			viewang_y = 90;
			playercamera_angle = 90;
		}
		else
		{
			angdiff = NormalizeAngle(input_angles_y - playercamera_angle);
			if(frametime)
				yawspeed = frametime/max(frametime, 5*(1-cvar("chase_yawspeed")));
			viewang_y = playercamera_angle + angdiff*yawspeed;
			playercamera_angle = viewang_y;
		}

		ang_y = input_angles_y;
		makevectors(ang);
		
		if(fpscam)
		{
			chase_overhead = false;
			viewang_x = 20;
			chase_up = 150;
			chase_back = 100;
		}
		else
		if(devmode && maxplayers <= 1)
		{
			chase_overhead = cvar("chase_overhead");
			chase_up = cvar("chase_up");		
		}
		else
		{
			chase_overhead = true;
			chase_up = 1350;
			viewang_x = bound(75, viewang_x, 90);
			chase_back = bound(-500, chase_back, 0);
			viewpitch_min = 75 + ((0-chase_back)/500)*15;
			viewang_x = bound(viewpitch_min, viewang_x, 90);			
			chase_back_min = -500 + ((90-viewang_x)/15)*500;
			chase_back = bound(chase_back_min, chase_back, 0);			
		}

		playercamera_pitch = viewang_x;
		
		if(chase_overhead || fpscam)
			R_SetView(VF_ANGLES, viewang);

		camera_origin = v_forward*-1*chase_back;
		camera_origin_z += chase_up;
		camera_origin = CameraEffects(camera_origin);
		camera_origin = AdminCamera(camera_origin);

		// Set view origin to align with shared player ent's origin
		R_SetView(VF_ORIGIN, camera_origin);	
		
		local vector fov;
		fov_y = tan(90*PI/360) * (3/4);
		fov_x = fov_y * vid_res_x / vid_res_y * cvar("vid_pixelheight");
		fov_x = atan(fov_x)*360/PI;
		fov_y = atan(fov_y)*360/PI;
		
		R_SetView(VF_FOVX, fov_x);
		R_SetView(VF_FOVY, fov_y);		
//	R_SetView(VF_ORIGIN, pmove_org+'0 0 1350');	
		// Draw the Crosshair
//	R_SetView(VF_DRAWCROSSHAIR, 1);
		// Draw the Engine Status Bar (the default Quake HUD)
		
	//	R_SetView(VF_MIN, getviewvec(VF_MIN));
	//	R_SetView(VF_SIZE, getviewvec(VF_SIZE));
		
	local float items1, items2, secondaryweapon;
	items1 = getstati(STAT_ITEMS1);
	items2 = getstati(STAT_ITEMS2);
	secondaryweapon = getstati(STAT_SECONDARYWEP);		
	DrawReticles(items1, items2, secondaryweapon);			
		
		
		R_SetView(VF_DRAWENGINESBAR, 0);
		
//	R_SetView(VF_PERSPECTIVE, 0);

		// Setup Entities to be Rendered (include all base types; normal, engine and viewmodels)
		R_AddEntities(MASK_NORMAL | MASK_ENGINE | MASK_ENGINEVIEWMODELS);
		
		// Render DLights
		R_AddLights();
		
		// Render the Scene
		R_RenderScene();
		
		if(frametime)
		{
			DrawEntConnections();
			DrawPathConnections();	
		//	DrawReticles();
			DrawShots();	
			if(effectdrawtime <= time)
				DrawParticleEmitters(camera_origin);
		}
	}
	
//	DrawCellPaths();	// partially working cell navigation debugger
	
/*	if(cl_button == -K_MOUSE2)	
	if(IsAssignedFunction(pulldown_tool))
	if(!IsAssignedFunction(pulldown_mainfunc))
	if(!marker)
	if(!movingent)
	if(!hover_ent)
	{
		cl_button = 0;
		if(pulldown_tooltype == PDT_SUB)
			Toggle_PullDown(pulldown_tool, false, world, 0, 0);
		else
		if(pulldown_tooltype == PDT_FUNC)
			pulldown_tool();
	}	*/
	
/*	if(esctime)
	{
		if(esctime <= time)
			esctime = 0;
	}
	else*/
	if(!ESCMENU)
	{
		DrawNameTags();
		DrawPainFrame();
		DrawStats();
		DrawGlobalItems();			
		DrawRadar();		
		Draw_VoteStats();		
		DrawActiveTerminal();
		DrawHud();			
	//	DrawScene();

		DrawCenterPrintMessages();
		Mouse();
		if(!active_input && !active_textblock)
		{
			if(GameControl(CTRL_TOGGLEMISSIONBRIEFING, 0))
				ToggleMissionBriefing();
			else
			if(GameControl(CTRL_TOGGLELIVESCORES, 0))
				Toggle_LiveScores();	
			else
			if(GameControl(CTRL_TOGGLECAMMODE, 0))
				Toggle_CamMode();
		}
	}	
	
//	DrawEntConnections();
//	DrawPathConnections();
	
//	if(IsAssignedFunction(admin_EditingFunc))
//		admin_EditingFunc();	

/*	local entity e;
	local vector screenpos;
	local float connections;
	e = findchainfloat(class, CLASS_CELL);
	while(e)
	{
		screenpos = cs_project(e.origin);
		screenpos_z = 0;
		
		drawstring(screenpos, ftos(e.filloccupancy), '8 8 0', '1 1 1', 1, 0);
		connections = 0;
		e = e.chain;
	}*/
		
//	if(list_ownerlesschain) this has to be a think function per owner. may have to spawn a seperate ent to think? maybe not.
//		UpdateOwners();	
		
	ClearInput();
	if(effectdrawtime <= time)
		effectdrawtime = time+(1/60);		
}