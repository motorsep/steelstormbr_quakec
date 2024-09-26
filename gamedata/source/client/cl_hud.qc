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
void DrawWeaponBar(vector pos, string iconimgname, float rechargetime, float rechargetimetotal, float scooldownnew, float scooldowndur, float reverse, float hasweapon, float highlight) =
{
	local vector wepbarcolor, cooldownbarcolor, barofs, barimgsize, iconimgsize, barpos, iconpos;
	local string barimgname;
	local float baralpha;
	
	if(hasweapon)
		baralpha = 1;
	else
	{
		iconimgname = "gfx/hud/ico_weap_null.tga";
		baralpha = 0.1;
	}
	
	wepbarcolor = '0 0.75 0';
	cooldownbarcolor = '-1 -1 -1';		
	
	iconimgsize = drawgetimagesize(iconimgname);			
	barimgname = "gfx/hud/ico_chargebar_outline.tga";
	barimgsize = drawgetimagesize(barimgname);

	iconpos = barpos = pos;
	barpos_y += (iconimgsize_y - barimgsize_y)*0.5;	
	
	if(reverse)
		iconpos_x = pos_x + barimgsize_x;
	else
		barpos_x = pos_x + iconimgsize_x;
		
	drawpic(iconpos, iconimgname, iconimgsize, '1 1 1', baralpha, 0);		

	if(highlight)
	{
		iconimgname = "gfx/hud/ico_weap_highlight.tga";
		iconimgsize = drawgetimagesize(iconimgname);
		drawpic(iconpos, iconimgname, iconimgsize, '1 1 1', 1, 0);	
	}
	
	barofs = '12 13.5 0';
	DrawPercentBar(barpos+barofs, rechargetime, rechargetimetotal, wepbarcolor, '65.5 8 0', false, "", 1, true, reverse);	
	
	if(scooldowndur)
		DrawPercentBar(barpos+barofs, scooldownnew, scooldowndur, cooldownbarcolor, '66 8 0', false, "", 0.75, false, !reverse);	
	
	drawpic(barpos, barimgname, barimgsize, '1 1 1', baralpha, 0);
}

void DrawVerticalPercentageImage(vector pos, string imgname, vector imgsize, vector imgcolor, float percent, vector bboxpos, vector bboxsize) =
{
	local vector topleftvert, toprightvert, bottomrightvert, bottomleftvert, top_left, top_right, bottom_right, bottom_left;
	local float totalmarginsize, topmarginspace, bottommarginspace, marginpercent;

	//	drawfill(bboxpos, bboxsize, '0 0 0', 0.5, 0);

	if(imgcolor == '0 0 0')
		imgcolor = '1 1 1';
	
	topleftvert		= bboxpos; 									topleftvert_y += (bboxsize_y - bboxsize_y*percent);
	toprightvert 	= bboxpos;	toprightvert_x += bboxsize_x;	toprightvert_y += (bboxsize_y - bboxsize_y*percent);
	bottomrightvert = bboxpos + bboxsize;
	bottomleftvert 	= bboxpos; bottomleftvert_y += bboxsize_y;

	totalmarginsize = imgsize_y - bboxsize_y;
	topmarginspace = bboxpos_y - pos_y;
	bottommarginspace = totalmarginsize - topmarginspace;
	
	if(!topmarginspace || !totalmarginsize)
		marginpercent = 1;
	else
		marginpercent = topmarginspace/totalmarginsize;
	
	top_left_y = top_right_y = 0 + (1 - (bboxsize_y/imgsize_y))*marginpercent;
	top_right_x = 1;

	bottom_left_y = bottom_right_y = 1 - (1 - (bboxsize_y/imgsize_y))*marginpercent;
	bottom_right_x = 1;
	
	top_left_y = top_right_y = top_left_y + ((percent*(top_left_y-bottom_left_y)) - (top_left_y-bottom_left_y) );
	
	R_BeginPolygon(imgname, DRAWFLAG_NORMAL);
	R_PolygonVertex(topleftvert, top_left, imgcolor, 1);	
	R_PolygonVertex(toprightvert, top_right, imgcolor, 1);
	R_PolygonVertex(bottomrightvert, bottom_right, imgcolor, 1);
	R_PolygonVertex(bottomleftvert, bottom_left, imgcolor, 1);	
	R_EndPolygon();	
}

void DrawReticlePolygon(vector pos, float angyaw, string texturename, vector rgb, float ret_alpha) =
{
	local vector texturesize, top_left, top_right, org, ang;

	ang_y = input_angles_y;//angyaw;
	
	pos_z += 16;
	
	texturesize = drawgetimagesize(texturename);
	
//	ang_y += 90;
	ang_x = 0;
	makevectors(ang);
	
//	pos = pos + v_forward*texturesize_y*0.5;
	
//	v_forward_y = -v_forward_y;
//	v_right_y = -v_right_y;

	R_BeginPolygon(texturename, DRAWFLAG_NORMAL);
	R_PolygonVertex(pos+v_forward*texturesize_y*0.5+v_right*texturesize_x*-0.5, '0 0 0', rgb, ret_alpha);	
	R_PolygonVertex(pos+v_forward*texturesize_y*0.5+v_right*texturesize_x*0.5, '1 0 0', rgb, ret_alpha);
	R_PolygonVertex(pos+v_forward*texturesize_y*-0.5+v_right*texturesize_x*0.5, '1 1 0', rgb, ret_alpha);
	R_PolygonVertex(pos+v_forward*texturesize_y*-0.5+v_right*texturesize_x*-0.5, '0 1 0', rgb, ret_alpha);
	R_EndPolygon();	
}

