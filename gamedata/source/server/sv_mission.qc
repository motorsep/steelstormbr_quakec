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
float	mission_rotation;

/*void SV_ChangeTeam(float tcolor) =
{
}*/

float CompletedMission(entity e, string missionname) =
{
	local float file, count;
	local string filename, campaignline, t, playername;
	
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
	//	print("Profile does not exist.\n");
		return FALSE;
	}	

	for(campaignline = fgets(file); campaignline && campaignline != "GAMEPROGRESS"; campaignline = fgets(file))
	{}
	
	campaignline = fgets(file);
	while(campaignline)
	{
		tokenizebyseparator(campaignline, SEP_SPACE);
		t = argv(0);
		if(t == cvar_string("campaign"))
			break;
		campaignline = fgets(file);
	}		
	
	fclose(file);

	count = 1;
	
	if(argv(count) == "EPISODE")
	{
		count++;
		count += stof(argv(count));
	}

	count++;
	
	for(t = argv(count); t; t = argv(count))
	{
		if(t == missionname)
			return TRUE;
		
		tokenizebyseparator(campaignline, SEP_SPACE);
		count++;
	}
	
	return FALSE;
}	
	
float StartMissionMap(float mode, string cname, string mname) =
{
	local string filename, line, s;
	local float file;

	filename = GetMissionFilename(mode, cname, mname, FALSE, FALSE);

	file = FileOpen(filename, FILE_READ);
	if(file == -1)
		return FALSE;
		
	for(line = fgets(file); line; line = fgets(file))
	{
		tokenize(line);
		if(argv(0) == "MAP")
		{
			mapname = argv(1);
			break;
		}
	}		
	
	fclose(file);
	
	gamemode = mode;
	cvar_set("sv_gamemode", ftos(mode));
	cvar_set("campaign", cname);
	cvar_set("mission", mname);
	s = strcat("changelevel ", mapname);
	s = strcat(s, "\n");
	localcmd(s);
	
	return TRUE;
}	
	
void RotateMission() =
{
	local string filename, nextmission, line, t, m;
	local float file, total_missions, count, incompletemission;
	
	filename = strcat(GetGameMode_String(gamemode, TRUE), "/");
	
	if(gamemode == GAMEMODE_CAMPAIGN)
	{
		filename = strcat(filename, "_");
		filename = strcat(filename, uri_escape(campaign));
		filename = strcat(filename, "/");
	}
	
	filename = strcat(filename, "missions.txt");
	file = FileOpen(filename, FILE_READ);

	if(file != -1)
	{
		if(!GameMode_HasMissionProgression(gamemode))//gamemode == GAMEMODE_DEATHMATCH)
			mission_rotation = cvar("sv_missionrotationnum");
			
		for(line = fgets(file); line; line = fgets(file))
		{
			tokenizebyseparator(line, SEP_SPACE);
			t = argv(0);
			if(t != "TIER" && t != "ENDTIER" && strlen(t))
			{
				total_missions++;
			
				if(gamemode == GAMEMODE_CAMPAIGN)
				if(mission)
				if(UnderscoreString(line) == mission)
					mission_rotation = total_missions;
			}
		}	

		if(mission_rotation >= total_missions)
		{
			mission_rotation = 0;
			if(!GameMode_HasMissionProgression(gamemode))//gamemode == GAMEMODE_DEATHMATCH)
				cvar_set("sv_missionrotationnum", ftos(mission_rotation));
		}

		fclose(file);

		if(total_missions > 0)
		{
			FileOpen(filename, FILE_READ);
			while(count <= mission_rotation)
			{
				line = fgets(file);
				tokenizebyseparator(line, SEP_SPACE);
				t = argv(0);
				
				if(t != "TIER" && t != "ENDTIER")
				{
					if(singleplayer)
					{
						if(!CompletedMission(self, t))
						{
							incompletemission = TRUE;
							break;
						}
					}
						
					count++;
				}
			}
			
			if(singleplayer)
			if(!incompletemission)
			{
				for(m = fgets(file); m && m != "ENDTIER"; m = fgets(file))
				{
					tokenizebyseparator(m, SEP_SPACE);
					t = argv(0);
				
					if(!CompletedMission(self, t))
					{
						line = m;
						break;
					}
				}
			}
			
			nextmission = line;
			fclose(file);
		}
	}
	else
		dprint("Error: No missions.txt file. Restarting Current Mission\n");

	if(line)
	{
		if(!StartMissionMap(gamemode, campaign, nextmission))
			dprint("Error: Mission does not exist. Restarting current mission.\n");
	}
	else
		dprint("Error: No missions found in missions.txt file. Restarting current mission.\n");

	localcmd("restart\n");
}

