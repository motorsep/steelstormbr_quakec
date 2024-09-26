////////////////////////////////////////
// NetherScript v 2.0 source code
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

.entity next;
.entity prev;

// #define NS_PARSER_DEBUG 1
#define NS_PATH							"script/"
#define NS_CACHEPATH					"scriptcache/"
#define NS_EXT							".ns2"
#define NS_LIST_EXT						".nsx"
#define NS_PARSER_MAX_IF_DEPTH			24
#define NS_PARSER_MAX_LABEL_HITS		10000
#define NS_PARSER_MAX_INCLUDES			64 // maximal count of includes per compilation

// pragma defs
#define NS_PRAGMA_DEBUGMODE 1 				// advanced messages during parsing
#define NS_PRAGMA_DEBUGMODE_MESSAGES 2		// allow #debug message
#define NS_PRAGMA_LABELS_ON_FAILED_IFS	4 	// force labels to be registered in #if that failed, this allows some statements featuring
#define NS_PRAGMA_FORBID_PRECOMPILER 8		// disable precompiler functionality

// message types
#define NS_MSG_LOG 		0
#define NS_MSG_MESSAGE 	1

// error codes
#define NS_PARSER_ERROR_STOP 	-1
#define NS_PARSER_ERROR_NO 		0
#define NS_PARSER_ERROR_EOF 	1

// define flags
#define NS_PARSER_DEFINEFLAG_SYSTEM	1 	// system define, not erased on #undefall
#define NS_PARSER_DEFINEFLAG_MACRO 	2 	// appears as @

// filestack/define list/labels list
nosave entity ns_parser_definelist;
nosave entity ns_parser_macrolist;
nosave entity ns_parser_labelslist;
// define parameters
.string def_name;
.string def_value;
.string def_parms;
.float def_flags;
.float def_hits;
// cached file buffers
float ns_cached_files;
float ns_cached_hbuf;
float ns_cached_nbuf;
float ns_cached_rbuf;
// filestacking
nosave float ns_parser_file; 
nosave float ns_parser_filehandle;
nosave string ns_parser_filename;
nosave float ns_parser_filestack[NS_PARSER_MAX_INCLUDES];
nosave float ns_parser_filestack_wordpos[NS_PARSER_MAX_INCLUDES];
nosave float ns_parser_filestack_line[NS_PARSER_MAX_INCLUDES];
nosave string ns_parser_filestack_names[NS_PARSER_MAX_INCLUDES];
nosave string ns_parser_filestack_tokenlines[NS_PARSER_MAX_INCLUDES];
// filesystem
var float(float tQuiet) Ns_Parser_NextLine;
var void(float tSkipLines) Ns_Parser_SkipLines;
// tokenizer
nosave string ns_parser_token;
nosave float	ns_parser_tokenpos;
nosave string ns_parser_tokenline;
nosave float	ns_parser_line;
nosave float	ns_parser_line_numtokens;
// precompiler
nosave float	ns_parser_precompiler;
nosave float	ns_parser_precompiler_pragma;
nosave float	ns_parser_precompiler_if_depth;
nosave float	ns_parser_precompiler_if_results;
// generic states:
nosave float	ns_parser_errorcode;
nosave float	ns_parser_warnings;
// profile
nosave var void() ns_parser_pparse;		// called on each token until file ends
nosave var float() ns_parser_pprecompiler;	// override precompiler functions
nosave var float() ns_parser_pmacro;		// override precompiler macro
nosave var void() ns_parser_pshutdown;		// called in the end of parsing

////////////////////////////////////////
// CODE
////////////////////////////////////////

/*
================================================================================

 MESSAGING

================================================================================
*/

// casts message of various level
void Ns_Parser_Message(float tLevel, string tString)
{
	// messages are printed in low warnings mode or debugmode
	if (tLevel == NS_MSG_MESSAGE) 
	{
		if (ns_parser_warnings < 2 && !(ns_parser_precompiler_pragma & NS_PRAGMA_DEBUGMODE))
			return;
		tString = strcat("Ns_Message: ", tString);
	}
	// logs are printed only in debugmode		
	else if (tLevel == NS_MSG_LOG) 
	{
		if (!(ns_parser_precompiler_pragma & NS_PRAGMA_DEBUGMODE))
			return;
		tString = strcat("Ns_Log: ", tString);
	}
	print(tString);
	print("\n");
}

// casts error message
void Ns_Parser_Error(string tString)
{
	float tPos, tSelPos;
	
	ns_parser_errorcode = NS_PARSER_ERROR_STOP;
	// print error
	print("^1NetherScript 2.0 parser error at (");
#ifdef TARG_MENUPROGS
	print("MENU ");
#else
	#ifdef TARG_CLIENTPROGS
		print("CLIENT ");
	#else
		print("SERVER ");
	#endif
#endif
	print(ns_parser_filename);
	print(":");
	print(ftos(ns_parser_line));
	print("):^7 ");
	print(tString);
	print("\n");
	// print line dump
	tString = "^3last parsed line:^7\n";
	tSelPos = bound(0, ns_parser_tokenpos - 1, ns_parser_line_numtokens-1);
	for (tPos = 0; tPos < ns_parser_line_numtokens; tPos++)
	{
		if (tPos == tSelPos)
			tString = strcat(tString, "^3", strquickmaketoken(argv(tPos)), "^7 ");
		else
			tString = strcat(tString, strquickmaketoken(argv(tPos)), " ");
	}
	print(tString);
	print("\n");
}

// casts warning message
void Ns_Parser_Warning(string tString)
{
	if (ns_parser_warnings == 0 && !(ns_parser_precompiler_pragma & NS_PRAGMA_DEBUGMODE))
		return;
	print("^3NetherScript 2.0 parser warning (");
	print(ns_parser_filename);
	print(":");
	print(ftos(ns_parser_line));
	print("):^7 ");
	print(tString);
	print("\n");
}

/*
================================================================================

 FILE SYSTEM

================================================================================
*/

float() Ns_Parser_FS_EndFile;
// next line for file parsing
float Ns_Parser_FS_NextLine_File(float tQuiet)
{
	float tEndFileCounter;
	
	ns_parser_tokenpos = 0;
	ns_parser_line_numtokens = 0;
	for(tEndFileCounter = 0; ns_parser_line_numtokens == 0; tEndFileCounter++)
	{
		if (tEndFileCounter > 16)
		{
			if (Ns_Parser_FS_EndFile())
			{
				ns_parser_errorcode = NS_PARSER_ERROR_EOF;
				return 0;
			}
			return 1;
		}
		ns_parser_tokenline = fgets(ns_parser_filehandle);
		ns_parser_line++;
		ns_parser_line_numtokens = tokenize(ns_parser_tokenline);
	}
	return 1;
}

// next line for cached file parsing
float Ns_Parser_FS_NextLine_Buffer(float tQuiet)
{
	ns_parser_tokenpos = 0;
	ns_parser_line_numtokens = 0;
	// read from buffer
	while(ns_parser_line_numtokens == 0)
	{	
		if (ns_parser_line >= buf_getsize(ns_parser_filehandle))
		{
			if (Ns_Parser_FS_EndFile())
			{
				ns_parser_errorcode = NS_PARSER_ERROR_EOF;
				return 0;
			}
			return 1;
		}
		ns_parser_tokenline = bufstr_get(ns_parser_filehandle, ns_parser_line);
		ns_parser_line_numtokens = tokenize(ns_parser_tokenline);
		ns_parser_line++;
	}
	return 1;
}

// next line for file parsing
void Ns_Parser_FS_SkipLines_File(float tSkipLines)
{
	float tEndFileCounter;
	
	ns_parser_tokenpos = 0;
	ns_parser_line_numtokens = 0;
	for(tEndFileCounter = 0; tSkipLines >= 0; tSkipLines--)
	{
		if (tEndFileCounter > 16)
			return;
		ns_parser_line++;
		ns_parser_line_numtokens = tokenize(fgets(ns_parser_filehandle));
		if(ns_parser_line_numtokens)
			tEndFileCounter = 0;
		else
			tEndFileCounter++;
	}	
}

// next line for file parsing
void Ns_Parser_FS_SkipLines_Buffer(float tSkipLines)
{
	ns_parser_tokenpos = 0;
	ns_parser_line_numtokens = 0;
	ns_parser_line = ns_parser_line + tSkipLines + 1; 
	ns_parser_tokenline = bufstr_get(ns_parser_filehandle, ns_parser_line);
	ns_parser_line_numtokens = tokenize(ns_parser_tokenline);
}

// restore current globals from filestack
void Ns_Parser_FS_RestoreState(float tStackPos)
{
	if (tStackPos < 0 || tStackPos >= NS_PARSER_MAX_INCLUDES)
	{
		Ns_Parser_Error(strcat("RestoreFromFilestack: unknown filestack handle ", ftos(ns_parser_file)));
		return;
	}
	ns_parser_filehandle = ns_parser_filestack[tStackPos];
	ns_parser_filename = ns_parser_filestack_names[tStackPos];
	ns_parser_tokenpos = ns_parser_filestack_wordpos[tStackPos];
	ns_parser_tokenline = ns_parser_filestack_tokenlines[tStackPos];
	ns_parser_line = ns_parser_filestack_line[tStackPos];	
	// set hub functions
	if (substring(ns_parser_filename, 0, 1) == "*") // buffer
	{
		Ns_Parser_NextLine = Ns_Parser_FS_NextLine_Buffer;
		Ns_Parser_SkipLines = Ns_Parser_FS_SkipLines_Buffer;
	}
	else
	{
		Ns_Parser_NextLine = Ns_Parser_FS_NextLine_File;
		Ns_Parser_SkipLines = Ns_Parser_FS_SkipLines_File;
	}
	Ns_Parser_NextLine(1);
}

// save current globals to filestack
void() Ns_Parser_FS_SaveState =
{
	if (ns_parser_file < 0 || ns_parser_file >= NS_PARSER_MAX_INCLUDES)
	{
		Ns_Parser_Error(strcat("Ns_Parser_FS_SaveState: unknown filestack handle ", ftos(ns_parser_file)));
		return;
	}
	ns_parser_filestack[ns_parser_file] = ns_parser_filehandle;
	ns_parser_filestack_names[ns_parser_file] = ns_parser_filename;
	ns_parser_filestack_wordpos[ns_parser_file] = ns_parser_tokenpos;
	ns_parser_filestack_tokenlines[ns_parser_file] = ns_parser_tokenline;
	ns_parser_filestack_line[ns_parser_file] = ns_parser_line;
}

// get real path of file
string Ns_Parser_FS_FileRealPath(string tFilePath)
{
	if (sleft(tFilePath, 1) == "<" && sright(tFilePath, 1) == ">")
		return strcat("system/", substring(tFilePath, 1, strlen(tFilePath)-2));
	if (sleft(tFilePath, 2) == "./")
		return strcat(basepath(ns_parser_filename), substring(tFilePath, 2, 10000));
	return tFilePath;
}

float Ns_Parser_FS_GetCachedFileBuf(string tFilePath)
{
	float tPos;
	
	for (tPos = 0; tPos < ns_cached_files; tPos++)
		if (bufstr_get(ns_cached_nbuf, tPos) == tFilePath)
			return tPos;
	return -1;
}

void Ns_Parser_FS_RegisterCachedFile(float tBuf, string tFilePath, float tAutoRemove)
{
	if (Ns_Parser_FS_GetCachedFileBuf(tFilePath) >= 0)
	{
		Ns_Parser_Warning(strcat("CachedFile: File '", tFilePath, "' already cached, cancelling"));
		return;
	}
	if (ns_cached_hbuf < 0 || ns_cached_nbuf < 0 || ns_cached_rbuf < 0)
		return;
	bufstr_set(ns_cached_hbuf, ns_cached_files, ftos(tBuf));
	bufstr_set(ns_cached_nbuf, ns_cached_files, tFilePath);
	bufstr_set(ns_cached_rbuf, ns_cached_files, ftos(tAutoRemove));
}

float Ns_Parser_FS_CacheFile(string tFilePath)
{
	float tFile, tEndFileCounter, tBuf, tLineNum;
	string tLine, tFullFilePath;
	
	// try to open file, check absolute path, if not found - check relative
	if (substring(tFilePath, 0, strlen(NS_PATH)) != NS_PATH)
		tFullFilePath = strcat(NS_PATH, tFilePath);
	else
		tFullFilePath = tFilePath;
	tFile = fopen(tFullFilePath, FILE_READ);
	if (tFile < 0)
	{
		Ns_Parser_Error(strcat("Cannot open '", tFullFilePath, "'!\n"));
		return 0;
	}
	// create buffer
	tBuf = buf_create();
	if (tBuf < 0)
	{
		Ns_Parser_Error(strcat("Failed to create buffer for '", tFullFilePath, "'!\n"));
		fclose(tFile);
		return 0;
	}
	// cache file
	tLineNum = 0;
	for(tEndFileCounter = 0; tEndFileCounter < 16; tEndFileCounter++)
	{
		tLine = fgets(ns_parser_filehandle);
		if (tLine != "")
			tEndFileCounter = 0;
		bufstr_set(tBuf, tLineNum, tLine);
		tLineNum++;
	}
	// close
	fclose(tFile);
	return tBuf;
}

