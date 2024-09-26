////////////////////////////////////////
// Blood Omnicide source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

void() EditLights_Frame;

float EditLights_MoveForward;
float EditLights_MoveBack;
float EditLights_MoveLeft;
float EditLights_MoveRight;
float EditLights_Active;

vector EditLight_ViewOrigin;
vector EditLight_ViewAngles;
vector EditLight_ViewMin;
vector EditLight_ViewSize;

vector EditLights_Movement;

// modeviewer globals
float ModelViewer_Enabled;
void() ModelViewer_Frame;
void() ModelViewer_2DFrame;

// external globals
float hud_screenwidth;
float vid_pixelheight;

////////////////////////////////////////
// CODE
////////////////////////////////////////

/*
================================================================================

  MAIN 

================================================================================
*/

void() EditLights_Stop;
void() EditLightsUpdateView =
{
	float fov;
	
	// camera movement
	EditLight_ViewAngles = input_angles;
	makevectors(EditLight_ViewAngles);
	EditLight_ViewOrigin = EditLight_ViewOrigin + normalize(v_forward*EditLights_Movement_x + v_right*EditLights_Movement_y + v_up*EditLights_Movement_z)*cvar("r_editlights_cameraspeed")*frametime;
	
	// set fov
	fov = cvar("fov");
	if (hud_screenwidth && vid_pixelheight)
	{
		setview(VF_FOVX, fov*hud_screenwidth);
		setview(VF_FOVY, fov*vid_pixelheight*0.75);
	}
	else
	{
		setview(VF_FOVX, fov);
		setview(VF_FOVY, fov*0.75);
	}
	
	// render
	setview(VF_ORIGIN, EditLight_ViewOrigin);
	setview(VF_ANGLES, EditLight_ViewAngles);
	setview(VF_VIEWANGLES, EditLight_ViewAngles);
	setlistener(EditLight_ViewOrigin, v_forward, v_right, v_up);
	
	// grab viewport cos we going to draw stuff in it
	EditLight_ViewMin = getviewvec(VF_MIN);
	EditLight_ViewSize = getviewvec(VF_SIZE);

	// stop if r_editlights was shut down
	if (!cvar("r_editlights") && !ModelViewer_Enabled)
	{
		EditLights_Stop();
		return;
	}
	
	// run model viewer frame
	ModelViewer_Frame();
}

float EditLightsKeyEvent(float tEvent, float tKeyCode) =
{
	if (!EditLights_Active)
		return KR_FALSE;
		
	if (tKeyCode == EditLights_MoveForward)
	{
		if (tEvent == KEYEVENT_HOLD)
			EditLights_Movement_x = 1;
		else
			EditLights_Movement_x = 0;
		return KR_TRUE;
	}
	if (tKeyCode == EditLights_MoveBack)
	{
		if (tEvent == KEYEVENT_HOLD)
			EditLights_Movement_x = -1;
		else
			EditLights_Movement_x = 0;
		return KR_TRUE;
	}
	if (tKeyCode == EditLights_MoveRight)
	{
		if (tEvent == KEYEVENT_HOLD)
			EditLights_Movement_y = 1;
		else
			EditLights_Movement_y = 0;
		return KR_TRUE;
	}
	if (tKeyCode == EditLights_MoveLeft)
	{
		if (tEvent == KEYEVENT_HOLD)
			EditLights_Movement_y = -1;
		else
			EditLights_Movement_y = 0;
		return KR_TRUE;
	}
	return KR_FALSE;
}

//void() EditLightsSpawnObjects;
void() EditLights_ProcDef =
{	
	Menu_Sys_SetProcCoordSpace(menu_proc, vec2(640, 480));
	Menu_Sys_SetProcMouse(menu_proc, 0);
	Menu_Sys_SetProcFrameFunc(menu_proc, EditLights_Frame);
	Menu_LoadFromFile(null_entity, "editlights/menu.ns2", 0);
	Menu_Sys_SetProcFlags(menu_proc, -MENU_PROCFLAG_HIDDEN);
	//EditLightsSpawnObjects();
}

void() EditLights_Start =
{
	if (Menu_Sys_FindProc("EditLights"))
		return;
	cvar_set("r_editlights", "1");
	Menu_API_CreateProc("EditLights", EditLights_ProcDef, null_function);
	EditLight_ViewOrigin = getviewvec(VF_ORIGIN);
	EditLight_ViewAngles = getviewvec(VF_ANGLES);
	EditLights_Active = 1;
	print("Lights editor GUI loaded\n");
}

void() EditLights_Stop =
{
	if (!Menu_Sys_FindProc("EditLights"))
		return;
	cvar_set("r_editlights", "0");
	Menu_Sys_DestroyProc("EditLights");
	EditLights_Active = 0;
	print("Lights editor GUI unloaded\n");
}

void() EditLights_Frame =
{
	// update keys
	EditLights_MoveForward = Menu_Sys_StringToKeyNum(cvar_string("editlights_key_forward"));
	EditLights_MoveBack = Menu_Sys_StringToKeyNum(cvar_string("editlights_key_back"));
	EditLights_MoveLeft = Menu_Sys_StringToKeyNum(cvar_string("editlights_key_moveleft"));
	EditLights_MoveRight = Menu_Sys_StringToKeyNum(cvar_string("editlights_key_moveright"));
	
	// draw modelviewer 2d stuff
	ModelViewer_2DFrame();
}

/*
================================================================================

  MODEL PREVIEWER

================================================================================
*/