string GenerateProfileGlobalItemsString(entity e, float globalitems1, float globalitems2) =
{
	local float wep;
	local string line;
	
	for(wep = 1; wep <= 16777215; wep = wep*2)
	{
		if(e.items1 & wep)
			globalitems1 = globalitems1 | wep;
	}
	
	for(wep = 1; wep <= 16777215; wep = wep*2)
	{
		if(e.items2 & wep)
			globalitems2 = globalitems2 | wep;
	}	
	
	line = strcat("ITEMS", SEP_SPACE);
	line = strcat(line, ftos(globalitems1));
	line = strcat(line, SEP_SPACE);
	line = strcat(line, ftos(globalitems2));
		
	return line;
}

string AppendChallenge(string line, string challenge) =
{
	if(line)
		line = strcat(line, SEP_SPACE);
	line = strcat(line, challenge);
	
	return line;
}

void Challenges_Kills(entity attacker, entity victim, entity projectile) =
{
	if(victim.objclass == OBJ_NPC || victim.class == CLASS_PLAYER)
	{
		if(!attacker.lastkillwep)
			attacker.lastkillwep = projectile.shotvariant;
		
		if(projectile.shotvariant == attacker.lastkillwep)
			attacker.consecutivewepkillcount = attacker.consecutivewepkillcount + 1;
		else
			attacker.consecutivewepkillcount = 1;
		
		if(projectile.shotvariant == PROJ_MINIMIRV)
		if(attacker.consecutivewepkillcount >= 20)
			attacker.challenge_morbidblanket = TRUE;
	}
}

string GenerateChallengeStringForMission(entity player) =
{
	local string line, s;
	local float liveai, unfinishedobjectives, wep;
	local entity e;
	
	liveai = ai_total - ai_killed;
	
	for(e = list_objectivechain; e; e = e.objectivechain)
	{
		if(!e.istoggled)
		{
			unfinishedobjectives = TRUE;
			break;
		}
	}	
	
	if(singleplayer)
	{
		for(wep = 1; wep <= 16777215; wep = wep*2)
		{
			if((player.items1 & wep) && !(player.earneditems1 & wep))
			{
				switch(wep)
				{
					case WEP1_MINIGUN:		s = "MINIGUN";				break;
					case WEP1_STORMPLOW:	s = "STORMPLOW";			break;
					case WEP1_BEAMCANNON:	s = "BEAMCANNON";			break;
					case WEP1_ROCKETPOD:	s = "ROCKETPOD";			break;
				}
				
				line = AppendChallenge(line, s);	
			}
		}
		
		for(wep = 1; wep <= 16777215; wep = wep*2)
		{
			if((player.items2 & wep) && !(player.earneditems2 & wep))
			{
				switch(wep)
				{
					case WEP2_FLACKGUN:			s = "FLACKGUN";			break;
					case WEP2_SHOCKWAVE:		s = "SHOCKWAVE";		break;
					case WEP2_STORMSPREAD:		s = "STORMSPREAD";		break;
					case WEP2_STORMSHIELD:		s = "STORMSHIELD";		break;
					case WEP2_THUNDERBOLT:		s = "THUNDERBOLT";		break;
					case WEP2_HOMINGMISSILES:	s = "HOMINGMISSILES";	break;
					case WEP2_MIRVMORTAR:		s = "MIRVMORTAR";		break;
				}
				
				line = AppendChallenge(line, s);				
			}
		}	
	}
	
	if(player.challenge_berserker)
		line = AppendChallenge(line, "BERSERKER");	
	
	if(player.challenge_perforator)
		line = AppendChallenge(line, "PERFORATOR");

	if(player.accuracy > 0.8)
		line = AppendChallenge(line, "MARKSMAN");
		
	if(mission_finished_time < 180)
	if(liveai > 3)
		line = AppendChallenge(line, "SCOUT");

	if(!liveai)
	{
		line = AppendChallenge(line, "STEELTITAN");
		
		if(mission_finished_time < 180)	
		if(!unfinishedobjectives)
		if(!player.deaths)
			line = AppendChallenge(line, "DEATHHAMMER");
	}
	
	if(player.challenge_annihilator)
	if(!player.deaths)
		line = AppendChallenge(line, "ANNIHILATOR");
	
	if(player.challenge_morbidblanket)
		line = AppendChallenge(line, "MORBIDBLANKET");
	
	msg_entity = player;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	if(singleplayer)
		WriteByte(MSG_ONE, TE_SENDCHALLENGES);
	else
		WriteByte(MSG_ONE, TE_SAVECHALLENGES);
	WriteString(MSG_ONE, line);

	return line;
}

