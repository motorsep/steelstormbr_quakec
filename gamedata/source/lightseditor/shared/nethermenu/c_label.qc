////////////////////////////////////////
// Nether Menu System source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

/*
 Label
 
 visual object
 draws background-text
 is size is not set it will be set automatically to text size
*/

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

////////////////////////////////////////
// CODE
////////////////////////////////////////

/*
===================================================

 DATA

===================================================
*/

// void(entity tSource)
Menu_DataRefresh Object_Label_RefreshData =
{
	self.setMethod(self, MMA_SET, "text", Menu_DataSource_GetDescValue(self, tSource));
}

Menu_MethodSetEvent Object_Label_SetMethod =
{
	Menu_Sys_SetMethod(tObject, tOp, tMethod, tValue);
	Object_DataUser_SetMethod(tObject, tOp, tMethod, tValue);
}

/*
===================================================

 DRAW

===================================================
*/

void() Object_Label_Draw =
{
	ObjectLib_Background_Draw();
	ObjectLib_Text_Draw();
	ObjectLib_Foreground_Draw();
}

/*
===================================================

 UPDATE

===================================================
*/

void() Object_Label_PreUpdate =
{
	ObjectLib_Text_PreUpdate();
}

void() Object_Label_PostUpdate =
{
	ObjectLib_Text_PostUpdate();
}

/*
===================================================

 SPAWN

===================================================
*/

void() Object_Label_Spawn =
{
	self.mPreUpdate = Object_Label_PreUpdate;
	self.mPostUpdate = Object_Label_PostUpdate;
	self.mDataRefresh = Object_Label_RefreshData;
	self.mDraw = Object_Label_Draw;
	
	Object_DataUser_Spawn();
}

void() Object_Label_Init =
{
	self.setMethod = Object_Label_SetMethod;
	// start defaults
	Menu_Sys_StateMap_AddMethod(self, ":normal", "textColor", "'1 1 1'");
}

void() Object_Label =
{
	className = "Label";
	classInit = Object_Label_Init;
	classSpawn = Object_Label_Spawn;
}