// globals
float ModelViewer_Tool;
float ModelViewer_Drag;
float ModelViewer_SpawnType;
string ModelViewer_Tag;
vector ModelViewer_TagOffset;
vector ModelViewer_TagAngles;
string ModelViewer_Model;
entity ModelViewer_EntSelected;
entity ModelViewer_EntPreview;
float ModelViewer_EntSelectionLock;
float ModelViewer_Index;
vector ModelViewer_DragOfs;
vector ModelViewer_DragAngleOfs;

// drag tool
enum
{
	MODELVIEW_DRAG_NO,
	MODELVIEW_DRAG_XYZ,
	MODELVIEW_DRAG_XY,
	MODELVIEW_DRAG_Z,
	_
};

// spawntypes
enum
{
	MODELVIEW_SPAWNTYPE_STATIC, // traced, not oriented
	MODELVIEW_SPAWNTYPE_FACED, // faced to camera
	MODELVIEW_SPAWNTYPE_DECAL, // turn from walls
	MODELVIEW_SPAWNTYPE_PLANT, // like decal but forward = z axis
	_
};


// tools
enum
{
	MODELVIEW_TOOL_SELECT,
	MODELVIEW_TOOL_SPAWN,
	MODELVIEW_TOOL_ATTACH,
	_
};

// entity fields
.float drawtime;

// precache model and return its modelindex
float ModelViewer_Loadmodel(string s) =
{
	entity e;
	float i;
	
	e = spawn();
	precache_model(s);
	setmodel(e, s);
	i = e.modelindex;
	remove(e);
	return i;
}

// trace cursor
void ModelViewer_TraceCursor(entity tIgnore, float maxdist, float pushback) =
{
	makevectors(EditLight_ViewAngles);
	if (!ModelViewer_Drag && ModelViewer_Tool == MODELVIEW_TOOL_SPAWN)
		tracebox(EditLight_ViewOrigin, ModelViewer_EntPreview.mins, ModelViewer_EntPreview.maxs, EditLight_ViewOrigin + v_forward*maxdist, MOVE_NOMONSTERS, tIgnore);
	else
		traceline(EditLight_ViewOrigin, EditLight_ViewOrigin + v_forward*maxdist, MOVE_HITMODEL, tIgnore);
	trace_endpos = trace_endpos - v_forward*min(trace_fraction*maxdist, pushback);
}

// limit bbox cos we don't get ugly selection on very large models
vector ModelViewer_LimitBbox(vector v)
{
	v_x = bound(-128, v_x, 128);
	v_y = bound(-128, v_y, 128);
	v_z = bound(-512, v_z, 512);
	return v;
}


