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

.float _listBuf; // < -100 ones are internal
.float _listRows; // number of spawned list rows
.float _listShift; // the amount of shifted units
.float _listItemShift; // the number of shifted records

// custom runflags
#define LISTBOX_RUNFLAG_REBUILD			MENU_RUNFLAG_CUSTOM1

////////////////////////////////////////
// CODE
////////////////////////////////////////

/*
===================================================

 DATA

===================================================
*/

// replaces a list buffer for list, handles internal and external lists (first are negative - 100)
void Object_ListBox_ReplaceBuf(entity tObject, float bufhandle, float connected_buffer)
{
	if (!bufhandle)
	{
		Menu_Warning(tObject, "Object_ListBox_ReplaceBuf: bad buffer!");
		return;
	}
	// delete old buffer
	if (tObject._listBuf < -100)
		buf_del(0 - (tObject._listBuf + 100));
	// set new
	if (connected_buffer)
	{
		tObject._listBuf = bufhandle;
		return;
	}
	tObject._listBuf = (0 - bufhandle) - 100;
}

// get a true bufhandle from listbox _listbuf
#define Object_ListBox_GetBuf(f,o) if (o._listBuf <= -100) f = 0 - (o._listBuf + 100); else f = o._listBuf;

// creates a listbuffer from string
float Object_ListBox_BufferFromString(string s)
{
	float bh, tokens, i;
	
	bh = buf_create();
	tokens = tokenize(s);
	for (i =0; i < tokens; i++)
		bufstr_set(bh, i, strcat("'", Menu_Data_EscapeToStaticList(argv(i)), "'"));
	return bh;
}

// create a listbuffer from searchpath
// 'fullpath''type''filename''filename_noextension'
#define file_exist(f) strlen(extension(f))
float Object_ListBox_BufferFromPath(string str, float add_directories)
{
	float buf1, buf2, buf3, sh, ss, tokens, i, k, numsearches, search, extlen;
	string tmpn, tmpf, tmp, tpath;
	
	// create buffers
	buf1 = buf_create();
	buf2 = buf_create();
	
	// don't use / at the beginning
	while(substring(str, 0, 1) == "/")
		str = substring(str, 1, 100000);
	
	// add searches
	if (!add_directories) // only basic search
	{
		sh = search_begin(str, 1, 1);
		if (sh >= 0)
		{
			ss = search_getsize(sh);
			for (i = 0; i < ss; i++)
			{
				tmpn = search_getfilename(sh, i);
				tmpf = basename(tmpn);
				if (substring(tmpf, 0, 1) == ".") // considered nasty by FS_CheckNastyPath
					continue;
				if (file_exist(tmpn)) // file
				{
					bufstr_add(buf2, strcat("'", tmpn, "''f''", tmpf, "''", stripextension(tmpf), "'"), 1);
					continue;
				}
				// directory
				if (strstr(tmpn, ".") >= 0) // considered nasty by FS_CheckNastyPath
					continue; 
				bufstr_add(buf1, strcat("'", tmpn, "''d''", tmpf, "''", stripextension(tmpf), "'"), 1);
			}
			search_end(sh);
		}
		// always use first path as backpath
		str = basepath(argv(0)); 
	}
	else
	{
		// extended mode, first is a path, second and more is masks
		numsearches = tokenizebyseparator(str, ";");
		// add a folders
		sh = search_begin(strcat(argv(0), "*"), 1, 1);
		if (sh >= 0)
		{
			ss = search_getsize(sh);
			for (i = 0; i < ss; i++)
			{
				tmpn = search_getfilename(sh, i);
				if (strstr(tmpn, ".") >= 0) // considered nasty by FS_CheckNastyPath
					continue; 
				if (file_exist(tmpn)) // file
					continue;
				// add
				tmpf = basename(tmpn);
				bufstr_add(buf1, strcat("'", tmpn, "''d''", tmpf, "''", tmpf, "'"), 1);
			}
			search_end(sh);
		}
		// add extensions
		tpath = basepath(argv(0));
		for (search = 1; search < numsearches; search++)
		{
			sh = search_begin(strcat(tpath, "*", argv(search)), 1, 1);
			extlen = strlen(argv(search));
			if (sh >= 0)
			{
				ss = search_getsize(sh);
				for (i = 0; i < ss; i++)
				{
					tmpn = search_getfilename(sh, i);
					tmpf = basename(tmpn);
					if (substring(tmpf, 0, 1) == ".") // considered nasty by FS_CheckNastyPath
						continue;
					if (!file_exist(tmpn)) // folders
						continue;
					// add
					bufstr_add(buf2, strcat("'", tmpn, "''f''", tmpf, "''", substring(tmpf, 0, strlen(tmpf)-extlen), "'"), 1);
				}
				search_end(sh);
			}
		}
		// always use first path as backpath
		str = tpath; 
	}
	
	// sort buffers
	buf_sort(buf1, 256, 0);
	buf_sort(buf2, 256, 0);
	
	// add .. folder
	if (add_directories)
	{
		// merge buffers into buffer #3, add ".."
		buf3 = buf_create();
		tmp = basefolder(basefolder(str));
		bufstr_add(buf3, strcat("'", tmp, "''d''..''..'"), 1);
		// append folders
		ss = buf_getsize(buf1);
		for (i = 0; i < ss; i++)
			bufstr_add(buf3, bufstr_get(buf1, i), 1);
		buf_del(buf1);
		buf1 = buf3;
	}
	
	// append buf2 to 1
	ss = buf_getsize(buf2);
	for (i = 0; i < ss; i++)
		bufstr_add(buf1, bufstr_get(buf2, i), 1);
	buf_del(buf2);
	
	return buf1;	
}
#undef file_exist

