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

vector Draw2D_Scale;
vector Draw2D_Pos;
vector Draw2D_AreaSize;
vector Draw2D_AreaAlign;
vector Draw2D_AreaOrient;

float Draw2D_ShadowOpacity;
vector Draw2D_ShadowOffset;
float Draw2D_Clip;
float Draw2D_ClipPosX;
float Draw2D_ClipPosY;
float Draw2D_ClipSizeX;
float Draw2D_ClipSizeY;
vector Draw2D_StringEndPos;
float Draw2D_CursorLine;
float Draw2D_CursorPos;
float Draw2D_CursorTime;
float Draw2D_CursorBlinkTime;

// multi line text parser
string mlt_string;
string mlt_skipped;
string mlt_word;
string mlt_token;
string mlt_font;
vector mlt_fontSize;
vector mlt_area;
float mlt_fontDrawFlag;
float mlt_pos;
float mlt_skippedpos;
float mlt_len;
float mlt_newline;
string mlt_line;
vector mlt_linesize;

// font drawer
entity Draw2D_DefaultFontProcessor;
entity Draw2D_FontProcessor;
.vector(entity tFontEntry, string tText, vector tTextSize, float tDrawFlag) d2dTextSize;
.vector(entity tFontEntry, vector tPos, string tText, vector tTextSize, vector tRGB, float tAlpha, float tDrawFlag) d2dDrawText;

// loaded fonts storage
entity draw2d_fontlist;
entity draw2d_foundentry;
.float alpha;
.float clip;
.float clipMarginUp;
.float mType;
.vector scalevec;
#define qfontPicmapBuf alpha
#define qfontKernmapBuf clip
#define qfontBrightness mType
#define qfontScale scalevec
#define qfontScale_x scalevec_x
#define qfontScale_y scalevec_y
#define qfontVOffset scalevec_z

// loaded cursor storage
entity draw2d_cursorlist;
entity draw2d_cursorentry;
.string picture; // map file
.vector orient; // orientation

// drawflags
enumflags
{
	DRAW2D_ADDITIVE,
	DRAW2D_MODULATE, 		// modulate + additive = 2xmodulate
	DRAW2D_SCREEN,			
	DRAW2D_ALIGN,			// all: box-aligned against area (area must be set by Draw2D_SetArea)
	DRAW2D_COLORCODES,		// text: use colorcodes
	DRAW2D_SHADOW,			// text: draw shadow for text
	DRAW2D_MULTILINE,		// text: draw text multiple-lined
	DRAW2D_CURSOR
};

// draw2d orientations
// align/alignment/orient constants
#define DRAW2D_TOPLEFT 		'0 0 0' // default
#define DRAW2D_TOPCENTER 	'1 0 0'
#define DRAW2D_TOPRIGHT 	'2 0 0'
#define DRAW2D_MIDLEFT 		'0 1 0'
#define DRAW2D_MIDCENTER 	'1 1 0'
#define DRAW2D_MIDRIGHT 	'2 1 0'
#define DRAW2D_BOTLEFT 		'0 2 0'
#define DRAW2D_BOTCENTER 	'1 2 0'
#define DRAW2D_BOTRIGHT 	'2 2 0'

// scale one vector by another with z-support (z is scale)
// #define Draw2D_TransformSize(outx, outy, inx, iny, inz) if (inz) { outx = inx*Draw2D_Scale_x*inz; outy = iny*Draw2D_Scale_y*inz; } else { outx = inx*Draw2D_Scale_x; outy = iny*Draw2D_Scale_y; }

////////////////////////////////////////
// CODE
////////////////////////////////////////

/*
================================================================================

  DEFAULT FONT PROCESSOR

================================================================================
*/

vector Draw2D_FontDrawer_Default_TextSize_UTF8(entity tFontEntry, string tText, vector tTextSize, float tDrawFlag)
{
	vector tSize;
	float utf8;

	// draw
	utf8 = cvar("utf8_enable");
	if (!utf8)
	{
		cvar_set("utf8_enable", "1");
		drawfont = tFontEntry.qfontPicmapBuf;
		tSize_x = stringwidth(tText, (tDrawFlag & DRAW2D_COLORCODES), tTextSize);
		tSize_y = tTextSize_y;
		cvar_set("utf8_enable", "0");
	}
	else
	{
		drawfont = tFontEntry.qfontPicmapBuf;
		tSize_x = stringwidth(tText, (tDrawFlag & DRAW2D_COLORCODES), tTextSize);
		tSize_y = tTextSize_y;
	}
	return tSize;
}

vector Draw2D_FontDrawer_Default_DrawText_UTF8(entity tFontEntry, vector tPos, string tText, vector tTextSize, vector tRGB, float tAlpha, float tDrawFlag)
{
	vector tWholeTextSize;
	float utf8;

	// apply mods
	tRGB = tRGB*tFontEntry.qfontBrightness;
	// draw
	utf8 = cvar("utf8_enable");
	if (!utf8)
		cvar_set("utf8_enable", "1");
	drawfont = tFontEntry.qfontPicmapBuf;
	if (tDrawFlag & DRAW2D_COLORCODES)
	{
		if (tDrawFlag & DRAW2D_SHADOW)
			drawstring(tPos + Draw2D_ShadowOffset, tText, tTextSize, '0 0 0', tAlpha*Draw2D_ShadowOpacity, 0);
		drawcolorcodedstring(tPos, tText, tTextSize, tRGB, tAlpha, (tDrawFlag & 7));
		tWholeTextSize_x = tTextSize_x*strlen(tText);
		tWholeTextSize_y = tTextSize_y;
		if (!utf8)
			cvar_set("utf8_enable", "0");
		return tWholeTextSize;
	}
	if (tDrawFlag & DRAW2D_SHADOW)
		drawstring(tPos + Draw2D_ShadowOffset, tText, tTextSize, '0 0 0', tAlpha*Draw2D_ShadowOpacity, 0);
	drawstring(tPos, tText, tTextSize, tRGB, tAlpha, (tDrawFlag & 7));
	tWholeTextSize_x = tTextSize_x*strlen(tText);
	tWholeTextSize_y = tTextSize_y;
	if (!utf8)
		cvar_set("utf8_enable", "0");
	return tWholeTextSize;
}

void() Draw2D_FontDrawer_Default_UTF8 =
{
	self.classname = "Conchars";
	self.d2dTextSize = Draw2D_FontDrawer_Default_TextSize_UTF8;
	self.d2dDrawText = Draw2D_FontDrawer_Default_DrawText_UTF8;
}

vector Draw2D_FontDrawer_Default_TextSize(entity tFontEntry, string tText, vector tTextSize, float tDrawFlag)
{
	vector tSize;
	
	// draw
	drawfont = tFontEntry.qfontPicmapBuf;
	tSize_x = stringwidth(tText, (tDrawFlag & DRAW2D_COLORCODES), tTextSize);
	tSize_y = tTextSize_y;
	return tSize;
}

vector Draw2D_FontDrawer_Default_DrawText(entity tFontEntry, vector tPos, string tText, vector tTextSize, vector tRGB, float tAlpha, float tDrawFlag)
{
	vector tWholeTextSize;

	// apply mods
	tRGB = tRGB*tFontEntry.qfontBrightness;
	// draw
	drawfont = tFontEntry.qfontPicmapBuf;
	if (tDrawFlag & DRAW2D_COLORCODES)
	{
		if (tDrawFlag & DRAW2D_SHADOW)
			drawstring(tPos + Draw2D_ShadowOffset, tText, tTextSize, '0 0 0', tAlpha*Draw2D_ShadowOpacity, 0);
		drawcolorcodedstring(tPos, tText, tTextSize, tRGB, tAlpha, (tDrawFlag & 7));
		tWholeTextSize_x = tTextSize_x*strlen(tText);
		tWholeTextSize_y = tTextSize_y;
		return tWholeTextSize;
	}
	if (tDrawFlag & DRAW2D_SHADOW)
		drawstring(tPos + Draw2D_ShadowOffset, tText, tTextSize, '0 0 0', tAlpha*Draw2D_ShadowOpacity, 0);
	drawstring(tPos, tText, tTextSize, tRGB, tAlpha, (tDrawFlag & 7));
	
	tWholeTextSize_x = tTextSize_x*strlen(tText);
	tWholeTextSize_y = tTextSize_y;
	return tWholeTextSize;
}

void() Draw2D_FontDrawer_Default =
{
	self.classname = "Conchars";
	self.d2dTextSize = Draw2D_FontDrawer_Default_TextSize;
	self.d2dDrawText = Draw2D_FontDrawer_Default_DrawText;
}

/*
================================================================================

  NEW 'QFONT' FONT PROCESSOR

================================================================================
*/