.float	ret_wepepisode;
.float	ret_wep;
void DrawReticles(float items1, float items2, float secondaryweapon) =
{
	local vector pos, ang, vec, ofs, lineofs, newlineofs, imgsize, ret_color_base, ret_color, rgb, illusion_viewofs;
	local float cl_reticles, ret_alpha, e_skin, colorcoded, wep, nextwep, charge, charge_minigun, charge_storm, charge_energy, charge_missile, globalcooldown, chargefadetime, numepisode, wepepisode, retexists;
	local string imgname;
	local entity e, nexte;
	
	cl_reticles = cvar("cl_reticles");
	
	if(!cl_reticles || ESCMENU || !frametime)
		return;
	else
	if(cl_reticles == 1)
	{
		items1 = 1;
		items2 = 0;
	}

	charge_minigun = getstatf(32);
	charge_storm = getstatf(34);	
	charge_energy = getstatf(35);
	charge_missile = getstatf(36);
	globalcooldown = getstatf(50);
	
//	pos = project(player.origin);
	
	ang_y = input_angles_y;
	ang_x = 0;
//	ang_x = playercamera_pitch-90;
	
	makevectors(ang);
	
	pos_y = 0;
	pos_z = 0;
	
	colorcoded = cvar("cl_reticles_colorcoded");
	
	if(colorcoded)
		ret_color_base = '1 1 1';	
	else
		ret_color_base = stov(cvar_string("cl_reticles_color"));
		
	ret_alpha = cvar("cl_reticles_alpha");
	
	for(e = list_reticlechain; e; )
	{
		nexte = e.reticlechain;
	
		if(e.drawmask)
			e.drawmask = false;
		else
		{
			MobileEntChain_Remove(e);
			ReticleChain_Remove(e);
			remove(e);
		}
		
		e = nexte;
	}
	
	if(adminmode
	|| player.isdead)
		return;
	
	for(wep = numepisode = 1; numepisode <= EPISODE; wep = nextwep)
	{
		nextwep = wep*2;
		wepepisode = numepisode;
	
		if((wepepisode == 1 && wep == 128)
		|| (wepepisode == 2 && wep == 64))
		{
			numepisode++;
			nextwep = 1;
		}

		if((wepepisode == 1 && !items1 & wep)
		|| (wepepisode == 2 && !items2 & wep))
			continue;
		
		if(wepepisode == 1)
		switch(wep)
		{
			case WEP1_MINIGUN:			e_skin = 2;		ofs = '0 100 0';		charge = charge_minigun;	break;

			case WEP1_STORMPLOW:		e_skin = 1;		ofs = '0 100 0';		charge = charge_storm;		break;

			case WEP1_BEAMCANNON:		if(secondaryweapon != 1) continue;
										e_skin = 3;		ofs = '0 100 0';		charge = charge_energy;		break;
			
			case WEP1_ROCKETPOD:		if(secondaryweapon != 0) continue;
										e_skin = 0;	ofs = '0 30 0';	charge = charge_missile;	break;

			default:		continue;
		}

		if(wepepisode == 2)
		switch(wep)
		{
		//	case WEP2_STORMSPREAD:		imgname = "gfx/hud/ico_weap_sspread.tga";		ofs = '0 50 1200';	charge = charge_storm;		break;
			
			case WEP2_THUNDERBOLT:		if(secondaryweapon != 1) continue;	
										e_skin = 3;		ofs = '0 100 430';	charge = charge_energy;		break;
			
		//	case WEP2_HOMINGMISSILES:	if(secondaryweapon != 0) continue;
		//								imgname = "gfx/hud/ico_weap_hmissile.tga";		ofs = '0 50 500';	charge = charge_missile;	break;
			
			case WEP2_MIRVMORTAR:		if(secondaryweapon != 0) continue;
										e_skin = 0;	ofs = '0 30 1020';	charge = charge_missile;	break;

			case WEP2_FLACKGUN:			e_skin = 2;		ofs = '0 100 0';		charge = charge_minigun;	break;

			default:		continue;
		}
	
		if(!(wepepisode == 1 && wep == WEP1_MINIGUN))
		if(!(wepepisode == 2 && wep == WEP2_FLACKGUN))
		if(globalcooldown > charge)
			charge = globalcooldown;
	
		retexists = false;
		
		for(e = list_reticlechain; e; e = e.reticlechain)
		{
			if(e.ret_wepepisode == wepepisode)
			if(e.ret_wep == wep)
			{
				retexists = true;
				break;
			}
		}
		
		if(!retexists)
		{
			e = spawn();
			setmodel(e, "models/player/fps_reticle.dpm");
			e.skin = e_skin;
			e.effects = EF_NODEPTHTEST | EF_FULLBRIGHT;
			ReticleChain_Add(e);
			MobileEntChain_Add(e);
		}

		if(fpscam)
		{
			e.angles_x = 15;
			e.scale = 3;
		}
		else
		{
			e.angles_x = 0;
			e.scale = 3;
		}
		
		e.drawmask = MASK_NORMAL;
		
	//	if(!colorcoded)
	//		imgname = strcat(substring(imgname, 0, strlen(imgname)-4), "_w.tga");
		
		if(colorcoded)
		{
			if(e_skin == 0)
				ret_color = '1 0.404706 0.080000';
			else	
			if(e_skin == 1)
				ret_color = '0.510000 0.694471 1';
			else	
			if(e_skin == 2)
				ret_color = '1 0.705882 0';				
			else	
			if(e_skin == 3)
				ret_color = '0.680000 0.777882 1';
		}
		else
			ret_color = ret_color_base;
		
	//	imgsize = drawgetimagesize(imgname);
		
		if(!ofs_z)
			ofs_z = 1200;
		
	//	if(ofs_z)
	//	{
			makevectors(ang);
			vec = player.origin + v_forward*ofs_z;
		//	vec = project(vec);
		//	vec_z = 0;
	//	}
	//	else
	//		vec = pos;
		
		pos = project(player.origin);
		vec = project(vec);
	//	vec_z = 0;
		lineofs = vec - pos;
	
		if(vec_x < ofs_y || vec_x > vid_size_x-ofs_y)
		{
			vec_x = bound(ofs_y, vec_x, vid_size_x-ofs_y);
			newlineofs = vec - pos;
			newlineofs_y = (newlineofs_x/lineofs_x) * lineofs_y;
			vec = pos + newlineofs;
		}
		
		if(vec_y < ofs_y || vec_y > vid_size_y-ofs_y)
		{
			vec_y = bound(ofs_y, vec_y, vid_size_y-ofs_y);//max(vec_y, ofs_y);
			newlineofs = vec - pos;
			newlineofs_x = (newlineofs_y/lineofs_y) * lineofs_x;
			vec = pos + newlineofs;		
		}
	//	vec -= imgsize*0.5;
		
	//	drawfill(vec, '10 10 0', '1 1 1', 1, 0);
		
		vec = unproject(vec);
		vec_z = player.origin_z;
		
		if(charge <= time)
			rgb = ret_color;
		else
		{
			ret_color_x = 0;
			chargefadetime = 0.1;
			rgb = '1 0 0'*(min(chargefadetime, charge-time)/chargefadetime);
			rgb += ret_color*((chargefadetime - min(chargefadetime, charge-time))/chargefadetime);
		}
		
		setorigin(e, vec);
		e.angles_y = input_angles_y;//input_angles_y - playercamera_angle;
		e.colormod = rgb;
		e.alpha = ret_alpha;
	//	DrawReticlePolygon(vec, input_angles_y - playercamera_angle, imgname, rgb, ret_alpha);
	}
}

void DrawKillMultipleAnnouncement(float multiple, float alph) =
{
	local float translate;
	local vector pos;
	local string s, filename, str_doublekill, str_triplekill, str_quadkill, str_quinkill, str_maniac;
	
	translate = skiptranslation;
	skiptranslation = false;
	
	filename = __FUNC__;
	buf_localizemultiplekill = InitializeNonstandardTranslations(buf_localizemultiplekill, filename, false);
	
	str_doublekill		= Localize("DOUBLEKILL", buf_localizemultiplekill);
	str_triplekill		= Localize("TRIPLEKILL", buf_localizemultiplekill);
	str_quadkill		= Localize("QUADKILL", buf_localizemultiplekill);
	str_quinkill		= Localize("QUINKILL", buf_localizemultiplekill);
	str_maniac			= Localize("YOU'RE A MANIAC!", buf_localizemultiplekill);
	
	WriteNonstandardTranslations(buf_localizemultiplekill, filename, false, false);	
	
	skiptranslation = translate;
	
	switch(multiple)
	{
		case 2:		s = str_doublekill;		break;
		case 3:		s = str_triplekill;		break;
		case 4:		s = str_quadkill;		break;
		case 5:		s = str_quinkill;		break;
		default:	s = str_maniac;			break;		
	}

	drawfont = FONT_USER2;
	pos_x = (vid_size_x-stringwidth(s, 0, '30 25 0'))*0.5;
	pos_y = vid_size_y - 110;
	drawstring(pos, s, '30 25 0', '1 0 0', alph, 0);
}

void DrawPointText() =
{
	local float f, lastscoremultiplier, lastscorealpha;
	local vector ofs, pos, fontsize, angtoplayer;
	local entity e, nexte;
	local string s;
	
	drawfont = FONT_USER3;
	fontsize = '32 32 0';//*languagefontscale;
	
	e = list_pointtextchain;
	while(e)
	{
		nexte = e.pointtextchain;

		s = string_null;		
		f = (time - e.borntime)/5;
		
		if(f >= 1)
		{
			PointTextChain_Remove(e);
			SH_RemoveEnt(e);
		}
		else
		{
			if(e.origin == '0 0 0')
			{
				ofs_x = -12;
				ofs_y = -22 + f*-600;
				pos = scorepos+ofs;
			}
			else
			{
				if(playerviewsetting_fpscam)
				{
					angtoplayer = vectoangles(e.origin - player.origin);	
					if(AngleDifference(input_angles_y, angtoplayer_y) > 89)
					{
						e = nexte;
						continue;
					}
				}
				
				ofs = '0 0 0';			
				pos = project(e.origin);
				pos_x -= stringwidth(s, 0, fontsize)*0.5;
				pos_y -= fontsize_y*0.5;
			}

			pos_z = 0;				
				
			if(e.points)
				s = ftos(e.points);
			
			if(e.scoremultiplier > 1)
			{
				if(e.points)
				{
					lastscoremultiplier = e.scoremultiplier;
					lastscorealpha = 1-f;
				}
				s = strcat(s, "x", ftos(e.scoremultiplier));
			}

			drawstring(pos, s, fontsize, '0.46 0.62 0.75', 1-f, 0);
		}
		
		e = nexte;
	}
	
	if(lastscoremultiplier)
		DrawKillMultipleAnnouncement(lastscoremultiplier, lastscorealpha);	
}

