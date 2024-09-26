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
float radarzoom;
float minimapmode;
float mwidth;
float	mapoverlay_alpha		 = 0.75;

/*void CloseMissionMapMenu() =	{	showmissionmap = false;		}

void Draw_MissionMapMenu() =
{
	local vector radarsize;
	local float mapbufferspace;

	mapbufferspace = 32;
	radarsize_y = vid_size_y;
	radarsize_x = (radarsize_y/3)*4 - mapbufferspace;
	radarsize_y -= mapbufferspace;
	radarsize += border_size;

	Menu_Start_MissionMap("MAP", radarsize);
	
	Menu_End();
}*/

void DrawCompassDirection(vector pos, string char, vector dir, float dist) =
{
	local vector fontsize, charsize;	
	
	drawfont = FONT_USER1;
	if(showmissionmap)
		fontsize = '20 20 0';//*languagefontscale;
	else
		fontsize = '10 10 0'*languagefontscale;
	charsize_y = fontsize_y;	
	
	charsize_x = stringwidth(char, false, fontsize);
	pos += dir*dist - charsize*0.5;
	drawstring(pos, char, fontsize, '1 1 1', 1, 0);	
}

vector ConvertToRadarCoords(vector org, vector playercoords, vector radarpos) =
{
	local vector ang;
	
	org_z = playercoords_z;
	ang = vectoangles(org - playercoords);
	
	ang_y = ang_y*-1;

	if(!showmissionmap)
		ang_y+=playercamera_angle - 90;
	
	makevectors(ang);
	org = radarpos+v_forward*vlen(org-playercoords)*radarzoom;

	return org;
}

void DrawTeleporterMapConnection(entity e, vector playerradarcoords, vector radarpos) =
{
	local entity a;
	local vector posa, pose;
	
	for(a = list_radarchain; a; a = a.radarchain)
	{
		if(a.maptargetid == e.id)
		if(a.activated || a.mapicon || !GameMode_HideTeleporters(gamemode))
		{	
			posa = ConvertToRadarCoords(a.origin, playerradarcoords, radarpos);
			pose = ConvertToRadarCoords(e.origin, playerradarcoords, radarpos);
			drawline(1, posa, pose, '0.9725 0.7697 0.19607', 0.8, 0);
		}
	}
}