vector Draw2D_FontDrawer_QFont_TextSize(entity tFontEntry, string tText, vector tTextSize, float tDrawFlag)
{
	float tPos, tLen, tAsc;
	vector tSize, tKern, tPrevKern;

	// apply mods
	tTextSize_x = tTextSize_x * tFontEntry.qfontScale_x;
	tTextSize_y = tTextSize_y * tFontEntry.qfontScale_y;
	// draw
	tLen = strlen(tText);
	tSize_x = 0;
	tSize_y = tTextSize_y;
	tPrevKern = '0 0 0';
	for (tPos = 0; tPos < tLen; tPos++)
	{
		tAsc = str2chr(tText, tPos);
		tKern = stov(bufstr_get(Draw2D_FontProcessor.qfontKernmapBuf, tAsc));
		tSize_x = tSize_x + tTextSize_x*tKern_z + (min(tKern_x, tKern_x-tPrevKern_y) + tKern_y)*tTextSize_y;
		tPrevKern = tKern;
	}
	tSize_x = tSize_x - tKern_y*tTextSize_y*2; // don't kern back last character
	
	return tSize;
}

vector Draw2D_FontDrawer_QFont_DrawText(entity tFontEntry, vector tPos, string tText, vector tTextSize, vector tRGB, float tAlpha, float tDrawFlag)
{
	float tLetter, tLen, tAsc;
	vector tOrg, tSize, tKern, tPrevKern;
	vector tWholeTextSize;
	string tPic;
	
	// apply mods
	tRGB = tRGB*tFontEntry.qfontBrightness;
	tTextSize_x = tTextSize_x * tFontEntry.qfontScale_x;
	tTextSize_y = tTextSize_y * tFontEntry.qfontScale_y;
	tPos_y += tTextSize_y * tFontEntry.qfontVOffset;
	// draw
	tOrg = tPos;
	tLen = strlen(tText);
	tSize_y = tTextSize_y;
	tPrevKern = '0 0 0';
	for (tLetter = 0; tLetter < tLen; tLetter++)
	{
		tAsc = str2chr(tText, tLetter);
		tKern = stov(bufstr_get(tFontEntry.qfontKernmapBuf, tAsc));
		tPic = bufstr_get(tFontEntry.qfontPicmapBuf, tAsc);
		if (tPic == "")
			continue;
		tSize_x = tTextSize_x*tKern_z;
		tOrg_x = tOrg_x + min(tKern_x, tKern_x-tPrevKern_y)*tTextSize_y;
		tWholeTextSize_x = tWholeTextSize_x + tSize_x + (min(tKern_x, tKern_x-tPrevKern_y) + tKern_y)*tTextSize_y;
		if (tDrawFlag & DRAW2D_SHADOW)
			drawpic(tOrg + Draw2D_ShadowOffset, tPic, tSize, '0 0 0', tAlpha*Draw2D_ShadowOpacity, 0);
		drawpic(tOrg, tPic, tSize, tRGB, tAlpha, (tDrawFlag & 7));
		tOrg_x = tOrg_x + tSize_x + tKern_y*tTextSize_y;
		tPrevKern = tKern;
	}
	tWholeTextSize_y = tTextSize_y;
	
	return tWholeTextSize;
}

void() Draw2D_FontDrawer_QFont =
{
	self.classname = "QFont";
	self.d2dTextSize = Draw2D_FontDrawer_QFont_TextSize;
	self.d2dDrawText = Draw2D_FontDrawer_QFont_DrawText;
}

/*
================================================================================

  FONT STORAGE

================================================================================
*/

// find entity in font storage
float Draw2D_FontStorage_FindEntry(string tEntryName) =
{
	entity tEntry;
	
	for (tEntry = draw2d_fontlist; isentity(tEntry); tEntry = tEntry._next)
	{	
		if (tEntry.name == tEntryName)
		{
			draw2d_foundentry = tEntry;
			return 1;
		}
	}
	draw2d_foundentry = null_entity;
	return 0;
}

// spawn new font entity and link into list
entity Draw2D_FontStorage_NewEntry(string tName, void() tProfileFunc) =
{
	entity tNewEntry, tEntry, tLastEntry;
	
	if (Draw2D_FontStorage_FindEntry(tName))
		return draw2d_foundentry;

	tNewEntry = spawn();
	tNewEntry.classname = "font_entry";
	tNewEntry.name = strzone(tName);
	// link
	if (isnotentity(draw2d_fontlist))
	{ 
		draw2d_fontlist = tNewEntry; 
		tNewEntry._next = null_entity; 
		tNewEntry._prev = null_entity; 
	} 
	else
	{
		for (tEntry = draw2d_fontlist; tEntry; tEntry = tEntry._next) 
			tLastEntry = tEntry; 
		tLastEntry._next = tNewEntry; 
		tNewEntry._prev = tLastEntry; 
		tNewEntry._next = null_entity;
	}
	// make profile
	tEntry = self;
	self = tNewEntry;
	tProfileFunc();
	self = tEntry;
	return tNewEntry;
}

// delete entry from chain
void Draw2D_FontStorage_DelEntry(entity tEntry)  =
{
	// first
	if (tEntry == draw2d_fontlist)
	{
		if (tEntry._next)
			tEntry._next._prev = null_entity;
		draw2d_fontlist = tEntry._next;
		remove(tEntry);
		return;
	}
	// middle of last
	if (tEntry._next)
		tEntry._next._prev = tEntry._prev;
	if (tEntry._prev)	
		tEntry._prev._next = tEntry._next;
	remove(tEntry);
}

