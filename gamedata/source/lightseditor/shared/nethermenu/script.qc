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

#ifdef MENU_DEVELOPER
void(float buf) Menu_Debug_CompiledMenuScript;
void(float buf, string result) Menu_Debug_ExecMenuScript;
#endif

// menuscript custom builtins
#define MENUSCRIPT_MAX_FUNCTIONS 128
ncd_builtin ncd_menuscript_builtins[MENUSCRIPT_MAX_FUNCTIONS] = { NCD_NULL64, NCD_NULL64 };
float ncd_menuscript_numbuiltins;

////////////////////////////////////////
// CODE
////////////////////////////////////////

/*
================================================================================

   NETHERCODE CUSTOM BUILTINS

   beware the prog name in defs
   
================================================================================
*/

// script selection
entity self; // currently selected
.entity selectchain; // next entity in select chain

#define NCD_CHECKSELF_S "nothing is selected, operation cannot go"
#define NCD_CHECKSELF() if (isnotentity(self)) { NetherCode_Warning(NCD_CHECKSELF_S, 0); NCD_RETURN_NULL() }

// add new object to chain, retuns new chain last object
entity ncd_menuscript_select_addtochain(entity first_selected, entity last_selected, string findname)
{
	entity e;
	
	if (!Menu_FindObject(menu_proc, self, findname))
	{
		NetherCode_Warning(strcat("select: cannot find object '", findname, "' from ", self.name), 0);
		return last_selected;
	}
	// check if object was already added
	for (e = first_selected; e; e = e.selectchain)
	{
		if (e == foundobject)
		{
			NetherCode_Warning(strcat("select: object '", findname, "' is already selected'"), 0);
			return last_selected;
		}
	}
	last_selected.selectchain = foundobject;
	foundobject.selectchain = null_entity;
	return foundobject;
}

// select('namespace'[namespace1,'namespace2','namespace3'...]) 
// find object and set it as current, return 1 if cussesful
ncd_builtin ncd_menuscript_select =
{
	entity first_selected, last_selected;
	
	NCD_SAFEPARMCOUNT(1, 8)
	// find first object
	if (!Menu_FindObject(menu_proc, self, NCD_PARM1))
	{
		NetherCode_Warning(strcat("select: cannot find object '", NCD_PARM1, "' from '", self.name, "'"), 0);
		self = null_entity;
		NCD_RETURN("0")
	}
	first_selected = foundobject;
	first_selected.selectchain = null_entity;
	last_selected = first_selected;
	// add more
	if (NCD_PARMNUM >= 2) last_selected = ncd_menuscript_select_addtochain(first_selected, last_selected, NCD_PARM2);
	if (NCD_PARMNUM >= 3) last_selected = ncd_menuscript_select_addtochain(first_selected, last_selected, NCD_PARM3);
	if (NCD_PARMNUM >= 4) last_selected = ncd_menuscript_select_addtochain(first_selected, last_selected, NCD_PARM4);
	if (NCD_PARMNUM >= 5) last_selected = ncd_menuscript_select_addtochain(first_selected, last_selected, NCD_PARM5);
	if (NCD_PARMNUM >= 6) last_selected = ncd_menuscript_select_addtochain(first_selected, last_selected, NCD_PARM6);
	if (NCD_PARMNUM >= 7) last_selected = ncd_menuscript_select_addtochain(first_selected, last_selected, NCD_PARM7);
	if (NCD_PARMNUM >= 8) last_selected = ncd_menuscript_select_addtochain(first_selected, last_selected, NCD_PARM8);
	self = first_selected;
	NCD_RETURN("1")
}

