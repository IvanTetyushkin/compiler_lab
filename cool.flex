/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */
int comment = 0;
//int bracket = 0;
int string_buf_len = 0;
bool string_error;
char* backslash_common()
{
	char* c = &yytext[1];
	if(*c == '\n')
	{
		++curr_lineno;
	}
	return c;
}

int write_str(char* str, int len)
{
	if(len< string_buf_len)
	{
		strncpy(string_buf_ptr, str, len);
		string_buf_ptr += len;
		string_buf_len -= len;
		return 0;
	}else
	{
		string_error = true;
		yylval.error_msg = "String constant too long";
		return -1;
	}
		
}
int null_character_err() {
  yylval.error_msg = "String contains null character";
  string_error = true;
  return -1;
}

%}

/*
 * Define names for regular expressions here.
 * What difference [a][b] and "ab"
 */

DARROW          =>
WHITESPACE		[ \t\r\f\v]+
NEWLINE			[\n]
ELSE			[eE][lL][sS][eE]
TRUE			t[rR][uU][eE]
FALSE			[f][aA][lL][sS][eE]
TYPEID			[A-Z][_a-zA-Z0-9]*
CLASS			[cC][lL][aA][sS][sS]
START_COMMENT	[(][*]
END_COMMENT		[*][)]
STAR			[*]
NOTCOMMENT		[^\n*(\\]
NOTRIGHTPAREN	[^)]
NOTSTAR			[^*]
NOTLEFTPAREN	[^(]
LEFTPAREN		[(]
BACKSLASH		[\\]
OBJECTID		[a-z][_a-zA-Z0-9]*
ASSIGN			[<][-]
NUMBER			[0-9][0-9]*
SMALLCOMMENT	[-][-]
NOTNEWLINE		[^\n]
LET				[lL][eE][tT]
IN				[iI][nN]
NEW				[nN][eE][wW]
IF				[iI][fF]
THEN			[tT][hH][eE][nN]
FI				[fF][iI]
WHILE			[wW][hH][iI][lL][eE]
LE				[<][=]
LOOP			[lL][oO][oO][pP]
POOL			[pP][oO][oO][lL]
INHERITS		[iI][nN][hH][eE][rR][iI][tT][sS]
QUOTES			[\"]
NOTSTRING		[^\n\0\\\"]
CASE			[cC][aA][sS][eE]
OF				[oO][fF]
ESAC			[eE][sS][aA][cC]
%x COMMENT
%x STRING
%%

 /*
  *  Nested comments
  */


 /*
  *  The multiple-character operators.
  */
  
<INITIAL,COMMENT>{NEWLINE}		{++curr_lineno;};
<INITIAL>{WHITESPACE}	;
<INITIAL>{ELSE}			{return(ELSE);};
{DARROW}				{ return (DARROW); };
<INITIAL>{TRUE}			{yylval.boolean = true; return (BOOL_CONST);};
<INITIAL>{FALSE}		{yylval.boolean = false; return(BOOL_CONST);}
<INITIAL>{TYPEID}		{yylval.symbol = stringtable.add_string(yytext);
						return(TYPEID);};
<INITIAL>{LOOP}			{return(LOOP);}
<INITIAL>{THEN}			{return(THEN);}
<INITIAL>{CLASS}		{return(CLASS);};
<INITIAL>{LET}			{return (LET);}
<INITIAL>{IN}			{return (IN);}
<INITIAL>{NEW}			{return (NEW);}
<INITIAL>{IF}			{return (IF);}
<INITIAL>{FI}			{return (FI);}
<INITIAL>{WHILE}		{return (WHILE);}
<INITIAL>{LE}			{return (LE);}
<INITIAL>{POOL}			{return (POOL);}
<INITIAL>{INHERITS}		{return (INHERITS);}
<INITIAL>{CASE}			{return(CASE);}
<INITIAL>{OF}			{return(OF);}
<INITIAL>{ESAC}			{return(ESAC);}
<INITIAL,COMMENT>{START_COMMENT} {++comment; BEGIN(COMMENT);};
<COMMENT>{END_COMMENT}	{comment--;
						if( comment == 0)
							BEGIN(INITIAL);
						};
<COMMENT>{START_COMMENT} {++comment; BEGIN(COMMENT);};
<COMMENT>{STAR}/{NOTRIGHTPAREN}    ;
<COMMENT>{LEFTPAREN}/{NOTSTAR}     ;
<COMMENT>{NOTCOMMENT}*             ;
<COMMENT>{BACKSLASH}(.|{NEWLINE}) {backslash_common();};
<COMMENT>{BACKSLASH}               ;
<INITIAL>"{"			{return int('{');};
<INITIAL>"}"			{return int('}');}
<INITIAL>":"			{return int(':');};
<INITIAL>{OBJECTID}		{yylval.symbol = stringtable.add_string(yytext);
						return (OBJECTID);};
<INITIAL>{ASSIGN}		{return(ASSIGN);};
<INITIAL>{NUMBER}		{yylval.symbol = stringtable.add_string(yytext);
						return (INT_CONST);}
<INITIAL>";"			{return int(';');}
<INITIAL>"("			{ return int('(');}
<INITIAL>")"			{ return int(')');}
<INITIAL>{SMALLCOMMENT}{NOTNEWLINE}*	;
<INITIAL>","			{return int(',');}	
<INITIAL>"~"			{return int('~');}
<INITIAL>"."			{return int('.');}
<INITIAL>">"			{return int('>');}
<INITIAL>"<"			{return int('<');}
<INITIAL>"+"			{return int('+');}
<INITIAL>"-"			{return int('-');}
<INITIAL>"="			{return int('=');}
<INITIAL>"*"			{return int('*');}
<INITIAL>"/"			{return int('/');}
<INITIAL>"@"			{return int('@');}
<INITIAL>{QUOTES}		{BEGIN(STRING);
						string_buf_ptr = string_buf;
						string_buf_len = MAX_STR_CONST;
						string_error = false;}
<STRING><<EOF>>			{yylval.error_msg = "EOF in string constant";
						BEGIN(INITIAL);
						return(ERROR);}
<STRING>{QUOTES}		{
						BEGIN(INITIAL);
						if(!string_error)
						{
							yylval.symbol = stringtable.add_string(string_buf,
							string_buf_ptr-string_buf);
							return (STR_CONST);
						}
						}
<STRING>{BACKSLASH}		;
<STRING>{NOTSTRING}*	{
						if(write_str(yytext,strlen(yytext))!=0)
							return( ERROR);
						}
<STRING>{NEWLINE}		{BEGIN(INITIAL);
						curr_lineno++;
						if(!string_error)
						{
							yylval.error_msg = "Undeterminated srting constant";
							return (ERROR);
						}}
<STRING>{BACKSLASH}(.|{NEWLINE}) {
								char *c = backslash_common();
								int rc;
								switch(*c)
								{
								case 'n':
									rc = write_str("\n",1);
									break;
								case 'b':
									rc = write_str("\b",1);
									break;
								case 't':
									rc = write_str("\t", 1);
									break;
								case 'f':
									rc = write_str("\f",1);
									break;
								case '\0':
									rc = null_character_err();
									break;
								default:
									rc = write_str(c,1);
								}
								if(rc!=0)
									return(ERROR);
								}

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


%%