// draw a rectangle box around some entity
// parms:
//   emin : entity absmin
//   emax : entity absmax
//   box_parms : x - minimum size, y - size scale
//   pulse_parms : x - period, y - power, z - unused
//   corner_color : color of corners
//   corner_parms : x - size, y - width, z - outline
//   outline_alpha : opacity of outlining
float ModelViewer_DrawSelectBox(entity e, vector box_parms, vector pulse_parms, vector corner_color, vector corner_parms, float outline_alpha, float test)
{
	vector org, eorg, emin, emax, bmin, bmax, v1, v2, v3, v4, v5, v6, v7, v8, outline;
	float pulse, nearestz, bboxenlargement;

	// get entity bbox
	v1 = v_forward;
	v2 = v_right;
	v3 = v_up;
	if (e.tag_entity)
	{
		eorg = gettaginfo(e, -1);
		emin = eorg + vec3(min(-16, e.mins_x), min(-16, e.mins_y), min(-16, e.mins_z));
		emax = eorg + vec3(min(16, e.maxs_x), min(16, e.maxs_y), min(16, e.maxs_z));
	}
	else
	{
		eorg = e.origin;
		emin = e.absmin;
		emax = e.absmax;
	}
	v_forward = v1;
	v_right = v2;
	v_up = v3;
	
	// get base bbox parms
	org = (emin + emax)*0.5;
	if (vlen(org - eorg) > 128) // too much dirrerence, use original
		org = eorg;
	bmin = org + ModelViewer_LimitBbox(vec3(min(0-box_parms_x, emin_x - org_x), min(0-box_parms_x, emin_y - org_y), min(0-box_parms_x, emin_z - org_z))*box_parms_y);
	bmax = org + ModelViewer_LimitBbox(vec3(max(box_parms_x, emax_x - org_x), max(box_parms_x, emax_y - org_y), max(box_parms_x, emax_z - org_z))*box_parms_y);
	
	// pulse template
	bboxenlargement = bound(1, (bbox_radius(bmin-org, bmax-org) / 80), 8);
	pulse = (1-fabs(cos(time*pulse_parms_x)))*pulse_parms_y;
	outline = vec2(corner_parms_z, corner_parms_z);
	
	// project all box corners
	org = cs_project(org); org_z = 0;
	v1 = cs_project(bmin);
	v2 = cs_project(vec3(bmax_x, bmin_y, bmin_z));
	v3 = cs_project(vec3(bmin_x, bmax_y, bmin_z));
	v4 = cs_project(vec3(bmax_x, bmax_y, bmin_z));
	v5 = cs_project(bmax);
	v6 = cs_project(vec3(bmin_x, bmax_y, bmax_z));
	v7 = cs_project(vec3(bmax_x, bmin_y, bmax_z));
	v8 = cs_project(vec3(bmin_x, bmin_y, bmax_z));
	
	// cull
	nearestz = max(v1_z, v2_z, v3_z, v4_z, v5_z, v6_z, v7_z, v8_z);
	if (nearestz < 0)
		return 0;
		
	// scale by distance
	pulse = pulse * max(0, bound(0, 256 / nearestz, 1)) * bboxenlargement;
	corner_parms = corner_parms * bound(0.5, 100 / nearestz, 1) * bboxenlargement * (Draw2D_Scale_x + Draw2D_Scale_y) * 0.5;
	
	// reuse some temps
	bmin_x = bound(0, min(v1_x, v2_x, v3_x, v4_x, v5_x, v6_x, v7_x, v8_x), cvar("vid_conwidth")-corner_parms_x);
	bmin_y = bound(0, min(v1_y, v2_y, v3_y, v4_y, v5_y, v6_y, v7_y, v8_y), cvar("vid_conheight")-corner_parms_x);
	bmax_x = bound(0, max(v1_x, v2_x, v3_x, v4_x, v5_x, v6_x, v7_x, v8_x), cvar("vid_conwidth")-corner_parms_x);
	bmax_y = bound(0, max(v1_y, v2_y, v3_y, v4_y, v5_y, v6_y, v7_y, v8_y), cvar("vid_conheight")-corner_parms_x);

	// testing against crosshair
	if (test) 
	{
		makevectors(EditLight_ViewAngles);
		v1 = cs_project(EditLight_ViewOrigin + v_forward*256);
		if (pointinsector(v1, bmin, bmax))
			return 1;
		return 0;
	}
	
	// prepare for draw
	v1 = vec2(corner_parms_x, corner_parms_y);
	v2 = vec2(corner_parms_y, corner_parms_x);
	v3 = v1 + outline*2;
	v4 = v2 + outline*2;
	v5_z = 0;
	
	// 2d box : left up corner
	v5_x = bmin_x;
	v5_y = bmin_y;
	v5 += normalize(org - v5)*pulse;
	if (corner_parms_z)
	{
		drawfill(v5 - outline, v3, '0 0 0', outline_alpha, 0); // outline horz
		drawfill(v5 - outline, v4, '0 0 0', outline_alpha, 0); // outline vert
	}
	drawfill(v5, v1, corner_color, 1, 0); // horz
	drawfill(v5, v2, corner_color, 1, 0); // vert
	
	// 2d box : left down corner
	v5_x = bmin_x;
	v5_y = bmax_y;
	v5 += normalize(org - v5)*pulse;
	if (corner_parms_z)
	{
		drawfill(v5 - vec2(0, corner_parms_y) - outline, v3, '0 0 0', outline_alpha, 0); // outline horz
		drawfill(v5 - vec2(0, corner_parms_x) - outline, v4, '0 0 0', outline_alpha, 0); // outline vert
	}
	drawfill(v5 - vec2(0, corner_parms_y), v1, corner_color, 1, 0); // horz
	drawfill(v5 - vec2(0, corner_parms_x), v2, corner_color, 1, 0); // vert
	
	// 2d box : right up corner
	v5_x = bmax_x;
	v5_y = bmin_y;
	v5 += normalize(org - v5)*pulse;
	if (corner_parms_z)
	{
		drawfill(v5 - vec2(corner_parms_x, 0) - outline, v3, '0 0 0', outline_alpha, 0); // outline horz
		drawfill(v5 - vec2(corner_parms_y, 0) - outline, v4, '0 0 0', outline_alpha, 0); // outline vert
	}
	drawfill(v5 - vec2(corner_parms_x, 0), v1, corner_color, 1, 0); // horz
	drawfill(v5 - vec2(corner_parms_y, 0), v2, corner_color, 1, 0); // vert
	
	// 2d box : right down corner
	v5_x = bmax_x;
	v5_y = bmax_y;
	v5 += normalize(org - v5)*pulse;
	if (corner_parms_z)
	{
		drawfill(v5 - vec2(corner_parms_x, corner_parms_y) - outline, v3, '0 0 0', outline_alpha, 0); // outline horz
		drawfill(v5 - vec2(corner_parms_y, corner_parms_x) - outline, v4, '0 0 0', outline_alpha, 0); // outline vert
	}
	drawfill(v5 - vec2(corner_parms_x, corner_parms_y), v1, corner_color, 1, 0); // horz
	drawfill(v5 - vec2(corner_parms_y, corner_parms_x), v2, corner_color, 1, 0); // vert
	return 1;
}

// selecting traceline
entity ModelViewer_SelectEntity(string clsname, float try_trace)
{
	entity e, selected;
	float dist, selected_dist, rad, oldsolid;
	vector dir;
	
	makevectors(EditLight_ViewAngles);
	selected = world;
	selected_dist = 1000000000;
	for (e = nextent(world); e; e = nextent(e))
	{
		if (e.classname != clsname)
			continue;
		dir = e.origin - EditLight_ViewOrigin;
		dist = vlen(dir);
		dir = normalize(dir);
		if (e.tag_entity) // attached entities cannot be traced
			trace_ent = world;
		else
		{
			// try trace
			oldsolid = e.solid;
			e.solid = SOLID_BBOX;
			traceline(EditLight_ViewOrigin, EditLight_ViewOrigin + v_forward*1024, MOVE_HITMODEL, world);
			e.solid = oldsolid;
		}
		// trace against bbox
		if (trace_ent != e)
		{
			if (ModelViewer_DrawSelectBox(e, '4 0.75 0', '6 10 0', '1 1 1', '10 1.5 0.5', 0.9, 1))
				trace_ent = e;
			else
				continue;
		}
		// select
		if (!selected || dist < selected_dist || (e.tag_entity && !selected.tag_entity))
		{
			selected = e;
			selected_dist = dist;
		}
	}
	return selected;
}