// select+('namespace'[,quiet,'namespace2','namespace3'...) 
// find additional object and add it to selection mask
// does not add object twice
ncd_builtin ncd_menuscript_selectadd =
{
	entity e, last_selected;
	
	NCD_SAFEPARMCOUNT(1, 8)
	// check starting
	if (isnotentity(self))
	{
		NetherCode_Warning("select+: cannot add objects, chain is empty!", 0);
		NCD_RETURN("0")
	}
	// find last selected
	for (e = self; e; e = e.selectchain)
		last_selected = e;
	// add first
	last_selected = ncd_menuscript_select_addtochain(self, last_selected, NCD_PARM1);
	// add more
	if (NCD_PARMNUM >= 2) last_selected = ncd_menuscript_select_addtochain(self, last_selected, NCD_PARM2);
	if (NCD_PARMNUM >= 3) last_selected = ncd_menuscript_select_addtochain(self, last_selected, NCD_PARM3);
	if (NCD_PARMNUM >= 4) last_selected = ncd_menuscript_select_addtochain(self, last_selected, NCD_PARM4);
	if (NCD_PARMNUM >= 5) last_selected = ncd_menuscript_select_addtochain(self, last_selected, NCD_PARM5);
	if (NCD_PARMNUM >= 6) last_selected = ncd_menuscript_select_addtochain(self, last_selected, NCD_PARM6);
	if (NCD_PARMNUM >= 7) last_selected = ncd_menuscript_select_addtochain(self, last_selected, NCD_PARM7);
	if (NCD_PARMNUM >= 8) last_selected = ncd_menuscript_select_addtochain(self, last_selected, NCD_PARM8);
	NCD_RETURN("1")
}

// find('namespace'[,set_selection]) 
// tries to find an object, if succesful - returns 1, can set selectino chain
// does not cast any warnings
ncd_builtin ncd_menuscript_find =
{
	NCD_SAFEPARMCOUNT(1, 2)
	// find first object
	if (!Menu_FindObject(menu_proc, self, NCD_PARM1))
	{
		if (NCD_PARMNUM >= 2 && NCD_PARM2F)
			self = null_entity;
		NCD_RETURN("0")
	}
	if (NCD_PARMNUM >= 2 && NCD_PARM2F)
	{
		self = foundobject;
		self.selectchain = null_entity;
	}
	NCD_RETURN("1")
}

// unselect()
// returns current object back to script starter
ncd_builtin ncd_menuscript_unselect =
{
	NCD_SAFEPARMCOUNT(0, 0)
	self = ncd_self;
	if (isentity(self))
		self.selectchain = null_entity;
	NCD_RETURN_NULL()
}

// focus([silent])
// set current object as menu active item, silen flag are optional
ncd_builtin ncd_menuscript_focus =
{
	NCD_SAFEPARMCOUNT(0, 1)
	NCD_CHECKSELF()
	if (NCD_PARMNUM)
		Menu_SelectItem(self, NCD_PARM1F);
	else
		Menu_SelectItem(self, 0);
	NCD_RETURN_NULL()
}

// update()
// lets object update
ncd_builtin ncd_menuscript_update =
{
	entity e;
	
	NCD_SAFEPARMCOUNT(0, 0)
	for (e = self; isentity(e); e = e.selectchain)
	{
		e.mRunFlags = e.mRunFlags | MENU_RUNFLAG_UPDATEOBJECT;
		Menu_Sys_UpdateObjectNode(e);
	}
	NCD_RETURN_NULL()
}

// focused()
// returns full namespace of curently focused object
ncd_builtin ncd_menuscript_focused =
{
	entity f;
	
	NCD_SAFEPARMCOUNT(0, 0)
	f = Menu_SelectedItem();
	NCD_RETURN(strcat("!!", f.name)) // return full static name
}

// method_get('method_name')
// returns method value of current object, if state is specified it get's method from this state
ncd_builtin ncd_menuscript_method_get =
{
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_CHECKSELF()
	NCD_RETURN(self.getMethod(self, NCD_PARM1))
}

