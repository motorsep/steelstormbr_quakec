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

// events
#define Menu_SelectEvent float(float tSilent)
#define Menu_MouseClickEvent float(float tEvent, float tKeyCode, float tKeySealed, float tMouseOver)

.void() mTrigger;
.float onClick;
.Menu_MouseClickEvent mClick; // called on focus item when it receives mouse click or enter
.float onSelect;
.Menu_SelectEvent mSelect;
.float onDeselect;
.Menu_SelectEvent mDeSelect;

// children layout (todo)
#define MENU_CHILDLAYOUT_VERTICAL		0	// up - prev, down - next
#define MENU_CHILDLAYOUT_HORIZONTAL	1	// left - prev, right - next

#ifdef MENU_DEVELOPER
void Menu_Debugger_TriggerCast(entity tObject);
#endif

////////////////////////////////////////
// CODE
////////////////////////////////////////

/*
================================================================================

   BACKGROUND / FOREGROUD
   
================================================================================
*/

#define ObjectLib_Background_Draw() if (self.bgAlpha) _ObjectLib_Background_Draw()
void() _ObjectLib_Background_Draw =
{
	vector tBgPicPos;
	vector tBgPicSize;
	float tDrawFlag;
	
	tDrawFlag = self.bgDrawFlag;
	tBgPicPos_x = self.bgPicPos_x*self._scale_x;
	tBgPicPos_y = self.bgPicPos_y*self._scale_y;
	if (self.bgPicSize_x)
		tBgPicSize_x = self.bgPicSize_x*self._scale_x;
	else	
		tBgPicSize_x = self._size_x;
	if (self.bgPicSize_y)
		tBgPicSize_y = self.bgPicSize_y*self._scale_y;
	else	
		tBgPicSize_y = self._size_y;	
	// draw picture or fill
	if (self.background != "")
	{
		Draw2D_DrawPic(self._absmin + tBgPicPos, self.background, tBgPicSize, self.bgColor, self.bgAlpha*self.alpha, tDrawFlag);
		return;
	}
	Draw2D_DrawFill(self._absmin + tBgPicPos, tBgPicSize, self.bgColor, self.bgAlpha, tDrawFlag);
}


#define ObjectLib_Foreground_Draw() if (self.fgAlpha) _ObjectLib_Foreground_Draw()
void() _ObjectLib_Foreground_Draw =
{
	vector tFgPicPos;
	vector tFgPicSize;
	float tDrawFlag;
	
	tDrawFlag = self.fgDrawFlag;
	tFgPicPos_x = self.fgPicPos_x*self._scale_x;
	tFgPicPos_y = self.fgPicPos_y*self._scale_y;
	if (self.fgPicSize_x)
		tFgPicSize_x = self.fgPicSize_x*self._scale_x;
	else	
		tFgPicSize_x = self._size_x;
	if (self.fgPicSize_y)
		tFgPicSize_y = self.fgPicSize_y*self._scale_y;
	else	
		tFgPicSize_y = self._size_y;	
	// draw picture or fill
	if (self.foreground != "")
	{
		Draw2D_DrawPic(self._absmin + tFgPicPos, self.foreground, tFgPicSize, self.fgColor, self.fgAlpha*self.alpha, tDrawFlag);
		return;
	}
	Draw2D_DrawFill(self._absmin + tFgPicPos, tFgPicSize, self.fgColor, self.fgAlpha, tDrawFlag);
}
/*
================================================================================

   PICTURE
   
================================================================================
*/

#define ObjectLib_Picture_Draw() if (self.picture != null_string) _ObjectLib_Picture_Draw()
void() _ObjectLib_Picture_Draw =
{
	float tDrawFlag;
	vector tPicSize, tPicPos;
	
	// pic fit object size
	if (self.picSize == '0 0 0')
	{
		tDrawFlag = self.picDrawFlag;
		// picture shadow
		if (self.picShadow)
		{
			Draw2D_SetShadow(self.picShadow, self.picShadowOfs);
			tDrawFlag = tDrawFlag | DRAW2D_SHADOW;
		}
		Draw2D_DrawPic(self._absmin, self.picture, self._size, self.picColor, self.picAlpha*self.alpha, tDrawFlag);
		return;
	}
	// apply scale
	tDrawFlag = self.picDrawFlag;
	tPicSize_x = self.picSize_x*self._scale_x;
	tPicSize_y = self.picSize_y*self._scale_y;
	tPicPos_x = self.picPos_x*self._scale_x;
	tPicPos_y = self.picPos_y*self._scale_y;
	// aligned draw
	if (self.picAlign != '0 0 0')
	{
		Draw2D_SetArea(self._size, self.picAlign, DRAW2D_TOPLEFT);
		tDrawFlag = tDrawFlag | DRAW2D_ALIGN;
	}
	// picture shadow
	if (self.picShadow)
	{
		Draw2D_SetShadow(self.picShadow, self.picShadowOfs);
		tDrawFlag = tDrawFlag | DRAW2D_SHADOW;
	}
	Draw2D_DrawPic(self._absmin + tPicPos, self.picture, tPicSize, self.picColor, self.picAlpha*self.alpha, self.picDrawFlag);
}

