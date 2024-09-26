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

Menu_DataEvent Object_Container_DataEvent =
{
	entity tChild;
	for (tChild = self._child; tChild; tChild = tChild._next)
		Menu_RaiseDataEvent(tChild, tEvent);
	return 0;
}

Menu_KeyEvent Object_Container_Key =
{
	float tKeyReturnCode;
	
	entity tChild;
	for (tChild = self._child; tChild; tChild = tChild._next)
		tKeyReturnCode = tKeyReturnCode | Menu_Sys_KeyEventOnNode(tChild, tEvent, tKeyCode, tKeySealed, 1, 0, 0);
	return tKeyReturnCode;
}

void() Object_Container_Init =
{
	self.mDataEvent = Object_Container_DataEvent;
	self.mKey = Object_Container_Key;
	Menu_Sys_StateMap_AddMethod(self, ":normal", "container", "1");
}

void() Object_Container =
{
	className = "Container";
	classInit = Object_Container_Init;
	classSpawn = null_function;
}