// method_set
// A miltiselect-capable operation, method_set('method_name','value'[,'op']), runs method on current object
ncd_builtin ncd_menuscript_method_set =
{
	float op;
	entity e;
	
	NCD_SAFEPARMCOUNT(2, 3)
	// has certain op
	if (NCD_PARMNUM == 3)
	{
		op = Menu_Sys_MethodOpForString(NCD_PARM3);
		if (op < 0)
		{
			NetherCode_Warning(strcat("method_set: bad op '", NCD_PARM3, "'"), 0);
			op = MMA_SET;
		}
		for (e = self; isentity(e); e = e.selectchain)
			e.setMethod(e, op, NCD_PARM1, NCD_PARM2);
		NCD_RETURN_NULL()
	}
	// default op
	for (e = self; isentity(e); e = e.selectchain)
		e.setMethod(e, MMA_SET, NCD_PARM1, NCD_PARM2);
	NCD_RETURN_NULL()
}

// keycode('key_name')
// returns key code for given name
ncd_builtin ncd_menuscript_keycode =
{
	float keycode;
	
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURNF(Menu_Sys_StringToKeyNum(NCD_PARM1))
}

// keyname('key_code')
// returns key name for given code
ncd_builtin ncd_menuscript_keyname =
{
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURN(Menu_Sys_KeyNumToString(NCD_PARM1F))
}

// keystate('key_code'[,'property'])
// returns current key state for one of properties:
//      pressed : returns 0/1
//      pressdelay : returns how much time it was hold
//      releasedelay : returns how much time ago last release happens
// by default returns 'pressed'
ncd_builtin ncd_menuscript_keystate =
{
	vector kq;
	
	NCD_SAFEPARMCOUNT(1, 2)
	if (NCD_PARMNUM == 1 || NCD_PARM2 == "pressed")
		NCD_RETURNF(Menu_Sys_KeyPressed(NCD_PARM1F))
	kq = Menu_Sys_KeyQuery(NCD_PARM1F);
	if (NCD_PARMNUM == 1 || NCD_PARM2 == "pressed")
		NCD_RETURNF(kq_x)
	if (NCD_PARM2 == "pressdelay")	
	{
		if (kq_x)
			NCD_RETURNF(time - kq_y)
		NCD_RETURNF(kq_z - kq_y)
	}
	if (NCD_PARM2 == "pressdelay")	
		NCD_RETURNF(time - kq_z)
	NetherCode_Warning(strcat("keystate: bad property '", NCD_PARM2, "'"), 0);
	NCD_RETURN("0")
}

// keyevent('keynum'[,'event','process_embedded','process_child','raise_parents'])
// A miltiselect-capable operation, simulates key event on current item
// event = 'press' or 'release' or 'press+release'
// process_child = 1 makes event to be processed on children too
// raise_parents = 1 makes event to be processed on all parents
// warning: this easily can do runaway loop if targeted key will also call keyevent, 
// so there is a limit of maximum 100 keyevent calls per frame
float ncd_menuscript_keyevent_calltime;
float ncd_menuscript_keyevent_callcount;
ncd_builtin ncd_menuscript_keyevent =
{
	float tEventHold, tEventRelease, tProcessEmbedded, tProcessChildren, tRaiseParents;
	entity e;
	
	// runaway loop detector
	if (time > ncd_menuscript_keyevent_calltime)
	{
		ncd_menuscript_keyevent_calltime = time;
		ncd_menuscript_keyevent_callcount = 0;
	}
	ncd_menuscript_keyevent_callcount = ncd_menuscript_keyevent_callcount + 1;
	if (ncd_menuscript_keyevent_callcount > 100)
	{
		NetherCode_Warning("keyevent: maximum number of per-frame hits (100) reached, runaway loop?", 0);
		NCD_RETURN_NULL()
	}
	NCD_SAFEPARMCOUNT(1, 4)
	tProcessEmbedded = 1;
	tProcessChildren = 0;
	tRaiseParents = 0;
	if (NCD_PARMNUM > 1)
	{
		tEventHold = 0;
		tEventRelease = 0;
		if (NCD_PARM2 == "hold")
			tEventHold = 1;
		else if (NCD_PARM2 == "release")
			tEventRelease = 1;
		else if (NCD_PARM2 == "hold+release")	
		{
			tEventHold = 1;
			tEventRelease = 1;
		}
		else NetherCode_Warning(strcat("keyevent: bad event name '", NCD_PARM2, "'"), 0);
	}
	else 
	{	
		tEventHold = 1;
		tEventRelease = 1;
	}
	if (NCD_PARMNUM > 2)
		tProcessEmbedded = NCD_PARM3F;
	if (NCD_PARMNUM > 3)
		tProcessChildren = NCD_PARM4F;
	if (NCD_PARMNUM > 4)
		tRaiseParents = NCD_PARM5F;
	for (e = self; isentity(e); e = e.selectchain)
	{
		if (tEventHold)
			Menu_Sys_KeyEventOnNode(e, KEYEVENT_HOLD, NCD_PARM1F, KR_FALSE, tProcessEmbedded, tProcessChildren, tRaiseParents);
		if (tEventRelease)
			Menu_Sys_KeyEventOnNode(e, KEYEVENT_RELEASE, NCD_PARM1F, KR_FALSE, tProcessEmbedded, tProcessChildren, tRaiseParents);
	}	
	NCD_RETURN_NULL()
}

