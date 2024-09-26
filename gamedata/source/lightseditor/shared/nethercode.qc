////////////////////////////////////////
// NetherCode mini low level scripting language source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

/*
DOCS 

NetherCode is special language that is designed 
for low-level scripting it is fast and quite simple

Precompiler:
	 none at the moment
	 planned:
	   $something = <expression>;
	       expands to var('something', expression);
	   $something = $somethingelse = <expression>;
	       expands to var('something', var('somethingelse', expression));
	   :labelname
	       places a label statement
	   goto labelname
	       generates a seek statement (back or forward based on label pos)
		   
Syntax:
      expression1;expression2;etc...
	  
Expression types:
	builtin or user function call - somefunc(parm1,parm2,parm3) - up to 8 parms

Default builtins:

 FIXME: UPDATE!
 var('varname'[,'newvalue'])    		- operating with script-space vars, one parm - returns current var value, two parms - sets a new value for var
 freevar('varname')					- free var
 isvar('varname')						- return 1 is var exists, 0 if not
 temp(num,[,'newvalue'])             	- operating with temporary buffer, one parm - returns current local value, two parms - sets a new value for local
 print('string','string2' ...)           - print message to console
 add(x, y[,...])                         - returns a sum of all arguments
 sub(x, y[,...])                         - returns a substract of all arguments
 mul(x, y[,...])                         - returns a multiplication of all arguments
 div(x, y[,...])                         - returns a div of all arguments
 floor(x)                                - lower round
 sqrt(x)                                 - returns a square root from x
 pow(x, y)                               - returns x raised to power y
 sin(x)                                  - returns sin of x
 cos(x)                                  - returns cos of x
 flagbit(bitnum)                         - returns flag value for bit num, think flagbit(4) = 16
 flagadd(value,bitflag1[,...])           - add bitflags to a value
 flagrem(value,bitflag1[,...])           - removes flags from value
 bitshift(value,bitflag1[,...])          - shifts value by x bits
 float('val')                            - returns float value from 'val', if input is not numeric - returns 0
 int('val')                              - returns integer value from 'val', if input is not numeric - returns 0, returns 9 for 9.7 and -7 for -7.3
 bool('val')                             - returns boolean 0/1 value from 'val' 
 vector('val')                           - returns vector value from 'val', if input is not numeric - returns '0 0 0'
 vec([x,y,z])                            - builds 1d/2d/3d vector with x,y,z components, if no components are gives it returns null vector
 x(vector)                               - extracts x value from vector and returns it as float
 y(vector)                               - extracts y value from vector and returns it as float
 z(vector)                               - extracts z value from vector and returns it as float
 xy(vector)                              - extracts xy vector from 3d vector
 xz(vector)                              - extracts xz vector from 3d vector
 yz(vector)                              - extracts yz vector from 3d vector
 vlen(vector)                            - returns vector length
 abs('val')                              - returns absolute value
 ceil(x)                                 - upper round
 floor(x)                                - lower round
 rint(x)                                 - round-to-nearest
 natural(x)                              - natural frac for norm/base
 ascii('string'[,pos])                   - extract ASCII code from char (of first char of entered string), is pos is set it can override char position in entered string
 chr('ascii_code')                       - returns a character from ascii code
 eq('x','y')                             - logic function - returns 1 if x is equal to y, otherwise returns 1
 gr('x','y')                             - logic function -returs 1 if x is greater than y, otherwise returns 1
 le('x','y')                             - logic function - returs 1 if x is lesser than y, otherwise returns 1
 groreq('x','y')                         - logic function - returs 1 if x is greater or equal than y, otherwise returns 1
 leoreq('x','y')                         - logic function - returs 1 if x is greater or equal than y, otherwise returns 1
 not('x')                                - logic not
 and('x','y'...)                         - logic and for up to 8 parms
 or('x','y')                             - logic or
 bitand('x','y')                         - bitwise and
 bitor('x','y')                          - bitwise or
 lif('condition','x','y')                - returns x if condition != 0, otherwize returns y
 pick('index','a'[,'b'...])            	- return certain parm based on index, a for 1, b for 2 etc..., up to 7
 indexof('value','a'[,'b'...])			- return index (1 - 7) of parm that matches value, return 0 if not found
 min('val1','val2',...)                  - returns minimal value from supplied arguments
 max('val1','val2',...)                  - returns maximal value from supplied arguments
 bound('min','val','max')                - bounds value
 strcat('string','string2' ...)          - returns all args concentenated
 implode('separator','string2' ...)      - returns all args concentenated with 'separator' glue
 mid('string1',start,length)             - returns middle part of string
 left('string1',length)                  - returns left part of string
 right('string1',length)                 - returns right part of string
 len('string')                           - returns length of string
 ucase('string1'string2' ...)            - returns all args concentenated and lowered
 lcase('string1'string2' ...)            - returns all args concentenated and lowered
 cmd('string1','string2' ...)            - stuff message into console, return whole string builded from varargs 
 cvar('string1')                         - returns string value of cvar
 cvar_set('cvar','value');               - change cvar value
 fileattr('filename','attr');			  - get file attribute
 loadfile(filename);                     -  load a file as buffer and returns it
 newbuf(buf)                             - create an empty buf
 bufsize(buf)                            - get a size of buf
 bufstr(buf, index [,new_value])         - set/get string from buf
 bufadd(buf, string[,keep_order])        - add a string to buffer
 tokenbuf([getout])                      - returns a handle to tokenbuffer, if getout is 1 it will return a copy of it so futher tokenizing will not change it (tokenbuffer will be cleaned after that)
 bufsort(buf, sortpower[, backward])     - sorts a buffer
 parsebuf(buf, parsefunc[,moreparms])    - parses a buffer with 'parsefunc' being called on each line, parsefunc should be Script($buf,$line[,moreparms])
 freebuf(buf)                            - unloads a buffer
 return([value])                         - sets output value and stop script executing
 
 // parsebuf(buf, parsefunc[,additional parms])
// parses a buffer with 'parsefunc' being called on each line
// parsefunc should be Script($buf,$line[,additional parms])
*/

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

// prototypes 
#define ncd_builtin string(string NCD_PARM1, string NCD_PARM2, string NCD_PARM3, string NCD_PARM4, string NCD_PARM5, string NCD_PARM6, string NCD_PARM7, string NCD_PARM8)
void NetherCode_Warning(string s, float print_dump);
string NetherCode_SystemFunctionName(float builtin_num);
void NetherCode_RegisterSystemFunction(string n, ncd_builtin f);
float NetherCode_Compiler_FindFunctionOrScript(string token, float dowarning);
string NetherCode_Execute(float code, string vars);

// current process info
nosave float ncd_currentProgNum;
nosave string ncd_currentProg;
nosave float ncd_currentProgFunctions;
nosave float ncd_currentProgFuncBodies;
nosave float ncd_currentProgFuncParms;
nosave float ncd_currentProgNumFunctions;
nosave float ncd_currentProgBuiltins;
nosave float ncd_currentProgGlobals;
nosave float ncd_currentProgNumGlobals;
nosave float ncd_currentProgGlobalNames;
var float(float function_index) ncd_currentProgBuiltinGetQC;
nosave float ncd_currentProgNumBuiltins;
#define NetherCode_CheckProg(p) (p >= 0 && p < ncd_progs && ncd_prog[p] != "")
#define NetherCode_SetProg(float prog) if (ncd_currentProgNum != prog) { ncd_currentProgNum = prog; ncd_currentProg = ncd_prog[prog]; ncd_currentProgGlobals = ncd_progglobals[prog]; ncd_currentProgGlobalNames = ncd_progglobalnames[prog]; ncd_currentProgFunctions = ncd_progfunctions[prog]; ncd_currentProgFuncBodies = ncd_progfuncbodies[prog]; ncd_currentProgFuncParms = ncd_progfuncparms[prog]; ncd_currentProgBuiltins = ncd_progbuiltins[prog]; ncd_currentProgBuiltinGetQC = ncd_progbuiltinsQC[prog]; } ncd_currentProgNumGlobals = buf_getsize(ncd_currentProgGlobals); ncd_currentProgNumFunctions = buf_getsize(ncd_currentProgFunctions); ncd_currentProgNumBuiltins = buf_getsize(ncd_currentProgBuiltins);

// system functions table
#define NCD_MAX_FUNCTIONS	128 // VorteX: OK to increase this
nosave string ncd_func_names[NCD_MAX_FUNCTIONS];
ncd_builtin ncd_null = { NetherCode_Warning("NULL builtin should never be called!", 1); return ""; }
#define NCD_NULL8 ncd_null, ncd_null, ncd_null, ncd_null, ncd_null, ncd_null, ncd_null, ncd_null
#define NCD_NULL64 NCD_NULL8, NCD_NULL8, NCD_NULL8, NCD_NULL8, NCD_NULL8, NCD_NULL8, NCD_NULL8, NCD_NULL8
ncd_builtin ncd_func_f[NCD_MAX_FUNCTIONS] = { NCD_NULL64, NCD_NULL64 };
nosave float ncd_num_functions;

// nethercode compiler
nosave string ncdc_tokenline;     // currently parsed line
nosave float ncdc_numtokens;      // tokens in line
nosave float ncdc_tokenpos;       // token position
nosave string ncdc_token;         // token
nosave float ncdc_errorcode;      // error state
nosave string ncdc_statement;     // statement output
nosave string ncdc_compilation;   // compilation output
nosave float ncdc_functionindex;  // set by NetherCode_Compiler_FindFunctionOrScript
nosave float ncdc_warnings;       // number of warnings casted during compile

// function types
#define NCD_FUNCTION_INVALID		-1
#define NCD_FUNCTION_BUILTIN		0 	// system builtin
#define NCD_FUNCTION_PROGBUILTIN	1	// prog's builtin
#define NCD_FUNCTION_SCRIPT			2	// NCD script

// nethercode running
nosave float ncde_running;      // defines that nethercode executor is running
nosave string ncde_varstream;   // lump containing variables that will be put into execution stream
nosave string ncde_tempstream;  // lump containing temps (paremeters) that will be put into execution stream

// nethercode memory struct
nosave float ncde_script;			// buffer index
nosave string ncde_statement;    	// statement being executed
nosave float ncde_statement_index;
nosave string ncde_token;     		// current token
nosave vector ncde_state;     		// current token pos, number of tokens in current line, error code
nosave entity ncd_self;       		// entity that initiates script
nosave float ncd_func;     		// currently running builtin
var ncd_builtin ncd_funcf;	// found builtin function
nosave string ncde_return; 		// return value

// globals
#define NETHERCODE_MAX_VARS 32 // VorteX: OK to increase this
nosave string ncd_varbuffer_names[NETHERCODE_MAX_VARS];
nosave string ncd_varbuffer_values[NETHERCODE_MAX_VARS];
nosave float ncd_variables;

// progs
#define NCD_MAX_PROGS 4 // VorteX: OK to increase this
string ncd_prog[NCD_MAX_PROGS];
float ncd_progglobals[NCD_MAX_PROGS];
float ncd_progglobalnames[NCD_MAX_PROGS];
float ncd_progfunctions[NCD_MAX_PROGS];
float ncd_progfuncbodies[NCD_MAX_PROGS];
float ncd_progfuncparms[NCD_MAX_PROGS];
float ncd_progbuiltins[NCD_MAX_PROGS];
float(float function_index) ncd_nullprogbuiltinQC = { ncd_funcf = ncd_null; return 1; }
float(float function_index) ncd_progbuiltinsQC[NCD_MAX_PROGS] = { ncd_nullprogbuiltinQC, ncd_nullprogbuiltinQC, ncd_nullprogbuiltinQC, ncd_nullprogbuiltinQC } // , ncd_nullprogbuiltinQC, ncd_nullprogbuiltinQC, ncd_nullprogbuiltinQC, ncd_nullprogbuiltinQC };
float ncd_progs;

// locals
#define NETHERCODE_MAX_TEMPS 16 // VorteX: OK to increase this
nosave string ncd_temps[NETHERCODE_MAX_TEMPS];
nosave float ncd_numtemps;

// numparms checking
#define NCD_SPCERR1 "- not enough parms, should be not less than "
#define NCD_SPCERR2 "- too many parms, should be not more than "
#define NCD_SAFEPARMCOUNT(pmin,pmax) if (ncd_numparms<pmin){NetherCode_Warning(strcat(NetherCode_SystemFunctionName(ncd_func),NCD_SPCERR1,ftos(pmin)),true);return null_string;}else if(ncd_numparms > pmax){NetherCode_Warning(strcat(NetherCode_SystemFunctionName(ncd_func),NCD_SPCERR2,ftos(pmax)),true);} 