/*
================================================================================

   TEXT
   
================================================================================
*/

#define ObjectLib_Text_PreUpdate() if (!self.size_x || !self.size_y) _ObjectLib_Text_PreUpdate()
void() _ObjectLib_Text_PreUpdate =
{
	vector tSize;
	
	if (self.mFlags & MENU_FLAG_MULTILINE)
	{
		if (!self.size_y)
			self.size_y = self.textFontSize_y*self.textMLC;	
		if (!self.size_x)
			print("no auto self.size_x for multiline text yet!\n");
		return;
	}
	
	tSize = Draw2D_GetTextSize(self.text, self.textFont, self.textFontSize, self.textDrawFlag);
	if (!self.size_x)
		self.size_x = tSize_x;
	if (!self.size_y)
		self.size_y = tSize_y;	
}

void() ObjectLib_Text_PostUpdate =
{	
	float tMLC;
	vector tTextPos, tTextSize, tTextFontSize;
	string tMLC1, tMLC2;

	// dynamic props
	if (self.textSize_x)
		tTextSize_x = self.textSize_x*self._scale_x;
	else
		tTextSize_x = self._size_x - self.textPos_x*self._scale_x;
	if (self.textSize_y)
		tTextSize_y = self.textSize_y*self._scale_y;	
	else
		tTextSize_y = self._size_y - self.textPos_y*self._scale_y;
	tTextFontSize_x = self.textFontSize_x*self._scale_x;
	tTextFontSize_y = self.textFontSize_y*self._scale_y;
	if (!tTextFontSize_x || !tTextFontSize_y)
	{
		Menu_Warning(self, strcat("bad textFontSize ", vtos(self._scale), "!"));
		return;
	}
	// cache multiline text
	if (!(self.mFlags & MENU_FLAG_MULTILINE))
		return;
	tMLC1 = newlump();
	tMLC2 = newlump();
	tMLC = 0;
	Draw2D_MLT(self.text, self.textFont, tTextFontSize, self.textDrawFlag, tTextSize);
	while(Draw2D_MLT_GetLine())
	{
		tMLC1 = poplump(tMLC1, mlt_line);
		tMLC2 = poplump(tMLC2, vtos(mlt_linesize));
		tMLC++;
	}
	rezone(self.textMLC1, tMLC1);
	rezone(self.textMLC2, tMLC2);
	self.textMLC = tMLC;
}

