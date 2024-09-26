////////////////////////////////////////
// Nether Menu System source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

/*
KeyRouter

this object will route key events to "link"

it uses two scripts:

"onInput" script
keycode is passed as 'key' var
event is passed as 'release' = 0 for pressed and 'release' = 1 for released
should return 0 or 1 (0 to ignore key, 1 to route)

when is decided to route key then "onOutput" script is called
keycode is passed as 'key' var
event is passed as 'release' = 0 for pressed and 'release' = 1 for released
should return key code to be sent to target (so you can remap key!)
you can leave "onOutput" empty - then key will be transformed as-is
onOutput can still cancel key routing by returning -1
*/

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

////////////////////////////////////////
// CODE
////////////////////////////////////////

Menu_KeyEvent Object_KeyRouter_Key =
{
	float tAutoEvent, tKeyReturn;
	string s, link2, link3, link4;
	entity routelink;
		
	if (isnotentity(self._link))
		return KR_FALSE;

	// route in
	if (self.onInput)
	{
		MenuScript_SetVar("key", ftos(tKeyCode));
		MenuScript_SetVar("sealflags", ftos(tKeySealed));
		MenuScript_SetVar("release", ftos(tEvent));
		s = MenuScript_Run(self, self.onInput);
		tKeyReturn = stof(s);
		if (!tKeyReturn)
			return KR_FALSE;
	}
	// transformed routing of key event
	if (self.onOutput)
	{
		routelink = self._link;
		MenuScript_SetVar("key", ftos(tKeyCode));
		MenuScript_SetVar("sealflags", ftos(tKeySealed));
		MenuScript_SetVar("release", ftos(tEvent));
		MenuScript_SetVar("keyreturn", ftos(self.autoEvent));
		MenuScript_SetVar("link", "");
		MenuScript_SetVar("link2", "");
		MenuScript_SetVar("link3", "");
		MenuScript_SetVar("link4", "");
		s = MenuScript_Run(self, self.onOutput);
		tAutoEvent = stof(MenuScript_GetVar("keyreturn"));
		tKeyCode = stof(s);
		if (tKeyCode >= 0)
		{
			link2 = MenuScript_GetVar("link2");
			link3 = MenuScript_GetVar("link3");
			link4 = MenuScript_GetVar("link4");
			// route to link, call event,
			s = MenuScript_GetVar("link");
			if (s != "")
				routelink = Menu_GetItem(s);
			tKeyReturn = Menu_Sys_KeyEventOnNode(routelink, tEvent, tKeyCode, tKeySealed, 1, 0, 0);
			// route to extra links
			if (link2 != "") { routelink = Menu_GetItem(link2); Menu_Sys_KeyEventOnNode(routelink, tEvent, tKeyCode, tKeySealed, 1, 0, 0); }
			if (link3 != "") { routelink = Menu_GetItem(link3); Menu_Sys_KeyEventOnNode(routelink, tEvent, tKeyCode, tKeySealed, 1, 0, 0); }
			if (link4 != "") { routelink = Menu_GetItem(link4); Menu_Sys_KeyEventOnNode(routelink, tEvent, tKeyCode, tKeySealed, 1, 0, 0); }
		}
		// if autoEvent is 0 - return key result of linked onject, if -1 - always return 0
		if (!tAutoEvent)
			return tKeyReturn;
		if (tAutoEvent < 0)	
			return 0;
		return tAutoEvent;
	}
	// simple route key event
	tKeyReturn = Menu_Sys_KeyEventOnNode(self._link, tEvent, tKeyCode, tKeySealed, 1, 0, 0);
	// if autoEvent is 0 - return key result of linked onject, if -1 - always return 0
	if (!self.autoEvent)
		return tKeyReturn;
	if (self.autoEvent < 0)	
		return 0;	
	return self.autoEvent;
}

void() Object_KeyRouter_Spawn =
{
	self.mKey = Object_KeyRouter_Key;
	self.setMethod(self, MMA_SET, "embedded", "1");
}

void() Object_KeyRouter_Init =
{
	Menu_Sys_StateMap_AddMethod(self, ":normal", "autoEvent", "0");
}

void() Object_KeyRouter =
{
	className = "KeyRouter";
	classInit = Object_KeyRouter_Init;
	classSpawn = Object_KeyRouter_Spawn;
}