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
void DrawPercentBar(vector pos, float currentamt, float maxamt, vector clr, vector percentbox, float TEXTTYPE, string label, float ALPHA, float BG, float SWAPSIDES) =
{
	local vector pos_ofs;
	local string text;
	
	if(!ALPHA)
		ALPHA = 1;
	
	if(maxamt)
	{
		boxsize_x = percentbox_x*currentamt/maxamt;
		boxsize_y = percentbox_y;
		if(SWAPSIDES)
			pos_ofs_x = percentbox_x - boxsize_x;
	}
		
//	pos_ofs_y = -5;(FONTSIZE_HUD_y - percentbox_y)*0.5;
	if(BG)
		drawfill(pos, percentbox, clr*0.2, ALPHA, 0);
		
	if(maxamt)
		drawfill(pos + pos_ofs, boxsize, clr, ALPHA, 0);
	
	if(!TEXTTYPE)
	if(!label)
		return;
	
	if(TEXTTYPE == PERCENTBAR_RATIO)
	{
		text = strcat(ftos(currentamt), "/");
		text = strcat(text, ftos(maxamt));
	}
	else
	if(TEXTTYPE == PERCENTBAR_PERCENT)
		text = strcat(ftos(floor(currentamt/maxamt*100+0.5)), "%");
	else
		text = label;

	pos_x += percentbox_x*0.5 - FONTSIZE_HUD_x*strlen(text)*0.5;
	drawstring(pos, text, FONTSIZE_HUD, COLOR_HUD_INFO, ALPHA_HUD, 1);
}