// adds string buffer to parse process
float Ns_Parser_FS_AddBufferToStack(float tBufHandle, string tBufName)
{
	float tPos;
	 
	tBufName = strcat(tBufName, "*");
	// debug message
	Ns_Parser_Message(NS_MSG_LOG, strcat("Adding buffer #", ftos(tBufHandle), "(", tBufName, ")..."));
	// check if buffer is already included
	for (tPos = 0; tPos <= ns_parser_file; tPos++)
	{
		if (ns_parser_filestack_names[tPos] == tBufName && ns_parser_filestack[tPos] == tBufHandle)
		{
			Ns_Parser_Error(strcat("Recusive include detected for buffer #", ftos(tBufHandle), "(", tBufName, ")!"));
			return 0;
		}
	}
	// cast max includes reached error ---
	if (ns_parser_file >= (NS_PARSER_MAX_INCLUDES - 1))
	{
		Ns_Parser_Error("reached NS_PARSER_MAXINCLUDES");
		return 0;
	}
	// cast file-not-opened error
	if (buf_getsize(tBufHandle) == -1)
	{
		Ns_Parser_Error(strcat("Cannot open buffer #", ftos(tBufHandle), "(", tBufName, ")!\n"));
		return 0;
	}
	// backup currently parsed file
	if (ns_parser_file >= 0)
		Ns_Parser_FS_SaveState();
	// add to stack
	ns_parser_file++;
	ns_parser_filehandle = tBufHandle;
	ns_parser_filename = tBufName;
	ns_parser_tokenpos = 0;
	ns_parser_tokenline = "";
	ns_parser_line = 0;
	Ns_Parser_NextLine = Ns_Parser_FS_NextLine_Buffer;
	Ns_Parser_SkipLines = Ns_Parser_FS_SkipLines_Buffer;
	Ns_Parser_FS_SaveState();
	// initiate file parsing (start conditions for ReadToken)
	Ns_Parser_NextLine(0);
	return TRUE;
}

// reopens file with given line
void Ns_Parser_FS_ReopenFile(float tSkipLines)
{
	if (substring(ns_parser_filename, 0, 1) == "*")
		ns_parser_line = 0;
	else
	{
		if (ns_parser_filehandle >= 0)
			fclose(ns_parser_filehandle);
		ns_parser_line = 0;
		if (substring(ns_parser_filename, 0, strlen(NS_PATH)) != NS_PATH)
			ns_parser_filehandle = fopen(strcat(NS_PATH, ns_parser_filename), FILE_READ);
		else
			ns_parser_filehandle = fopen(ns_parser_filename, FILE_READ);
	}
	Ns_Parser_SkipLines(tSkipLines);
	Ns_Parser_FS_SaveState();
}

// adds file to parse process
float Ns_Parser_FS_AddFileToStack(string tFilePath)
{
	float tFile, tPos;
	string tFullFilePath;

	// check if file is cached
	tPos = Ns_Parser_FS_GetCachedFileBuf(tFilePath);
	if (tPos >= 0)
		return Ns_Parser_FS_AddBufferToStack(tPos, bufstr_get(ns_cached_nbuf, tPos));
	// debug meggase
	Ns_Parser_Message(NS_MSG_LOG, strcat("Adding '", tFilePath, "'..."));
	// check if file is already included
	for (tPos = 0; tPos <= ns_parser_file; tPos++)
	{
		if (ns_parser_filestack_names[tPos] == tFilePath)
		{
			Ns_Parser_Error(strcat("Recusive include detected for '", tFilePath, "'!"));
			return 0;
		}
	}
	// cast max includes reached error ---
	if (ns_parser_file >= (NS_PARSER_MAX_INCLUDES - 1))
	{
		Ns_Parser_Error("reached NS_PARSER_MAXINCLUDES");
		return 0;
	}
	// try to open file, check absolute path, if not found - check relative
	tFullFilePath = strcat(NS_PATH, tFilePath);
	tFile = fopen(tFullFilePath, FILE_READ);
	if (tFile < 0)
	{
		Ns_Parser_Error(strcat("Cannot open '", tFullFilePath, "'!\n"));
		return 0;
	}
	// backup currently parsed file
	if (ns_parser_file >= 0)
		Ns_Parser_FS_SaveState();
	// add to stack
	ns_parser_file++;
	ns_parser_filehandle = tFile;
	ns_parser_filename = tFilePath;
	ns_parser_tokenpos = 0;
	ns_parser_tokenline = "";
	ns_parser_line = 0;
	Ns_Parser_NextLine = Ns_Parser_FS_NextLine_File;
	Ns_Parser_SkipLines = Ns_Parser_FS_SkipLines_File;
	Ns_Parser_FS_SaveState();
	// initiate file parsing (start conditions for ReadToken)
	Ns_Parser_NextLine(0);
	return TRUE;
}

// curent file is ended, process parent file or stop compilation
// returns true if stack is empty and there is nothing to parse
float() Ns_Parser_FS_EndFile =
{
	// close current file
	if (substring(ns_parser_filename, 0, 1) != "*")
		fclose(ns_parser_filestack[ns_parser_file]);
	ns_parser_filestack[ns_parser_file] = -1;
	// move filestack pos back
	ns_parser_file--;
	if (ns_parser_file >= 0)
	{
		Ns_Parser_FS_RestoreState(ns_parser_file);
		return 0;
	}
	return 1;
}

// init parser file system
void() Ns_Parser_FS_Init =
{
	float tPos;

	ns_parser_file = -1; 
	ns_parser_filehandle = -1;
	ns_parser_filename = "";
	ns_parser_line = 0;
	ns_parser_tokenpos = 0;
	ns_parser_line_numtokens = -1;
	// setup cached files buffers
	ns_cached_files = 0;
	ns_cached_hbuf = buf_create();
	ns_cached_nbuf = buf_create();
	ns_cached_rbuf = buf_create();
	if (ns_cached_hbuf < 0 || ns_cached_nbuf < 0 || ns_cached_rbuf < 0)
		Ns_Parser_Warning("Failed to create cache buffers, filecaching will be disabled");
	// clear filestack
	for (tPos = 0; tPos < NS_PARSER_MAX_INCLUDES; tPos++)
	{
		ns_parser_filestack[tPos] = -1;
		ns_parser_filestack_names[tPos] = "";
		ns_parser_filestack_wordpos[tPos] = 0;
		ns_parser_filestack_tokenlines[tPos] = "";
	}
	ns_parser_line = 0;
	ns_parser_tokenpos = 0;
	ns_parser_line_numtokens = -1;
}

// shutdown parser file system
void() Ns_Parser_FS_Shutdown =
{
	float tPos;
	
	// close cache buffers
	if (ns_cached_files)
	{
		for (tPos = 0; tPos < ns_cached_files; tPos++)
		{
			if (!stof(bufstr_get(ns_cached_rbuf, tPos)))
				continue;
			buf_del(stof(bufstr_get(ns_cached_hbuf, tPos)));
		}
	}
	buf_del(ns_cached_hbuf);
	buf_del(ns_cached_nbuf);
	buf_del(ns_cached_rbuf);
	// close opened files
	if (ns_parser_file >= 0)
	{
		while (1)
			if (Ns_Parser_FS_EndFile())
				break;
	}
}

/*
================================================================================

 PARSES DEFINES/MACROS LIST

================================================================================
*/

entity Ns_Parser_DefineList_Find(string tName, float tIsMacro)
{
	entity tDefine;
	
	// find macro
	if (tIsMacro)
	{
		for (tDefine = ns_parser_macrolist; tDefine; tDefine = tDefine.next)
			if (tDefine.def_name == tName)
				return tDefine;
		return null_entity;
	}
	// standart define
	for (tDefine = ns_parser_definelist; tDefine; tDefine = tDefine.next)
		if (tDefine.def_name == tName)
			return tDefine;
	return null_entity;
}

entity Ns_Parser_DefineList_Add(string tName, string tContent, string tParms, float tFlags, float tRedefine)
{
	entity tNewDef, tLastDef, tDef;

	tDef = Ns_Parser_DefineList_Find(tName, (tFlags & NS_PARSER_DEFINEFLAG_MACRO));
	if (!tDef)
	{
		tNewDef = spawn();
		if (tFlags & NS_PARSER_DEFINEFLAG_MACRO)
		{
			if (!ns_parser_macrolist)
			{
				ns_parser_macrolist = tNewDef;
				tNewDef.next = null_entity;
				tNewDef.prev = null_entity;
			}
			else
			{
				for (tDef = ns_parser_macrolist; tDef; tDef = tDef.next)
					tLastDef = tDef;
				tLastDef.next = tNewDef;
				tNewDef.prev = tLastDef;
				tNewDef.next = null_entity;
			}
		}
		else
		{
			if (!ns_parser_definelist)
			{
				ns_parser_definelist = tNewDef;
				tNewDef.next = null_entity;
				tNewDef.prev = null_entity;
			}
			else
			{
				for (tDef = ns_parser_definelist; tDef; tDef = tDef.next)
					tLastDef = tDef;
				tLastDef.next = tNewDef;
				tNewDef.prev = tLastDef;
				tNewDef.next = null_entity;
			}
		}
		tNewDef.def_name = strzone(tName);
		tNewDef.def_value = strzone(tContent);
		tNewDef.def_parms = strzone(tParms);
		tNewDef.def_flags = tFlags;
	}
	else 
	{
		if (tRedefine == 0)
		{
			Ns_Parser_Warning(strcat("Define ", tDef.def_name, " already exists"));
			return tDef;
		}
		if (tRedefine == 1)
			Ns_Parser_Warning(strcat("Define ", tDef.def_name, " already exists, it will be redefined"));
		tNewDef = tDef;
		strunzone(tNewDef.def_name);
		strunzone(tNewDef.def_value);
		strunzone(tNewDef.def_parms);
	}
	// set
	tNewDef.def_name = strzone(tName);
	tNewDef.def_value = strzone(tContent);
	tNewDef.def_parms = strzone(tParms);
	tNewDef.def_flags = tFlags;
	
	return tNewDef;
}

float Ns_Parser_DefineList_Remove(entity tDefine, float tForceEraseSystemDef)
{
	if ((tDefine.def_flags & NS_PARSER_DEFINEFLAG_SYSTEM) && !tForceEraseSystemDef)
		return 0;
	// common clear
	if (tDefine.prev)
		tDefine.prev.next = tDefine.next;
	if (tDefine.next)
		tDefine.next.prev = tDefine.prev;
	strunzone(tDefine.def_name);
	strunzone(tDefine.def_value);
	strunzone(tDefine.def_parms);
	// clear define or macro list
	if (tDefine.def_flags & NS_PARSER_DEFINEFLAG_MACRO)
	{
		if (ns_parser_macrolist == tDefine)
			ns_parser_macrolist = tDefine.next;
	}
	else if (ns_parser_definelist == tDefine)
		ns_parser_definelist = tDefine.next;
	// remove
	remove(tDefine);
	return 1;
}

void Ns_Parser_DefineList_Clear(float tEraseSystemDefs)
{
	entity tDefine, tNextDef;
	
	for (tDefine = ns_parser_definelist; tDefine; tDefine = tNextDef)
	{
		tNextDef = tDefine.next;
		Ns_Parser_DefineList_Remove(tDefine, tEraseSystemDefs);
	}
	for (tDefine = ns_parser_macrolist; tDefine; tDefine = tNextDef)
	{
		tNextDef = tDefine.next;
		Ns_Parser_DefineList_Remove(tDefine, tEraseSystemDefs);
	}
}

/*
================================================================================

 PARSER LABEL LIST

================================================================================
*/

entity Ns_Parser_LabelsList_Find(string tName)
{
	entity tLabel;

	for (tLabel = ns_parser_labelslist; tLabel; tLabel = tLabel.next)
		if (tLabel.def_name == tName)
			return tLabel;
	return null_entity;
}

entity Ns_Parser_LabelsList_Add(string tName, float tLine)
{
	entity tNewLabel, tLastLabel, tLabel;

	// check if such label already exists
	tLabel = Ns_Parser_LabelsList_Find(tName);
	if (tLabel)
	{
		Ns_Parser_Warning(strcat("Label ", tLabel.def_name, " already exists"));
		return tLabel;
	}
	// spawn
	tNewLabel = spawn();
	tNewLabel.def_name = strzone(tName);
	tNewLabel.def_flags = tLine;
	tNewLabel.def_hits = NS_PARSER_MAX_LABEL_HITS - 1;
	// add to chain
	if (!ns_parser_labelslist)
	{
		ns_parser_labelslist = tNewLabel;
		tNewLabel.next = null_entity;
		tNewLabel.prev = null_entity;
	}
	else
	{
		for (tLabel = ns_parser_labelslist; tLabel; tLabel = tLabel.next)
			tLastLabel = tLabel;
		tLastLabel.next = tNewLabel;
		tNewLabel.prev = tLastLabel;
		tNewLabel.next = null_entity;
	}
	return tNewLabel;
}

float Ns_Parser_LabelsList_Remove(entity tLabel)
{
	if (tLabel.prev)
		tLabel.prev.next = tLabel.next;
	if (tLabel.next)
		tLabel.next.prev = tLabel.prev;
	if (ns_parser_labelslist == tLabel)
		ns_parser_labelslist = tLabel.next;
	strunzone(tLabel.def_name);
	remove(tLabel);
	return 1;
}

