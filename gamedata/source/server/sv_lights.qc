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
float START_OFF = 1;

void Light_setup() =
{
	if (self.style < 32)
		return;							// Dont switch other styles.

	if (self.spawnflags & START_OFF)  
		lightstyle(self.style, "a");    // If light starts off, set it off.
	else
		lightstyle(self.style, "m");    // If light starts ON, turn in ON. Simple :)
}

void LightStyles_setup() =
{
	float f, argc, linenum, numstyles;
	string s;
	
	f = FileOpen("lightstyles.txt", FILE_READ);
	if (f < 0)
	{
		print("^1Warning! lightstyles.txt is missing!\n");
		lightstyle(0, "m");
		return;
	}
	for (s = fgets(f); s; s = fgets(f))
	{
		linenum++;
		argc = tokenize(s);
		if (!argc || substring(argv(0), 0, 2) == "//" || argv(0) == "")
			continue;
		if (argc < 2) // bad definition
		{
			print("^1Warning! lightstyles.txt: bad style definition at line '", substring(argv(0), 0, 2), "' - ", ftos(linenum), "!\n");
			continue; 
		}
		lightstyle(stof(argv(0)), argv(1));
		numstyles++;
	}
	// print a num of registered styles
	dprint(strcat("lightstyles.txt: parsed ", ftos(numstyles), " styles\n"));
}

void light() =                       // Basic Light
{
	Light_setup();                          // Setup Light
}

void light_fluoro() =                // Light with hum ambient
{
	Light_setup();                          // Setup Light
}

void light_fluorospark() =           // Light with buzz ambient
{
	Light_setup();                          // Setup Light
}