void() ObjectLib_Text_DrawMultiLine =
{
	float tDrawFlag, tStartPos, tPos, tHeight;
	float tMLC1ChunkPos, tMLC2ChunkPos, tChunkSize;
	vector tLineSize, tLinePos, tTextPos, tTextSize, tTextFontSize;
	string tLine;
	
	// dynamic props
	tDrawFlag = self.textDrawFlag;
	tTextPos_x = self._absmin_x + self.textPos_x*self._scale_x;
	tTextPos_y = self._absmin_y + self.textPos_y*self._scale_y;
	if (self.textSize_x)
		tTextSize_x = self.textSize_x*self._scale_x;
	else
		tTextSize_x = self._size_x - self.textPos_x*self._scale_x;
	if (self.textSize_y)
		tTextSize_y = self.textSize_y*self._scale_y;	
	else
		tTextSize_y = self._size_y - self.textPos_y*self._scale_y;
	tTextFontSize_x = self.textFontSize_x*self._scale_x;
	tTextFontSize_y = self.textFontSize_y*self._scale_y;
	if (self.textShadow)
	{
		Draw2D_SetShadow(self.textShadow, self.textShadowOfs);
		tDrawFlag = tDrawFlag | DRAW2D_SHADOW;
	}
	tMLC1ChunkPos = lumpstart(self.textMLC1);
	tMLC2ChunkPos = lumpstart(self.textMLC2);
	
	// vertical align
	if (self.textAlign_y)
	{
		tHeight = (self._size_y - tTextFontSize_y*self.textMLC)*self.textAlign_y*0.5;
		tTextPos_y = tTextPos_y + tHeight;
		if (self.clip && tHeight < 0) // clip string at the beginning
		{
			tStartPos = floor(fabs(tHeight/tTextFontSize_y));
			for(tPos = 0; tPos < tStartPos; tPos++)
			{
				tMLC1ChunkPos = lumpstep(tMLC1ChunkPos, lumpchunk(self.textMLC1, tMLC1ChunkPos));
				tMLC2ChunkPos = lumpstep(tMLC2ChunkPos, lumpchunk(self.textMLC2, tMLC2ChunkPos));
				tTextPos_y = tTextPos_y + tTextFontSize_y*(1 + self.lineSpacing);
			}
		}
	}
	else
		tPos = 0;
	
	// horizontal align
	if (self.textAlign_x)
	{
		while (tPos < self.textMLC)
		{
			// read line
			tChunkSize = lumpchunk(self.textMLC1, tMLC1ChunkPos);
			tLine = lumpread(self.textMLC1, tMLC1ChunkPos, tChunkSize);
			tMLC1ChunkPos = lumpstep(tMLC1ChunkPos, tChunkSize);
			// read line size
			tChunkSize = lumpchunk(self.textMLC2, tMLC2ChunkPos);
			tLineSize = stov(lumpread(self.textMLC2, tMLC2ChunkPos, tChunkSize));
			tMLC2ChunkPos = lumpstep(tMLC2ChunkPos, tChunkSize);
			// draw
			tLinePos_x = tTextPos_x + (tTextSize_x - tLineSize_x)*self.textAlign_x*0.5;
			tLinePos_y = tTextPos_y;
			Draw2D_DrawText(tLinePos, tLine, self.textFont, tTextFontSize, self.textColor, self.textAlpha*self.alpha, tDrawFlag);
			tTextPos_y = tTextPos_y + tTextFontSize_y*(1 + self.lineSpacing);
			if (self.clip) // do not draw text that will be clipped anyway
			{
				tHeight = tHeight + tTextFontSize_y;
				if (tHeight > (self._size_y + self.clipMarginDown))
					break; 
			}
			tPos++;
		}
	}
	else
	{
		while (tPos < self.textMLC)
		{
			// read line
			tChunkSize = lumpchunk(self.textMLC1, tMLC1ChunkPos);
			tLine = lumpread(self.textMLC1, tMLC1ChunkPos, tChunkSize);
			tMLC1ChunkPos = lumpstep(tMLC1ChunkPos, tChunkSize);
			// read line size
			tChunkSize = lumpchunk(self.textMLC2, tMLC2ChunkPos);
			tLineSize = stov(lumpread(self.textMLC2, tMLC2ChunkPos, tChunkSize));
			tMLC2ChunkPos = lumpstep(tMLC2ChunkPos, tChunkSize);
			// draw
			Draw2D_DrawText(tTextPos, tLine, self.textFont, tTextFontSize, self.textColor, self.textAlpha*self.alpha, tDrawFlag);
			tTextPos_y = tTextPos_y + tTextFontSize_y*(1 + self.lineSpacing);
			if (self.clip) // do not draw text that will be clipped anyway
			{
				tHeight = tHeight + tTextFontSize_y;
				if (tHeight > (self._size_y + self.clipMarginDown))
					break; 
			}
			tPos++;
		}
	}
}

#define ObjectLib_Text_Draw() if (self.text != null_string) _ObjectLib_Text_Draw()
void() _ObjectLib_Text_Draw =
{
	float tDrawFlag;
	vector tTextPos, tTextFontSize;
	
	// draw multiline text
	if (self.mFlags & MENU_FLAG_MULTILINE)
	{
		ObjectLib_Text_DrawMultiLine();
		return;
	}
	
	// dynamic props
	tTextPos_x = self._absmin_x + self.textPos_x*self._scale_x;
	tTextPos_y = self._absmin_y + self.textPos_y*self._scale_y;
	tTextFontSize_x = self.textFontSize_x*self._scale_x;
	tTextFontSize_y = self.textFontSize_y*self._scale_y;
	
	// draw single line text
	tDrawFlag = self.textDrawFlag;
	if (self.textShadow)
	{
		Draw2D_SetShadow(self.textShadow, self.textShadowOfs);
		tDrawFlag = tDrawFlag | DRAW2D_SHADOW;
	}
	if (self.textAlign != '0 0 0')
	{
		Draw2D_SetArea(self._size, self.textAlign, DRAW2D_TOPLEFT);
		tDrawFlag = tDrawFlag | DRAW2D_ALIGN;
	}
	Draw2D_DrawText(tTextPos, self.text, self.textFont, tTextFontSize, self.textColor, self.textAlpha*self.alpha, tDrawFlag);
}

/*
================================================================================

   FIND OBJECTS
   
================================================================================
*/

float Menu_FindObject_NodeForward_ScanNode(entity tStartObject, string tName)
{	
	entity tObject;
	
	if (tStartObject.localname == tName)
	{
		foundobject = tStartObject;
		return 1;
	}
	// check children
	for (tObject = tStartObject._child; tObject; tObject = tObject._next)
		if (Menu_FindObject_NodeForward_ScanNode(tObject, tName))
			return 1;
	return 0;
}

float Menu_FindObject_NodeForward(entity tStartObject, string tName, float tCheckStart)
{
	entity tObject;
	
	// check current
	if (tCheckStart && tStartObject.localname == tName)
	{
		foundobject = tStartObject;
		return 1;
	}
	// search next entities and childs first
	for (tObject = tStartObject; tObject; tObject = tObject._next)
		if (Menu_FindObject_NodeForward_ScanNode(tObject, tName))
			return 1;
	// then try raise parent
	tStartObject = tStartObject._parent;
	while(tStartObject && !tStartObject._next)
		tStartObject = tStartObject._parent;
	if (!tStartObject) // end of chain
	{
		foundobject = null_entity;
		return 0;
	}
	// check parent
	return Menu_FindObject_NodeForward(tStartObject, tName, 1);
}

