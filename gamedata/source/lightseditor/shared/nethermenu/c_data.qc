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

// data events
#define MENU_DATAENTRY_SYNC			0	// load value/syncValue from storage
#define MENU_DATAENTRY_SEND			1	// send self value to storage and sync to it
#define MENU_DATAENTRY_TEST			2	// send self value but do not sync it with syncValue
#define MENU_DATAENTRY_ENDTEST		3	// restore storage value to sync value	
#define MENU_DATAENTRY_RESTORE		4	// restore self value from syncValue
#define MENU_DATAENTRY_RESET		5	// restore self value from default value
#define MENU_DATAENTRY_RESYNC		6	// check if outer storage is changed, 
											// if is then if self._syncValue == self.value - raise full synchronization
											// else just set self._syncValue to new outer storage value												
#define MENU_DATASOURCE_GET			7
#define MENU_DATASOURCE_SET			8
#define MENU_DATACONTROL_AUTO		9	// pick control's dataevent

// data event names
#define MENU_NUMDATAEVENTS		10
string dataeventnames[MENU_NUMDATAEVENTS] =
{
	"sync",
	"send",
	"test",
	"endtest",
	"restore",
	"reset",
	"resync",
	"get",
	"set",
	"auto"
};

// must be set on object that uses data
#define Menu_DataRefresh void(entity tSource)
.Menu_DataRefresh mDataRefresh;

// must be set on stream that sends data
#define Menu_DataEvent float(float tEvent)
.Menu_DataEvent mDataEvent;
#define Menu_DataEntryRead string()
.Menu_DataEntryRead mDataRead;
#define Menu_DataEntryWrite void(string tValue)
.Menu_DataEntryWrite mDataWrite;

.string _syncValue;
.string _desc;

////////////////////////////////////////
// CODE
////////////////////////////////////////

// escape ' and " that will be expanded on tokenize
string Menu_Data_EscapeToStaticList(string s)
{
	float p;
	string s1, s2;
	
	// escape '
	for (p = strstr(s, "'"); p >= 0; p = strstrofs(s, "'", p+1))
	{
		if ((p == 0 || substring(s, p-1, 1) != "\\") && (p < 1 || substring(s, p-2, 1) != "\\"))
		{
			s1 = substring(s, 0, p);
			s2 = substring(s, p, 100000); 
			s = strcat(s1, "\\", s2);
			p++;
		}
	}
	// escape "
	for (p = strstr(s, "\""); p >= 0; p = strstrofs(s, "\"", p+1))
	{
		if ((p == 0 || substring(s, p-1, 1) != "\\") && (p < 1 || substring(s, p-2, 1) != "\\"))
		{
			s1 = substring(s, 0, p);
			s2 = substring(s, p, 100000); 
			s = strcat(s1, "\\", s2);
			p++;
		}
	}
	
	return s;
}

/*
================================================================================

   DATA USERS COMMON

================================================================================
*/

// raise data event on data object (whatever it will be - DataSource, DataEntry or other)
float Menu_RaiseDataEvent(entity tObject, float tEvent)
{
	float tProcessed;
	entity tOldSelf;

	// print("DataEvent: ", dataeventnames[tEvent], " on ", tObject.name, "\n");	

	tOldSelf = self;
	self = tObject;
	if (self.mDataEvent)
		tProcessed = self.mDataEvent(tEvent);
	self = tOldSelf;
		
	return tProcessed;
}

void Menu_UnlinkDynamicDataObject(entity tObject)
{
	entity tSource;
	
	// already unlinked?
	if (!tObject._datasource)
		return; 
		
	// drop link
	tSource = tObject._datasource;
	tObject._datasource = null_entity;
	
	// drop backlink
	#define try(f) if (tSource.f == tObject) { tSource.f = null_entity; return; }
	try(_datauser1)
	try(_datauser2)
	try(_datauser3)
	try(_datauser4)
	try(_datauser5)
	try(_datauser6)
	try(_datauser7)
	try(_datauser8)
	#undef try
	// actually this is impossible (unless menu structure is damaged), but well
	Menu_Warning(tSource, strcat("Menu_UnlinkDynamicDataObject: failed to unlink '", tObject.name, "' from '", tSource.name, "' - not linked"));
}

void Menu_LinkDynamicDataObject(entity tSource, entity tObject) =
{	
	entity tOldSelf;
	
	// unlink one
	if (isnotentity(tSource))
	{
		Menu_UnlinkDynamicDataObject(tObject);
		return;
	}
	
	// set datasource
	tObject._datasource = tSource;
	
	// check if already linked
	#define try(f) if (tSource.f == tObject) return;
	try(_datauser1)
	try(_datauser2)
	try(_datauser3)
	try(_datauser4)
	try(_datauser5)
	try(_datauser6)
	try(_datauser7)
	try(_datauser8)
	#undef try
	// link data user to empty slot
	#define try(f) if (isnotentity(tSource.f) || tSource.f._datasource != tSource) { tSource.f = tObject; }
	try(_datauser1)
	else try(_datauser2)
	else try(_datauser3)
	else try(_datauser4)
	else try(_datauser5)
	else try(_datauser6)
	else try(_datauser7)
	else try(_datauser8)
	else 
		Menu_Warning(tSource, strcat("Menu_LinkDynamicDataObject: failed connecting ", tObject.name, " - no free sockets, no autoupdate will be performed"));
	#undef try
}