void SpawnPointText(float pointsize, float multiplier, vector org) =
{
	local entity e, endlist;
	e = spawn();
	e.borntime = time;
	e.points = pointsize;
	e.scoremultiplier = multiplier;
	setorigin(e, org);
	
	for(endlist = list_pointtextchain; endlist.pointtextchain; endlist = endlist.pointtextchain)
	{}
	
	if(!endlist)
		list_pointtextchain = e;
	else
	{
		endlist.pointtextchain = e;
		e.pointtextchain_prev = endlist;
	}
}

void DrawElement_HudText(vector pos, string text, float font, vector fsize, vector titlefontcolor, float fontalpha, float fontflags, float width, float align) =
{
	drawfont = font;

	fsize = FitFontSizeToWidth(text, width, fsize);

	if(align == 1)
	{
		pos_x += 125 - 24;
		pos_x -= stringwidth(text, FALSE, fsize);
	}
	
	drawstring(pos, text, fsize, titlefontcolor, fontalpha, fontflags);
}

void DrawActiveTerminal() =
{
	if(!active_terminal)
	if(!LOCALIZE_GENERATING)
		return;
		
	local float translate;
	local vector barpos, barsize, fontsize;
	
	translate = skiptranslation;
	skiptranslation = false;
	
	drawfont = FONT_USER2;
	
	barpos = vid_size*0.5;
	
	barsize = '316 24 0';
	drawfill(barpos-barsize*0.5, barsize, '0.3 0.1 0.1', 0.8, 0);
	
	barsize = '300 16 0';
	DrawPercentBar(barpos-barsize*0.5, time - active_terminal.activation_starttime, active_terminal.object_activationtime, '1 0.2 0.2', barsize, false, "", 0.75, false, false);	
	
	local string filename, s, str_hacking, str_uploading, str_downloading, str_activating, str_deactivating;
	
	filename = __FUNC__;
	buf_localizeterminal = InitializeNonstandardTranslations(buf_localizeterminal, filename, false);
	str_hacking			= Localize("HACKING", buf_localizeterminal);
	str_uploading		= Localize("UPLOADING", buf_localizeterminal);
	str_downloading		= Localize("DOWNLOADING", buf_localizeterminal);
	str_activating		= Localize("ACTIVATING", buf_localizeterminal);
	str_deactivating	= Localize("DEACTIVATING", buf_localizeterminal);
	WriteNonstandardTranslations(buf_localizeterminal, filename, false, false);
	
	skiptranslation = translate;
	
	switch(active_terminal.terminaltype)
	{
		case TERMINAL_HACKING:			s = str_hacking;		break;
		case TERMINAL_UPLOADING:		s = str_uploading;		break;
		case TERMINAL_DOWNLOADING:		s = str_downloading;	break;
		case TERMINAL_ACTIVATING:		s = str_activating;		break;
		case TERMINAL_DEACTIVATING:		s = str_deactivating;	break;
	}	
	
	fontsize = '24 10 0';//*languagefontscale;
	barsize_x = stringwidth(s, false, fontsize);
	barsize_y = fontsize_y;

	drawstring(barpos - barsize*0.5-'0 24 0', s, fontsize, '1 0.8 0.8', 1, 0);	
	
//	BR();
//	BR();
	
//	BeginBottomButtons(2);
//	DrawElement_BottomButton("Quit", Quit, 0, 0, 0, 0, MBT_QUIT);	
//	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
//	EndBottomButtons();	
	
//	Menu_End();

}

void OpenTerminal() =
{
	local entity e;
	local float e_id;
	e_id = ReadLong();
	e = findfloat(world, id, e_id);
	if(!e)
		return;
	
	active_terminal = e;
	active_terminal.activation_starttime = time;
//	SetCurrentMenu(DrawActiveTerminal);
//	menu_terminal = currentmenu;
}

void CloseTerminal() =
{
	active_terminal = world;
	
/*	if(menu_terminal)
	{
		currentmenu = menu_terminal;
		CloseMenu();
	}*/
}

void DrawObjectives() =
{
	local vector pos, textblocksize;
	local entity e;
	local float count, buf, numprimaryobjectives, numsecondaryobjectives, indentsize, alph, translation;
	local string s, filename;
	
	filename = __FUNC__;	
	translation = skiptranslation;
	skiptranslation = false;
	
	buf_localizeobjectives = InitializeNonstandardTranslations(buf_localizeobjectives, filename, false);
	
	local string str_primaryobjectives, str_secondaryobjectives, str_complete;
	str_primaryobjectives	= Localize("PRIMARY OBJECTIVES", buf_localizeobjectives);
	str_secondaryobjectives	= Localize("SECONDARY OBJECTIVES", buf_localizeobjectives);
	str_complete			= Localize("(COMPLETE)", buf_localizeobjectives);

	WriteNonstandardTranslations(buf_localizeobjectives, filename, true, false);	
	
	skiptranslation = true;
	
	indentsize = 6;
	
	drawfont = FONT_USER2;
	title_fontcolor = '1 1 1';
	body_fontcolor = '0.46 0.62 0.75';
	body_fontsize = '8 8 0'*languagefontscale;
	body_fontalpha = 1;
	body_fontflags = 0;
	body_textalignment = '0 0 0';
	body_textbordersize = '0 0 0';
	option_size = body_fontsize;
	
	textblocksize_x = 120 - indentsize;
	
	for(e = list_objectivechain; e; e = e.objectivechain)
	{
	/*	if(e.borntime)
		if(e.borntime+5 > time)
		{
			alph = 0.7;
		
			if(time < e.borntime+0.5)
				alph = alph - ((e.borntime+0.5-time)/0.5)*0.5;
			else
			if(time > e.borntime+3)
				alph = ((e.borntime+5-time)/2)*0.7;
			
			s = "OBJECTIVE COMPLETE";
			pos_x = (vid_size_x-stringwidth(s, 0, '20 20 0'))*0.5;
			if(pos_y == 0)
				pos_y = 100;
			else
				pos_y += 30;
			drawstring(pos, s, '20 20 0', body_fontcolor, alph, body_fontflags);

			pos_y += 25;
			s = e.objectivetext;
			pos_x = (vid_size_x-stringwidth(s, 0, '20 20 0'))*0.5;
			drawstring(pos, s, '20 20 0', body_fontcolor, alph, body_fontflags);
		}*/
	
		if(e.objectivepriority == 0)
			numprimaryobjectives++;
		else
		if(e.objectivepriority == 1)
			numsecondaryobjectives++;	
	}
	
	if(!cvar("cl_hud_showobjectives"))
		return;
	
//	drawfont = FONT_USER1;
	pos_x = vid_size_x-120;	
	pos_y = 120;	
	option_pos = pos;	
	
	if(numprimaryobjectives || numsecondaryobjectives)
	{
		if(!objectiveblock)
			objectiveblock = spawn();
	}
	else
	if(objectiveblock)
	{
	//	ClearObjectiveBuffers(objectiveblock);
		SH_RemoveEnt(objectiveblock);
	}
	
	if(numprimaryobjectives)
	{
		drawstring(pos, str_primaryobjectives, body_fontsize, title_fontcolor, body_fontalpha, body_fontflags);
		pos_y += body_fontsize_y;
		
		for(e = list_objectivechain; e; e = e.objectivechain)
		{
			if(e.objectivepriority != 0)
				continue;
		
			drawstring(pos, "-", body_fontsize, body_fontcolor, body_fontalpha, body_fontflags);
			pos_x += indentsize;
		
			s = e.objectivetext[currentlanguage];
			if(e.istoggled)
				s = strcat(str_complete, SEP_SPACE, s);
			buf = objectiveblock.(buf_textblock_objectives_primary[count]);
			objectiveblock.(buf_textblock_objectives_primary[count]) = DrawTextBlock(buf, pos, -1, textblocksize, s, body_fontsize, body_fontcolor, body_fontalpha, body_fontflags);
			count++;
			
			pos_y = option_pos_y+5;
			pos_x -= indentsize;
		}
	}
	
	if(numsecondaryobjectives)
	{
		if(numprimaryobjectives)
			pos_y += body_fontsize_y;
	
		drawstring(pos, str_secondaryobjectives, body_fontsize, title_fontcolor, body_fontalpha, body_fontflags);
		pos_y += body_fontsize_y;
		
		for(e = list_objectivechain; e; e = e.objectivechain)
		{
			if(e.objectivepriority != 1)
				continue;
		
			drawstring(pos, "-", body_fontsize, body_fontcolor, body_fontalpha, body_fontflags);
			pos_x += indentsize;
		
			s = e.objectivetext[currentlanguage];
			if(e.istoggled)
				s = strcat(str_complete, SEP_SPACE, s);			
			buf = objectiveblock.(buf_textblock_objectives_secondary[count]);
			objectiveblock.(buf_textblock_objectives_secondary[count]) = DrawTextBlock(buf, pos, -1, textblocksize, s, body_fontsize, body_fontcolor, body_fontalpha, body_fontflags);
			count++;
			
			pos_y = option_pos_y+5;
			pos_x -= indentsize;
		}
	}		
	
	skiptranslation = translation;
}

