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
/*void MergeMissionFiles(string missionfilename_1, string missionfilename_2, string outputfilename) =
{
	local float file, count, buf, objcount, pathgroupcount, readingobjects;
	local string line, variable, value;
	
	buf = CreateBuffer();
	
	if(!missionfilename_1 || !missionfilename_2 || !outputfilename)
	{
		print("Error: missing filename paramaters. (Syntax: mergemissions missionfilename_1 missionfilename_2 outputfilename)\n");
		return;		
	}
	
	file = FileOpen(missionfilename_1, FILE_READ);
	if(file == -1)
	{
		print("Error: Can not find mission file 1.\n");
		return;
	}
	
	for(line = fgets(file); line; line = fgets(file))
	{
		AddBufferString(buf, line, 0);	
		
		if(!readingobjects)
		{
			if(line == "ENTITIES")
				readingobjects = true;	
			continue;
		}
		
		objcount++;
		
		tokenize(line);
		for(count = 0; argv(count); count+=2)
		{
			variable = argv(count);
			if(variable == "PATHRGROUPID")
			if(stof(argv(count+1)) > pathgroupcount)
				pathgroupcount = stof(argv(count+1));
		}
	}
	
	fclose(file);
	
	file = FileOpen(missionfilename_2, FILE_READ);
	if(file == -1)
	{
		print("Error: Can not find mission file 2.\n");
		return;
	}	
	
	readingobjects = false;
	for(line = fgets(file); line; line = fgets(file))
	{
		if(!readingobjects)
		{
			if(line == "ENTITIES")
				readingobjects = true;					
			continue;
		}	
	
		tokenize(line);
		line = string_null;
		for(count = 0; argv(count); count+=2)
		{
			variable = argv(count);
			value = argv(count+1);
			
			if(stof(value))
			{
				if(variable == "ENTID"
				|| variable == "TARGETENTID"
				|| variable == "TRIGGERENTID"
				|| variable == "ASSOCIATIONENTID"
				|| variable == "PREVPATHENTID"
				|| variable == "NEXTPATHENTID")
					value = ftos(stof(argv(count+1))+objcount);
			
				if(variable == "PATHGROUPID")
					value = ftos(stof(argv(count+1))+pathgroupcount);
			}
			
			line = AppendToken(line, SEP_SPACE, variable);
			line = AppendToken(line, SEP_SPACE, value);
		}
		
		AddBufferString(buf, substring(line, 1, strlen(line)-1), 0);
	}
	
	fclose(file);
	
	file = FileOpen(uri_escape(outputfilename), FILE_WRITE);
	
	count = 0;
	for(line = GetBufferString(buf, count); line; line = GetBufferString(buf, count))
	{
		NewFileLine(file, line);
		count++;
	}
	
	fclose(file);
	DeleteBuffer(buf);
	
	print("Mission files merged successfully.\n");
}*/