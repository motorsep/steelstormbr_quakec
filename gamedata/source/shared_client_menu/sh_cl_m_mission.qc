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
string GetItemIcon(float ep, float wep) =
{
	local string icon;

	if(ep == 1)
	{
		switch(wep)
		{
			case WEP1_MINIGUN:			icon = "gfx/hud/ico_weap_minigun.tga";		break;
			case WEP1_STORMPLOW:		icon = "gfx/hud/ico_weap_splow.tga";		break;
			case WEP1_BEAMCANNON:		icon = "gfx/hud/ico_weap_beam.tga";			break;
			case WEP1_ROCKETPOD:		icon = "gfx/hud/ico_weap_rockets.tga";		break;
		}
	}
	else
	if(ep == 2)
	{
		switch(wep)
		{
			case WEP2_FLACKGUN:			icon = "gfx/hud/ico_weap_flackgun.tga";		break;
			case WEP2_SHOCKWAVE:		icon = "gfx/hud/ico_weap_swave.tga";		break;
			case WEP2_STORMSPREAD:		icon = "gfx/hud/ico_weap_sspread.tga";		break;
			case WEP2_STORMSHIELD:		icon = "gfx/hud/ico_weap_sshield.tga";		break;
			case WEP2_THUNDERBOLT:		icon = "gfx/hud/ico_weap_thunder.tga";		break;
			case WEP2_HOMINGMISSILES:	icon = "gfx/hud/ico_weap_hmissile.tga";		break;
			case WEP2_MIRVMORTAR:		icon = "gfx/hud/ico_weap_mirv.tga";			break;
		}
	}

	return icon;
}

void DrawItemIcons(vector org, float buf, float center) =
{
	local float count, numitems;
	local vector pos, imgsize;
	local string icon;
	
	numitems = GetBufferSize(buf);
	
	for(count = 0; count < numitems; count++)
	{
		icon = GetBufferString(buf, count);
		imgsize = '42 42 0';
		
		pos = org;
		if(center)
			pos_x += 150 - border_size_x - body_margin_x - numitems*imgsize_x*0.5;
		pos_x += count*imgsize_x;
		
		drawpic(pos, icon, imgsize, '1 1 1', 1, 0);
	}
}

void RetryMission() =
{
	localcmd("restart\n");
	CloseMenu();
}

float	challenge_items;
void DrawChallenges(float maxchallengesperline, float drawitemsontop) =
{
	float itemline, ch_count, ch_numchallenges, count, numchallenges, linenum, line_count, line_numchallenges, challenge_spacing, challenge_multiple, posadjust;
	string challenge, imgname, s;
	vector pos, imgsize;
	
	drawfont = FONT_CHAT;
	challenge_spacing = 40;
	
	linenum = 1;
	
	if(buf_list_challenges)
	{
		numchallenges = GetBufferSize(buf_list_challenges);
		for(count = 0; count < numchallenges; count++)
		{
			if(drawitemsontop && count >= challenge_items)
			{
				ch_count = count - challenge_items;
				ch_numchallenges = numchallenges - challenge_items;
			}
			else
			{
				ch_count = count;
				if(drawitemsontop && count < challenge_items)
					ch_numchallenges = challenge_items;
				else
					ch_numchallenges = numchallenges;
			}
		
			line_count = ch_count - (linenum-1)*maxchallengesperline;
			line_numchallenges = min(maxchallengesperline, ch_numchallenges-maxchallengesperline*(linenum-1));

			challenge = GetBufferString(buf_list_challenges, count);
				
			tokenizebyseparator(challenge, SEP_SPACE);

			challenge = argv(0);		
			imgname = argv(1);
			challenge_multiple = stof(argv(2));
			
			if(drawitemsontop)
			if(count < challenge_items)
				itemline = true;
			else
			{
				if(itemline)
					option_pos_y += 40 + option_spacing*2 + 8;
				itemline = false;
			}
			
			imgsize = '48 48 0';
			
			pos = option_pos;
			pos_x += (active_menu.menusize_x - border_size_x*2 - body_margin_x*2)*0.5;
			pos_x -= (line_numchallenges*imgsize_x + (line_numchallenges - 1)*challenge_spacing)*0.5;
			pos_x += line_count*(imgsize_x+challenge_spacing);
			drawpic(pos, imgname, imgsize, '1 1 1', 1, 0);

			pos_y += 40 + option_spacing;
			
			if(challenge_multiple)
			{
				s = strcat("x", ftos(challenge_multiple));
				posadjust = (stringwidth(s, TRUE, '8 8 0'*languagefontscale) - imgsize_x)*0.5;
				pos_x -= posadjust;
				drawstring(pos, s, '8 8 0'*languagefontscale, '0.46 0.62 0.75', 1, 0);
				pos_x += posadjust;
				pos_y += 10;
			}
			
			pos_x -= (stringwidth(challenge, TRUE, '8 8 0'*languagefontscale) - imgsize_x)*0.5;
			drawstring(pos, challenge, '8 8 0'*languagefontscale, '0.46 0.62 0.75', 1, 0);
			
			if(ch_count+1 < ch_numchallenges)
			if((maxchallengesperline*(linenum-1)+line_count+1) >= maxchallengesperline*linenum)
			{
				option_pos_y += 40 + option_spacing*2 + 8;
				if(challenge_multiple)
					option_pos_y += 10;
				linenum++;
			}
		}
	}
	
	drawfont = body_font;
	if(numchallenges)
		option_pos_y += 50;		
}