void() Ns_Parser_LabelsList_Clear =
{
	entity tLabel, tNextLabel;
	
	for (tLabel = ns_parser_labelslist; tLabel; tLabel = tNextLabel)
	{
		tNextLabel = tLabel.next;
		Ns_Parser_LabelsList_Remove(tLabel);
	}
}

/*
================================================================================

 PARSER GENERIC

================================================================================
*/

void Ns_Parser_SetToken(string tToken)
{
	ns_parser_token = tToken;
};

// get next token (automatically jumps to next line)
// can processes defines and macro functions
void Ns_Parser_Precompiler();
float Ns_Parser_ProcessDefine(entity tMacroDef);
float Ns_Parser_ProcessMacro();
#define Ns_Parser_ReadToken() _Ns_Parser_ReadToken(1)
float _Ns_Parser_ReadToken(float tAllowNextLine) =
{
	// go to next line
	if (ns_parser_tokenpos >= ns_parser_line_numtokens) 
	{
		if (tAllowNextLine)
		{
			if (Ns_Parser_NextLine(0) == 0)
				return 0;
		}
		else
		{
			ns_parser_token = "";
			return 0;
		}
	}
			
	// get token
	ns_parser_token = argv(ns_parser_tokenpos);
	ns_parser_tokenpos++;
	
	// check for parser-related command prefixed with #...
	if (ns_parser_precompiler <= 0)
		return 1;

	// replacing #define
	if (ns_parser_token == "[")
		return Ns_Parser_ProcessDefine(null_entity);
		
	// process macro-command
	if (substring(ns_parser_token, 0,1) == "@")
		return Ns_Parser_ProcessMacro();

	if (ns_parser_tokenpos != 1)
		return 1;
	
	// VorteX: here is the support for long chainlists of precompiler commands
	// the code like this is much shorter and cleaner:
	// if (substring(ns_parser_token, 0,1) == "#")
	// {
	//     Ns_Parser_Precompiler();
	//     if (ns_parser_errorcode == NS_PARSER_ERROR_NO)
	//        Ns_Parser_ReadToken();
	// }
	// but:
	// 1) in case of long lists of precompiler commands (like #label Label1 maxhits 10000 \n #message " hit" \n #goto Label1)
	// it will give a restriction of 256 commands cause it will do recursion function call for each # command
	// 2) the fact that script can crash QC is bad, so we must avoid it
	// so we need to get rid of recursion with this code here:
	while (substring(ns_parser_token, 0,1) == "#")
	{
		Ns_Parser_Precompiler();
		if (ns_parser_errorcode)
			break; // so precompiler can cast errors...
		// go to next line
		if (ns_parser_tokenpos >= ns_parser_line_numtokens)
		{
			if (!Ns_Parser_NextLine(0))
			{
				Ns_Parser_SetToken("");
				ns_parser_errorcode = NS_PARSER_ERROR_EOF;
				return 0;
			}
		}
		// load token
		ns_parser_token = argv(ns_parser_tokenpos);
		ns_parser_tokenpos++;
		// replacing #define
		if (ns_parser_token == "[")
			return Ns_Parser_ProcessDefine(null_entity);
		// process macro-command
		if (substring(ns_parser_token, 0,1) == "@")
			return Ns_Parser_ProcessMacro();
	}
	
	return 1;
}

// return true if end of line
#define Ns_Parser_EndOfLine() (ns_parser_tokenpos >= ns_parser_line_numtokens)

// gets next command argument, pretty similar to Ns_Parser_ReadToken
// but don't jumps to next line and don't checks for '#' commands
// arguments skips "," and have special detection method for ",," or "(," (todo)
// alse they can jump of nextline if " \ " is founded
// arguments can't be precompiler directives, # are not allowed
void Ns_Parser_SetToken(string tToken);
#define Ns_Parser_ReadArg() _Ns_Parser_ReadArgument(0,0,1,0)
#define Ns_Parser_ReadArgNoConcat() _Ns_Parser_ReadArgument(0,0,0,0)
#define Ns_Parser_ReadOptionalArg() _Ns_Parser_ReadArgument(0,1,1,0)
#define Ns_Parser_ReadOptionalArgNoConcat() _Ns_Parser_ReadArgument(0,1,0,0)
#define Ns_Parser_ReadParm() _Ns_Parser_ReadArgument(0,0,1,1)
#define Ns_Parser_ReadParmNoConcat() _Ns_Parser_ReadArgument(0,0,0,1)
#define Ns_Parser_ReadOptionalParm() _Ns_Parser_ReadArgument(0,1,1,1)
#define Ns_Parser_ReadOptionalParmNoConcat() _Ns_Parser_ReadArgument(0,1,0,1)
float _Ns_Parser_ReadArgument(float tCommaSkippedAlready, float tOptional, float tUseConcat, float tUseCommas)
{
	string tFirstChar;
	string tPrevToken, tToken;
	float tReaded;
	
	tReaded = _Ns_Parser_ReadToken(0);
	if (!tReaded)
	{
		if (!tOptional)
			Ns_Parser_Warning("command argument expected, found end-of-line");
		return 0;
	}
	
	// check for concantenator operator &
	if (tUseConcat && (ns_parser_precompiler > 0) && (argv(ns_parser_tokenpos) == "&"))
	{
		tToken = ns_parser_token;
		while (argv(ns_parser_tokenpos) == "&")
		{
			ns_parser_tokenpos++;
			_Ns_Parser_ReadArgument(tCommaSkippedAlready, tOptional, tUseConcat, tUseCommas);
			tToken = strcat(tToken, ns_parser_token);
		}
		Ns_Parser_SetToken(tToken);
		return 1;	
	}

	// newline for args
	if (ns_parser_token == "\\")
	{
		if (!Ns_Parser_NextLine(1))
		{
			Ns_Parser_SetToken("");
			return FALSE;
		}
		return _Ns_Parser_ReadArgument(tCommaSkippedAlready, tOptional, tUseConcat, tUseCommas);
	}
	
	// skip over ","
	// in case of ,, - this should be null token
	if (tUseCommas)	
	{
		// found ","
		if (ns_parser_token == ",")
		{
			// check if it was real , not ","
			if (substring(ns_parser_tokenline, argv_start_index(ns_parser_tokenpos-1), 1) == ",")
			{
				if (tCommaSkippedAlready)
				{
					Ns_Parser_SetToken("");
					ns_parser_tokenpos--; // round back
					return TRUE;
				}
				return _Ns_Parser_ReadArgument(1, tOptional, tUseConcat, tUseCommas);
			}
		}
	}
	
	return 1;
}

// replaces token by some string and re-tokenizes line
void Ns_Parser_ReplaceTokensByString(float tFirstTokenIndex, float tNumTokens, string tString)
{
	string tAltTokenizedLine;
	float tPos;

	// get real pos
	tFirstTokenIndex = tFirstTokenIndex - 1;
	// build alternative tokenized line with replaced define
	for (tPos = 0; tPos < tFirstTokenIndex; tPos++)
		tAltTokenizedLine = strcat(tAltTokenizedLine, strquickmaketoken(argv(tPos)), " ");
	tAltTokenizedLine = strcat(tAltTokenizedLine, tString, " ");
	for (tPos = tFirstTokenIndex + tNumTokens; tPos < ns_parser_line_numtokens; tPos++)
		tAltTokenizedLine = strcat(tAltTokenizedLine, strquickmaketoken(argv(tPos)), " ");
	// alternate token line and return first argument
	ns_parser_tokenline = tAltTokenizedLine;
	ns_parser_line_numtokens = tokenize(tAltTokenizedLine);
	ns_parser_token = argv(tFirstTokenIndex);
	ns_parser_tokenpos = tFirstTokenIndex+1;
}

// replace a parameter in define value - 1 parameter
string Ns_Parser_ProcessDefine_ReplaceParm1(string tStr, string tFind, string tReplace)
{
	float tPos, tFindLen, tAddPos;
	string tResult;
	
	tPos = 0;
	tAddPos = 0;
	tFindLen = strlen(tFind);
	while(1)
	{
		tPos = strstrofs(tStr, "%", tPos);
		if (tPos < 0)
			break;
		if (substring(tStr, tPos, tFindLen) == tFind)
		{
			tResult = strcat(tResult, substring(tStr, tAddPos, tPos-tAddPos), tReplace);
			tAddPos = tPos + tFindLen;
		}
		tPos++;
	}
	// add tail
	tResult = strcat(tResult, substring(tStr, tAddPos, 10000));
	return tResult;
}

// replace a parameter in define value - 2 parameter batch
string Ns_Parser_ProcessDefine_ReplaceParm2(string tStr, string tFind, string tReplace, string tFind2, string tReplace2)
{
	float tPos, tFindLen, tFind2Len, tAddPos;
	string tResult;
	
	tPos = 0;
	tAddPos = 0;
	tFindLen = strlen(tFind);
	tFind2Len = strlen(tFind2);
	while(1)
	{
		tPos = strstrofs(tStr, "%", tPos);
		if (tPos < 0)
			break;
		if (substring(tStr, tPos, tFindLen) == tFind)
		{
			tResult = strcat(tResult, substring(tStr, tAddPos, tPos-tAddPos), tReplace);
			tAddPos = tPos + tFindLen;
		}
		if (substring(tStr, tPos, tFind2Len) == tFind2)
		{
			tResult = strcat(tResult, substring(tStr, tAddPos, tPos-tAddPos), tReplace2);
			tAddPos = tPos + tFind2Len;
		}
		tPos++;
	}
	// add tail
	tResult = strcat(tResult, substring(tStr, tAddPos, 10000));
	return tResult;
}

// replace a parameter in define value - 3 parameter batch
string Ns_Parser_ProcessDefine_ReplaceParm3(string tStr, string tFind, string tReplace, string tFind2, string tReplace2, string tFind3, string tReplace3)
{
	float tPos, tFindLen, tFind2Len, tFind3Len, tAddPos;
	string tResult;
	
	tPos = 0;
	tAddPos = 0;
	tFindLen = strlen(tFind);
	tFind2Len = strlen(tFind2);
	tFind3Len = strlen(tFind3);
	while(1)
	{
		tPos = strstrofs(tStr, "%", tPos);
		if (tPos < 0)
			break;
		if (substring(tStr, tPos, tFindLen) == tFind)
		{
			tResult = strcat(tResult, substring(tStr, tAddPos, tPos-tAddPos), tReplace);
			tAddPos = tPos + tFindLen;
		}
		if (substring(tStr, tPos, tFind2Len) == tFind2)
		{
			tResult = strcat(tResult, substring(tStr, tAddPos, tPos-tAddPos), tReplace2);
			tAddPos = tPos + tFind2Len;
		}
		if (substring(tStr, tPos, tFind3Len) == tFind3)
		{
			tResult = strcat(tResult, substring(tStr, tAddPos, tPos-tAddPos), tReplace3);
			tAddPos = tPos + tFind3Len;
		}
		tPos++;
	}
	// add tail
	tResult = strcat(tResult, substring(tStr, tAddPos, 10000));
	return tResult;
}

#define NS_DEFINE_MAX_PARM_NAME_LENGTH	32
#define NS_DEFINE_MAX_PARMS	16

