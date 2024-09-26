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
/*void UpdateMobileEntChain() =
{
	local entity e;
	list_mobileentchain = e = findchainfloat(mobile, TRUE);
	while(e)
	{
		e.mobileentchain = e.chain;
		e = e.chain;
	}
}*/

void MobileEntChain_Add(entity e) =	{	list_mobileentchain = LinkedList_Add(e, list_mobileentchain, mobileentchain, mobileentchain_prev);	}

void MobileEntChain_Remove(entity e) =	{	list_mobileentchain = LinkedList_Remove(e, list_mobileentchain, mobileentchain, mobileentchain_prev);	}

float GetScoreFlag(float SCORE_FLAG) =
{
	local float count, FLAG; 

	FLAG = 1;
	for(count = 0; count < SCORE_FLAG; count++)
		FLAG = FLAG*2;	

	return FLAG;
}