// builtins, parms, return
nosave float ncd_numparms; // number of parms stuffed to current function
#define NCD_MAX_PARMS 8 // hardcoded, cannot be increased
#define NCD_PARMNUM ncd_numparms
#define NCD_PARM1F stof(NCD_PARM1)
#define NCD_PARM2F stof(NCD_PARM2)
#define NCD_PARM3F stof(NCD_PARM3)
#define NCD_PARM4F stof(NCD_PARM4)
#define NCD_PARM5F stof(NCD_PARM5)
#define NCD_PARM6F stof(NCD_PARM6)
#define NCD_PARM7F stof(NCD_PARM7)
#define NCD_PARM8F stof(NCD_PARM8)
#define NCD_PARM1V stov(NCD_PARM1)
#define NCD_PARM2V stov(NCD_PARM2)
#define NCD_PARM3V stov(NCD_PARM3)
#define NCD_PARM4V stov(NCD_PARM4)
#define NCD_PARM5V stov(NCD_PARM5)
#define NCD_PARM6V stov(NCD_PARM6)
#define NCD_PARM7V stov(NCD_PARM7)
#define NCD_PARM8V stov(NCD_PARM8)

// return macros
#define NCD_RETURN(s) return s;
#define NCD_RETURNF(s) return ftos(s); 
#define NCD_RETURNV(s) return vtos(s);
#define NCD_RETURN_NULL() return null_string;

// error codes
#define NCD_ERRORCODE_ERROR      -1
#define NCD_ERRORCODE_NO         0
#define NCD_ERRORCODE_ENDSCRIPT  1

// magic markers
#define NCM_CALL		"~?"
#define NCM_LEN			2 // length of markers
#define NCM_SCRIPTLINK	-1000

// 0 until everything is set up
float NetherCode_Initialized;
float NetherCode_Scripts;

////////////////////////////////////////
// CODE
////////////////////////////////////////

/*
================================================================================

   GLOBALS

================================================================================
*/

// convert var buffer into string
string() NetherCode_VariableBufferToStream =
{
	string l, n, v;
	float p;
	
	l = newlump();
	for (p = 0; p < ncd_variables; p++)
	{
		n = ncd_varbuffer_names[p];
		v = ncd_varbuffer_values[p];
		l = poplump(l, n);
		l = poplump(l, v);
	}
	return l;
}

void NetherCode_VariableBufferFromStream(string buffer_str) =
{
	float p, l, chunk_size;
	string varname, varvalue;
	
	ncd_variables = 0;
	if (buffer_str == "")
		return;
	l = strlen(buffer_str);
	p = lumpstart(buffer_str);
	while(p < l)
	{
		// read name and value
		chunk_size = lumpchunk(buffer_str, p);
		varname = lumpread(buffer_str, p, chunk_size);
		p = lumpstep(p, chunk_size);
		chunk_size = lumpchunk(buffer_str, p);
		varvalue = lumpread(buffer_str, p, chunk_size);
		p = lumpstep(p, chunk_size);
		// add global
		ncd_varbuffer_names[ncd_variables] = varname;
		ncd_varbuffer_values[ncd_variables] = varvalue;
		ncd_variables++;
	}
}

void NetherCode_SetVar(string varname, string varvalue)
{
	if (ncde_varstream == "")
		ncde_varstream = newlump();
	ncde_varstream = poplump(ncde_varstream, varname);
	ncde_varstream = poplump(ncde_varstream, varvalue);
}

string NetherCode_GetVar(string varname)
{
	float p;
	
	for (p = 0; p < ncd_variables; p++)
		if (ncd_varbuffer_names[p] == varname)
			return ncd_varbuffer_values[p];
	NetherCode_Warning(strcat("NetherCode_GetVar: no such var '", varname, "'"), 0);
	return "";
}

void NetherCode_SetParms(string p1, string p2, string p3, string p4, string p5, string p6, string p7, string p8)
{
	ncde_tempstream = makelump8(p1, p2, p3, p4, p5, p6, p7, p8);
}

void NetherCode_SetParms_FromTokenbuffer(float start, float numparms)
{
	float end;
	
	ncde_tempstream = newlump();
	for(end = start + numparms; start < end; start++)
		ncde_tempstream = poplump(ncde_tempstream, argv(start));
}

/*
================================================================================

   COMPILER

================================================================================
*/

// print script stach
string NetherCode_Compiler_PrintStack(string tErrorTokenColor)
{
	float tPos;
	string tToken;
	string tDump;
	float tCurTokenPos;

	tCurTokenPos = ncdc_tokenpos - 1;

	tDump = "--- nethercode dump ---\n";
	for (tPos = 0; tPos < ncdc_numtokens; tPos++)
	{
		tToken = argv(tPos);
		if (tPos == tCurTokenPos)
			tDump = strcat(tDump, tErrorTokenColor);
		tDump = strcat(tDump, strmaketoken(tToken), " "); 
		if (tPos == tCurTokenPos)
			tDump = strcat(tDump, "^7");
		if (tToken == ";")
			tDump = strcat(tDump, "\n");
	}
	tDump = strcat(tDump, "--- end nethercode dump ---\n^7");

	print(tDump);

	return tDump;
}

// cast warning
void NetherCode_Compiler_Warning(string tStr, float printstack)
{
	ncdc_warnings++;
	print(strcat("^3MenuScript compiler warning: ^7", tStr, "\n"));
	if (printstack)
		NetherCode_Compiler_PrintStack("^3");
}

// cast error
void NetherCode_Compiler_Error(string tStr)
{
	print(strcat("^1MenuScript compiler error: ^7", tStr, "\n"));
	NetherCode_Compiler_PrintStack("^1");
	ncdc_errorcode = NCD_ERRORCODE_ERROR;
}

// create tokens array
void NetherCode_Compiler_FillTokens(string tStr)
{
	ncdc_tokenline = tStr;
	ncdc_numtokens = tokenize(tStr);
	// check if number of linex exceeds tokenizer limit
	if (ncdc_numtokens >= 8192)
		NetherCode_Compiler_Warning(strcat("Script is too big, number of tokens exceeds ", ftos(8192)), 1);
}

// get next token
float() NetherCode_Compiler_ReadToken =
{
	// end of script
	if (ncdc_tokenpos >= ncdc_numtokens)
	{
		ncdc_errorcode = NCD_ERRORCODE_ENDSCRIPT;
		return false;
	}
	ncdc_token = argv(ncdc_tokenpos);
	ncdc_tokenpos++;
	return true;
}

// check if next token is equal
float NetherCode_Compiler_CheckNextToken(string tToken)
{
	// end of script?
	if (ncdc_tokenpos >= ncdc_numtokens)
		return false;
	// check
	return (argv(ncdc_tokenpos) == tToken);
}

// check next token to be as Token1 Or 2
float NetherCode_Compiler_CheckTokens(string tTokens)
{
	float tResult, tLen;
	string tNextToken;

	tResult = false;

	// end of script
	if (ncdc_tokenpos >= ncdc_numtokens)
		return false;
	// check
	tNextToken = argv(ncdc_tokenpos);
	tLen = strlen(tTokens) - 1;
	while(tLen >= 0)
	{
		if (strstr(tNextToken, substring(tTokens, tLen, 1)) >= 0)
		{
			tResult = true;
			break;
		}
		tLen--;
	}
	return tResult;
}

// get nextken and assume it to be certain value
float NetherCode_Compiler_ExpectTokens(string tTokens)
{
	if (!NetherCode_Compiler_CheckTokens(tTokens))
	{
		NetherCode_Compiler_Warning(strcat("Expected '", tTokens, "' but found '", ncdc_token, "'"), 1);
		return false;
	}
	return true;
}

// skip all parameters until statement ends
void() NetherCode_Compiler_SkipThisLine =
{
	while(ncdc_errorcode == NCD_ERRORCODE_NO)
	{
		if (ncdc_token == ";")
			break;
		NetherCode_Compiler_ReadToken();
	}
}

// find a function/script, sets ncdc_functionindex, returns one of NCD_FUNC_* values
float NetherCode_Compiler_FindFunctionOrScript(string token, float dowarning) =
{
	string fname, findname;
	float b;
	
	findname = substring(token, 0, 2);
	// system builtin
	if (findname == "s.") 
	{
		findname = substring(token, 2, 10000);
		for (b = 0; b < ncd_num_functions; b++)
			if (ncd_func_names[b] == findname)
				break;
		if (b >= ncd_num_functions)
		{
			if (dowarning)
				NetherCode_Compiler_Warning(strcat("unknown system builtin '", findname, "'"), 1);
			return NCD_FUNCTION_INVALID; // not found
		}
		ncdc_functionindex = b;
		return NCD_FUNCTION_BUILTIN;
	}
	// prog's builtin
	if (findname == "p.") // prog's builtin
	{
		findname = substring(token, 2, 10000);
		for (b = 0; b < ncd_currentProgNumBuiltins; b++)
			if (bufstr_get(ncd_currentProgBuiltins, b) == findname)
				break;
		if (b >= ncd_currentProgNumBuiltins)
		{
			if (dowarning)
				NetherCode_Compiler_Warning(strcat("unknown prog builtin '", findname, "'"), 1);
			return NCD_FUNCTION_INVALID; // not found
		}
		ncdc_functionindex = b;
		return NCD_FUNCTION_PROGBUILTIN;
	}	
	// nethercode script
	if (findname == "f.")
	{
		findname = substring(token, 2, 10000);
		for (b = 0; b < ncd_currentProgNumFunctions; b++)
			if (bufstr_get(ncd_currentProgFunctions, b) == findname)
				break;
		if (b >= ncd_currentProgNumFunctions)
		{
			if (dowarning)
				NetherCode_Compiler_Warning(strcat("unknown external script '", findname, "'"), 1);
			return NCD_FUNCTION_INVALID; // not found		
		}
		ncdc_functionindex = b;
		return NCD_FUNCTION_SCRIPT;
	}
	// detect automatically
	// check script function
	for (b = 0; b < ncd_currentProgNumFunctions; b++)
		if (bufstr_get(ncd_currentProgFunctions, b) == token)
			break;
	if (b < ncd_currentProgNumFunctions)
	{
		ncdc_functionindex = b;
		return NCD_FUNCTION_SCRIPT;
	}
	// check prog builtin
	for (b = 0; b < ncd_currentProgNumBuiltins; b++)
		if (bufstr_get(ncd_currentProgBuiltins, b) == token)
			break;
	if (b < ncd_currentProgNumBuiltins)
	{
		ncdc_functionindex = b;
		return NCD_FUNCTION_PROGBUILTIN;
	}
	// check system
	for (b = 0; b < ncd_num_functions; b++)
		if (ncd_func_names[b] == token)
			break;
	if (b >= ncd_num_functions)
	{
		if (dowarning)
			NetherCode_Compiler_Warning(strcat("unknown function '", token, "'"), 1);
		return NCD_FUNCTION_INVALID; // too bad
	}
	ncdc_functionindex = b;
	return NCD_FUNCTION_BUILTIN;
}

// parse builting call sequence
float() NetherCode_Compiler_ParseExpression =
{
	float ftype, numargs, expectnewarg;

	// check if ( follows this token, then it's a statement
	if (!NetherCode_Compiler_CheckNextToken("("))
		return 0;
		
	// find function, check if type is forced
	ftype = NetherCode_Compiler_FindFunctionOrScript(ncdc_token, 1);
	if (ftype == NCD_FUNCTION_BUILTIN)
		ncdc_statement = strcat(ncdc_statement, NCM_CALL, ftos(ncdc_functionindex));
	else if (ftype == NCD_FUNCTION_PROGBUILTIN)
		ncdc_statement = strcat(ncdc_statement, NCM_CALL, ftos(0 - ncdc_functionindex));
	else if (ftype == NCD_FUNCTION_SCRIPT)	
		ncdc_statement = strcat(ncdc_statement, NCM_CALL, "f", ftos(ncdc_functionindex));
	else // NCD_FUNCTION_INVALID
		return 0;

	// parse arguments
	numargs = 0;
	expectnewarg = true;
	NetherCode_Compiler_ReadToken();
	if (ncdc_token != "(")
		ncdc_statement = strcat(ncdc_statement, "()");
	else
	{
		ncdc_statement = strcat(ncdc_statement, "(");
		while(ncdc_errorcode == NCD_ERRORCODE_NO)
		{
			// get argument
			if (!NetherCode_Compiler_ReadToken())
				break;
			if (ncdc_token == ")" || ncdc_token == ";")
			{
				ncdc_statement = strcat(ncdc_statement, ncdc_token);
				break;
			}
			// check argument, parse
			if (ncdc_token == "(" ) // wrong builtin, skip
			{
				NetherCode_Compiler_Warning("'(' not expected", 1);
				while(ncdc_errorcode == NCD_ERRORCODE_NO)
				{
					if (!NetherCode_Compiler_ReadToken())
						break;
					if (ncdc_token == ")" || ncdc_token == ";")
						break;
				}
				continue;
			}
			if (ncdc_token == "," ) // null argument
			{
				if (expectnewarg)
				{
					numargs++;
					if (numargs > 1)
						ncdc_statement = strcat(ncdc_statement, ",");
					ncdc_statement = strcat(ncdc_statement, "''");
				}
				else
					expectnewarg = true;
				continue;
			}
			// read arg
			numargs++;
			if (numargs > 1)
				ncdc_statement = strcat(ncdc_statement, ",");
			if (!NetherCode_Compiler_ParseExpression())
			{
				ncdc_statement = strcat(ncdc_statement, strquickmaketoken(ncdc_token));
				if (NetherCode_Compiler_CheckTokens("("))
					NetherCode_Compiler_Warning(strcat("'", ncdc_token,"' is not a function"), 1);
			}
			expectnewarg = false;
		}
	}
	return 1;
}

