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
string GetNewUnlockString() =
{
	local float file, count;
	local string filename, s, line, t;
	
	filename = strcat("campaign/_", uri_escape(campaign));
	filename = strcat(filename, "/local/");
	filename = strcat(filename, GetLanguageName(currentlanguage));
	filename = strcat(filename, "/campaignend.txt");
	file = FileOpen(filename, FILE_READ);	
	
	if(file == -1)
	{
		filename = strcat("campaign/_", uri_escape(campaign));
		filename = strcat(filename, "/campaignend.txt");
		file = FileOpen(filename, FILE_READ);
	}
	
	if(file != -1)
	{
		for(line = fgets(file); line; line = fgets(file))
		{
			tokenizebyseparator(line, SEP_SPACE);
			t = argv(0);
			if(t == "UNLOCK")
			{
				for(count = 1; argv(count); count++)
				{
					if(s)
						s = strcat(s, SEP_SPACE);
					s = strcat(s, argv(count));	
				}
				
				break;
			}
		}
	
		fclose(file);
	}
	
	return s;
}

void GenerateChallengeBufferStrings(float buf, float file, float existingchallenges, string newchallenges, float endgame) =
{
	local string line, newline, t, newunlockstring;
	local float gamemodestringnum, unlockedstringnum, unlocked, count, newcount, t_amount, isaddition, challengeexists, unlockexists, tempbuf, newamount;

	AddBufferString(buf, "ACHIEVEMENTS", 0);
	
	if(existingchallenges)
	{
		for(line = fgets(file); line && line != "GAMEPROGRESS"; line = fgets(file))
		{
			count++;
			tokenizebyseparator(line, SEP_SPACE);
			t = argv(0);

			if(t == "unlocked")
			{
				unlocked = TRUE;
				unlockedstringnum = count;
			}
			else
			if(newchallenges)
			{
				if(t == GetGameMode_String(gamemode, TRUE))
					gamemodestringnum = count;
			}
			
			AddBufferString(buf, line, 0);		
		}
	}
	
	if(endgame)
		newunlockstring = GetNewUnlockString();
	
	if(unlocked)
	{
		tempbuf = CreateBuffer();
		newline = "unlocked";
		SetBufferString(tempbuf, 0, newline);
		
		line = GetBufferString(buf, unlockedstringnum);
		tokenizebyseparator(line, SEP_SPACE);
		for(count = 1; argv(count); count++)
		{
			t = argv(count);
			newline = GetBufferString(tempbuf, 0);
			newline = strcat(newline, SEP_SPACE, t);
			SetBufferString(tempbuf, 0, newline);
			
			line = GetBufferString(buf, unlockedstringnum);	
			tokenizebyseparator(line, SEP_SPACE);			
		}

		tokenizebyseparator(newunlockstring, SEP_SPACE);
		for(newcount = 0; argv(newcount); newcount++)
		{
			unlockexists = FALSE;
			t = argv(newcount);
			line = GetBufferString(buf, unlockedstringnum);
			tokenizebyseparator(line, SEP_SPACE);
			for(count = 1; argv(count); count+=2)
			{
				if(argv(count) == t)
				{
					unlockexists = TRUE;
					break;
				}
			}
			
			if(!unlockexists)
			{
				newline = GetBufferString(tempbuf, 0);
				newline = strcat(newline, SEP_SPACE, t);
				SetBufferString(tempbuf, 0, newline);			
			}
		
			tokenizebyseparator(newunlockstring, SEP_SPACE);
		}
		
		newline = GetBufferString(tempbuf, 0);
		SetBufferString(buf, unlockedstringnum, newline);
		DeleteBuffer(tempbuf);			
	}
	else
	if(newunlockstring)
	{
		tokenizebyseparator(newunlockstring, SEP_SPACE);
		newunlockstring = "unlocked";
		for(count = 0; argv(count); count++)
			newunlockstring = strcat(newunlockstring, SEP_SPACE, argv(count));

		AddBufferString(buf, newunlockstring, 0);	
	}
	
	if(gamemodestringnum) // modify line for game mode challenges
	{
		tempbuf = CreateBuffer();
		newline = GetGameMode_String(gamemode, TRUE);	// start new line to save gamemode challenges
		SetBufferString(tempbuf, 0, newline);			// save the new string to the tempbuf buffer
		
		line = GetBufferString(buf, gamemodestringnum);		// old challenge line for gamemode
		tokenizebyseparator(line, SEP_SPACE);				// look at old line
		for(count = 1; argv(count); count+=2)				// advance tokens by two to only check challenge names to fine new challenges to be appended to the the line
		{
			isaddition = FALSE;					// clear the flag to default before reading new values
			t = argv(count);					// old challenge name
			t_amount = stof(argv(count+1)); 	// old challenge amount
			
			tokenizebyseparator(newchallenges, SEP_SPACE);		// look at new challenges
			for(newcount = 0; argv(newcount); newcount+=1)		// advance by one, amounts are not included in tokens
			{
				if(argv(newcount) == t)			// the new challenge is the same as the old challenge
				{
					isaddition = TRUE;							// don't append the old value later because a new value has already been appended
					newline = GetBufferString(tempbuf, 0);		// get the new line that is being created
					newline = strcat(newline, SEP_SPACE, t);	// append the challenge name to the new line
					newamount = t_amount+1;						// add one to the existing amount of times the challenge has been earned
					newline = strcat(newline, SEP_SPACE, ftos(newamount));	// append the new value for the old challenge to the new string
					SetBufferString(tempbuf, 0, newline);		// save the new string to the tempbuf buffer
					break;
				}
			}
		
			if(!isaddition)		// the challenge is unchanged so append as is
			{
				newline = GetBufferString(tempbuf, 0);
				newline = strcat(newline, SEP_SPACE, t, SEP_SPACE, ftos(t_amount));
				SetBufferString(tempbuf, 0, newline);
			}
		
			// get the old challenge line for gamemode and look at it again to avoid loss of tokens before loop
			line = GetBufferString(buf, gamemodestringnum);	
			tokenizebyseparator(line, SEP_SPACE);
		}
		
		tokenizebyseparator(newchallenges, SEP_SPACE);	// look at new challenges
		for(newcount = 0; argv(newcount); newcount+=1)	// advance by one, amounts are not included in tokens
		{
			challengeexists = FALSE;			// reset the flag
			t = argv(newcount);					// get the challenge name
			line = GetBufferString(buf, gamemodestringnum);		// get the old challenge string
			tokenizebyseparator(line, SEP_SPACE);				// look at the old challenge string
			for(count = 1; argv(count); count+=2)				// advance by two to only read challenge names
			{
				if(argv(count) == t)			// old challenge is the same as new challenge and has already been appended
				{
					challengeexists = TRUE;		// don't append
					break;						// found the match so break loop
				}
			}
			
			if(!challengeexists)	// is new challenge so append to new line
			{
				newline = GetBufferString(tempbuf, 0);
				newline = strcat(newline, SEP_SPACE, t, " 1");
				SetBufferString(tempbuf, 0, newline);			
			}
		
			tokenizebyseparator(newchallenges, SEP_SPACE);		// look at new challenges again before loop to avoid losing tokens
		}
		
		newline = GetBufferString(tempbuf, 0);					// get new challenge line
		SetBufferString(buf, gamemodestringnum, newline);		// set challenge buffer to new challenge line
		DeleteBuffer(tempbuf);
	}
	else
	if(newchallenges)		// player has not previously earned challenges for this game mode
	{
		tokenizebyseparator(newchallenges, SEP_SPACE);							// look at new challenges
		newchallenges = GetGameMode_String(gamemode, TRUE);						// create new challenge line
		for(count = 0; argv(count); count+=1)									// advance by one, amounts are not included in tokens
		{
			newchallenges = strcat(newchallenges, SEP_SPACE, argv(count));		// append challenge name
			newchallenges = strcat(newchallenges, " 1");						// append challenge amount of times earned
		}
		AddBufferString(buf, newchallenges, 0);									// set challenge buffer to new challenge line
	}
} 