// cleate a listbuffer from model skins
float Object_ListBox_BufferFromModelSkins(string str) =
{
	float i, buf, sh, ss, fh, num, slen, pathlen;
	string s, ext, numpart, path;
	
	buf = buf_create();
	slen = strlen(str);
	path = basepath(str);
	pathlen = strlen(path);
	// load .skin/.tga/.jpeg files
	sh = search_begin(strcat(str, "_*.*"), 1, 1);
	if (sh < 0) // no skins, add default
	{
		bufstr_add(buf, "'0''Default'", 1);
		return buf;
	}
	// add skins
	for (i = 0, ss = search_getsize(sh); i < ss; i++)
	{
		s = search_getfilename(sh, i);
		ext = extension(s);
		numpart = substring(s, slen+1, strlen(s)-slen-2-strlen(ext)); // number part
		// skip subskins or special textures
		if (strstr(numpart, "_") >= 0)
			continue;
		num = stof(numpart);
		// .skin files are very simple to load and they provide s material paths instead of skinframes
		if (ext == "skin") 
		{
			fh = fopen(s, FILE_READ);
			if (fh < 0) // can't read, add a stub
			{
				bufstr_set(buf, num, strcat("'", numpart, "''", numpart, "'"));
				continue;
			}
			// get a real string (file may contain comments)
			for (ext = fgets(fh); ext; ext = fgets(fh))
				if (tokenize(ext) == 3)
					break;
			if (ext) // got a real string
			{
				ext = argv(2);
				if (!strncmp(ext, path, pathlen)) // if has path in it - cut off
					ext = substring(ext, pathlen, 10000);
				bufstr_set(buf, num, strcat("'", numpart, "''", ext, "'"));
			}			
			else // otherwise return as skinframe
			{
				bufstr_set(buf, num, stripextension(basename(s)));		
			}			
			fclose(fh);
			continue;
		}
		// DP_GFX_EXTERNALTEXTURES, those are just skinframes
		if (ext == "tga" || ext == "jpg" || ext == "pcx" || ext == "png")
		{
			bufstr_set(buf, num, strcat("'", numpart, "''", stripextension(basename(s)), "'"));		
			continue;
		}
		// skip unknown files
	}
	search_end(sh);
	return buf;
}