float Ns_Parser_CheckNext(string tStr, float tAllowLineBreak);
float Ns_Parser_ProcessDefine(entity tIsMacroDef) 
{
	float tPos, tDefPos, tLen, tDefLen, tNumParms, tLeftParms;
	string tParm1, tParm2, tParm3, tParm4, tParm5, tParm6, tParm7, tParm8;
	string tParm9, tParm10, tParm11, tParm12, tParm13, tParm14, tParm15, tParm16;
	string tParm, tParmName, tParmName2, tParmName3, tValue;
	entity tDef;

	tDefPos = ns_parser_tokenpos;
	// get name and find def
	if (tIsMacroDef)
	{
		tDef = tIsMacroDef;
		if (Ns_Parser_CheckNext("(", 0))
		{
			tNumParms = 0;
			// VorteX: 16 parms
			#define endbrace ")"
			#define try(n) if (Ns_Parser_ReadParm()) { if (ns_parser_token != endbrace) { n = ns_parser_token; tNumParms++;
			try(tParm1)
			try(tParm2)
			try(tParm3)
			try(tParm4)
			try(tParm5)
			try(tParm6)
			try(tParm7)
			try(tParm8)
			try(tParm9)
			try(tParm10)
			try(tParm11)
			try(tParm12)
			try(tParm13)
			try(tParm14)
			try(tParm15)
			try(tParm16)
			}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
			#undef try
			#undef endbrace
		}
	}
	else
	{
		// find def
		Ns_Parser_ReadParm();
		tDef = Ns_Parser_DefineList_Find(ns_parser_token, 0);
		if (!tDef)
			Ns_Parser_Warning(strcat("Define '", ns_parser_token, "' not found"));
		// get parms
		Ns_Parser_ReadArgNoConcat();
		if (ns_parser_token == "(")
		{
			tNumParms = 0;
			// VorteX: 16 parms
			#define endbrace ")"
			#define try(n) if (Ns_Parser_ReadParm()) { if (ns_parser_token == endbrace) { n = ns_parser_token; tNumParms++;
			try(tParm1)
			try(tParm2)
			try(tParm3)
			try(tParm4)
			try(tParm5)
			try(tParm6)
			try(tParm7)
			try(tParm8)
			try(tParm9)
			try(tParm10)
			try(tParm11)
			try(tParm12)
			try(tParm13)
			try(tParm14)
			try(tParm15)
			try(tParm16)
			}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
			#undef try
			#undef endbrace
			Ns_Parser_ReadArgNoConcat();
		}
		// --- "]" should be in the end ---
		// --- edit: this is false for macro define calling ---
		if (ns_parser_token != "]")
		{
			Ns_Parser_Error(strcat("expected ']', found '", ns_parser_token, "'"));
			ns_parser_token = "";
			return 0;
		}
	}
	tValue = tDef.def_value;	
	// process parms
	if (tDef.def_parms != "")
		tLen = clump_getlenquick(tDef.def_parms, NS_DEFINE_MAX_PARM_NAME_LENGTH);
	else
		tLen = 0;
	if (tNumParms != tLen)
	{
		Ns_Parser_Warning(strcat("Implicit define macro parms count, should be ", ftos(tLen), " but ", ftos(tNumParms), " is found"));
		tLen = min(tLen, tNumParms);
	}
	// VorteX: 16 parms
	#define get(num) clumpele_extract(clump_getquick(tDef.def_parms, NS_DEFINE_MAX_PARM_NAME_LENGTH, num))
	#define try1(bu,vu) tParmName = get(bu); tValue = Ns_Parser_ProcessDefine_ReplaceParm1(tValue, tParmName, vu);
	#define try2(bu,vu,gu,lu) tParmName = get(bu); tParmName2 = get(gu); tValue = Ns_Parser_ProcessDefine_ReplaceParm2(tValue, tParmName, vu, tParmName2, lu);
	#define try3(bu,vu,gu,lu,zu,du) tParmName = get(bu); tParmName2 = get(gu); tParmName3 = get(zu); tValue = Ns_Parser_ProcessDefine_ReplaceParm3(tValue, tParmName,vu, tParmName2, lu, tParmName3, du);
	     if (tNumParms == 1) { try1(0, tParm1) }
	else if (tNumParms == 2) { try2(0, tParm1, 1, tParm2) }
	else if (tNumParms == 3) { try3(0, tParm1, 1, tParm2, 2, tParm3) }
	else if (tNumParms == 4) { try3(0, tParm1, 1, tParm2, 2, tParm3) try1(3, tParm4) }
	else if (tNumParms == 5) { try3(0, tParm1, 1, tParm2, 2, tParm3) try2(3, tParm4, 4, tParm5) }
	else if (tNumParms == 6) { try3(0, tParm1, 1, tParm2, 2, tParm3) try3(3, tParm4, 4, tParm5, 5, tParm6) }
	else if (tNumParms == 7) { try3(0, tParm1, 1, tParm2, 2, tParm3) try3(3, tParm4, 4, tParm5, 5, tParm6) try1(6, tParm7) }
	else if (tNumParms == 8) { try3(0, tParm1, 1, tParm2, 2, tParm3) try3(3, tParm4, 4, tParm5, 5, tParm6) try2(6, tParm7, 7, tParm8) }
	else if (tNumParms == 9) { try3(0, tParm1, 1, tParm2, 2, tParm3) try3(3, tParm4, 4, tParm5, 5, tParm6) try3(6, tParm7, 7, tParm8, 8, tParm9) }
	else if (tNumParms == 10){ try3(0, tParm1, 1, tParm2, 2, tParm3) try3(3, tParm4, 4, tParm5, 5, tParm6) try3(6, tParm7, 7, tParm8, 8, tParm9) try1(9, tParm10) }
	else if (tNumParms == 11){ try3(0, tParm1, 1, tParm2, 2, tParm3) try3(3, tParm4, 4, tParm5, 5, tParm6) try3(6, tParm7, 7, tParm8, 8, tParm9) try2(9, tParm10, 10, tParm11) }
	else if (tNumParms == 12){ try3(0, tParm1, 1, tParm2, 2, tParm3) try3(3, tParm4, 4, tParm5, 5, tParm6) try3(6, tParm7, 7, tParm8, 8, tParm9) try3(9, tParm10, 10, tParm11, 11, tParm12) }
	#undef get
	#undef try1
	#undef try2
	#undef try3
/*
	if (tDef.def_name == "BigButton")
	{
		print("=================\n");
		print("1", tParm1, "\n");
		print("2", tParm2, "\n");
		print("3", tParm3, "\n");
		print("4", tParm4, "\n");
		print("5", tParm5, "\n");
		print("6", tParm6, "\n");
		print("7", tParm7, "\n");
		print(tValue);
		print("\n=================\n");
	}
*/
	// replace tokens by define value
	Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), tValue);
	return TRUE;
}

// call this if using tokenize/tokenizebyseparator when parsing
void() Ns_Parser_RestoreTokens =
{
	tokenize(ns_parser_tokenline);
}

// read all tokens
string Ns_Parser_GetRestOfLine(float tDontKeepTokenStructure)
{
	string tResult;

	if (!tDontKeepTokenStructure)
	{
		Ns_Parser_ReadOptionalParm();
		tResult = strquickmaketoken(ns_parser_token);
		while(Ns_Parser_ReadOptionalArgNoConcat())
			tResult = strcat(tResult, " ", strquickmaketoken(ns_parser_token));
	}
	else
	{
		Ns_Parser_ReadOptionalParm();
		tResult = ns_parser_token;
		while(Ns_Parser_ReadOptionalArgNoConcat())
			tResult = strcat(tResult, " ", ns_parser_token);
	}
	return tResult;
}

// expects certain command arg and casts error if wrong
// if allright and tCompiled != "" - writes tCompiled to compilation
float Ns_Parser_Expect(string tStr, float tAllowLineBreak)
{
	//ns_parser_precompiler--;
	if (tAllowLineBreak)
		Ns_Parser_ReadToken();
	else
		Ns_Parser_ReadParm();
	//ns_parser_precompiler++;
	if (ns_parser_token != tStr)
	{
		Ns_Parser_Error(strcat("expected '", tStr, "', found '", ns_parser_token, "'"));
		return 0;
	}
	return 1;
}

// expect punctuation element
// the only allowed pucntuation elements that supports line breaks is { and }
float Ns_Parser_ExpectPunctuation(string tStr)
{
	//ns_parser_precompiler--;
	if (tStr == "{" || tStr == "}" )
		Ns_Parser_ReadToken();
	else
		Ns_Parser_ReadArgNoConcat();
	//ns_parser_precompiler++;
	if (ns_parser_token != tStr)
	{
		Ns_Parser_Error(strcat("expected '", tStr, "', found '", ns_parser_token, "'"));
		return 0;
	}
	return 1;
}

// expects to not be as certain command and casts error if wrong
// if allright and tCompiled != "" - writes tCompiled to compilation
void Ns_Parser_UnExpect(string tStr, float tAllowLineBreak)
{
	//ns_parser_precompiler--;
	if (tAllowLineBreak)
		Ns_Parser_ReadToken();
	else
		Ns_Parser_ReadParm();
	//ns_parser_precompiler++;
	if (ns_parser_token == tStr)
	{
		Ns_Parser_Error(strcat("'", ns_parser_token, "' not expected"));
		return;
	}
	ns_parser_tokenpos--;
}

// checks next argument to be equal or not
float Ns_Parser_CheckNext(string tStr, float tAllowLineBreak)
{
	string tPrevToken;
	float tReaded;

	tPrevToken = ns_parser_token;
//	ns_parser_precompiler--;
	if (tAllowLineBreak)
		tReaded = Ns_Parser_ReadToken();
	else
		tReaded = Ns_Parser_ReadOptionalArgNoConcat();
//	ns_parser_precompiler++;
	if (!tReaded)
		return 0;
	if (ns_parser_token == tStr)
		return 1;
	ns_parser_tokenpos--;
	ns_parser_token = tPrevToken;
	return 0;
}

// more advanced Ns_Parser_CheckNext - Ns_Parser_Predict
// it allows to do multiple selections (Ns_Parser_CheckNext allows only one)
nosave float Ns_Parser_Predict_Engaged;
nosave float Ns_Parser_Predict_HasMoved; // VorteX: contains ReadToken/ReadArg result so rollback can be rejected if reached endfile
nosave string Ns_Parser_Predict_PrevToken;
void Ns_Parser_PredictStart(float tAllowLineBreak)
{
	if (Ns_Parser_Predict_Engaged)
	{
		error("Ns_Parser_PredictStart: prediction is already started\n");
		return;
	}

	Ns_Parser_Predict_Engaged = 1;
	Ns_Parser_Predict_PrevToken = ns_parser_token;
//	ns_parser_precompiler--;
	if (tAllowLineBreak)
		Ns_Parser_Predict_HasMoved = Ns_Parser_ReadToken();
	else
		Ns_Parser_Predict_HasMoved = Ns_Parser_ReadOptionalParm();
//	ns_parser_precompiler++;
}

// end prediction pass, if tResult is FALSE a rollback will be performed
void Ns_Parser_PredictEnd(float tResult)
{
	if (!Ns_Parser_Predict_Engaged)
	{
		error("Ns_Parser_PredictEnd: prediction was not started\n");
		return;
	}
	Ns_Parser_Predict_Engaged = 0;
	if (tResult || Ns_Parser_Predict_HasMoved == 0)
		return;
	// rollback
	ns_parser_tokenpos--;
	ns_parser_token = Ns_Parser_Predict_PrevToken;
}

/*
================================================================================

  NSX LISTFILES PARSER
  
  listfiles are usable to store shared data
  
================================================================================
*/

#define NSX_MAX_HANDLES	4
nosave float NSX[NSX_MAX_HANDLES];
nosave float NSX_File[NSX_MAX_HANDLES];
nosave string NSX_Line[NSX_MAX_HANDLES];
nosave string NSX_Group[NSX_MAX_HANDLES]; 
nosave string NSX_GroupSep[NSX_MAX_HANDLES]; 
nosave string NSX_GroupMap[NSX_MAX_HANDLES];
nosave float NSX_GroupMapDecompiled[NSX_MAX_HANDLES];
nosave float NSX_GroupMapDKeys[NSX_MAX_HANDLES];
nosave float NSX_GroupMapDAddr[NSX_MAX_HANDLES];
nosave string NSX_Key[NSX_MAX_HANDLES];
nosave string NSX_KeyValue[NSX_MAX_HANDLES];

// begin NSX parsing, return process handle
// return < 0 if error
float NSX_Open(string tFile, float quiet)
{
	float tHandle, tFileHandle;
	
	if (substring(tFile, 0, strlen(NS_PATH)) != NS_PATH)
		tFile = strcat(NS_PATH, tFile);
	// get free handle
	for (tHandle = 0; tHandle < NSX_MAX_HANDLES; tHandle++)
		if (!NSX[tHandle])
			break;
	if (tHandle == NSX_MAX_HANDLES)
	{
		if (!quiet)
			warning(strcat("NSX_Open: ran put of free handles when opening ", tFile));
		return -1;
	}
	// open file
	tFileHandle = fopen(tFile, FILE_READ);
	// read first line
	if (tFileHandle >= 0)
		NSX_Line[tHandle] = fgets(tFileHandle);
	else
	{
		if (!quiet)
			warning(strcat("NSX_Open: cannot read ", tFile));
		NSX_Line[tHandle] = null_string;
		return -1;
	}
	// fill handle and return it
	NSX[tHandle] = 1;
	NSX_File[tHandle] = tFileHandle;
	return tHandle;
}

float NSX_GroupMapDecompile_TrimmedNamespaceLen(string tNameSpace)
{
	float tOfs, tLastOfs;
	
	tOfs = strstrofs(tNameSpace, ":", 0);
	tLastOfs = tOfs;
	while(tOfs >= 0)
	{
		tLastOfs = tOfs;
		tOfs = strstrofs(tNameSpace, ":", tOfs+1);
	}
	return tLastOfs + 1;
}