string GetObjectName(float CLASS, float VARIANT) =
{
	local float translate;
	local string objname, filename, str_lightplasmaturret, str_heavybeamturret, str_rocketturret, str_repairturret, str_friendlylighttank, str_lighttank, str_mediumtank, str_heavyprotontank, str_heavyminiguntank, str_lightningtank, str_microflyer, str_carriertank, str_destroyertank, str_portal, str_incinerator, str_bunker, str_hangar, str_barracks, str_coolingtower, str_coolingtowertwin, str_obelisk, str_pylon, str_refinery, str_bboss, str_bbosssmall, str_tree, str_stone, str_crystal, str_bush, str_cactus, str_barrel, str_container, str_crate, str_fusioncorerack;

	translate = skiptranslation;
	skiptranslation = false;
	
	filename = __FUNC__;
	buf_localizeobjectnames = InitializeNonstandardTranslations(buf_localizeobjectnames, filename, false);
	
	str_lightplasmaturret	= Localize("Light Plasma Turret", buf_localizeobjectnames);
	str_heavybeamturret		= Localize("Beam Turret", buf_localizeobjectnames);
	str_rocketturret		= Localize("Rocket Turret", buf_localizeobjectnames);
	str_repairturret		= Localize("Repair Turret", buf_localizeobjectnames);
	str_friendlylighttank	= Localize("Modified Light Tank", buf_localizeobjectnames);
	str_lighttank			= Localize("Light Tank", buf_localizeobjectnames);
	str_mediumtank			= Localize("Medium Tank", buf_localizeobjectnames);
	str_heavyprotontank		= Localize("Heavy Proton Tank", buf_localizeobjectnames);
	str_heavyminiguntank	= Localize("Heavy Minigun Tank", buf_localizeobjectnames);
	str_lightningtank		= Localize("Lightning Tank", buf_localizeobjectnames);
	str_microflyer			= Localize("Micro Flyer", buf_localizeobjectnames);
	str_carriertank			= Localize("Carrier Tank", buf_localizeobjectnames);
	str_destroyertank		= Localize("Destroyer Tank", buf_localizeobjectnames);
	str_portal				= Localize("Portal", buf_localizeobjectnames);
	str_incinerator			= Localize("Incinerator", buf_localizeobjectnames);
	str_bunker				= Localize("Bunker", buf_localizeobjectnames);
	str_hangar				= Localize("Hangar", buf_localizeobjectnames);
	str_barracks			= Localize("Barracks", buf_localizeobjectnames);
	str_coolingtower		= Localize("Cooling Tower", buf_localizeobjectnames);
	str_coolingtowertwin	= Localize("Twin Cooling Tower", buf_localizeobjectnames);
	str_obelisk				= Localize("Obelisk", buf_localizeobjectnames);
	str_pylon				= Localize("Pylon", buf_localizeobjectnames);
	str_refinery			= Localize("Refinery", buf_localizeobjectnames);
	str_bboss				= Localize("Enemy Base", buf_localizeobjectnames);
	str_bbosssmall			= Localize("Small Enemy Base", buf_localizeobjectnames);
	str_tree				= Localize("Tree", buf_localizeobjectnames);
	str_stone				= Localize("Stone", buf_localizeobjectnames);
	str_crystal				= Localize("Crystal", buf_localizeobjectnames);
	str_bush				= Localize("Bush", buf_localizeobjectnames);
	str_cactus				= Localize("Cactus", buf_localizeobjectnames);
	str_barrel				= Localize("Barrel", buf_localizeobjectnames);
	str_container			= Localize("Container", buf_localizeobjectnames);
	str_crate				= Localize("Crate", buf_localizeobjectnames);
	str_fusioncorerack		= Localize("Fusion Core Rack", buf_localizeobjectnames);
	
	WriteNonstandardTranslations(buf_localizeobjectnames, filename, false, false);	
	
	skiptranslation = translate;
	
	switch(CLASS)
	{
		case OBJ_NPC:
			if(VARIANT == NPC_LIGHTPLASMATURRET)			objname = str_lightplasmaturret;
			else if(VARIANT == NPC_HEAVYBEAMTURRET)			objname = str_heavybeamturret;
			else if(VARIANT == NPC_ROCKETTURRET)			objname = str_rocketturret;
			else if(VARIANT == NPC_REPAIRTURRET)			objname = str_repairturret;
			else if(VARIANT == NPC_FRIENDLYLIGHTTANK)		objname = str_friendlylighttank;
			else if(VARIANT == NPC_LIGHTTANK)				objname = str_lighttank;
			else if(VARIANT == NPC_MEDIUMTANK)				objname = str_mediumtank;
			else if(VARIANT == NPC_HEAVYTANK_PROTON)		objname = str_heavyprotontank;
			else if(VARIANT == NPC_HEAVYTANK_MINIGUN)		objname = str_heavyminiguntank;
			else if(VARIANT == NPC_LIGHTNINGTANK)			objname = str_lightningtank;
			else if(VARIANT == NPC_MICROFLYER)				objname = str_microflyer;
			else if(VARIANT == NPC_CARRIERTANK)				objname = str_carriertank;
			else if(VARIANT == NPC_DESTROYERTANK)			objname = str_destroyertank;
			break;

		case OBJ_PORTAL:			objname = str_portal;		break;
			
		case OBJ_STRUCTURE:
			if(VARIANT == STRUCTURE_INCINERATOR)		objname = str_incinerator;
			else if(VARIANT == STRUCTURE_BUNKER)				objname = str_bunker;	
			else if(VARIANT == STRUCTURE_HANGAR)				objname = str_hangar;
			else if(VARIANT == STRUCTURE_BARRACKS)			objname = str_barracks;
			else if(VARIANT == STRUCTURE_COOLINGTOWER)		objname = str_coolingtower;
			else if(VARIANT == STRUCTURE_COOLINGTOWER_TWIN)	objname = str_coolingtowertwin;
			else if(VARIANT == STRUCTURE_OBELISK)			objname = str_obelisk;
			else if(VARIANT == STRUCTURE_PYLON)				objname = str_pylon;
			else if(VARIANT == STRUCTURE_REFINERY)			objname = str_refinery;
			else if(VARIANT == STRUCTURE_BBOSS)				objname = str_bboss;
			else if(VARIANT == STRUCTURE_BBOSS_SMALL)		objname = str_bbosssmall;
			break;
		
		case OBJ_TREE:				objname = str_tree;		break;
		case OBJ_STONE:				objname = str_stone;		break;
		case OBJ_ENVCRYSTAL:		objname = str_crystal;	break;

		case OBJ_PLANT:
			if(VARIANT >= 0 && VARIANT <= 3)	objname = str_bush;
			else if(VARIANT >= 4 && VARIANT <= 7)	objname = str_cactus;
			break;
		
		case OBJ_EQUIPMENT:			objname = str_barrel;		break;
		case OBJ_EQUIPMENT_MED:		objname = str_container;	break;
		case OBJ_EQUIPMENT_BIG:		objname = str_crate;		break;
		case OBJ_FUSIONCORERACK:	objname = str_fusioncorerack;	break;		
	}

	return objname;
}

