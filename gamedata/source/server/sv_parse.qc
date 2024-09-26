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
void ReceiveEpisodeNum(float epnum) =
{
	if(epnum < EPISODE)
	{
		dropclient(self);
		return;
	}
	
	self.requestingepisodenum = FALSE;	
	PutClientInServer();
}

void ReceiveJoinPassword(string password) =
{
	local string server_password;
	
	server_password = cvar_string("sv_join_password");
	
	if(!strlen(server_password) || password == server_password)
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_TEMPENTITY);	
		WriteByte(MSG_ONE, TE_GAMEJOINGRANTED);	
		
		self.requestingjoinpassword = FALSE;	
		PutClientInServer();
		return;
	}

	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);	
	WriteByte(MSG_ONE, TE_GAMEJOINDENIED);
}	

void GameCommand(string s) =
{
	local string c;
	tokenize(s);
	c = argv(0);

	if(c == "startcampaign")
	{
		if(!cvar_string("campaign"))
			dprint("You must specify a campaign.\n");
		else
		{
			mission = freezone(mission);
			campaign = zonecpy(campaign, UnderscoreString(cvar_string("campaign")));
			RotateMission();
		}
	}
}

void SV_ParseClientCommand (string s) =
{
	local string c;
	local float admn;
	tokenize(s);
	c = argv(0);

	if(self.adminmode) // editor is on
		admn = TRUE;
	
// RESTRICTED COMMANDS

	#ifdef COMPILE_SERVICE_ONLIVE
		if(c == "name")
			self.SendFlags = self.SendFlags | SFL_BASEDATA;
	#else
		if(c == "name" && self.netname != "unconnected" && self.netname != argv(1))
		{
			sprint(self, "You must change profiles to set your name.\n");
			return;
		}
		else
	#endif
	
// INITIALIZATION COMMANDS

	if(c == "episode")
	{	if(self.requestingepisodenum)	ReceiveEpisodeNum(stof(argv(1)));	}
	else
	if(c == "joinpassword")
	{	if(self.requestingjoinpassword)	ReceiveJoinPassword(argv(1));	}
	else	
	if(c == "items")
	{	AssignClientItems(s);	}
	else
	if(c == "jointeam")
	{	if(self.team == -1) if(!self.requestingjoinpassword)	JoinTeam(stof(argv(1)));	}
	else
	
// MENU COMMANDS
	
	if(c == "votemenu")
	{	if(!self.requestingjoinpassword)	InitiateVoteMenu();		}
	else
	if(c == "requestlist_gamemodes")
	{	if(!self.requestingjoinpassword)	RequestGameModeListToClient();	}
	else
	if(c == "requestlist_campaigns")
	{	if(!self.requestingjoinpassword)	RequestCampaignListToClient();	}
	else
	if(c == "requestlist_missions")
	{	if(!self.requestingjoinpassword)	RequestMissionListToClient(stof(argv(1)), argv(2));	}
	else	
	if(c == "vote_submit")
	{	if(!self.requestingjoinpassword)	VoteSubmit(substring(s, 12, strlen(s)-12));	}
	else
	if(c == "kickplayer")
	{	if(!self.requestingjoinpassword)	KickSubmit(substring(s, 11, strlen(s)-11));	}
	else
	if(c == "vote_yes")
	{	if(!self.requestingjoinpassword)	Vote(TRUE);		}
	else
	if(c == "vote_no")
	{	if(!self.requestingjoinpassword)	Vote(FALSE);	}
	else

	#ifdef COMPILE_SERVICE_ONLIVE
		if(c == "submitplayername")
		{	if(showingmissionscores)	if(realarcade_waitingformissioncompleteresponse)	if(self.scoreplacing)	SubmitPlayerName(argv(1));	}
		else
		if(c == "getscoresfromserver_realarcade")
		{	if(showingmissionscores)	if(realarcade_waitingformissioncompleteresponse) if(!self.scoreplacing)	GetScoresFromServer_RealArcade();	}
		else		
	#endif
	
	if(c == "menus_opened")
		self.menus_opened = TRUE;
	else
	if(c == "menus_closed")
		self.menus_opened = FALSE;
	else
	if(c == "closemissionbriefing")
		RestartActivity();
	else
	if(c == "lockcamera")
		self.lockedcamera = stof(argv(1));
	else
	if(c == "playercolors")
		AssignPlayerColors(stof(argv(1)), stof(argv(2)), stof(argv(3)));
	else
	if(c == "respawn")
	{	Respawn();	}
	else
	if(c == "nextmission")
	{	if(showingmissionscores)	PlayerFinishedViewingMissionScores(TRUE, TRUE);		}
	else
	if(c == "endmission")
	{	if(showingmissionscores)	PlayerFinishedViewingMissionScores(TRUE, FALSE);	}
	else
	if(c == "missioneditor") // check for admin priv
	{	if(missioneditorenabled) if(!self.requestingjoinpassword)	/*Respawn();*/	ToggleAdminMode(); 	}
	else
	if(c == "requestguesteditoraccess")
	{	if(missioneditorenabled) if(!self.requestingjoinpassword)	GrantEditorAccess();	}
	else
	if(c == "toggleeditoraccess")
	{	if(self.hasadminaccess)	if(!self.requestingjoinpassword)	ToggleEditorAccess(stof(argv(1)));	}
	else
	if(c == "grantadminaccess")
	{	if(!self.requestingjoinpassword)	GrantAdminAccess(argv(1), argv(2));	}
	else
	
// ADMIN COMMANDS	
	
	#ifndef COMPILE_SERVICE_ONLIVE
		if(c == "setmaptime")
		{
			if(admn)
			{
				mission_maptime_total = stof(argv(1));
				mission_maptime_start = time;
			}
		}
		else
		if(c == "setmissiontrack")
		{
			if(admn)
			{
				mission_track = zonecpy(mission_track, argv(1));
				BroadcastMissionTrack();
			}
		}
		else
		if(c == "setmissionbriefing")
		{
			if(admn)
			{
				mission_briefing = zonecpy(mission_briefing, argv(1));
				s = mission_briefing[currentlanguage+1];
				s = zonecpy(s, mission_briefing);
				mission_briefing[currentlanguage+1] = s;		
				BroadcastMissionBriefing();
				MISSION_LANGUAGE = currentlanguage;
			}
		}
		else	
	//	if(c == "toggleeditingrights")
	//	{	if(admn)	ClaimEditingRights(stof(argv(1)));	}
	//	else
		if(c == "remove_ent")
		{	if(admn)	Admin_RemoveEnt(stof(argv(1)));	}
		else
		if(c == "undelete_ent")
		{	if(admn)	Admin_UndeleteEnt(stof(argv(1)));	}	
		else
		if(c == "commit_entity")
		{	if(admn)	Commit_Entity(substring(s, strlen(c), strlen(s)-strlen(c)+1));		}
		else
		if(c == "remove_path")
		{	if(admn)	Remove_Path(stof(argv(1)));		}
	//	else
	//	if(c == "remove_pathgroup")
	//	{	if(admn)	Remove_PathGroup(stof(argv(1)));		}	
		else
		if(c == "commit_path")
		{	if(admn)	Commit_Path(substring(s, strlen(c), strlen(s)-strlen(c)+1));		}
		else
	//	if(c == "commit_entities_end")
	//	{	if(admn)	Commit_Entities_End();	}
	//	else
		if(c == "entity_deleteall")
		{	if(self.hasadminaccess)	ClearEntities();	}
		else
		if(c == "entity_reloadall")
		{	if(self.hasadminaccess)	ReloadEntities();	}
		else
		if(c == "entity_saveall")
		{	if(self.hasadminaccess)	SaveEntities_Default();	}
		else
		if(c == "entity_saveallas_check")
		{	if(self.hasadminaccess)	SaveEntitiesAs_Check(stof(argv(1)), argv(2), argv(3));	}
		else
		if(c == "entity_saveallas")
		{	if(self.hasadminaccess)	SaveEntitiesAs(stof(argv(1)), argv(2), argv(3));	}
		else	
		if(c == "createcampaign_check")
		{	if(self.hasadminaccess)	CreateCampaign_Check(argv(1));	}
		else
		if(c == "mission_lock")
		{	if(self.hasadminaccess)	SetMissionLock(stof(argv(1)));		}

	//	else
	//	if(c == "viewnavigationcells")
	//	{	if(admn)	ToggleViewNavigationCells();	}	
	//	else
	//	if(c == "debugent")
	//	{	if(admn)	eprint(GetLinkedListEnt_float(list_objectchain, objectchain, id, stof(argv(1))));	}	

		else
	#endif		
		
// END ADMIN COMMANDS

		clientcommand(self, s);
}