void DrawMapIcon(vector pos, entity e, vector blipcolor, vector playerradarcoords, vector radarpos) =
{
	local string icon, icon_blink, text;
	local vector iconimgsize, e_blipsize, ang, topleftvert, toprightvert, bottomrightvert, bottomleftvert, rgb, fontsize;
	local float imgalpha, imgscale, blink_animate, pulse;
	
	e_blipsize_x = e_blipsize_y = e.blipsize;
	imgalpha = 1;
	imgscale = 1;
	
	rgb = '1 1 1';
	
	if(e.class == CLASS_PLAYER)
	{
		if(showmissionmap)
			text = e.netname;
		else
			imgscale = 0.5;
	
		ang_y = e.angles_y;
		icon = "gfx/map/ico_map_player.tga";
		rgb = GetTeamColor(e.team);
	}
	else
	if(e.objclass == OBJ_SPAWNPAD)
	{
		icon = "gfx/map/ico_map_player_start.tga";
		rgb = GetTeamColor(e.variant);
	}
	else
	if(e.objclass == OBJ_STRUCTURE && e.variant == STRUCTURE_OBELISK)
	{
		if(!showmissionmap)
			imgscale = 0.5;
		pulse = true;
		icon = "gfx/map/ico_map_obelisk.tga";
	}
	else
	if(e.objclass == OBJ_EXITPAD)
	{
		pulse = true;
		icon = "gfx/map/ico_map_objective.tga";
	}
	else
	if(e.objclass == OBJ_TELEPORTER && (e.activated || e.mapicon || !GameMode_HideTeleporters(gamemode)))
	{
		if(!showmissionmap)
			imgscale = 0.5;
		icon = "gfx/map/ico_map_teleport.tga";
		DrawTeleporterMapConnection(e, playerradarcoords, radarpos);
	}
	else	
	if(e.objclass == OBJ_FORCEFIELD && (e.activated || e.mapicon))//e.istoggled)
	{
		if(!showmissionmap)
			imgscale = 0.75;
	
		pulse = true;
		if(e.istoggled)
		{
			if(e.isnewobject)
				icon = "gfx/map/ico_map_ffield_last_opened.tga";
			else
				icon = "gfx/map/ico_map_ffield.tga";
		}
		else
		{
			if(e.isnewobject)
				icon = "gfx/map/ico_map_ffield_last_closed.tga";
			else
				icon = "gfx/map/ico_map_ffield_on.tga";		
		}
	}		
	else
	if(e.objclass == OBJ_FLAG)
	{
		if(!showmissionmap)
			imgscale = 0.5;	
	
		pulse = true;
		if(e.variant == 1)
			icon = "gfx/map/ico_map_ctf_red_flag.tga";
		else
			icon = "gfx/map/ico_map_ctf_blue_flag.tga";
	}
	else
	if(e.objclass == OBJ_FLAGBASE)
	{
		if(!showmissionmap)
			imgscale = 0.5;
	
		pulse = true;
		if(e.variant == 1)
			icon = "gfx/map/ico_map_ctf_red_base.tga";
		else
			icon = "gfx/map/ico_map_ctf_blue_base.tga";
	}
	else
	if(e.mapicon)
	{
		if(e.objclass == OBJ_PRESSUREPLATE)
		{
			if(!showmissionmap)
				imgscale = 0.5;
		
			pulse = true;
			icon = "gfx/map/ico_map_pplate.tga";
		}
		else
		if(e.objclass == OBJ_NPC)
		{
			if(!showmissionmap)
				imgscale = 0.5;
				
			icon = "gfx/map/ico_map_enemy.tga";
		}
		else
		if(e.objclass == OBJ_STRUCTURE)
		{
			if(!showmissionmap)
				imgscale = 0.5;
		//	pulse = true;
			if(e.variant == STRUCTURE_BARRACKS)
				icon = "gfx/map/ico_map_building_barracks.tga";
			else
			if(e.variant == STRUCTURE_BUNKER)
				icon = "gfx/map/ico_map_building_bunker.tga";
			else
			if(e.variant == STRUCTURE_INCINERATOR)
				icon = "gfx/map/ico_map_building_incinerator.tga";
			else
			if(e.variant == STRUCTURE_COOLINGTOWER)
				icon = "gfx/map/ico_map_cooling1.tga";
			else
			if(e.variant == STRUCTURE_COOLINGTOWER_TWIN)
				icon = "gfx/map/ico_map_cooling2.tga";
			else
			if(e.variant == STRUCTURE_HANGAR)
				icon = "gfx/map/ico_map_building_hangar.tga";
			else
			if(e.variant == STRUCTURE_PYLON)
			{
				if(e.istoggled)
					icon = "gfx/map/ico_map_pylon_no_shield.tga";
				else
					icon = "gfx/map/ico_map_pylon_shield.tga";
			}			
			else
			if(e.variant == STRUCTURE_BBOSS)
				icon = "gfx/map/ico_map_bboss.tga";
			else
			if(e.variant == STRUCTURE_BBOSS_SMALL)
				icon = "gfx/map/ico_map_bboss_small.tga";
			else
			if(e.variant == STRUCTURE_GASPUMP)
				icon = "gfx/map/ico_map_big_pump.tga";
			else
			if(e.variant == STRUCTURE_EVAPORATOR)
			{
				if(e.istoggled)
					icon = "gfx/map/ico_map_evaporator_off.tga";
				else
					icon = "gfx/map/ico_map_evaporator_on.tga";
			}
			else
			if(e.variant == STRUCTURE_REFINERY)
			{
				if(e.istoggled)
					icon = "gfx/map/ico_map_refinery_off.tga";
				else
					icon = "gfx/map/ico_map_refinery_on.tga";				
			}
			else
				icon = "gfx/map/ico_map_building.tga";	
		}
		else
/*		if(e.objclass == OBJ_FORCEFIELD)
		{
			pulse = true;
			if(e.isnewobject)
				icon = "gfx/map/ico_map_ffield_last_closed.tga";
			else
				icon = "gfx/map/ico_map_ffield_on.tga";
		}
		else*/
		if(e.objclass == OBJ_EQUIPMENT_MED)
		{
			if(!showmissionmap)
				imgscale = 0.5;
			pulse = true;
			if(e.variant == 0)
				icon = "gfx/map/ico_map_container02.tga";
			else
			if(e.variant == 1)
				icon = "gfx/map/ico_map_container03.tga";
		}
		else
		if(e.objclass == OBJ_EQUIPMENT_BIG)
		{
			if(!showmissionmap)
				imgscale = 0.5;
		
			pulse = true;
			icon = "gfx/map/ico_map_container01.tga";
		}
		else
		if(e.objclass == OBJ_FUSIONCORERACK)
		{
			if(!showmissionmap)
				imgscale = 0.5;
		
			pulse = true;
			icon = "gfx/map/ico_map_fusion_rack.tga";
		}
		else
		if(e.objclass == OBJ_TERMINAL)
		{
			if(!showmissionmap)
				imgscale = 0.35;
			else
				imgscale = 0.5;
		
			pulse = true;
			if(e.variant == 0)
				icon = "gfx/map/ico_map_terminal.tga";
			else
			if(e.variant == 1)
				icon = "gfx/map/ico_map_terminal_small.tga";
		}
		else
		{
			pulse = true;
			icon = "gfx/map/ico_map_objective.tga";
		}
	}
	
	if(blink_animate)
	if(floor(time+0.5)*0.5 != floor(floor(time+0.5)*0.5))
		icon = icon_blink;
	
	if(pulse)
	if(floor(time)*0.5 == floor(floor(time)*0.5))
		imgalpha = (time - floor(time))*0.5 + 0.5;
	else
		imgalpha = 1 - (time - floor(time))*0.5;
	
	if(strlen(icon))
	{
		iconimgsize = drawgetimagesize(icon);
		iconimgsize = iconimgsize*imgscale;
		
		if(ang != '0 0 0')
		{
			ang_y = ang_y*-1 + 180;
		
			if(!showmissionmap)
				ang_y+=playercamera_angle-90;
		
			makevectors(ang);
			topleftvert		= pos + ((v_forward*-1)*iconimgsize_y + (v_right*-1)*iconimgsize_x)*0.5;
			toprightvert 	= pos + ((v_forward*-1)*iconimgsize_y + (v_right)*iconimgsize_x)*0.5;
			bottomrightvert = pos + ((v_forward)*iconimgsize_y + (v_right)*iconimgsize_x)*0.5;
			bottomleftvert 	= pos + ((v_forward)*iconimgsize_y + (v_right*-1)*iconimgsize_x)*0.5;

			R_BeginPolygon(icon, DRAWFLAG_NORMAL);
			R_PolygonVertex(topleftvert, '0 0 0', rgb, imgalpha);	
			R_PolygonVertex(toprightvert, '1 0 0', rgb, imgalpha);
			R_PolygonVertex(bottomrightvert, '1 1 0', rgb, imgalpha);
			R_PolygonVertex(bottomleftvert, '0 1 0', rgb, imgalpha);	
			R_EndPolygon();				
		}
		else
			drawpic(pos - iconimgsize*0.5, icon, iconimgsize, rgb, imgalpha, 0);
	}
	else
		drawfill(pos-e_blipsize*0.5, e_blipsize, blipcolor, imgalpha, 0);	
		
	if(text)
	{
		drawfont = FONT_USER2;
		text = substring(text, 0, 12);
		fontsize = '10 10 0'*languagefontscale;
		pos_x -= stringwidth(text, 0, fontsize)*0.5;
		pos_y -= fontsize_y*0.5;
		pos_y -= 10;
		pos_z = 0;
		drawstring(pos, text, fontsize, '1 1 1', 1, 0);	
	}
}