// precache font, returns font entry
entity Draw2D_LoadFontFromBuffer(float tOverride, string tBasePath, string tFontName, float tBuf)
{
	string tFile, tLine, tArg, tCharPic, tDefaultCharPic, tCharSet, tFontSizes;
	float tNumLines, tNumLine, tPos, tLen, tAsc, tFontVersion, tFontSlot, tFontAllowUTF8;
	float tPicBuffer, tKernBuffer, tBrightness, tScaleLen, tUseFullPaths;
	float tFTAntialias, tFTHinting, tFTBlur, tFTOutline;
	float oldFontHinting, oldFontAntialias, oldFontBlur, oldFontOutline, oldFontOutlineX, oldFontOutlineY, oldFontOutlineZ;
	vector tCharKern, tCharSize, tDefaultCharKern, tFTShadow;
	float tScale, tVOffset;
	entity tEntry;

	// already loaded?
	if (Draw2D_FontStorage_FindEntry(tFontName))
	{
		if (tOverride)
			Draw2D_FontStorage_DelEntry(draw2d_foundentry);
		else
			return draw2d_foundentry;
	}
	// create loader structure
	tFontVersion = 1;
	tFontSlot = -1;
	tFontAllowUTF8 = 0;
	tBrightness = 1.0;
	tScale = 1.0;
	tVOffset = 0;
	// freetype defaults
	tFTAntialias = 1;
	tFTHinting = 2;
	tFTBlur = 0;
	tFTOutline = 0;
	tFTShadow = '0 0 0';
	if (tBuf >= 0)
	{
		tNumLines = buf_getsize(tBuf);
		tNumLine = 0;
		// parse file
		// first line should be version
		tScaleLen = 1.0;
		tLine = bufstr_get(tBuf, tNumLine);
		tokenize(tLine); tArg = argv(0);
		if (tArg == "qfontversion1") // conchars
		{
			tFontVersion = 1;
			tCharSet = "";
			for(tNumLine = 1; tNumLine < tNumLines; tNumLine++)
			{
				tLine = bufstr_get(tBuf, tNumLine);
				tLen = tokenize(tLine);
				tArg = argv(0);
				// comment or null line
				if (tLen == 0)
					continue;
				if (tArg == "slot")
				{
					tFontSlot = findfont(argv(1));
					continue;
				}
				if (tArg == "file")
				{
					tCharSet = argv(1);
					if (!strncmp(tCharSet, "./", 2)) // check if relative path is given
						tCharSet = strcat(tBasePath, substring(tCharSet, 2, 10000));
					continue;
				}
				if (tArg == "sizes")
				{
					tFontSizes = "";
					for (tPos = 1; argv(tPos) != ""; tPos++)
						tFontSizes = strcat(tFontSizes, " ", argv(tPos));
					continue;
				}
				if (tArg == "antialias")
				{
					tFTAntialias = stof(argv(1));
					continue;
				}
				if (tArg == "hinting")
				{
					tFTHinting = stof(argv(1));
					continue;
				}
				if (tArg == "shadowblur")
				{
					tFTBlur = stof(argv(1));
					continue;
				}
				if (tArg == "shadowoutline")
				{
					tFTOutline = stof(argv(1));
					continue;
				}
				if (tArg == "shadowofs")
				{
					tFTShadow_x = stof(argv(1));
					tFTShadow_y = stof(argv(2));
					tFTShadow_z = stof(argv(3));
					continue;
				}
				if (tArg == "scale")
				{
					tScale = stof(argv(1));
					continue;
				}
				if (tArg == "voffset")
				{
					tVOffset = stof(argv(1));
					continue;
				}
				if (tArg == "brightness")
				{
					tBrightness = stof(argv(1));	
					continue;
				}
				if (tArg == "encoding")
				{
					tArg = argv(1);
					if (tArg == "utf8")
						tFontAllowUTF8 = 1;	
					else
						tFontAllowUTF8 = 0;	
					continue;
				}
			}
			// load font
			if (tCharSet != "")
			{
				// backup old values
				oldFontAntialias = cvar("r_font_antialias");
				oldFontHinting = cvar("r_font_hinting");
				oldFontBlur = cvar("r_font_postprocess_blur");
				oldFontOutline = cvar("r_font_postprocess_outline");
				oldFontOutlineX = cvar("r_font_postprocess_shadow_x");
				oldFontOutlineY = cvar("r_font_postprocess_shadow_y");
				oldFontOutlineZ = cvar("r_font_postprocess_shadow_z");
				// set new
				cvar_set("r_font_antialias", ftos(tFTAntialias));
				cvar_set("r_font_hinting", ftos(tFTHinting));
				cvar_set("r_font_postprocess_blur", ftos(tFTBlur));
				cvar_set("r_font_postprocess_outline", ftos(tFTOutline));
				cvar_set("r_font_postprocess_shadow_x", ftos(tFTShadow_x));
				cvar_set("r_font_postprocess_shadow_y", ftos(tFTShadow_y));
				cvar_set("r_font_postprocess_shadow_z", ftos(tFTShadow_z));
				// load font
				tFontSlot = loadfont(tFontName, tCharSet, tFontSizes, tFontSlot, tScale, tVOffset);
				// restore old values
				cvar_set("r_font_antialias", ftos(oldFontAntialias));
				cvar_set("r_font_hinting", ftos(oldFontHinting));
				cvar_set("r_font_postprocess_blur", ftos(oldFontBlur));
				cvar_set("r_font_postprocess_outline", ftos(oldFontOutline));
				cvar_set("r_font_postprocess_shadow_x", ftos(oldFontOutlineX));
				cvar_set("r_font_postprocess_shadow_y", ftos(oldFontOutlineY));
				cvar_set("r_font_postprocess_shadow_z", ftos(oldFontOutlineZ));
			}
		}
		else if (tArg == "qfontversion2")
		{
			tFontVersion = 2;
			tCharSet = tFontName; // default charset
			// create buffers
			tPicBuffer = buf_create();
			if (tPicBuffer < 0)
				warning("Draw2D_LoadFontFromBuffer: cannot create pictures buffer");
			tKernBuffer = buf_create();
			if (tKernBuffer < 0)
				warning("Draw2D_LoadFontFromBuffer: cannot create kerning buffer");
			for (tPos = 0; tPos < 256; tPos++)
			{
				bufstr_set(tPicBuffer, tPos, "");
				bufstr_set(tKernBuffer, tPos, "");
			}
			// parse rest of file
			for(tNumLine = 1; tNumLine < tNumLines; tNumLine++)
			{
				tLine = bufstr_get(tBuf, tNumLine);
				tLen = tokenize(tLine);
				tArg = argv(0);
				// comment or null line
				if (tLen == 0)
					continue;
				if (tArg == "testchar")
				{
					print("testchar: ", ftos(str2chr(argv(1), 0)), "\n");
					continue;
				}
				if (tArg == "scale")
				{
					tScale = stof(argv(1));
					continue;
				}
				if (tArg == "voffset")
				{
					tVOffset = stof(argv(1));
					continue;
				}
				if (tArg == "charset")
				{
					tCharSet = argv(1);
					continue;
				}
				if (tArg == "resetcharset")
				{
					tCharSet = tFontName;
					continue;
				}
				if (tArg == "defaultchar")
				{
					tDefaultCharPic = strcat(tBasePath, tCharSet, "/", argv(1));
					#ifndef MENU_DEBUG_NOCACHE
					loadpic(tDefaultCharPic);
					#endif
					tCharSize = getpicsize(tDefaultCharPic);
					if (argv(2) == "kern")
					{
						tDefaultCharKern_x = stof(argv(3))*0.01;
						tDefaultCharKern_y = stof(argv(4))*0.01;
					}
					else
					{
						tDefaultCharKern_x = 0;
						tDefaultCharKern_y = 0;
					}
					tDefaultCharKern_z = (tCharSize_x/tCharSize_y)*tScaleLen;
					for (tPos = 0; tPos < 256; tPos++)
					{
						bufstr_set(tPicBuffer, tPos, tDefaultCharPic);
						bufstr_set(tKernBuffer, tPos, vtos(tDefaultCharKern));
					}
					continue;
				}
				if (tArg == "brightness")
				{
					tBrightness = stof(argv(1));	
					continue;
				}
				if (tArg == "widthscale")
				{
					tScaleLen = stof(argv(1));	
					continue;
				}
				// parse picture
				tCharPic = strcat(tBasePath, tCharSet, "/", argv(0));
				tCharSize = getpicsize(tCharPic);
				#ifndef MENU_DEBUG_NOCACHE
				loadpic(tCharPic);
				#endif
				tCharKern_x = 0;
				tCharKern_y = 0;
				tCharKern_z = (tCharSize_x/tCharSize_y)*tScaleLen;
				// parse char properties
				for (tPos = 1; tPos < tLen; tPos++)
				{
					tArg = argv(tPos);
					if (tArg == "asc") 
					{
						for(tPos++;tPos < tLen;tPos++)
						{
							tAsc = stof(argv(tPos));
							if (tAsc < 0 || tAsc > 255)
								warning(strcat("Draw2D_LoadFontFromBuffer(", tFontName, "): notice when parsing line ", ftos(tNumLine), " : bad ascii code '", argv(tPos), "'"));	
							else
							{
								bufstr_set(tPicBuffer, tAsc, tCharPic);
								bufstr_set(tKernBuffer, tAsc, vtos(tCharKern));
							}
						}
						break;
					}
					if (tArg == "kern")
					{
						if (argv(tPos+1) == "default")
						{
							if (tDefaultCharPic != "")
							{
								tCharKern_x = tDefaultCharKern_x;
								tCharKern_y = tDefaultCharKern_y;
							}
							else
								warning(strcat("Draw2D_LoadFontFromBuffer(", tFontName, "): notice when parsing line ", ftos(tNumLine), " : default kerning is requested, but defaultchar has not been set"));
							tPos = tPos + 1;
						}
						else
						{
							tCharKern_x = stof(argv(tPos+1))*0.01;
							tCharKern_y = stof(argv(tPos+2))*0.01;
							tPos = tPos + 2;
						}
					}
					else
						warning(strcat("Draw2D_LoadFontFromBuffer(", tFontName, "): notice when parsing line ", ftos(tNumLine), " : unknown option " , argv(tPos)));
				}
			}
		}
		else
		{
			tFontVersion = 1;
			warning(strcat("Draw2D_LoadFontFromBuffer(", tFontName, "): error parsing line ", ftos(tNumLine), " : bad version number\n"));
		}
		// delete buffer
		buf_del(tBuf); 
	}
	else	
	{	
		tFontVersion = 1;
		warning(strcat("Draw2D_LoadFontFromBuffer(", tFontName, "): error parsing - buffer is empty\n"));
	}
	// make new font entry
	if (tFontVersion == 1)
	{
		if (tFontAllowUTF8)
			tEntry = Draw2D_FontStorage_NewEntry(tFontName, Draw2D_FontDrawer_Default_UTF8);
		else
			tEntry = Draw2D_FontStorage_NewEntry(tFontName, Draw2D_FontDrawer_Default);
		tEntry.qfontPicmapBuf = tFontSlot;
	}
	else
	{
		tEntry = Draw2D_FontStorage_NewEntry(tFontName, Draw2D_FontDrawer_QFont);
		tEntry.qfontScale_x = tScale;
		tEntry.qfontScale_y = tScale;
		tEntry.qfontVOffset = tVOffset;
		tEntry.qfontPicmapBuf = tPicBuffer;
		tEntry.qfontKernmapBuf = tKernBuffer;
	}
	tEntry.qfontBrightness = tBrightness;
	return tEntry;
}