void Menu_LinkStaticDataObject(entity tSource, entity tObject) =
{
	// link data user to empty slot
	#define try(f) if (isnotentity(tSource.f)) { tSource.f = tObject; }
	     try(_datauserstatic1)
	else try(_datauserstatic2)
	else try(_datauserstatic3)
	else try(_datauserstatic4)
	else 
		Menu_Warning(tSource, strcat("Menu_LinkStaticDataObject: failed connecting ", tObject.name, " - no free sockets, no autoupdate will be performed"));
	#undef try
}

string Menu_DataSource_GetDescValue(entity tControl, entity tSource);
void Menu_RefreshDataObject(entity tObject, entity tSource)
{
	entity tOldSelf;
	
	// script event
	if (tObject.onRefresh)
	{
		MenuScript_SetVar("value", tSource.value);
		MenuScript_SetVar("source", tSource._datasource.name);
		MenuScript_SetVar("sourcevalue", tSource._datasource.value);
		MenuScript_SetVar("syncvalue", tSource._syncValue);
		MenuScript_SetVar("descvalue", Menu_DataSource_GetDescValue(tObject, tSource));
		MenuScript_Run(tObject, tObject.onRefresh);
		return;
	}
	
	// system event
	tOldSelf = self;
	self = tObject;
	if (self.mDataRefresh)
		self.mDataRefresh(tSource);
	self = tOldSelf;
}

void Menu_RefreshLinkedDataObjects(entity tSource)
{
	// run over current users table
	// exclude users that do not match (i.e. changed datasource)
	#define try(f) if (isentity(tSource.f)) { if (tSource.f._datasource != tSource) tSource.f = null_entity; else Menu_RefreshDataObject(tSource.f, tSource); }
	try(_datauser1)
	try(_datauser2)
	try(_datauser3)
	try(_datauser4)
	try(_datauser5)
	try(_datauser6)
	try(_datauser7)
	try(_datauser8)
	#undef try
	// run static users
	#define try(f) if (isentity(tSource.f)) { Menu_RefreshDataObject(tSource.f, tSource); }
	try(_datauserstatic1)
	try(_datauserstatic2)
	try(_datauserstatic3)
	try(_datauserstatic4)
	#undef try
}

// since ierarchy of data objects is not fixed for now we should rescan all tree
// refresh all sub-entries to have same value
// this useful when multiple data sources connected to same entry
void Menu_RefreshDataSources(entity tObject)
{
	entity tChild;
	
	Menu_RefreshLinkedDataObjects(tObject);
	// update chidren
	for (tChild = tObject._child; tChild; tChild = tChild._next)
		Menu_RefreshDataSources(tChild);
}

Menu_MethodSetEvent Object_DataUser_SetMethod =
{
	entity tSource;
	
	if (tMethod != "source")
		return;
	// find source
	if (tValue == "")
		foundobject = null_entity;
	else if (!Menu_FindObject(menu_proc, tObject, tValue))
		Menu_Warning(tObject, strcat("DataUser_SetMethod: data source ", tValue, " not found"));
	Menu_LinkDynamicDataObject(foundobject, tObject);
}

/*
================================================================================

   DATASOURCE COMMON

================================================================================
*/

void() Object_DataUser_Spawn =
{
	if (isentity(self._datasource))
		Menu_RaiseDataEvent(self._datasource, MENU_DATAENTRY_SYNC);
}

void() Object_DataSource_Destroy =
{
	unzone(self._desc);
}

Menu_DataRefresh Object_DataSource_Refresh = 
{
	Menu_RaiseDataEvent(self, MENU_DATASOURCE_GET);
}

void() Object_DataSource_Init =
{
	self.mDataRefresh = Object_DataSource_Refresh;
	self.mDestroy = Object_DataSource_Destroy;
	self._desc = newzone();
}

void() Object_DataSource_Spawn =
{
	self._datasource = null_entity;
	if (self.source == "")
	{
		Menu_Warning(self, "Object_DataSource_Spawn: no source");
		return;
	}
	// find data source
	if (!Menu_FindObject(menu_proc, self, self.source))
	{
		Menu_Warning(self, "Object_DataSource_Spawn: data source not found");
		return;
	}
	Menu_LinkDynamicDataObject(foundobject, self);
}

string Object_DataSource_TransformIn(entity tObject) =
{
	if (tObject.onInput)
	{
		MenuScript_SetVar("in", tObject._datasource.value);
		return MenuScript_Run(tObject, tObject.onInput);
	}
	return tObject._datasource.value;
}

void Object_DataSource_TransformOut(string tStr)
{
	string tGlobalStream;
	
	if (isnotentity(self._datasource))
		return;
		
	// run transform
	if (self.onOutput)
	{
		MenuScript_SetVar("in", tStr);
		MenuScript_SetVar("entry", self._datasource.value);
		tStr = MenuScript_Run(self, self.onOutput);
	}
	// send value
	rezone(self._datasource.value, tStr);
	// raise update event on parent which also refresh value of this entry
	Menu_RefreshDataSources(self._datasource);
}

/*
================================================================================

   DATA ENTRY COMMON
   
================================================================================
*/