void SaveProfile(entity e, string challenges, float endgame) =
{
	local float count, file, buffer_list, buffer_list_header, buffer_list_challenges, buffer_size, campaignprogress, missionpreviouslycompleted, existingchallenges, globalitems1_old, globalitems2_old;
	local string filename, line, s, playername;
	
	#ifdef COMPILE_SERVICE_ONLIVE
		playername = "player";
	#else
		playername = e.netname;
	#endif
	
	filename = strcat("profiles/_", uri_escape(playername));
	filename = strcat(filename, ".profile");

	file = FileOpen(filename, FILE_READ);	
	if(file == -1)
	{
		dprint("Profile for netname does not exist.\n");
		return;
	}	

	buffer_list_header = CreateBuffer();
	buffer_list_challenges = CreateBuffer();
	buffer_list = CreateBuffer();

	for(line = fgets(file); line && line != "GAMEPROGRESS" && line != "ACHIEVEMENTS"; line = fgets(file))
	{
		tokenizebyseparator(line, SEP_SPACE);
		if(argv(0) == "NAME"
		|| argv(0) == "COLORS"
		|| argv(0) == "RETICLE")
//		|| (CODEBASE == CLIENTCODE && argv(0) == "ITEMS"))
			AddBufferString(buffer_list_header, line, 0);
//		else
//		if(argv(0) == "ITEMS")
//		{
//			globalitems1_old = stof(argv(1));
//			if(argv(2))
//				globalitems2_old = stof(argv(2));
//		}
	}

	if(line == "ACHIEVEMENTS")
		existingchallenges = TRUE;
	GenerateChallengeBufferStrings(buffer_list_challenges, file, existingchallenges, challenges, endgame);
	
//	for(count = 0; (line && line != "GAMEPROGRESS") || !count; count++)
//		line = fgets(file);
	
	line = fgets(file);
	while(line)
	{
		if(CODEBASE == SERVERCODE)
		{
			tokenizebyseparator(line, SEP_SPACE);
			if(argv(0) == campaign)
			{
				campaignprogress = TRUE;
				line = GenerateProfileItemString(e);		
					
				count = 1;
				if(argv(count) == "EPISODE")
				{
					count++;
					count += stof(argv(count));
				}
				
				count++;
					
				for(; argv(count); count++)
				{
					line = AppendToken(line, SEP_SPACE, argv(count));
					if(argv(count) == mission)
						missionpreviouslycompleted = TRUE;
				}
			
				if(!missionpreviouslycompleted)
					line = AppendToken(line, SEP_SPACE, mission);
			}
		}
		
		AddBufferString(buffer_list, line, 0);
		line = fgets(file);
	}
	
	if(CODEBASE == SERVERCODE)
	if(!campaignprogress)
	{
		line = GenerateProfileItemString(e);	
		line = AppendToken(line, SEP_SPACE, mission);
		AddBufferString(buffer_list, line, 0);
	}
	
	fclose(file);
	
	file = FileOpen(filename, FILE_WRITE);

	s = strcat("VERSION ", ftos(PROFILE_FILEVERSION_CURRENT));
	NewFileLine(file, s);
	
	buffer_size = GetBufferSize(buffer_list_header);
	for(count = 0; count < buffer_size; count++)
		NewFileLine(file, GetBufferString(buffer_list_header, count));
	
//	if(CODEBASE == SERVERCODE)
//	{
//		line = GenerateProfileGlobalItemsString(e, globalitems1_old, globalitems2_old);
//		NewFileLine(file, line);	
//	}
	
	buffer_size = GetBufferSize(buffer_list_challenges);
	for(count = 0; count < buffer_size; count++)
		NewFileLine(file, GetBufferString(buffer_list_challenges, count));	
	
	NewFileLine(file, "GAMEPROGRESS");
	
	buffer_size = GetBufferSize(buffer_list);
	for(count = 0; count < buffer_size; count++)
		NewFileLine(file, GetBufferString(buffer_list, count));
	
	DeleteBuffer(buffer_list_header);
	DeleteBuffer(buffer_list_challenges);
	DeleteBuffer(buffer_list);
	fclose(file);	
}

