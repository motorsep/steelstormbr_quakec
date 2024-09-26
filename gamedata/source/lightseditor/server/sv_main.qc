void main() = {}

void precaches() =
{
	precache_model ("progs/player.mdl");
}
	
void worldspawn() =
{
	precaches();
	LightStyles_setup();
}

void SetNewParms() = {}
	
void SetChangeParms() = {}
	
void StartFrame() = {}
	