// precache font from file, returns font entry
entity Draw2D_LoadFont(string tFontName)
{
	string tFile;
	float bh;

	// already loaded?
	if (Draw2D_FontStorage_FindEntry(tFontName))
		return draw2d_foundentry; 
	// try load direct file
	tFile = tFontName;
	bh = loadfile(tFile);
	if (bh >= 0) // loaded
		tFontName = stripextension(basename(tFontName));
	else
	{
		// fallback to .qfont extension
		tFile = strcat(tFontName, ".qfont");
		bh = loadfile(tFile);
		if (bh >= 0) // loaded
			tFontName = stripextension(basename(tFontName));
		else
		{
			// fallback to gfx/fonts/
			tFile = strcat("gfx/fonts/", tFontName);
			bh = loadfile(tFile);
			if (bh < 0)
			{
				// fallback to gfx/fonts/.qfont
				tFile = strcat("gfx/fonts/", tFontName, ".qfont");
				bh = loadfile(tFile);
			}
		}
	}
	// load font
	return Draw2D_LoadFontFromBuffer(0, basepath(tFile), tFontName, bh);
}

// set font for string drawers
#define Draw2D_SetFont(f) if (Draw2D_FontProcessor.name != f) _Draw2D_SetFont(f)
void _Draw2D_SetFont(string tFontName)
{
	if (isnotentity(Draw2D_DefaultFontProcessor))
		Draw2D_DefaultFontProcessor = Draw2D_FontStorage_NewEntry("conchars", Draw2D_FontDrawer_Default);
	// try to load font
	Draw2D_LoadFont(tFontName);
	// set font processor
	if (!Draw2D_FontStorage_FindEntry(tFontName))
		draw2d_foundentry = Draw2D_DefaultFontProcessor;
	Draw2D_FontProcessor = draw2d_foundentry;
}

// reset string drawers for default system font
#define Draw2D_ResetFont(f) Draw2D_FontProcessor = Draw2D_DefaultFontProcessor;

/*
================================================================================

  CURSORS
  
================================================================================
*/

// cursor type
#define QCUR_STATIC			0	// static
#define QCUR_ANIMATED_SYNC	1	// animated, sync with state start time
#define QCUR_ANIMATED_ASYNC	2	// animated, async

// globals used for cursor parsing/drawing
nosave string draw2d_cursor_state;
nosave float draw2d_cursor_statenum;
nosave float draw2d_cursor_type;
nosave vector draw2d_cursor_pos;
nosave vector draw2d_cursor_size;
nosave vector draw2d_cursor_color;
nosave float draw2d_cursor_drawflags;
nosave float draw2d_cursor_alpha;
nosave float draw2d_cursor_shadow;
nosave vector draw2d_cursor_shadowofs;
nosave string draw2d_cursor_pic;

// find entity in cursor storage
float Draw2D_FindCursor(string tEntryName) =
{
	entity tEntry;
	
	for (tEntry = draw2d_cursorlist; isentity(tEntry); tEntry = tEntry._next)
	{	
		if (tEntry.name == tEntryName)
		{
			draw2d_cursorentry = tEntry;
			return 1;
		}
	}
	draw2d_foundentry = null_entity;
	return 0;
}

// get cursor entity
entity Draw2D_GetCursor(string tEntryName)
{
	if (Draw2D_FindCursor(tEntryName))
		return draw2d_cursorentry;
	return null_entity;
}

// spawn new cursor entity and link into list
entity Draw2D_NewCursor(string tName) =
{
	entity tNewEntry, tEntry, tLastEntry;
	
	if (Draw2D_FindCursor(tName))
		return draw2d_cursorentry;

	tNewEntry = spawn();
	tNewEntry.classname = "cursor_entry";
	tNewEntry.name = strzone(tName);
	// link
	if (isnotentity(draw2d_cursorlist))
	{ 
		draw2d_cursorlist = tNewEntry; 
		tNewEntry._next = null_entity; 
		tNewEntry._prev = null_entity; 
	} 
	else
	{
		for (tEntry = draw2d_cursorlist; tEntry; tEntry = tEntry._next) 
			tLastEntry = tEntry; 
		tLastEntry._next = tNewEntry; 
		tNewEntry._prev = tLastEntry; 
		tNewEntry._next = null_entity;
	}
	return tNewEntry;
}

// check if cursor file is loadable
float Draw2D_IsLoadableQCursor(string tCursorName)
{
	string tFile;
	float tFileHandle;
	
	tFile = strcat("gfx/cursors/", tCursorName, ".qcur");
	tFileHandle = fopen(tFile, FILE_READ);
	if (tFileHandle < 0)
		return 0;
	fclose(tFileHandle);
	return 1;
}

// reset cursor globals
void() Draw2D_CursorResetState =
{
	draw2d_cursor_state = "";
	draw2d_cursor_statenum = 0;			
	draw2d_cursor_type = QCUR_STATIC;
	draw2d_cursor_size = '20 20 0';
	draw2d_cursor_pos = '0 0 0';
	draw2d_cursor_color = '1 1 1';
	draw2d_cursor_drawflags = 0;
	draw2d_cursor_alpha = 1;
	draw2d_cursor_pic = "";
	draw2d_cursor_shadow = 0;
	draw2d_cursor_shadowofs = '1 1 0';
}

// update cursor state themefrom globals
float Draw2D_CursorSaveState(entity tEntry)
{
	float tPos, tLen;
	string tStr, tPic;
	
	if (!tEntry)
		return 0;
		
	// check if theme already exists
	tLen = buf_getsize(tEntry.qfontPicmapBuf);
	for (tPos = 0; tPos < tLen; tPos++)
		if (bufstr_get(tEntry.qfontPicmapBuf, tPos) == draw2d_cursor_state)
			return 0;
			
	// set pic
	tPic = draw2d_cursor_pic;
	if (substring(tPic, 0, 4) != "gfx/") // check for full path
		tPic = strcat("gfx/cursors/", tPic);
	loadpic(tPic);
			
	// save
	bufstr_set(tEntry.qfontPicmapBuf, draw2d_cursor_statenum, draw2d_cursor_state);
	tStr = strcat(ftos(draw2d_cursor_type), " ");
	tStr = strcat(tStr, vtos(draw2d_cursor_size), " ");
	tStr = strcat(tStr, vtos(draw2d_cursor_pos), " ");
	tStr = strcat(tStr, vtos(draw2d_cursor_color), " ");
	tStr = strcat(tStr, ftos(draw2d_cursor_drawflags), " ");
	tStr = strcat(tStr, ftos(draw2d_cursor_alpha), " ");
	tStr = strcat(tStr, "\"", tPic, "\"");
	tStr = strcat(tStr, ftos(draw2d_cursor_shadow), " ");
	tStr = strcat(tStr, vtos(draw2d_cursor_shadowofs), " ");
	bufstr_set(tEntry.qfontKernmapBuf, draw2d_cursor_statenum, tStr);
	return 1;
}

// load specific theme from cursor
// loads "default" theme if nothing happens
float Draw2D_CursorFetchState(entity tEntry, string tThemeName)
{
	float tPos, tLen;
	
	if (!tEntry)
		return 0;
	tLen = buf_getsize(tEntry.qfontPicmapBuf);
	for (tPos = 0; tPos < tLen; tPos++)
		if (bufstr_get(tEntry.qfontPicmapBuf, tPos) == tThemeName)
			break; // found
	if (tPos >= tLen) // load "default" theme instead
	{
		tThemeName = "default";
		for (tPos = 0; tPos < tLen; tPos++)
			if (bufstr_get(tEntry.qfontPicmapBuf, tPos) == tThemeName)
				break;
	}
	if (tPos >= tLen) // too bad!
		return 0;
	
	// set
	tokenize(bufstr_get(tEntry.qfontKernmapBuf, tPos));
	draw2d_cursor_state = tThemeName;
	draw2d_cursor_type = stof(argv(0));
	draw2d_cursor_size = stov(argv(1));
	draw2d_cursor_pos = stov(argv(2));
	draw2d_cursor_color = stov(argv(3));
	draw2d_cursor_drawflags = stof(argv(4));
	draw2d_cursor_alpha = stof(argv(5));
	draw2d_cursor_pic = argv(6);
	draw2d_cursor_shadow = stof(argv(7));
	draw2d_cursor_shadowofs = stov(argv(8));
	return 1;
}