vector SetRadarVertDist(vector mapimgsize) =
{
	local vector disttovert;
	disttovert = mapimgsize * mwidth * radarzoom;
	return disttovert;
}

void DrawMapKey(vector pos) =
{		
	local string icon;
	local vector keysize, col2, fontisze, fsize, bordersize;
	local float linespacing, translate, col2width;		
	
	drawfont = FONT_USER2;	
	
	fontisze = '8 9 0'*languagefontscale;
	keysize = '140 134 0';
	col2 = '22 0 0';
	bordersize = '4 4 0';
	col2width = keysize_x - col2_x - bordersize_x*2;
	linespacing = 16;		
	
	pos -= keysize;
	drawfill(pos, keysize, '0 0 0', 0.5, 0);
	
	local string filename, str_obelisk, str_ffopennew, str_ffclosednew, str_ffopen, str_ffclosed, str_teleporter, str_spawnpad, str_exitgate;
	translate = skiptranslation;
	skiptranslation = false;	
	filename = __FUNC__;
	buf_localizemapkey = InitializeNonstandardTranslations(buf_localizemapkey, filename, false);
	str_obelisk			= Localize("Obelisk (waypoint)", buf_localizemapkey);
	str_ffopennew		= Localize("Open Forcefield (new)", buf_localizemapkey);
	str_ffclosednew		= Localize("Closed Forcefield (new)", buf_localizemapkey);
	str_ffopen			= Localize("Open Forcefield", buf_localizemapkey);
	str_ffclosed		= Localize("Closed Forcefield", buf_localizemapkey);
	str_teleporter		= Localize("Teleporter", buf_localizemapkey);
	str_spawnpad		= Localize("Spawn Pad", buf_localizemapkey);
	str_exitgate		= Localize("Exit Gate", buf_localizemapkey);	
	WriteNonstandardTranslations(buf_localizemapkey, filename, false, false);
	skiptranslation = translate;
	
	pos += bordersize;	
	icon = "gfx/map/ico_map_obelisk.tga";
	drawpic(pos, icon, drawgetimagesize(icon)*0.5, '1 1 1', 1, 0);
	fsize = FitFontSizeToWidth(str_obelisk, col2width, fontisze);
	drawstring(pos+col2, str_obelisk, fsize, '1 1 1', 1, 0);		
	
	pos_y += linespacing;		
	icon = "gfx/map/ico_map_ffield_last_opened.tga";
	drawpic(pos, icon, drawgetimagesize(icon)*0.75, '1 1 1', 1, 0);
	fsize = FitFontSizeToWidth(str_ffopennew, col2width, fontisze);	
	drawstring(pos+col2, str_ffopennew, fsize, '1 1 1', 1, 0);

	pos_y += linespacing;
	icon = "gfx/map/ico_map_ffield_last_closed.tga";
	drawpic(pos, icon, drawgetimagesize(icon)*0.75, '1 1 1', 1, 0);
	fsize = FitFontSizeToWidth(str_ffclosednew, col2width, fontisze);		
	drawstring(pos+col2, str_ffclosednew, fsize, '1 1 1', 1, 0);	
	
	pos_y += linespacing;
	icon = "gfx/map/ico_map_ffield.tga";
	drawpic(pos, icon, drawgetimagesize(icon)*0.75, '1 1 1', 1, 0);
	fsize = FitFontSizeToWidth(str_ffopen, col2width, fontisze);		
	drawstring(pos+col2, str_ffopen, fsize, '1 1 1', 1, 0);	
	
	pos_y += linespacing;
	icon = "gfx/map/ico_map_ffield_on.tga";
	drawpic(pos, icon, drawgetimagesize(icon)*0.75, '1 1 1', 1, 0);
	fsize = FitFontSizeToWidth(str_ffclosed, col2width, fontisze);		
	drawstring(pos+col2, str_ffclosed, fsize, '1 1 1', 1, 0);			
	
	pos_y += linespacing;
	icon = "gfx/map/ico_map_teleport.tga";
	drawpic(pos, icon, drawgetimagesize(icon)*0.5, '1 1 1', 1, 0);
	fsize = FitFontSizeToWidth(str_teleporter, col2width, fontisze);		
	drawstring(pos+col2, str_teleporter, fsize, '1 1 1', 1, 0);		
	
	pos_y += linespacing;
	icon = "gfx/map/ico_map_player_start.tga";
	drawpic(pos, icon, drawgetimagesize(icon)*1, '1 1 1', 1, 0);
	fsize = FitFontSizeToWidth(str_spawnpad, col2width, fontisze);		
	drawstring(pos+col2, str_spawnpad, fsize, '1 1 1', 1, 0);		
	
	pos_y += linespacing;
	icon = "gfx/map/ico_map_objective.tga";
	drawpic(pos, icon, drawgetimagesize(icon)*1, '1 1 1', 1, 0);
	fsize = FitFontSizeToWidth(str_exitgate, col2width, fontisze);		
	drawstring(pos+col2, str_exitgate, fsize, '1 1 1', 1, 0);		
}

