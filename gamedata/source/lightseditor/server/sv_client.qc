void ClientKill() = {}
	
void ClientConnect() = {}
	
void ClientDisconnect() = {}
	
void PlayerPreThink() = {}
	
void PlayerPostThink() = {}
	
void info_player_start()        = {}
void info_player_start2()       = {}
void info_player_deathmatch()   = {}
void info_player_coop()         = {}
	
void PutClientInServer() =
{
	local entity spawn_spot;             // This holds where we want to spawn
	spawn_spot = find (world, classname, "info_player_start"); // Find it :)
	
	self.classname = "player";           // I'm a player!
	self.health = self.max_health = 100; // My health (and my max) is 100
	self.takedamage = DAMAGE_AIM;        // I can be fired at
	self.solid = SOLID_SLIDEBOX;         // Things sort of 'slide' past me
	self.movetype = MOVETYPE_WALK;       // Yep, I want to walk.
	self.flags = FL_CLIENT;              // Yes, I'm a client.
	
	setorigin(self, spawn_spot.origin + '0 0 1'); // Move to the spawnspot location
	self.angles = spawn_spot.angles;     // Face the angle the spawnspot indicates
	self.fixangle = TRUE;                // Turn this way immediately
	
	setmodel (self, "progs/player.mdl"); // Set my player to the player model
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX); // Set my size
	
	self.view_ofs = '0 0 22';            // Center my view
	self.velocity = '0 0 0';             // Stop any old movement
}