void GenerateChallenges(string challenges, float viewingprofile, float generatingmenufile) =
{
	local float count, tokens, advancecount, translate;
	local string challenge, filename;
	
	filename = __FUNC__;
	
	translate = skiptranslation;
	skiptranslation = false;	
	
	local string str_marksman, str_berserker, str_survivor, str_scout, str_steeltitan, str_deathhammer, str_perforator, str_morbidblanket, str_swiftyjuggler, str_mrclassic, str_annihilator, str_minigun, str_stormplow, str_beamcannon, str_rocketpod, str_flackgun, str_shockwave, str_stormspread, str_stormshield, str_thunderbolt, str_homingmissiles, str_mirvmortar;

	buf_localizechallenges = InitializeNonstandardTranslations(buf_localizechallenges, filename, true);
	
	str_marksman		= Localize("MARKSMAN", buf_localizechallenges);
	str_berserker		= Localize("BERSERKER", buf_localizechallenges);
	str_survivor		= Localize("SURVIVOR", buf_localizechallenges);
	str_scout			= Localize("SCOUT", buf_localizechallenges);
	str_steeltitan		= Localize("STEELTITAN", buf_localizechallenges);
	str_deathhammer		= Localize("DEATHHAMMER", buf_localizechallenges);
	str_perforator		= Localize("PERFORATOR", buf_localizechallenges);
	str_morbidblanket	= Localize("MORBIDBLANKET", buf_localizechallenges);
	str_swiftyjuggler	= Localize("SWIFTYJUGGLER", buf_localizechallenges);
	str_mrclassic		= Localize("MRCLASSIC", buf_localizechallenges);
	str_annihilator		= Localize("ANNIHILATOR", buf_localizechallenges);	
	str_minigun			= Localize("MINIGUN", buf_localizechallenges);
	str_stormplow		= Localize("STORMPLOW", buf_localizechallenges);
	str_beamcannon		= Localize("BEAMCANNON", buf_localizechallenges);
	str_rocketpod		= Localize("ROCKETPOD", buf_localizechallenges);
	str_flackgun		= Localize("FLACKGUN", buf_localizechallenges);
	str_shockwave		= Localize("SHOCKWAVE", buf_localizechallenges);
	str_stormspread		= Localize("STORMSPREAD", buf_localizechallenges);
	str_stormshield		= Localize("STORMSHIELD", buf_localizechallenges);
	str_thunderbolt		= Localize("THUNDERBOLT", buf_localizechallenges);
	str_homingmissiles	= Localize("HOMINGMISSILES", buf_localizechallenges);
	str_mirvmortar		= Localize("MIRVMORTAR", buf_localizechallenges);
	
	WriteNonstandardTranslations(buf_localizechallenges, filename, false, true);
	
	if(generatingmenufile)
		return;
	
	challenge_items = 0;
	buf_list_challenges = CreateBuffer();
	tokens = tokenizebyseparator(challenges, SEP_SPACE);

	if(viewingprofile)	
		advancecount = 2;
	else
		advancecount = 1;	
	
	for(count = 0; count <= tokens; count+=advancecount)
	{
		challenge = string_null;
	
		switch(argv(count))
		{
			case "MINIGUN":			challenge = strcat(str_minigun, SEP_SPACE, GetItemIcon(1, WEP1_MINIGUN));		challenge_items++;	break;
			case "STORMPLOW":		challenge = strcat(str_stormplow, SEP_SPACE, GetItemIcon(1, WEP1_STORMPLOW));	challenge_items++;	break;
			case "BEAMCANNON":		challenge = strcat(str_beamcannon, SEP_SPACE, GetItemIcon(1, WEP1_BEAMCANNON));	challenge_items++;break;
			case "ROCKETPOD":		challenge = strcat(str_rocketpod, SEP_SPACE, GetItemIcon(1, WEP1_ROCKETPOD));	challenge_items++;break;
			case "FLACKGUN":		challenge = strcat(str_flackgun, SEP_SPACE, GetItemIcon(2, WEP2_FLACKGUN));		challenge_items++;break;
			case "SHOCKWAVE":		challenge = strcat(str_shockwave, SEP_SPACE, GetItemIcon(2, WEP2_SHOCKWAVE));	challenge_items++;break;
			case "STORMSPREAD":		challenge = strcat(str_stormspread, SEP_SPACE, GetItemIcon(2, WEP2_STORMSPREAD));challenge_items++;break;
			case "STORMSHIELD":		challenge = strcat(str_stormshield, SEP_SPACE, GetItemIcon(2, WEP2_STORMSHIELD));challenge_items++;break;
			case "THUNDERBOLT":		challenge = strcat(str_thunderbolt, SEP_SPACE, GetItemIcon(2, WEP2_THUNDERBOLT));challenge_items++;break;
			case "HOMINGMISSILES":	challenge = strcat(str_homingmissiles, SEP_SPACE, GetItemIcon(2, WEP2_HOMINGMISSILES));challenge_items++;	break;
			case "MIRVMORTAR":		challenge = strcat(str_mirvmortar, SEP_SPACE, GetItemIcon(2, WEP2_MIRVMORTAR));	challenge_items++;break;			
			default: 				continue;	
		}
		
		if(challenge != string_null)
		{
			if(viewingprofile)
				challenge = strcat(challenge, SEP_SPACE, argv(count+1));
			AddBufferString(buf_list_challenges, challenge, 0);			
		}
	}	
	
	for(count = 0; count <= tokens; count+=advancecount)
	{
		challenge = string_null;
		
		switch(argv(count))
		{
			case "MARKSMAN":		challenge = strcat(str_marksman, SEP_SPACE, "gfx/challenges/ico_ach_marksman.tga");	break;
			case "BERSERKER":		challenge = strcat(str_berserker, SEP_SPACE, "gfx/challenges/ico_ach_berserker.tga");	break;
			case "SURVIVOR":		challenge = strcat(str_survivor, SEP_SPACE, "gfx/challenges/ico_ach_survivor.tga");	break;
			case "SCOUT":			challenge = strcat(str_scout, SEP_SPACE, "gfx/challenges/ico_ach_scout.tga");	break;
			case "STEELTITAN":		challenge = strcat(str_steeltitan, SEP_SPACE, "gfx/challenges/ico_ach_steeltitan.tga");	break;
			case "DEATHHAMMER":		challenge = strcat(str_deathhammer, SEP_SPACE, "gfx/challenges/ico_ach_deathhammer.tga");	break;
			case "PERFORATOR":		challenge = strcat(str_perforator, SEP_SPACE, "gfx/challenges/ico_ach_perforator.tga");	break;
			case "MORBIDBLANKET":	challenge = strcat(str_morbidblanket, SEP_SPACE, "gfx/challenges/ico_ach_blanket.tga");	break;
			case "SWIFTYJUGGLER":	challenge = strcat(str_swiftyjuggler, SEP_SPACE, "gfx/challenges/ico_ach_juggler.tga");	break;
			case "MRCLASSIC":		challenge = strcat(str_mrclassic, SEP_SPACE, "gfx/challenges/ico_ach_mrclassic.tga");	break;
			case "ANNIHILATOR":		challenge = strcat(str_annihilator, SEP_SPACE, "gfx/challenges/ico_ach_annihilator.tga");	break;
			default: 				continue;	
		}
		
		if(challenge != string_null)
		{
			if(viewingprofile)
				challenge = strcat(challenge, SEP_SPACE, argv(count+1));		
			AddBufferString(buf_list_challenges, challenge, 0);			
		}		
	}
	
	skiptranslation = translate;
}