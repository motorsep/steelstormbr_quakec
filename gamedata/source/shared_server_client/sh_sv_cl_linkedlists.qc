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
void PlayerChain_Add(entity e) =		{	list_playerchain = LinkedList_Add(e, list_playerchain, playerchain, playerchain_prev);	}
void PlayerChain_Remove(entity e) =		{	list_playerchain = LinkedList_Remove(e, list_playerchain, playerchain, playerchain_prev);	}

void TagEntChain_Add(entity h, entity e) =		{	h.list_tagentchain = LinkedList_Add(e, h.list_tagentchain, tagentchain, tagentchain_prev);	}
void TagEntChain_Remove(entity h, entity e) =	{	h.list_tagentchain = LinkedList_Remove(e, h.list_tagentchain, tagentchain, tagentchain_prev);	}

void AIChain_Add(entity e) =	{	LinkedList_Add(e, list_aichain, aichain, aichain_prev);	}
void AIChain_Remove(entity e) = {	LinkedList_Remove(e, list_aichain, aichain, aichain_prev);	}