// sendkey('key_code'[,'release_delay'])
// sends a virtual key press to system, it will be applied next frame
// release delay is 0.1 by default
ncd_builtin ncd_menuscript_sendkey =
{
	NCD_SAFEPARMCOUNT(1, 2)
	Menu_AddKeyEvent(KEYEVENT_HOLD, NCD_PARM1F, "", 0);
	if (NCD_PARMNUM > 1)
		Menu_AddKeyEvent(KEYEVENT_RELEASE, NCD_PARM1F, "", NCD_PARM2F);
	else
		Menu_AddKeyEvent(KEYEVENT_RELEASE, NCD_PARM1F, "", 0.1);
	NCD_RETURN_NULL()
}

// sendkeys('keystring'[,'release_delay'])
// sends a several virtual key prtessings to system, they will be applied next frame
// release delay is 0.1 by default
ncd_builtin ncd_menuscript_sendkeys =
{
	float p, l, d, k;
	
	NCD_SAFEPARMCOUNT(1, 2)
	d = 0.1;
	if (NCD_PARMNUM > 1)
		d = NCD_PARM2F;
	l = tokenizebyseparator(NCD_PARM1, "+");
	for(p = 0; p < l; p++)
	{
		k = Menu_Sys_StringToKeyNum(argv(p));
		Menu_AddKeyEvent(KEYEVENT_HOLD, k, "", 0);
		Menu_AddKeyEvent(KEYEVENT_RELEASE, k, "", d);
	}	
	NCD_RETURN_NULL()
}

// sound('sample'[,'volume'])
// play sound
ncd_builtin ncd_menuscript_sound =
{
	NCD_SAFEPARMCOUNT(1, 2)
	if (NCD_PARMNUM == 2)
		localcmd(strcat("playvol \"sound/", NCD_PARM1, "\" ", NCD_PARM2));
	else
		localcmd(strcat("play \"sound/", NCD_PARM1, "\""));
	NCD_RETURN_NULL()
}

// return info about savegame
ncd_builtin ncd_menuscript_get_savegame_header =
{
	float fh, p;
	string s, v;

	NCD_SAFEPARMCOUNT(1, 1)
	if (NCD_PARMNUM == 2)
		s = strcat(NCD_PARM2, NCD_PARM1, ".sav");
	else
		s = strcat("saves/", NCD_PARM1, ".sav");
	fh = fopen(s, FILE_READ);
	if (fh < 0)
		NCD_RETURN("--------------- EMPTY ---------------")
	fgets(fh);
	s = fgets(fh);
	fclose(fh);
	NCD_RETURN(s)
}

