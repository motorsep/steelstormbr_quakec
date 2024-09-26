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
//void UpdateRadarEntChain() =	{	list_radarchain = UpdateLinkedList(showonradar, true, radarchain);	}
void ShotChain_Add(entity e) =	{	list_shotchain = LinkedList_Add(e, list_shotchain, shotchain, shotchain_prev);	}
void ShotChain_Remove(entity e) =	{	list_shotchain = LinkedList_Remove(e, list_shotchain, shotchain, shotchain_prev);	}

void RadarEntChain_Add(entity e) =		{	list_radarchain = LinkedList_Add(e, list_radarchain, radarchain, radarchain_prev);	}
void RadarEntChain_Remove(entity e) =	{	list_radarchain = LinkedList_Remove(e, list_radarchain, radarchain, radarchain_prev);	}

//void UpdateCameraShakeChain() =	{	list_camerashakechain = UpdateLinkedList(shakecamera, true, camerashakechain);	}
void CameraShakeChain_Add(entity e) =		{	list_camerashakechain = LinkedList_Add(e, list_camerashakechain, camerashakechain, camerashakechain_prev);	}
void CameraShakeChain_Remove(entity e) =	{	list_camerashakechain = LinkedList_Remove(e, list_camerashakechain, camerashakechain, camerashakechain_prev);	}

//void UpdateCellChain() =	{	list_cellchain = UpdateLinkedList(class, CLASS_CELL, cellchain);	}
//void CellChain_Add(entity e) =			{	list_cellchain = LinkedList_Add(e, list_cellchain, cellchain, cellchain_prev);	}
//void CellChain_Remove(entity e) =		{	list_cellchain = LinkedList_Remove(e, list_cellchain, cellchain, cellchain_prev);	}

//void UpdateOwnerlessChain() =	{	list_ownerlesschain = UpdateLinkedList(noowner, true, ownerlesschain);	}
void OwnerlessChain_Add(entity e) =		{	list_ownerlesschain = LinkedList_Add(e, list_ownerlesschain, ownerlesschain, ownerlesschain_prev);	}
void OwnerlessChain_Remove(entity e) =	{	list_ownerlesschain = LinkedList_Remove(e, list_ownerlesschain, ownerlesschain, ownerlesschain_prev);	}

//void UpdateHasAvelocityChain() =	{	list_hasavelocitychain = UpdateLinkedList(hasavelocity, true, hasavelocitychain);	}
void HasAvelocityChain_Add(entity e) =		{	list_hasavelocitychain = LinkedList_Add(e, list_hasavelocitychain, hasavelocitychain, hasavelocitychain_prev);	}
void HasAvelocityChain_Remove(entity e) =	{	list_hasavelocitychain = LinkedList_Remove(e, list_hasavelocitychain, hasavelocitychain, hasavelocitychain_prev);	}

void MenuChain_Add(entity e) =		{	list_menuchain = LinkedList_Add(e, list_menuchain, menuchain, menuchain_prev);	}
void MenuChain_Remove(entity e) =	{	list_menuchain = LinkedList_Remove(e, list_menuchain, menuchain, menuchain_prev);	}

void HittableChain_Add(entity e) =		{	list_hittablechain = LinkedList_Add(e, list_hittablechain, hittablechain, hittablechain_prev);	e.hittable = true;	}
void HittableChain_Remove(entity e) =	{	list_hittablechain = LinkedList_Remove(e, list_hittablechain, hittablechain, hittablechain_prev);	e.hittable = false;	}

void CanShootChain_Add(entity e) =		{	list_canshootchain = LinkedList_Add(e, list_canshootchain, canshootchain, canshootchain_prev);	}
void CanShootChain_Remove(entity e) =	{	list_canshootchain = LinkedList_Remove(e, list_canshootchain, canshootchain, canshootchain_prev);	}

void MissingPathConnectionsChain_Add(entity e) =	{	list_missingpathconnectionschain = LinkedList_Add(e, list_missingpathconnectionschain, missingpathconnectionschain, missingpathconnectionschain_prev);	}
void MissingPathConnectionsChain_Remove(entity e) =	{	list_missingpathconnectionschain = LinkedList_Remove(e, list_missingpathconnectionschain, missingpathconnectionschain, missingpathconnectionschain_prev);	}

//void DeletedPathChain_Add(entity e) =		{	list_deletedpathchain = LinkedList_Add(e, list_deletedpathchain, deletedpathchain, deletedpathchain_prev);	}
//void DeletedPathChain_Remove(entity e) =	{	list_deletedpathchain = LinkedList_Remove(e, list_deletedpathchain, deletedpathchain, deletedpathchain_prev);	}

void ControlEntChain_Add(entity e) =		{	list_controlentchain = LinkedList_Add(e, list_controlentchain, controlentchain, controlentchain_prev);	}
void ControlEntChain_Remove(entity e) =		{	list_controlentchain = LinkedList_Remove(e, list_controlentchain, controlentchain, controlentchain_prev);	}

void PointTextChain_Add(entity e) =		{	list_pointtextchain = LinkedList_Add(e, list_pointtextchain, pointtextchain, pointtextchain_prev);	}
void PointTextChain_Remove(entity e) =		{	list_pointtextchain = LinkedList_Remove(e, list_pointtextchain, pointtextchain, pointtextchain_prev);	}

void CenterPrintChain_Add(entity e) =		{	list_centerprintchain = LinkedList_Add(e, list_centerprintchain, centerprintchain, centerprintchain_prev);	}
void CenterPrintChain_Remove(entity e) =		{	list_centerprintchain = LinkedList_Remove(e, list_centerprintchain, centerprintchain, centerprintchain_prev);	}

void ObjectiveTextChain_Add(entity e) =		{	list_objectivetextchain = LinkedList_Add(e, list_objectivetextchain, objectivetextchain, objectivetextchain_prev);	}
void ObjectiveTextChain_Remove(entity e) =		{	list_objectivetextchain = LinkedList_Remove(e, list_objectivetextchain, objectivetextchain, objectivetextchain_prev);	}

void NewMapObjectChain_Add(entity e) =		{	list_newmapobjectchain = LinkedList_Add(e, list_newmapobjectchain, newmapobjectchain, newmapobjectchain_prev);	}
void NewMapObjectChain_Remove(entity e) =		{	list_newmapobjectchain = LinkedList_Remove(e, list_newmapobjectchain, newmapobjectchain, newmapobjectchain_prev);	}

void ReticleChain_Add(entity e) =		{	list_reticlechain = LinkedList_Add(e, list_reticlechain, reticlechain, reticlechain_prev);	}
void ReticleChain_Remove(entity e) =		{	list_reticlechain = LinkedList_Remove(e, list_reticlechain, reticlechain, reticlechain_prev);	}