float Menu_FindObject_NodeBack_ScanNode(entity tStartObject, string tName)
{	
	entity tObject, tLastObject;
	
	// check object
	if (tStartObject.localname == tName)
	{
		foundobject = tStartObject;
		return 1;
	}
	// check children
	if (tStartObject._child)
	{
		for (tObject = tStartObject._child; tObject; tObject = tObject._next)
			tLastObject = tObject;
		while(tLastObject)
		{
			if (Menu_FindObject_NodeBack_ScanNode(tLastObject, tName))
				return 1;
			tLastObject = tLastObject._prev;
		}
	}
	return 0;
}

float Menu_FindObject_NodeBack(entity tStartObject, string tName, float tCheckStart)
{
	entity tObject;
	
	// check if current
	if (tCheckStart && tStartObject.localname == tName)
	{
		foundobject = tStartObject;
		return 1;
	}
	// search prev entities and childs first
	for (tObject = tStartObject; tObject; tObject = tObject._prev)
		if (Menu_FindObject_NodeBack_ScanNode(tObject, tName))
			return 1;
	// then try raise parent
	tStartObject = tStartObject._parent;
	if (!tStartObject) // end of chain
	{
		foundobject = null_entity;
		return 0;
	}
	return Menu_FindObject_NodeBack(tStartObject, tName, 1);
}

float Menu_FindObject_Tag(entity tProc, string tTagName)
{
	entity tObject;
	
	for (tObject = tProc._tags; isentity(tObject); tObject = tObject._tagnext)
	{
		if (tObject.tag == tTagName)
		{
			foundobject = tObject;
			return 1;
		}
	}
	foundobject = null_entity;
	return 0;
}

float Menu_FindObject_Static(string tName)
{
	entity tObject;
	
	tObject = find(null_entity, name, tName);
	if (isentity(tObject))
	{
		foundobject = tObject;
		return 1;
	}
	foundobject = null_entity;
	return 0;
}

float Menu_FindObject_Directional(entity tStartObject, string tNameString)
{
	entity tObject;
	string tName;
	
	strpart_pos = 0;
	tObject = tStartObject;
	while(strpart_pos >= 0)
	{
		tName = strpart(tNameString, " ", strpart_pos);
		if (tName == "self") // stupid, but useful
			continue;
		if (tName == "next") // next brother
			tObject = tObject._next;
		else if (tName == "prev") // last brother
			tObject = tObject._prev;
		else if (tName == "child") // child
			tObject = tObject._child;
		else if (tName == "template") // template based on
			tObject = tObject._template;		
		else if (tName == "up") // up nav
			tObject = tObject.navUp;		
		else if (tName == "down") // down nav
			tObject = tObject.navDown;
		else if (tName == "left") // left nav
			tObject = tObject.navLeft;		
		else if (tName == "right") // right nav
			tObject = tObject.navRight;		
		else if (tName == "link") // linked to
			tObject = tObject._link;					
		else if (tName == "source") // datasource
			tObject = tObject._datasource;			
		else if (tName == "last") // last brother
		{
			while(isentity(tObject._next))
				tObject = tObject._next;
		}
		else if (tName == "first") // first brother
		{
			while(isentity(tObject._prev))
				tObject = tObject._prev;
		}
		else if (tName == "parent") // parent
			tObject = tObject._parent;	
	}
	// result?
	if (isentity(tObject))
	{
		foundobject = tObject;
		return 1;
	}
	foundobject = null_entity;
	return 0;
}

