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
float	buf_localizerandomquitmessage;
float	buf_localizemissionstatustokens;
float	buf_localizecredits;
float	buf_localizecontrolsmenuheader;
float	buf_localizesystemmenuheader;

void ResetLanguageBuffers() =
{
	ResetGlobalLanguageBuffers();
	ResetSharedClientMenuLanguageBuffers();
	ResetMenuLanguageBuffers();
	
	DeleteBuffer(buf_localizerandomquitmessage);
	buf_localizerandomquitmessage = 0;	
	
	DeleteBuffer(buf_localizemissionstatustokens);
	buf_localizemissionstatustokens = 0;		
	
	DeleteBuffer(buf_localizecredits);
	buf_localizecredits = 0;			
	
	DeleteBuffer(buf_localizecontrolsmenuheader);
	buf_localizecontrolsmenuheader = 0;
	
	DeleteBuffer(buf_localizesystemmenuheader);
	buf_localizesystemmenuheader = 0;
	
	DeleteBuffer(buf_credits);
	buf_credits = 0;
}

string GetLocalCampaignName(string filename) =
{
	local float file;
	local string line;

	file = FileOpen(filename, FILE_READ);
	
	if(file == -1)
		return "DEFAULT";
		
	fgets(file);
	line = fgets(file);
	
	fclose(file);

	return line;
}

string GetLocalMissionName(string filename) =
{
	local float file;
	local string line, missionname;

	file = FileOpen(filename, FILE_READ);
	
	missionname = "DEFAULT";
	
	if(file != -1)
	{
		for(line = fgets(file); missionname == "DEFAULT" && line; line = fgets(file))
		{
			tokenize(line);
			
			if(argv(0) == "MISSION")
				missionname = argv(1);
		}

		fclose(file);
	}
	
	return missionname;
}