void NSX_GroupMapDecompile(float tHandle)
{
	float tBufferName, tBufferAddr, tPos, tLen, tFix, tTrim, tIndex;
	string tStr, tBrAddr, tComAddr, tNameSpace, tChar, tPoint, temp;
	
	tBufferName = buf_create();
	tBufferAddr = buf_create();
	tStr = NSX_GroupMap[tHandle]; // Vortex: test case - "{x1,x2,portals:{x3,b},f,super:{2x,3x,4x},{goal1,{subgoal1,subgoal2},goal2}}";
	// add the key
	tIndex = 0;
	tFix = strstrofs(tStr, "=", 0);
	if (tFix >= 0)
	{
		bufstr_set(tBufferName, tIndex, substring(tStr, 0, tFix));
		bufstr_set(tBufferAddr, tIndex, "*key");
		tStr = substring(tStr, tFix+1, 10000);
		tIndex++;
	}
	// add the value
	tLen = strlen(tStr);
	tFix = 0;
	for (tPos = 0; tPos < tLen; tPos++)
	{
		tChar = substring(tStr, tPos, 1);
		if (tChar == " ")
			continue;
		if (tChar == "{")
		{
			tComAddr = "";
			tBrAddr = strcat(tBrAddr, "{");
			// get point
			tPoint = substring(tStr, tFix, tPos - tFix);
			if (tPoint != "")
			{
				// modify previous
				if (tIndex > 0)
				{
					temp = bufstr_get(tBufferAddr, tIndex-1);
					bufstr_set(tBufferAddr, tIndex-1, strcat(temp, "?", tChar));
				}
				// new address
				bufstr_set(tBufferName, tIndex, strcat(tNameSpace, tPoint));
				bufstr_set(tBufferAddr, tIndex, strcat(tBrAddr, tComAddr));
				tIndex++;
			}
			// add namespace
			if (substring(tStr, tPos-1, 1) == ":") 
				tNameSpace = strcat(tNameSpace, substring(tStr, tFix, tPos - tFix));
			else if (tPos > 0)
				tNameSpace = strcat(tNameSpace, ":");
			tFix = tPos + 1;
		}
		else if (tChar == "}")
		{
			// add address point
			tPoint = substring(tStr, tFix, tPos - tFix);
			if (tPoint != "")
			{
				// modify previous
				if (tIndex > 0)
				{
					temp = bufstr_get(tBufferAddr, tIndex-1);
					bufstr_set(tBufferAddr, tIndex-1, strcat(temp, "?", tChar));
				}
				// new address
				bufstr_set(tBufferName, tIndex, strcat(tNameSpace, tPoint));
				bufstr_set(tBufferAddr, tIndex, strcat(tBrAddr, tComAddr));
				tIndex++;
			}
			// substract namespace
			tNameSpace = substring(tNameSpace, 0, strlen(tNameSpace) - 1);
			tNameSpace = substring(tNameSpace, 0, NSX_GroupMapDecompile_TrimmedNamespaceLen(tNameSpace));
			// adjust address
			tComAddr = "";
			for(tTrim = strlen(tBrAddr)-1;tTrim >= 0;tTrim--)
				if (substring(tBrAddr, tTrim, 1) != "{")
					break;
			tBrAddr = strcat(substring(tBrAddr, 0, tTrim+1), "}");
			tFix = tPos + 1;
		}
		else if (tChar == "," || tChar == ";")
		{
			// add address point
			tPoint = substring(tStr, tFix, tPos - tFix);
			if (tPoint != "")
			{
				// modify previous
				if (tIndex > 0)
				{
					temp = bufstr_get(tBufferAddr, tIndex-1);
					bufstr_set(tBufferAddr, tIndex-1, strcat(temp, "?", tChar));
				}
				// new address
				bufstr_set(tBufferName, tIndex, strcat(tNameSpace, tPoint));
				bufstr_set(tBufferAddr, tIndex, strcat(tBrAddr, tComAddr));
				tIndex++;
			}
			// adjust address
			tComAddr = strcat(tComAddr, tChar);
			tFix = tPos + 1;
		}
		else if (tChar == "&") // custom separator
		{
			tChar = substring(tStr, tPos+1, 1);
			// add address point
			tPoint = substring(tStr, tFix, tPos - tFix);
			if (tPoint != "")
			{
				// modify previous
				if (tIndex > 0)
				{
					temp = bufstr_get(tBufferAddr, tIndex-1);
					bufstr_set(tBufferAddr, tIndex-1, strcat(temp, "?", tChar));
				}
				// new address
				bufstr_set(tBufferName, tIndex, strcat(tNameSpace, tPoint));
				bufstr_set(tBufferAddr, tIndex, strcat(tBrAddr, tComAddr));
				tIndex++;
			}
			// adjust address
			tComAddr = strcat(tComAddr, tChar);
			tPos++;
			tFix = tPos + 1;
		}
	}
	// last part
	if (tFix < tPos)
	{
		// add address point
		tPoint = substring(tStr, tFix, tPos - tFix);
		if (tPoint != "")
		{
			// modify previous
			if (tIndex > 0)
			{
				temp = bufstr_get(tBufferAddr, tIndex-1);
				bufstr_set(tBufferAddr, tIndex-1, strcat(temp, "?", sright(tComAddr, 1)));
			}
			// new address
			bufstr_set(tBufferName, tIndex, strcat(tNameSpace, tPoint));
			bufstr_set(tBufferAddr, tIndex, strcat(tBrAddr, tComAddr));
			tIndex++;
		}
	}
	// mark decompiles
	NSX_GroupMapDecompiled[tHandle] = 1;
	NSX_GroupMapDKeys[tHandle] = tBufferName;
	NSX_GroupMapDAddr[tHandle] = tBufferAddr;
}

float NSX_GetGroup(float tHandle, float tDecompileMap)
{
	float tFileHandle;
	string tLine;
	
	// seek for a group
	tFileHandle = NSX_File[tHandle];
	tLine = NSX_Line[tHandle];
	while(tLine)
	{
		if (substring(tLine, 0, 1) == "[")
		{
			NSX_Group[tHandle] = strpart(tLine, "]", 1);
			if (strpart_pos < 0)
				NSX_GroupMap[tHandle] = "key=value";
			else
				NSX_GroupMap[tHandle] = substring(tLine, strpart_pos, 10000);
			// clear decompiled map
			if (NSX_GroupMapDecompiled[tHandle] == 1)
			{
				buf_del(NSX_GroupMapDKeys[tHandle]);
				buf_del(NSX_GroupMapDAddr[tHandle]);
			}
			NSX_GroupMapDecompiled[tHandle] = 0;
			NSX_GroupMapDKeys[tHandle] = -1;
			NSX_GroupMapDAddr[tHandle] = -1;
			// compile map
			if (tDecompileMap)
				NSX_GroupMapDecompile(tHandle);
			// next line
			NSX_Line[tHandle] = fgets(tFileHandle);
			return 1;
		}
		tLine = fgets(tFileHandle);
	}
	// end-of-file
	if (NSX_File[tHandle] >= 0)
		fclose(NSX_File[tHandle]);
	NSX_Line[tHandle] = null_string;
	NSX_File[tHandle] = -999;
	return 0;
}

float NSX_GetKey(float tHandle)
{
	float tFileHandle;
	string tLine, tChar;
	
	// seek for a key, if found group stop immediately
	tFileHandle = NSX_File[tHandle];
	tLine = NSX_Line[tHandle];
	while(tLine)
	{
		tChar = substring(tLine, 0, 1);
		if (tChar == "[")
		{
			// found new group!
			NSX_Line[tHandle] = tLine;
			return 0;
		}
		// skip comments
		if (tChar == "" || tChar == "#")
		{
			tLine = fgets(tFileHandle);
			continue;
		}	
		// we got a key
		NSX_Key[tHandle] = strpart(tLine, "=", 0);
		if (strpart_pos < 0)
			NSX_KeyValue[tHandle] = "";
		else
			NSX_KeyValue[tHandle] = substring(tLine, strpart_pos, 10000);
		NSX_Line[tHandle] = fgets(tFileHandle);
		return 1;
	}
	// end-of-file
	if (NSX_File[tHandle] >= 0)
		fclose(NSX_File[tHandle]);
	NSX_Line[tHandle] = null_string;
	NSX_File[tHandle] = -999;
	return 0;
}

string NSX_GetColumnAddress(float tHandle, string tColumnName)
{
	float tPos, tLen, tBufferName, tBufferAddr;
	
	if (!NSX[tHandle])
		return "";
	// decompile map if needed
	if (NSX_GroupMapDecompiled[tHandle] == 0)
		NSX_GroupMapDecompile(tHandle);
	// get address
	tBufferName = NSX_GroupMapDKeys[tHandle];
	tBufferAddr = NSX_GroupMapDAddr[tHandle];
	tLen = buf_getsize(tBufferName);
	for (tPos = 0; tPos < tLen; tPos++)
		if (bufstr_get(tBufferName, tPos) == tColumnName)
			return bufstr_get(tBufferAddr, tPos);
	return "";
}

string NSX_GetKeyColumn(float tHandle, string tAddress)
{
	float tPos, tLen, tOfs, tCommaOfs, tBrOfs, tBrcOfs;
	string tStr, tValue, tChar, tNext;

	tValue = NSX_KeyValue[tHandle];
	if (tAddress == "*key")
		return NSX_Key[tHandle];
	if (tAddress == "*value")
		return tValue;	
	// normal address
	tLen = strlen(tAddress);
	for (tOfs = 0,tPos = 0; tPos < tLen; tOfs++,tPos++)
	{
		tChar = substring(tAddress, tPos, 1);
		if (tChar == "?")
		{
			tNext = substring(tAddress, tPos+1, 1);
			tCommaOfs = strstrofs(tValue, tNext, tOfs);
			if (tCommaOfs < 0) 
				return substring(tValue, tOfs, 10000);
			return substring(tValue, tOfs, tCommaOfs - tOfs);
		}
		tOfs = strstrofs(tValue, tChar, tOfs);
	}
	if (tOfs < 0)
		return "";
	return substring(tValue, tOfs, 10000);
}

void NSX_PrintKey(float tHandle)
{
	float tBufferName, tBufferAddr, tPos, tLen;
	string tKey, tValue;
	
	// decompile map if needed
	if (NSX_GroupMapDecompiled[tHandle] == 0)
		NSX_GroupMapDecompile(tHandle);
	tBufferName = NSX_GroupMapDKeys[tHandle];
	tBufferAddr = NSX_GroupMapDAddr[tHandle];
	// print
	print(strcat("== key #", NSX_GetKeyColumn(tHandle, "*key"), " ==\n"));
	tLen = buf_getsize(tBufferName);
	for (tPos = 0; tPos < tLen; tPos++)
		print(strcat(" ", bufstr_get(tBufferName, tPos), "=", NSX_GetKeyColumn(tHandle, bufstr_get(tBufferAddr, tPos)), "\n"));
	print("\n");
}

void NSX_Close(float tHandle) =
{
	NSX[tHandle] = 0;
	// clear decompiled map
	if (NSX_GroupMapDecompiled[tHandle] == 1)
	{
		buf_del(NSX_GroupMapDKeys[tHandle]);
		buf_del(NSX_GroupMapDAddr[tHandle]);
	}
	NSX_GroupMapDecompiled[tHandle] = 0;
	NSX_GroupMapDKeys[tHandle] = -1;
	NSX_GroupMapDAddr[tHandle] = -1;
	// free file
	if (NSX_File[tHandle] >= 0)
		fclose(NSX_File[tHandle]);
	NSX_File[tHandle] = -999;
	// clear line
	NSX_Line[tHandle] = null_string;
}

// returns groups from a file as altstring
string NSX_ExtractAltString(string tFile, string tGroup, string tColumn) =
{
	string tStr;
	float tNSX;
	
	tNSX = NSX_Open(tFile, 1);
	if (tNSX >= 0) 
	{
		while(NSX_File[tNSX] >= 0) 
			if (NSX_GetGroup(tNSX, 0)) 
				if (NSX_Group[tNSX] == tGroup) 
					while(NSX_GetKey(tNSX)) 
						tStr = strcat(tStr, "'", NSX_GetKeyColumn(tNSX, NSX_GetColumnAddress(tNSX, tColumn)), "'");
		NSX_Close(tNSX);
	}
	return tStr;
}

// make defines our of nsx file
void NSX_CreateDefs(string tFile, string tGroup, float tIsWord, float tRedefine, string tNameFormat) =
{
	string tStr, tKey, tValue;
	float tNSX;
	
	tNSX = NSX_Open(tFile, 1);
	if (tNSX >= 0) 
	{
		while(NSX_File[tNSX] >= 0)
		{
			if (!NSX_GetGroup(tNSX, 0))
				break;
			if (tGroup != "" && NSX_Group[tNSX])
				continue;
			while(NSX_GetKey(tNSX))
			{
				// format name
				if (tNameFormat == "")
					tKey = NSX_GetKeyColumn(tNSX, "*key");
				else
					tKey = strreplace("%name", tKey, NSX_GetKeyColumn(tNSX, "*key"));
				// format value
				if (tIsWord)
					tValue = strcat("\"", NSX_GetKeyColumn(tNSX, "*value"), "\"");
				else
					tValue = NSX_GetKeyColumn(tNSX, "*value");
				Ns_Parser_DefineList_Add(tKey, tValue, "", 0, tRedefine);
			}
		}
		NSX_Close(tNSX);
	}
}

/*
================================================================================

  MACRO COMMANDS

  They are processed on-compile, they are common between parser and precompiler

  standart commands are:

  @true or $on - returns "1"
  @false or $off - returns "0"
  @random - returns random 0-1
  @random(x,y) - returns rancome from x-y range
  @crandom - returns c-style random, equal is $random(-1,1)
  @chance(x) - returns "1" with chance of x percents (x = 1 is 100%) else returns 0
  @defined(n) - returns true if this define exists
  @incpath(s) - transforms include path to simple path
  @file_exists(n) - returns true if file with this path exists
  @file_line(filename,linenum) - get a line out of file
  @get_token(string,pos,separator1,separator2...separator7) - get a token out of line
  @not(n) - for 0 returns 1, else returns 0
  @equal(x,y) - returns true if x == y (string-wise, so "1" will not be equal to "1.0")
  @bitand(x,y) - returns true if ((x & y) = y)
  @bitor(x,y) - returns true if ((x & y) != 0)  
  @label_list - debug, returns registered labels list
  @define_list - debug, returns registered defines list
  @cached_files - debug, returns cached files list
  @nsx_extract(file,group,column) - creates altstring
  @nsx_createdefs(file[,group,is_word,redefine,nameformat]) - create list of defines
  // todo: register all debug macros dynamically based on #pragma debugmacros on/off
================================================================================
*/