Menu_DataEvent Object_DataEntry_DataEvent =
{
	string tValue, tOldValue;
	
	if (tEvent == MENU_DATAENTRY_SYNC)
	{
		tValue = self.mDataRead();
		rezone(self._syncValue, tValue);
		rezone(self.value, tValue);
		Menu_RefreshDataSources(self); // value changed, refresh childrn data sources
		return 1;
	}
	if (tEvent == MENU_DATAENTRY_SEND)
	{
		rezone(self._syncValue, self.value);
		self.mDataWrite(self.value);
		return 1;
	}
	if (tEvent == MENU_DATAENTRY_TEST)
	{
		self.mDataWrite(self.value);
		return 1;
	}
	if (tEvent == MENU_DATAENTRY_ENDTEST)
	{
		self.mDataWrite(self._syncValue);
		rezone(self.value, self._syncValue);
		Menu_RefreshDataSources(self); // value changed, refresh childrn data sources
		return 1;
	}
	if (tEvent == MENU_DATAENTRY_RESTORE)
	{
		rezone(self.value, self._syncValue);
		Menu_RefreshDataSources(self); // value changed, refresh childrn data sources
		return 1;
	}
	if (tEvent == MENU_DATAENTRY_RESET)
	{
		rezone(self.value, self.defValue);
		Menu_RefreshDataSources(self); // value changed, refresh childrn data sources
		return 1;
	}	
	if (tEvent == MENU_DATAENTRY_RESYNC)
	{
	
		tValue = self.mDataRead();
		if (self._syncValue != tValue)
		{
			// raise full resync
			if (self.value == self._syncValue)
			{
				Object_DataEntry_DataEvent(tEvent);
				return 1;
			}
			// partial resync
			rezone(self._syncValue, tValue);
		}
		return 1;
	}
	return 0;
}

void() Object_DataEntry_Destroy =
{
	strunzone(self._syncValue);
}

void() Object_DataEntry_Init =
{
	self._syncValue = newzone();
	self.mDataEvent = Object_DataEntry_DataEvent;
	self.mDestroy = Object_DataEntry_Destroy;
}

/*
================================================================================

   TEMPORARY DATA ENTRY
   
   stores a value in self
   
================================================================================
*/

Menu_DataEntryRead Object_DataEntry_Temp_Read =
{
	return strtemp(self._desc);
}

Menu_DataEntryWrite Object_DataEntry_Temp_Write =
{
	rezone(self._desc, tValue);
}

void() Object_DataEntry_Temp_Destroy =
{
	unzone(self._desc);
	Object_DataEntry_Destroy();
} 

void() Object_DataEntry_Temp_Init =
{
	Object_DataEntry_Init();
	
	self.mDestroy = Object_DataEntry_Temp_Destroy;
	self.mDataRead = Object_DataEntry_Temp_Read;
	self.mDataWrite = Object_DataEntry_Temp_Write;
	self._desc = newzone();
}

void() Object_DataEntry_Temp =
{
	className = "DataEntry_Temp";
	classInit = Object_DataEntry_Temp_Init;
	classSpawn = null_function;
}

/*
================================================================================

   CVAR DATA ENTRY
   
================================================================================
*/

Menu_DataEntryRead Object_DataEntry_Cvar_Read =
{
	return cvar_string(self.source);
}

Menu_DataEntryWrite Object_DataEntry_Cvar_Write =
{
	cvar_set(self.source, tValue);
}

void() Object_DataEntry_Cvar_Init =
{
	Object_DataEntry_Init();
	
	self.mDataRead = Object_DataEntry_Cvar_Read;
	self.mDataWrite = Object_DataEntry_Cvar_Write;
}

void() Object_DataEntry_Cvar_Spawn =
{
	string temp;
	
	if (self.source == "")
	{
		Menu_Warning(self, "DataEntry_Cvar with no actual cvar\n");
		return;
	}
	// create/reset cvar if it not exist
	if (cvar_description(self.source) == ""/* || cvar_defstring(self.source) != self.defValue*/)
	{
		registercvar(self.source, self.defValue);
		if (self.comment != "")
			localcmd(strcat("seta \"", self.source, "\" \"", self.defValue, "\" \"", self.comment, "\"\n"));
		else
			localcmd(strcat("seta \"", self.source, "\" \"", self.defValue, "\"\n"));
	}
	// if comment was changed, re-register it
	if (self.comment != "" && cvar_description(self.source) != self.comment)
	{
		temp = cvar_string(self.source);
		localcmd(strcat("seta \"", self.source, "\" \"", temp, "\" \"", self.comment, "\"\n"));
	}
}

void() Object_DataEntry_Cvar =
{
	className = "DataEntry_Cvar";
	classInit = Object_DataEntry_Cvar_Init;
	classSpawn = Object_DataEntry_Cvar_Spawn;
}

/*
================================================================================

   TEXT DATA SOURCE
   
================================================================================
*/

Menu_DataEvent Object_DataSource_Text_DataEvent =
{
	entity tOldSelf;
	string tValue, tDescValue;
	
	if (isnotentity(self._datasource) || self._datasource == self)
	{
		Menu_Warning(self, strcat("Object_DataSource_Text_DataEvent: bad source '", self.source, "'!"));
		return 0;
	}
	 
	if (tEvent == MENU_DATASOURCE_GET)
	{
		// get
		tValue = Object_DataSource_TransformIn(self);
		rezone(self.value, tValue);
		// set descriptional value
		if (self.onFormat)
		{
			MenuScript_SetVar("in", "");
			MenuScript_SetVar("value", self.value);
			MenuScript_SetVar("sourcevalue", self._datasource.value);
			tDescValue = MenuScript_Run(self, self.onFormat);
		}
		else tDescValue = tValue;
		rezone(self._desc, tDescValue);
		// autoupdate objects
		Menu_RefreshLinkedDataObjects(self);	
		return 1;
	}
	if (tEvent == MENU_DATASOURCE_SET)
	{
		Object_DataSource_TransformOut(self.value);
		return 1;
	}
		
	// raise event on linked data entry
	Menu_RaiseDataEvent(self._datasource, tEvent);
	return 0;
}

