/*
===========================================================================

Steel Storm Burning Retribution QuakeC Source Code
Copyright (C) 2008-2024 Kot-in-Action Creative Artel.

This file is part of the Steel Storm Burning Retribution QuakeC Source Code.

License:
  - You may use, modify, and distribute modifications of this source code under the terms of the Steel Storm Burning Retribution QuakeC Source Code License Agreement.
  - No commercial use of this source code or any derivative works is permitted.
  - All mods and modifications must be distributed for free and include this license header.
 
The full text of the license is included in the license.txt file that came with this source code.

If you have questions concerning this license, you may contact info (at) kot-in-action.com

===========================================================================
*/
/*void PrintNumEntsInList(string title) =
{
	local entity e;
	local float count;

	count = 0;
	
	e = list_objectchain;
	while(e)
	{
		count++;
		e = e.objectchain;
	}

	if(count == 1)
	{
	//	print("trying to eprint?\n");
	//	eprint(list_objectchain);
		}
	
	print(title);	
	print(" - TOTAL: ");
	print(ftos(count));
	print("\n");
}*/

entity LinkedList_Remove(entity e, entity list, .entity entchain, .entity entparent) =
{
	if(!(e.entchain || e.entparent || e == list))
		return list;

	if(list == e)
	{
		list = e.entchain;
		if(list)
			list.entparent = world;
	}
	
	if(e.entparent)
		e.entparent.entchain = e.entchain;
	if(e.entchain)
		e.entchain.entparent = e.entparent;
		
	e.entparent = world;
	e.entchain = world;
		
	return list;
}

entity LinkedList_Add(entity e, entity list, .entity entchain, .entity entparent) =
{
	if(e.entchain || e.entparent || e == list)
		return list;

	if(list)
	{
		e.entchain = list;
		list.entparent = e;
	}
	
	list = e;
	
	return list;
}

entity GetLinkedListEnt_float(entity list, .entity entchain, .float floatfield, float match) =
{
	local entity e;
	e = list;
	while(e)
	{
		if(e.floatfield == match)
			break;
		e = e.entchain;
	}

	return e;
}

entity GetLinkedListEnt_entity(entity list, .entity entchain, .entity floatfield, entity match) =
{
	local entity e;
	e = list;
	while(e)
	{
		if(e.floatfield == match)
			break;
		e = e.entchain;
	}

	return e;
}

void ClearPointer_Entfield(.entity efield, entity freedent) =
{
	local entity e;
	e = findchainentity(efield, freedent);
	while(e)
	{
		e.efield = world;		
		e = e.chain;
	}
}

void NewFileLine(float handle, string linetext) =
{
	fputs(handle, linetext);
	fputs(handle, "\n");
}

string zonecpy(string dst, string src) = // if dst is not null or zoned, this will cause errors
{
	local string s;

	if(src != string_null)
	{
	//	zones++;
	//	print("zonecpy: ");	print(src);	print("\n");
		s = strzone(src);
	}
	
	if(dst != string_null)
	{
	//	zones--;
		strunzone(dst);
	}

	return s;
}

string freezone(string zone) = // if zone is not null or zoned, this will cause errors
{
	if(zone != string_null)
	{
	//	print("freezone: ");	print(zone);	print("\n");
	//	zones--;
		strunzone(zone);
	}
	
	zone = string_null;
	
	return zone;
}

float IsLowercaseTitleWord(string s) =
{
	local float filter;

	switch(s)
	{
		case "a":		filter = TRUE;		break;
		case "and":		filter = TRUE;		break;
		case "but":		filter = TRUE;		break;
		case "for":		filter = TRUE;		break;		
		case "from":	filter = TRUE;		break;	
		case "if":		filter = TRUE;		break;
		case "is":		filter = TRUE;		break;				
		case "it":		filter = TRUE;		break;
		case "or":		filter = TRUE;		break;
		case "so":		filter = TRUE;		break;
		case "the":		filter = TRUE;		break;	
		case "to":		filter = TRUE;		break;
	}
	
	return filter;
}

string TimeString_Seconds(float t) =
{
	local string s;
	
	s = ftos(t);
	
	if(t == 0)
		s = "00";
	else
	if(t < 10)
		s = strcat("0", s);
	
	return s;
}