// model entity predraw
void() ModelViewer_Frame_ModelPredraw =
{
	float frac, start, end, rate, numframes, animtime, loop;
	
	// animation
	// todo: cleanup
	if (self.netname != "") // animation
	{
		tokenize(self.netname);
		start = stof(argv(0));
		end = stof(argv(1));
		rate = stof(argv(2));
		loop = stof(argv(3));
		numframes = fabs(fabs(end - start) + 1);
		animtime = numframes/rate;
		if (rate)
		{
			frac = (time - self.drawtime)/animtime;
			// cycle animation
			if (frac > 1 && loop) 
			{
				while(frac > 1)
				{
					self.drawtime += animtime;
					frac -= 1;
				}
			}
			// update frame
			if (frac <= 1)
			{
				frac = start + numframes*frac;
				self.frame = floor(frac);
				self.lerpfrac = frac - floor(frac);
				self.frame2 = ceil(frac);
			}
		}
	}
	
	// avelocity
	self.angles = self.angles + self.avelocity*frametime;
}

// called each frame before render
void() ModelViewer_Frame =
{
	entity oldModelSelected, e;
	string newModel;
	float reattach;
	vector org, ang;
	
	// model placing turns off editor
	ModelViewer_Enabled = cvar("r_modelview");
	if (!ModelViewer_Enabled)
	{
		cvar_set("r_editlights", "1");
		return;
	}
	cvar_set("r_editlights", "0");
	ModelViewer_EntPreview.drawmask = 0;
	reattach = 0;
	
	// check if changed model
	newModel = cvar_string("r_modelview_model");
	if (ModelViewer_Model != newModel)
	{
		ModelViewer_Index = ModelViewer_Loadmodel(newModel);
		ModelViewer_Model = rezone(ModelViewer_Model, newModel);
		reattach = 1;
	}
	
	// check if changed tag
	newModel = cvar_string("r_modelview_tag");
	if (ModelViewer_Tag != newModel)
	{
		ModelViewer_Tag = rezone(ModelViewer_Tag, newModel);
		reattach = 1;
	}

	// selection and spawn preview
	if (ModelViewer_Drag)
	{
		ModelViewer_TraceCursor(ModelViewer_EntSelected, ModelViewer_DragOfs_x, 16);
		// dragging
		e = ModelViewer_EntSelected;
		if (isnotentity(e))
			ModelViewer_Drag = MODELVIEW_DRAG_NO; // disable drag tool if nothing selected (well, should never happen)
		else
		{
			if (ModelViewer_Drag == MODELVIEW_DRAG_XYZ)
			{
				makevectors(EditLight_ViewAngles);
				org = EditLight_ViewOrigin + v_forward*ModelViewer_DragOfs_x*trace_fraction + v_right*ModelViewer_DragOfs_y + v_up*ModelViewer_DragOfs_z;
				ang = vec3(e.angles_x, EditLight_ViewAngles_y + ModelViewer_DragAngleOfs_y, e.angles_z);
			}
			else if (ModelViewer_Drag == MODELVIEW_DRAG_XY)
			{
				makevectors(EditLight_ViewAngles);
				org = trace_endpos;
				org_z = e.origin_z;
				ang = e.angles;
			}
			else if (ModelViewer_Drag == MODELVIEW_DRAG_Z)
			{
				makevectors(EditLight_ViewAngles);
				org = trace_endpos;
				org_x = e.origin_x;
				org_y = e.origin_y;
				ang = e.angles;
			}
			setorigin(e, org);
			e.angles = ang;
		}
	}
	else
	{
		// select/unselect
		if (!ModelViewer_EntSelectionLock)
		{
			e = ModelViewer_EntSelected;
			if (ModelViewer_Tool == MODELVIEW_TOOL_SELECT || ModelViewer_Tool == MODELVIEW_TOOL_ATTACH)
				ModelViewer_EntSelected = ModelViewer_SelectEntity("mdl", 1);
			else
				ModelViewer_EntSelected = world;
			if (e != ModelViewer_EntSelected)
				reattach = 1;
		}
		// show preview if spawning
		ModelViewer_TraceCursor(ModelViewer_EntPreview, cvar("r_modelview_spawndist"), 0);
		if (ModelViewer_Tool == MODELVIEW_TOOL_ATTACH)
		{
			if (reattach && ModelViewer_EntSelected)
				setattachment(ModelViewer_EntPreview, ModelViewer_EntSelected, ModelViewer_Tag);
			// always update origin/angles of attachment
			setorigin(ModelViewer_EntPreview, vec3(cvar("r_modelview_tag_offsetx"),cvar("r_modelview_tag_offsety"),cvar("r_modelview_tag_offsetz")));
			ModelViewer_EntPreview.angles = vec3(cvar("r_modelview_tag_anglesx"),cvar("r_modelview_tag_anglesy"),cvar("r_modelview_tag_anglesz"));
		}
		else if (ModelViewer_Tool == MODELVIEW_TOOL_SPAWN)
		{
			ModelViewer_SpawnType = cvar("r_modelview_spawntype");
			// MODELVIEW_SPAWNTYPE_STATIC
			setattachment(ModelViewer_EntPreview, world, "");
			setorigin(ModelViewer_EntPreview, trace_endpos);
			ModelViewer_EntPreview.angles = '0 0 0'; 
			ModelViewer_EntPreview.renderflags = ModelViewer_EntPreview.renderflags - (ModelViewer_EntPreview.renderflags & RF_USEAXIS);
			if (ModelViewer_SpawnType == MODELVIEW_SPAWNTYPE_FACED)
				ModelViewer_EntPreview.angles = vectoangles(normalize(EditLight_ViewOrigin - trace_endpos));
			else if (ModelViewer_SpawnType == MODELVIEW_SPAWNTYPE_DECAL)
			{
				makevectors(vectoclientangles(trace_plane_normal));
				ModelViewer_EntPreview.angles = vectoangles(v_forward, v_up);	
			}
			else if (ModelViewer_SpawnType == MODELVIEW_SPAWNTYPE_PLANT)
			{
				makevectors(vectoclientangles(trace_plane_normal));
				ModelViewer_EntPreview.angles = vectoangles(v_up, v_forward);
			}
		}
		else
		{
			setattachment(ModelViewer_EntPreview, world, "");
			setorigin(ModelViewer_EntPreview, trace_endpos);
			ModelViewer_EntPreview.angles = '0 0 0';
		}
		ModelViewer_EntPreview.modelindex = ModelViewer_Index;
		ModelViewer_EntPreview.predraw = null_function;
		if (ModelViewer_Tool == MODELVIEW_TOOL_SPAWN || (ModelViewer_Tool == MODELVIEW_TOOL_ATTACH && ModelViewer_EntSelected))
			ModelViewer_EntPreview.drawmask = MASK_NORMAL;
	}
	
	// update selected cvars
	if (ModelViewer_EntSelected)
		cvar_set("r_modelview_selected_model", ModelViewer_EntSelected.model);
}