void() Object_DataSource_Text_Init =
{
	Object_DataSource_Init();
	
	self.mDataEvent = Object_DataSource_Text_DataEvent;
}

void() Object_DataSource_Text =
{
	className = "DataSource_Text";
	classInit = Object_DataSource_Text_Init;
	classSpawn = Object_DataSource_Spawn;
}

/*
================================================================================

   SLIDER DATA SOURCE
   
   valueMin value valueMax and valusSteps
   returns a 0-1 fraction ordinated by valueSteps (if valueSteps is 0 - not ordinated)
   
================================================================================
*/

Menu_DataEvent Object_DataSource_Slider_DataEvent =
{
	entity tOldSelf;
	float tVal, tStep;
	string tValue, tDescValue;
	
	if (isnotentity(self._datasource) || self._datasource == self)
	{
		Menu_Warning(self, strcat("Object_DataSource_Slider_DataEvent: bad source '", self.source, "'!"));
		return 0;
	}
	
	if (tEvent == MENU_DATASOURCE_GET)
	{
		tValue = Object_DataSource_TransformIn(self);
		// calculate new value and clamp it, transform to 0-1 fraction
		if (self.valueMin <= self.valueMax)
		{
			tVal = bound(self.valueMin, stof(tValue), self.valueMax);
			tVal = (tVal - self.valueMin)/(self.valueMax - self.valueMin);
		}
		else
		{
			tVal = bound(self.valueMax, stof(tValue), self.valueMin);
			tVal = (tVal - self.valueMax)/(self.valueMin - self.valueMax);
			tVal = 1 - tVal;
		}
		// ordinate it
		if (self.valueSteps)
			tVal = (rint(tVal / ( 1 / self.valueSteps))/self.valueSteps);
		rezone(self.value, ftos2(tVal));	
		// set descriptional value
		if (self.onFormat)
		{
			MenuScript_SetVar("in", "");
			MenuScript_SetVar("value", tValue);
			MenuScript_SetVar("sourcevalue", self._datasource.value);
			MenuScript_SetVar("sliderpos", self.value);
			tDescValue = MenuScript_Run(self, self.onFormat);
		}
		else tDescValue = tValue;
		rezone(self._desc, tDescValue);
		// autoupdate objects
		Menu_RefreshLinkedDataObjects(self);	
		return 1;
	}
	if (tEvent == MENU_DATASOURCE_SET)
	{
		// get value and ordinate it
		tVal = stof(self.value);
		if (self.valueSteps)
			tVal = rint(tVal / ( 1 / self.valueSteps))/self.valueSteps;
		// transform from fraction into value
		if (self.valueMin <= self.valueMax)
			tVal = self.valueMin + (self.valueMax - self.valueMin)*tVal;
		else
		{
			tVal = 1 - tVal;
			tVal = self.valueMax + (self.valueMin - self.valueMax)*tVal;
		}
		// send
		Object_DataSource_TransformOut(ftos2(tVal));
		return 1;
	}
		
	// raise event on linked data entry
	Menu_RaiseDataEvent(self._datasource, tEvent);
	return 0;
}

void() Object_DataSource_Slider_Init =
{
	Object_DataSource_Init();
	
	self.mDataEvent = Object_DataSource_Slider_DataEvent;
}

void() Object_DataSource_Slider =
{
	className = "DataSource_Slider";
	classInit = Object_DataSource_Slider_Init;
	classSpawn = Object_DataSource_Spawn;
}

/*
================================================================================

   LIST
   
   uses index position

================================================================================
*/

float Object_DataSource_List_GetIndex(entity tObject, float tCurPos, string tValue)
{
	float tPos;
	
	// VorteX: respect current position while searching in case of same values
	for (tPos = tCurPos; tPos < tObject.valueListSize; tPos++)
		if (altstr_frag(tObject.valueList, tPos) == tValue)
			return tPos;
	for (tPos = 0; tPos < tCurPos; tPos++)
		if (altstr_frag(tObject.valueList, tPos) == tValue)
			return tPos;
	return -1;
}

Menu_DataEvent Object_DataSource_List_DataEvent =
{
	entity tOldSelf;
	string tValue, tDescValue;
	float tPos;
	
	if (isnotentity(self._datasource) || self._datasource == self)
	{
		Menu_Warning(self, strcat("Object_DataSource_List_DataEvent: bad source '", self.source, "'!"));
		return 0;
	}

	if (tEvent == MENU_DATASOURCE_GET)
	{
		tValue = Object_DataSource_TransformIn(self);
		// find it in the list
		tPos = Object_DataSource_List_GetIndex(self, stof(self.value), tValue);
		if (tPos < 0) // not found
		{
			tPos = Object_DataSource_List_GetIndex(self, stof(self.value), self.defValue);
			if (tPos < 0) // too bad! defValue fails!
				tPos = 1;
			rezone(self.value, ftos2(tPos));
		}
		else
			rezone(self.value, ftos2(tPos));	
		// set descriptional value
		tDescValue = altstr_frag(self.descList, tPos);
		if (self.onFormat)
		{
			MenuScript_SetVar("in", tDescValue);
			MenuScript_SetVar("value", tValue);
			MenuScript_SetVar("sourcevalue", self._datasource.value);
			MenuScript_SetVar("listpos", self.value);
			tDescValue = MenuScript_Run(self, self.onFormat);
		}
		else if (tDescValue == "")
			tDescValue = tValue;
		rezone(self._desc, tDescValue);
		// autoupdate data users
		Menu_RefreshLinkedDataObjects(self);	
		return 1;
	}
	if (tEvent == MENU_DATASOURCE_SET)
	{
		// don't set if out of range
		tPos = stof(self.value);
		if (tPos < 0 || tPos > self.valueListSize)
			return 1;
		// send
		Object_DataSource_TransformOut(altstr_frag(self.valueList, tPos));
		return 1;
	}
	
	// raise event on linked data entry
	Menu_RaiseDataEvent(self._datasource, tEvent);
	return 0;
}