// returns compiled script as string-buffer
float NetherCode_Compile(float prog, string code)
{
	float buf, buf2;
	string s;
	
	// prog info
	if (!NetherCode_CheckProg(prog))
		return -1;
	NetherCode_SetProg(prog)
	ncdc_warnings = 0;
	
	// check for '=' in content - script function linking definition
	if (substring(code, 0, 1) == "=")
	{
		code = substring(code, 1, 100000);
		buf = NetherCode_Compiler_FindFunctionOrScript(code, 0);
		if (buf != NCD_FUNCTION_SCRIPT)
		{
			NetherCode_Compiler_Warning(strcat("cant link function '", code, "'"), 0);
			return -1;
		}
		return NCM_SCRIPTLINK - ncdc_functionindex;
	}

	// create buffer, never allow 0 bufhandles (that shouldn't be happening anyway since many buffers are allocated before this)
	buf = buf_create();
	if (buf == 0)
	{
		NetherCode_Compiler_Warning("avoiding buffer 0", 0);
		buf2 = buf_create();
		buf_del(buf);
		buf = buf2;
	}
		
	// todo: run precompile pass
	ncdc_compilation = "";
	ncdc_errorcode = NCD_ERRORCODE_NO;
	ncdc_tokenpos = 0;
	ncdc_token = "";
	// begin compilation	
	NetherCode_Compiler_FillTokens(code);
	while(ncdc_errorcode == NCD_ERRORCODE_NO)
	{
		if (!NetherCode_Compiler_ReadToken())
			break;
		ncdc_statement = "";
		if (!NetherCode_Compiler_ParseExpression())
		{
			NetherCode_Compiler_SkipThisLine();
			continue;
		}
		bufstr_add(buf, ncdc_statement, 1);
	}
	
	bufstr_add(NetherCode_Scripts, ftos(buf), 0);
	return buf;
}

float() NetherCode_CompileWarnings =
{
	return ncdc_warnings;
}

/*
================================================================================

   EXECUTOR

================================================================================
*/

void NetherCode_PrintStack(string tErrorTokenColor)
{
	float p;
	string tToken;
	string d;

	d = "--- stack dump ---\n";
	for (p = 0; p < buf_getsize(ncde_script); p++)
	{
		if (p == ncde_statement_index)
			d = strcat(d, tErrorTokenColor);
		d = strcat(d, bufstr_get(ncde_script, p), " "); 
		if (p == ncde_statement_index)
			d = strcat(d, "^7");
		d = strcat(d, "\n");	
	}
	d = strcat(d, "--- end stack dump ---\n^7");
	print(d);
}

void NetherCode_Warning(string str, float print_stack)
{
	string s;
	
	if (ncd_func >= 0) // system function
		s = NetherCode_SystemFunctionName(ncd_func);
	else
		s = strcat("prog custom builtin #", ftos(0 - ncd_func));
	print(strcat("^3NetherCode Warning(", s, "): ", str, "^7\n"));
	if (print_stack)
		NetherCode_PrintStack("^3");
}

#define NetherCode_ReadToken if (ncde_state_x >= ncde_state_y) { ncde_state_z = NCD_ERRORCODE_ENDSCRIPT; ncde_token = ""; } else { ncde_token = argv(ncde_state_x); ncde_state_x++; }
float NetherCode_CheckToken(string tTokens)
{
	float tResult, tLen;
	string tNextToken;

	// --- check ---
	tResult = false;
	tNextToken = argv(ncde_state_x);
	tLen = strlen(tTokens) - 1;
	while(tLen >= 0)
	{
		if (strstr(tNextToken, substring(tTokens, tLen, 1)) >= 0)
			return true;
		tLen--;
	}
	return false;
}

// run statement code
string() NetherCode_Statement =
{
	var ncd_builtin f;
	string statementstr, v, p, p1, p2, p3, p4, p5, p6, p7, p8;
	float numparms, i;

	// FTEQCC bug?
	numparms = 0;
	p1 = "";
	p2 = "";
	p3 = "";
	p4 = "";
	p5 = ""; 
	p6 = "";
	p7 = "";
	p8 = "";
	
	statementstr = substring(ncde_token, NCM_LEN, 10000);
	// parse args
	NetherCode_ReadToken
	if (ncde_token == "(")
	{
		while(ncde_state_z == NCD_ERRORCODE_NO)
		{
			NetherCode_ReadToken
			if (ncde_token == ")" || ncde_token == ";")  // end of parms
				break;
			// if function passed as parm get it's value
			if (substring(ncde_token, 0, NCM_LEN) == NCM_CALL)
				p = NetherCode_Statement();
			else
				p = ncde_token;
			// add parm
				 if (numparms == 0)	p1 = p;
			else if (numparms == 1)	p2 = p;
			else if (numparms == 2)	p3 = p;
			else if (numparms == 3)	p4 = p;
			else if (numparms == 4)	p5 = p;
			else if (numparms == 5)	p6 = p;
			else if (numparms == 6)	p7 = p;
			else if (numparms == 7)	p8 = p;
			else NetherCode_Warning(strcat("too many parms(", ftos(numparms), ")"), true);
			numparms++;
			// skip ,
			if (NetherCode_CheckToken(","))
			{
				NetherCode_ReadToken
			}
		}
	}
	
	ncd_func = stof(statementstr);
	
	// call builtin
	if (ncd_func > 0) // system builtin
	{ 
		ncd_numparms = numparms;
		f = ncd_func_f[ncd_func];
		p = f(p1, p2, p3, p4, p5, p6, p7, p8);
		ncde_state_y = tokenize(ncde_statement);
		return p;
	}
	
	// prog builtin
	if (ncd_func < 0) 
	{
		ncd_numparms = numparms;
		ncd_currentProgBuiltinGetQC(0 - ncd_func);
		p = ncd_funcf(p1, p2, p3, p4, p5, p6, p7, p8);
		ncde_state_y = tokenize(ncde_statement);
		return p;
	}
	
	// script
	ncd_func = stof(substring(statementstr, 1, 1000));
	ncd_numparms = numparms;
	if (numparms <= 4)
		v = makelump4(p1, p2, p3, p4);
	else
		v = makelump8(p1, p2, p3, p4, p5, p6, p7, p8);
	i = stof(bufstr_get(ncd_currentProgFuncBodies, ncd_func));
	if (i < 0)
	{
		NetherCode_Warning(strcat("Undefined script '", bufstr_get(ncd_currentProgFunctions, ncd_func), "'"), 0);
		return "";
	}
	p = NetherCode_Execute(i, v);
	ncde_state_y = tokenize(ncde_statement);
	return p;
}

// execute inlined script in a stack of current script, used on nested script calls, fast
void NetherCode_ExecuteInline(float code) =
{
	float statements, oldScript, oldStatemetIndex;
	string oldStatement;
	vector oldState;
	
	// backup
	oldStatement = ncde_statement;
	oldState = ncde_state;
	oldScript = ncde_script;
	oldStatemetIndex = ncde_statement_index;
	
	// run
	ncde_script = code;
	statements = buf_getsize(ncde_script);
	for (ncde_statement_index = 0; ncde_statement_index < statements; ncde_statement_index++)
	{
		ncde_statement = bufstr_get(ncde_script, ncde_statement_index);
		ncde_state_x = 0;
		ncde_state_y = tokenize(ncde_statement);
		NetherCode_ReadToken
		// execute this statement
		if (substring(ncde_token, 0, NCM_LEN) != NCM_CALL)
		{
			NetherCode_Warning(strcat("Unknown statement '", ncde_token, "' on token #", ftos(ncde_state_x), ": ", ncde_statement), true);
			break;
		}
		NetherCode_Statement();
		if (ncde_state_z != NCD_ERRORCODE_NO)
			break; // break on error
	}
	
	// restore
	ncde_statement = oldStatement;
	ncde_state = oldState;
	ncde_script = oldScript;
	ncde_statement_index = oldStatemetIndex;
	tokenize(ncde_statement);
}

#define NetherCode_BackUpStack1 " \"" // FTEQCC bug
#define NetherCode_BackUpStack2 "\""
#define NetherCode_Execute_BackUpStack() \
		float i; \
		string temp; \
		string old_token = ncde_token; \
		float old_script = ncde_script; \
		string old_statement = ncde_statement; \
		float old_statement_index = ncde_statement_index; \
		vector old_state = ncde_state; \
		string old_return = ncde_return; \
		string old_vars; \
		old_vars = ""; \
		for (i = 0; i < ncd_numtemps; i++) \
		{ \
			temp = ncd_temps[i]; \
			old_vars = strcat(old_vars, NetherCode_BackUpStack1, temp, NetherCode_BackUpStack2); \
		}
		
#define NetherCode_Execute_RestoreStack() \
		ncd_numtemps = tokenize(old_vars); \
		for (i = 0; i < ncd_numtemps; i++) \
			ncd_temps[i] = argv(i); \
		ncde_token = old_token; \
		ncde_script = old_script; \
		ncde_statement = old_statement; \
		ncde_statement_index = old_statement_index; \
		ncde_state = old_state; \
		ncde_state_y = tokenize(ncde_statement); \
		ncde_state_z = NCD_ERRORCODE_NO; \
		ncde_return = old_return; 
		
#define NetherCode_Execute_SetTempsFromString(vars) \
		float l, c; \
		string v; \
		ncd_numtemps = 0; \
		l = strlen(vars); \
		i = lumpstart(vars); \
		while (i < l) \
		{ \
			c = lumpchunk(vars, i); \
			v = lumpread(vars, i, c); \
			i = lumpstep(i, c); \
			ncd_temps[ncd_numtemps] = v; \
			ncd_numtemps = ncd_numtemps + 1; \
		}
		
#define NetherCode_Execute_SetTemp(num,v) ncd_temps[num] = v; ncd_numtemps = max(ncd_numtemps, num+1);
		
// execute script
string NetherCode_Execute(float code, string vars) =
{
	float statements, saved;

	// backup old values
	saved = 0;
	if (ncde_running)
	{ 
		NetherCode_Execute_BackUpStack() 
		saved = 1;
	}
	
	// setup compiler tokenizer
	ncde_state_z = NCD_ERRORCODE_NO;
	if (ncde_state_y >= 4096)
		NetherCode_Warning("NetherCode: tokens num reached 4096, script could be truncated\n", 0);
	
	// set variables
	NetherCode_Execute_SetTempsFromString(vars)

	// execute
	ncde_running = ncde_running + 1;
	ncde_script = code;
	ncde_return = "";
	statements = buf_getsize(ncde_script);
	for (ncde_statement_index = 0; ncde_statement_index < statements; ncde_statement_index++)
	{
		ncde_statement = bufstr_get(ncde_script, ncde_statement_index);
		ncde_state_x = 0;
		ncde_state_y = tokenize(ncde_statement);
		NetherCode_ReadToken
		// execute this statement
		if (substring(ncde_token, 0, NCM_LEN) != NCM_CALL)
		{
			NetherCode_Warning(strcat("Unknown statement '", ncde_token, "' on token #", ftos(ncde_state_x), ": ", ncde_statement), true);
			break;
		}
		NetherCode_Statement();
		if (ncde_state_z != NCD_ERRORCODE_NO)
			break; // break on error
	}
	ncde_running = ncde_running - 1;
	v = ncde_return;
	
	// restore old values
	if (saved)
	{ 
		NetherCode_Execute_RestoreStack()
	}
	
	return v;
}

// returns result of script operations
string NetherCode_Run(float prog, entity e, float code)
{
	string global_stream, temp_stream, old_var_stream, return_code;
	entity old_ncd_self, oldself;
	float old_prog, saved;
	
	// read global/temp stream
	global_stream = ncde_varstream;
	ncde_varstream = "";
	temp_stream = ncde_tempstream;
	ncde_tempstream = "";
	
	// prog info
	if (!NetherCode_CheckProg(prog))
		return "";
	
	// transform back function link
	if (code <= NCM_SCRIPTLINK)
	{
		saved = ncd_progfuncbodies[prog];
		code = stof(bufstr_get(saved, fabs(code - NCM_SCRIPTLINK)));
	}

	// bad buffer?
	if (code <= 0) 
		return "";

	// check if nested call
	if (ncde_running)
	{	
		old_prog = ncd_currentProgNum;
		old_ncd_self = ncd_self;
		old_var_stream = NetherCode_VariableBufferToStream();
		saved = 1;
	}
	
	// set prog, globals, self entity and some other things
	NetherCode_SetProg(prog)
	NetherCode_VariableBufferFromStream(global_stream);
	oldself = self;
	ncd_self = e;
	self = e;
	return_code = NetherCode_Execute(code, temp_stream);
	self = oldself;
	
	// restore global buffer and prog if nested call
	if (ncde_running)
	{
		NetherCode_VariableBufferFromStream(old_var_stream);
		NetherCode_SetProg(old_prog) 
		ncd_self = old_ncd_self;
	}

	return return_code;
}