// save_game('slot_name'[, 'savpath']), saves game to specified slot
// return 0 if failed, 1 if proceeded
ncd_builtin ncd_menuscript_save_game =
{
	string s;
	
	NCD_SAFEPARMCOUNT(1, 2)
	#ifdef TARG_MENUPROGS
	if (clientstate() != CLIENTSTATE_CONNECTED)
		NCD_RETURN("0")
	#else
	if (isdemo())
		NCD_RETURN("0")
	#endif3
	if (NCD_PARMNUM == 2)
		s = strcat(NCD_PARM2, NCD_PARM1, ".sav");
	else
		s = strcat("saves/", NCD_PARM1, ".sav");
	#ifdef TARG_MENUPROGS
	localcmd("togglemenu\n");
	#endif
	localcmd(strcat("save \"", s, "\"\n"));
	NCD_RETURN("1")
}

// load_game('slot_name'[, 'savpath'])
// loads a game from specified slot
ncd_builtin ncd_menuscript_load_game =
{
	string s;
	
	NCD_SAFEPARMCOUNT(1, 1)
	if (NCD_PARMNUM == 2)
		s = strcat(NCD_PARM2, NCD_PARM1, ".sav");
	else
		s = strcat("saves/", NCD_PARM1, ".sav");
	localcmd(strcat("load \"", s, "\"\n"));
	#ifdef TARG_MENUPROGS
	localcmd("togglemenu\n");
	#endif
	NCD_RETURN("1")
}

// dataeventforcode('code')
// convert event code to string
ncd_builtin ncd_menuscript_dataeventforcode =
{
	float p;
	
	NCD_SAFEPARMCOUNT(1, 1)
	p = NCD_PARM1F;
	if (p >= 0 && p < MENU_NUMDATAEVENTS)
		NCD_RETURN(dataeventnames[p])
	NCD_RETURN("null")
}
float ncd_menuscript_dataeventcodeforname(string n)
{
	float p;
	
	if (n == "null")
		return -1;
	for (p = 0; p < MENU_NUMDATAEVENTS; p++)
		if (dataeventnames[p] == n)
			break;
	if (p < MENU_NUMDATAEVENTS) // found
		return p;
	NetherCode_Warning(strcat("bad event name '", n, "'"), 1);
	return -1;
}

// dataevent('event_name')
// A miltiselect-capable operation
// raises data vent on current entity
// event names: auto (picks item's autoEvent key), sync, send, test, endtest, restore, reset, resync, get (datasource only event), set (datasource only event) 
ncd_builtin ncd_menuscript_dataevent =
{
	entity e;
	float ev;
	
	NCD_SAFEPARMCOUNT(1, 1)
	ev = ncd_menuscript_dataeventcodeforname(NCD_PARM1);
	if (ev >= 0)
		for (e = self; isentity(e); e = e.selectchain)
			Menu_DataSource_DataEvent(null_entity, e, ev);
	NCD_RETURN_NULL()
}

// datarefresh()
// A miltiselect-capable operation
// makes object reload it's value from corresponding data
ncd_builtin ncd_menuscript_datarefresh =
{
	entity e;
	
	NCD_SAFEPARMCOUNT(0, 0)
	for (e = self; isentity(e); e = e.selectchain)
		if (isentity(e._datasource))
			Menu_RefreshDataObject(e, e._datasource);
	NCD_RETURN_NULL()
}