string GenerateProfileItemString(entity e) =
{
	local string line;

	line = strcat(campaign, SEP_SPACE, "EPISODE", SEP_SPACE, ftos(MISSIONEPISODE));
	line = strcat(line, SEP_SPACE);
	line = strcat(line, ftos(e.items1));

	if(MISSIONEPISODE >= 2)
	{
		line = strcat(line, SEP_SPACE);
		line = strcat(line, ftos(e.items2));
	}

	return line;
}

string GetScoreFilename() =
{
	local string filename;

	filename = strcat(GetGameMode_String(gamemode, TRUE), "/");
	
	if(gamemode == GAMEMODE_CAMPAIGN)
	{
		filename = strcat(filename, "_");
		filename = strcat(filename, uri_escape(campaign));
		filename = strcat(filename, "/");
	}

	filename = strcat(filename, "_");
	filename = strcat(filename, uri_escape(mission));
	filename = strcat(filename, ".scores");

	return filename;
}

float GetTimeBonus(entity e) =	{	return max(0, ceil(e.points*((600 - mission_finished_time)/600)));	}

string CreateScoreStringForEnt(entity e) =
{
	local string s;
	local float timebonus;
	
	timebonus = GetTimeBonus(e);
	e.points = e.points + timebonus;
	UpdateScore(e, SCORESTAT_SCORE);
	
	s = "NAME";
	s = AppendToken(s, SEP_QUOTE, e.netname);
	
	s = AppendToken(s, SEP_QUOTE, "SCORE");
	s = AppendToken(s, SEP_QUOTE, ftos(floor(e.points)));
	
	s = strcat(s, SEP_QUOTE, "CAPTURES");
	s = strcat(s, SEP_QUOTE, ftos(e.captures));
	
	s = strcat(s, SEP_QUOTE, "RETURNS");
	s = strcat(s, SEP_QUOTE, ftos(e.returns));	
	
//	s = AppendToken(s, SEP_QUOTE, "SECRETS");
//	s = AppendToken(s, SEP_QUOTE, ftos(0));	
	
	s = AppendToken(s, SEP_QUOTE, "ACCURACY");
	s = AppendToken(s, SEP_QUOTE, ftos(floor(e.accuracy*100)*0.01));
	
	s = AppendToken(s, SEP_QUOTE, "FRAGS_PLAYER");
	s = AppendToken(s, SEP_QUOTE, ftos(e.frags));
	
	s = AppendToken(s, SEP_QUOTE, "FRAGS_NPC");
	s = AppendToken(s, SEP_QUOTE, ftos(e.frags_npc));
	
	s = AppendToken(s, SEP_QUOTE, "FRAGS_OTHER");
	s = AppendToken(s, SEP_QUOTE, ftos(e.frags_other));
	
	s = AppendToken(s, SEP_QUOTE, "DEATHS");	
	s = AppendToken(s, SEP_QUOTE, ftos(e.deaths));
	
	s = AppendToken(s, SEP_QUOTE, "SUICIDES");	
	s = AppendToken(s, SEP_QUOTE, ftos(e.suicides));
	
	s = AppendToken(s, SEP_QUOTE, "DAMAGE");	
	s = AppendToken(s, SEP_QUOTE, ftos(floor(e.damagedealt)));

	s = AppendToken(s, SEP_QUOTE, "TIME_LEFT");	
	s = AppendToken(s, SEP_QUOTE, ftos(max(0, floor(mission_maptime_total - mission_finished_time))));
	
	s = AppendToken(s, SEP_QUOTE, "TIME_TAKEN");
	s = AppendToken(s, SEP_QUOTE, ftos(floor(mission_finished_time)));
	
	s = AppendToken(s, SEP_QUOTE, "TIME_BONUS");		
	s = AppendToken(s, SEP_QUOTE, ftos(timebonus));	
	
	return s;
}