// precache cursor, returns cursor entry
entity Draw2D_LoadCursor(string tCursorName)
{
	float tFileHandle, tNumLine, tNumStates, tPos, tLen, tUseDefaultCursor, tHasDefaultstate, tCursorStateNum, tCursorType, tCursorDrawflag, tCursorAlpha;
	string tFile, tLine, tStr, tCursorState, tCursorPic;
	vector tCursorSize, tCursorPos, tCursorColor;
	entity tEntry;
	
	// check if cursor is cached already
	if (Draw2D_FindCursor(tCursorName))
		return draw2d_cursorentry;
		
	// make new font entry
	tEntry = Draw2D_NewCursor(tCursorName);
	tEntry.qfontPicmapBuf = buf_create(); // reuse fields from QFont
	tEntry.qfontKernmapBuf = buf_create();
	
	// open and load cursor file
	tFile = strcat("gfx/cursors/", tCursorName, ".qcur");
	tFileHandle = fopen(tFile, FILE_READ);
	tHasDefaultstate = 0;
	if (tFileHandle < 0)
	{
		tUseDefaultCursor = 1;
		warning(strcat("Draw2D_LoadCursor(", tCursorName, "): cannot open file!\n"));
	}
	else
	{
		// first line should be version
		tLine = fgets(tFileHandle);
		tNumLine = 1;
		if (tLine == "qcursorversion1")
			tUseDefaultCursor = 1;
		else if (tLine == "qcursorversion2")
		{
			// reset cursor info
			tNumStates = 0;
			Draw2D_CursorResetState();
			
			// parse
			for(tLine = fgets(tFileHandle); tLine; tLine = fgets(tFileHandle))
			{
				tNumLine++;
				tLen = tokenize(tLine);
				if (!tLen)
					continue;
				if (argv(1) == ":") // new state
				{
					// save state
					if (tCursorState != "")
					{
						if (Draw2D_CursorSaveState(tEntry))
							tNumStates++;
						else
							warning(strcat("Draw2D_LoadCursor(", tCursorName, "): state'", tCursorState, "' redefined on line ", ftos(tNumLine), "\n"));
					}
					
					// reset cursor props
					Draw2D_CursorResetState();
					draw2d_cursor_state = argv(0);
					draw2d_cursor_statenum = tNumStates;
					if (draw2d_cursor_state == "default")
						tHasDefaultstate = 1;
					continue;
				}
				
				// parse parms
				tStr = argv(0);
				if (tLen < 2)
				{
					warning(strcat("Draw2D_LoadCursor(", tCursorName, "): not enough parms on line ", ftos(tNumLine), "\n"));
					continue;
				}
				if (tStr == "size")
				{
					if (argv(2) == "")
						draw2d_cursor_size = stov(argv(1));
					else
					{
						draw2d_cursor_size_x = stof(argv(1));
						draw2d_cursor_size_y = stof(argv(2));
					}
				}
				else if (tStr == "center")
				{
					if (argv(2) == "")
						draw2d_cursor_pos = stov(argv(1));
					else
					{
						draw2d_cursor_pos_x = 0 - stof(argv(1));	
						draw2d_cursor_pos_y = 0 - stof(argv(2));	
					}
				}
				else if (tStr == "pic")
					draw2d_cursor_pic = argv(1);	
				else if (tStr == "color")
				{
					if (argv(2) == "")
						draw2d_cursor_color = stov(argv(1));	
					else
					{
						draw2d_cursor_color_x = stof(argv(1));
						draw2d_cursor_color_y = stof(argv(2));
						draw2d_cursor_color_z = stof(argv(3));
					}
				}					
				else if (tStr == "alpha")
					draw2d_cursor_alpha = stof(argv(1));	
				else if (tStr == "shadowalpha")
					draw2d_cursor_shadow = stof(argv(1));	
				else if (tStr == "shadowoffset")
				{
					if (argv(2) == "")
						draw2d_cursor_shadowofs = stov(argv(1));	
					else
					{
						draw2d_cursor_shadowofs_x = stof(argv(1));	
						draw2d_cursor_shadowofs_y = stof(argv(2));	
					}
				}
				else if (tStr == "shadow")
				{
					draw2d_cursor_shadow = stof(argv(1));	
					if (argv(2) != "")
					{
						if (argv(3) == "")
							draw2d_cursor_shadowofs = stov(argv(2));	
						else
						{
							draw2d_cursor_shadowofs_x = stof(argv(2));	
							draw2d_cursor_shadowofs_y = stof(argv(3));	
						}
					}
				}
				else if (tStr == "drawmode")
				{
					tStr = argv(1);
					if (tStr == "normal")
						draw2d_cursor_drawflags = 0;
					else if (tStr == "add" || tStr == "additive")
						draw2d_cursor_drawflags = DRAW2D_ADDITIVE;	
					else if (tStr == "mod" || tStr == "modulate")
						draw2d_cursor_drawflags = DRAW2D_MODULATE;	
					else if (tStr == "mod2x" || tStr == "modulate2x")
						draw2d_cursor_drawflags = DRAW2D_MODULATE | DRAW2D_ADDITIVE;		
					else if (tStr == "screen")
						draw2d_cursor_drawflags = DRAW2D_SCREEN;		
					else
						warning(strcat("Draw2D_LoadCursor(", tCursorName, "): unknown cursor drawmode '", tStr, "' on line ", ftos(tNumLine), "\n"));
				}		
				else
					warning(strcat("Draw2D_LoadCursor(", tCursorName, "): unexpected token '", tStr, "' on line ", ftos(tNumLine), "\n"));
			}
			
			// save last state / check for any states
			if (draw2d_cursor_state == "")
			{
				warning(strcat("Draw2D_LoadCursor(", tCursorName, "): no states defined!\n"));
				tUseDefaultCursor = 1;
			}
			else if (Draw2D_CursorSaveState(tEntry))
				tNumStates++;
			else
				warning(strcat("Draw2D_LoadCursor(", tCursorName, "): state'", tCursorState, "' redefined\n"));
				
			// check if cursor has deault state, if no - add it and warn
			if (!tHasDefaultstate)
			{
				Draw2D_CursorFetchState(tEntry, bufstr_get(tEntry.qfontPicmapBuf, 0));
				warning(strcat("Draw2D_LoadCursor(", tCursorName, "): 'default' state is not defiled, using '", draw2d_cursor_state, "' for it\n"));
				draw2d_cursor_state = "default";
				Draw2D_CursorSaveState(tEntry);
			}
		}
		else
		{
			tUseDefaultCursor = 1;
			warning(strcat("Draw2D_LoadCursor(", tCursorName, "): bad file\n"));
		}
		fclose(tFileHandle);
	}
	
	// use default cursor?
	if (tUseDefaultCursor)
	{
		buf_del(tEntry.qfontPicmapBuf);
		buf_del(tEntry.qfontKernmapBuf);
		tEntry.qfontPicmapBuf = buf_create(); // reuse fields from QFont
		tEntry.qfontKernmapBuf = buf_create();
		Draw2D_CursorResetState();
		draw2d_cursor_state = "default";
		draw2d_cursor_statenum = 0;
		draw2d_cursor_pic = "gfx/menu/mousecursor";
		Draw2D_CursorSaveState(tEntry);
	}
		
	return tEntry;
}

void Draw2D_DrawCursor(entity tCursor, string tState, vector tDrawPos)
{
	vector tPos, tSize, tShadowOfs;

	if (!Draw2D_CursorFetchState(tCursor, tState))
		return;
		
	// transfom into con space
	tPos_x = (tDrawPos_x + draw2d_cursor_pos_x)*Draw2D_Scale_x;
	tPos_y = (tDrawPos_y + draw2d_cursor_pos_y)*Draw2D_Scale_y;
	tSize_x = draw2d_cursor_size_x*Draw2D_Scale_x;
	tSize_y = draw2d_cursor_size_y*Draw2D_Scale_y;
	tShadowOfs_x = draw2d_cursor_shadowofs_x*Draw2D_Scale_x;
	tShadowOfs_y = draw2d_cursor_shadowofs_y*Draw2D_Scale_y;
	
	// draw
	if (draw2d_cursor_shadow)
		drawpic(tPos + tShadowOfs, draw2d_cursor_pic, tSize, '0 0 0', draw2d_cursor_alpha*draw2d_cursor_shadow, 0);
	drawpic(tPos, draw2d_cursor_pic, tSize, draw2d_cursor_color, draw2d_cursor_alpha, (draw2d_cursor_drawflags & 7));
}

/*
================================================================================

  BRUSH-BASED DRAW

================================================================================
*/

void Draw2D_SetPos(float tX, float tY)
{
	Draw2D_Pos_x = tX;
	Draw2D_Pos_y = tY;
}

void Draw2D_SetPosX(float tX)
{
	Draw2D_Pos_x = tX;
}

void Draw2D_SetPosY(float tY)
{
	Draw2D_Pos_y = tY;
}

void Draw2D_Move(float tX, float tY, float tDistX, float tDistY)
{
	Draw2D_Pos_x += tX*tDistX;
	Draw2D_Pos_y += tY*tDistY;
}

void Draw2D_MoveX(float tX)
{
	Draw2D_Pos_x += tX;
}

void Draw2D_MoveY(float tY)
{
	Draw2D_Pos_y += tY;
}

void Draw2D_SetArea(vector tSize, vector tAlign, vector tOrient)
{
	Draw2D_AreaSize_x = tSize_x*Draw2D_Scale_x;
	Draw2D_AreaSize_y = tSize_y*Draw2D_Scale_y;
	Draw2D_AreaAlign = tAlign*0.5;
	Draw2D_AreaOrient = tOrient*0.5;
}