/*
================================================================================

   SYSTEM FUNCTIONS

================================================================================
*/

// var('varname',['newvalue'])
// get a variable value or set new value, returns 1 if allright, 0 if bad
ncd_builtin ncd_var = 
{ 
	float p, freevar;
	string str;
	
	NCD_SAFEPARMCOUNT(1, 2)
	// set new value
	if (NCD_PARMNUM > 1)
	{
		// try find var
		for (freevar = -1, p = 0; p < ncd_variables; p++)
		{
			str = ncd_varbuffer_names[p];
			if (str == NCD_PARM1)
				break;
			if (str == "")
				freevar = p;
		}
		// global is found, set value	
		if (p < ncd_variables) 
			ncd_varbuffer_values[p] = NCD_PARM2;
		else if (freevar >= 0) 
		{
			// replace free global
			ncd_varbuffer_names[freevar] = NCD_PARM1;
			ncd_varbuffer_values[freevar] = NCD_PARM2;
		}
		else 
		{
			// check if we can create this global
			if (ncd_variables >= NETHERCODE_MAX_VARS)
			{
				NetherCode_Warning(strcat("ran out of free variable slots (max is ", ftos(NETHERCODE_MAX_VARS), ")"), 1);
				NCD_RETURN_NULL()
			}
			// check if there is any free var slots
			ncd_varbuffer_names[ncd_variables] = NCD_PARM1;
			ncd_varbuffer_values[ncd_variables] = NCD_PARM2;
			ncd_variables++;
		}
		NCD_RETURN_NULL()
	}	
	
	// return global's value
	for (p = 0; p < ncd_variables; p++)
		if (ncd_varbuffer_names[p] == NCD_PARM1)
			break;
	if (p < ncd_variables) // var is found
		NCD_RETURN(ncd_varbuffer_values[p])
	NetherCode_Warning(strcat("var '", NCD_PARM1, "' not exist"), 1);	
	NCD_RETURN_NULL()
}

// freevar('varname');
// delete variable
ncd_builtin ncd_freevar = 
{ 
	float p;
	
	NCD_SAFEPARMCOUNT(1, 1)
	for (p = 0; p < ncd_variables; p++)
		if (ncd_varbuffer_names[p] == NCD_PARM1)
			break;
	if (p < ncd_variables) // var is found
		NCD_RETURN("1")	
	NetherCode_Warning(strcat("freevar: variable '", NCD_PARM1, "' not exist"), 1);	
	NCD_RETURN_NULL()
}

// isvar('varname');
// check if there's var
ncd_builtin ncd_isvar = 
{
	float p;
	
	NCD_SAFEPARMCOUNT(1, 1)
	for (p = 0; p < ncd_variables; p++)
		if (ncd_varbuffer_names[p] == NCD_PARM1)
			break;
	if (p < ncd_variables)
		NCD_RETURN("1")	
	NCD_RETURN("0")		
}

// global('name',['value'])
// get or set value for global
ncd_builtin ncd_global = 
{ 
	float numglobals, emptyglobal, g;
	string n;
	
	NCD_SAFEPARMCOUNT(1, 2)
	numglobals = buf_getsize(ncd_currentProgGlobalNames);
	// set value
	if (NCD_PARMNUM > 1)
	{
		// find global
		emptyglobal = numglobals;
		for (g = 0; g < numglobals; g++)
		{
			n = bufstr_get(ncd_currentProgGlobalNames, g);
			if (n == NCD_PARM1)
				break;
			if (n == "")
				emptyglobal = g;
		}
		// if found, set value
		if (g < numglobals)
		{
			bufstr_set(ncd_currentProgGlobals, g, NCD_PARM2);
			NCD_RETURN(NCD_PARM2)
		}
		// set new global
		bufstr_set(ncd_currentProgGlobalNames, emptyglobal, NCD_PARM1);
		bufstr_set(ncd_currentProgGlobals, emptyglobal, NCD_PARM2);
		NCD_RETURN(NCD_PARM2)
	}
	// get value
	for (g = 0; g < numglobals; g++)
		if (bufstr_get(ncd_currentProgGlobalNames, g) == NCD_PARM1)
			break;
	if (g >= numglobals)
	{
		NetherCode_Warning(strcat("global: global '", NCD_PARM1, "' not exists"), 1);	
		NCD_RETURN_NULL()
	}
	NCD_RETURN(bufstr_get(ncd_currentProgGlobals, g))
}

// isglobal('name')
// returns 1 if there is such global
ncd_builtin ncd_isglobal = 
{ 
	float numglobals, g;
	
	NCD_SAFEPARMCOUNT(1, 1)
	numglobals = buf_getsize(ncd_currentProgGlobalNames);
	for (g = 0; g < numglobals; g++)
		if (bufstr_get(ncd_currentProgGlobalNames, g) == NCD_PARM1)
			NCD_RETURN("1")
	NCD_RETURN("0")
}

// freeglobal('name')
// delete global, returns global value
ncd_builtin ncd_freeglobal = 
{
	float numglobals, g;
	string n;
	
	NCD_SAFEPARMCOUNT(1, 1)
	numglobals = buf_getsize(ncd_currentProgGlobalNames);
	for (g = 0; g < numglobals; g++)
	{
		if (bufstr_get(ncd_currentProgGlobalNames, g) == NCD_PARM1)
		{
			n = bufstr_get(ncd_currentProgGlobals, g);
			bufstr_set(ncd_currentProgGlobalNames, g, "");
			bufstr_set(ncd_currentProgGlobals, g, "");
			NCD_RETURN(n)
		}
	}
	NetherCode_Warning(strcat("freeglobal: global '", NCD_PARM1, "' not exists"), 1);	
	NCD_RETURN_NULL()
}

// temp('num'[,'newvalue'])
// operating with locals
// one parm - returns current local value
// two parms - sets a new value for local
ncd_builtin ncd_temp = 
{ 
	float p;
	
	NCD_SAFEPARMCOUNT(1, 2)
	p = floor(NCD_PARM1F);
	// set value
	if (NCD_PARMNUM > 1)
	{
		if (p < 0 || p >= NETHERCODE_MAX_TEMPS)
		{
			NetherCode_Warning(strcat("temp: index ", NCD_PARM1, " out of buffer bounds(0...", ftos(NETHERCODE_MAX_TEMPS)), 1);	
			NCD_RETURN_NULL()
		}
		// enlarge temp buffer, fill unchecked temps
		if (ncd_numtemps <= p)
		{
			while(ncd_numtemps < p)
			{
				ncd_temps[ncd_numtemps] = "";
				ncd_numtemps++;
			}
			ncd_numtemps = p + 1;
		}
		// set value
		ncd_temps[p] = NCD_PARM2;
		NCD_RETURN(NCD_PARM2) // allow set(set()) constructions
	}	
	// return var's value
	if (p < 0 || p >= ncd_numtemps)
	{
		NetherCode_Warning(strcat("temp: index ", NCD_PARM1, " not exist"), 1);	
		NCD_RETURN_NULL()
	}
	NCD_RETURN(ncd_temps[p])
}

// print('string','string2' ...);
// print message to console
ncd_builtin ncd_print = 
{ 
	NCD_SAFEPARMCOUNT(1, 8)
	print(strcat(NCD_PARM1, NCD_PARM2, NCD_PARM3, NCD_PARM4, NCD_PARM5, NCD_PARM6, NCD_PARM7, NCD_PARM8));
	print("\n");
	NCD_RETURN_NULL()
};

// add(x, y[,...])
// returns a sum of all arguments
ncd_builtin ncd_add = 
{ 
	float r;
	
	NCD_SAFEPARMCOUNT(2, 8)
	r = NCD_PARM1F;
	r = r + NCD_PARM2F;
	if (NCD_PARMNUM > 2) r = r + NCD_PARM3F;
	if (NCD_PARMNUM > 3) r = r + NCD_PARM4F;
	if (NCD_PARMNUM > 4) r = r + NCD_PARM5F;
	if (NCD_PARMNUM > 5) r = r + NCD_PARM6F;
	if (NCD_PARMNUM > 6) r = r + NCD_PARM7F;
	if (NCD_PARMNUM > 7) r = r + NCD_PARM8F;
	NCD_RETURNF(r)
}

// sub(x, y[,...])
// returns a substract of all arguments
ncd_builtin ncd_sub = 
{ 
	float r;
	
	NCD_SAFEPARMCOUNT(2, 8)
	r = NCD_PARM1F;
	r = r - NCD_PARM2F;
	if (NCD_PARMNUM > 2) r = r - NCD_PARM3F;
	if (NCD_PARMNUM > 3) r = r - NCD_PARM4F;
	if (NCD_PARMNUM > 4) r = r - NCD_PARM5F;
	if (NCD_PARMNUM > 5) r = r - NCD_PARM6F;
	if (NCD_PARMNUM > 6) r = r - NCD_PARM7F;
	if (NCD_PARMNUM > 7) r = r - NCD_PARM8F;
	NCD_RETURNF(r)
}

// mul(x, y[,...])
// returns a multiplication of all arguments
ncd_builtin ncd_mul = 
{ 
	float r;
	
	NCD_SAFEPARMCOUNT(2, 8)
	r = NCD_PARM1F;
	r = r * NCD_PARM2F;
	if (NCD_PARMNUM > 2) r = r * NCD_PARM3F;
	if (NCD_PARMNUM > 3) r = r * NCD_PARM4F;
	if (NCD_PARMNUM > 4) r = r * NCD_PARM5F;
	if (NCD_PARMNUM > 5) r = r * NCD_PARM6F;
	if (NCD_PARMNUM > 6) r = r * NCD_PARM7F;
	if (NCD_PARMNUM > 7) r = r * NCD_PARM8F;
	NCD_RETURNF(r)
}

// div(x, y[,...])
// returns a div of all arguments
ncd_builtin ncd_div = 
{ 
	float r;
	
	NCD_SAFEPARMCOUNT(2, 8)
	r = NCD_PARM1F;
	r = r / NCD_PARM2F;
	if (NCD_PARMNUM > 2) r = r / NCD_PARM3F;
	if (NCD_PARMNUM > 3) r = r / NCD_PARM4F;
	if (NCD_PARMNUM > 4) r = r / NCD_PARM5F;
	if (NCD_PARMNUM > 5) r = r / NCD_PARM6F;
	if (NCD_PARMNUM > 6) r = r / NCD_PARM7F;
	if (NCD_PARMNUM > 7) r = r / NCD_PARM8F;
	NCD_RETURNF(r)
}

// sqrt(x)
// got a square root from x
ncd_builtin ncd_sqrt = 
{ 
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURNF(sqrt(NCD_PARM1F))
}

// pow(x, y)
// returns x raised to power y
ncd_builtin ncd_pow = 
{ 
	float n, p;
	
	NCD_SAFEPARMCOUNT(2, 2)
	n = NCD_PARM1F;
	p = NCD_PARM2F;
	NCD_RETURNF(pow(n, p))
}
	
// sin(x)
// returns sin of x
ncd_builtin ncd_sin = 
{ 
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURNF(sin(deg2rad(NCD_PARM1F)))
}

// cos(x)
// returns cos of x
ncd_builtin ncd_cos = 
{ 
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURNF(cos(deg2rad(NCD_PARM1F)))
}

// tokenize(x)
// tokenizes a string and returns how many tokens are there
nosave float ncd_tokenizebuf;
nosave float ncd_tokenizebuflen;
ncd_builtin ncd_tokenize = 
{ 
	float i;
	
	NCD_SAFEPARMCOUNT(1, 1)
	ncd_tokenizebuflen = tokenize(NCD_PARM1);
	// fill buffer and return
	for (i = 0; i < ncd_tokenizebuflen; i++)
		bufstr_set(ncd_tokenizebuf, i, argv(i));
	NCD_RETURNF(ncd_tokenizebuflen)
}

// tokenizebyseparator(x,separator1[,separator2...separator7])
// tokenizes a string and returns how many tokens are there
// could have 1-7 separators
ncd_builtin ncd_tokenizebyseparator = 
{ 
	float i;
	
	NCD_SAFEPARMCOUNT(2,8)
	     if (NCD_PARMNUM > 7) ncd_tokenizebuflen = tokenizebyseparator(NCD_PARM1, NCD_PARM2, NCD_PARM3, NCD_PARM4, NCD_PARM5, NCD_PARM6, NCD_PARM7, NCD_PARM8); 
	else if (NCD_PARMNUM > 6) ncd_tokenizebuflen = tokenizebyseparator(NCD_PARM1, NCD_PARM2, NCD_PARM3, NCD_PARM4, NCD_PARM5, NCD_PARM6, NCD_PARM7); 
	else if (NCD_PARMNUM > 5) ncd_tokenizebuflen = tokenizebyseparator(NCD_PARM1, NCD_PARM2, NCD_PARM3, NCD_PARM4, NCD_PARM5, NCD_PARM6); 
	else if (NCD_PARMNUM > 4) ncd_tokenizebuflen = tokenizebyseparator(NCD_PARM1, NCD_PARM2, NCD_PARM3, NCD_PARM4, NCD_PARM5); 
	else if (NCD_PARMNUM > 3) ncd_tokenizebuflen = tokenizebyseparator(NCD_PARM1, NCD_PARM2, NCD_PARM3, NCD_PARM4); 
	else if (NCD_PARMNUM > 2) ncd_tokenizebuflen = tokenizebyseparator(NCD_PARM1, NCD_PARM2, NCD_PARM3); 
	else                      ncd_tokenizebuflen = tokenizebyseparator(NCD_PARM1, NCD_PARM2); 
	// fill buffer and return
	for (i = 0; i < ncd_tokenizebuflen; i++)
		bufstr_set(ncd_tokenizebuf, i, argv(i));
	NCD_RETURNF(ncd_tokenizebuflen)
}