// called each frame after render
void() ModelViewer_2DFrame =
{
	vector vMin, vSize, cMin, cSize;
	
	if (!ModelViewer_Enabled || ModelViewer_Tool == MODELVIEW_TOOL_SPAWN)
		return;

	Draw2D_Start("conchars", 640, 480);
	// draw crosshair (match viewport)
	cMin = getviewvec(VF_MIN);
	cSize = getviewvec(VF_SIZE);
	vMin_x = ( EditLight_ViewMin_x / cMin_x ) * cvar("vid_conwidth");
	vMin_y = ( EditLight_ViewMin_y / cMin_y ) * cvar("vid_conheight");
	vSize_x = ( EditLight_ViewSize_x / cSize_x ) * cvar("vid_conwidth");
	vSize_y = ( EditLight_ViewSize_y / cSize_y ) * cvar("vid_conheight");
	drawfill(vMin + vSize * 0.5 - '3.5 1', '7 2', '0 0 0', 0.9, 0); // outline
	drawfill(vMin + vSize * 0.5 - '1 3.5', '2 7', '0 0 0', 0.9, 0); // outline
	drawfill(vMin + vSize * 0.5 - '3 0.5', '6 1', '1 1 1', 1, 0);
	drawfill(vMin + vSize * 0.5 - '0.5 3', '1 6', '1 1 1', 1, 0);
	
	// draw selection box (temporarily restore our main viewport)
	if (isentity(ModelViewer_EntSelected))
	{
		setview(VF_MIN, EditLight_ViewMin);
		setview(VF_SIZE, EditLight_ViewSize);
		ModelViewer_DrawSelectBox(ModelViewer_EntSelected, '4 0.75 0', '6 10 0', '1 1 1', '10 1.5 0.5', 0.9, 0);
		setview(VF_MIN, cMin);
		setview(VF_SIZE, cSize);
	}
}

// spawn/attach new model entity
command Cmd_ModelViewer_Spawn =
{
	entity e;
	
	if (ModelViewer_Tool != MODELVIEW_TOOL_ATTACH && ModelViewer_Tool != MODELVIEW_TOOL_SPAWN)
	{
		print("ModelViewer_Spawn: not in spawn/attach tool\n");
		return;
	}
	if (ModelViewer_Tool == MODELVIEW_TOOL_ATTACH && isnotentity(ModelViewer_EntSelected))
	{
		print("ModelViewer_Spawn: no model selected to attach to\n");
		return;
	}
	// spawn/attach
	e = spawn();
	e.classname = "mdl";
	e.drawmask = MASK_NORMAL;
	e.solid = SOLID_SLIDEBOX;
	e.predraw = ModelViewer_Frame_ModelPredraw;
	setmodelindex(e, ModelViewer_Index);
	setorigin(e, ModelViewer_EntPreview.origin);
	e.angles = ModelViewer_EntPreview.angles;
	setsize(e, e.mins, e.maxs);
	if (ModelViewer_Tool == MODELVIEW_TOOL_ATTACH)
	{
		setattachment(e, ModelViewer_EntSelected, ModelViewer_Tag);
		setorigin(e, vec3(cvar("r_modelview_tag_offsetx"),cvar("r_modelview_tag_offsety"),cvar("r_modelview_tag_offsetz")));
		e.angles = vec3(cvar("r_modelview_tag_anglesx"),cvar("r_modelview_tag_anglesy"),cvar("r_modelview_tag_anglesz"));
	}
}

// lock/unlock editing
command Cmd_ModelViewer_Lock =
{
	// turn off lock	
	if (ModelViewer_EntSelectionLock)
	{
		ModelViewer_EntSelectionLock = 0;
		return;
	}
	// need something selected
	if (isnotentity(ModelViewer_EntSelected))
	{
		print("ModelViewer_Lock: nothing selected\n");
		return;
	}
	ModelViewer_EntSelectionLock = 1;
}

// choose tool
command Cmd_ModelViewer_Tool =
{
	cmdstr = argv(1);
	if (cmdstr == "select" || cmdstr == "default")
	{
		ModelViewer_Tool = MODELVIEW_TOOL_SELECT;
		return;
	}
	if (cmdstr == "attach")
	{
		ModelViewer_Tool = MODELVIEW_TOOL_ATTACH;
		return;
	}
	if (cmdstr == "spawn")
	{
		ModelViewer_Tool = MODELVIEW_TOOL_SPAWN;
		return;
	}
	print("Model viewer tools: \n");
	print(" ^select 0/1^7 : select models\n");
	print(" ^attach 0/1^7 : attach new models to selected one\n");
	print(" ^spawn 0/1^7 : spawn new models\n");
}