void() Object_DataSource_List_Init =
{
	Object_DataSource_Init();
	
	self.mDataEvent = Object_DataSource_List_DataEvent;
}

void() Object_DataSource_List =
{
	className = "DataSource_List";
	classInit = Object_DataSource_List_Init;
	classSpawn = Object_DataSource_Spawn;
}

/*
================================================================================

   LIST COMBINER
   
   combines the multiple lists which must be children, 
   all lists must have same values count!
   
================================================================================
*/

Menu_DataEvent Object_DataSource_ListCombiner_DataEvent =
{
	entity tChild;
	string tDesc, tStr, tValue;
	float tPos, tListPos, tListSize;
	
	if (isnotentity(self._datasource) || self._datasource == self)
	{
		Menu_Warning(self, strcat("Object_DataSource_List_DataEvent: bad source '", self.source, "'!"));
		return 0;
	}
	
	tListSize = -1;
	tListPos = -1;
	if (tEvent == MENU_DATASOURCE_GET)
	{
		//print("--- GET ---\n");
		if (!self.onFormat)
		{
			Menu_Warning(self, "Object_DataSource_ListCombiner_DataEvent: null format!");
			tDesc = "#ERROR#";
		}
		else
		{
			// 1st pass
			tListSize = 0;
			tValue = "";
			MenuScript_SetVar("in", "");
			for (tChild = self._child; tChild; tChild = tChild._next)
			{
				if (tChild.classname != "DataSource_List")
					continue;
				// get most longer child
				if (tChild.valueListSize > tListSize)
					tListSize = tChild.valueListSize;
				// build common exact value
				tValue = strcat(tValue, "%", Object_DataSource_TransformIn(tChild));
				// set menuScript global with current item value
				MenuScript_SetVar(tChild.localname, tChild._desc);
			}
			// 2st pass
			tListPos = tListSize;
			while(tListPos >= 0)
			{
				tListPos--;
				// build long list value
				tStr = "";
				for (tChild = self._child; tChild; tChild = tChild._next)
				{
					if (tChild.classname != "DataSource_List")
						continue;
					tStr = strcat(tStr, "%", altstr_frag(tChild.valueList, tListPos));
				}
				// check
				if (tValue == tStr)
					break;
			}
			// if value is not found we are going to use arcane magic
			if (tListPos == -1)
			{
				tListSize = -1;
				for (tChild = self._child; tChild; tChild = tChild._next)
				{
					if (tChild.classname != "DataSource_List")
						continue;
					// pick minimum list size
					if (tListSize < 0 || tListSize > tChild.valueListSize)
						tListSize = tChild.valueListSize;
					if (tListPos < 0 || tListPos > stof(tChild.value))	
						tListPos = stof(tChild.value);
				}
			}
			// run desctiption formatter
			tDesc = MenuScript_Run(self, self.onFormat);
		}
		// set descriptional value
		rezone(self._desc, tDesc);
		// set list props
		self.valueListSize = tListSize;
		rezone(self.value, ftos2(tListPos));
		// autoupdate data users
		Menu_RefreshLinkedDataObjects(self);	
		return 1;
	}
	if (tEvent == MENU_DATASOURCE_SET)
	{
		// don't set if out of range
		tPos = stof(self.value);
		if (tPos < 0 || tPos > self.valueListSize)
			return 1;	
		// send to datasource
		rezone(self._datasource.value, self.value);	
		// send values of all childs and raise event
		// VorteX: two passes bacause we need to set values on all
		// children before they got event and in turn update the parent
		for (tChild = self._child; tChild; tChild = tChild._next)
			if (tChild.classname == "DataSource_List")
				rezone(tChild.value, self.value);
		for (tChild = self._child; tChild; tChild = tChild._next)
			if (tChild.classname == "DataSource_List")	
				Menu_RaiseDataEvent(tChild, MENU_DATASOURCE_SET);
		// raise update event and refresh value of this entry
		Menu_RefreshDataSources(self._datasource);
		return 1;
	}
	// raise event on children
	for (tChild = self._child; tChild; tChild = tChild._next)
		if (tChild.classname == "DataSource_List")
			Menu_RaiseDataEvent(tChild, tEvent);
	// raise event on linked data entry
	Menu_RaiseDataEvent(self._datasource, tEvent);
	return 0;
}

void() Object_DataSource_ListCombiner_Spawn =
{
	entity tChild;
	
	// link to all children
	// so if they are updated separately this will update as well
	for (tChild = self._child; tChild; tChild = tChild._next)
	 	if (tChild.classname == "DataSource_List")
				Menu_LinkStaticDataObject(tChild, self);
	// link to source
	Object_DataSource_Spawn();	
}

void() Object_DataSource_ListCombiner_Init =
{
	Object_DataSource_Init();
	
	self.mDataEvent = Object_DataSource_ListCombiner_DataEvent;
}