float IsRomanNumeral(string s) =
{
	local float count, letters;
	local string c;
	
	letters = strlen(s);
	
	for(count = 0; count < letters; count++)
	{
		c = substring(s, count, 1);
		c = strtolower(c);
		
		if(!(c == "i"
		|| c == "v"
		|| c == "x"
		|| c == ":"))
			return FALSE;
	}

	return TRUE;
}

string TitleString(string s) =
{
	local float count, words;
	local string ch, text;
	
	words = tokenizebyseparator(s, SEP_SPACE, "_");

	for(count = 0; count < words; count++)
	{
		s = argv(count);
		
		if(IsRomanNumeral(s))
		{
			s = strtoupper(s);
			text = strcat(text, s);
		}
		else
		if(!IsLowercaseTitleWord(s) || !count)
		{
			ch = substring(s, 0, 1);
			text = strcat(text, strtoupper(ch));
			text = strcat(text, substring(s, 1, strlen(s)-1));
		}
		else
			text = strcat(text, s);
		
		if(count < words-1)
			text = strcat(text, " ");
	}
	
	return text;
}

string PrefixZerosToNumString(string numstring, float totallength) =
{
	while(strlen(numstring) < totallength)
		numstring = strcat("0", numstring);
		
	return numstring;
}

string UnderscoreString(string s) =
{
	local string text;
	local float words, count;
	
	s = strtolower(s);
	
	words = tokenizebyseparator(s, SEP_SPACE);
	text = argv(0);
	for(count = 1; count < words; count++)
	{	
		text = strcat(text, "_");
		text = strcat(text, argv(count));
	}
	
	return text;
}

string AppendToken(string src, string SEPARATOR, string appendage) =
{
	src = strcat(src, SEPARATOR);
	src = strcat(src, appendage);
	return src;
}

string AddQuotes(string s) = {	return AppendToken(SEP_QUOTE, s, SEP_QUOTE);	}

void Func_oself(entity e, void() func) =
{
	local entity oself;
	oself = self;
	self = e;
	func();
	self = oself;
}

float IsAssignedFunction(void() func) =
{
	if(func && func != SUB_Null)
		return TRUE;
		
	return FALSE;
}

float CreateBuffer() =	{	return buf_create()+1;	}
void DeleteBuffer(float handle) =	{	if(!handle) return;	buf_del(handle-1);	}
float GetBufferSize(float handle) =	{	return buf_getsize(handle-1);	}
void CopyBuffer(float handle_from, float handle_to) =	{	buf_copy(handle_from-1, handle_to-1);	}
void SortBuffer(float handle, float sortpower, float backward) =	{	buf_sort(handle-1, sortpower, backward);	}
string ImplodeBuffer(float handle, string glue) =	{	return buf_implode(handle-1, glue);	}
string GetBufferString(float handle, float index) =	{	return bufstr_get(handle-1, index);	}
void SetBufferString(float handle, float index, string str) =	{	bufstr_set(handle-1, index, str);	}
float AddBufferString(float handle, string str, float order) =	{	return bufstr_add(handle-1, str, order);	}
void FreeBufferString(float handle, float index) =	{	bufstr_free(handle-1, index);	}

float HasDuplicateStringInList(float buf, string s) =
{
	local float count, buffersize;
	local string bstring;
	
	buffersize = GetBufferSize(buf);
	for(count = 0; count < buffersize; count++)
	{
		bstring = GetBufferString(buf, count);
		if(strtolower(s) == strtolower(bstring))
			return TRUE;
	}

	return FALSE;
}

string URI_Escape(string s) =
{
	s = uri_escape(s);
	s = strtolower(s);
	
	return s;
}

float FileOpen(string filename, float method) =
{
	local float file;

	if(method == FILE_WRITE)
		filename = strtolower(filename);
		
	file = fopen(filename, method);
	
	if(method == FILE_READ)
	if(file == -1)
	if(filename != strtolower(filename))
		file = fopen(strtolower(filename), method);
		
	return file;
}

float GetFrameForTime(float frames, float framelen) =
{
	local float time_current, frame_current;

	time_current = time - floor(time/(framelen*frames))*(framelen*frames);
	frame_current = floor(time_current / framelen);
	
	return frame_current;
}