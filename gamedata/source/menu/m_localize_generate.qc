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
void GenerateLocalMissionFilesForGameType(string missionsearchpath) =
{
	local float searchhandle, count, tcount, numfiles, missionstartpos, missionendpos, file, newfile, objective, objpriority, e_id;
	local string missionname, line, realmissionname, filename, objectivetext, briefing;
	
	searchhandle = search_begin(strcat(strtolower(missionsearchpath), "*.mission"), TRUE, TRUE);

	if(searchhandle != -1)
	{
		numfiles = search_getsize(searchhandle);
	
		for(count = 0; count < numfiles; count++)
		{
			missionname = search_getfilename(searchhandle, count);

			filename = substring(missionsearchpath, 5, strlen(missionsearchpath)-5);
			missionstartpos = strlen(missionsearchpath);
			missionendpos = strlen(missionname) - missionstartpos - 8;
			realmissionname = substring(missionname, missionstartpos, missionendpos);
			filename = strcat(filename, realmissionname);
			filename = strcat(filename, "/local/local.txt");

			file = FileOpen(missionname, FILE_READ);
			newfile = FileOpen(filename, FILE_WRITE);
			
			fputs(newfile, "# Steel-Storm Translation File (MISSION DATA)\n");
			
			fputs(newfile, "MISSION \"");
			fputs(newfile, uri_unescape(substring(realmissionname, 1, strlen(realmissionname)-1)));
			fputs(newfile, "\"\n");
			
			for(line = fgets(file); line != "ENTITIES"; line = fgets(file))
			{
				tokenize(line);
			
				if(argv(0) == "BRIEFING")
				{
					briefing = argv(1);
					fputs(newfile, "BRIEFING \"");
					fputs(newfile, briefing);
					fputs(newfile, "\"\n");
				}
			}
			
			for(line = fgets(file); line; line = fgets(file))
			{
				objective = false;
			
				tokenize(line);
				for(tcount = 0; argv(tcount); tcount+=2)
				{
					if(argv(tcount) == "OBJCLASS")
					if(argv(tcount+1) == "13")
						objective = true;
				
					if(argv(tcount) == "ENTID")
						e_id = stof(argv(tcount+1));
						
					if(argv(tcount) == "OBJECTIVETEXT")
						objectivetext = argv(tcount+1);
						
					if(argv(tcount) == "PRIORITY")
						objpriority = stof(argv(tcount+1))+1;
				}
				
				if(objective)
				{
					fputs(newfile, "OBJECTIVE ");
					fputs(newfile, ftos(objpriority));
					fputs(newfile, " ");
					fputs(newfile, ftos(e_id));
					fputs(newfile, " \"");
					fputs(newfile, objectivetext);
					fputs(newfile, "\"\n");
				}
			}
			
			fclose(file);
			fclose(newfile);
		}
		
		search_end(searchhandle);
	}
}

void GenerateLocalMissionFiles() =
{
	local string line, cfilename, filename, campaign_title;
	local float file, cfile, count, searchhandle, numfiles, buf_campaigns;
	
	searchhandle = search_begin("data/campaign/*/missions.txt", TRUE, TRUE);
	if(searchhandle != -1)
	{

		buf_campaigns = CreateBuffer();
		numfiles = search_getsize(searchhandle);	

		for(count = 0; count < numfiles; count++)
		{
			campaign_title = search_getfilename(searchhandle, count);
			
			AddBufferString(buf_campaigns, substring(campaign_title, 0, strlen(campaign_title)-12), 0);

			cfilename = substring(campaign_title, 5, strlen(campaign_title)-18);
			filename = strcat(cfilename, "/local/local.txt");
			file = FileOpen(filename, FILE_WRITE);
			campaign_title = substring(campaign_title, 15, strlen(campaign_title)-28);
			NewFileLine(file, "# Steel-Storm Translation File (CAMPAIGN TITLE)");
			NewFileLine(file, uri_unescape(campaign_title));
			
			filename = strcat(cfilename, "/missions.txt");
			cfile = FileOpen(filename, FILE_READ);
			if(cfile != -1)
			{
				for(line = fgets(cfile); line; line = fgets(cfile))
				{
					tokenize(line);
					if(argv(0) == "TIER")
					{
						line = substring(line, 5, strlen(line)-5);
						NewFileLine(file, line);
					}
				}
				fclose(cfile);
			}
			
			fclose(file);
		}	
		
		search_end(searchhandle);
	}
	
	numfiles = GetBufferSize(buf_campaigns);
	for(count = 0; count < numfiles; count++)
	{
		campaign_title = GetBufferString(buf_campaigns, count);
		GenerateLocalMissionFilesForGameType(campaign_title);
	}
	
	DeleteBuffer(buf_campaigns);
	
	GenerateLocalMissionFilesForGameType("data/deathmatch/");
	GenerateLocalMissionFilesForGameType("data/ctf/");
}