void DrawRadar() =
{
	if(GameControl(CTRL_TOGGLEMISSIONMAP, -1))
	if(!(currentmenu.menu_style & STYLE_PRIORITY))
	{
		showmissionmap = !showmissionmap;
/*		if(!showmissionmap)
		{
			showmissionmap = true;
			SetCurrentMenu(Draw_MissionMapMenu);
			currentmenu.CloseMenuFunc = CloseMissionMapMenu;
			menu_missionmap = currentmenu;
		}
		else
		if(currentmenu == menu_missionmap)
			CloseMenu();*/
	}

	if(adminmode)
	if(!showmissionmap)
		return;

	local entity e;
	local vector diff, ang, pos, radarpos, playercoords, playerradarcoords, radarsize, e_blipsize, blipcolor, pos_start, pos_end, origionalstart, e_org, mapimgsize, mapimgpos, imgconsize, maxiconsize;
	local float count, mapbufferspace, mapalpha;
	local string mapimgname;

	if(showmissionmap)
		mapalpha = mapoverlay_alpha;
	else
		mapalpha = 1;
		
	maxiconsize = '20 20 0';
	
//	if(!radarzoom)
		radarzoom = 0.02;//*(30000/mapwidth);

	playercoords = player.origin;
	playercoords_z = 0;
	
	if(showmissionmap)
	{
		mapbufferspace = 32;
		playerradarcoords = '0 0 0';
		radarsize_y = vid_size_y - mapbufferspace;
		radarsize_x = (radarsize_y/3)*4;// - mapbufferspace;
	//	radarsize_y -= mapbufferspace;
		radarpos = vid_size*0.5;
	}
	else
	{
		playerradarcoords = playercoords;
		radarsize = '100 100 0';
		radarpos_x = vid_size_x - radarsize_x*0.5;
		radarpos_y = radarsize_x*0.5;
		radarpos += '-4 4 0';	
		drawfill(radarpos-radarsize*0.5 - '2 2 0', radarsize + '4 4 0', '0 0 0', 1, 0);
	}
	
//	if(mapimageexists)
//	{
		mapimgname = substring(mapname, 0, strlen(mapname)-3);
		mapimgname = strcat(mapimgname, "tga");
		mapimgsize = drawgetimagesize(mapimgname);
		mapimgsize = GetConSizeForResolution(mapimgsize);
		
		if(!mwidth)
		{
			mwidth = 5.455734;
			mwidth = ((640/mapimgsize_x)*mwidth*mapwidth)/10000;
		}
			
//		if(cl_buttondown[K_SHIFT])
//		{
/*			if(cl_button == K_MWHEELUP)
				mwidth -= 0.1;
			else
			if(cl_button == K_MWHEELDOWN)
				mwidth += 0.1;		
				
			print(ftos((mwidth/(mapwidth*(640/mapimgsize_x)))*10000));
			print(" : base mwidth setting.\n");
			
			print(ftos(mapwidth));print("mapwidth\n");*/
/*		}
		else
		{		
			if(cl_button == K_MWHEELUP)
				radarzoom += 0.005;
			else
			if(cl_button == K_MWHEELDOWN)
				radarzoom -= 0.005;
				
			radarzoom = bound(0.02, radarzoom, 0.075);
		}		*/

		local vector topleftvert, toprightvert, bottomrightvert, bottomleftvert, disttovert;

		disttovert = SetRadarVertDist(mapimgsize);
		
		if(showmissionmap)
		{
			mapimgpos = ConvertToRadarCoords('0 0 0', '0 0 0', radarpos);
		
			radarzoom = radarzoom * (radarsize_x/(disttovert_x*2));
			disttovert = SetRadarVertDist(mapimgsize);
						
			if(disttovert_y > radarsize_y)
			{
				radarzoom = radarzoom * (radarsize_y/(disttovert_y*2));
				disttovert = SetRadarVertDist(mapimgsize);
			}
						
			ang_y = 90;
		}
		else
		{
			mapimgpos = ConvertToRadarCoords('0 0 0', playercoords, radarpos);
			ang_y = playercamera_angle;
		}
		
		makevectors(ang);
		
		topleftvert		= mapimgpos + (v_forward*-1)*disttovert_y + (v_right*-1)*disttovert_x;
		toprightvert 	= mapimgpos + (v_forward*-1)*disttovert_y + (v_right)*disttovert_x;
		bottomrightvert = mapimgpos + (v_forward)*disttovert_y + (v_right)*disttovert_x;
		bottomleftvert 	= mapimgpos + (v_forward)*disttovert_y + (v_right*-1)*disttovert_x;
		
		mapimgpos = radarpos-radarsize*0.5;
		drawsetcliparea(mapimgpos_x, mapimgpos_y, radarsize_x, radarsize_y);
		
		R_BeginPolygon(mapimgname, DRAWFLAG_NORMAL);
		R_PolygonVertex(topleftvert, '0 0 0', '1 1 1', mapalpha);	
		R_PolygonVertex(toprightvert, '1 0 0', '1 1 1', mapalpha);
		R_PolygonVertex(bottomrightvert, '1 1 0', '1 1 1', mapalpha);
		R_PolygonVertex(bottomleftvert, '0 1 0', '1 1 1', mapalpha);	
		R_EndPolygon();	
//	}
	
/*	for(count = 0; count <= 360; count+=6)
	{
		ang_y = count;
		makevectors(ang);
	
		traceline(playercoords, playercoords+v_forward*2000, TRUE, player);
	
		pos_end = ConvertToRadarCoords(trace_endpos, playercoords, radarpos);
	
		drawline(8, radarpos, pos_end, '0.1 0.1 0.1', 1, 0);	
	}*/
	
	for(e = list_radarchain; e; e = e.radarchain)
	{
		if(e.owner != e)
			e_org = e.owner.origin;
		else
			e_org = e.origin;
		e_org_z = 0;
		e_blipsize_x = e_blipsize_y = e.blipsize;
		
	//	if(e.drawmask)
	//	if(!IsAttachedAIClass(e.npcclass))// != NPC_TURRET)
		diff = playercoords - e_org;
		if(!e.ismapobject
		|| (e.class == CLASS_PLAYER
			&& ((GameMode_HasTeams(gamemode) && e.team != player.team)
			|| (GameMode_NoFriendlyPlayers(gamemode) && e != player))))
		if(!e.mapicon)
		if(diff*diff > 2450*2450)
			continue;
		
		if(e.class == CLASS_PLAYER && e.team == player.team)
			blipcolor = '0 1 0';
	/*	else
		if (e.class == CLASS_SHOT)
			blipcolor = '1 1 0';*/
		else
			blipcolor = '1 0 0';
	
/*		if(e.class == CLASS_SHOT && e.shotclass == CLASS_BULLET)
		{
			for(count = 0; count < 2; count++)
			{
				origionalstart = e.(org_start[count]);
				if(origionalstart == '0 0 0')//is npc minigun (single shot)
					break;
					
				pos_end = e.(org_end[count]);
				pos_start = origionalstart + normalize(pos_end - origionalstart)*((time-e.borntime)*12000);
				
				if(!vlen(origionalstart - pos_start) > vlen(origionalstart - pos_end))
				{
					pos_start = ConvertToRadarCoords(pos_start, playerradarcoords, radarpos);
					drawfill(pos_start-e_blipsize*0.5, e_blipsize, blipcolor, 1, 0);						
				}
			}			
		}
		else
		if(e.class == CLASS_SHOT && e.shotclass != CLASS_PROJECTILE)
		{
			pos_start = ConvertToRadarCoords(e.org_start, playerradarcoords, radarpos);
			ang_y = e.owner.angles_y;
			makevectors(ang);
			pos_end = ConvertToRadarCoords(e.org_start+v_forward*e.shotlen, playerradarcoords, radarpos);
			drawline(2, pos_start, pos_end, blipcolor, 1, 0);
		}
		else
		{*/
			if(e == player && adminmode)
				pos = ConvertToRadarCoords(admincamera_ofs, playerradarcoords, radarpos);
			else
				pos = ConvertToRadarCoords(e_org, playerradarcoords, radarpos);

			if(!(!showmissionmap && !IsInsideBox(pos, radarpos-radarsize*0.5-maxiconsize*0.5, radarsize+maxiconsize)))
				DrawMapIcon(pos, e, blipcolor, playerradarcoords, radarpos);
	//	}
	}
	
	makevectors(ang);	
	DrawCompassDirection(radarpos, "N", v_forward*-1, radarsize_y*0.45);
	DrawCompassDirection(radarpos, "S", v_forward, radarsize_y*0.45);
	DrawCompassDirection(radarpos, "E", v_right, radarsize_x*0.45);
	DrawCompassDirection(radarpos, "W", v_right*-1, radarsize_x*0.45);
	
	drawresetcliparea();

	border_size					= '12 13 0';
	border_appearance			= IMAGE;
	border_imagecolor			= '1 1 1';
	border_imagealpha			= mapalpha;
	border_imageflags			= DRAWFLAG_ADDITIVE;	
	
	if(showmissionmap)
	{
		Menu_Borders(radarpos-radarsize*0.5-border_size*0.8, radarsize+border_size*1.6);	
	
		pos_x = radarpos_x + radarsize_x*0.5;
		pos_y = radarpos_y + radarsize_y*0.5;

		DrawMapKey(pos);
	}
}