void Draw2D_SetShadow(float tOpacity, vector tOffset)
{
	Draw2D_ShadowOpacity = tOpacity;
	Draw2D_ShadowOffset_x = tOffset_x*Draw2D_Scale_x;
	Draw2D_ShadowOffset_y = tOffset_y*Draw2D_Scale_y;
}

void() Draw2D_ResetShadow =
{
	Draw2D_ShadowOpacity = 0;
}

void Draw2D_SetCursor(float tLine, float tPos, float tStartTime, float tBlinkTime) =
{
	Draw2D_CursorLine = tLine;
	Draw2D_CursorPos = tPos;
	Draw2D_CursorTime = tStartTime;
	Draw2D_CursorBlinkTime = tBlinkTime;
}

/*
================================================================================

  DRAW CALLS

================================================================================
*/

// just align
vector Draw2D_Align(vector tPos, vector tArea, vector tSize, vector tAlign, vector tOrient)
{
	tPos_x = tPos_x + (tArea_x - tSize_x)*0.5*tAlign_x - tOrient_x*0.5*tArea_x;
	tPos_y = tPos_y + (tArea_y - tSize_y)*0.5*tAlign_y - tOrient_y*0.5*tArea_y;
	return tPos;
}

// draw line
void Draw2D_DrawLine(vector tPos, float tWidth, vector tSize, vector tRGB, float tAlpha, float tDrawFlag)
{
	// todo: scale width
	// transfom into con space
	tPos_x = tPos_x*Draw2D_Scale_x;
	tPos_y = tPos_y*Draw2D_Scale_y;
	tSize_x = tSize_x*Draw2D_Scale_x;
	tSize_y = tSize_y*Draw2D_Scale_y;
	// align
	if (tDrawFlag & DRAW2D_ALIGN)
	{
		tPos_x = tPos_x + (Draw2D_AreaSize_x - tSize_x)*Draw2D_AreaAlign_x - Draw2D_AreaOrient_x*Draw2D_AreaSize_x;
		tPos_y = tPos_y + (Draw2D_AreaSize_y - tSize_y)*Draw2D_AreaAlign_y - Draw2D_AreaOrient_y*Draw2D_AreaSize_y;
	}
	if (tDrawFlag & DRAW2D_SHADOW)
		drawline(tWidth, tPos + Draw2D_ShadowOffset, tSize, '0 0 0', tAlpha*Draw2D_ShadowOpacity, 0);
	drawline(tWidth, tPos, tSize, tRGB, tAlpha, (tDrawFlag & 7));
}

// draw grid
void(vector tPos, vector tSize, vector tBorder, float tHorzIndex, float tVertIndex) Null_GridCellDraw =
{
};
void Draw2D_DrawGrid(vector tPos, vector tGrid, vector tBorder, vector tSize, vector tRGB, float tAlpha, float tDrawFlags, void(vector tPos, vector tSize, vector tBorder, float tHorzIndex, float tVertIndex) GridCellDraw)
{
	vector tGridPos;
	vector tGridSize;
	vector tGridWidth;
	float tHorzIndex;
	float tVertIndex;
	
	// todo: alpha-draw is harder (because of blended grid intersections)
	// draw cells
	if (GridCellDraw != Null_GridCellDraw)
	{
		if (tGrid_x && tGrid_y)
		{
			tGridSize = tGrid;
			tVertIndex = 0;
			for(tGridPos_y = 0;tGridPos_y < tSize_y;tGridPos_y += tGrid_y)
			{
				tHorzIndex = 0;
				for(tGridPos_x = 0;tGridPos_x < tSize_x;tGridPos_x += tGrid_x)
				{
					GridCellDraw(tPos + tGridPos, tGridSize, tBorder, tHorzIndex, tVertIndex);
					tHorzIndex++;
				}
				tVertIndex++;
			}
		}
		else if (tGrid_x)
		{
			tGridSize_x = tGrid_x;
			tGridSize_y = tSize_y;
			tVertIndex = 0;
			tHorzIndex = 0;
			for(tGridPos_y = 0;tGridPos_y < tSize_y;tGridPos_y += tGrid_y)
			{
				GridCellDraw(tPos + tGridPos, tGridSize, tBorder, tHorzIndex, tVertIndex);
				tHorzIndex++;
			}
		}
		else if (tGrid_y)
		{
		
			tGridSize_x = tSize_x;
			tGridSize_y = tGrid_y;
			tVertIndex = 0;
			tHorzIndex = 0;
			for(tGridPos_x= 0;tGridPos_x < tSize_x;tGridPos_x += tGrid_x)
			{
				GridCellDraw(tGridPos, tGridSize, tBorder, tHorzIndex, tVertIndex);
				tVertIndex++;
			}
		}
	}
	// transfom into con space
	tPos_x = tPos_x*Draw2D_Scale_x;
	tPos_y = tPos_y*Draw2D_Scale_y;
	tSize_x = tSize_x*Draw2D_Scale_x;
	tSize_y = tSize_y*Draw2D_Scale_y;
	tGrid_x = tGrid_x*Draw2D_Scale_x;
	tGrid_y = tGrid_y*Draw2D_Scale_y;
	tBorder_x = tBorder_x*Draw2D_Scale_x;
	tBorder_x = tBorder_y*Draw2D_Scale_y;
	// draw horizontal grid
	if (tGrid_x)
	{
		tGridPos_x = 0;
		tGridPos_y = 0;
		tGridSize_x = 0;
		tGridSize_y = tSize_y;
		tGridWidth_x = tBorder_x*0.5*Draw2D_Scale_x;
		tGridWidth_y = 0;
		while(tGridPos_x < (tSize_x - tGrid_x))
		{
			tGridPos_x = tGridPos_x + tGrid_x;
			drawfill(tPos + tGridPos - tGridWidth, tGridSize + tGridWidth, tRGB, tAlpha, (tDrawFlags & 3));
		}
	}
	// draw vertical grid
	if (tGrid_y)
	{
		tGridPos_x = 0;
		tGridPos_y = 0;
		tGridSize_x = tSize_x;
		tGridSize_y = 0;
		tGridWidth_x = 0;
		tGridWidth_y = tBorder_y*0.5*Draw2D_Scale_y;
		while(tGridPos_y < (tSize_y - tGrid_y))
		{
			tGridPos_y = tGridPos_y + tGrid_y;
			drawfill(tPos + tGridPos - tGridWidth, tGridSize + tGridWidth, tRGB, tAlpha, (tDrawFlags & 3));
		}
	}
}

// draw fill
void Draw2D_DrawFill(vector tPos, vector tSize, vector tRGB, float tAlpha, float tDrawFlag)
{
	// transfom into con space
	tPos_x = tPos_x*Draw2D_Scale_x;
	tPos_y = tPos_y*Draw2D_Scale_y;
	tSize_x = tSize_x*Draw2D_Scale_x;
	tSize_y = tSize_y*Draw2D_Scale_y;
	// align
	if (tDrawFlag & DRAW2D_ALIGN)
	{
		tPos_x = tPos_x + (Draw2D_AreaSize_x - tSize_x)*Draw2D_AreaAlign_x - Draw2D_AreaOrient_x*Draw2D_AreaSize_x;
		tPos_y = tPos_y + (Draw2D_AreaSize_y - tSize_y)*Draw2D_AreaAlign_y - Draw2D_AreaOrient_y*Draw2D_AreaSize_y;
	}
	if (tDrawFlag & DRAW2D_SHADOW)
		drawfill(tPos + Draw2D_ShadowOffset, tSize, '0 0 0', tAlpha*Draw2D_ShadowOpacity, 0);
	drawfill(tPos, tSize, tRGB, tAlpha, (tDrawFlag & 7));
}

// draw picture
void Draw2D_DrawPic(vector tPos, string tPic, vector tSize, vector tRGB, float tAlpha, float tDrawFlag)
{
	// transfom into con space
	tPos_x = tPos_x*Draw2D_Scale_x;
	tPos_y = tPos_y*Draw2D_Scale_y;
	tSize_x = tSize_x*Draw2D_Scale_x;
	tSize_y = tSize_y*Draw2D_Scale_y;
	// align
	if (tDrawFlag & DRAW2D_ALIGN)
	{
		tPos_x = tPos_x + (Draw2D_AreaSize_x - tSize_x)*Draw2D_AreaAlign_x - Draw2D_AreaOrient_x*Draw2D_AreaSize_x;
		tPos_y = tPos_y + (Draw2D_AreaSize_y - tSize_y)*Draw2D_AreaAlign_y - Draw2D_AreaOrient_y*Draw2D_AreaSize_y;
	}
	if (tDrawFlag & DRAW2D_SHADOW)
		drawpic(tPos + Draw2D_ShadowOffset, tPic, tSize, '0 0 0', tAlpha*Draw2D_ShadowOpacity, 0);
	drawpic(tPos, tPic, tSize, tRGB, tAlpha, (tDrawFlag & 7));
}