// retrieves a listbox from given string
// returns if retrieved succesfully
float Object_ListBox_BufferFromSource(entity tObject, string s)
{
	string tmp;
	float v;
	
	// empty text
	if (s == "")
	{
		Object_ListBox_ReplaceBuf(tObject, buf_create(), 0);
		return 1;
	}
	// accept a text-like source
	if (!strncmp(s, "'", 1) || !strncmp(s, "\"", 1))
	{
		Object_ListBox_ReplaceBuf(tObject, Object_ListBox_BufferFromString(s), 0);
		return 1;
	}
	// a static buffer source
	if (!strncmp(s, "buf:", 4))
	{
		v = stof(substring(s, 4, 100000));
		Object_ListBox_ReplaceBuf(tObject, v, 1);
		return 1;
	}
	// build a file tree
	if (!strncmp(s, "dir:", 4))
	{
		Object_ListBox_ReplaceBuf(tObject, Object_ListBox_BufferFromPath(substring(s, 4, 100000), 1), 0);
		return 1;
	}
	// search a path
	if (!strncmp(s, "path:", 5))
	{
		Object_ListBox_ReplaceBuf(tObject, Object_ListBox_BufferFromPath(substring(s, 5, 100000), 0), 0);
		return 1;
	}
	// a tempbuffer source
	if (!strncmp(s, "tmpbuf:", 7))
	{
		v = stof(substring(s, 7, 100000));
		Object_ListBox_ReplaceBuf(tObject, v, 0);
		return 1;
	}
	// a script source
	if (!strncmp(s, "script:", 7))
	{
		tmp = substring(s, 7, 100000);
		tmp = MenuScript_Run(self, MenuScript_Compile(tmp));
		Object_ListBox_ReplaceBuf(tObject, stof(tmp), 0);
		return 1;
	}
	// model skins
	if (!strncmp(s, "modelskins:", 11))
	{
		tmp = substring(s, 11, 100000);
		Object_ListBox_ReplaceBuf(tObject, Object_ListBox_BufferFromModelSkins(tmp), 0);
	}
	return 0;
}

// void(entity tSource)
Menu_DataRefresh Object_ListBox_RefreshData =
{
	string s, tmp;
	float v;
	
	s = Menu_DataSource_GetListValue(self, tSource);
	if (Object_ListBox_BufferFromSource(self, s))
		return;
	// generic method
	self.setMethod(self, MMA_SET, "source", s);
}

/*
===================================================

 UPDATE

===================================================
*/

// update all visible rows
void() Object_ListBox_UpdateRowCaptions =
{
	float i, bh, bs, c;
	entity row;
	string m;
	
	Object_ListBox_GetBuf(bh, self)
	bs = buf_getsize(bh);
	// the only children of listBox is it's rows, so we can start from them
	i = self._listItemShift;
	for (row = self._child; row; row = row._next, i++)
	{
		// hide
		if (i < 0 || i >= bs)
		{
			Menu_Hide(row, "ListBox_");
			continue;
		}
		// unhide, always save full record to "map"
		Menu_Unhide(row, "ListBox_");
		m = bufstr_get(bh, i);
		row.setMethod(row, MMA_SET, "map", m); 
		// fill tokenizebuf so script can access it by argv()/argc()
		ncd_tokenizebuflen = tokenize(m);
		for (c = 0; c < ncd_tokenizebuflen; c++)
			bufstr_set(ncd_tokenizebuf, c, argv(c));
		MenuScript_Run(row, self.onFormat);
	}
}