// drag model entities
command Cmd_ModelViewer_Drag =
{
	entity e;
	string s;
	
	// can't drag attached at the moment
	if (ModelViewer_EntSelected.tag_entity)
	{
		print("ModelViewer_Drag: cannot drag attached entities\n");
		return;
	}
	// turn off drag	
	if (ModelViewer_Drag)
	{
		ModelViewer_Drag = MODELVIEW_DRAG_NO;
		return;
	}
	// need something selected
	if (isnotentity(ModelViewer_EntSelected))
	{
		print("ModelViewer_Drag: nothing selected\n");
		return;
	}
	// get the tool
	s = argv(1);
	if (s == "xyz")
		ModelViewer_Drag = MODELVIEW_DRAG_XYZ;
	else if (s == "xy")
		ModelViewer_Drag = MODELVIEW_DRAG_XY;
	else if (s == "z")
		ModelViewer_Drag = MODELVIEW_DRAG_Z;
	else
	{
		print("Model viewer drag tools: \n");
		print(" ^xyz 0/1^7 : free draging\n");
		print(" ^xy 0/1^7 : with z axis locked\n");
		print(" ^z 0/1^7 : only z\n");
		return;
	}
	e = ModelViewer_EntSelected;
	ModelViewer_DragOfs_x = vlen(EditLight_ViewOrigin - e.origin);
	ModelViewer_DragOfs_y = 0;
	ModelViewer_DragOfs_z = 0;
	ModelViewer_DragAngleOfs_x = 0;
	ModelViewer_DragAngleOfs_y = e.angles_y - EditLight_ViewAngles_y;
	ModelViewer_DragAngleOfs_z = 90;
}

// drop to floor selected model
command Cmd_ModelViewer_Droptofloor =
{
	entity e;
	
	// need something selected
	if (isnotentity(ModelViewer_EntSelected))
	{
		print("ModelViewer_Drop: nothing selected\n");
		return;
	}
	e = ModelViewer_EntSelected;
	tracebox(e.origin, e.mins, e.maxs, e.origin - '0 0 1000', MOVE_NORMAL, e);
	if (!trace_startsolid && trace_fraction < 1.0)
	{
		setorigin(e, trace_endpos);
		return;
	}
	print("ModelViewer_Drop: drop-to-floor failed!\n");
}

// remove selected model
command Cmd_ModelViewer_Remove =
{
	entity e;
	
	// need something selected
	if (isnotentity(ModelViewer_EntSelected))
	{
		print("ModelViewer_Remove: nothing selected\n");
		return;
	}
	// delete attachments
	for (e = findentity(world, tag_entity, ModelViewer_EntSelected); isentity(e); e = findentity(e, tag_entity, ModelViewer_EntSelected))
		remove(e);
	// delete model
	remove(ModelViewer_EntSelected);
	// unlock and unselect
	ModelViewer_EntSelectionLock = 0;
	ModelViewer_EntSelected = null_entity;
}

// clear scene (remove all models)
command Cmd_ModelViewer_Clear =
{
	entity e, e2;
	
	// clear all models
	for (e = find(world, classname, "mdl"); e; e = find(e, classname, "mdl"))
	{
		// delete attachments
		for (e2 = findentity(world, tag_entity, ModelViewer_EntSelected); isentity(e2); e2 = findentity(e2, tag_entity, ModelViewer_EntSelected))
			remove(e2);
		// delete model
		remove(e);
	}
	// unlock and unselect
	ModelViewer_EntSelectionLock = 0;
	ModelViewer_EntSelected = null_entity;
}

// model animator commands
command Cmd_ModelViewer_Animate =
{
	entity e;
	string s;
	
	cmdstr = argv(1);
	// need something selected?
	if ((cmdstr == "play" || cmdstr == "loop" || cmdstr == "stop") && isnotentity(ModelViewer_EntSelected))
	{
		print("ModelViewer_Animate: nothing selected\n");
		return;
	}
	e = ModelViewer_EntSelected;
	// need something animated?
	if ((cmdstr == "play" || cmdstr == "loop") && argv(2) == "" && e.netname == "")
	{
		print("ModelViewer_Animate: selected model not animated\n");
		return;
	}
	// start new animation
	if (cmdstr == "play" || cmdstr == "loop")
	{
		// replay current 
		if (argv(2) == "") // replay animation
		{
			e.drawtime = time;
			tokenize(e.netname);
			unzone(e.netname);
			if (cmdstr == "loop")
				e.netname = zone(strcat(argv(0), " ", argv(1), " ", argv(2), " 1"));
			else
				e.netname = zone(strcat(argv(0), " ", argv(1), " ", argv(2), " 0"));
			return;
		}
		// or start new
		if (cmdstr == "loop")
			s = strcat(argv(2), " ", argv(3), " ", argv(4), " 1");
		else
			s = strcat(argv(2), " ", argv(3), " ", argv(4), " 0");
		if (e.netname != "")
			unzone(e.netname);
		e.netname = zone(s);
		e.drawtime = time;
		return;
	}
	// stop animation
	if (cmdstr == "stop")
	{
		if (e.netname != "")
			unzone(e.netname);
		e.netname = "";
		return;
	}
	// print commands
	print("Model animator commands: \n");
	print(" ^3play start end rate^7 : set animation sequece and play it\n");
	print(" ^3play ^7 : just play animation (sequence should be set)\n");
	print(" ^3loop start end rate^7 : set animation sequece and play it looped\n");
	print(" ^3loop ^7 : just play looped animation (sequence should be set)\n");
	print(" ^3stop^7 : stop animation\n");
}