float BeatsScore(entity e, entity c, string comparedscorestring, float tiewins) =
{
	local float e_val, c_val, numchecks, count;
	
	numchecks = 12;
	
	for(count == 0; count < numchecks; count++)
	{
		e_val = c_val = 0;

		switch(count)
		{
			case 0:		e_val = e.points+GetTimeBonus(e);
						if(c) c_val = c.points+GetTimeBonus(c); else c_val = GetStatFromScoreString(comparedscorestring, "SCORE");	break;
					
			case 1: 	e_val = e.captures;
						if(c) c_val = c.captures;	else continue;	break;

			case 2: 	e_val = e.returns;
						if(c) c_val = c.returns;	else continue;	break;
					
			case 3:		e_val = e.frags;
						if(c) c_val = c.frags;		else c_val = GetStatFromScoreString(comparedscorestring, "FRAGS_PLAYER");	break;
			
			case 4:		e_val = e.frags_npc;
						if(c) c_val = c.frags_npc;	else c_val = GetStatFromScoreString(comparedscorestring, "FRAGS_NPC");	break;
			
			case 5:		e_val = e.frags_other;
						if(c) c_val = c.frags_other;	else c_val = GetStatFromScoreString(comparedscorestring, "FRAGS_OTHER");	break;
			
			case 6:		e_val = e.accuracy;
						if(c) c_val = c.accuracy;	c_val = GetStatFromScoreString(comparedscorestring, "ACCURACY");	break;
						
			case 7:		e_val = e.damagedealt;
						if(c) c_val = c.damagedealt;	c_val = GetStatFromScoreString(comparedscorestring, "DAMAGE");	break;						
			case 8:		e_val = max(0, floor(mission_maptime_total - mission_finished_time));
						if(c) continue;				else c_val = GetStatFromScoreString(comparedscorestring, "TIME_LEFT");	break;
			
			case 9:		c_val = floor(mission_finished_time);
						if(c) continue;				else e_val = GetStatFromScoreString(comparedscorestring, "TIME_TAKEN");	break;
			
			case 10:		c_val = e.deaths;		
						if(c) e_val = c.deaths;		else e_val = GetStatFromScoreString(comparedscorestring, "DEATHS");	break;
			
			case 11:	c_val = e.suicides;		
						if(c) e_val = c.suicides;	else e_val = GetStatFromScoreString(comparedscorestring, "SUICIDES");	break;			
		}
	
		if(!(c_val == -1 || e_val == -1))
		if(e_val > c_val)
			return TRUE;
		else
		if(e_val < c_val)
			return FALSE;
	}

	return tiewins;
}