// set listBox shift
void Object_ListBox_AdjustShift(float tShift)
{
	float tMinShift, tMaxShift;
	
	tMinShift = 0 - self._child.size_y;
	tMaxShift = self._child.size_y;
	// check if going next
	if (tShift <= tMinShift)
	{
		// going next
		self._listItemShift = self._listItemShift + 1;
		self._listShift = 0;
		Menu_SelectItem(Menu_PrevSelectable(menu_proc.focus), 1);
		Object_ListBox_UpdateRowCaptions();
	}
	else if (tShift >= tMaxShift)
	{
		// going prev
		self._listItemShift = self._listItemShift - 1;
		self._listShift = 0;
		Menu_SelectItem(Menu_NextSelectable(menu_proc.focus), 1);
		Object_ListBox_UpdateRowCaptions();
	}
	else 
		self._listShift = tShift;
	// make shift
	self._child.setMethod(self._child, MMA_SET, "pos_y", ftos(self._listShift));
	self.mRunFlags = self.mRunFlags | MENU_RUNFLAG_UPDATEPOS;
}

void() Object_ListBox_BuildRows =
{
	entity row;
	vector rowsize;
	float i, reselect;
	
	// determine if we need reselecting
	for (row = menu_proc.focus._parent; row && !reselect; row = row._parent)
		if (row == self)
			reselect = 1;
	// delete old children
	Menu_Sys_DestroyChildren(self);
	// update position cos it goes after preUpdate (we need it for sise & scale)
	Menu_Sys_UpdateObjectNode_UpdatePos(self);
	// figure out what number of objects we need, always do a +2 for smooth scroll forward & back
	if (isentity(self._link))
	{
		// calc average row size
		rowsize_x = self._link.size_x * self._link.scalevec_x * self._scale_x;
		rowsize_y = self._link.size_y * self._link.scalevec_y * self._scale_y;
		self._listRows = ceil(self._size_y / rowsize_y) + 2;
		// spawn rows (update position immediately)
		for (i = 0; i < self._listRows; i++)
		{
			row = Menu_Sys_CloneObject(self._link, strcat("#", ftos(i)), self, 1);
			Menu_UpdateObjectNode_SpawnClass(row);
		}
	}
	// update whole object to get arrangement working
	self.mRunFlags = self.mRunFlags | MENU_RUNFLAG_UPDATEOBJECT | MENU_RUNFLAG_UPDATEPOS;
	// update row captions
	self._listShift = 0;
	self._listItemShift = -1;
	Object_ListBox_AdjustShift(self._listShift);
	Object_ListBox_UpdateRowCaptions();
	// set a padding to skip over first object
	self.setMethod(self, MMA_SET, "pad_y", ftos(0 - ((self._child.pos_y + self._child.size_y)*self._child.scalevec_y)));
	// reselect
	if (reselect)
		Menu_SelectItem(self._child, 1);
}

void() Object_ListBox_PreUpdate =
{
	ObjectLib_Text_PreUpdate();
	// rebuild rows
	if (self.mRunFlags & LISTBOX_RUNFLAG_REBUILD)
	{
		Object_ListBox_BuildRows();
		self.mRunFlags = self.mRunFlags - LISTBOX_RUNFLAG_REBUILD;
	}
}

void() Object_ListBox_PostUpdate =
{
	ObjectLib_Text_PostUpdate();
}

/*
===================================================

 DRAW & KEY STUFF

===================================================
*/

void() Object_ListBox_Draw =
{	
	float bh;
	
	Object_ListBox_GetBuf(bh, self)
	ObjectLib_Background_Draw();
	// draw text only of no items
	//if (buf_getsize(bh) <= 0)
	//	ObjectLib_Text_Draw();
	// draw scroll bar
	/*
	Draw2D_BackUpClipArea();
	Draw2D_ResetClipArea();
	Draw2D_DrawFill(self._absmin + '-10 0', '10 10', '0.5 0.5 0.5', 1, 0);
	Draw2D_DrawFill(self._absmin + '-10 10', vec2(10, self._size_y - 20), '0.2 0.2 0.2', 1, 0);
	Draw2D_DrawFill(self._absmin + vec2(-10, self._size_y - 10), '10 10', '0.5 0.5 0.5', 1, 0);
	Draw2D_RestoreClipArea();
	*/
}

