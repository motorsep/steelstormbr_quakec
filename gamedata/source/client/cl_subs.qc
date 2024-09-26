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
void PacifyCompiler_CSQC() =
{
	local entity e;
	e = spawn();
		e.cellconnection_id = e.cellconnection_id;
		e.scrollbar_pos = e.scrollbar_pos;
		e.scrollbar_handlesize = e.scrollbar_handlesize;
		e.scrollbar_size = e.scrollbar_size;
		e.scrollbar_ofs = e.scrollbar_ofs;
		e.scrollbar_height = e.scrollbar_height;
		e.renderflags = e.renderflags;
		e.message = e.message;
	remove(e);
	
	intermission = intermission;
	sb_showscores = sb_showscores;
	dmg_take = dmg_take;
	dmg_save = dmg_save;
	dmg_origin = dmg_origin;
	
	e = NULL;
	vid_res = vid_res;
}

vector unproject(vector vec) =
{
	return cs_unproject(vec);

//	vec_x = (vec_x-vid_size_x*0.5)*vid_res_x/vid_size_x;
//	vec_y = (vec_y-vid_size_y*0.5)*vid_res_y/vid_size_y;	
	
/*	vec_x = vec_x/vid_size_x*vid_res_x;
	vec_y = vec_y/vid_size_y*vid_res_y;	
	
	vec = cs_unproject(vec);
	return vec;*/
}

vector project(vector vec) =
{
	return cs_project(vec);

/*	vec = cs_project(vec);
	vec_x = vec_x*vid_size_x/vid_res_x;
	vec_y = vec_y*vid_size_y/vid_res_y;
//	vec = vid_size*0.5 + vec;
	vec_z = 0;	
	return vec;*/
}

void ClearFreedEnts() = // in case an administrator removes an entity while you're manipulating or interacting with it
{
	if(wasfreed(hover_ent))
		hover_ent = world;
	
//	if(wasfreed(interactionent))
//		CloseMenu();
	
//	if(wasfreed(drawentinfo))
//	{	
//		print("Warning: entity drawentinfo was freed.\n");
//		drawentinfo = world;
//	}
	
//	if(wasfreed(pulldown_ent))
//		Clear_PullDownMenu();
		
//	if(wasfreed(admin_editingent))
//		CloseAdminInputMenu();
	
	if(wasfreed(marker))
		marker = world;

	if(wasfreed(movingent))
		movingent = world;
}

float GetNewEntID() =
{
	local entity e;
	local float count, newentid;
	
	for(count = -1; !newentid; count-=1)
	{
		e = findfloat(world, entid, count);
		if(!e)
			newentid = count;
	}
	
	return newentid;
}

float IsWaitingForServerResponse(float WFSR_FLAG) =
{
	if(waitingforserverresponse != WFSR_FLAG)
		return false;
		
	waitingforserverresponse = false;
	return true;
}

void DrawPolygonBeam(vector start, vector end, string imgname, vector rgb, float mode) =
{
	// modes
	// 0 = normal
	// 1 = pulsing
	// 2 = low alpha

	local vector topleftvert, toprightvert, bottomrightvert, bottomleftvert, imgsize, top_left, top_right;
	local float alph;
	
	if(mode == 2)
		alph = 0.25;
	else
		alph = 0.5;
	
	if(mode == 1)
	{
		if(floor(time)*0.5 == floor(floor(time)*0.5))
			alph = time - floor(time);
		else
			alph = 1 - (time - floor(time));
		alph = alph*0.75+0.25;
	}
	
	imgsize = drawgetimagesize(imgname);	
	
	top_left_y = top_right_y = 1- vlen(start-end) / imgsize_y;
	top_right_x = 1;	
	
	makevectors(vectoangles(end - start));
	topleftvert = end+v_right*imgsize_x*-0.5;
	toprightvert = end+v_right*imgsize_x*0.5;
	bottomleftvert = start+v_right*imgsize_x*-0.5;
	bottomrightvert = start+v_right*imgsize_x*0.5;
	
//	print("top_left: "); print(vtos(top_left));print("\n");
//	print("top_right: ");	print(vtos(top_right));print("\n");
//	print("rgb: "); print(vtos(rgb));print("\n");
	
	R_BeginPolygon(imgname, DRAWFLAG_ADDITIVE);
	R_PolygonVertex(topleftvert, top_left, rgb, alph);	
	R_PolygonVertex(toprightvert, top_right, rgb, alph);
	R_PolygonVertex(bottomrightvert, '1 1 0', rgb, alph);
	R_PolygonVertex(bottomleftvert, '0 1 0', rgb, alph);	
	R_EndPolygon();	
	
/*	topleftvert = cs_project(topleftvert);
	topleftvert_z = 0;
	drawfill(topleftvert, '5 5 0', '1 1 1', 1, 0);
	toprightvert = cs_project(toprightvert);
	toprightvert_z = 0;
	drawfill(toprightvert, '5 5 0', '1 1 1', 1, 0);
	bottomleftvert = cs_project(bottomleftvert);
	bottomleftvert_z = 0;
	drawfill(bottomleftvert, '5 5 0', '1 1 1', 1, 0);
	bottomrightvert = cs_project(bottomrightvert);
	bottomrightvert_z = 0;
	drawfill(bottomrightvert, '5 5 0', '1 1 1', 1, 0);	
	
	drawstring(bottomrightvert, imgname, '6 6 0', '0 1 0', 1, 0);*/
}

void MakeObjectInvisibleToClients(entity e) =	{	e.drawmask = false;	}

void PlaySoundLoop(entity thinker, entity soundent, float CHAN, string soundname, void() func) =
{
	sound(soundent, CHAN, soundname, 1, ATTN_NORM);
	thinker.nextthink = time+soundlength(soundname);
	thinker.think = func;
}

void PlayBGMusic(string trackname) =
{
	local string s;
	s = strcat("cd loop ", trackname);
	s = strcat(s, "\n");
	localcmd(s);
}