// argc() - returns a number of tokens
ncd_builtin ncd_argc = 
{ 
	NCD_SAFEPARMCOUNT(0,0)
	NCD_RETURNF(ncd_tokenizebuflen)
}

// argv(x) - returns a token #x
ncd_builtin ncd_argv = 
{ 
	float i;
	
	NCD_SAFEPARMCOUNT(1,1)
	i = NCD_PARM1F;
	if (i < 0 || i >= ncd_tokenizebuflen)
		NCD_RETURN_NULL()
	NCD_RETURN(bufstr_get(ncd_tokenizebuf, i))
}

// flagbit(bitnum)
// returns flag value fit bit num
// eg flagbit(4) = 16
ncd_builtin ncd_bitflag =
{
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURNF(pow(2, NCD_PARM1F))
}

// flagadd(value,bitflag1[,...])
// add bitflags to a value
ncd_builtin ncd_flagadd =
{ 
	float r;
	
	NCD_SAFEPARMCOUNT(2, 8)
	r = NCD_PARM1F;
	r = r | NCD_PARM2F;
	if (NCD_PARMNUM > 2) r = r | NCD_PARM3F;
	if (NCD_PARMNUM > 3) r = r | NCD_PARM4F;
	if (NCD_PARMNUM > 4) r = r | NCD_PARM5F;
	if (NCD_PARMNUM > 5) r = r | NCD_PARM6F;
	if (NCD_PARMNUM > 6) r = r | NCD_PARM7F;
	if (NCD_PARMNUM > 7) r = r | NCD_PARM8F;
	NCD_RETURNF(r)
}

// flagrem('value','flag1[,...]
// removes flags from value
ncd_builtin ncd_flagrem =
{ 
	float r;
	
	NCD_SAFEPARMCOUNT(2, 8)
	r = NCD_PARM1F;
	r = r - (r & NCD_PARM2F);
	if (NCD_PARMNUM > 2) r = r - (r & NCD_PARM3F);
	if (NCD_PARMNUM > 3) r = r - (r & NCD_PARM4F);
	if (NCD_PARMNUM > 4) r = r - (r & NCD_PARM5F);
	if (NCD_PARMNUM > 5) r = r - (r & NCD_PARM6F);
	if (NCD_PARMNUM > 6) r = r - (r & NCD_PARM7F);
	if (NCD_PARMNUM > 7) r = r - (r & NCD_PARM8F);
	NCD_RETURNF(r)
}
	
// bitshift('value','bits')
// shifts value by x bits
ncd_builtin ncd_bitshift =
{ 
	float v, b;
	
	NCD_SAFEPARMCOUNT(2, 2)
	v = NCD_PARM1F;
	b = NCD_PARM2F;
	NCD_RETURNF(bitshift(v,b))
}

// float('val');
// returns float value from 'val', if input is not numeric - returns 0
ncd_builtin ncd_float =
{
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURNF(NCD_PARM1F)
}

// int('val');
// returns integer value from 'val', if input is not numeric - returns 0, returns 9 for 9.7 and -7 for -7.3
ncd_builtin ncd_int =
{
	float v;

	NCD_SAFEPARMCOUNT(1, 1)
	v = NCD_PARM1F;
	if (v >= 0)
		NCD_RETURNF(floor(v))
	NCD_RETURNF(ceil(v))
}

// bool('val');
// returns boolean 0/1 value from 'val' 
ncd_builtin ncd_bool =
{
	NCD_SAFEPARMCOUNT(1, 1)
	if (NCD_PARM1F)
		NCD_RETURN("1")
	NCD_RETURN("0")
}

// vector('val');
// returns vector value from 'val', if input is not numeric - returns '0 0 0'
ncd_builtin ncd_vector =
{
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURNV(NCD_PARM1V)
}

// vec([x,y,z]);
// builds 1d/2d/3d vector with x,y,z components, if no components are gives it returns null vector
ncd_builtin ncd_vec =
{
	vector v;

	NCD_SAFEPARMCOUNT(0, 3)
	if (NCD_PARMNUM > 0)
		v_x = NCD_PARM1F;
	if (NCD_PARMNUM > 1)
		v_y = NCD_PARM2F;	
	if (NCD_PARMNUM > 2)
		v_z = NCD_PARM3F;
	NCD_RETURNV(v)
}

// x(vector);
// extracts x value from vector and returns it as float
ncd_builtin ncd_x =
{
	vector v;
	
	NCD_SAFEPARMCOUNT(1, 1)
	v = NCD_PARM1V;
	NCD_RETURNF(v_x)
}

// y(vector);
// extracts y value from vector and returns it as float
ncd_builtin ncd_y =
{
	vector v;
	
	NCD_SAFEPARMCOUNT(1, 1)
	v = NCD_PARM1V;
	NCD_RETURNF(v_y)
}

// z(vector);
// extracts z value from vector and returns it as float
ncd_builtin ncd_z =
{
	vector v;
	
	NCD_SAFEPARMCOUNT(1, 1)
	v = NCD_PARM1V;
	NCD_RETURNF(v_z)
}

// xy(vector);
// extracts xy vector from 3d vector
ncd_builtin ncd_xy =
{
	vector v;
	
	NCD_SAFEPARMCOUNT(1, 1)
	v = NCD_PARM1V;
	v_z = 0;
	NCD_RETURNV(v)
}

// xz(vector);
// extracts xz vector from 3d vector
ncd_builtin ncd_xz =
{
	vector v;
	
	NCD_SAFEPARMCOUNT(1, 1)
	v = NCD_PARM1V;
	v_y = 0;
	NCD_RETURNV(v)
}

// yz(vector);
// extracts xy vector from 3d vector
ncd_builtin ncd_yz =
{
	vector v;
	
	NCD_SAFEPARMCOUNT(1, 1)
	v = NCD_PARM1V;
	v_x = 0;
	NCD_RETURNV(v)
}

// vlen('vector');
// returns vector length
ncd_builtin ncd_vlen =
{
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURNF(vlen(NCD_PARM1V))
}

// abs('val');
// returns absolute value
ncd_builtin ncd_abs =
{
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURNF(fabs(NCD_PARM1F))
}

// ceil('val');
// returns highest round
ncd_builtin ncd_ceil =
{
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURNF(ceil(NCD_PARM1F))
}

// floor('val');
// returns lowest round
ncd_builtin ncd_floor =
{
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURNF(floor(NCD_PARM1F))
}

// rint('val');
// returns nearest int
ncd_builtin ncd_rint =
{
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURNF(rint(NCD_PARM1F))
}

// natural('val','base');
// returns nearest int
ncd_builtin ncd_natural =
{
	NCD_SAFEPARMCOUNT(2, 2)
	NCD_RETURN(natural(NCD_PARM1F, NCD_PARM2F))
}

// ascii('string'[,pos])
// extract ASCII code from char (of first char of entered string), is pos is set it can override char position in entered string
ncd_builtin ncd_ascii =
{
	float p;
	
	NCD_SAFEPARMCOUNT(1, 2)
	p = NCD_PARM2F;
	NCD_RETURNF(str2chr(NCD_PARM1, p))
}

// chr('ascii_code')
// returns a character from ascii code
ncd_builtin ncd_chr =
{
	NCD_SAFEPARMCOUNT(1, 1)
	if (NCD_PARM1 == "dquot")
		NCD_RETURN("\"")
	if (NCD_PARM1 == "squot")
		NCD_RETURN("'")
	NCD_RETURN(chr2str(NCD_PARM1F))
}	

// eq('x','y')
// logic function - returns 1 if x is equal to y, otherwise returns 1
ncd_builtin ncd_equal =
{
	NCD_SAFEPARMCOUNT(2, 2)
	if (NCD_PARM1 == NCD_PARM2)
		NCD_RETURN("1")
	NCD_RETURN("0")
}

// neq('x','y')
// logic function - returns 0 if x is equal to y, otherwise returns 0
ncd_builtin ncd_nequal =
{
	NCD_SAFEPARMCOUNT(2, 2)
	if (NCD_PARM1 == NCD_PARM2)
		NCD_RETURN("0")
	NCD_RETURN("1")
}

// gr('x','y')
// logic function - returs 1 if x is greater than y, otherwise returns 1
ncd_builtin ncd_gr =
{
	float v1, v2;
	
	NCD_SAFEPARMCOUNT(2, 2)
	v1 = NCD_PARM1F;
	v2 = NCD_PARM2F;
	if (v1 > v2)
		NCD_RETURN("1")
	NCD_RETURN("0")
}

// le('x','y')
// logic function - returs 1 if x is lesser than y, otherwise returns 1
ncd_builtin ncd_le =
{
	float v1, v2;
	
	NCD_SAFEPARMCOUNT(2, 2)
	v1 = NCD_PARM1F;
	v2 = NCD_PARM2F;
	if (v1 < v2)
		NCD_RETURN("1")
	NCD_RETURN("0")
}

// groreq('x','y')
// logic function - returs 1 if x is greater or equal than y, otherwise returns 1
ncd_builtin ncd_groreq =
{
	float v1, v2;
	
	NCD_SAFEPARMCOUNT(2, 2)
	v1 = NCD_PARM1F;
	v2 = NCD_PARM2F;
	if (v1 >= v2)
		NCD_RETURN("1")
	NCD_RETURN("0")
}

// leoreq('x','y')
// logic function - returs 1 if x is greater or equal than y, otherwise returns 1
ncd_builtin ncd_leoreq =
{
	float v1, v2;
	
	NCD_SAFEPARMCOUNT(2, 2)
	v1 = NCD_PARM1F;
	v2 = NCD_PARM2F;
	if (v1 <= v2)
		NCD_RETURN("1")
	NCD_RETURN("0")
}

// not
// not('x')
// returns 1 for 0, otherwise 0
ncd_builtin ncd_not =
{
	NCD_SAFEPARMCOUNT(1, 1)
	if (!NCD_PARM1F)
		NCD_RETURN("1")
	NCD_RETURN("0")
}

// and('x','y'...)
// logic and for up to 8 parms
ncd_builtin ncd_and =
{
	float f, f1, f2, f3, f4, f5, f6, f7, f8;
	
	NCD_SAFEPARMCOUNT(2,8)
	if (NCD_PARMNUM < 5)
	{
		if (NCD_PARMNUM < 3) // 2
		{
			f1 = NCD_PARM1F; f2 = NCD_PARM2F;
			NCD_RETURNF(f1 && f2)
		}
		if (NCD_PARMNUM < 4) // 3
		{
			f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F;
			NCD_RETURNF(f1 && f2 && f3)
		}
		// 4
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F;
		NCD_RETURNF(f1 && f2 && f3 && f4)
	}
	// 5-8 parms
	if (NCD_PARMNUM < 6) // 5
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F;
		NCD_RETURNF(f1 && f2 && f3 && f4 && f5)
	}
	if (NCD_PARMNUM < 7) // 6
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F;
		NCD_RETURNF(f1 && f2 && f3 && f4 && f5 && f6)
	}
	if (NCD_PARMNUM < 8) // 7
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F; f7 = NCD_PARM5F;
		NCD_RETURNF(f1 && f2 && f3 && f4 && f5 && f6 && f7)
	}
	// 8
	f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F; f7 = NCD_PARM5F; f8 = NCD_PARM8F;
	NCD_RETURNF(f1 && f2 && f3 && f4 && f5 && f6 && f7 && f8)
}

// or('x','y'[,parm3...parm8])
// logic or
ncd_builtin ncd_or =
{
	float f, f1, f2, f3, f4, f5, f6, f7, f8;
	
	NCD_SAFEPARMCOUNT(2,8)
	if (NCD_PARMNUM < 5)
	{
		if (NCD_PARMNUM < 3) // 2
		{
			f1 = NCD_PARM1F; f2 = NCD_PARM2F;
			NCD_RETURNF(f1 || f2)
		}
		if (NCD_PARMNUM < 4) // 3
		{
			f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F;
			NCD_RETURNF(f1 || f2 || f3)
		}
		// 4
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F;
		NCD_RETURNF(f1 || f2 || f3 || f4)
	}
	// 5-8 parms
	if (NCD_PARMNUM < 6) // 5
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F;
		NCD_RETURNF(f1 || f2 || f3 || f4 || f5)
	}
	if (NCD_PARMNUM < 7) // 6
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F;
		NCD_RETURNF(f1 || f2 || f3 || f4 || f5 || f6)
	}
	if (NCD_PARMNUM < 8) // 7
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F; f7 = NCD_PARM5F;
		NCD_RETURNF(f1 || f2 || f3 || f4 || f5 || f6 || f7)
	}
	// 8
	f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F; f7 = NCD_PARM5F; f8 = NCD_PARM8F;
	NCD_RETURNF(f1 || f2 || f3 || f4 || f5 || f6 || f7 || f8)
}