// edit current model
command Cmd_ModelViewer_Edit =
{
	entity e;
	
	cmdstr = argv(1);
	// need something selected?
	if (isnotentity(ModelViewer_EntSelected))
	{
		print("ModelViewer_Edit: nothing selected\n");
		return;
	}
	e = ModelViewer_EntSelected;
	// colormod
	if (cmdstr == "colormod")
	{
		// one component
		if (argv(3) == "")
		{
			e.colormod = vec(stof(argv(2)));
			return;
		}
		// three components
		e.colormod_x = stof(argv(2));
		e.colormod_y = stof(argv(3));
		e.colormod_z = stof(argv(4));
		return;
	}
	// avelocity
	if (cmdstr == "avelocity")
	{
		// one component
		if (argv(3) == "")
		{
			e.avelocity = vec(stof(argv(2)));
			return;
		}
		// three components
		e.avelocity_x = stof(argv(2));
		e.avelocity_y = stof(argv(3));
		e.avelocity_z = stof(argv(4));
		return;
	}
	// model
	if (cmdstr == "model")
	{
		setmodelindex(e, ModelViewer_Loadmodel(argv(2)));	
		if (e.scale)
			setsize(e, e.mins*e.scale, e.maxs*e.scale);
		return;
	}
	// scale
	if (cmdstr == "scale")
	{
		e.scale = stof(argv(2));	
		setmodelindex(e, e.modelindex);	
		if (e.scale)
			setsize(e, e.mins*e.scale, e.maxs*e.scale);
		return;
	}
	// frame
	if (cmdstr == "frame")
	{
		e.frame = stof(argv(2));	
		return;
	}
	// anglex
	if (cmdstr == "anglesx")
	{
		e.angles_x = stof(argv(2));	
		return;
	}
	// angley
	if (cmdstr == "anglesy")
	{
		e.angles_y = stof(argv(2));	
		return;
	}
	// anglez
	if (cmdstr == "anglesz")
	{
		e.angles_z = stof(argv(2));	
		return;
	}
	// skin
	if (cmdstr == "skin")
	{
		e.skin = stof(argv(2));		
		return;
	}
	// print commands 
	print("Model properties editing: \n");
	print("  ^3colormod g^7 : colormod (grayscale)\n");
	print("  ^3colormod r g b^7 : rgb colormod\n");
	print("  ^3model modelname^7 : change model\n");
	print("  ^3anglesx angle^7 : change pitch\n");
	print("  ^3anglesy angle^7 : change yaw\n");
	print("  ^3anglesz angle^7 : change roll\n");
}

void() EditLights_ModelViewer_Init =
{
	ModelViewer_Enabled = 0;
	ModelViewer_Drag = MODELVIEW_DRAG_NO;
	ModelViewer_Tool = MODELVIEW_TOOL_SELECT;
	ModelViewer_EntPreview = spawn();
	ModelViewer_EntPreview.drawmask = 0;
	ModelViewer_EntPreview.modelindex = ModelViewer_Index;
	ModelViewer_Model = zone("models/cube.mdl");
	ModelViewer_Tag = zone("");
	ModelViewer_TagOffset = '0 0 0';
	ModelViewer_TagAngles = '0 0 0';
	ModelViewer_Index = ModelViewer_Loadmodel(ModelViewer_Model);
	
	registercvar("r_modelview", "0");
	registercvar("r_modelview_model", ModelViewer_Model);
	registercvar("r_modelview_spawntype", ModelViewer_Tag);
	registercvar("r_modelview_spawndist", "256");
	registercvar("r_modelview_tag", ModelViewer_Tag);
	registercvar("r_modelview_tag_offsetx", ftos(ModelViewer_TagOffset_x));
	registercvar("r_modelview_tag_offsety", ftos(ModelViewer_TagOffset_y));
	registercvar("r_modelview_tag_offsetz", ftos(ModelViewer_TagOffset_z));
	registercvar("r_modelview_tag_anglesx", ftos(ModelViewer_TagAngles_x));
	registercvar("r_modelview_tag_anglesy", ftos(ModelViewer_TagAngles_y));
	registercvar("r_modelview_tag_anglesz", ftos(ModelViewer_TagAngles_z));
	registercvar("r_modelview_selected_model", "");
	
	RegisterCommand("r_modelview_spawn", Cmd_ModelViewer_Spawn, "spawn new model in cursor position");
	RegisterCommand("r_modelview_lock", Cmd_ModelViewer_Lock, "locks (or unlock) highlight on current entity");
	RegisterCommand("r_modelview_tool", Cmd_ModelViewer_Tool, "change tool interface");
	RegisterCommand("r_modelview_drag", Cmd_ModelViewer_Drag, "drag/drop selected model");
	RegisterCommand("r_modelview_droptofloor", Cmd_ModelViewer_Droptofloor, "drop to floor selected model");
	RegisterCommand("r_modelview_remove", Cmd_ModelViewer_Remove, "remove selected model");
	RegisterCommand("r_modelview_clear", Cmd_ModelViewer_Clear, "clear scene (remove all models)");
	RegisterCommand("r_modelview_animate", Cmd_ModelViewer_Animate, "model animator commands");
	RegisterCommand("r_modelview_edit", Cmd_ModelViewer_Edit, "edit model properties");
}

/*
================================================================================

  NEW LIGHT OPERATIONS

================================================================================
*/