// datasource_advance('advance'[,'auto_event','cycle'])
// A miltiselect-capable operation
// makes slider of list datasource object adjust it's value
ncd_builtin ncd_menuscript_datasource_advance =
{	
	entity e;
	float ev;
	
	NCD_SAFEPARMCOUNT(1, 3)
	if (NCD_PARMNUM > 1)
	{
		ev = ncd_menuscript_dataeventcodeforname(NCD_PARM2);
		if (NCD_PARMNUM > 2)	
		{
			for (e = self; isentity(e); e = e.selectchain)
				if (isentity(e._datasource))
					Menu_DataSource_Advance(e, e._datasource, NCD_PARM1F, NCD_PARM3F, ev);
		}
		else
		{
			for (e = self; isentity(e); e = e.selectchain)
				if (isentity(e._datasource))
					Menu_DataSource_Advance(e, e._datasource, NCD_PARM1F, 0, ev);
		}
		NCD_RETURN_NULL()
	}
	for (e = self; isentity(e); e = e.selectchain)
		if (isentity(e._datasource))
			Menu_DataSource_Advance(e, e._datasource, NCD_PARM1F, 0, -1);
	NCD_RETURN_NULL()
}
	
// datasource_setpos('pos'[,'auto_event'])
// A miltiselect-capable operation
// makes slider of list datasource object adjust it's value
ncd_builtin ncd_menuscript_datasource_setpos =
{	
	entity e;
	float ev;
	
	NCD_SAFEPARMCOUNT(1, 2)
	if (NCD_PARMNUM == 2)
	{
		ev = ncd_menuscript_dataeventcodeforname(NCD_PARM2);
		for (e = self; isentity(e); e = e.selectchain)
			if (isentity(e._datasource))
				Menu_DataSource_SetPos(e, e._datasource, NCD_PARM1F, ev);
		NCD_RETURN_NULL()
	}
	for (e = self; isentity(e); e = e.selectchain)
		if (isentity(e._datasource))
			Menu_DataSource_SetPos(e, e._datasource, NCD_PARM1F, -1);
	NCD_RETURN_NULL()
}

// datasource_setvalue('value'[,'auto_event'])
// A miltiselect-capable operation
// set new value to text datasource object
ncd_builtin ncd_menuscript_datasource_setvalue =
{	
	entity e;
	float ev;
	
	NCD_SAFEPARMCOUNT(1, 2)
	if (NCD_PARMNUM == 2)
	{
		ev = ncd_menuscript_dataeventcodeforname(NCD_PARM2);
		for (e = self; isentity(e); e = e.selectchain)
			if (isentity(e._datasource))
				Menu_DataSource_SetValue(e, e._datasource, NCD_PARM1, ev);
		NCD_RETURN_NULL()
	}
	for (e = self; isentity(e); e = e.selectchain)
		if (isentity(e._datasource))
			Menu_DataSource_SetValue(e, e._datasource, NCD_PARM1, -1);
	NCD_RETURN_NULL()
}

// trigger()
// A miltiselect-capable operation
// causes trigger even on item
ncd_builtin ncd_menuscript_trigger =
{
	entity e;
	
	NCD_SAFEPARMCOUNT(0, 0)
	for (e = self; isentity(e); e = e.selectchain)
		Menu_TriggerCast(e);
	NCD_RETURN_NULL()
}

// name();
// returns name of current object
ncd_builtin ncd_menuscript_name = 
{ 
	NCD_SAFEPARMCOUNT(0, 0)
	NCD_RETURN(self.name)
}

// classname();
// returns class name of current object
ncd_builtin ncd_menuscript_classname = 
{ 
	NCD_SAFEPARMCOUNT(0, 0)
	NCD_RETURN(self.classname)
}

// localname();
// returns localname of current object
ncd_builtin ncd_menuscript_localname = 
{ 
	NCD_SAFEPARMCOUNT(0, 0)
	NCD_RETURN(self.localname)
}

// proc();
// returns proc name of current object
ncd_builtin ncd_menuscript_proc = 
{ 
	NCD_SAFEPARMCOUNT(0, 0)
	NCD_RETURN(self._proc.name)
}

// isdemo()
// returns 1 if playing demo, otherwise 0
ncd_builtin ncd_menuscript_isdemo = 
{ 
	NCD_SAFEPARMCOUNT(0, 0)
	NCD_RETURNF(isdemo())
}

// isserver()
// returns 1 if server, otherwise 0
ncd_builtin ncd_menuscript_isserver = 
{ 
	NCD_RETURNF(isserver())
}