// find and object
// * - tag search
// : - children-space static link (':ChildName' means 'ParentName:ChildName')
// !! - is the full link (with process)
// >> - node forward search method
// => - node equal-forward search method
// << - node back search method
// =< - node erqual-back search method
// ## - directional
// otherwize - is the link in current process
float Menu_FindObject(entity proc, entity starte, string findstr)
{
	string one, two, str;
	float found, s, f;
	entity o;
	
	one = substring(findstr, 0, 1);
	two = substring(findstr, 0, 2);

	// multiple search threads
	if (one == "[")
	{
		s = 1;
		str = findstr;
		while(one != "")
		{
			if (one != "[")
				return 0; // error
			// get string till ]
			f = strstrofs(str, "]", s);
			if (f <= 0)
				return 0; // error
			findstr = substring(str, s, f - s);
			one = substring(findstr, 0, 1);
			two = substring(findstr, 0, 2);
			// search thread
				 if (one ==  "*") found = Menu_FindObject_Tag(proc, substring(findstr, 1, 10000));              // tagged search
			else if (one ==  ":") found = Menu_FindObject_Static(strcat(starte.name, findstr));                 // childrenspace static link
			else if (two == "!!") found = Menu_FindObject_Static(substring(findstr, 2, 10000));                 // full static
			else if (two == ">>") found = Menu_FindObject_NodeForward(starte, substring(findstr, 2, 10000), 0); // node forward
			else if (two == "=>") found = Menu_FindObject_NodeForward(starte, substring(findstr, 2, 10000), 1); // node equal-forward
			else if (two == "<<") found = Menu_FindObject_NodeBack(starte, substring(findstr, 2, 10000), 0);    // node back
			else if (two == "=<") found = Menu_FindObject_NodeBack(starte, substring(findstr, 2, 10000), 1);    // node equal-back
			else if (two == "##") found = Menu_FindObject_Directional(starte, substring(findstr, 2, 10000));    // directional
			else found = Menu_FindObject_Static(strcat(proc.name, "::", findstr));                              // proc static
			if (!found)
				return 0; // error
			// move and set new thread
			starte = foundobject;
			one = substring(str, f + 1, 1);
			s = f + 2;
		}
		return found;
	}
	
	// single search thread
		 if (one ==  "*") found = Menu_FindObject_Tag(proc, substring(findstr, 1, 10000));              // tagged search
	else if (one ==  ":") found = Menu_FindObject_Static(strcat(starte.name, findstr));                 // childrenspace static link
	else if (two == "!!") found = Menu_FindObject_Static(substring(findstr, 2, 10000));                 // full static
	else if (two == ">>") found = Menu_FindObject_NodeForward(starte, substring(findstr, 2, 10000), 0); // node forward
	else if (two == "=>") found = Menu_FindObject_NodeForward(starte, substring(findstr, 2, 10000), 1); // node equal-forward
	else if (two == "<<") found = Menu_FindObject_NodeBack(starte, substring(findstr, 2, 10000), 0);    // node back
	else if (two == "=<") found = Menu_FindObject_NodeBack(starte, substring(findstr, 2, 10000), 1);    // node equal-back
	else if (two == "##") found = Menu_FindObject_Directional(starte, substring(findstr, 2, 10000));    // directional
	else found = Menu_FindObject_Static(strcat(proc.name, "::", findstr));                              // proc static
	
	return found;
}

// find an object, cast error if not found
//  * - tag search
// !! - is the full link (with process)
// :: - is the link in current process
// >> - node forward search method
// << - node back search method
// ## - directional
entity Menu_GetItem(string findstring)
{
	if (Menu_FindObject(menu_proc, self, findstring))
		return foundobject;
	Menu_Crash(strcat("Menu_GetItem: cannot find ", findstring, "\n"));
	return null_entity;
}

entity Menu_FindItem(string findstring)
{
	Menu_FindObject(menu_proc, self, findstring);
	return foundobject;
}

/*
================================================================================

   OBJECT STUFF
   
================================================================================
*/

// raise select event on item
float Menu_RaiseSelectEvent(entity tObject, .Menu_SelectEvent tEvent, .float tScriptEvent, float tSilent, float tForceEmbedded) 
{
	entity tOldSelf, tChild;
	
	tOldSelf = self;
	// system event
	self = tObject;
	if (self.tEvent) 
		if (!self.tEvent(tSilent))
			return 0;
	// launch script
	self = tObject;
	if (self.tScriptEvent)
		MenuScript_Run(self , self.tScriptEvent);
	self = tOldSelf;
	// run on embedded too
	if (tForceEmbedded || (tObject.mRunFlags & MENU_RUNFLAG_HASEMBEDDED))
		for (tChild = tObject._child; tChild; tChild = tChild._next)
			if (tForceEmbedded || (tChild.mFlags & MENU_FLAG_EMBEDDED))
				Menu_RaiseSelectEvent(tChild, tEvent, tScriptEvent, tSilent, 1);
	return 1;
}

// set new active item
entity Menu_NextSelectable(entity tStartItem);
float Menu_SelectItem(entity tObject, float tSilent) 
{
	entity old_focus;
	
	if (menu_proc.focus == tObject) // don't select twice
		return 0;
	// container redirects to child
	if (tObject.mFlags & MENU_FLAG_CONTAINER)
		if (tObject._child)
			tObject = tObject._child;
	// check if selectable
	if (!Menu_IsSelectable(tObject))
	{
		tObject = Menu_NextSelectable(tObject);
		if (!Menu_IsSelectable(tObject))
			return 0;
		return Menu_SelectItem(tObject, tSilent);
	}
	// deselect previous
	old_focus = menu_proc.focus;
	menu_proc.focus = null_entity;
	if (isentity(old_focus)) 
	{
		if (!Menu_RaiseSelectEvent(old_focus, mDeSelect, onDeselect, tSilent, 0))
		{
			menu_proc.focus = old_focus;
			return 0; // object deny it's deselecting
		}
	}
	if (menu_proc.focus != null_entity)
		return 1; // event has changed focus
	// select new
	old_focus = menu_proc.focus;
	menu_proc.focus = null_entity;
	if (!Menu_RaiseSelectEvent(tObject, mSelect, onSelect, tSilent, 0))
	{
		menu_proc.focus = old_focus;
		return 0; // object deny it's selecting
	}
	if (menu_proc.focus != null_entity)
		return 1; // event has changed focus
	menu_proc.focus = tObject;		
	return 1;
}