// draw text
// get text size
vector Draw2D_GetTextSize(string tText, string tFontName, vector tFontSize, float tDrawFlag)
{
	if (tFontName != "")
		Draw2D_SetFont(tFontName);
	return Draw2D_FontProcessor.d2dTextSize(Draw2D_FontProcessor, tText, tFontSize, tDrawFlag);
}

// draw text
// get number of lines
float Draw2D_CountLines(string tText)
{
	return tokenizebyseparator(tText, "\n", "\\n");
}

// draw horizontal text string
// returns drawed text size
vector Draw2D_DrawText(vector tPos, string tText, string tFontName, vector tFontSize, vector tRGB, float tAlpha, float tDrawFlag)
{
	vector tSize, tOverallSize, tDrawPos;
	float t, lines;
	string s;
	
	// transform into con space
	tPos_x = tPos_x*Draw2D_Scale_x;
	tPos_y = tPos_y*Draw2D_Scale_y;
	if (tFontSize_z)
	{
		tFontSize_x = tFontSize_x*Draw2D_Scale_x*tFontSize_z;
		tFontSize_y = tFontSize_y*Draw2D_Scale_y*tFontSize_z;
	}
	else
	{
		tFontSize_x = tFontSize_x*Draw2D_Scale_x;
		tFontSize_y = tFontSize_y*Draw2D_Scale_y;
	}
	// set font
	if (tFontName != "")
		Draw2D_SetFont(tFontName);
	// draw multilined text
	if (tDrawFlag & DRAW2D_MULTILINE)
	{
		lines = tokenizebyseparator(tText, "\n", "\\n");
		// aligned draw
		if (tDrawFlag & DRAW2D_ALIGN)
		{
			// apply orient vertical align immediately
			tPos_x = tPos_x - Draw2D_AreaOrient_x*Draw2D_AreaSize_x;
			tPos_y = tPos_y - Draw2D_AreaOrient_y*Draw2D_AreaSize_y + (Draw2D_AreaSize_y - tFontSize_y*lines)*Draw2D_AreaAlign_y;
			// draw with horizontal align
			for (t = 0; t < lines; t++)
			{
				s = argv(t);
				tSize = Draw2D_FontProcessor.d2dTextSize(Draw2D_FontProcessor, s, tFontSize, tDrawFlag);
				tDrawPos_x = tPos_x + (Draw2D_AreaSize_x - tSize_x)*Draw2D_AreaAlign_x;
				tDrawPos_y = tPos_y;
				Draw2D_FontProcessor.d2dDrawText(Draw2D_FontProcessor, tDrawPos, s, tFontSize, tRGB, tAlpha, tDrawFlag);
				// draw cursor
				if (tDrawFlag & DRAW2D_CURSOR && t == Draw2D_CursorLine)
				{
					tSize = Draw2D_FontProcessor.d2dTextSize(Draw2D_FontProcessor, substring(s, 0, Draw2D_CursorPos), tFontSize, tDrawFlag);
					tDrawPos_x = tDrawPos_x + tSize_x;
					Draw2D_DrawFill(tDrawPos, vec2(1, tFontSize_y), '1 1 1', rint(0.1 + sin((time - Draw2D_CursorTime)*Draw2D_CursorBlinkTime)), 0);
				}
				// adjust line
				tPos_y = tPos_y + tSize_y;
				// adjust overall size
				if (tSize_x > tOverallSize_x)
					tOverallSize_x = tSize_x;
				tOverallSize_y = tOverallSize_y + tSize_y;
			}
			return tOverallSize;
		}
		// normal draw
		for (t = 0; t < lines; t++)
		{
			tSize = Draw2D_FontProcessor.d2dDrawText(Draw2D_FontProcessor, tPos, argv(t), tFontSize, tRGB, tAlpha, tDrawFlag);
			// draw cursor
			if (tDrawFlag & DRAW2D_CURSOR && t == Draw2D_CursorLine)
			{
				tSize = Draw2D_FontProcessor.d2dTextSize(Draw2D_FontProcessor, substring(s, 0, Draw2D_CursorPos), tFontSize, tDrawFlag);
				tDrawPos_x = tPos_x + tSize_x;
				tDrawPos_y = tPos_y;
				Draw2D_DrawFill(tDrawPos, vec2(1, tFontSize_y), '1 1 1', rint(0.1 + sin((time - Draw2D_CursorTime)*Draw2D_CursorBlinkTime)), 0);
			}
			// adjust line
			tPos_y = tPos_y + tSize_y; 
			// adjust overall size
			if (tSize_x > tOverallSize_x)
				tOverallSize_x = tSize_x;
			tOverallSize_y = tOverallSize_y + tSize_y;
		}
		return tOverallSize;
	}
	// draw single line
	if (tDrawFlag & DRAW2D_ALIGN)
	{
		tSize = Draw2D_FontProcessor.d2dTextSize(Draw2D_FontProcessor, tText, tFontSize, tDrawFlag);
		tPos_x = tPos_x + (Draw2D_AreaSize_x - tSize_x)*Draw2D_AreaAlign_x - Draw2D_AreaOrient_x*Draw2D_AreaSize_x;
		tPos_y = tPos_y + (Draw2D_AreaSize_y - tSize_y)*Draw2D_AreaAlign_y - Draw2D_AreaOrient_y*Draw2D_AreaSize_y;
	}
	tOverallSize = Draw2D_FontProcessor.d2dDrawText(Draw2D_FontProcessor, tPos, tText, tFontSize, tRGB, tAlpha, tDrawFlag);
	// draw cursor
	if (tDrawFlag & DRAW2D_CURSOR)
	{
		tSize = Draw2D_FontProcessor.d2dTextSize(Draw2D_FontProcessor, substring(tText, 0, Draw2D_CursorPos), tFontSize, tDrawFlag);
		tPos_x = tPos_x + tSize_x;
		Draw2D_DrawFill(tPos, vec2(1, tFontSize_y), '1 1 1', rint(0.1 + sin((time - Draw2D_CursorTime)*Draw2D_CursorBlinkTime)), 0);
	}
	return tOverallSize;
}

// draw text
// build a buffer for multiline text
float Draw2D_BufForMultilineText(string tText)
{
	float l, lines, buf;
	
	buf = buf_create();
	lines = tokenizebyseparator(tText, "\n", "\\n");
	for (l = 0; l < lines; l++)
		bufstr_add(buf, argv(l), 1);
	return buf;
}

// draw horizontal text string from buffer
// returns drawed text size
// this is fully equal to Draw2D_DrawText but takes bufhandle as input
// if multiline not supplied - it only draws string 0
vector Draw2D_DrawTextBuf(vector tPos, float tTextBuf, string tFontName, vector tFontSize, vector tRGB, float tAlpha, float tDrawFlag)
{
	vector tSize, tOverallSize, tDrawPos;
	float t, lines;
	string txt, s;
	
	// transform into con space
	tPos_x = tPos_x*Draw2D_Scale_x;
	tPos_y = tPos_y*Draw2D_Scale_y;
	if (tFontSize_z)
	{
		tFontSize_x = tFontSize_x*Draw2D_Scale_x*tFontSize_z;
		tFontSize_y = tFontSize_y*Draw2D_Scale_y*tFontSize_z;
	}
	else
	{
		tFontSize_x = tFontSize_x*Draw2D_Scale_x;
		tFontSize_y = tFontSize_y*Draw2D_Scale_y;
	}
	// set font
	if (tFontName != "")
		Draw2D_SetFont(tFontName);
	// draw multilined text
	if (tDrawFlag & DRAW2D_MULTILINE)
	{
		lines = buf_getsize(tTextBuf);
		// aligned draw
		if (tDrawFlag & DRAW2D_ALIGN)
		{
			// apply orient vertical align immediately
			tPos_x = tPos_x - Draw2D_AreaOrient_x*Draw2D_AreaSize_x;
			tPos_y = tPos_y - Draw2D_AreaOrient_y*Draw2D_AreaSize_y + (Draw2D_AreaSize_y - tFontSize_y*lines)*Draw2D_AreaAlign_y;
			// draw with horizontal align
			for (t = 0; t < lines; t++)
			{
				s = bufstr_get(tTextBuf, t);
				tSize = Draw2D_FontProcessor.d2dTextSize(Draw2D_FontProcessor, s, tFontSize, tDrawFlag);
				tDrawPos_x = tPos_x + (Draw2D_AreaSize_x - tSize_x)*Draw2D_AreaAlign_x;
				tDrawPos_y = tPos_y;
				Draw2D_FontProcessor.d2dDrawText(Draw2D_FontProcessor, tDrawPos, s, tFontSize, tRGB, tAlpha, tDrawFlag);
				tPos_y = tPos_y + tSize_y; // adjust line
				// adjust overall size
				if (tSize_x > tOverallSize_x)
					tOverallSize_x = tSize_x;
				tOverallSize_y = tOverallSize_y + tSize_y;
			}
			return tOverallSize;
		}
		// normal draw
		for (t = 0; t < lines; t++)
		{
			tSize = Draw2D_FontProcessor.d2dDrawText(Draw2D_FontProcessor, tPos, bufstr_get(tTextBuf, t), tFontSize, tRGB, tAlpha, tDrawFlag);
			tPos_y = tPos_y + tSize_y; // adjust line
			// adjust overall size
			if (tSize_x > tOverallSize_x)
				tOverallSize_x = tSize_x;
			tOverallSize_y = tOverallSize_y + tSize_y;
		}
		return tOverallSize;
	}
	// draw single line
	txt = bufstr_get(tTextBuf, 0);
	if (tDrawFlag & DRAW2D_ALIGN)
	{
		tSize = Draw2D_FontProcessor.d2dTextSize(Draw2D_FontProcessor, txt, tFontSize, tDrawFlag);
		tPos_x = tPos_x + (Draw2D_AreaSize_x - tSize_x)*Draw2D_AreaAlign_x - Draw2D_AreaOrient_x*Draw2D_AreaSize_x;
		tPos_y = tPos_y + (Draw2D_AreaSize_y - tSize_y)*Draw2D_AreaAlign_y - Draw2D_AreaOrient_y*Draw2D_AreaSize_y;
	}
	return Draw2D_FontProcessor.d2dDrawText(Draw2D_FontProcessor, tPos, txt, tFontSize, tRGB, tAlpha, tDrawFlag);
}