void GenerateMenuFiles() =
{
	LOCALIZE_GENERATING = true;
	ResetLanguageBuffers();
	
	active_menu = spawn();

	Draw_UpdatesAvailable();
	Draw_ErrorMenu();
	Draw_InputHostName();
	Draw_HostGameOptions_Advanced();
	Draw_HostGameOptions();
	Draw_LimitedVersion_EntCount();
	Draw_MissionBriefing();
	Draw_LockedMission();
	Draw_MissionMenu();
	Draw_CampaignMenu();
	Draw_LeaveCampaignConfirmationMenu();
	Draw_MapMenu();
	Draw_RestartMapConfirmationMenu();
	Draw_CloseMapConfirmationMenu();
	Draw_MultiPlayerMenu();
	Draw_QuitConfirmationMenu();
	Draw_AdminToggle_MaxEnts();
	Draw_MainMenu();
	Draw_CampaignEdit_EditTierName();
	Draw_CampaignEditMenu();
	Draw_CampaignEdit_NewCampaign();
	Draw_OfflineMissionEditor_Campaign();
	Draw_OfflineMissionEditor_Deathmatch();
	Draw_OfflineMissionEditor_CTF();
	Draw_OfflineMissionEditor();
//	Draw_ConfirmResetEditorControls();
//	Draw_ConfirmResetGamepadSettings();
//	Draw_ConfirmResetMiscControls();
//	Draw_ConfirmResetPlayerControls();
	Draw_GetNewControlKey();
	Draw_ControlsMenu_Editor();
	Draw_ControlsMenu_Input();
	Draw_ControlsMenu_Misc();
	Draw_ControlsMenu_Player();
	Draw_LanguageMenu();
	Draw_PlayerChallengesForGameMode();
	Draw_PlayerChallenges();
	Draw_PlayerColorMenu();
	Draw_ReticleColorMenu();
	Draw_ReticleOptions();
	Draw_PlayerCameraOptions();
	Draw_HUDOptions();
	Draw_DifficultyOptions();
	Draw_ProfileOptions();
	Draw_ChooseDefaultDifficulty();
	Draw_CreateNewProfileMenu();
	Draw_ProfileMenu();
	Draw_ServerListFilter(string_null, string_null, SUB_Null, SUB_Null);
	Draw_Confirm_JoinServer();
	Draw_InaccessableEpisode();
	Draw_ServerList();
	Draw_SoundOptions();
	Draw_SystemMenu();
	Draw_SetServerPassword();
	Draw_ConfirmResolution();
	Draw_IPConnect();
	Draw_ProfileUpdated();
	Draw_ResetControlSettings();
	DrawControlsMenuHeader(0, 0, 0);
	DrawSystemMenuHeader(0, 0);
	
	RandomQuitMessage();
	GetGameMode_String_Local(0, false);
	GenerateChallenges(string_null, false, true);
	ListOption_Mission_Local(0);
	DrawCredits();
	Menu_InputWarnings_Local();
	
	ResetLanguageBuffers();
	
	remove(active_menu);
	active_menu = world;
	
	GenerateLocalMissionFiles();	
	
	LOCALIZE_GENERATING = false;	
}