// returns currently selected item
entity() Menu_SelectedItem =
{
	return menu_proc.focus;
}

// get next entity
entity Menu_NextSelectable(entity tStartItem)
{
	entity tNextItem, tVisibleItem;

	// select next item
	tNextItem = tStartItem;
	while(tNextItem)
	{
		// if leaving container - jump to _parent._next
		if (!tNextItem._next && tNextItem._parent.mFlags & MENU_FLAG_CONTAINER)
		{
			tNextItem = tNextItem._parent;
			while (!tNextItem._next && tNextItem._parent.mFlags & MENU_FLAG_CONTAINER) // move next or to parent container
				tNextItem = tNextItem._parent;
			tNextItem = tNextItem._next;
			continue;
		}
		// move next
		tNextItem = tNextItem._next;
		// if enter container - move to first visible child
		if (tNextItem.mFlags & MENU_FLAG_CONTAINER)
		{
			// skip unseen items
			for (tVisibleItem = tNextItem._child; tVisibleItem; tVisibleItem = tVisibleItem._next)
			{
				if (sectorsoverlap(tVisibleItem._absmin, tVisibleItem._absmax, tNextItem._absmin, tNextItem._absmax))
				{
					tNextItem = tVisibleItem;
					break;
				}
			}
			if (!tVisibleItem) // oh, there should be one!
				tNextItem = tNextItem._child;
		}
		// jumped to selectable item?
		if (Menu_IsSelectable(tNextItem))
			break;
	}
	// no more items, check from beginning
	if (!tNextItem)
	{
		// check from beginning, cycle back containers (as we don't want to stay on them)
		tNextItem = tStartItem._parent._child;
		while(tNextItem._parent.mFlags & MENU_FLAG_CONTAINER && tNextItem._parent._parent) 
			tNextItem = tNextItem._parent._parent._child;
		// move
		while(tNextItem)
		{
			// if enter container - move to first child
			if (tNextItem.mFlags & MENU_FLAG_CONTAINER)
			{
				tNextItem = tNextItem._child;
				continue;
			}
			// if leaving container - jump to _parent._next
			if (!tNextItem._next && tNextItem._parent.mFlags & MENU_FLAG_CONTAINER)
			{
				tNextItem = tNextItem._parent;
				while (!tNextItem._next && tNextItem._parent.mFlags & MENU_FLAG_CONTAINER) // move next or to parent container
					tNextItem = tNextItem._parent;
				tNextItem = tNextItem._next;
				continue;
			}
			// jumped to selectable item?
			if (Menu_IsSelectable(tNextItem))
				break;
			// move next
			tNextItem = tNextItem._next;
		}
	}
	if (!tNextItem)
		return tStartItem;
	return tNextItem;
}

// get next entity
entity Menu_PrevSelectable(entity tStartItem)
{
	entity tPrevItem, tChild, tVisibleItem;
	
	// select prev item
	tPrevItem = tStartItem;
	while(tPrevItem)
	{
		// if leaving container - jump to _parent._prev or _parent._parent if there is no _prev and _parent is container
		if (!tPrevItem._prev && tPrevItem._parent.mFlags & MENU_FLAG_CONTAINER)
		{
			tChild = tPrevItem._parent;
			while (!tChild._prev && tChild._parent.mFlags & MENU_FLAG_CONTAINER) // move next or to parent container
				tChild = tChild._parent;
			tPrevItem = tChild._prev;
		}
		else
			tPrevItem = tPrevItem._prev;
		// if enter container - move to last child
		while(tPrevItem.mFlags & MENU_FLAG_CONTAINER)
		{
			for(tChild = tPrevItem._child; tChild._next; tChild = tChild._next);
			// skip unseen items
			for (tVisibleItem = tChild; tVisibleItem; tVisibleItem = tVisibleItem._prev)
			{
				if (sectorsoverlap(tVisibleItem._absmin, tVisibleItem._absmax, tPrevItem._absmin, tPrevItem._absmax))
				{
					tPrevItem = tVisibleItem;
					break;
				}
			}
			if (!tVisibleItem) // oh, there should be one!
				tPrevItem = tChild;
		}
		// jumped to selectable item?
		if (Menu_IsSelectable(tPrevItem))
			break;
	}
	if (tPrevItem)
		return tPrevItem;
	// check from end
	// raise up one level for containers
	while (tStartItem._parent.mFlags & MENU_FLAG_CONTAINER)
		tStartItem = tStartItem._parent;
	// get last child
	for(tChild = tStartItem._parent._child; tChild; tChild = tChild._next)
		tPrevItem = tChild;
	// move
	while(tPrevItem)
	{
		// if leaving container - jump to _parent._prev or _parent._parent if there is no _prev and _parent is container
		if (!tPrevItem._prev && tPrevItem._parent.mFlags & MENU_FLAG_CONTAINER)
		{
			tPrevItem = tPrevItem._parent;
			while (!tPrevItem._prev && tPrevItem._parent.mFlags & MENU_FLAG_CONTAINER) // move next or to parent container
				tPrevItem = tPrevItem._parent;
			tPrevItem = tPrevItem._prev;
		}
		// if enter container - move to last child
		if (tPrevItem.mFlags & MENU_FLAG_CONTAINER)
		{
			// get last child
			for(tChild = tPrevItem._child; tChild; tChild = tChild._next)
				tPrevItem = tChild;
			continue;
		}
		// jumped to selectable item?
		if (Menu_IsSelectable(tPrevItem))
			break;
		tPrevItem = tPrevItem._prev;
	}
	if (tPrevItem)
		return tPrevItem;
	// baaad, can't move
	return tStartItem;
}