void() Object_DataSource_ListCombiner =
{
	className = "DataSource_ListCombiner";
	classInit = Object_DataSource_ListCombiner_Init;
	classSpawn = Object_DataSource_ListCombiner_Spawn;
}

/*
================================================================================

   BIND COMMAND DATA ENTRY
   
================================================================================
*/

Menu_DataEvent Object_DataEntry_BindCommand_DataEvent =
{
	string tTrueDefValue;
	float tPos, tLen;
	
	// VorteX: special case for 'reset to defaults'
	// since defValue are stored as altstring of keynames instead of keycodes
	if (tEvent == MENU_DATAENTRY_RESET)
	{
		tTrueDefValue = "";
		tLen = altstr_len(self.defValue);
		for (tPos = 0; tPos < tLen; tPos++)
			tTrueDefValue = strcat(tTrueDefValue, "'", ftos2(Menu_Sys_StringToKeyNum(altstr_frag(self.defValue, tPos))), "'");
		rezone(self.value, tTrueDefValue);
		Menu_RefreshDataSources(self);
		return 1;
	}	
	// otherwise use generic
	return Object_DataEntry_DataEvent(tEvent);
}

Menu_DataEntryRead Object_DataEntry_BindCommand_Read =
{
	return findkeysforcommand(self.source);
}

Menu_DataEntryWrite Object_DataEntry_BindCommand_Write =
{
	float tPos, tLen, tKeyCode;
	string tCurBinds;
	
	// unbind previous binds
	tCurBinds = findkeysforcommand(self.source);
	tLen = altstr_len(tCurBinds);
	for (tPos = 0; tPos < tLen; tPos++)
	{
		tKeyCode = stof(altstr_frag(tCurBinds, tPos));
		if (tKeyCode >= 0)
			localcmd(strcat("unbind \"", Menu_Sys_KeyNumToString(tKeyCode), "\"\n"));
	}
	// write new binds
	tLen = altstr_len(tValue);
	for (tPos = 0; tPos < tLen; tPos++)
	{
		tKeyCode = stof(altstr_frag(tValue, tPos));
		if (tKeyCode >= 0)
			localcmd(strcat("bind \"", Menu_Sys_KeyNumToString(tKeyCode), "\" \"", self.source, "\"\n"));
	}
}

void() Object_DataEntry_BindCommand_Init =
{
	Object_DataEntry_Init();
	
	self.mDataRead = Object_DataEntry_BindCommand_Read;
	self.mDataWrite = Object_DataEntry_BindCommand_Write;
	self.mDataEvent = Object_DataEntry_BindCommand_DataEvent;
}

void() Object_DataEntry_BindCommand =
{
	className = "DataEntry_BindCommand";
	classInit = Object_DataEntry_BindCommand_Init;
	classSpawn = null_function;
}


/*
================================================================================

   BINDLIST DATA SOURCE
   
================================================================================
*/

Menu_DataEvent Object_DataSource_BindList_DataEvent =
{
	entity tOldSelf;
	string tValue, tDescValue;
	float tPos, tLen, tKeyCode;
	
	if (isnotentity(self._datasource) || self._datasource == self)
	{
		Menu_Warning(self, strcat("Object_DataSource_BindList_DataEvent: bad source '", self.source, "'!"));
		return 0;
	}
	 
	if (tEvent == MENU_DATASOURCE_GET)
	{
		tValue = Object_DataSource_TransformIn(self);
		rezone(self.value, tValue);
		// set descriptional value
		tDescValue = "";
		tLen = altstr_len(self.value);
		if (self.valueMax) // bound max binds
			tLen = min(tLen, self.valueMax);
		for (tPos = 0; tPos < tLen; tPos++)
		{
			tKeyCode = stof(altstr_frag(self.value, tPos));
			if (tKeyCode == -1)
				continue;
			if (tDescValue == "")
				tDescValue = Menu_Sys_KeyNumToString(tKeyCode);
			else
				tDescValue = strcat(tDescValue, ", ", Menu_Sys_KeyNumToString(tKeyCode));
		}
		if (tDescValue == "")
			tDescValue = "???";
		rezone(self._desc, tDescValue);
		// autoupdate objects
		Menu_RefreshLinkedDataObjects(self);	
		return 1;
	}
	if (tEvent == MENU_DATASOURCE_SET)
	{
		// bound max binds
		if (self.valueMax) // bound max binds
		{
			tLen = min(altstr_len(self.value), self.valueMax);
			tValue = "";
			for (tPos = 0; tPos < tLen; tPos++)
				tValue = strcat(tValue, "'", altstr_frag(self.value, tPos), "'");
			rezone(self.value, tValue);
		}
		Object_DataSource_TransformOut(self.value);
		return 1;
	}
		
	// raise event on linked data entry
	Menu_RaiseDataEvent(self._datasource, tEvent);
	return 0;
}

void() Object_DataSource_BindList_Init =
{
	Object_DataSource_Init();
	
	self.mDataEvent = Object_DataSource_BindList_DataEvent;
}

void() Object_DataSource_BindList =
{
	className = "DataSource_BindList";
	classInit = Object_DataSource_BindList_Init;
	classSpawn = Object_DataSource_Spawn;
}

/*
================================================================================

   DATASOURCE UTIL

================================================================================
*/

// run dataevent
float Menu_DataSource_DataEvent(entity tControl, entity tSource, float tEvent)
{
	if (tEvent == MENU_DATACONTROL_AUTO)
	{
		if (isentity(tControl))
			tEvent = tControl.autoEvent;
		else
			tEvent = -1;
	}
	if (tEvent < 0)
		return -1;
	return Menu_RaiseDataEvent(tSource, tEvent);
}