void DrawTargetHealthBar() =
{
	local float targethealth, targethealth_max, targetclass, targetvariant;
	local vector pos, bsize;
	local string targetobjectname;

	targethealth = getstati(64);
	
	if(targethealth <= 0)
		return;

	if(targethealth != targethealth_old)
	{
		targethealth_old = targethealth;
		drawtargethealthtime = time+3;
	}
	
	if(drawtargethealthtime < time)
		return;

	targethealth_max = getstati(65);
	targetclass = getstati(66);
	targetvariant = getstati(67);
		
	targetobjectname = GetObjectName(targetclass, targetvariant);
	
	pos_x = (vid_size_x - 404)*0.5;
	pos_y = 20;
	
	bsize_x = stringwidth(targetobjectname, false, '13 13 0')+4;
	bsize_y = 14;
	
//	drawfill(pos, bsize, '0 0 0', 0.4, 0);	
	drawfont = FONT_USER1;
	drawstring(pos+'2 2 0', targetobjectname, '13 13 0', '1 1 1', 0.6, 0); // *languagefontscale 

	pos_y += 14;
	
	drawfill(pos, '404 14 0', '0 0 0', 0.3, 0);
	DrawPercentBar(pos+'2 2 0', targethealth, targethealth_max, '1 0 0', '400 10 0', false, "", 0.4, true, false);	
}

void DrawGlobalItems() =
{
	local float count, totalitems, numitems, globalitems_datakeys, globalitems_corruptfusioncores, slot_datakeys, slot_corruptfusioncores;
	local vector pos, imgsize, fontsize;
	local string img;
	
	globalitems_datakeys = getstati(80);
	globalitems_corruptfusioncores = getstati(81);
	drawfont = FONT_USER1;
	fontsize = '8 8 0'*languagefontscale;
	
	if(globalitems_datakeys)
	{
		totalitems++;
		slot_datakeys = totalitems;
	}

	if(globalitems_corruptfusioncores)
	{
		totalitems++;
		slot_corruptfusioncores = totalitems;
	}

	for(count = 0; count < totalitems; count++)
	{
		if(count+1 == slot_datakeys)
		{
			img = "gfx/hud/hud_ico_key.tga";
			imgsize = drawgetimagesize(img);
			numitems = globalitems_datakeys;
		}
		else
		if(count+1 == slot_corruptfusioncores)
		{
			img = "gfx/hud/hud_ico_fusion_core.tga";
			imgsize = drawgetimagesize(img);
			numitems = globalitems_corruptfusioncores;	
		}
	
		pos_x = vid_size_x*0.5 - imgsize_x*0.5;
		pos_y = vid_size_y - 120;
		
		pos_x -= (totalitems-1)*(imgsize_x+20)*0.5;
		pos_x += count*(imgsize_x+20);
		
		drawpic(pos, img, imgsize, '1 1 1', 0.7, 0);
		drawstring(pos+imgsize-fontsize, ftos(numitems), fontsize, '1 1 1', 1, 0);
	}
}

void DrawHudMissionStats() =
{
	local vector pos, scoreofs, fontsize, titlefontsize, fontcolor, titlefontcolor, startpos, imgsize;
	local float fontalpha, translation, width, titlefont, statfont;
	local string s, imgname, filename;
	
	filename = __FUNC__;	
	translation = skiptranslation;
	skiptranslation = false;
	
	buf_localizehudmissionstats = InitializeNonstandardTranslations(buf_localizehudmissionstats, filename, false);
	
	local string str_score, str_timebonus, str_timeleft, str_timetaken, str_frags, str_aikills, str_misckills;
	str_score		= Localize("SCORE", buf_localizehudmissionstats);
	str_timebonus	= Localize("TIME BONUS", buf_localizehudmissionstats);
	str_timeleft	= Localize("TIME LEFT", buf_localizehudmissionstats);
	str_timetaken	= Localize("TIME TAKEN", buf_localizehudmissionstats);
	str_frags		= Localize("FRAGS", buf_localizehudmissionstats);
	str_aikills		= Localize("AI KILLS", buf_localizehudmissionstats);
	str_misckills	= Localize("MISC KILLS", buf_localizehudmissionstats);

	WriteNonstandardTranslations(buf_localizehudmissionstats, filename, true, false);
	
	skiptranslation = true;
	
//	drawfont = FONT_USER1;
	fontcolor = '1 1 1';
//	titlefontcolor = '0.75 0.75 0.75';
	titlefontcolor = '0.2 1 1';
	titlefontsize = '14 14 0';//*languagefontscale;
	fontalpha = 0.8;	
	
	pos_x = vid_size_x*0.5 + 170;

	imgname = "gfx/hud/hud_stats_right.tga";
	imgsize = drawgetimagesize(imgname);
	pos_y = vid_size_y - imgsize_y;//80;	
	pos += '-12 0 0';	
	drawpic(pos, imgname, imgsize, '1 1 1', 0.65, 0);	
//	drawfill(pos, '195 79 0', '0 0 0', 0.4, 0);

	scoreofs = '-5 0 0';	
	
// POINTS
	fontsize = '22 22 0';//*languagefontscale;

//	points = getstati(STAT_POINTS);	
	
	if(player.points > points_old)
		SpawnPointText(player.points-points_old, player.scoremultiplier-scoremultiplier_old, '0 0 0');
	scoremultiplier_old = player.scoremultiplier;
	points_old = player.points;

	pos_x = vid_size_x*0.5 + 170;
	pos_y = vid_size_y - 80;
	scorepos = pos;	
	scorepos_y += titlefontsize_y - 6;	
	DrawPointText();		
	
	width = 175;
	titlefont = FONT_USER1;	
	statfont = FONT_USER3;
//	drawstring(pos, str_score, titlefontsize, titlefontcolor, fontalpha, 0);
	DrawElement_HudText(pos, str_score, titlefont, titlefontsize, titlefontcolor, fontalpha, 0, width, -1);
	pos = scorepos;
//	drawstring(pos+scoreofs, ftos(player.points), fontsize, fontcolor, fontalpha, 0);
	DrawElement_HudText(pos+scoreofs, ftos(player.points), statfont, fontsize, fontcolor, fontalpha, 0, width, -1);
	
	if(!timestopped)
	{
		pos_y += fontsize_y - 6;	
	//	drawstring(pos, str_timebonus, titlefontsize, titlefontcolor, fontalpha, 0);
		DrawElement_HudText(pos, str_timebonus, titlefont, titlefontsize, titlefontcolor, fontalpha, 0, width, -1);
		pos_y += titlefontsize_y - 6;
	//	drawstring(pos+scoreofs, ftos(ceil(player.points*max(0, (600-(time - maptime_current))/600))), fontsize, fontcolor, fontalpha, 0);
		DrawElement_HudText(pos+scoreofs, ftos(ceil(player.points*max(0, (600-(time-maptime_start))/600))), statfont, fontsize, fontcolor, fontalpha, 0, width, -1);
	}		
// END POINTS

// TIMER	
	if(!timestopped)
	{
		local float time_total, time_minutes, time_seconds;

		pos_y += fontsize_y - 6;	

		if(maptime_total)
		{
			DrawElement_HudText(pos, str_timeleft, titlefont, titlefontsize, titlefontcolor, fontalpha, 0, width, -1);
//			drawstring(pos, str_timeleft, titlefontsize, titlefontcolor, fontalpha, 0);	
			time_total = max(0, (maptime_start+maptime_total) - time);
		}
		else
		{
			DrawElement_HudText(pos, str_timetaken, titlefont, titlefontsize, titlefontcolor, fontalpha, 0, width, -1);
		//	drawstring(pos, str_timetaken, titlefontsize, titlefontcolor, fontalpha, 0);	
			time_total = time - maptime_start;
		}
		
		pos_y += titlefontsize_y - 6;
		
		time_minutes = floor(time_total/60);
		time_seconds = time_total - time_minutes*60;
			
		s = strcat(ftos(time_minutes), ":");
		s = strcat(s, TimeString_Seconds(ceil(time_seconds)));

	//	drawstring(pos+scoreofs, s, fontsize, fontcolor, fontalpha, 0);	
		DrawElement_HudText(pos+scoreofs, s, statfont, fontsize, fontcolor, fontalpha, 0, width, -1);
	}
// END TIMER		

	imgname = "gfx/hud/hud_stats_left.tga";
	imgsize = drawgetimagesize(imgname);
	pos_x = vid_size_x*0.5 - 170 - 120;
	pos_y = vid_size_y - imgsize_y;	
	pos += '-12 0 0';
	drawpic(pos, imgname, imgsize, '1 1 1', 0.65, 0);
//	drawfill(pos, '125 79 0', '0 0 0', 0.4, 0);

	scoreofs = '5 0 0';
	
// FRAGS

	//frags = getstati(STAT_FRAGS);
	//frags_npc = getstati(STAT_FRAGS_NPC);
	//frags_other = getstati(STAT_FRAGS_OTHER);
	width = 110;
	pos_x = vid_size_x*0.5 - 270;
	pos_y = vid_size_y - 80;
	if(GameMode_PlayerVSPlayer(gamemode))
	{
		DrawElement_HudText(pos, str_frags, titlefont, titlefontsize, titlefontcolor, fontalpha, 0, width, 1);
		pos_y += titlefontsize_y - 6;
		DrawElement_HudText(pos+scoreofs, ftos(player.frags), statfont, fontsize, fontcolor, fontalpha, 0, width, 1);
		pos_y += fontsize_y - 6;
	}
	
	if(GameMode_CanSpawnEnemies(gamemode))
	{
		DrawElement_HudText(pos, str_aikills, titlefont, titlefontsize, titlefontcolor, fontalpha, 0, width, 1);
		pos_y += titlefontsize_y - 6;
		DrawElement_HudText(pos+scoreofs, ftos(player.frags_npc), statfont, fontsize, fontcolor, fontalpha, 0, width, 1);
		pos_y += fontsize_y - 6;
	}	
	
	DrawElement_HudText(pos, str_misckills, titlefont, titlefontsize, titlefontcolor, fontalpha, 0, width, 1);
	pos_y += titlefontsize_y - 6;
	DrawElement_HudText(pos+scoreofs, ftos(player.frags_other), statfont, fontsize, fontcolor, fontalpha, 0, width, 1);	
	
// END FRAGS	

	
//	local vector mpos;
//	mpos = getmousepos();
//	drawfill(mpos, '10 10 0', '1 0 0', 1, 0);
//	drawstring(mpos+'20 0 0', vtos(mpos), '10 10 0', '1 1 1', 1, 0);

	skiptranslation = translation;
}