// get next entity compared to nav chain
void Menu_NavSelect(entity tStartItem, .entity NavFld)
{
	entity tLoop;
	
	if (!Menu_IsSelectable(tStartItem))
	{
		tLoop = tStartItem;
		tStartItem = tStartItem.NavFld;
		while(!Menu_IsSelectable(tStartItem))
		{
			tStartItem = tStartItem.NavFld;
			if (isnotentity(tStartItem) || tStartItem == tLoop)
				return;
		}
	}
	Menu_SelectItem(tStartItem, 0);
}

/*
===================================================

 THINK

===================================================
*/

void Menu_NextThink(void() tThink, float tThinkDelay)
{
	menu_event.mDraw = tThink;
	menu_event.thinktime = time + tThinkDelay;
	menu_event.thinkcontinue = 1;
}

void Menu_NextThinkDelay(float tThinkDelay)
{
	menu_event.thinktime = time + tThinkDelay;
	menu_event.thinkcontinue = 1;
}

/*
===================================================

 TRIGGERS

===================================================
*/

void Menu_TriggerCast(entity tObject) =
{
	entity tOldSelf;
	
	if (isnotentity(tObject))
		return;
	#ifdef MENU_DEVELOPER
	Menu_Debugger_TriggerCast(tObject);
	#endif
	// launch system event
	tOldSelf = self;
	self = tObject;
	if (self.mTrigger)
		self.mTrigger();
	self = tOldSelf;	
	// launch script
	if (tObject.onTrigger)
		MenuScript_Run(tObject, tObject.onTrigger);
}

/*
===================================================

 PROCESSING

===================================================
*/

void() Menu_ProcInit = { }
void() Menu_ProcDestroy = { }
void() Menu_ProcFrame = { }
void() Menu_ProcDraw =
{
	entity tProc, tChild, tNextChild, tSelect, tSelected;
	float tUpdFlags;
	
	if (tProc.mFlags & MENU_FLAG_HIDDEN)
		return;

	// update self
	tProc = menu_proc;
	tUpdFlags = tProc.mRunFlags & (MENU_RUNFLAG_UPDATEPOS + MENU_RUNFLAG_UPDATEOBJECT);
	tProc.mRunFlags = tProc.mRunFlags - tUpdFlags;
	if (tUpdFlags)
	{
		tProc._scale_x = tProc.scalevec_x*tProc.autoEvent;
		tProc._scale_y = tProc.scalevec_y;
	}
	Draw2D_Start("conchars", tProc.size_x, tProc.size_y);
	// pass 1 - update
	for (tChild = tProc._child; tChild; tChild = tNextChild)
	{
		tNextChild = tChild._next;
		tChild.mRunFlags = tChild.mRunFlags | tUpdFlags;
		Menu_Sys_UpdateObjectNode(tChild);
	}
	// pass 2 - process mouse
	if (tProc.cursor && menu_mousemove != '0 0 0')
	{
		tSelected = null_entity;
		for (tChild = tProc._child; tChild; tChild = tChild._next)
		{
			tSelect = Menu_Sys_ObjectNodeProcessMouse(tChild, MENU_MOUSETRACE_SELECT, 0);
			if (tSelect)
				tSelected = tSelect;
		}
		if (tSelected)
			Menu_SelectItem(tSelected, 0);
	}
	// pass 3 - draw
	for (tChild = tProc._child; tChild; tChild = tChild._next)
		Menu_Sys_DrawObjectNode(tChild);
	
	// draw mouse cursor
	// todo: states
	if (tProc.cursor)
		Draw2D_DrawCursor(tProc.cursor, "default", tProc.mousePos);
}

void Menu_RaiseClickEvent(entity tObject, float tEvent, float tKeyCode, float tMouseOver)
{
	entity tOldSelf;
	
	// system event
	if (tObject.mClick)
	{
		tOldSelf = self;
		self = tObject;
		self.mClick(tEvent, tKeyCode, KR_FALSE, tMouseOver);
		self = tOldSelf;
	}
	// script
	if (tEvent == KEYEVENT_RELEASE)
		if (tObject.onClick)
			MenuScript_Run(tObject, tObject.onClick);
}