// reloads menu
// void(float tParmCount)
command Cmd_Editlights_ReloadMenu =
{
	if (EditLights_Active)
	{
		EditLights_Stop();
		EditLights_Start();
		return;
	}
	EditLights_Start();
}	

// run lights editor
command Cmd_Editlights =
{
	if (EditLights_Active)
	{
		EditLights_Stop();
		return;
	}
	EditLights_Start();
}

command Cmd_Editlights_Edit2 =
{
	string tColor1, tColor2, tColor3, tColorCmd;
	vector tPos, tNewPos;
	float tCvar;

	cmdstr = argv(1);
	if (cmdstr == "movetocam")
		localcmd("r_editlights_edit origin ", ftos(EditLight_ViewOrigin_x), " ", ftos(EditLight_ViewOrigin_y), " ", ftos(EditLight_ViewOrigin_z), "\n");
	else if (cmdstr == "facecam")
	{
		makevectors(EditLight_ViewAngles);
		tPos = vectoangles(v_forward*NEGATIVE);
		if (tPos_x <= 90)
			tPos_x = 0-tPos_x;
		else
			tPos_x = 360-tPos_x;
		if (tPos_y > 180)
			tPos_y = 0 - (360 - tPos_y);
		localcmd("r_editlights_edit angles ", ftos(rint(tPos_x)), " ", ftos(rint(tPos_y)), " ", ftos(rint(tPos_z)), "\n");
	}
	else if (cmdstr == "facecamangles")
	{
		tPos = EditLight_ViewAngles;
		localcmd("r_editlights_edit angles ", ftos(rint(tPos_x)), " ", ftos(rint(tPos_y)), " ", ftos(rint(tPos_z)), "\n");
	}
	else if (cmdstr == "offset")
	{
		makevectors(EditLight_ViewAngles);
		tPos = v_forward*stof(argv(2)) + v_right*stof(argv(3)) + v_right*stof(argv(4));
		localcmd("r_editlights_edit move ", ftos(tPos_x), " ", ftos(tPos_y), " ", ftos(tPos_z), "\n");
	}
	else if (cmdstr == "offsetx")
	{
		makevectors(EditLight_ViewAngles);
		tPos = v_forward*stof(argv(2));
		localcmd("r_editlights_edit move ", ftos(tPos_x), " ", ftos(tPos_y), " ", ftos(tPos_z), "\n");
	}
	else if (cmdstr == "offsety")
	{
		makevectors(EditLight_ViewAngles);
		tPos = v_right*stof(argv(2));
		localcmd("r_editlights_edit move ", ftos(tPos_x), " ", ftos(tPos_y), " ", ftos(tPos_z), "\n");
	}
	else if (cmdstr == "offsetz")
	{
		makevectors(EditLight_ViewAngles);
		tPos = v_up*stof(argv(2));
		localcmd("r_editlights_edit move ", ftos(tPos_x), " ", ftos(tPos_y), " ", ftos(tPos_z), "\n");
	}
	else if (cmdstr == "color")
	{
		tColor1 = argv(2);
		if (substring(tColor1, 0, 1) != "*")
			tColorCmd = "color";
		else
		{
			tColorCmd = "colorscale";
			tColor1 = substring(tColor1, 1, 1000);
		}
		tColor2 = argv(3);
		tColor3 = argv(4);
		if (tColor2 == "")
			tColor2 = tColor1;
		if (tColor3 == "")
			tColor3 = tColor1;	
		localcmd(strcat("r_editlights_edit ", tColorCmd, " ", tColor1, " ", tColor2, " ", tColor3), "\n");
	}
	else if (cmdstr == "radius")
	{
		if (substring(argv(2), 0, 1) == "*")
			localcmd("r_editlights_edit radiusscale ", substring(argv(2),1,1000), "\n");
		else
			localcmd("r_editlights_edit radius ", argv(2), "\n");
	}
	else
	{
		print("Additional editlights commands: \n");
		print(" ^3movetocam^7 : move light to camera position\n");
		print(" ^3facecam^7 : turn light to camera position\n");
		print(" ^3facecamangles^7 : set light angles to camera angles\n");
		print(" ^3offset f r u^7 : move lights in camera space - forward, right and up\n");
		print(" ^3offsetx f^7 : move lights in camera space - forward\n");
		print(" ^3offsety r^7 : move lights in camera space - right\n");
		print(" ^3offsetz u^7 : move lights in camera space - up\n");
		print(" ^3color r g b^7 : like normal color command but supports * operator which makes colorscale\n");
		print(" ^3radius v^7 : like normal radius command but supports * operator which makes radiusscale\n");
	}
}

void() EditLightsInit =
{
	EditLights_ModelViewer_Init();
	// register cvars
	if (cvar_string("editlights_key_forward") == "")
		localcmd("seta editlights_key_forward \"e\"\n");
	if (cvar_string("editlights_key_back") == "")
		localcmd("seta editlights_key_back \"d\"\n");	
	if (cvar_string("editlights_key_moveleft") == "")
		localcmd("seta editlights_key_moveleft \"s\"\n");	
	if (cvar_string("editlights_key_moveright") == "")
		localcmd("seta editlights_key_moveright \"f\"\n");
	registercvar("r_editlights_cameraspeed", "400");
	// register commands
	RegisterCommand("editlights", Cmd_Editlights, "run new lights editor");
	RegisterCommand("editlights_restart", Cmd_Editlights_ReloadMenu, "restart editlights menu");
	RegisterCommand("r_editlights_edit2", Cmd_Editlights_Edit2, "new lights editor commands");
}