string endbrace = ")"; // FTEQCC BUG
string Ns_Parser_Precompiler_PrintLabelsStat();
string Ns_Parser_Precompiler_PrintDefinesStat();
string Ns_Parser_Precompiler_PrintCachedFilesStat();
float() Ns_Parser_ProcessMacro =
{
	string tStrParm, tStrParm1, tStrParm2, tStrParm3, tStrParm4, tStrParm5, tStrParm6, tStrParm7;
	float tDefPos, tParm1, tParm2;
	entity tDef;
	
	// profile macro command
	if (ns_parser_pmacro())
		return 1;

	// standart macro functions
	tDefPos = ns_parser_tokenpos;
	if (ns_parser_token == "@random")
	{
		if (Ns_Parser_CheckNext("(", FALSE))
		{
			Ns_Parser_ReadParm();
			tParm1 = stof(ns_parser_token);
			Ns_Parser_ReadParm();
			tParm2 = stof(ns_parser_token);
			Ns_Parser_ExpectPunctuation(endbrace);
			Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), ftos(lhrandom(tParm1, tParm2)));
		}
		else
			Ns_Parser_ReplaceTokensByString(tDefPos, 1, ftos(random()));
		return 1;
	}
	if (ns_parser_token == "@nsx_extract") // loadlist(File,Group,Column)
	{
		if (Ns_Parser_CheckNext("(", FALSE))
		{
			Ns_Parser_ReadParm();
			tStrParm = ns_parser_token;
			Ns_Parser_ReadParm();
			tStrParm2 = ns_parser_token;
			Ns_Parser_ReadParm();
			tStrParm3 = ns_parser_token;
			Ns_Parser_ExpectPunctuation(endbrace);
			Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), strcat("\"", NSX_ExtractAltString(tStrParm, tStrParm2, tStrParm3), "\""));
		}
		else
		{
			Ns_Parser_Warning("loadlist: no parms");
			Ns_Parser_ReplaceTokensByString(tDefPos, 1, "");
		}
		return 1;
	}
	if (ns_parser_token == "@nsx_createdefs") // nsx_createdefs(File[,Group,IsWord,Redefine,NameFormat])
	{
		Ns_Parser_ExpectPunctuation("(");
		Ns_Parser_ReadParm();
		tStrParm = strcat(NS_PATH, Ns_Parser_FS_FileRealPath(ns_parser_token));
		tStrParm1 = "";
		tParm1 = 0;
		tParm2 = 1;
		tStrParm2 = "";
		Ns_Parser_ReadParm();
		if (ns_parser_token != endbrace)
		{
			tStrParm1 = ns_parser_token;
			Ns_Parser_ReadParm();
			if (ns_parser_token != endbrace)
			{
				tParm1 = stof(ns_parser_token);
				Ns_Parser_ReadParm();
				if (ns_parser_token != endbrace)
				{
					tParm2 = stof(ns_parser_token);
					Ns_Parser_ReadParm();
					if (ns_parser_token != endbrace)
					{
						tStrParm2 = ns_parser_token;
						Ns_Parser_ExpectPunctuation(endbrace);
					}
				}
			}
		}
		NSX_CreateDefs(tStrParm, tStrParm1, tParm1, tParm2, tStrParm2);
		Ns_Parser_RestoreTokens();
		return 1;
	}
	if (ns_parser_token == "@crandom")
	{
		Ns_Parser_ReplaceTokensByString(tDefPos, 1, ftos(crandom()));
		return 1;
	}
	if (ns_parser_token == "@chance")
	{
		Ns_Parser_ExpectPunctuation("(");
		Ns_Parser_ReadParm();
		tParm1 = stof(ns_parser_token);
		Ns_Parser_ExpectPunctuation(endbrace);
		Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), ftos(random() > tParm1));
		return 1;
	}
	if (ns_parser_token == "@defined")
	{
		Ns_Parser_ExpectPunctuation("(");
		Ns_Parser_ReadParm();
		tStrParm = ns_parser_token;
		Ns_Parser_ExpectPunctuation(endbrace);
		
		if (Ns_Parser_DefineList_Find(tStrParm, 0))
			Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), "1");
		else
			Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), "0");
		return 1;
	}
	if (ns_parser_token == "@incpath")
	{
		Ns_Parser_ExpectPunctuation("(");
		Ns_Parser_ReadParm();
		tStrParm = strcat(NS_PATH, Ns_Parser_FS_FileRealPath(ns_parser_token));
		Ns_Parser_ExpectPunctuation(endbrace);
		
		Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), tStrParm);
		return 1;
	}
	if (ns_parser_token == "@file_exists")
	{
		Ns_Parser_ExpectPunctuation("(");
		Ns_Parser_ReadParm();
		tStrParm = ns_parser_token;
		Ns_Parser_ExpectPunctuation(endbrace);
		if (file_exist(tStrParm))
			Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), "1");
		else
			Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), "0");
		return 1;
	}
	if (ns_parser_token == "@file_line")
	{
		Ns_Parser_ExpectPunctuation("(");
		Ns_Parser_ReadParm();
		tStrParm = ns_parser_token;
		Ns_Parser_ReadParm();
		tParm1 = stof(ns_parser_token);
		Ns_Parser_ExpectPunctuation(endbrace);
		// open file
		tParm2 = fopen(tStrParm, FILE_READ);
		if (tParm2 < 0)
		{
			Ns_Parser_Warning(strcat("file_line: cannot open file '", tStrParm, "'"));
			tStrParm = "";
		}
		else
		{
			while(tParm1 > 0)
			{
				tStrParm = fgets(tParm2);
				tParm1--;
			}
			fclose(tParm2);
		}
		Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), tStrParm);
		return 1;
	}
	if (ns_parser_token == "@get_token")
	{
		Ns_Parser_ExpectPunctuation("(");
		Ns_Parser_ReadParm();
		tStrParm = ns_parser_token;
		Ns_Parser_ReadParm();
		tParm1 = stof(ns_parser_token);
		// read separators
		tParm2 = 0;
		while(Ns_Parser_ReadParm())
		{
			if (ns_parser_token == endbrace)
				break;
			// too many?
			if (tParm2 > 6)
			{
				Ns_Parser_Warning("token: too many separators (max 7)");
				continue;
			}
			// get separator
			if (tParm2 == 0)
				tStrParm1 = ns_parser_token;
			else if (tParm2 == 1)
				tStrParm2 = ns_parser_token;	
			else if (tParm2 == 2)
				tStrParm3 = ns_parser_token;
			else if (tParm2 == 3)
				tStrParm4 = ns_parser_token;				
			else if (tParm2 == 4)
				tStrParm5 = ns_parser_token;				
			else if (tParm2 == 5)
				tStrParm6 = ns_parser_token;		
			else
				tStrParm7 = ns_parser_token;
			tParm2++;
		}
		// do tokenize
		if (tParm2 == 0)
			tParm2 = tokenize(tStrParm);
		else
			tParm2 = tokenizebyseparator(tStrParm, tStrParm1, tStrParm2, tStrParm3, tStrParm4, tStrParm5, tStrParm6, tStrParm7);
		tStrParm = argv(tParm1);
		Ns_Parser_RestoreTokens();
		Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), tStrParm);
		return 1;
	}
	if (ns_parser_token == "@not")
	{
		Ns_Parser_ExpectPunctuation("(");
		Ns_Parser_ReadParm();
		tStrParm = ns_parser_token;
		Ns_Parser_ExpectPunctuation(endbrace);
		
		if (stof(tStrParm))
			Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), "0");
		else
			Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), "1");
		return 1;
	}
	if (ns_parser_token == "@equal")
	{
		Ns_Parser_ExpectPunctuation("(");
		Ns_Parser_ReadParm();
		tStrParm = ns_parser_token;
		Ns_Parser_ReadParm();
		tStrParm2 = ns_parser_token;
		Ns_Parser_ExpectPunctuation(endbrace);
		if (tStrParm == tStrParm2)
			Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), "1");
		else
			Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), "0");
		return 1;
	}
	if (ns_parser_token == "@bitand")
	{
		Ns_Parser_ExpectPunctuation("(");
		Ns_Parser_ReadParm();
		tParm1 = stof(ns_parser_token);
		Ns_Parser_ReadParm();
		tParm2 = stof(ns_parser_token);
		Ns_Parser_ExpectPunctuation(endbrace);
		if ((tParm1 & tParm2) == tParm2)
			Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), "1");
		else
			Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), "0");
		return 1;
	}
	if (ns_parser_token == "@bitor")
	{
		Ns_Parser_ExpectPunctuation("(");
		Ns_Parser_ReadParm();
		tParm1 = stof(ns_parser_token);
		Ns_Parser_ReadParm();
		tParm2 = stof(ns_parser_token);
		Ns_Parser_ExpectPunctuation(endbrace);
		if (tParm1 & tParm2)
			Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), "1");
		else
			Ns_Parser_ReplaceTokensByString(tDefPos, (ns_parser_tokenpos - tDefPos + 1), "0");
		return 1;
	}
	if (ns_parser_token == "@label_list")
	{
		Ns_Parser_ReplaceTokensByString(tDefPos, 1, Ns_Parser_Precompiler_PrintLabelsStat());
		return 1;
	}
	if (ns_parser_token == "@define_list")
	{
		Ns_Parser_ReplaceTokensByString(tDefPos, 1, Ns_Parser_Precompiler_PrintDefinesStat());
		return 1;
	}
	if (ns_parser_token == "@cached_files")
	{
		Ns_Parser_ReplaceTokensByString(tDefPos, 1, Ns_Parser_Precompiler_PrintCachedFilesStat());
		return 1;
	}
	if (ns_parser_token == "@checkextension")
	{	
		Ns_Parser_ReadParm();
		if (!cvar("pr_checkextension"))
			Ns_Parser_ReplaceTokensByString(tDefPos, 1, "0");
		else
			Ns_Parser_ReplaceTokensByString(tDefPos, 1, ftos(checkextension(ns_parser_token)));
		return 1;	
	}
	// #define'd macrofunction
	tDef = Ns_Parser_DefineList_Find(substring(ns_parser_token, 1, 10000), 1);
	if (tDef)
		return Ns_Parser_ProcessDefine(tDef);
	// bad macrofunction
	Ns_Parser_Warning(strcat("Unknown macro function '", ns_parser_token, "'"));
	return 1;
}

/*
================================================================================

 PRECOMPILER

 NOTE: precompiler commands begins with #

 Comands list:
  #include "filename" - include file to parse process
	use ./filename to include file from same directory as current script
	<filename> will include file from script/system/ directory
	note: any included files must be in script/ directory
  #define <defname>(parms) <rest_of_line> - creates define
  #redef <defname>(parms) - create new or redefine previous macro
  #undef - delete define
  #undefall - delete all defines except system ones
  #const <defname>(parms) <rest_of_line> - similar to define but have much restricted 
					use since it makes one big token off rest of line
					it is fast however, useful for constants
	in the <rest_of_line> parms must be prefixed by %, to include token-strings use postfix %
	[DefineOrName(parms)] - use this to insert define into string
  #message <rest_of_line> - stuffs notice (visible with #pragma warnings extended)
  #error <rest_of_line> - stuffs error (always visible)
  #warning <rest_of_line> - stuffs warning (visible with #pragma warnings on)
  #pragma [parm]
	parms:
		precompiler on/off - enables/disables precompiler, if disabled - compiler will cast error on any precompiler usage it found (only #pragma precompiler stays not forbidden, so it can be enabled again) 
		warnings 0 - warnings off
		warnings 1 - warnings on
		warnings 2 - warnings extended
		warnings 3 - warnings debug
		debug 0/1 - forces warnings to maximal level, dumps assembler, enables writing NewLine (\n\r) symbol in the end of each compiled command and adds some extra #-commands
		debugmessages on/off - each #debug will be printed as message
		labels_on_failed_ifs on/off - enables/disables label registering when skipping failed #if statements (this enables #goto to #labels that was be on faileds #if's)
									  in other words - #labels being registered even #if statement is considered skipped
  #debug <rest_of_line> - outputs '// message' directly to compilation, only available in debugmode (take care with this: it may break compilation since compilation size is limited to 4096)
  #if [parm] ... #elseif [parm] ... #else ... #endif
  #goto [labename] - go to named #label (up and down transitions are supported)
  #label [labelname] - place a label
  #eof
  #skip X words
  #skip X lines
================================================================================
*/