float Menu_MouseClick(entity tObject, float tEvent, float tKeyCode, float tTraceCheck)
{
	entity tNewSelected;
	float tMouseOver;
	
	// check if really pointing selected item
	tMouseOver = 1;
	if (tTraceCheck && (tObject._proc.mFlags & MENU_PROCFLAG_USEMOUSE))
		if (Menu_Sys_ObjectNodeProcessMouse(tObject, MENU_MOUSETRACE_SELECT, 1) != tObject)
			tMouseOver = 0;
			
	// event
	Menu_RaiseClickEvent(tObject, tEvent, tKeyCode, tMouseOver);
	
	// if item has embedded stuff - launch additional onClick event on it
	if (tObject.mRunFlags & MENU_RUNFLAG_HASEMBEDDED)
	{
		tNewSelected = Menu_Sys_ObjectNodeProcessMouse(tObject, MENU_MOUSETRACE_NORMAL, 1);
		if (isentity(tNewSelected) && tNewSelected != tObject)
			Menu_RaiseClickEvent(tNewSelected, tEvent, tKeyCode, 1);
		else
			Menu_RaiseClickEvent(tNewSelected, tEvent, tKeyCode, 0);
	}
	if (tMouseOver)
		return KR_TRUE;
	return KR_FALSE;
}

float Menu_GlobalKey(entity tObject, float tEvent, float tKeyCode)
{
	float tNavType, tNavDirection;
	entity tNewSelected;
	
	// mouse click
	if (tKeyCode == K_MOUSE1)
		return Menu_MouseClick(tObject, tEvent, tKeyCode, 1);
	// keyboard navigation
	if (tKeyCode == K_MWHEELUP || tKeyCode == K_MWHEELDOWN ||
		tKeyCode == K_DOWNARROW || tKeyCode == K_UPARROW || tKeyCode == K_LEFTARROW || tKeyCode == K_RIGHTARROW)
	{	
		// freeze if interpolating
		for (tNewSelected = tObject; tNewSelected; tNewSelected = tNewSelected._parent)
			if (tNewSelected.mRunFlags & MENU_RUNFLAG_INTERPOLATING) 
				return KR_TRUE | KR_SEAL_PROC | KR_SEAL_ENGINE;
		// next/down
		if (tKeyCode == K_DOWNARROW || tKeyCode == K_MWHEELUP)
		{	
			
			if (tEvent == KEYEVENT_HOLD)
			{
				if (isentity(tObject.navDown))
					Menu_NavSelect(tObject.navDown, navDown);
				else
				{
					tNewSelected = Menu_NextSelectable(tObject);
					if (tNewSelected != tObject) // don't select same item
						Menu_SelectItem(tNewSelected, 0);
				}
			}
			return KR_TRUE | KR_SEAL_PROC | KR_SEAL_ENGINE;
		}
		// prev/up
		if (tKeyCode == K_UPARROW || tKeyCode == K_MWHEELDOWN)
		{
			if (tEvent == KEYEVENT_HOLD)
			{
				if (isentity(tObject.navUp))
					Menu_NavSelect(tObject.navUp, navUp);
				else
				{
					tNewSelected = Menu_PrevSelectable(tObject);
					if (tNewSelected != tObject) // don't select same item
						Menu_SelectItem(tNewSelected, 0);
				}
			}
			return KR_TRUE | KR_SEAL_PROC | KR_SEAL_ENGINE;
		}
		// select left
		if (tKeyCode == K_LEFTARROW)
		{
			if (tEvent == KEYEVENT_HOLD && isentity(tObject.navLeft))
			{
				Menu_NavSelect(tObject.navLeft, navLeft);
				return KR_TRUE | KR_SEAL_PROC | KR_SEAL_ENGINE;
			}
		}
		// select right
		if (tKeyCode == K_RIGHTARROW)
		{
			if (tEvent == KEYEVENT_HOLD && isentity(tObject.navRight))
			{
				Menu_NavSelect(tObject.navRight, navRight);
				return KR_TRUE | KR_SEAL_PROC | KR_SEAL_ENGINE;
			}
		}
	}
	return KR_FALSE;
}

Menu_KeyEvent Menu_ProcKey =
{
	entity tChild, tParent, tProc, tOldSelf;
	float tKeyReturn;

	// process focused item first
	tProc = menu_proc;
	if (isentity(tProc.focus))
	{
		tKeyReturn = Menu_Sys_KeyEventOnNode(tProc.focus, tEvent, tKeyCode, KR_FALSE, 1, 1, 1);
		// default global key
		if (!tKeyReturn && !Menu_IsHidden(tProc.focus))
			tKeyReturn = Menu_GlobalKey(tProc.focus, tEvent, tKeyCode);
	}
	return tKeyReturn;
}

void Menu_SetProc(string tName)
{
	if (!Menu_Sys_FindProc(tName))
	{
		(strcat("Menu_SetProc: cannot found proc '", tName, "'"));
		return;
	}
	menu_proc = foundproc;
}