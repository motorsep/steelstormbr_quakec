////////////////////////////////////////
// Nether Menu System source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

/*
Group

visual/system object
Draws background
Do arrangement
*/

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

.float _state;
enum
{
	GROUP_STATE_NORMAL,
	GROUP_STATE_SELECTED,
	_
};

////////////////////////////////////////
// CODE
////////////////////////////////////////

Menu_MethodSetEvent Object_Group_SetMethod =
{
	Menu_Sys_SetMethod(tObject, tOp, tMethod, tValue);
	Object_DataUser_SetMethod(tObject, tOp, tMethod, tValue);
}

/*
===================================================

 KEY & CLICK & MOUSE

===================================================
*/

Menu_SelectEvent Object_Group_Select =
{
	if (self._state == GROUP_STATE_NORMAL)
	{
		if (!tSilent)
			Menu_Sys_RunState(self, MSU_EVENT, self.state, ":select");	
		Menu_Sys_RunState(self, MSU_NORMAL, self.state, ":selected");	
		self._state = GROUP_STATE_SELECTED;
	}
	return 1; // allow select
}

Menu_SelectEvent Object_Group_Deselect =
{
	if (self._state == GROUP_STATE_SELECTED)
	{
		if (!tSilent)
			Menu_Sys_RunState(self, MSU_EVENT, self.state, ":deselect");	
		Menu_Sys_RunState(self, MSU_NORMAL, self.state, ":normal");	
		self._state = GROUP_STATE_NORMAL;
	}
	return 1; // allow deselect
}

/*
===================================================

 DRAW

===================================================
*/

void() Object_Group_Draw =
{
	ObjectLib_Background_Draw();
	ObjectLib_Picture_Draw();
	ObjectLib_Text_Draw();
	ObjectLib_Foreground_Draw();
}

/*
===================================================

 UPDATE

===================================================
*/

void() Object_Group_PreUpdate =
{
	ObjectLib_Text_PreUpdate();
}

void() Object_Group_PostUpdate =
{
	ObjectLib_Text_PostUpdate();
}

/*
===================================================

 SPAWN

===================================================
*/

void() Object_Group_Spawn =
{
	self.mSelect = Object_Group_Select;
	self.mDeSelect = Object_Group_Deselect;
	self.mPreUpdate = Object_Group_PreUpdate;
	self.mPostUpdate = Object_Group_PostUpdate;
	self.mDraw = Object_Group_Draw;
}

void() Object_Group_Init =
{
}

void() Object_Group =
{
	className = "Group";
	classInit = Object_Group_Init;
	classSpawn = Object_Group_Spawn;
}