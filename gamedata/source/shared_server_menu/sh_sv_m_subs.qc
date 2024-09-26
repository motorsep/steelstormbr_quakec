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
string		QCSF_CAMPAIGN	=	"!";
string		QCSF_MISSION	=	"@";
string		QCSF_EPISODE	= 	"~";

string ConvertToQCStatusString(string s, string c) =
{
	local float count, slen;
	local string a;
	
	slen = strlen(s);
	
	for(count = 0; count < slen; count++)
	{
		a = strcat(a, c);
		a = strcat(a, substring(s, count, 1));
	}
	
	return a;
}

string ConvertFromQCStatusString(string s, string c) =
{
	local float count, slen;
	local string a;

	slen = strlen(s);
	
	for(count = 0; count < slen; count+=2)
		a = strcat(a, substring(s, count+1, 1));

	return a;
}