// get a list value from datasource
string Menu_DataSource_GetListValue(entity tControl, entity tSource)
{
	float v, i, bh;
	
	if (isnotentity(tSource))
	{
		Menu_Warning(tControl, "Menu_DataSource_GetDescValue: null data source!");
		return "'#BAD_SOURCE#'";
	}
	// for slider we built total list of values
	if (tSource.classname == "DataSource_Slider")
	{ 
		bh = buf_create();
		bufstr_set(bh, 0, strcat("'", ftos(i), "''", ftos2(v), "'"));
		for (i = 0; i <= tSource.valueSteps; i++)
		{
			v = tSource.valueMin + (tSource.valueMax - tSource.valueMin)*(1 / tSource.valueSteps)*i;
			bufstr_set(bh, i+1, strcat("'", ftos(i), "''", ftos2(v), "'"));
		}	
		return strcat("tmpbuf:", ftos(bh));
	}
	// for switch we build a value;desc; buffer
	if (tSource.classname == "DataSource_Switch")
	{
		bh = buf_create();
		tokenize(tSource.valueList);
		for (i = 0; i < tSource.valueListSize; i++)
			bufstr_set(bh, i, strcat("'", Menu_Data_EscapeToStaticList(argv(i)), "'"));
		tokenize(tSource.descList);	
		for (i = 0; i < tSource.valueListSize; i++)
			bufstr_set(bh, i, strcat(bufstr_get(bh, i), "'", Menu_Data_EscapeToStaticList(argv(i)), "'"));
		return strcat("tmpbuf:", ftos(bh));
	}
	// super new link source
	// fixme!!
	if (tSource.classname == "DataSource_Link")
	{
		if (!Menu_FindObject(menu_proc, tSource, tSource.value))
			return tSource.value;
		// return a value of that object
		if (foundobject.classname != "DataSource_Link") // just return text, to ensure there will be no looped execution
			return Menu_DataSource_GetListValue(tControl, foundobject);
		return foundobject.value;
	}
	// text holds just a text value
	if (tSource.classname == "DataSource_Text")
		return tSource.value;
	Menu_Warning(tControl, strcat("Menu_DataSource_GetDescValue: unsupported data source type '", tSource.classname, "'"));
	return "'#BAD_SOURCE#'";
}

// get descriptional value from datasource
string Menu_DataSource_GetDescValue(entity tControl, entity tSource)
{
	if (isnotentity(tSource))
	{
		Menu_Warning(tControl, "Menu_DataSource_GetDescValue: null data source!");
		return "#BAD_SOURCE#";
	}
	if (tSource.classname == "DataSource_Slider" || 
		 tSource.classname == "DataSource_List" || 
		 tSource.classname == "DataSource_ListCombiner" ||
		 tSource.classname == "DataSource_BindList" ||
		 tSource.classname == "DataSource_Text")
	{
		return tSource._desc;
	}
	Menu_Warning(tControl, strcat("Menu_DataSource_GetDescValue: unsupported data source type '", tSource.classname, "'"));
	return "#BAD_SOURCE#";
}
	
// list/slider advance
float Menu_DataSource_Advance(entity tControl, entity tSource, float tAdvance, float tCycle, float tAutoEvent) =
{
	float tSliderPos, tNewSliderPos;
	
	if (isnotentity(tSource))
	{
		Menu_Warning(tControl, "Menu_DataSource_Advance: null data source!");
		return 0;
	}
	
	if (tSource.classname == "DataSource_Slider")
	{
		// get
		tSliderPos = stof(tSource.value);
		// advance
		if (tControl.valueSteps)
			tNewSliderPos = tSliderPos + (1/tControl.valueSteps)*tAdvance;
		else if (tSource.valueSteps)
			tNewSliderPos = tSliderPos + (1/tSource.valueSteps)*tAdvance;
		else
			tNewSliderPos = tSliderPos + (1/20)*tAdvance;
		if (!tCycle)
			tNewSliderPos = bound(0, tNewSliderPos, 1);
		else if (tAdvance > 0)
		{
			if (tNewSliderPos > 1)
				tNewSliderPos = 0;
		}
		else if (tNewSliderPos < 0)
			tNewSliderPos = 1;
		// save
		if (tSliderPos != tNewSliderPos)
		{
			if (tAdvance > 0)
				Menu_Sys_RunState(tControl, MSU_EVENT, tControl.state, ":move-forward");
			else
				Menu_Sys_RunState(tControl, MSU_EVENT, tControl.state, ":move-back");
			
			rezone(tSource.value, ftos2(tNewSliderPos));
			Menu_DataSource_DataEvent(tControl, tSource, MENU_DATASOURCE_SET);
			Menu_DataSource_DataEvent(tControl, tSource, tAutoEvent);
			return 1;
		}
		return 0;
	}
	if (tSource.classname == "DataSource_List" || tSource.classname == "DataSource_ListCombiner")
	{
		if (tAdvance > 0)
			Menu_Sys_RunState(tControl, MSU_EVENT, tControl.state, ":move-forward");
		else
			Menu_Sys_RunState(tControl, MSU_EVENT, tControl.state, ":move-back");
		// get
		tSliderPos = stof(tSource.value);
		// advance
		tNewSliderPos = tSliderPos + tAdvance;
		if (!tCycle)
			tNewSliderPos = bound(0, tNewSliderPos, tSource.valueListSize - 1);
		else if (tAdvance > 0)
		{
			if (tNewSliderPos > (tSource.valueListSize - 1))
				tNewSliderPos = 0;
		}
		else if (tNewSliderPos < 0)
			tNewSliderPos =  tSource.valueListSize - 1;
		// save
		if (tSliderPos != tNewSliderPos)
		{
			rezone(tSource.value, ftos2(tNewSliderPos));
			Menu_DataSource_DataEvent(tControl, tSource, MENU_DATASOURCE_SET);
			Menu_DataSource_DataEvent(tControl, tSource, tAutoEvent);
			return 1;
		}
		return 0;
	}
	if (tSource.classname == "DataSource_Text")
	{
		rezone(tSource.value, ftos2(stof(tSource.value) + tAdvance));
		Menu_DataSource_DataEvent(tControl, tSource, MENU_DATASOURCE_SET);
		Menu_DataSource_DataEvent(tControl, tSource, tAutoEvent);
		return 1;
	}
	Menu_Warning(tControl, strcat("Menu_DataSource_Advance: bad data source type ", tSource.classname, "!"));
	return 0;
}