void DrawStats() =
{
	if(adminmode || showmissionmap)
		return;

	local float player_hittime_new, i, currenthealth, armor, lives, items1, items2, rechargetime_minigun, rechargetimetotal_minigun, rechargetime_energy, rechargetimetotal_energy, rechargetime_storm, rechargetimetotal_storm, rechargetime_shockwave, rechargetimetotal_shockwave, rechargetime_missile, rechargetimetotal_missile, scooldownnew, scooldowndur, globalcooldownnew, globalcooldowndur, fontalpha, columns, shieldbarspacing, count, columnwidth, percent, haswep_minigun, haswep_swave, haswep_storm, haswep_energy, haswep_missile, secondaryweapon;
	local vector pos, startpos, fontsize, fontcolor, hudsize, shieldbarsize, imgsize, imgcolor, base_imgcolor_armor, imgcolor_armor, imgcolor_shield, lastimgsize, bboxpos, bboxsize, wepbarspacing;
	local string s, bracket, imgname, imgname_minigun, imgname_energy, imgname_missile, imgname_storm;

	currenthealth = getstati(STAT_HEALTH);
	armor = getstati(STAT_ARMOR);
	lives = getstati(STAT_LIVES);
	items1 = getstati(STAT_ITEMS1);
	items2 = getstati(STAT_ITEMS2);
//	energyweapon = getstati(STAT_ENERGYWEAPON);	
//	missileweapon = getstati(STAT_MISSILEWEAPON);
		
	secondaryweapon = getstati(STAT_SECONDARYWEP);		
		
//	DrawReticles(items1, items2, secondaryweapon);		
		
//	if(targetobject_class || targetobject_variant)
		DrawTargetHealthBar();
		
	if(currenthealth_old)
	{
		if(currenthealth < currenthealth_old)
		{
			gainedarmortime = 0;
			player_hittime_new = (currenthealth_old - currenthealth)/5;
	
			if(time + player_hittime_new > player_hittime)
			{
				player_hittime_total = player_hittime_new;
				player_hittime = time+player_hittime_total;
			}
			else
			{
				player_hittime_total += player_hittime_new;
				player_hittime += player_hittime_new;
			}
		}
	//	if(lostarmortime)
	//	if(player_hittime)
	//	if(time <= player_hittime)
	//	if(!gainedarmortime)
	//	{
			base_imgcolor_armor = '1 0 0';
			if(player_hittime_total)
				base_imgcolor_armor += '0 1 1'*(1-((player_hittime-time)/player_hittime_total));	
			else
				base_imgcolor_armor = '1 1 1';
			
			local float maxcolor;
			maxcolor = currenthealth/100;
			base_imgcolor_armor_y = bound(0, base_imgcolor_armor_y, maxcolor);
			base_imgcolor_armor_z = bound(0, base_imgcolor_armor_z, maxcolor);
		//	if(imgcolor_armor == '1 1 1')
			if(player_hittime)
			if(time >= player_hittime)
			{
				player_hittime = 0;
				player_hittime_total = 0;
			}
	//	}	
	
		if(currenthealth > currenthealth_old)
		{
			SpawnArmorPickupEffect();
			gainedarmortime = time+3;
			player_hittime = 0;
			player_hittime_total = 0;
		//	lostarmortime = 0;
		}
		
		if(gainedarmortime)
		{
			imgcolor_armor = '0 1 0';
			imgcolor_armor += '1 0 1'*(1-((gainedarmortime - time)/3));
			imgcolor_armor_x = bound(0, imgcolor_armor_x, base_imgcolor_armor_x);
			imgcolor_armor_y = bound(0, imgcolor_armor_y, base_imgcolor_armor_y);
			imgcolor_armor_z = bound(0, imgcolor_armor_z, base_imgcolor_armor_z);
			if(time >= gainedarmortime)
				gainedarmortime = 0;
		}
		else
			imgcolor_armor = base_imgcolor_armor;

		if(armor < shield_old) // shield pickup
		{
			gainedshieldtime = 0;	
			lostshieldtime = time+1;
		//	player_hittime = time+0.25;
		}
		
		if(lostshieldtime)
		{
			imgcolor_shield = '1 0 0';
			imgcolor_shield += '0 1 1'*(1-((lostshieldtime - time)/1));
			if(time >= lostshieldtime)
				lostshieldtime = 0;
		}	
	
		if(armor > shield_old) // shield pickup
		{
			SpawnShieldPickupEffect();
			gainedshieldtime = time+3;	
			lostshieldtime = 0;
		}
		
		if(gainedshieldtime)
		{
			imgcolor_shield = '0 1 0';
			imgcolor_shield += '1 0 1'*(1-((gainedshieldtime - time)/3));
			if(time >= gainedshieldtime)
				gainedshieldtime = 0;
		}
		
		if(imgcolor_shield == '0 0 0')
			imgcolor_shield = '1 1 1';
		
	}
	currenthealth_old = currenthealth;	
	shield_old = armor;
	
	rechargetime_minigun = getstatf(32);
	rechargetime_shockwave = getstatf(33);	
	rechargetime_storm = getstatf(34);	
	rechargetime_energy = getstatf(35);
	rechargetime_missile = getstatf(36);
	
//	rechargetime_minigun = getstatf(32);
//	rechargetime_shockwave = getstatf(33);	
//	rechargetime_storm = getstatf(34);	
//	rechargetimetotal_energy = getstatf(45);
//	rechargetimetotal_missile = getstatf(46);	
	
//	rechargetime_thunderbolt = getstatf(35);	

	globalcooldownnew = getstatf(50);
//	scooldownnew = getstatf(51);
	
//	if(globalcooldownnew > scooldownnew)
//		scooldownnew = globalcooldownnew;

	if(globalcooldownend != globalcooldownnew)
		globalcooldownstart = time;
	
//	if(scooldownend != scooldownnew)
//		scooldownstart = time;
	
	globalcooldownend = globalcooldownnew;
//	scooldownend = scooldownnew;
	globalcooldowndur = globalcooldownend - globalcooldownstart;
	globalcooldownnew = bound(0, (globalcooldownend - time), globalcooldowndur);	
//	scooldowndur = scooldownend - scooldownstart;
//	scooldownnew = bound(0, scooldownend-time, scooldowndur);
	
	DrawHudMissionStats();

//ARMOR
	if(armor)
	{
		imgname = "gfx/hud/ico_shield_drain_bar.tga";
		imgsize = drawgetimagesize(imgname);		

		pos_x = 2;
		pos_y = vid_size_y - imgsize_y - 2;
		
		percent = (armor - ((ceil(armor/100)*100)-100)) / 100;
		bboxpos_x = pos_x;
		bboxpos_y = pos_y + 0;
		bboxsize_x = imgsize_x;
		bboxsize_y = imgsize_y - 0;
		DrawVerticalPercentageImage(pos, imgname, imgsize, imgcolor_shield, percent, bboxpos, bboxsize);				
	}

	imgname = "gfx/hud/ico_ship_armor.tga";
	imgsize = drawgetimagesize(imgname);

	pos_x = 12;
	pos_y = vid_size_y - imgsize_y - 2;//*0.5;	
	
	if(armor)
	{
		imgname = strcat("gfx/hud/ico_ship_shield", ftos(ceil(armor/100)));//.tga";
		imgname = strcat(imgname, "_halo.tga");
		imgsize = drawgetimagesize(imgname);
		drawpic(pos, imgname, imgsize, '1 1 1', 1, 0);
	}
	
	imgname = "gfx/hud/ico_ship_armor.tga";
	imgsize = drawgetimagesize(imgname);
	percent = currenthealth/100;
	bboxpos_x = pos_x;
	bboxpos_y = pos_y + 26;
	bboxsize_x = imgsize_x;
	bboxsize_y = 35;
	DrawVerticalPercentageImage(pos, imgname, imgsize, imgcolor_armor, percent, bboxpos, bboxsize);
	
	imgname = "gfx/hud/ico_ship_armor_outline.tga";
	imgsize = drawgetimagesize(imgname);
	drawpic(pos, imgname, imgsize, '1 1 1', 1, 0);		

//SHIELDS	
	for(count = 0; count <= 3; count++)
	{
		if(armor > count*100)
		{
			imgname = strcat("gfx/hud/ico_ship_shield", ftos(count+1));
			imgname = strcat(imgname, ".tga");
			imgsize = drawgetimagesize(imgname);				
		
			if(gainedshieldtime > time && armor == (count+1)*100)
				imgcolor = imgcolor_shield;
			else
				imgcolor = '1 1 1';
		
			drawpic(pos, imgname, imgsize, imgcolor, bound(0, armor-count*100, 100)/100, 0);	
		}				
	}		

// WEAPONS

	if(items1 & WEP1_MINIGUN || items2 & WEP2_FLACKGUN)
	{
		if(items1 & WEP1_MINIGUN)
		{
			imgname_minigun = GetItemIcon(1, WEP1_MINIGUN);
			rechargetimetotal_minigun = 0.1;
		}
		else
		if(items2 & WEP2_FLACKGUN)
		{
			imgname_minigun = GetItemIcon(2, WEP2_FLACKGUN);
			rechargetimetotal_minigun = 0.3;
		}
		
		haswep_minigun = true;
	}

	if(items2 & WEP2_SHOCKWAVE)
	{
		rechargetimetotal_shockwave = 4;
		haswep_swave = true;
	}
		
	if(items1 & WEP1_STORMPLOW || items2 & WEP2_STORMSPREAD || items2 & WEP2_STORMSHIELD)
	{
		if(items1 & WEP1_STORMPLOW)
		{
			imgname_storm = GetItemIcon(1, WEP1_STORMPLOW);
			rechargetimetotal_storm = 0.125;	
		}
		else
		if(items2 & WEP2_STORMSPREAD)
		{
			imgname_storm = GetItemIcon(2, WEP2_STORMSPREAD);
			rechargetimetotal_storm = 0.3;
		}
		else
		if(items2 & WEP2_STORMSHIELD)
		{
			imgname_storm = GetItemIcon(2, WEP2_STORMSHIELD);
			rechargetimetotal_storm = 0.3;	
		}
	
		haswep_storm = true;
	}
		
	if(items1 & WEP1_BEAMCANNON || items2 & WEP2_THUNDERBOLT)
	{
		if(items1 & WEP1_BEAMCANNON)
		{
			imgname_energy = GetItemIcon(1, WEP1_BEAMCANNON);
			if(!rechargetimetotal_energy)
				rechargetimetotal_energy = 2;	
		}
		else
		if(items2 & WEP2_THUNDERBOLT)
		{
			imgname_energy = GetItemIcon(2, WEP2_THUNDERBOLT);
			if(!rechargetimetotal_energy)
				rechargetimetotal_energy = 3;	
		}		

		haswep_energy = true;
	}
	
	if(items1 & WEP1_ROCKETPOD || items2 & WEP2_HOMINGMISSILES || items2 & WEP2_MIRVMORTAR)
	{
		if(items1 & WEP1_ROCKETPOD)
		{
			imgname_missile = GetItemIcon(1, WEP1_ROCKETPOD);
			if(!rechargetimetotal_missile)
				rechargetimetotal_missile = 2;
		}
		else
		if(items2 & WEP2_HOMINGMISSILES)
		{
			imgname_missile = GetItemIcon(2, WEP2_HOMINGMISSILES);
			if(!rechargetimetotal_missile)
				rechargetimetotal_missile = 1;
		}
		else
		if(items2 & WEP2_MIRVMORTAR)
		{
			imgname_missile = GetItemIcon(2, WEP2_MIRVMORTAR);
			if(!rechargetimetotal_missile)
				rechargetimetotal_missile = 3;
		}		
		
		haswep_missile = true;
	}
	
	rechargetime_minigun = bound(0, rechargetimetotal_minigun - (rechargetime_minigun - time), rechargetimetotal_minigun);
	rechargetime_shockwave = bound(0, rechargetimetotal_shockwave - (rechargetime_shockwave - time), rechargetimetotal_shockwave);		
	rechargetime_storm = bound(0, rechargetimetotal_storm - (rechargetime_storm - time), rechargetimetotal_storm);	
	rechargetime_energy = bound(0, rechargetimetotal_energy - (rechargetime_energy - time), rechargetimetotal_energy);
	rechargetime_missile = bound(0, rechargetimetotal_missile - (rechargetime_missile - time), rechargetimetotal_missile);	

//	if(missileweapon == WEP_MIRVMORTAR)
/*	if(reticle_mirv)
	if(rechargetime_missile >= 3)
		reticle_mirv.colormod = '0 1 0';
	else
		reticle_mirv.colormod = '1 0 0';		*/
	
	wepbarspacing = '50 25 0';
	imgsize = drawgetimagesize("gfx/hud/ico_weap_minigun.tga");
	columnwidth = imgsize_x;
	imgsize = drawgetimagesize("gfx/hud/ico_chargebar_outline.tga");
	columnwidth += imgsize_x;

	pos_x = (vid_size_x - wepbarspacing_x)*0.5 - columnwidth;
//	pos_y += 100;
	startpos = pos;

	DrawWeaponBar(pos, imgname_minigun, rechargetime_minigun, rechargetimetotal_minigun, 0, 0, false, haswep_minigun, false);
	pos_y += wepbarspacing_y;	
	DrawWeaponBar(pos, imgname_missile, rechargetime_missile, rechargetimetotal_missile, globalcooldownnew, globalcooldowndur, false, haswep_missile, secondaryweapon == 0);			
	pos_y += wepbarspacing_y;
	DrawWeaponBar(pos, GetItemIcon(2, WEP2_SHOCKWAVE), rechargetime_shockwave, 4, globalcooldownnew, globalcooldowndur, false, haswep_swave, false);

	
	pos_x += columnwidth + wepbarspacing_x;
	pos_y = startpos_y;

	DrawWeaponBar(pos, imgname_storm, rechargetime_storm, rechargetimetotal_storm, globalcooldownnew, globalcooldowndur, true, haswep_storm, false);
	pos_y += wepbarspacing_y;	
	DrawWeaponBar(pos, imgname_energy, rechargetime_energy, rechargetimetotal_energy, globalcooldownnew, globalcooldowndur, true, haswep_energy, secondaryweapon == 1);
//	pos_y += wepbarspacing_y;
//	DrawWeaponBar(pos, "gfx/hud/ico_weap_thunder.tga", rechargetime_beam, 5, scooldownnew, scooldowndur, true);	
//	pos_y += wepbarspacing_y;

// LIVES
	imgname = "gfx/hud/ico_ship_life.tga";
	imgsize = drawgetimagesize(imgname);
	pos_x = vid_size_x - imgsize_x - 10;
	pos_y = vid_size_y - imgsize_y - 10;//startpos_y + 10;
	for(count = 0; count < lives; count++)
	{
		drawpic(pos, imgname, imgsize, '1 1 1', 1, 0);	
		pos_y -= imgsize_y + 5;
	}
	
	if(list_teamchain)
	{
		local entity e_team;
		local string teamname, s_points;
		local vector rgb, ofs;
	
		drawfont = FONT_MENU;

		pos_x = vid_size_x-120;	
		pos_y = 10;//120;		
		ofs = '0 0 0';
		
		for(e_team = list_teamchain; e_team; e_team = e_team.teamchain)
		{
			teamname = GetTeamName(e_team.team);
			rgb = GetTeamColor(e_team.team);
			
			s_points = ftos(e_team.points);
			if(floor(e_team.points) != e_team.points)
				s_points = substring(s_points, 0, strlen(ftos(floor(e_team.points)))+2);
			
			ofs_x = stringwidth(teamname, false, '20 20 0')*-1;
			drawstring(pos+ofs, teamname, '20 20 0', rgb, 1, 0);
			ofs_x = stringwidth(s_points, false, '20 20 0')*-1;
			drawstring(pos+ofs+'0 25 0', s_points, '20 20 0', rgb, 1, 0);
			pos_y += 60;
		}
	}		
	
	DrawObjectives();
}