// isconnected()
// returns 1 if connected, otherwise 0
// for CSQC always returns 1
ncd_builtin ncd_menuscript_isconnected = 
{ 
	NCD_SAFEPARMCOUNT(0, 0)
#ifdef TARG_MENUPROGS
	if (clientstate() == CLIENTSTATE_CONNECTED)
		NCD_RETURN("1")
	NCD_RETURN("0")
#else
	NCD_RETURN("1")
#endif
}

// getresolutions('width', 'height'[,'glue'])
// returns list of resulutions, put 0 or 1 whether you want wihdth or height or both, 'glue' works only when width and height requested, default is ' '
// works only in menu.dat
ncd_builtin ncd_menuscript_getresolutions = 
{
	NCD_SAFEPARMCOUNT(2, 3)
#ifdef TARG_MENUPROGS
	float n, usewidth, useheight;
	string l, clue;
	vector v;
	
	// read parms
	usewidth = NCD_PARM1F;
	useheight = NCD_PARM2F;
	clue = " ";
	if (NCD_PARMNUM > 2)
		clue = NCD_PARM3;
	if (!usewidth && !useheight)
	{
		NetherCode_Warning("getresolutions: bad parms", 0);
		NCD_RETURN_NULL()
	}
	
	// construct list
	l = "";
	for (n = 0; ; n++)
	{
		v = getresolution(n, 1);
		if (!v_x)
			break;
		if (usewidth && useheight)
			l = strcat(l, "'", ftos(v_x), clue, ftos(v_y), "'");
		else if (usewidth)
			l = strcat(l, "'", ftos(v_x), "'");
		else
			l = strcat(l, "'", ftos(v_y), "'");
	}
	NCD_RETURN(l)
#else
	NetherCode_Warning("getresolutions: only usable in menu.dat", 0);
	NCD_RETURN_NULL()
#endif	
}

// precache('file1'[,'file2'...])
// precache model or pic for menu puproses
ncd_builtin ncd_menuscript_precache = 
{
	NCD_SAFEPARMCOUNT(1, 8)
	Menu_Precache(NCD_PARM1);
	if (NCD_PARMNUM >= 2)
		Menu_Precache(NCD_PARM2);
	if (NCD_PARMNUM >= 3)
		Menu_Precache(NCD_PARM3);
	if (NCD_PARMNUM >= 4)
		Menu_Precache(NCD_PARM4);
	if (NCD_PARMNUM >= 5)
		Menu_Precache(NCD_PARM5);
	if (NCD_PARMNUM >= 6)
		Menu_Precache(NCD_PARM6);
	if (NCD_PARMNUM >= 7)
		Menu_Precache(NCD_PARM7);
	if (NCD_PARMNUM >= 8)
		Menu_Precache(NCD_PARM8);		
	NCD_RETURN_NULL()
}

// togglemenu([state])
// toggles menu, only for menu.dat
#ifdef TARG_MENUPROGS
void() m_toggle;
void() m_hide;
void() m_display;
#endif
ncd_builtin ncd_menuscript_togglemenu = 
{
	NCD_SAFEPARMCOUNT(0, 1)
#ifdef TARG_MENUPROGS
	if (!NCD_PARMNUM)
		m_toggle();
	{
		if (NCD_PARM1F)
			m_display();
		else
			m_hide();
	}
#else
	NetherCode_Warning("togglemenu: only usable in menu.dat", 0);
#endif
	NCD_RETURN_NULL()
}