// list/slider setPos
float Menu_DataSource_SetPos(entity tControl, entity tSource, float tPos, float tAutoEvent) =
{
	if (isnotentity(tSource))
	{
		Menu_Warning(tControl, "Menu_DataSource_SetPos: null data source!");
		return 0;
	}
	
	if (tSource.classname == "DataSource_List")
	{
		Menu_Sys_RunState(tControl, MSU_EVENT, tControl.state, ":move-pos");
		rezone(tSource.value, ftos2(rint(tPos*tSource.valueListSize)));
		Menu_DataSource_DataEvent(tControl, tSource, MENU_DATASOURCE_SET);
		Menu_DataSource_DataEvent(tControl, tSource, tAutoEvent);
		return 1;
	}
	if (tSource.classname == "DataSource_Slider")
	{
		Menu_Sys_RunState(tControl, MSU_EVENT, tControl.state, ":move-pos");
		rezone(tSource.value, ftos2(tPos));
		Menu_DataSource_DataEvent(tControl, tSource, MENU_DATASOURCE_SET);
		Menu_DataSource_DataEvent(tControl, tSource, tAutoEvent);
		return 1;
	}
	Menu_Warning(tControl, strcat("Menu_DataSource_SetPos: bad data source type ", tSource.classname, "\n!"));
	return 0;
}

// list/slider/editbox value
float Menu_DataSource_SetValue(entity tControl, entity tSource, string tValue, float tAutoEvent) =
{
	float tPos, tVal;
	
	if (isnotentity(tSource))
	{
		Menu_Warning(tControl, "Menu_DataSource_SetValue: null data source!");
		return 0;
	}
	if (tSource.classname == "DataSource_Text")
	{
		rezone(tSource.value, tValue);
		Menu_DataSource_DataEvent(tControl, tSource, MENU_DATASOURCE_SET);
		Menu_DataSource_DataEvent(tControl, tSource, tAutoEvent);
		return 1;
	}
	if (tSource.classname == "DataSource_Slider")
	{
		tVal = stof(tValue);
		tPos = bound(0, (tVal - tSource.valueMin) / (tSource.valueMax - tSource.valueMin), 1);
		Menu_DataSource_SetPos(tControl, tSource, tPos, tAutoEvent);
		return 1;
	}
	Menu_Warning(tControl, strcat("Menu_DataSource_SetValue: bad data source type ", tSource.classname, "!"));
	return 0;
}

// add bind to BindCommand datasource
float Menu_DataSource_AddBinding(entity tControl, entity tSource, string tValue, float tAutoEvent) =
{
	float tStrCount, tPos;
	string tNewValue, tKey;
	
	if (isnotentity(tSource))
	{
		Menu_Warning(tControl, "Menu_DataSource_AddBinding: null data source!");
		return 0;
	}
	
	if (tSource.classname == "DataSource_BindList")
	{
		// remove this key from biending if bind already
		if (tValue != "")
		{
			tStrCount = altstr_len(tSource.value);
			tNewValue = "";
			for (tPos = 0; tPos < tStrCount; tPos++)
			{
				tKey = altstr_frag(tSource.value, tPos);
				if (tKey != tValue)
					tNewValue = strcat(tNewValue, "'", tKey, "'");
			}
			// push to the beginning
			tValue = strcat("'", tValue, "'", tNewValue);
			rezone(tSource.value, tValue);
		}
		Menu_DataSource_DataEvent(tControl, tSource, MENU_DATASOURCE_SET);
		Menu_DataSource_DataEvent(tControl, tSource, tAutoEvent);
		return 1;
	}
	Menu_Warning(tControl, strcat("Menu_DataSource_AddBinding: bad data source type ", tSource.classname, "!"));
	return 0;
}

// clear binds for BindCommand datasource
float Menu_DataSource_ClearBindings(entity tControl, entity tSource, float tAutoEvent) =
{
	float tStrCount, tPos;
	
	if (isnotentity(tSource))
	{
		Menu_Warning(tControl, "Menu_DataSource_ClearBindings: null data source!");
		return 0;
	}
	
	if (tSource.classname == "DataSource_BindList")
	{
		rezone(tSource.value, "");
		Menu_DataSource_DataEvent(tControl, tSource, MENU_DATASOURCE_SET);
		Menu_DataSource_DataEvent(tControl, tSource, tAutoEvent);
		return 1;
	}
	Menu_Warning(tControl, strcat("Menu_DataSource_ClearBindings: bad data source type ", tSource.classname, "!"));
	return 0;
}