float GetStatFromScoreString(string s, string stat) =
{
	local float count;

	tokenizebyseparator(s, SEP_QUOTE);
	for(count = 0; argv(count); count+=2)
	{
		if(argv(count) == stat)
			return stof(argv(count+1));
	}

	return -1;
}

void FixScoreFileFormatting(string filename) =
{
	local float file, count, buffer_newscores;
	local string line, s, t, n;
	
	file = FileOpen(filename, FILE_READ);
		
	if(file == -1)
		return;
	
	line = fgets(file);
	if(substring(line, 4, 1) == SEP_QUOTE)
	{
		// format already fixed so don't reformat
		fclose(file);
		return;
	}

	buffer_newscores = CreateBuffer();
	
	for( ;line; line = fgets(file))
	{
		s = string_null;
		tokenizebyseparator(line, SEP_SPACE);
		
		for(count = 0; argv(count); count++)
		{
			if(strlen(s))
				s = strcat(s, SEP_QUOTE);
		
			t = argv(count);
		
			if(t == "NAME")
			{
				s = strcat(t, SEP_QUOTE);
				
				count++;
				n = argv(count);
				
				n = substring(n, 1, strlen(n)-1);
				while(substring(n, strlen(n)-1, 1) != SEP_QUOTE)
				{
					count++;
					n = strcat(n, SEP_SPACE, argv(count));
				}

				n = substring(n, 0, strlen(n)-1);
				s = strcat(s, n);
				continue;
			}
			
			s = strcat(s, t);
		}
	
		AddBufferString(buffer_newscores, s, 0);
	}
	
	fclose(file);

	file = FileOpen(filename, FILE_WRITE);
	line = GetBufferString(buffer_newscores, 0);
	for(count = 1; line && count <= MAXSCORESAVES; count++)
	{
		NewFileLine(file, line);
		line = GetBufferString(buffer_newscores, count);
	}
	
	fclose(file);
	DeleteBuffer(buffer_newscores);
}

