////////////////////////////////////////
// Nether Menu System source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

////////////////////////////////////////
// CODE
////////////////////////////////////////

/*
===================================================

 STANDART TRIGGER

===================================================
*/

void() Object_Trigger_Trigger = {}
void() Object_Trigger_Spawn =
{
	self.mTrigger = Object_Trigger_Trigger;
}

void() Object_Trigger_Init = 
{
}
void() Object_Trigger =
{
	className = "Trigger";
	classInit = Object_Trigger_Init;
	classSpawn = Object_Trigger_Spawn;
}


/*
===================================================
MultiTrigger

when triggered
fires self and then all children (if no NOCHILDREN flag)
===================================================
*/

void() Object_MultiTrigger_Trigger =
{
	entity tChild;
	
	if (self.mFlags & MENU_FLAG_NOCHILDREN)
		return;
	for (tChild = self._child; tChild; tChild = tChild._next)
		Menu_TriggerCast(tChild);	
}

void() Object_MultiTrigger_Spawn =
{
	self.mTrigger = Object_MultiTrigger_Trigger;
	Menu_Hide(self, "alwshide");
}

void() Object_MultiTrigger_Init = 
{
	Menu_Sys_StateMap_AddMethod(self, ":normal", "nonsolid", "1");
}

void() Object_MultiTrigger =
{
	className = "MultiTrigger";
	classInit = Object_MultiTrigger_Init;
	classSpawn = Object_MultiTrigger_Spawn;
}

/*
===================================================

 HOTKEY TRIGGER
 the only difference of it is it has datasource and link it to self.hotkey
 so it's hotkey could be configurable

===================================================
*/

Menu_DataRefresh Object_Hotkey_RefreshData =
{
	self.setMethod(self, MMA_SET, "hotkey", tSource.value);
}

Menu_MethodSetEvent Object_Hotkey_SetMethod =
{
	Menu_Sys_SetMethod(tObject, tOp, tMethod, tValue);
	Object_DataUser_SetMethod(tObject, tOp, tMethod, tValue);
}

void() Object_Hotkey_Trigger = {}
void() Object_Hotkey_Spawn =
{
	self.mTrigger = Object_Hotkey_Trigger;
	self.mDataRefresh = Object_Hotkey_RefreshData;
	Object_DataUser_Spawn();
}

void() Object_Hotkey_Init = 
{
	self.setMethod = Object_Hotkey_SetMethod;
}

void() Object_Hotkey =
{
	className = "Hotkey";
	classInit = Object_Hotkey_Init;
	classSpawn = Object_Hotkey_Spawn;
}