/*
================================================================================

  CLIPPING

================================================================================
*/

// save clip area and backup it insode function
// using to make special clipping
#define Draw2D_BackUpClipArea() local float clipDO, clipPx, clipPy, clipSx, clipSy; if (Draw2D_Clip) { clipPx = Draw2D_ClipPosX; clipPy = Draw2D_ClipPosY; clipSx = Draw2D_ClipSizeX; clipSy = Draw2D_ClipSizeY; } clipDO = Draw2D_Clip 
#define Draw2D_RestoreClipArea() if (clipDO) Draw2D_SetClipArea(clipPx, clipPy, clipSx - clipPx, clipSy - clipPy); else Draw2D_ResetClipArea()

// set clipping area
void Draw2D_SetClipArea(float tX, float tY, float tWidth, float tHeight)
{
	Draw2D_Clip = 1;
	Draw2D_ClipPosX = tX;
	Draw2D_ClipPosY = tY;
	Draw2D_ClipSizeX = tX + tWidth;
	Draw2D_ClipSizeY = tY + tHeight;
	
	drawsetcliparea(tX*Draw2D_Scale_x, tY*Draw2D_Scale_y, tWidth*Draw2D_Scale_x, tHeight*Draw2D_Scale_y);
}

// clip existing clip area to be smaller or equal than current
void Draw2D_ClipClipArea(float tX, float tY, float tWidth, float tHeight)
{
	if (!Draw2D_Clip)
	{
		Draw2D_SetClipArea(tX, tY, tWidth, tHeight);
		return;
	}
	
	Draw2D_ClipPosX = max(Draw2D_ClipPosX, tX);
	Draw2D_ClipPosY = max(Draw2D_ClipPosX, tY);
	Draw2D_ClipSizeX = min(Draw2D_ClipSizeX, tX + tWidth);
	Draw2D_ClipSizeY = min(Draw2D_ClipSizeY, tY + tHeight);
	
	drawsetcliparea(tX*Draw2D_Scale_x, tY*Draw2D_Scale_y, tWidth*Draw2D_Scale_x, tHeight*Draw2D_Scale_y);
}

// reset clip area
void() Draw2D_ResetClipArea =
{
	if (!Draw2D_Clip)
		return;
	drawresetcliparea();
	Draw2D_Clip = 0;
}

// start
void Draw2D_Start(string tFontName, float tWidth, float tHeight)
{
	Draw2D_Scale_x = cvar("vid_conwidth")/tWidth;
	Draw2D_Scale_y = cvar("vid_conheight")/tHeight;
	Draw2D_Scale_z = 0;
	Draw2D_SetFont(tFontName);
}

/*
================================================================================

  MULTILINE TEXT PARSER

================================================================================
*/

#define Draw2D_MLT_Active() mlt_pos < mlt_len
void Draw2D_MLT(string tText, string tTextFont, vector tTextFontSize, float tTextDrawFlag, vector tArea)
{
	mlt_string = tText;
	mlt_pos = 0;
	mlt_newline = 0;
	mlt_len = strlen(mlt_string);
	mlt_font = tTextFont;
	mlt_fontSize = tTextFontSize;
	mlt_fontDrawFlag = tTextDrawFlag;
	mlt_area = tArea;
}

void() Draw2D_MLT_NextWord =
{
	float tStart, tCheckNewLine;
	vector tSize;
	string tChar;

	mlt_newline = 0;
	// get word start
	tStart = mlt_pos;
	while(Draw2D_MLT_Active())
	{
		tChar = substring(mlt_string, mlt_pos, 1);
		if (tChar != " " && tChar != "	" && tChar != "+" && tChar != "-")
			break;
		mlt_pos++;	
	}
	// check if we got newline
	mlt_skipped = substring(mlt_string, tStart, mlt_pos - tStart);
	mlt_skippedpos = mlt_pos;
	if (tChar == "\n")
	{
		mlt_pos = mlt_pos + 1;
		mlt_newline = 1;
		mlt_word = "";
		return;
	}
	// check if we got \n special symbol
	if (tChar == "\\" && substring(mlt_string, mlt_pos+1, 1) == "n")
	{
		mlt_pos = mlt_pos + 2;
		mlt_newline = 1;
		mlt_word = "";
		return;
	}
		
	// get word
	tStart = mlt_pos;
	tCheckNewLine = 0;
	while(Draw2D_MLT_Active())
	{
		tChar = substring(mlt_string, mlt_pos, 1);
		if (tChar == "\n") // got a new line
			break;
		if (tChar == "n" && tCheckNewLine) // got a new line
		{
			mlt_pos--;
			break;
		}
		tCheckNewLine = 0;
		if (tChar == "\\")
			tCheckNewLine = 1;
		else if (tChar == " " || tChar == "	" || tChar == "+" || tChar == "-")
			break;
		mlt_pos++;
	}
	// get word
	mlt_word = substring(mlt_string, tStart, mlt_pos - tStart);
	mlt_token = strcat(mlt_skipped, mlt_word);
}

float() Draw2D_MLT_GetLine =
{
	float tStart, tLen, tLeftSize, tFullSize, tCharLen;
	vector tSize;
	
	mlt_line = "";
	mlt_linesize_x = 0;
	mlt_linesize_y = mlt_fontSize_y; // todo: vertical text
	tLeftSize = mlt_area_x;
	tFullSize = mlt_area_x;
	if (!Draw2D_MLT_Active())
		return 0;
	while(Draw2D_MLT_Active())
	{
		tStart = mlt_pos;
		Draw2D_MLT_NextWord();
		if (mlt_newline)
			break;
		tSize = Draw2D_GetTextSize(mlt_token, mlt_font, mlt_fontSize, mlt_fontDrawFlag); 
		// word does fill line and area
		if (tSize_x < tLeftSize) 
		{
			tLeftSize = tLeftSize - tSize_x;
			mlt_line = strcat(mlt_line, mlt_token);
			mlt_linesize_x = mlt_linesize_x + tSize_x;
			if (tSize_x == tLeftSize) // no more adding
				break;
			continue;
		}
		// word does not fill area but do line - apply word next time
		if (tSize_x <= tFullSize) 
		{
			// skip all spacers before this word
			mlt_pos = mlt_skippedpos;
			break;
		}
		// word does not fill line and area - wrap it
		tFullSize = tLeftSize;
		tLen = strlen(mlt_token);
		tStart = 1;
		tSize = Draw2D_GetTextSize(substring(mlt_token, 0, 1), mlt_font, mlt_fontSize, mlt_fontDrawFlag);
		tLeftSize = tLeftSize - tSize_x;
		while(tLeftSize > 0)
		{
			tSize = Draw2D_GetTextSize(substring(mlt_token, tStart, 1), mlt_font, mlt_fontSize, mlt_fontDrawFlag); 
			if (tSize_x > tLeftSize) // skip rest
				break;
			tLeftSize = tLeftSize - tSize_x;
			tStart++;
		}
		mlt_pos = mlt_pos - (tLen - tStart); // round back
		mlt_line = strcat(mlt_line, substring(mlt_token, 0, tStart));
		mlt_linesize_x = mlt_linesize_x + (tFullSize -  tLeftSize);
		break;
	}
	return 1;
}