void SaveScores(float WRITESCORES) =
{
	if(adminmodeactive)
		return;

	local float file, buffer_scores, buffer_newscores, foundscoreplacing, count;
	local string filename, line;
	local entity e, e_bumpscore;
	
	filename = GetScoreFilename();

	FixScoreFileFormatting(filename);	
	
	file = FileOpen(filename, FILE_READ);

	buffer_scores = CreateBuffer();	
	buffer_newscores = CreateBuffer();	
	
	if(file != -1)
	{
		for(line = fgets(file); line; line = fgets(file))
			AddBufferString(buffer_scores, line, 0);	
		fclose(file);	
	}
	
	for(e = list_playerchain; e; e = e.playerchain)
	{
		foundscoreplacing = FALSE;
		
		line = GetBufferString(buffer_scores, 0);
		for(count = 1; line; count++)
		{
			if(!foundscoreplacing)
			{
				if(BeatsScore(e, world, line, FALSE))
				{
					e.scoreplacing = count;
				
					if(!WRITESCORES)
					{
						UpdateScore(e, SCORESTAT_SCOREPLACING);
						DeleteBuffer(buffer_scores);
						DeleteBuffer(buffer_newscores);						
						return;
					}
					
					foundscoreplacing = TRUE;
						
					for(e_bumpscore = list_playerchain; e_bumpscore; e_bumpscore = e_bumpscore.playerchain)
					{
						if(e_bumpscore != e)
						if(e_bumpscore.scoreplacing >= count)
						{
							e_bumpscore.scoreplacing = e_bumpscore.scoreplacing + 1;
							if(e_bumpscore.scoreplacing > MAXSCORESAVES)
								e_bumpscore.scoreplacing = 0;
						}
					}
					
					AddBufferString(buffer_newscores, CreateScoreStringForEnt(e), 0);
				}
			}
		
			AddBufferString(buffer_newscores, line, 0);
			line = GetBufferString(buffer_scores, count);
		}
		
		// player score is last place in the entire list
		if(!foundscoreplacing)
		if(count <= MAXSCORESAVES)
		{
			e.scoreplacing = count;
			AddBufferString(buffer_newscores, CreateScoreStringForEnt(e), 0);
		}
	
		DeleteBuffer(buffer_scores);
		buffer_scores = CreateBuffer();
		
		line = GetBufferString(buffer_newscores, 0);
		for(count = 1; line; count++)
		{
			AddBufferString(buffer_scores, line, 0);
			line = GetBufferString(buffer_newscores, count);		
		}
		
		DeleteBuffer(buffer_newscores);
		buffer_newscores = CreateBuffer();
	}
	
	DeleteBuffer(buffer_newscores);
	
	for(e = list_playerchain; e; e = e.playerchain)
		UpdateScore(e, SCORESTAT_SCOREPLACING);
	
	if(WRITESCORES)
	{
		file = FileOpen(filename, FILE_WRITE);
		line = GetBufferString(buffer_scores, 0);
		for(count = 1; line && count <= MAXSCORESAVES; count++)
		{
			NewFileLine(file, line);
			line = GetBufferString(buffer_scores, count);
		}

		fclose(file);
	}
	
	DeleteBuffer(buffer_scores);	
}

void PlayerFinishedViewingMissionScores(float APPLY, float nextsingleplayermission) =
{
	local float MSGTYPE;

	if(APPLY)
	{
		if(self.finishedviewingmissionscores == TRUE)
			return;
			
		MSGTYPE = MSG_ALL;
		self.finishedviewingmissionscores = TRUE;	
	}
	
	local entity e;
	e = list_playerchain;
	while(e)
	{
		if(e != self)
		if(!e.finishedviewingmissionscores)
			return;
			
		e = e.playerchain;
	}
	
	if(!APPLY)
	{
		msg_entity = self;
		MSGTYPE = MSG_ONE;
		self.finishedviewingmissionscores = TRUE;
	}
	
	self.scoreviewingtime = -1;

	if(singleplayer)
	{
		if(nextsingleplayermission)
		{
		//	self.earneditems1 = self.items1;
		//	self.earneditems2 = self.items2;
			RotateMission();
		}
	}
	else
	{
		if(!cvar("sv_manualmissionrotation"))
		{
			if(!GameMode_HasMissionProgression(gamemode))//gamemode == GAMEMODE_DEATHMATCH)
				cvar_set("sv_missionrotationnum", ftos(cvar("sv_missionrotationnum")+1));
			RotateMission();
			return;
		}
	}
	
	WriteByte(MSGTYPE, SVC_TEMPENTITY);
	WriteByte(MSGTYPE, TE_PLAYERSFINISHEDVIEWINGMISSIONSCORES);		
}

void RestartActivity() =
{
	local entity e, oself;
	
	if(showingmissionscores || !activityhalted)
		return;
		
	mission_maptime_start = time;
	activityhalted = FALSE;
	
	for(e = list_playerchain; e; e = e.playerchain)
	{
		e.movetype = MOVETYPE_WALK;
		Func_oself(e, AI_Wake);
	}
}

void StopAllActivity() =
{
	local entity e, oself;
	
	activityhalted = TRUE;
	
	for(e = list_playerchain; e; e = e.playerchain)
	{
		e.velocity = '0 0 0';
		e.movetype = MOVETYPE_NONE;
		e.SendFlags = e.SendFlags | SFL_ORIGIN | SFL_ORIGIN_STOP;
	}
	
	for(e = list_aichain; e; e = e.aichain)
	{
		oself = self;
		self = e;
			AI_Sleep();
		self = oself;
	}
}