// bitand('x','y')
// bitwise and
ncd_builtin ncd_bitand =
{
	float f, f1, f2, f3, f4, f5, f6, f7, f8;
	
	NCD_SAFEPARMCOUNT(2,8)
	if (NCD_PARMNUM < 5)
	{
		if (NCD_PARMNUM < 3) // 2
		{
			f1 = NCD_PARM1F; f2 = NCD_PARM2F;
			NCD_RETURNF(f1 & f2)
		}
		if (NCD_PARMNUM < 4) // 3
		{
			f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F;
			NCD_RETURNF(f1 & f2 & f3)
		}
		// 4
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F;
		NCD_RETURNF(f1 & f2 & f3 & f4)
	}
	// 5-8 parms
	if (NCD_PARMNUM < 6) // 5
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F;
		NCD_RETURNF(f1 & f2 & f3 & f4 & f5)
	}
	if (NCD_PARMNUM < 7) // 6
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F;
		NCD_RETURNF(f1 & f2 & f3 & f4 & f5 & f6)
	}
	if (NCD_PARMNUM < 8) // 7
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F; f7 = NCD_PARM5F;
		NCD_RETURNF(f1 & f2 & f3 & f4 & f5 & f6 & f7)
	}
	// 8
	f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F; f7 = NCD_PARM5F; f8 = NCD_PARM8F;
	NCD_RETURNF(f1 & f2 & f3 & f4 & f5 & f6 & f7 & f8)
}

// bitor('x','y')
// bitwise or
ncd_builtin ncd_bitor =
{
	float f, f1, f2, f3, f4, f5, f6, f7, f8;
	
	NCD_SAFEPARMCOUNT(2,8)
	if (NCD_PARMNUM < 5)
	{
		if (NCD_PARMNUM < 3) // 2
		{
			f1 = NCD_PARM1F; f2 = NCD_PARM2F;
			NCD_RETURNF(f1 | f2)
		}
		if (NCD_PARMNUM < 4) // 3
		{
			f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F;
			NCD_RETURNF(f1 | f2 | f3)
		}
		// 4
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F;
		NCD_RETURNF(f1 | f2 | f3 | f4)
	}
	// 5-8 parms
	if (NCD_PARMNUM < 6) // 5
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F;
		NCD_RETURNF(f1 | f2 | f3 | f4 | f5)
	}
	if (NCD_PARMNUM < 7) // 6
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F;
		NCD_RETURNF(f1 | f2 | f3 | f4 | f5 | f6)
	}
	if (NCD_PARMNUM < 8) // 7
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F; f7 = NCD_PARM5F;
		NCD_RETURNF(f1 | f2 | f3 | f4 | f5 | f6 | f7)
	}
	// 8
	f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F; f7 = NCD_PARM5F; f8 = NCD_PARM8F;
	NCD_RETURNF(f1 | f2 | f3 | f4 | f5 | f6 | f7 | f8)
}

// lif('condition','x'[,'y'])
// returns x if condition != 0, otherwize returns y
ncd_builtin ncd_lif =
{
	NCD_SAFEPARMCOUNT(1, 3)
	if (NCD_PARM1F != 0)
	{
		if (NCD_PARMNUM < 2)
			NCD_RETURN("1")
		NCD_RETURN(NCD_PARM2)
	}
	if (NCD_PARMNUM < 3)
		NCD_RETURN("0")
	NCD_RETURN(NCD_PARM3)
}

// pick('index','a'[,'b','c','d','e','f','j'])
// return certain parm based on index, 'a' for 1, 'b' for 2 etc..., up to 7, for all < 1 return 'a', for > 7 return 'j'
ncd_builtin ncd_pick =
{
	float f;
	
	NCD_SAFEPARMCOUNT(2, 8)
	f = bound(1, floor(NCD_PARM1F), 7);
	if (f == 1) NCD_RETURN(NCD_PARM2)
	if (f == 2) NCD_RETURN(NCD_PARM3)	
	if (f == 3) NCD_RETURN(NCD_PARM4)
	if (f == 4) NCD_RETURN(NCD_PARM5)
	if (f == 5) NCD_RETURN(NCD_PARM6)
	if (f == 6) NCD_RETURN(NCD_PARM7)
	if (f == 7) NCD_RETURN(NCD_PARM8)	
	NCD_RETURN_NULL()
}

// indexof('value','a'[,'b'...])
// return index (1 - 7) of parm that matches value, return 0 if not found
// a,b etc could be altstrings of a format: "'val''val'"
ncd_builtin ncd_indexof =
{
	string altn;
	
	NCD_SAFEPARMCOUNT(2, 8)
	
	altn = strcat("'", strreplace("'", "\'", NCD_PARM1), "'");
	#define check(p,n) if (altstr_check(p)) { if (strstrofs(p, altn, 0) > 0) return n; } else if (NCD_PARM1 == p) return n;
	check(NCD_PARM2, "1")
	check(NCD_PARM3, "2")
	check(NCD_PARM4, "3")
	check(NCD_PARM5, "4")
	check(NCD_PARM6, "5")
	check(NCD_PARM7, "6")
	check(NCD_PARM8, "7")
	#undef check
	return "0";
}

// min('val1','val2',...);
// returns minimal value from supplied arguments
ncd_builtin ncd_min =
{
	float f, f1, f2, f3, f4, f5, f6, f7, f8;
	
	NCD_SAFEPARMCOUNT(2, 8)
	if (NCD_PARMNUM < 5)
	{
		if (NCD_PARMNUM < 3) // 2
		{
			f1 = NCD_PARM1F; f2 = NCD_PARM2F;
			NCD_RETURNF(min(f1, f2))
		}
		if (NCD_PARMNUM < 4) // 3
		{
			f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F;
			NCD_RETURNF(min(f1, f2, f3))
		}
		// 4
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F;
		NCD_RETURNF(min(f1, f2, f3, f4))
	}
	// 5-8 parms
	if (NCD_PARMNUM < 6) // 5
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F;
		NCD_RETURNF(min(f1, f2, f3, f4, f5))
	}
	if (NCD_PARMNUM < 7) // 6
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F;
		NCD_RETURNF(min(f1, f2, f3, f4, f5, f6))
	}
	if (NCD_PARMNUM < 8) // 7
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F; f7 = NCD_PARM5F;
		NCD_RETURNF(min(f1, f2, f3, f4, f5, f6, f7))
	}
	// 8
	f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F; f7 = NCD_PARM5F; f8 = NCD_PARM8F;
	NCD_RETURNF(min(f1, f2, f3, f4, f5, f6, f7, f8))
}

// max('val1','val2',...);
// returns maximal value from supplied arguments
ncd_builtin ncd_max =
{
	float f, f1, f2, f3, f4, f5, f6, f7, f8;
	
	NCD_SAFEPARMCOUNT(2, 8)
	if (NCD_PARMNUM < 5)
	{
		if (NCD_PARMNUM < 3) // 2
		{
			f1 = NCD_PARM1F; f2 = NCD_PARM2F;
			NCD_RETURNF(max(f1, f2))
		}
		if (NCD_PARMNUM < 4) // 3
		{
			f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F;
			NCD_RETURNF(max(f1, f2, f3))
		}
		// 4
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F;
		NCD_RETURNF(max(f1, f2, f3, f4))
	}
	// 5-8 parms
	if (NCD_PARMNUM < 6) // 5
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F;
		NCD_RETURNF(max(f1, f2, f3, f4, f5))
	}
	if (NCD_PARMNUM < 7) // 6
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F;
		NCD_RETURNF(max(f1, f2, f3, f4, f5, f6))
	}
	if (NCD_PARMNUM < 8) // 7
	{
		f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F; f7 = NCD_PARM5F;
		NCD_RETURNF(max(f1, f2, f3, f4, f5, f6, f7))
	}
	// 8
	f1 = NCD_PARM1F; f2 = NCD_PARM2F; f3 = NCD_PARM3F; f4 = NCD_PARM4F; f5 = NCD_PARM5F; f6 = NCD_PARM5F; f7 = NCD_PARM5F; f8 = NCD_PARM8F;
	NCD_RETURNF(max(f1, f2, f3, f4, f5, f6, f7, f8))
}

// bound('min','val','max');
// bounds value
ncd_builtin ncd_bound =
{
	float fmin, f, fmax;
	
	NCD_SAFEPARMCOUNT(3, 3)
	fmin = NCD_PARM1F;
	f = NCD_PARM2F;
	fmax = NCD_PARM3F;
	NCD_RETURNF(bound(fmin, f, fmax))
}

// strcat('string','string2' ...);
// returns all args concentenated
ncd_builtin ncd_strcat = 
{ 
	NCD_SAFEPARMCOUNT(1, 8)
	NCD_RETURN(strcat(NCD_PARM1, NCD_PARM2, NCD_PARM3, NCD_PARM4, NCD_PARM5, NCD_PARM6, NCD_PARM7, NCD_PARM8))
};

// sprint('string1', 'parm1'[,'parm2'...'parm7'])
// replaces %1..%7 in a string by parms
ncd_builtin ncd_sprint = 
{ 
	string s;
	
	// todo: optimize, add more values (like %f)
	NCD_SAFEPARMCOUNT(2, 8)
	s = strreplace("%1", NCD_PARM2, NCD_PARM1);
	if (NCD_PARMNUM >= 3)
		s = strreplace("%2", NCD_PARM3, s);
	if (NCD_PARMNUM >= 4)
		s = strreplace("%3", NCD_PARM4, s);
	if (NCD_PARMNUM >= 5)
		s = strreplace("%4", NCD_PARM5, s);	
	if (NCD_PARMNUM >= 6)
		s = strreplace("%5", NCD_PARM6, s);
	if (NCD_PARMNUM >= 7)
		s = strreplace("%6", NCD_PARM7, s);
	if (NCD_PARMNUM >= 8)
		s = strreplace("%7", NCD_PARM8, s);
	NCD_RETURN(s)
}

// sprinta('string', 'parms')
// replaces %num instanced in string by altstring/tokenstring parts
ncd_builtin ncd_sprinta = 
{ 
	float i, cnt;
	string s;
	
	// todo: optimize, add more values (like %f)
	NCD_SAFEPARMCOUNT(2, 2)
	cnt = tokenize(NCD_PARM2);
	s = NCD_PARM1;
	for (i = 0; i < cnt; i++)
		s = strreplace(strcat("%", ftos(i)), argv(i), s);
	NCD_RETURN(s)
}

// implode('glue','string2' ...);
// returns all args concentenated with 'separator' glue
ncd_builtin ncd_implode =
{
	string s;
	
	NCD_SAFEPARMCOUNT(2, 8)
	if (NCD_PARMNUM < 3)
		NCD_RETURN(NCD_PARM2)
	if (NCD_PARMNUM < 4)
		NCD_RETURN(strcat(NCD_PARM2, NCD_PARM1, NCD_PARM3))
	if (NCD_PARMNUM < 5) 
		NCD_RETURN(strcat(NCD_PARM2, NCD_PARM1, NCD_PARM3, NCD_PARM1, NCD_PARM4))	
	if (NCD_PARMNUM < 6)
		NCD_RETURN(strcat(NCD_PARM2, NCD_PARM1, NCD_PARM3, NCD_PARM1, NCD_PARM4, NCD_PARM1, NCD_PARM5))	
	if (NCD_PARMNUM < 7)
	{
		s = strcat(NCD_PARM2, NCD_PARM1, NCD_PARM3, NCD_PARM1, NCD_PARM4, NCD_PARM1, NCD_PARM5, NCD_PARM1);
		NCD_RETURN(strcat(s, NCD_PARM6))
	}	
	if (NCD_PARMNUM < 8)
	{
		s = strcat(NCD_PARM2, NCD_PARM1, NCD_PARM3, NCD_PARM1, NCD_PARM4, NCD_PARM1, NCD_PARM5, NCD_PARM1);
		NCD_RETURN(strcat(s, NCD_PARM6, NCD_PARM1, NCD_PARM7))
	}
	s = strcat(NCD_PARM2, NCD_PARM1, NCD_PARM3, NCD_PARM1, NCD_PARM4, NCD_PARM1, NCD_PARM5, NCD_PARM1);
	NCD_RETURN(strcat(s, NCD_PARM6, NCD_PARM1, NCD_PARM7, NCD_PARM1, NCD_PARM8))
}