void DrawNameTags() =
{
	local float drawdist, inview, height, dist, frame_current;
	local vector diff, pos, fontsize, angtoplayer, pos_start, imgsize;
	local entity e;
	local string imgname;
	
	fontsize = '12 12 0'*languagefontscale;
	drawdist = 1600;
	drawfont = FONT_USER2;
	
	for(e = list_playerchain; e; e = e.playerchain)
	{
		if(e == player || !e.drawmask)
			continue;

		inview = false;			
		if(playerviewsetting_fpscam)
		{
			angtoplayer = vectoangles(e.origin - player.origin);	
			if(AngleDifference(input_angles_y, angtoplayer_y) <= 89)
				inview = true;
		}

		diff = e.origin - player.origin;			
		if(diff*diff < drawdist*drawdist)
		if(!playerviewsetting_fpscam || inview)
		{
			pos = project(e.origin+'0 0 128');
			pos_start = pos;
			pos_x -= stringwidth(e.netname, 0, fontsize)*0.5;
			pos_y -= fontsize_y*0.5;
			
/*			if(playerviewsetting_fpscam)
			{
				dist = vlen(diff);
				height = 160 * (1-(dist/2000));
				pos_y -= height;
			}*/
			if(!playerviewsetting_fpscam)
				pos_y -= 16;
			
			pos_z = 0;
			drawstring(pos, e.netname, fontsize, GetTeamColor(e.team), 1, 0);	

			if(e.buttonchat)
			{
				frame_current = GetFrameForTime(2, 0.5);
				imgname = strcat("gfx/hud/ico_waiting_frame", ftos(frame_current+1), ".tga");
				imgsize = drawgetimagesize(imgname)*0.8;
				pos_x = pos_start_x;
				pos -= imgsize*0.5;
				pos_y -= fontsize_y + 8;
				drawpic(pos, imgname, imgsize, '1 1 1', 0.35, 0);
			}
		}
	}
}