float IsFinalMission() =
{
	local string filename, line, t, missiontier, finaltier;
	local float file, tiercount, isnotfinalmission, missionfound;
	
	if(gamemode != GAMEMODE_CAMPAIGN)
		return FALSE;
	
	filename = strcat("campaign/_", uri_escape(campaign));
	filename = strcat(filename, "/missions.txt");
	
	file = FileOpen(filename, FILE_READ);
	
	if(file == -1)
		return FALSE;
		
	for(line = fgets(file); line; line = fgets(file))
	{
		tokenize(line);
		t = argv(0);
		if(t == "TIER")
		{
			if(missionfound)
			{
				isnotfinalmission = TRUE;
				break;	
			}				
		}
		else
		if(t != "ENDTIER")
		{
			if(t == mission)
				missionfound = TRUE;
			else
			if(!CompletedMission(list_playerchain, t))
			{
				isnotfinalmission = TRUE;
				break;
			}
		}
	}	
	
	fclose(file);
	
	if(isnotfinalmission)
		return FALSE;
		
	return TRUE;
}

void SendMissionScores(float MSGTYPE) =
{
	local string filename, line, scoresstring;
	local float file, count;
	local entity e;
	
	if(!GameMode_HasTeams(gamemode))
	{
		filename = GetScoreFilename();
		
		file = FileOpen(filename, FILE_READ);
		
		count = 0;
		for(line = fgets(file); line && count < MAXSCORESAVES; line = fgets(file))
		{
			count++;
		
			if(scoresstring)
				scoresstring = strcat(scoresstring, SEP_QUOTE);
				
			for(e = list_playerchain; e; e = e.playerchain)
			{
				if(e.scoreplacing == count)
				{
					scoresstring = AppendToken(scoresstring, "MISSIONSCORE", SEP_QUOTE);
					break;
				}
			}

			scoresstring = strcat(scoresstring, line);			
			
			scoresstring = AppendToken(scoresstring, SEP_QUOTE, "ENDSCORE");
		}
		
		fclose(file);
	}

	msg_entity = self;		
	WriteByte(MSGTYPE, SVC_TEMPENTITY);
	WriteByte(MSGTYPE, TE_SHOWMISSIONSCORES);	
	WriteByte(MSGTYPE, missionscores_endgame);
	WriteString(MSGTYPE, scoresstring);
}

#ifdef COMPILE_SERVICE_ONLIVE
	void SubmitPlayerName(string playername) =
	{
		realarcade_waitingformissioncompleteresponse = FALSE;
		local string s;
		s = strcat("name ", playername, ";saveconfig;\n");
		stuffcmd(self, s);
		savescorestime = time+frametime*5;
	}

	void GetScoresFromServer_RealArcade() =
	{
		realarcade_waitingformissioncompleteresponse = FALSE;
		SaveScores(TRUE);
		SendMissionScores(MSG_ALL);
	}
	
	void OnLive_AskForPlayerName(entity e) =
	{
		SaveScores(FALSE);
		
	//	if(!e.scoreplacing)
	//	{
	//		SaveScores(TRUE);
	//		SendMissionScores(MSG_ALL);
	//		return;
	//	}
		realarcade_waitingformissioncompleteresponse = TRUE;
		msg_entity = e;
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_ASKFORPLAYERNAME);	
	}
#endif

