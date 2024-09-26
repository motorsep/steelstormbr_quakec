////////////////////////////////////////
// Blood Omnicide source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

#ifndef VUTIL_CMD
#define VUTIL_CMD 1

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

#define command void(string commandname, string cmdstr, float numparms, float is_help, float is_server)
#define commandRedirect(c) c(commandname, cmdstr, numparms, is_help, is_server)
#define callCommand(c) c("", "", 0, 0, 0)

command null_command = { };
var command CALLCMD;

#define MAX_COMMANDS 64
nosave float NUM_COMMANDS;
nosave string CommandNames[MAX_COMMANDS];
nosave string CommandDescriptions[MAX_COMMANDS];

#define null4 null_command, null_command, null_command, null_command
#define null16 null4, null4, null4, null4
command CommandFunctions[MAX_COMMANDS] = { null16, null16 };
#undef null16
#undef null4

////////////////////////////////////////
// CODE
////////////////////////////////////////

#ifdef TARG_GAMEPROGS
	#define com_print(s) sprint(self, s)
#else
	#define com_print(s) print(s)
#endif

command HelpCommand =
{
	float tPos;
	
	com_print("COMMAND LISTING:\n");
	for (tPos = 0; tPos < NUM_COMMANDS; tPos++)
	{
		if (CommandDescriptions[tPos] == "hidden")
			continue;
		com_print(strcat(" ^3", CommandNames[tPos], "^7: "));
		com_print(strcat(CommandDescriptions[tPos], "\n"));
	}
}

float RegisterLocalCommand(string tCmdName, command tCmd, string tDesc)
{
	if (NUM_COMMANDS >= MAX_COMMANDS)
	{
		warning(strcat("command slots overflow, maximum number of commands is ", ftos(MAX_COMMANDS)));
		return 0;
	}
	CommandNames[NUM_COMMANDS] = tCmdName;
	CommandFunctions[NUM_COMMANDS] = tCmd;
	CommandDescriptions[NUM_COMMANDS] = tDesc;
	NUM_COMMANDS++;
	return 1;
}

void RegisterCommand(string tCmdName, command tCmd, string tDesc)
{
	if (!RegisterLocalCommand(tCmdName, tCmd, tDesc))
		return;
	#ifdef TARG_CLIENTPROGS
	registercmd(tCmdName);
	#endif
	#ifdef TARG_MENUPROGS
	localcmd("alias \"", tCmdName, "\" \"menu_cmd ", tCmdName, " $*\"\n");
	#endif
}

float CommandExists(string tCmdName)
{
	float tPos;
	for (tPos = 0; tPos < NUM_COMMANDS; tPos++)
		if (CommandNames[tPos] == tCmdName)
			return 1;
	return 0;
}

string GetCommandDescription(string tCmdName)
{
	float tPos;
	for (tPos = 0; tPos < NUM_COMMANDS; tPos++)
		if (CommandNames[tPos] == tCmdName)
			return CommandDescriptions[tPos];
	return "no info";
}

float ParseCommand(string tStr) =
{
	float tPos;
	float tNumParms;
	float tIsServer;
	string tCommand;
	
	tNumParms = tokenize(tStr);
	tCommand = argv(0);
	
	if (!tNumParms)
		return 0;
	
	#ifdef TARG_GAMEPROGS
	if (etof(self) == 1)
		tIsServer = 1;
	else
		tIsServer = 0;
	#else
		#ifdef TARG_CLIENTPROGS
			tIsServer = isserver();
		#else
			tIsServer = 0; // menu progs
		#endif
	#endif
	// builtin commands
	if (tCommand == "?") 
	{
		HelpCommand(tCommand, tStr, tNumParms, 0, tIsServer);
		return 1;
	}
	// find command
	for (tPos = 0; tPos < NUM_COMMANDS; tPos++)
		if (CommandNames[tPos] == tCommand)
			break;
	// run command
	if (tPos < NUM_COMMANDS)
	{
		CALLCMD = CommandFunctions[tPos];
		CALLCMD(tCommand, tStr, tNumParms, (argv(1) == "?"), tIsServer);
		return 1;
	}
	return 0;	
}

#ifdef TARG_GAMEPROGS
// automatically creates aliases for commands, useful on SVQC
void() CreateCommandAliases =
{
	string tAlias, tCommand;
	float tPos;
	for (tPos = 0; tPos < NUM_COMMANDS; tPos++)
	{
		tCommand = CommandNames[tPos];
		tAlias = strcat("alias \"", tCommand, "\" \"cmd \"", tCommand, "\" $*\"\n");
		stuffcmd(self, tAlias);
	}
}
#endif

#endif