void() Object_ListBox_PostDraw =
{
	entity e;
	
	ObjectLib_Foreground_Draw();
		
	// determine if we need shifting
	// if any child selected
	for (e = menu_proc.focus._parent; e; e = e._parent)
	{
		if (e != self)
			continue;
		// setup interpolatig flag is moving (freeze keyboard navigation then)
		// shift forward or back while moving in list
		if (menu_proc.focus._absmax_y > self._absmax_y)
		{
			self.mRunFlags = self.mRunFlags | MENU_RUNFLAG_INTERPOLATING;
			Object_ListBox_AdjustShift(self._listShift - menuframetime*250);
		}
		else if (menu_proc.focus._absmin_y < self._absmin_y)
		{
			self.mRunFlags = self.mRunFlags | MENU_RUNFLAG_INTERPOLATING;
			Object_ListBox_AdjustShift(self._listShift + menuframetime*250);
		}
		else self.mRunFlags = self.mRunFlags - (self.mRunFlags & MENU_RUNFLAG_INTERPOLATING);
		break;
	}
}

/*
===================================================

 SPAWN

===================================================
*/

Menu_MethodSetEvent Object_ListBox_SetMethod =
{	
	entity oldlink;
	vector oldsize;
	string tmp;
	float cnum;

	// link update need to rebuild list (as template is changed)
	if (tMethod == "link")
	{
		if (tOp == MMA_SET)
		{
			oldlink = tObject._link;
			Menu_Sys_SetMethod(tObject, tOp, tMethod, tValue);
			if (tObject._link != oldlink)
				tObject.mRunFlags = tObject.mRunFlags | MENU_RUNFLAG_UPDATEOBJECT | LISTBOX_RUNFLAG_REBUILD;
		}
		else warning("link: bad op\n");
	}
	else 
	{
		oldsize = tObject._size; 
		Menu_Sys_SetMethod(tObject, tOp, tMethod, tValue);
		// any size update forces list rebuilding
		if (oldsize != tObject._size)
			tObject.mRunFlags = tObject.mRunFlags | MENU_RUNFLAG_UPDATEOBJECT | LISTBOX_RUNFLAG_REBUILD;
	}
			
	// accept a special source link
	if (tMethod == "source") 
	{
		if (Object_ListBox_BufferFromSource(tObject, tObject.source))
			tObject.mRunFlags = tObject.mRunFlags | MENU_RUNFLAG_UPDATEOBJECT | LISTBOX_RUNFLAG_REBUILD;
		return;
	}
	// datasource link
	Object_DataUser_SetMethod(tObject, tOp, tMethod, tValue);
}

void() Object_ListBox_Spawn =
{
	self.mDraw = Object_ListBox_Draw;
	self.mPostDraw = Object_ListBox_PostDraw;
	self.mDataRefresh = Object_ListBox_RefreshData;
	self.mPreUpdate = Object_ListBox_PreUpdate;
	self.mPostUpdate = Object_ListBox_PostUpdate;
	
	Object_DataUser_Spawn();
}

void() Object_ListBox_Destroy =
{
}

void() Object_ListBox_Init =
{
	self.setMethod = Object_ListBox_SetMethod;
	self.mDestroy = Object_ListBox_Destroy;
	// start defaults
	Menu_Sys_StateMap_AddMethod(self, ":normal", "size", "'200 200'");
	Menu_Sys_StateMap_AddMethod(self, ":normal", "selectable", "1");
	Menu_Sys_StateMap_AddMethod(self, ":normal", "container", "1");
	Menu_Sys_StateMap_AddMethod(self, ":normal", "arrangement", "'0 1'");
	Menu_Sys_StateMap_AddMethod(self, ":normal", "clip", "1");
	Menu_Sys_StateMap_AddMethod(self, ":normal", "textColor", "'0.6 0.6 0.6'");
	Menu_Sys_StateMap_AddMethod(self, ":normal", "textAlign", vtos(DRAW2D_TOPCENTER));
}

void() Object_ListBox =
{
	className = "ListBox";
	classInit = Object_ListBox_Init;
	classSpawn = Object_ListBox_Spawn;
}