// mid('string1',start,length);
// returns middle part of string
ncd_builtin ncd_mid =
{
	NCD_SAFEPARMCOUNT(3, 3)
	NCD_RETURN(substring(NCD_PARM1, NCD_PARM2F, NCD_PARM3F))
}

// left('string1',length);
// returns left part of string
ncd_builtin ncd_left =
{
	NCD_SAFEPARMCOUNT(2, 2)
	NCD_RETURN(substring(NCD_PARM1, 0, NCD_PARM2F))
}

// right('string1',length);
// returns right part of string
ncd_builtin ncd_right =
{
	float s;
	
	NCD_SAFEPARMCOUNT(2, 2)
	s = NCD_PARM2F;
	NCD_RETURN(substring(NCD_PARM1, strlen(NCD_PARM1)-s, s)) // todo: rework
}

// len('string');
// returns length of string
ncd_builtin ncd_len =
{
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURNF(strlen(NCD_PARM1))
}

// ucase('string1'string2' ...);
// returns all args concentenated and lowered
ncd_builtin ncd_ucase =
{
	NCD_SAFEPARMCOUNT(1, 8)
	NCD_RETURN(strtoupper(strcat(NCD_PARM1, NCD_PARM2, NCD_PARM3, NCD_PARM4, NCD_PARM5, NCD_PARM6, NCD_PARM7, NCD_PARM8)))
}

// lcase('string1'string2' ...);
// returns all args concentenated and lowered
ncd_builtin ncd_lcase =
{
	NCD_SAFEPARMCOUNT(1, 8)
	NCD_RETURN(strtolower(strcat(NCD_PARM1, NCD_PARM2, NCD_PARM3, NCD_PARM4, NCD_PARM5, NCD_PARM6, NCD_PARM7, NCD_PARM8)))
}

// cmd('string1','string2' ...);
// stuff message into console, return whole string builded from varargs 
ncd_builtin ncd_cmd =
{
	string c;

	NCD_SAFEPARMCOUNT(1, 8)
	c = strcat(NCD_PARM1, NCD_PARM2, NCD_PARM3, NCD_PARM4, NCD_PARM5, NCD_PARM6, NCD_PARM7, NCD_PARM8);
	localcmd(strcat(c, "\n"));
	NCD_RETURN(c)
}

// cvar('string1');
// returns string value of cvar
ncd_builtin ncd_cvar =
{	
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURN(cvar_string(NCD_PARM1))
}

// cvar_set('cvar','value');
// change cvar value
ncd_builtin ncd_cvar_set =
{	
	NCD_SAFEPARMCOUNT(2, 2)
	cvar_set(NCD_PARM1, NCD_PARM2);
	NCD_RETURN_NULL()
}

// call('function_name'[,'parm1',...'parm7'])
// call a builtin/progbuiltin/script, only 7 parameters are supported due to restrictions
ncd_builtin ncd_call =
{
	var ncd_builtin f;
	string fn, fp;
	float ftype;
	
	NCD_SAFEPARMCOUNT(1, 8)
	ftype = NetherCode_Compiler_FindFunctionOrScript(NCD_PARM1, 0);
	if (ftype == NCD_FUNCTION_BUILTIN)
	{
		ncd_numparms = NCD_PARMNUM - 1;
		f = ncd_func_f[ncdc_functionindex];
		NCD_RETURN(f(NCD_PARM2, NCD_PARM3, NCD_PARM4, NCD_PARM5, NCD_PARM6, NCD_PARM7, NCD_PARM8, ""))
	}
	if (ftype == NCD_FUNCTION_PROGBUILTIN)
	{
		ncd_numparms = NCD_PARMNUM - 1;
		ncd_currentProgBuiltinGetQC(ncdc_functionindex);
		NCD_RETURN(ncd_funcf(NCD_PARM2, NCD_PARM3, NCD_PARM4, NCD_PARM5, NCD_PARM6, NCD_PARM7, NCD_PARM8, ""))
	}
	if (ftype == NCD_FUNCTION_SCRIPT)
	{
		ncd_numparms = NCD_PARMNUM - 1;
		fn = bufstr_get(ncd_currentProgFuncBodies, ncdc_functionindex);
		fp = makelump7(NCD_PARM2, NCD_PARM3, NCD_PARM4, NCD_PARM5, NCD_PARM6, NCD_PARM7, NCD_PARM8);
		NCD_RETURN(NetherCode_Execute(stof(fn), fp))
	}
	// NCD_FUNCTION_INVALID
	NetherCode_Warning(strcat("call: cannot find function '", NCD_PARM1, "'"), 0);
	NCD_RETURN_NULL()
}

// return([value, if_statement])
// sets output value and stop script executing
// if if_statement is presented it only do actual return if it's <> 0
ncd_builtin ncd_return =
{
	NCD_SAFEPARMCOUNT(0, 2)
	if (NCD_PARMNUM == 2)
		if (!NCD_PARM2F)
			NCD_RETURN_NULL()
	if (NCD_PARMNUM)
		ncde_return = NCD_PARM1;
	ncde_state_z = NCD_ERRORCODE_ENDSCRIPT; // stop script
	NCD_RETURN_NULL()
}

// warning('message')
// makes warning
ncd_builtin ncd_warning =
{
	NCD_SAFEPARMCOUNT(1, 1)
	NetherCode_Warning(NCD_PARM1, 1);
	NCD_RETURN_NULL()
}

// fileattr('file','attr_str')
// return one of file attributes:
//   name - filename (no path)
//   path - a patf of file
//   basename - filename without extension
//   ext - extension
//   exist (or no parms) - 1 if file exists
ncd_builtin ncd_fileattr =
{
	string s;
	
	NCD_SAFEPARMCOUNT(1, 2)
	if (NCD_PARMNUM == 1)
		NCD_RETURNF(file_exist(NCD_PARM1))
	if (NCD_PARM2 == "name")
		NCD_RETURN(basename(NCD_PARM1))
	if (NCD_PARM2 == "path")
		NCD_RETURN(basepath(NCD_PARM1))	
	if (NCD_PARM2 == "basedir")
	{
		s = basepath(NCD_PARM1);
		NCD_RETURN(substring(s, 0, strlen(s)-1))		
	}
	if (NCD_PARM2 == "basename")
		NCD_RETURN(stripextension(basename(NCD_PARM1)))
	if (NCD_PARM2 == "ext")
		NCD_RETURN(extension(NCD_PARM1))
	if (NCD_PARM2 == "exist")
		NCD_RETURNF(file_exist(NCD_PARM1))
	if (NCD_PARM2 == "whichpack")	
		NCD_RETURN(whichpack(NCD_PARM1))
	NCD_RETURN_NULL()
}

// loadfile(filename)
// load a file as buffer and returns it
ncd_builtin ncd_loadfile =
{
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURNF(loadfile(NCD_PARM1))
}

// newbuf(buf)
// create an empty buf
ncd_builtin ncd_newbuf =
{
	NCD_SAFEPARMCOUNT(0, 0)
	NCD_RETURNF(buf_create())
}

// bufsize(buf)
// get a size of buf
ncd_builtin ncd_bufsize =
{
	NCD_SAFEPARMCOUNT(1, 1)
	NCD_RETURNF(buf_getsize(NCD_PARM1F))
}

// bufstr(buf, index [,new_value])
// set/get string from buf
ncd_builtin ncd_bufstr =
{
	float bh, i;
	
	NCD_SAFEPARMCOUNT(2, 3)
	bh = NCD_PARM1F;
	i = NCD_PARM2F;
	if (NCD_PARMNUM == 3) // set new value
	{
		bufstr_set(bh, i, NCD_PARM3);
		NCD_RETURN_NULL()
	}
	NCD_RETURN(bufstr_get(bh, i))
}

// bufadd(buf, string[,keep_order])
// add a string to buffer
ncd_builtin ncd_bufadd =
{
	float bh;

	NCD_SAFEPARMCOUNT(2, 3)
	bh = NCD_PARM1F;
	if (NCD_PARMNUM == 3) // keep order
		bufstr_add(bh, NCD_PARM2, NCD_PARM3F);
	else
		bufstr_add(bh, NCD_PARM2, 1);
	NCD_RETURN_NULL()
}

// tokenbuf([getout])
// returns a handle to tokenbuffer
// if getout is 1 it will return a copy of it so futher tokenizing will not change it (tokenbuffer will be cleaned after that)
ncd_builtin ncd_tokenbuf =
{
	float bh;
	
	NCD_SAFEPARMCOUNT(0, 1)
	if (NCD_PARMNUM == 1 && NCD_PARM1F)
	{
		bh = ncd_tokenizebuf;
		ncd_tokenizebuf = buf_create();
		ncd_tokenizebuflen = 0;
		NCD_RETURNF(bh)
	}
	NCD_RETURNF(ncd_tokenizebuf)
}

// bufsort(buf, sortpower[, backward])
// sorts a buffer
ncd_builtin ncd_bufsort =
{
	float bh;
	
	NCD_SAFEPARMCOUNT(2, 3)
	bh = NCD_PARM1F;
	if (NCD_PARMNUM == 3)
		buf_sort(bh, NCD_PARM2F, NCD_PARM3F);
	else
		buf_sort(bh, NCD_PARM2F, 0);
	NCD_RETURN_NULL()
}

// parsebuf(buf, parsefunc[,additional parms])
// parses a buffer with 'parsefunc' being called on each line
// parsefunc should be Script($buf,$line[,additional parms])
ncd_builtin ncd_parsebuf =
{
	float bh, linenum, lines, fnum;
	string s, fparms;
	
	NCD_SAFEPARMCOUNT(2, 8)
	bh = NCD_PARM1F;
	// find function
	fnum = NetherCode_Compiler_FindFunctionOrScript(NCD_PARM2, 0);
	if (fnum != NCD_FUNCTION_SCRIPT)
	{
		NetherCode_Warning(strcat("script '", NCD_PARM2, "' not found!"), 0);
		NCD_RETURN_NULL()
	}
	fnum = stof(bufstr_get(ncd_currentProgFuncBodies, ncdc_functionindex));
	// set temps for parameters
	if (NCD_PARMNUM >= 3) { NetherCode_Execute_SetTemp(2, NCD_PARM3) }
	if (NCD_PARMNUM >= 4) { NetherCode_Execute_SetTemp(3, NCD_PARM4) }
	if (NCD_PARMNUM >= 5) { NetherCode_Execute_SetTemp(4, NCD_PARM5) }
	if (NCD_PARMNUM >= 6) { NetherCode_Execute_SetTemp(5, NCD_PARM6) }
	if (NCD_PARMNUM >= 7) { NetherCode_Execute_SetTemp(6, NCD_PARM7) }
	if (NCD_PARMNUM >= 8) { NetherCode_Execute_SetTemp(7, NCD_PARM8) }	
	// parse
	NetherCode_Execute_BackUpStack()
	lines = buf_getsize(bh);
	for (linenum = 0; linenum < lines; linenum++)
	{
		NetherCode_Execute_SetTemp(0, ftos(bh))
		NetherCode_Execute_SetTemp(1, ftos(linenum))
		NetherCode_ExecuteInline(fnum); 
	}
	NetherCode_Execute_RestoreStack()
	NCD_RETURN_NULL()
}

// freebuf(buf)
// delete a buffer
ncd_builtin ncd_freebuf =
{
	NCD_SAFEPARMCOUNT(1, 1)
	buf_del(NCD_PARM1F);
	NCD_RETURN_NULL()
}

// debug()
// starts counting execution time/prints out stats
nosave float ncd_debug_timer;
ncd_builtin ncd_debug =
{
	float f;
	
	NCD_SAFEPARMCOUNT(0, 0)
	if (!ncd_debug_timer)
	{
		ncd_debug_timer = gettime(TIME_UPTIME);
		NCD_RETURN_NULL()
	}
	print(strcat("execution time: ", ftos(ceil((gettime(TIME_UPTIME)-ncd_debug_timer)*1000)), " ms.\n"));
	ncd_debug_timer = 0;
	NCD_RETURN_NULL()
}

/*
================================================================================

   BUILTIN API

================================================================================
*/

string NetherCode_SystemFunctionName(float b) =
{
	string s;
	
	if (b >= 0 && b < ncd_num_functions)
		return ncd_func_names[b];
	return "null";
}

void NetherCode_RegisterSystemFunction(string n, ncd_builtin f) =
{
	if (ncd_num_functions >= NCD_MAX_FUNCTIONS)
	{
		warning("NetherCode_RegisterSystemFunction: NCD_MAX_FUNCTIONS exceeded");
		return;
	}
	
	// VorteX: do not care about doubled builtin names
	ncd_func_names[ncd_num_functions] = n;
	ncd_func_f[ncd_num_functions] = f;
	ncd_num_functions = ncd_num_functions + 1;
}