void() Ns_Parser_Precompiler_Pragma =
{
	Ns_Parser_ReadParm();
	if (ns_parser_token == "precompiler")
	{
		Ns_Parser_ReadParm();
		if (stof(ns_parser_token))
			ns_parser_precompiler_pragma = ns_parser_precompiler_pragma | NS_PRAGMA_FORBID_PRECOMPILER;
		else
			ns_parser_precompiler_pragma = ns_parser_precompiler_pragma - (ns_parser_precompiler_pragma & NS_PRAGMA_FORBID_PRECOMPILER);
		return;
	}
	// cast error on NS_PRAGMA_FORBID_PRECOMPILER, 
	// only #pragma precompiler will work
	if (ns_parser_precompiler_pragma & NS_PRAGMA_FORBID_PRECOMPILER)
	{
		Ns_Parser_Error("Forbidden precompiler usage");
		return;
	}
	if (ns_parser_token == "warnings")
	{
		Ns_Parser_ReadParm();
		ns_parser_warnings = stof(ns_parser_token);
		return;
	}
	if (ns_parser_token == "debug")
	{
		Ns_Parser_ReadParm();
		if (stof(ns_parser_token))
			ns_parser_precompiler_pragma = ns_parser_precompiler_pragma | NS_PRAGMA_DEBUGMODE;
		else
			ns_parser_precompiler_pragma = ns_parser_precompiler_pragma - (ns_parser_precompiler_pragma & NS_PRAGMA_DEBUGMODE);
		return;
	}
	if (ns_parser_token == "debugmessages")
	{
		Ns_Parser_ReadParm();
		if (stof(ns_parser_token))
			ns_parser_precompiler_pragma = ns_parser_precompiler_pragma | NS_PRAGMA_DEBUGMODE_MESSAGES;
		else
			ns_parser_precompiler_pragma = ns_parser_precompiler_pragma - (ns_parser_precompiler_pragma & NS_PRAGMA_DEBUGMODE_MESSAGES);
		return;
	}
	if (ns_parser_token == "labels_on_failed_ifs")
	{
		Ns_Parser_ReadParm();
		if (stof(ns_parser_token))
			ns_parser_precompiler_pragma = ns_parser_precompiler_pragma | NS_PRAGMA_LABELS_ON_FAILED_IFS;
		else
			ns_parser_precompiler_pragma = ns_parser_precompiler_pragma - (ns_parser_precompiler_pragma & NS_PRAGMA_LABELS_ON_FAILED_IFS);
		return;
	}
}

float() Ns_Parser_Precompiler_CheckIf =
{
	string tStr1, tStr2;
	
	// #ifdef
	if (ns_parser_token == "#ifdef")
	{
		Ns_Parser_ReadParm();
		if (Ns_Parser_DefineList_Find(ns_parser_token, 0))
			return TRUE;
		return FALSE;
	}
	// normal #if
	Ns_Parser_ReadParm();
	if (stof(ns_parser_token))
		return TRUE;
	return FALSE;
}

void() Ns_Parser_Precompiler_Include =
{
	Ns_Parser_ReadParm();
	if (ns_parser_token == "")
		return;
	Ns_Parser_FS_AddFileToStack(Ns_Parser_FS_FileRealPath(ns_parser_token));
}

void() Ns_Parser_Precompiler_Cache =
{
	string tFilePath;
	float tBuf;
	
	Ns_Parser_ReadParm();
	if (ns_parser_token == "")
		return;
	tFilePath = Ns_Parser_FS_FileRealPath(tFilePath);
	tBuf = Ns_Parser_FS_CacheFile(tFilePath);
	Ns_Parser_FS_RegisterCachedFile(tBuf, tFilePath, 1);
}

void() Ns_Parser_Precompiler_EOF =
{
	// cast warning if there is not closed #if's
	if (ns_parser_precompiler_if_depth)
		Ns_Parser_Warning("Some #if's are not propertly closed");
	// stop the parsing
	ns_parser_errorcode = NS_PARSER_ERROR_EOF;
}

void() Ns_Parser_Precompiler_SkipIfStatementGetToken =
{
	if (ns_parser_tokenpos >= ns_parser_line_numtokens) 
		if (Ns_Parser_NextLine(FALSE) == FALSE)
			return;
	ns_parser_token = argv(ns_parser_tokenpos);
	ns_parser_tokenpos++;
}

entity Ns_Parser_Precompiler_Label();
void Ns_Parser_Precompiler_SkipIfStatement(float tAllowElse) =
{
	float tLocalIfDepth;

	while(ns_parser_errorcode == NS_PARSER_ERROR_NO)
	{
		Ns_Parser_Precompiler_SkipIfStatementGetToken();
		if (ns_parser_token == "#if" || ns_parser_token == "#ifdef") // nested #if
			tLocalIfDepth++;
		else if (ns_parser_token == "#endif")
		{
			// stop skipping if it is not nested #if
			if (!tLocalIfDepth)
				break;
			tLocalIfDepth--;
		}
		else if (ns_parser_token == "#else" || ns_parser_token == "#elseif")
		{
			if (!tLocalIfDepth)
				break;
		}
		else if (ns_parser_token == "#eof")
		{
			if (!tLocalIfDepth)
			{
				Ns_Parser_Precompiler_EOF();
				break;
			}
		}
		else if (ns_parser_token == "#label")
		{
			// feature of labels being registered even on failed #if statements
			if ((ns_parser_precompiler_pragma & NS_PRAGMA_LABELS_ON_FAILED_IFS))
				Ns_Parser_Precompiler_Label();
		}	
	}
	// go back one pos, so our end token will be parsed in main loop
	ns_parser_tokenpos--;
}

void() Ns_Parser_Precompiler_If =
{
	float ifresult;
	
	ns_parser_precompiler_if_depth++;
	// cast error on ifdepth overflow
	if (ns_parser_precompiler_if_depth > NS_PARSER_MAX_IF_DEPTH)
	{
		Ns_Parser_Error(strcat("Too many nested #if's, max is ", ftos(NS_PARSER_MAX_IF_DEPTH)));
		return;
	}
	if (Ns_Parser_Precompiler_CheckIf())
		ns_parser_precompiler_if_results = ns_parser_precompiler_if_results | pow(2, ns_parser_precompiler_if_depth);
	else
	{
		ns_parser_precompiler_if_results = ns_parser_precompiler_if_results - (ns_parser_precompiler_if_results & pow(2, ns_parser_precompiler_if_depth));
		Ns_Parser_Precompiler_SkipIfStatement(1); // skip all until next #endif, #else, #elseif
	}
}

void() Ns_Parser_Precompiler_If_EndIf =
{
	// cast warning error endif without if
	if (ns_parser_precompiler_if_depth == 0)
	{
		Ns_Parser_Warning("#endif without starting #if");
		return;
	}
	ns_parser_precompiler_if_depth--;
}

void() Ns_Parser_Precompiler_If_Else =
{
	// check if current if_depth has right solution 
	// and if so skip all until next #endif
	if (ns_parser_precompiler_if_results & pow(2, ns_parser_precompiler_if_depth))
		Ns_Parser_Precompiler_SkipIfStatement(FALSE);
}

void() Ns_Parser_Precompiler_If_ElseIf =
{
	// --- check if current if_depth already has right solution 
	// and if so skip this statement ---
	if (ns_parser_precompiler_if_results & pow(2, ns_parser_precompiler_if_depth))
	{
		Ns_Parser_Precompiler_SkipIfStatement(FALSE);
		return;
	}
	Ns_Parser_Precompiler_If();
}

void() Ns_Parser_Precompiler_Skip =
{
	float tCount;
	string tStr;

	if (!Ns_Parser_ReadParm())
		return;
	tCount = stof(ns_parser_token);
	Ns_Parser_ReadParm();
	ns_parser_precompiler--;
	if (ns_parser_token == "words")
	{
		for ( ; tCount > 0; --tCount)
			Ns_Parser_ReadToken();
	}
	else if (ns_parser_token == "lines")
	{
		for ( ; tCount >= 0; --tCount)
			Ns_Parser_NextLine(TRUE);
	}
	else
		Ns_Parser_Warning(strcat("Unknown argument '", ns_parser_token, "' for #skip"));
	ns_parser_precompiler++;
}

// returns label index
float Ns_Parser_CheckNext(string tStr, float tAllowLineBreak);
entity() Ns_Parser_Precompiler_Label =
{
	string tLabelName;
	entity tLabel;

	if (!Ns_Parser_ReadParm())
		return null_entity;

	// check if this label is already registered
	tLabel = Ns_Parser_LabelsList_Find(ns_parser_token);
	if (tLabel)
	{
		// same named label is registered
		// check if this label are placed in same line as registered
		// VorteX: this check is needed because some code parts could call label registering twice
		if (tLabel.def_flags != ns_parser_line)
		{
			// cast error cause we are found duplicate named label
			Ns_Parser_Error("Duplicate #label definition");
			return tLabel;
		}
	}
	// register label
	tLabel = Ns_Parser_LabelsList_Add(ns_parser_token, ns_parser_line);
	if (Ns_Parser_CheckNext("maxhits", TRUE))
	{
		Ns_Parser_ReadParm();
		tLabel.def_hits = bound(2, stof(ns_parser_token), NS_PARSER_MAX_LABEL_HITS) - 1; // -1 because we hit label on registering it
	}
	return tLabel;
}

string() Ns_Parser_Precompiler_PrintLabelsStat =
{
	string tString, tStr2, tStr3;
	entity tLabel;

	tString = "";
	for (tLabel = ns_parser_labelslist; tLabel; tLabel = tLabel.next)
	{
		tStr2 = ftos(tLabel.def_flags);
		tStr3 = ftos(tLabel.def_hits);
		tString = strcat(tString, tLabel.def_name, " (line ", tStr2, ") : ", tStr3, " hits");
	}

	return tString;
}

void Ns_Parser_Precompiler_Goto_f(float tCurrentLine, string tLabelName) =
{
	float tPos, tLabelLine, tGotoLine;
	string tStr;
	entity tLabel;

	tGotoLine = tCurrentLine;
	tLabel = Ns_Parser_LabelsList_Find(tLabelName);
	if (tLabel)
	{
		// label found, check if it has hits still
		if (tLabel.def_hits <= 0)
			return; // label hits are expired, just exit
		tLabelLine = tLabel.def_flags;
		if (tGotoLine < tLabelLine)
			Ns_Parser_SkipLines(tLabelLine - tGotoLine); 	// go down
		else 
			Ns_Parser_FS_ReopenFile(tLabelLine); 			// go up
	}
	else
	{
		// go next until hit label
		ns_parser_precompiler--;
		while(ns_parser_errorcode == NS_PARSER_ERROR_NO)
		{
			Ns_Parser_NextLine(TRUE);
			Ns_Parser_ReadToken();
			if (ns_parser_token == "#label")
			{
				Ns_Parser_ReadParm();
				if (ns_parser_token == tLabelName)
					break; // found label
			}
		}
		ns_parser_precompiler++;
		// cast message if not found
		if (ns_parser_errorcode != NS_PARSER_ERROR_NO)
		{
			Ns_Parser_Error(strcat("#goto on line ", ftos(tGotoLine), " failed because #label ", tLabelName, " not found"));
			return;
		}
		// register label
		ns_parser_tokenpos = 1;
		tLabel = Ns_Parser_Precompiler_Label();
	}
	// adjust label hit count
	tLabel.def_hits = tLabel.def_hits - 1;
}

void() Ns_Parser_Precompiler_Goto =
{
	if (!Ns_Parser_ReadParm())
		return;
	Ns_Parser_Precompiler_Goto_f(ns_parser_line, ns_parser_token);
}

// parses #define 
void Ns_Parser_Precompiler_Define(float tIsWord, float tIsMacro, float tRedefine)
{
	string tDefName;
	string tDefValue;
	float tNumDefParts, tFastDef, tParmCount, tParseParms, tDefFlags;
	string tDefParms;

	if (!Ns_Parser_ReadParm())
	{
		Ns_Parser_NextLine(1);
		return;
	}
	
	// words are expanded on definition
	if (!tIsWord)
		ns_parser_precompiler--;
	tDefName = ns_parser_token;
	// parms
	if (Ns_Parser_CheckNext("(", 0))
	{
		tParmCount = 0;
		tParseParms = TRUE;
		tDefParms = clump_create(NS_DEFINE_MAX_PARM_NAME_LENGTH);
		// get parms
		while (ns_parser_errorcode == NS_PARSER_ERROR_NO)
		{
			if (tParmCount >= NS_DEFINE_MAX_PARMS)
			{
				if (tParseParms)
				{
					Ns_Parser_Warning(strcat("Too many define parms, max is ", ftos(NS_DEFINE_MAX_PARMS)));
					tParseParms = 0;
				}
			}
			Ns_Parser_ReadParm();
			if (ns_parser_token == endbrace)
				break;
			// --- add to parm string ---
			if (tParseParms)
			{
				tDefParms = clump_addquick(tDefParms, NS_DEFINE_MAX_PARM_NAME_LENGTH, strcat("%", ns_parser_token));
				tParmCount++;
			}
		}
	}
	// get content
	tDefValue = Ns_Parser_GetRestOfLine(tIsWord);
	// create def
	if (tIsMacro)
		tDefFlags = NS_PARSER_DEFINEFLAG_MACRO;
	else
		tDefFlags = 0;
	if (tIsWord)
		Ns_Parser_DefineList_Add(tDefName, strcat("\"", tDefValue, "\""), tDefParms, tDefFlags, tRedefine);
	else
		Ns_Parser_DefineList_Add(tDefName, tDefValue, tDefParms, tDefFlags, tRedefine);
	if (!tIsWord)
		ns_parser_precompiler++;
}