void DrawPainFrame() =
{
	if(!player.hashealth)
		return;	

	local float currenthealth, minalpha, hitalpha;
	local vector pos;
	
	if(player_hittime_total)
		hitalpha = (player_hittime - time)/player_hittime_total;

	currenthealth = getstati(STAT_HEALTH);	
	minalpha = (1-(currenthealth/100))*0.75;
	hitalpha = bound(minalpha, hitalpha, 1);

	if(hitalpha)
	if(vid_size_x == 800)
		drawpic('0 0 0', "gfx/hud/hud_pain_frame43.tga", vid_size, '1 1 1', hitalpha, 0);
	else
	{
		pos_x = vid_size_x - 479;
		pos_y = 0;
	
		drawpic('0 0 0', "gfx/hud/hud_pain_frame169_left.tga", '479 600 0', '1 1 1', hitalpha, 0);
		drawpic(pos, "gfx/hud/hud_pain_frame169_right.tga", '479 600 0', '1 1 1', hitalpha, 0);
	}
}

void DrawHud() =
{
	local entity menu;

//	if(cl_button == K_MOUSE1)
	if(GameControl(CTRL_MENUBUTTON1, 0))
		arrowkeymovement = FALSE;	
	
	if(!DRAWMOUSE_FORCEHIDE)
	if(currentmenu && !DRAWMOUSE)
	{
		DRAWMOUSE = true;
		setwantsmousemove(true);
	}
	else
	if(!currentmenu && DRAWMOUSE)
	{
		DRAWMOUSE = false;
		setwantsmousemove(false);	
	}
	
//	CheckToClearPullDownMenu();
	
//	for(count = menu_count; count > 0; count--)
//	{
/*		menu = list_menuchain;//findfloat(world, draworder, count);
		while(menu)
		{
			if(menu.mflags & MF_HIDDEN)
			{
				ClearMenuValues(menu);
				continue;
			}
		
			if(!(menu != currentmenu && menu.m_appearance & HIDE_ALPHA && menu.m_hidealpha == 0))
			{
				active_menu = menu;
				menu.DrawMenu();
			}
			
			menu = menu.menuchain;
		}*/
//	}	

	DrawMenus();

/*	if(focusnewmenu)
		FocusWindow(focusnewmenu);
	else
	if(nextfocusmenu)
		FocusWindow(nextfocusmenu);*
		
	focusnewmenu = world;
	nextfocusmenu = world;*/

	active_menu = world;

	if(currentmenu)//SHOWHUD_ADMINTOOLS)
	{
	/*	if(!cl_menutype)
		{
			Hud_AdminTools();	

			if(!currentmenu)
			if(cl_button == KEY_ESC)
				SetCurrentMenu(Draw_EditorExitConfirmation);
		}
		else
		{*/
			if(GameControl(CTRL_ESCAPE, 0))
		//	if(currentmenu != menu_missionedior)
		//	if(currentmenu != menu_generateminimap)
			{
				if(IsAssignedFunction(currentmenu.ESCFunc))
				{
				//	cl_button = 0; // don't close new windows
					currentmenu.ESCFunc();
				}
				else
					CloseMenu();
			//	cl_button = 0;	// CL_BUTTONTEST
			
				MenuSound(SOUND_CANCELCLICK);
			}
	//	}
	}
}