void() NetherCode_RegisterSystemFunctions =
{
	NetherCode_RegisterSystemFunction("null", ncd_null); // not used
	NetherCode_RegisterSystemFunction("var", ncd_var);
	NetherCode_RegisterSystemFunction("freevar", ncd_freevar);
	NetherCode_RegisterSystemFunction("isvar", ncd_isvar);
	NetherCode_RegisterSystemFunction("global", ncd_global);
	NetherCode_RegisterSystemFunction("isglobal", ncd_isglobal);
	NetherCode_RegisterSystemFunction("freeglobal", ncd_freeglobal);
	NetherCode_RegisterSystemFunction("temp", ncd_temp);
	NetherCode_RegisterSystemFunction("print", ncd_print);
	NetherCode_RegisterSystemFunction("add", ncd_add);
	NetherCode_RegisterSystemFunction("sub", ncd_sub);
	NetherCode_RegisterSystemFunction("mul", ncd_mul);
	NetherCode_RegisterSystemFunction("div", ncd_div);
	NetherCode_RegisterSystemFunction("sqrt", ncd_sqrt);
	NetherCode_RegisterSystemFunction("pow", ncd_pow);
	NetherCode_RegisterSystemFunction("sin", ncd_sin);
	NetherCode_RegisterSystemFunction("cos", ncd_cos);
	NetherCode_RegisterSystemFunction("argc", ncd_argc);
	NetherCode_RegisterSystemFunction("argv", ncd_argv);
	NetherCode_RegisterSystemFunction("bitand", ncd_bitand);
	NetherCode_RegisterSystemFunction("bitor", ncd_bitor);
	NetherCode_RegisterSystemFunction("bitflag", ncd_bitflag);
	NetherCode_RegisterSystemFunction("flagadd", ncd_flagadd);
	NetherCode_RegisterSystemFunction("flagrem", ncd_flagrem);
	NetherCode_RegisterSystemFunction("bitshift", ncd_bitshift);
	NetherCode_RegisterSystemFunction("float", ncd_float);
	NetherCode_RegisterSystemFunction("int", ncd_int);
	NetherCode_RegisterSystemFunction("bool", ncd_bool);
	NetherCode_RegisterSystemFunction("vector", ncd_vector);
	NetherCode_RegisterSystemFunction("vec", ncd_vec);
	NetherCode_RegisterSystemFunction("x", ncd_x);
	NetherCode_RegisterSystemFunction("y", ncd_y);
	NetherCode_RegisterSystemFunction("z", ncd_z);
	NetherCode_RegisterSystemFunction("xy", ncd_xy);
	NetherCode_RegisterSystemFunction("xz", ncd_xz);
	NetherCode_RegisterSystemFunction("yz", ncd_yz);
	NetherCode_RegisterSystemFunction("vlen", ncd_vlen);
	NetherCode_RegisterSystemFunction("abs", ncd_abs);
	NetherCode_RegisterSystemFunction("ceil", ncd_ceil);
	NetherCode_RegisterSystemFunction("floor", ncd_floor);
	NetherCode_RegisterSystemFunction("rint", ncd_rint);
	NetherCode_RegisterSystemFunction("natural", ncd_natural);
	NetherCode_RegisterSystemFunction("ascii", ncd_ascii);
	NetherCode_RegisterSystemFunction("chr", ncd_chr);
	NetherCode_RegisterSystemFunction("equal", ncd_equal);
	NetherCode_RegisterSystemFunction("nequal", ncd_nequal);
	NetherCode_RegisterSystemFunction("greater", ncd_gr);
	NetherCode_RegisterSystemFunction("lesser", ncd_le);
	NetherCode_RegisterSystemFunction("groreq", ncd_groreq);
	NetherCode_RegisterSystemFunction("lesoreq", ncd_leoreq);
	NetherCode_RegisterSystemFunction("not", ncd_not);
	NetherCode_RegisterSystemFunction("and", ncd_and);
	NetherCode_RegisterSystemFunction("or", ncd_or);
	NetherCode_RegisterSystemFunction("lif", ncd_lif);
	NetherCode_RegisterSystemFunction("pick", ncd_pick);
	NetherCode_RegisterSystemFunction("indexof", ncd_indexof);
	NetherCode_RegisterSystemFunction("min", ncd_min);
	NetherCode_RegisterSystemFunction("max", ncd_max);
	NetherCode_RegisterSystemFunction("bound", ncd_bound);
	NetherCode_RegisterSystemFunction("strcat", ncd_strcat);
	NetherCode_RegisterSystemFunction("sprint", ncd_sprint);
	NetherCode_RegisterSystemFunction("sprinta", ncd_sprinta);
	NetherCode_RegisterSystemFunction("implode", ncd_implode);
	NetherCode_RegisterSystemFunction("mid", ncd_mid);
	NetherCode_RegisterSystemFunction("left", ncd_left);
	NetherCode_RegisterSystemFunction("right", ncd_right);
	NetherCode_RegisterSystemFunction("len", ncd_len);
	NetherCode_RegisterSystemFunction("ucase", ncd_ucase);
	NetherCode_RegisterSystemFunction("lcase", ncd_lcase);
	NetherCode_RegisterSystemFunction("cmd", ncd_cmd);
	NetherCode_RegisterSystemFunction("cvar", ncd_cvar);
	NetherCode_RegisterSystemFunction("cvar_set", ncd_cvar_set);
	NetherCode_RegisterSystemFunction("call", ncd_call);
	NetherCode_RegisterSystemFunction("return", ncd_return);
	NetherCode_RegisterSystemFunction("warning", ncd_warning);
	NetherCode_RegisterSystemFunction("fileattr", ncd_fileattr);
	NetherCode_RegisterSystemFunction("loadfile", ncd_loadfile);
	NetherCode_RegisterSystemFunction("tokenize", ncd_tokenize);
	NetherCode_RegisterSystemFunction("tokenizebyseparator", ncd_tokenizebyseparator);
	NetherCode_RegisterSystemFunction("newbuf", ncd_newbuf);
	NetherCode_RegisterSystemFunction("bufsize", ncd_bufsize);
	NetherCode_RegisterSystemFunction("bufstr", ncd_bufstr);
	NetherCode_RegisterSystemFunction("bufadd", ncd_bufadd);
	NetherCode_RegisterSystemFunction("tokenbuf", ncd_tokenbuf);
	NetherCode_RegisterSystemFunction("bufsort", ncd_bufsort);
	NetherCode_RegisterSystemFunction("parsebuf", ncd_parsebuf);
	NetherCode_RegisterSystemFunction("debug", ncd_debug);
}

/*
================================================================================

   OTHER UTIL FUNCTIONS

================================================================================
*/

void() NetherCode_Init =
{
	entity null;
	
	ncd_tokenizebuf = buf_create();
	if (ncd_tokenizebuf < 0)
		warning("NetherCode_Init: failed to create tokenbuffer!");
	ncd_currentProgNum = -1;
	NetherCode_RegisterSystemFunctions();
	NetherCode_Initialized = 1;
	NetherCode_Scripts = buf_create();
}

void() NetherCode_Shutdown =
{
	float i, bufhandle;
	string temp;
	
	if (!NetherCode_Initialized)
		return;
	// free all compiled scripts
	for (i = 0; i < buf_getsize(NetherCode_Scripts); i++)
	{
		bufhandle = stof(bufstr_get(NetherCode_Scripts, i));
		if (bufhandle)
			buf_del(bufhandle);
	}
	buf_del(NetherCode_Scripts);
}

// set global value (or register new global)
void NetherCode_SetGlobal(float prog, string globalname, string startvalue)
{
	float bufglobals, bufvalues, g, numglobals, emptyglobal;
	string n;
	
	if (!NetherCode_CheckProg(prog))
		return;
	bufglobals = ncd_progglobalnames[prog];	
	bufvalues = ncd_progglobals[prog];
	// find global
	numglobals = buf_getsize(bufglobals);
	emptyglobal = numglobals;
	for (g = 0; g < numglobals; g++)
	{
		n = bufstr_get(bufglobals, g);
		if (n == globalname)
			break;
		if (n == "")
			emptyglobal = g;
	}
	// if found, set value
	if (g < numglobals)
	{
		bufstr_set(bufvalues, g, startvalue);
		return;
	}
	// set new global
	bufstr_set(bufglobals, emptyglobal, globalname);
	bufstr_set(bufvalues, emptyglobal, startvalue);
}

// add custom builtin to prog or override existing
float NetherCode_RegisterBuiltin(float prog, float num, string builtinname)
{
	float buf;
	
	if (!NetherCode_CheckProg(prog))
		return 0;
	buf = ncd_progbuiltins[prog];
	bufstr_set(buf, num, builtinname);
	return 1;
}

// check if function exists
float NetherCode_FindFunction(float prog, string scriptname) =
{
	float functionsbuf, funcbodiesbuf, numfunctions, f;
	
	if (!NetherCode_CheckProg(prog))
		return 0;
		
	functionsbuf = ncd_progfunctions[prog];
	funcbodiesbuf = ncd_progfuncbodies[prog];
	numfunctions = buf_getsize(functionsbuf);
	
	// find function
	for (f = 0; f < numfunctions; f++)
		if (bufstr_get(functionsbuf, f) == scriptname)
			break;
	if (f < numfunctions)
		return stof(bufstr_get(funcbodiesbuf, f));
	return 0;
}

// add custom function to prog
void NetherCode_AddFunction(float prog, string scriptname, string scriptcontent, string scriptvars) =
{
	float buf, scripts, scriptnum, compilation;

	if (!NetherCode_CheckProg(prog))
		return;
	
	// compile script content
	if (scriptcontent == "")
		compilation = -1;
	else
		compilation = NetherCode_Compile(prog, scriptcontent);

	// find if script is registered already
	buf = ncd_progfunctions[prog];
	scripts = buf_getsize(buf);
	for (scriptnum = 0; scriptnum < scripts; scriptnum++)
		if (bufstr_get(buf, scriptnum) == scriptname)
			break;

	// register function in buffers
	bufstr_set(buf, scriptnum, scriptname);
	buf = ncd_progfuncbodies[prog];
	bufstr_set(buf, scriptnum, ftos(compilation));	
	buf = ncd_progfuncparms[prog];
	bufstr_set(buf, scriptnum, scriptvars);
}

void NetherCode_RemoveProg(float prog)
{
	float buf;
	string s;
	
	if (!NetherCode_CheckProg(prog))
		return;
	s = ncd_prog[prog];
	if (s == "")
		return;
	strunzone(s);
	ncd_prog[prog] = "";
	buf = ncd_progglobals[prog]; if (buf >= 0) buf_del(buf);
	buf = ncd_progglobalnames[prog]; if (buf >= 0) buf_del(buf);
	buf = ncd_progfunctions[prog]; if (buf >= 0) buf_del(buf);
	buf = ncd_progfuncbodies[prog]; if (buf >= 0) buf_del(buf);	
	buf = ncd_progfuncparms[prog]; if (buf >= 0) buf_del(buf);	
	buf = ncd_progbuiltins[prog]; if (buf >= 0) buf_del(buf);	
}

float NetherCode_CreateProg(string progname, float(float function_index) custombuiltinfunc)
{
	float p, buf;
	string s;

	// check name
	if (progname == "")
	{
		warning("NetherCode_CreateProg: null prog name!");
		return -1;
	}
	
	// initialize?
	if (!NetherCode_Initialized)
		NetherCode_Init();
	
	// allocate prog
	for (p = 0; p < ncd_progs; p++)
	{
		s = ncd_prog[p];
		if (s == "")
			break;
	}
	if (p >= ncd_progs) // allocate new
	{
		if (ncd_progs >= NCD_MAX_PROGS)
		{
			warning("NetherCode_CreateProg: NCD_MAX_PROGS exceeded");
			return -1;
		}
		p = ncd_progs;
		ncd_progs++;
	}
	
	// create buffers
	s = strzone(progname);
	ncd_prog[p] = s;
	ncd_progglobals[p] = buf_create();
	ncd_progglobalnames[p] = buf_create();
	ncd_progfunctions[p] = buf_create();
	ncd_progfuncbodies[p] = buf_create();
	ncd_progfuncparms[p] = buf_create();
	buf = buf_create(); 
	bufstr_set(buf, 0, "null"); 
	ncd_progbuiltins[p] = buf;
	ncd_progbuiltinsQC[p] = custombuiltinfunc;
	return p;
}

float NetherCode_RunEvent(float prog, string eventname)
{
	float code;
	
	if (!NetherCode_CheckProg(prog))
		return 0;
	NetherCode_SetProg(prog)
	// find function
	code = NetherCode_FindFunction(prog, strcat("Event.", eventname));
	if (!code)
		return 0;
	NetherCode_Run(prog, null_entity, code);
	return 1;
}

float NetherCode_RunCommand(float prog, string cmdname, string cmdparms)
{
	float code, l;
	
	if (!NetherCode_CheckProg(prog))
		return 0;
	NetherCode_SetProg(prog)
	// find function
	code = NetherCode_FindFunction(prog, strcat("Cmd.", cmdname));
	if (!code)
		return 0;
	l = tokenize(cmdparms);
	NetherCode_SetParms_FromTokenbuffer(0, l);
	NetherCode_Run(prog, null_entity, code);
	return 1;
}

////////////////////////////////////////
// FOOTER
////////////////////////////////////////

#undef NetherCode_ReadToken
#undef NetherCode_CheckProg
#undef NetherCode_SetProg
