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
void ResetGlobalLanguageBuffers() =
{
	DeleteBuffer(buf_localizeobjectives);
	buf_localizeobjectives = 0;
	DeleteBuffer(buf_localizegamemode);
	buf_localizegamemode = 0;
}

void SetLanguageFontScale() =
{
	if(currentlanguage == LANGUAGE_JAPANESE)
		languagefontscale = 1.4;
	else
		languagefontscale = 1;
}

void UpdateLanguage() =
{
	local float lang;
	
	lang = cvar("localize_language");
	
	if(lang != currentlanguage)
	{
		currentlanguage = lang;	
		#ifdef CODE_MENU
			Font_Init(currentlanguage);
			GetMOTD();
		#endif
		ResetLanguageBuffers();
		SetLanguageFontScale();
	}
}

string GetLanguageName(float language) =
{
	string langname;

	switch(language)
	{
		case LANGUAGE_ENGLISH:			langname = "english";			break;
		case LANGUAGE_GERMAN:			langname = "german";			break;
		case LANGUAGE_FRENCH:			langname = "french";			break;
		case LANGUAGE_SPANISH_MX:		langname = "spanish_sp";		break;
		case LANGUAGE_SPANISH_ES:		langname = "spanish_es";		break;
		case LANGUAGE_RUSSIAN:			langname = "russian";			break;
		case LANGUAGE_ITALIAN:			langname = "italian";			break;
		case LANGUAGE_POLISH:			langname = "polish";			break;
		case LANGUAGE_PORTUGUESE_BR:	langname = "portuguese_br";		break;	
		case LANGUAGE_PORTUGUESE_PT:	langname = "portuguese_pt";		break;	
		case LANGUAGE_JAPANESE:			langname = "japanese";			break;
	}
	
	return langname;
}

string GetMenuFilename(string funcfilename, float write, float shared) =
{
	local string filename, langpath;
	local float language;
	
	language = cvar("localize_language");
	
	filename = "menu/";
	
	if(!write)
	{
		langpath = GetLanguageName(language);
		filename = strcat(filename, langpath, "/");
	}
	
	if(!shared)
	if(CODEBASE == MENUCODE)
		filename = strcat(filename, "m_");
	else
	if(CODEBASE == CLIENTCODE)
		filename = strcat(filename, "cl_");
	else
	if(CODEBASE == SERVERCODE)
		filename = strcat(filename, "sv_");

	filename = strcat(filename, funcfilename);
	filename = strcat(filename, ".txt");
	
	return filename;
}

void InitializeTranslations(float buf, string filename, float shared) =
{
	local float file;
	local string line;
	
	if(LOCALIZE_GENERATING)
		filetextline = 1;
	else
		filetextline = 0;

	if(cvar("localize_enable"))
	{
		if(LOCALIZE_GENERATING)
			AddBufferString(buf, "# Steel-Storm Translation File", 0);
		else
		{
			filename = GetMenuFilename(filename, FALSE, shared);
			file = FileOpen(filename, FILE_READ);

			if(file != -1)
			{
				fgets(file);
				for(line = fgets(file); line; line = fgets(file))
					AddBufferString(buf, line, 0);

				fclose(file);
			}
		}
	}
}

void WriteTranslations(float buf, string filename, float shared) =
{
	local float file, count, buffersize;
	local string line;

	if(cvar("localize_generateonview") || LOCALIZE_GENERATING)
	if(strlen(filename))
	{
		filename = GetMenuFilename(filename, TRUE, shared);
		file = FileOpen(filename, FILE_WRITE);

		buffersize = GetBufferSize(buf);
		for(count = 0; count < buffersize; count++)
		{
			line = GetBufferString(buf, count);
			NewFileLine(file, line);
		}
		
		fclose(file);
	}	
}

float InitializeNonstandardTranslations(float buf, string filename, float shared) =
{
	filetextline_old = filetextline;
	filetextline = 0;
	
	if(!skiptranslation)
	if(!buf)
	{
		buf = CreateBuffer();
		InitializeTranslations(buf, filename, shared);	
	}
	
	return buf;
}

void WriteNonstandardTranslations(float buf, string filename, float menudependant, float shared) =
{
	if(LOCALIZE_GENERATING)
	if(!menudependant || (menu_initializing || CODEBASE == SERVERCODE))	
	if(!skiptranslation)
		WriteTranslations(buf, filename, shared);
	
	filetextline = filetextline_old;
	filetextline_old = 0;
}

string Localize(string text, float buf) =
{
	local string translatedtext;

	if(!(cvar("localize_enable")) || skiptranslation)
		return text;

	if(!buf)
	{
		filetextline++;	
		return string_null;
	}
		
	if(LOCALIZE_GENERATING)
		SetBufferString(buf, filetextline, text);
	else
	{
		translatedtext = GetBufferString(buf, filetextline);
		if(strlen(translatedtext))
			text = translatedtext;		
	}

	filetextline++;	
	
	return text;
}