void MissionScores(float MSGTYPE) =
{
	local float file, count;
	local string filename, scoresstring, line;
	local entity e;

	if(adminmodeactive || mission_locked)
	{
		TE_CenterPrint(other, CPM_CANTFINISHGAMEWILEADMINISEDITING);
		return;
	}	
	
	StopAllActivity();	

	if(singleplayer)
		missionscores_endgame = IsFinalMission();
	
	if(MSGTYPE == MSG_ALL)
	{
		for(e = list_playerchain; e; e = e.playerchain)
		{
			if(e.isdead)
				UpdateLives(max(0, global_lives - 1));
		}
	
		mission_finished_time = time - mission_maptime_start;
		
		TriggerMissionEndObjectives();
	
		#ifdef COMPILE_SERVICE_ONLIVE
			for(e = list_playerchain; e; e = e.playerchain)
				OnLive_AskForPlayerName(e);	
		#else
			if(!GameMode_HasTeams(gamemode))
				SaveScores(TRUE);
		#endif
		
		if(singleplayer)
			SaveProfile(list_playerchain, GenerateChallengeStringForMission(list_playerchain), missionscores_endgame);
		else
		{
			for(e = list_playerchain; e; e = e.playerchain)
				GenerateChallengeStringForMission(e);
		}			
			
		mission_maptime_total = 0;
		mission_maptime_start = 0;
		showingmissionscores = 1;
	//	if(maxscoreviewingtime)
		//if(singleplayer)
		//	server_scoreviewingtime = -1;
	//	else
			server_scoreviewingtime = time + maxscoreviewingtime;
	}

	#ifndef COMPILE_SERVICE_ONLIVE
		SendMissionScores(MSGTYPE);
	#endif
}

void MissionTimeUp(float MSGTYPE) =
{
	local entity e;

	mission_maptime_total = -1;
	
	if(!server_restarttime)
	{
		if(!singleplayer)
			server_restarttime = time + RESTARTTIME;
		StopAllActivity();
	}
		
	if(MSGTYPE == MSG_ONE)
		msg_entity = self;
		
	WriteByte(MSGTYPE, SVC_TEMPENTITY);
	WriteByte(MSGTYPE, TE_GAMEOVERFORALL);
	WriteByte(MSGTYPE, TRUE);
}

void JoinTeam(float f_team) =
{
	local float players_max, allowed_difference, players_red, players_blue;
	local entity e;

	f_team = bound(1, f_team, 2);	
	
	if(GameMode_HasTeams(gamemode))
	{
		for(e = list_playerchain; e; e = e.playerchain)
		{
			if(e.team == 1)
				players_red++;
			else
			if(e.team == 2)
				players_blue++;
		
			players_max++;
		}
		
		allowed_difference = floor(players_max/12)*2;
		players_max = (players_max-allowed_difference)/2;
		players_max = players_max + allowed_difference;
		if(allowed_difference)
			players_max = floor(players_max);	

		if(f_team == 1)
		if(players_red >= players_max)
			return;
		
		if(f_team == 2)
		if(players_blue >= players_max)
			return;
	}
	
	self.team = f_team;

	self.SendFlags = self.SendFlags | SFL_BASEDATA;
	PutClientInServer();
}

void ChooseTeam() =
{
	if(GameMode_HasTeams(gamemode))
	{
		if(self.team == -1)
		if(!self.adminmode)
		{
		//	self.team = 0;
			msg_entity = self;
			WriteByte(MSG_ONE, SVC_TEMPENTITY);
			WriteByte(MSG_ONE, TE_CHOOSETEAM);
		}
	}
	else
		self.team = 1;
}

void AddTeamCapture(float teamnum, float cappoints) =
{
	local entity e_team;

	for(e_team = list_teamchain; e_team; e_team = e_team.teamchain)
	{
		if(e_team.team == teamnum)
		{
			e_team.points = e_team.points + cappoints;
			e_team.SendFlags = e_team.SendFlags | SFL_SCORE;
			
			if(capturelimit)
			if(!(maxplayers == 1 && !singleplayer))
			if(e_team.points >= capturelimit)
				MissionScores(MSG_ALL);
			
			return;
		}
	}
}

void CreateTeam(float teamnum, float hasnoflag) =
{
	local entity e_team;
	
	// don't create neutral team
	if(teamnum == 0)
		return;
	
	for(e_team = list_teamchain; e_team; e_team = e_team.teamchain)
	{
		if(e_team.team == teamnum)
			return;
	}

	e_team = SpawnEnt();
	e_team.team = teamnum;
	e_team.noflag = hasnoflag;
	e_team.SendEntity = SendTeam;
	setmodel(e_team, "null");
	e_team.effects = EF_NODEPTHTEST;
	TeamChain_Add(e_team);
}