// enumeration
float Ns_Parser_Expect(string tStr, float tAllowLineBreak);
void() Ns_Parser_Precompiler_Enumeration =
{
	float tEnumerationType; // 0 is integer, 1 is flags
	float tEnumerationStep;
	float tEnumerationPos;
	string tTokenName;
	float tPos;
	string tEndBrace; // FTEQCC bug with fucntion(")");
	tEndBrace = ")";

	Ns_Parser_ReadToken();
	// -set enumeration type
	tEnumerationType = 0;
	tEnumerationStep = 1;
	if (ns_parser_token != "{")
	{
		if (ns_parser_token == "int")
			tEnumerationType = 0;
		else if (ns_parser_token == "flags")
			tEnumerationType = 1;
		else
			Ns_Parser_Warning(strcat("Unknown enumeration type '", ns_parser_token, "'"));
		if (Ns_Parser_CheckNext("(", FALSE))
		{
			Ns_Parser_ReadParm();
			tEnumerationStep = stof(ns_parser_token);
			Ns_Parser_ExpectPunctuation(tEndBrace);
			if (ns_parser_errorcode != NS_PARSER_ERROR_NO)
				return;
		}
	}
	// begin enumeration
	Ns_Parser_ExpectPunctuation("{");
	if (ns_parser_errorcode != NS_PARSER_ERROR_NO)
		return;
	if (tEnumerationType == 0)
	{
		tEnumerationPos = 0;
		while(ns_parser_errorcode == NS_PARSER_ERROR_NO)
		{
			Ns_Parser_ReadToken();
			if (ns_parser_token == "}")
				break;
			tTokenName = ns_parser_token;
			if (Ns_Parser_CheckNext("=", FALSE))
			{
				Ns_Parser_ReadToken();
				tEnumerationPos = stof(ns_parser_token);
			}
			Ns_Parser_DefineList_Add(tTokenName, ftos(tEnumerationPos), null_string, 0, 1);
			tEnumerationPos = tEnumerationPos + tEnumerationStep;
		}
	}
	else if (tEnumerationType == 1)
	{
		tEnumerationPos = 1;
		while(ns_parser_errorcode == NS_PARSER_ERROR_NO)
		{
			Ns_Parser_ReadToken();
			if (ns_parser_token == "}")
				break;
			tTokenName = ns_parser_token;
			if (Ns_Parser_CheckNext("=", FALSE))
			{
				Ns_Parser_ReadToken();
				tEnumerationPos = stof(ns_parser_token);
			}
			Ns_Parser_DefineList_Add(tTokenName, ftos(tEnumerationPos), null_string, 0, 1);
			for (tPos = 0; tPos < tEnumerationStep; tPos++)
				tEnumerationPos = tEnumerationPos*2;
		}
	}
}

// parses #undef
void() Ns_Parser_Precompiler_Undef =
{
	entity tDef;
	
	// get def name
	if (!Ns_Parser_ReadParm())
	{
		Ns_Parser_NextLine(1);
		return;
	}
	// erase def
	tDef = Ns_Parser_DefineList_Find(ns_parser_token, 0);
	if (tDef)
		Ns_Parser_DefineList_Remove(tDef, 1);
}

// parses #undefall
void() Ns_Parser_Precompiler_UndefAll =
{
	Ns_Parser_DefineList_Clear(0);
}

// prints current defines
string() Ns_Parser_Precompiler_PrintDefinesStat =
{
	entity tDef;
	string tString;

	for (tDef = ns_parser_definelist; tDef; tDef = tDef.next)
	{
		if (tDef.def_flags & NS_PARSER_DEFINEFLAG_MACRO)
		{
			if (tDef.def_flags & NS_PARSER_DEFINEFLAG_SYSTEM)
				tString = strcat(tString, " system macro: ", tDef.def_name, " = ", tDef.def_value, "\n");
			else
				tString = strcat(tString, " macro: ", tDef.def_name, " = ", tDef.def_value, "\n");
		}
		else
		{
			if (tDef.def_flags & NS_PARSER_DEFINEFLAG_SYSTEM)
				tString = strcat(tString, " system def: ", tDef.def_name, " = ", tDef.def_value, "\n");
			else
				tString = strcat(tString, " def: ", tDef.def_name, " = ", tDef.def_value, "\n");
		}
	}

	return tString;
}

// print define contents
void() Ns_Parser_Precompiler_PrintDef =
{
	entity tDef;
	
	if (!Ns_Parser_ReadParm())
	{
		print("printdef: no name specified\n");
		Ns_Parser_NextLine(1);
		return;
	}
	tDef = Ns_Parser_DefineList_Find(ns_parser_token, 0);
	if (!tDef)
	{
		print(strcat("printdef: '", ns_parser_token, "' not found\n"));
		Ns_Parser_NextLine(1);
		return;
	}
	print(strcat("printdef: printing '", tDef.def_name, "'\n"));
	print(strcat(" parameters: ", tDef.def_parms, "\n"));
	print(strcat(" pattern: ", tDef.def_value, "\n"));
}

// print macro contents
void() Ns_Parser_Precompiler_PrintMacro =
{
	entity tDef;
	
	if (!Ns_Parser_ReadParm())
	{
		print("printmacro: no name specified\n");
		Ns_Parser_NextLine(1);
		return;
	}
	tDef = Ns_Parser_DefineList_Find(ns_parser_token, 1);
	if (!tDef)
	{
		print(strcat("printmacro: '", ns_parser_token, "' not found\n"));
		Ns_Parser_NextLine(1);
		return;
	}
	print(strcat("printmacro: printing '", tDef.def_name, "'\n"));
	print(strcat(" parameters: ", tDef.def_parms, "\n"));
	print(strcat(" pattern: ", tDef.def_value, "\n"));
}

// print list of cached files
string() Ns_Parser_Precompiler_PrintCachedFilesStat =
{
	float tPos, tBuf;
	string tStr;
	
	if (ns_cached_files < 0)
		return "no cached files";
	for (tPos = 0; tPos < ns_cached_files; tPos++)
	{
		tStr = strcat("  #", bufstr_get(ns_cached_hbuf, tPos), " ", bufstr_get(ns_cached_nbuf, tPos));
		if (stof(bufstr_get(ns_cached_rbuf, tPos)))
			tStr = strcat(tStr, " - temp");
		tStr = strcat(tStr, "\n");
	}
	return tStr;
}

// runs precompiler functionality
void() Ns_Parser_Precompiler =
{
	float tPos;
	string tDefName;

	if (ns_parser_token == "#pragma")	
	{ 
		Ns_Parser_Precompiler_Pragma(); 
		return; 
	}
	// cast error on NS_PRAGMA_FORBID_PRECOMPILER, 
	// only #pragma precompiler will work
	if (ns_parser_precompiler_pragma & NS_PRAGMA_FORBID_PRECOMPILER)
	{
		Ns_Parser_Error("Forbidden precompiler usage");
		return;
	}
	// profile precompiler
	if (ns_parser_pprecompiler())
		return;
	// standart precompiler
	if (ns_parser_token == "#include")	{ Ns_Parser_Precompiler_Include(); return; }
	if (ns_parser_token == "#cache")	{ Ns_Parser_Precompiler_Cache(); return; }
	if (ns_parser_token == "#define" || ns_parser_token == "#def")	{ Ns_Parser_Precompiler_Define(FALSE, FALSE, 0); return; }
	if (ns_parser_token == "#defword" || ns_parser_token == "#const")	{ Ns_Parser_Precompiler_Define(TRUE, FALSE, 0); return; }
	if (ns_parser_token == "#redef")	{ Ns_Parser_Precompiler_Define(FALSE, FALSE, 2); return; } 
	if (ns_parser_token == "#redefword")	{ Ns_Parser_Precompiler_Define(TRUE, FALSE, 2); return; }
	if (ns_parser_token == "#macro")	{ Ns_Parser_Precompiler_Define(FALSE, TRUE, 0); return; }
	if (ns_parser_token == "#macroword" || ns_parser_token == "#constmacro"){ Ns_Parser_Precompiler_Define(TRUE, TRUE, 0); return; }
	if (ns_parser_token == "#enum")		{ Ns_Parser_Precompiler_Enumeration(); return; }
	if (ns_parser_token == "#undef")	{ Ns_Parser_Precompiler_Undef(); return; }
	if (ns_parser_token == "#undefall")	{ Ns_Parser_Precompiler_UndefAll(); return; }
	if (substring(ns_parser_token, 0, 3) == "#if") { Ns_Parser_Precompiler_If(); return; }
	if (ns_parser_token == "#endif")	{ Ns_Parser_Precompiler_If_EndIf(); return; }
	if (ns_parser_token == "#else")		{ Ns_Parser_Precompiler_If_Else(); return; }
	if (ns_parser_token == "#elseif")	{ Ns_Parser_Precompiler_If_ElseIf(); return; }
	if (ns_parser_token == "#label")	{ Ns_Parser_Precompiler_Label(); return; }
	if (ns_parser_token == "#skip")		{ Ns_Parser_Precompiler_Skip(); return; }
	if (ns_parser_token == "#goto")		{ Ns_Parser_Precompiler_Goto(); return; }
	if (ns_parser_token == "#message")	{ Ns_Parser_Message(NS_MSG_MESSAGE, Ns_Parser_GetRestOfLine(1)); return; }
	if (ns_parser_token == "#warning")	{ Ns_Parser_Warning(Ns_Parser_GetRestOfLine(1)); return; }
	if (ns_parser_token == "#print")	{ print(Ns_Parser_GetRestOfLine(1)); print("\n"); return; }
	if (ns_parser_token == "#error")	{ Ns_Parser_Error(Ns_Parser_GetRestOfLine(FALSE)); return; }
	if (ns_parser_token == "#eof")		{ Ns_Parser_Precompiler_EOF(); return; }
	if (ns_parser_token == "#printdef"){ Ns_Parser_Precompiler_PrintDef(); return; }
	if (ns_parser_token == "#printmacro"){Ns_Parser_Precompiler_PrintMacro(); return; }
	if (ns_parser_token == "#debug")	
	{ 
		Ns_Parser_ReadParm();
		if ((ns_parser_precompiler_pragma & NS_PRAGMA_DEBUGMODE)) // only in debug mode
		{
			if ((ns_parser_precompiler_pragma & NS_PRAGMA_DEBUGMODE_MESSAGES))
				Ns_Parser_Message(NS_MSG_LOG, strcat("#debug: ", ns_parser_token));
		}
		return;
	}
}

/*
===================================================

 PARSE GENERAL

===================================================
*/

void Ns_Parser_Begin(void() tProfileSetup, string tScriptFile, float tPragma)
{
	string tRealFilename, tVal, tDef;
	float tStrPos, tStrPos2, tStrPos3, tDefPos;
	
	Ns_Parser_Message(NS_MSG_LOG, strcat("Parsing ", tScriptFile, "..."));
	
	Ns_Parser_FS_Init();
	ns_parser_errorcode = NS_PARSER_ERROR_NO;
	ns_parser_warnings = 0;
	ns_parser_precompiler = 1;
	ns_parser_precompiler_pragma = tPragma;
	ns_parser_precompiler_if_depth = 0;
	ns_parser_precompiler_if_results = 0;
	ns_parser_pparse = null_function;
	ns_parser_pprecompiler = falsef;
	ns_parser_pmacro = falsef;
	ns_parser_pshutdown = null_function;
	tProfileSetup();
	
	// add real filename and process embedded #-definitions
	tRealFilename = tScriptFile;
	tStrPos = strstrofs(tScriptFile, "#", 0);
	if (tStrPos > 0) // found any definitions
	{
		tRealFilename = substring(tScriptFile, 0, tStrPos);
		// register defines
		//print("--- registerDefines ---\n");
		tDefPos = tStrPos + 1;
		while(tDefPos > 0)
		{
			// check if it is 'define=value' or just 'define'
			tStrPos2 = strstrofs(tScriptFile, "=", tDefPos);
			tStrPos3 = strstrofs(tScriptFile, "#", tDefPos);
			tStrPos = tDefPos;
			tDefPos = tStrPos3 + 1;
			if (tStrPos3 < 0)
				tStrPos3 = strlen(tScriptFile);
			if (tStrPos2 < 0 || tStrPos3 < tStrPos2)
			{
				tDef = substring(tScriptFile, tStrPos, tStrPos3 - tStrPos);
				tVal = "";
			}
			else
			{
				tDef = substring(tScriptFile, tStrPos, tStrPos2 - tStrPos);
				tVal = substring(tScriptFile, tStrPos2+1, tStrPos3 - tStrPos2 - 1);
			}
			//print(tDef, " = ", tVal, "\n");
			Ns_Parser_DefineList_Add(tDef, tVal, "", NS_PARSER_DEFINEFLAG_SYSTEM, 0);
		}
		//print("--- end ---\n");
	}
	Ns_Parser_FS_AddFileToStack(Ns_Parser_FS_FileRealPath(tRealFilename));
	
	// compilation loop
	while(ns_parser_errorcode == NS_PARSER_ERROR_NO) 
	{ 
		Ns_Parser_ReadToken(); 
		if (ns_parser_errorcode != NS_PARSER_ERROR_NO)
			break;
		ns_parser_pparse();
	}		
	
	// shutdown
	ns_parser_pshutdown();
	Ns_Parser_DefineList_Clear(1); 
	Ns_Parser_LabelsList_Clear();
	Ns_Parser_FS_Shutdown();	
}

/*
===================================================

 API

===================================================
*/

// just parser file and returns if no errors found
// useful for config files which does not do any dynamic script work
float Ns_ParseFile(string tScriptFile, void() tProfile, float tPragma)
{
	Ns_Parser_Begin(tProfile, tScriptFile, tPragma);
	return (ns_parser_errorcode == NS_PARSER_ERROR_EOF);
}

// loads file into buffer and returns buffer index
float Ns_CacheFile(string tScriptFile)
{
	tScriptFile = Ns_Parser_FS_FileRealPath(tScriptFile);
	return Ns_Parser_FS_CacheFile(tScriptFile);
}
