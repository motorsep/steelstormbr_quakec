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
string RandomQuitMessage() =
{
	local float r, nummessages, translate;
	local string filename, message, str_msg1, str_msg2, str_msg3, str_msg4;
	
	translate = skiptranslation;
	skiptranslation = false;
	
	filename = __FUNC__;
	buf_localizerandomquitmessage = InitializeNonstandardTranslations(buf_localizerandomquitmessage, filename, false);
	
	str_msg1	= Localize("Don't be a wussy...", buf_localizerandomquitmessage);
	str_msg2	= Localize("Do you kiss your mother with that mouth?", buf_localizerandomquitmessage);
	str_msg3	= Localize("Quitters never win.", buf_localizerandomquitmessage);
	str_msg4	= Localize("Sorry there was no easy mode for you.", buf_localizerandomquitmessage);
	WriteNonstandardTranslations(buf_localizerandomquitmessage, filename, false, false);
	
	nummessages = 4;
	r = max(1, ceil(random()*nummessages));

	switch(r)
	{
		case 1:		message = str_msg1;		break;
		case 2:		message = str_msg2;		break;
		case 3:		message = str_msg3;		break;
		case 4:		message = str_msg4;		break;
		case 5:		message = "";		break;
		case 6:		message = "";		break;
		case 7:		message = "";		break;
		case 8:		message = "";		break;
		case 9:		message = "";		break;
		case 10:	message = "";		break;
	}
	
	skiptranslation = translate;
	
	return message;
}