// freepic(picname,[picname2,...])
// uncache picture(s)
ncd_builtin ncd_menuscript_freepic = 
{
	NCD_SAFEPARMCOUNT(1, 8)
	freepic(NCD_PARM1);
	if (NCD_PARMNUM >= 2)
		freepic(NCD_PARM2);
	if (NCD_PARMNUM >= 3)
		freepic(NCD_PARM3);
	if (NCD_PARMNUM >= 4)
		freepic(NCD_PARM4);
	if (NCD_PARMNUM >= 5)
		freepic(NCD_PARM5);
	if (NCD_PARMNUM >= 6)
		freepic(NCD_PARM6);
	if (NCD_PARMNUM >= 7)
		freepic(NCD_PARM7);
	if (NCD_PARMNUM >= 8)
		freepic(NCD_PARM8);		
	NCD_RETURN_NULL()
}

/*
================================================================================

   NETHERCODE WRAPPER

================================================================================
*/

float MenuScript_Compile(string s) // return compiled script
{
#ifdef MENU_DEVELOPER
	float compilation;
	compilation = NetherCode_Compile(menu_proc.procScriptProg, s);
	Menu_Debug_CompiledMenuScript(compilation);
	return compilation;
#else
	return NetherCode_Compile(menu_proc.procScriptProg, s);
#endif
}

string MenuScript_Run(entity e, float s)
{
#ifdef MENU_DEVELOPER
	string c;
	c = NetherCode_Run(menu_proc.procScriptProg, e, s);
	Menu_Debug_ExecMenuScript(s, c);
	return c;
#else
	return NetherCode_Run(menu_proc.procScriptProg, e, s);
#endif
}

float(float function_index) MenuScript_Builtin =
{
	if (function_index <= 0 || function_index >= ncd_menuscript_numbuiltins)
		return 0;
	ncd_funcf = ncd_menuscript_builtins[function_index];
	return 1;
}

void MenuScript_RegisterBuiltin(entity menuproc, ncd_builtin function, string function_name)
{
	float function_index;
	var ncd_builtin f;
	
	// get index
	for (function_index = 1; function_index < ncd_menuscript_numbuiltins; function_index++)
	{
		f = ncd_menuscript_builtins[function_index];
		if (f == function)
			break;
	}
	// create index?
	if (function_index >= ncd_menuscript_numbuiltins)
	{
		if (function_index >= MENUSCRIPT_MAX_FUNCTIONS)
		{
			warning("MenuScript_RegisterBuiltin: MENUSCRIPT_MAX_FUNCTIONS exceeded\n");
			return;
		}
		ncd_menuscript_builtins[function_index] = function;
		ncd_menuscript_numbuiltins = function_index + 1;
	}
	NetherCode_RegisterBuiltin(menuproc.procScriptProg, function_index, function_name);
}

void MenuScript_CreateProg(entity menuproc, string pname) =
{
	menuproc.procScriptProg = NetherCode_CreateProg(strcat("menuscript.", pname), MenuScript_Builtin);
	// create builtins
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_select, "select");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_find, "find");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_selectadd, "select+");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_unselect, "unselect");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_focus, "focus");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_update, "update");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_focused, "focused");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_method_get, "method_get");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_method_set, "method_set");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_keycode, "keycode");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_keyname, "keyname");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_keystate, "keystate");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_keyevent, "keyevent");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_sendkey, "sendkey");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_sendkeys, "sendkeys");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_sound, "sound");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_get_savegame_header, "get_savegame_header");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_save_game, "save_game");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_load_game, "load_game");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_dataeventforcode, "dataeventforcode");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_dataevent, "dataevent");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_datarefresh, "datarefres");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_datasource_advance, "datasource_advance");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_datasource_setpos, "datasource_setpos");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_datasource_setvalue, "datasource_setvalue");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_trigger, "trigger");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_name, "name");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_classname, "classname");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_localname, "localname");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_proc, "proc");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_isdemo, "isdemo");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_isserver, "isserver");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_isconnected, "isconnected");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_getresolutions, "getresolutions");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_precache, "precache");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_togglemenu, "togglemenu");
	MenuScript_RegisterBuiltin(menuproc, ncd_menuscript_freepic, "freepic");
}

void MenuScript_DeleteProg(float prog) =
{
	NetherCode_RemoveProg(prog);
}