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
vector GetConSizeForResolution(vector res) =
{
/*	vector csize;
	float minfactor, maxfactor;
	float vidscale, f;
//	vidscale = cvar("menu_vid_scale");

	if(res_z == 0)
		res_z = 1;

	// calculate the base resolution
	csize_z = 0;
	csize_x = 800;
	csize_y = csize_x * res_y * res_z / res_x;
	if(csize_y < 600)
	{
       csize_y = 600;
		csize_x = csize_y * res_x / (res_y * res_z);
	}

	f = min(res_x / csize_x, res_y / csize_y);
	if(f < 1)
		csize = csize * f; // ensures that c_x <= r_x and c_y <= r_y
 
	minfactor = min(1, 640 / csize_x);             // can be > 1 only if c_x is <640
	maxfactor = max(1, res_x / csize_x);
	maxfactor = max(maxfactor, res_y / csize_y); // can be < 1 only if r_x < c_x and r_y < c_y

	if(vidscale < 0)
		f = 1 - (maxfactor - 1) * vidscale;
	else if(vidscale > 0)
		f = 1 + (minfactor - 1) * vidscale;
	else
		f = 1;

	csize = csize * f; // fteqcc fail

	return csize;
	
//	cvar_set("vid_conwidth", ftos(rint(csize_x)));
//	cvar_set("vid_conheight", ftos(rint(csize_y)));
//	cvar_set("vid_pixelheight", ftos(rint(res_z)));



*/

	local vector consize;
	
//	consize_y = 600;
//	consize_x = (consize_y/res_y)*res_x;
//	if(consize_x > 800)
//		consize_z = 1;
//	return consize;
	
	res_z = 0;
	
	switch(res)
	{
		case '640 480 0':		consize = '800 600 0';		break;// 4x3
		case '800 600 0':		consize = '800 600 0';		break;// 4x3
		case '1024 768 0':		consize = '800 600 0';		break;// 4x3
		case '1152 864 0':		consize = '800 600 0';		break;// 4x3
		case '1280 720 0':		consize = '1067 600 1';		break;// 16x9
		case '1280 768 0':		consize = '1000 600 1';		break;// 5x3
		case '1280 800 0':		consize = '960 600 1';		break;
		case '1280 960 0':		consize = '800 600 0';		break;// 4x3
		case '1280 1024 0':		consize = '800 600 0';		break;
		case '1360 768 0':		consize = '1067 600 1';		break;
		case '1440 900 0':		consize = '960 600 1';		break;
		case '1600 900 0':		consize = '1067 600 1';		break;
		case '1600 1200 0':		consize = '800 600 0';		break;
		case '1680 1050 0':		consize = '960 600 1';		break;	
		case '1920 1080 0':		consize = '1067 600 1';		break;
		case '1920 1200 0':		consize = '960 600 1';		break;
		case '1980 1080 0':		consize = '1067 600 1';		break;
		case '2560 1440 0':		consize = '1067 600 1';		break;
		case '2560 1600 0':		consize = '960 600 1';		break;
		
		default:
			consize_y = 600;
			consize_x = (res_x/res_y)*600;
			//consize = '800 600 0';		
			break;
	}

	return consize;
}