D         [0-9]
L         [a-zA-Z_]
H         [a-fA-F0-9]
E         [Ee][+-]?{D}+
FS         (f|F|l|L)
IS         (u|U|l|L)*
IDENT    {L}({L}|{D})*

%{
import "ecdefs"
#define YYLTYPE Location

#include "grammar.eh"

bool echoOn = true;
public void SetEchoOn(bool b) { echoOn = b; }

extern YYLTYPE type_yylloc;
extern YYLTYPE expression_yylloc;

extern File fileInput;
int preprocessor();
int comment();

void TESTTTT()
{
   yylloc.end.charPos += yyleng;
   yylloc.end.pos += yyleng;
   type_yylloc.end.charPos += yyleng;
   type_yylloc.end.pos += yyleng;
   expression_yylloc.end.charPos += yyleng;
   expression_yylloc.end.pos += yyleng;
}

#define YY_USER_ACTION  \
   TESTTTT();

   /*
   yylloc.end.charPos += yyleng;
   yylloc.end.pos += yyleng;
   */

#define YY_INPUT(buf,result,max_size) \
   result = fileInput.Read(buf, 1, max_size) \

YY_BUFFER_STATE include_stack[MAX_INCLUDE_DEPTH];
File fileStack[MAX_INCLUDE_DEPTH];
char sourceFileStack[MAX_INCLUDE_DEPTH][MAX_LOCATION];
public void SetSomeSourceFileStack(char * fileName, int index) { strcpy(sourceFileStack[index], fileName); }
YYLTYPE locStack[MAX_INCLUDE_DEPTH];
AccessMode declModeStack[MAX_INCLUDE_DEPTH];
int include_stack_ptr = 0;

#define uint _uint
default:

%}

%%

%{
   yylloc.start = yylloc.end; 
   type_yylloc.start = type_yylloc.end; 
   expression_yylloc.start = expression_yylloc.end; 
%}

"#"                  { preprocessor(); }
"/*"                 { comment(); }
"//"                 { commentCPP(); }

"auto"               { return(AUTO); }
"break"              { return(BREAK); }
"case"               { return(CASE); }
"char"               { return(CHAR); }
"const"              { return(CONST); }
"continue"           { return(CONTINUE); }
"default"            { return(DEFAULT); }
"do"                 { return(DO); }
"double"             { return(DOUBLE); }
"else"               { return(ELSE); }
"enum"               { return(ENUM); }
"extern"             { return(EXTERN); }
"float"              { return(FLOAT); }
"for"                { return(FOR); }
"goto"               { return(GOTO); }
"if"                 { return(IF); }
"int"                { return(INT); }
"uint"               { return(UINT); }
 /* "uint16"            { return(UINT16); } */
 /* "uint32"            { return(UINT32); } */
 /* "bool"              { return(BOOL_TOKEN); } */
"long"               { return(LONG); }
"register"           { return(REGISTER); }
"return"             { return(RETURN); }
"short"              { return(SHORT); }
"signed"             { return(SIGNED); }
"__signed__"         { return(SIGNED); }
"sizeof"             { return(SIZEOF); }
"static"             { return(STATIC); }
"struct"             { return(STRUCT); }
"switch"             { return(SWITCH); }
"typedef"            { return(TYPEDEF); }
"union"              { return(UNION); }
"unsigned"           { return(UNSIGNED); }
"void"               { return(VOID); }
"volatile"           { return(VOLATILE); }
"__volatile__"       { return(VOLATILE); }
"__volatile"         { return(VOLATILE); }
"while"              { return(WHILE); }

"property"           { return(PROPERTY); }
"set"                { return(SETPROP); }    // TODO: Don't make this a keyword...
"get"                { return(GETPROP); }    // TODO: Don't make this a keyword...
"isset"              { return(ISPROPSET); }    // TODO: Don't make this a keyword...
"class"              { return(CLASS); }
"thisclass"          { return(THISCLASS); }
"virtual"            { return(VIRTUAL); }
"delete"             { return(DELETE); }
"new"                { return(NEWOP); }
"new0"               { return(NEW0OP); }
"renew"              { return(RENEW); }
"renew0"             { return(RENEW0); }
"import"             { return(IMPORT); }
"define"             { return(DEFINE); }
"__int64"            { return(INT64); }
"int64"              { return(INT64); }
"__builtin_va_list"  { return(VALIST); }
"__builtin_va_arg"   { return(VAARG); }

 /* "__attribute__".?"(("({D}|{L})*"))" { return(EXT_ATTRIB); } */

 /* DID I MEAN? "__attribute__"" "*"(("" "*({D}|{L})*" "*("("({D}|{L})*(" "*","" "*({D}|{L})*)*" "*")")?" "*"))" { return(EXT_ATTRIB); } */

"__attribute_deprecated__"(" "*)"(("(" "*)({D}|{L})*(" "*)("("({D}|{L}|\")*((" "*)","(" "*)({D}|{L}|\")*)*(" "*)")")?(" "*)(","(" "*)({D}|{L})*(" "*)("("({D}|{L}|\")*((" "*)","(" "*)({D}|{L}|\")*)*(" "*)")")?(" "*))*"))" { return(EXT_ATTRIB); }
"__attribute__"(" "*)"(("(" "*)({D}|{L})*(" "*)("("({D}|{L}|\")*((" "*)","(" "*)({D}|{L}|\")*)*(" "*)")")?(" "*)(","(" "*)({D}|{L})*(" "*)("("({D}|{L}|\")*((" "*)","(" "*)({D}|{L}|\")*)*(" "*)")")?(" "*))*"))" { return(EXT_ATTRIB); }
"__attribute"(" "*)"(("(" "*)({D}|{L})*(" "*)("("({D}|{L}|\")*((" "*)","(" "*)({D}|{L}|\")*)*(" "*)")")?(" "*)(","(" "*)({D}|{L})*(" "*)("("({D}|{L}|\")*((" "*)","(" "*)({D}|{L}|\")*)*(" "*)")")?(" "*))*"))" { return(EXT_ATTRIB); }

 /* "__attribute__".?"((".?({D}|{L})*.?("("({D}|{L})*(.?",".?({D}|{L})*)*.?")")?.?"))" { return(EXT_ATTRIB); } */
 /* "__attribute".?"((".?({D}|{L})*.?("("({D}|{L})*(.?",".?({D}|{L})*)*.?")")?.?"))" { return(EXT_ATTRIB); }*/

"__inline__"               { return(EXT_STORAGE); }
"_inline"                  { return(EXT_STORAGE); }
"__inline"                 { return(EXT_STORAGE); }
"inline"                   { return(EXT_STORAGE); }
"__declspec("({D}|{L})*")" { return(EXT_STORAGE); }
"dllexport"                { return(EXT_STORAGE); }
"dllimport"                { return(EXT_STORAGE); }
"__cdecl"                  { return(EXT_DECL); }
"__stdcall"                { return(EXT_DECL); }
"__stdcall__"              { return(EXT_DECL); }
"_stdcall"                 { return(EXT_DECL); }
"stdcall"                  { return(EXT_DECL); }
"__restrict"               { return(EXT_DECL); }
"__const"                  { return(EXT_DECL); }
"__restrict__"             { return(EXT_DECL); }
"public"                   { return(PUBLIC); }
"private"                  { return(PRIVATE); }
"typed_object"             { return(TYPED_OBJECT); }
"any_object"               { return(ANY_OBJECT); }
"incref"                   { return(_INCREF); }
"__extension__"            { return(EXTENSION); }
"_extension_"              { return(EXTENSION); }
"__asm__"                  { return(ASM); }
"asm"                      { return(ASM); }
"__asm"                    { return(ASM); }
"__typeof"                 { return(TYPEOF); }
"watch"                    { return(WATCH); }
"stopwatching"             { return(STOPWATCHING); }
"firewatchers"             { return(FIREWATCHERS); }
"watchable"                { return(WATCHABLE); }
"class_designer"           { return(CLASS_DESIGNER); }
"class_no_expansion"       { return(CLASS_NO_EXPANSION); }
"class_fixed"              { return(CLASS_FIXED); }
"class_default_property"   { return(CLASS_DEFAULT_PROPERTY); }
"property_category"        { return(PROPERTY_CATEGORY); }
"class_data"               { return(CLASS_DATA); }
"class_property"           { return(CLASS_PROPERTY); }
"subclass"                 { return(SUBCLASS); }
"namespace"                { return(NAMESPACE); }
"dbtable"                  { return(DBTABLE); }
"dbfield"                  { return(DBFIELD); }
"dbindex"                  { return(DBINDEX); }
"database_open"            { return(DATABASE_OPEN); }
      
("::"|(({IDENT}"&"?"::")*)){IDENT}?    { return(check_type()); }     // {L}({L}|{D})*      { return(check_type()); }  // ("::"|(({IDENT}"::")*)){IDENT}  { return(check_type()); }     // {L}({L}|{D})*      { return(check_type()); }

0[xX]{H}+{IS}?          { return(CONSTANT); }
0{D}+{IS}?              { return(CONSTANT); }
{D}+{IS}?               { return(CONSTANT); }
L?'(\\.|[^\\'])+'       { return(CONSTANT); }

{D}+{E}{FS}?            { return(CONSTANT); }
{D}*"."{D}+({E})?{FS}?  { return(CONSTANT); }
{D}+"."{D}*({E})?{FS}?  { return(CONSTANT); }

L?\"(\\.|[^\\"])*\"     { return(STRING_LITERAL); }

"..."       { return(ELLIPSIS); }
">>="       { return(RIGHT_ASSIGN); }
"<<="       { return(LEFT_ASSIGN); }
"+="        { return(ADD_ASSIGN); }
"-="        { return(SUB_ASSIGN); }
"*="        { return(MUL_ASSIGN); }
"/="        { return(DIV_ASSIGN); }
"%="        { return(MOD_ASSIGN); }
"&="        { return(AND_ASSIGN); }
"^="        { return(XOR_ASSIGN); }
"|="        { return(OR_ASSIGN); }
">>"        { return(RIGHT_OP); }
"<<"        { return(LEFT_OP); }
"++"        { return(INC_OP); }
"--"        { return(DEC_OP); }
"->"        { return(PTR_OP); }
"&&"        { return(AND_OP); }
"||"        { return(OR_OP); }
"<="        { return(LE_OP); }
">="        { return(GE_OP); }
"=="        { return(EQ_OP); }
"!="        { return(NE_OP); }
   /* "::"        { return(CLASS_OP); } */
";"         { return(';'); }
("{"|"<%")  { return('{'); }
("}"|"%>")  { return('}'); }
","         { return(','); }
":"         { return(':'); }
"="         { return('='); }
"("         { return('('); }
")"         { return(')'); }
("["|"<:")  { return('['); }
("]"|":>")  { return(']'); }
"."         { return('.'); }
"&"         { return('&'); }
"!"         { return('!'); }
"~"         { return('~'); }
"-"         { return('-'); }
"+"         { return('+'); }
"*"         { return('*'); }
"/"         { return('/'); }
"%"         { return('%'); }
"<"         { return('<'); }
">"         { return('>'); }
"^"         { return('^'); }
"|"         { return('|'); }
"?"         { return('?'); }
"$"         { return('$'); }

<<EOF>> {
      if ( --include_stack_ptr < 0 )
      {
         yyterminate();
      }
      else
      {
         delete fileInput;
         yy_delete_buffer( YY_CURRENT_BUFFER );
         fileInput = fileStack[include_stack_ptr];
         yylloc = locStack[include_stack_ptr];
         type_yylloc = locStack[include_stack_ptr];
         expression_yylloc = locStack[include_stack_ptr];
         yy_switch_to_buffer(include_stack[include_stack_ptr] );
         defaultDeclMode = declMode = declModeStack[include_stack_ptr];
      }
   }


[ \v\f]   { yylloc.start = yylloc.end; type_yylloc.start = type_yylloc.end; expression_yylloc.start = expression_yylloc.end;}
[\n+]    { 
   yylloc.end.charPos = 1; yylloc.end.line += yyleng; yylloc.start = yylloc.end; 
   type_yylloc.end.charPos = 1; type_yylloc.end.line += yyleng; type_yylloc.start = type_yylloc.end; 
   expression_yylloc.end.charPos = 1; expression_yylloc.end.line += yyleng; expression_yylloc.start = expression_yylloc.end; 
   }
[\t]     { 
   yylloc.start.charPos++ /*= 3 - (yylloc.start.col % 3)*/; yylloc.end.charPos = yylloc.start.charPos; yylloc.start.pos = yylloc.end.pos; 
   expression_yylloc.start.charPos++ /*= 3 - (expression_yylloc.start.col % 3)*/; expression_yylloc.end.charPos = expression_yylloc.start.charPos; expression_yylloc.start.pos = expression_yylloc.end.pos; 
   type_yylloc.start.charPos++ /*= 3 - (type_yylloc.start.col % 3)*/; type_yylloc.end.charPos = type_yylloc.start.charPos; type_yylloc.start.pos = type_yylloc.end.pos; 
   }

.         { yylloc.start = yylloc.end; expression_yylloc.start = expression_yylloc.end;  type_yylloc.start = type_yylloc.end; }

%%

yywrap()
{
   return(1);
}

int comment()
{
   int c, last = 0;
   for(;;)
   {
      c = input();
      if(c == EOF) break;

      // fputc(c, output);
      // putchar(c);
      if(c == '\n')
      {
         yylloc.end.charPos = 1;
         yylloc.end.pos++;
         yylloc.end.line++;
      }
      else if (c == '\t')
      {
         yylloc.end.charPos++ /* += 3 - (yylloc.end.col % 3)*/;
         yylloc.end.pos++;
      }
      else
      {
         yylloc.end.charPos++;
         yylloc.end.pos++;
      }
      if(c == '/' && last == '*')
         break;
      last = c;
   }
   yylloc.start = yylloc.end;
   return 0;
}

int commentCPP()
{
   int c, last = 0;
   for(;;)
   {
      c = input();
      if(c == EOF) break;

      // fputc(c, output);
      // putchar(c);
      if(c == '\n')
      {
         yylloc.end.charPos = 1;
         yylloc.end.pos++;
         yylloc.end.line++;
         break;
      }
      else if (c == '\t')
      {
         yylloc.end.charPos++ /* += 3 - (yylloc.end.col % 3)*/;
         yylloc.end.pos++;
      }
      else
      {
         yylloc.end.charPos++;
         yylloc.end.pos++;
      }
      last = c;
   }
   yylloc.start = yylloc.end;
   return 0;
}

int preprocessor()
{
   int c, last = 0;
   int count = 0;
   char line[1024];

   line[0] = '\0';

   for(;;)
   {
      c = input();
      if(c == EOF) break;

      if(c == '\n')
      {
         yylloc.end.charPos = 1;
         yylloc.end.pos++;
         yylloc.end.line++;
         if(last != '\\')
         {
            char * pointer = line + 1;
            int lineNumber;
            line[count] = 0;
            lineNumber = GetValue(&pointer);
            if(lineNumber)
            {
               char fileName[MAX_LOCATION];
               
               int inOut;
               GetString(&pointer, fileName, MAX_LOCATION);
               inOut = GetValue(&pointer);
                              
               if(inOut == 1)
               {
                  char extension[MAX_EXTENSION];

                  defaultDeclMode = declModeStack[include_stack_ptr] = declMode;

                  GetExtension(fileName, extension);
                  if(!strcmp(extension, "c") || !strcmp(extension, "h"))
                     declMode = defaultDeclMode = defaultAccess;

                  include_stack_ptr++;
               }
               else if(inOut == 2)
               {
                  include_stack_ptr--;
                  defaultDeclMode = declMode = declModeStack[include_stack_ptr];
               }

               yylloc.end.charPos = 1;
               yylloc.end.line = lineNumber;
               //yylloc.end.pos -= count;
               yylloc.end.included = (include_stack_ptr > 0) ? GetIncludeFileID(fileName) : 0;
            }
            /*
            int lineNumber = strtol(line+1, &endPtr, 0);
            if(lineNumber)
            {
               GetString(&
               endPtr

               yylloc.end.charPos = 1;
               yylloc.end.line = lineNumber;
               yylloc.end.pos -= count;
            }
            */
            break;
         }
         count = 0;
      }
      else if (c == '\t')
      {
         yylloc.end.charPos++ /* += 3 - (yylloc.end.col % 3)*/;
         yylloc.end.pos++;
         line[count++] = c;
      }
      else
      {
         yylloc.end.pos++;
         if(c != '\r')
         {
            yylloc.end.charPos++;
            line[count++] = c;
         }
      }
      last = c;
   }   
   yylloc.start = yylloc.end;
   line[count] = 0;

   TrimLSpaces(line, line);
   for(c = 0; line[c] && line[c] != ' '; c++);
   if(!strncmp(line, "include", c))
   {
      char includeFile[MAX_LOCATION] = "";

      strcpy(line, line+c);
      TrimLSpaces(line, line);
      if(line[0] == '\"')
      {
         for(c = 1; line[c]; c++)
         {
            if(line[c] == '\"')
            {
               strncpy(includeFile, line+1, c-1);
               includeFile[c-1] = '\0';
               break;
            }
         }
      }
      else if(line[0] == '<')
      {
         for(c = 1; line[c]; c++)
            if(line[c] == '>')
            {
               strncpy(includeFile, line+1, c-1);
               includeFile[c-1] = '\0';
               break;
            }
      }

      if ( include_stack_ptr >= MAX_INCLUDE_DEPTH )
      {
         fprintf( stderr, "Includes nested too deeply" );
         exit( 1 );
      }

      if(inCompiler || !FindIncludeFileID(includeFile))
      {
         File file = OpenIncludeFile(includeFile);
         if(file)
         {
            char extension[MAX_EXTENSION];

            fileStack[include_stack_ptr] = fileInput;
            locStack[include_stack_ptr] = yylloc;
            defaultDeclMode = declModeStack[include_stack_ptr] = declMode;
            include_stack[include_stack_ptr++] = YY_CURRENT_BUFFER;

            yylloc.start.charPos = yylloc.end.charPos = 1;
            yylloc.start.line = yylloc.end.line = 1;
            yylloc.start.pos = yylloc.end.pos = 0;
            yylloc.start.included = yylloc.end.included = GetIncludeFileID(includeFile);

            GetExtension(includeFile, extension);
            if(!strcmp(extension, "c") || !strcmp(extension, "h"))
               declMode = defaultDeclMode = defaultAccess;

            fileInput = file;
            yy_switch_to_buffer( yy_create_buffer( fileInput, YY_BUF_SIZE ) );
            BEGIN(INITIAL);
         }
         else
            printf("");
      }
   }
   return 0;
}

public void resetScanner()
{
   YY_FLUSH_BUFFER;
   yylloc.start.charPos = yylloc.end.charPos = 1;
   yylloc.start.line = yylloc.end.line = 1;
   yylloc.start.pos = yylloc.end.pos = 0;
   yylloc.start.included = yylloc.end.included = false;

   expression_yylloc.start.charPos = expression_yylloc.end.charPos = 1;
   expression_yylloc.start.line = expression_yylloc.end.line = 1;
   expression_yylloc.start.pos = expression_yylloc.end.pos = 0;
   expression_yylloc.start.included = expression_yylloc.end.included = false;

   type_yylloc.start.charPos = type_yylloc.end.charPos = 1;
   type_yylloc.start.line = type_yylloc.end.line = 1;
   type_yylloc.start.pos = type_yylloc.end.pos = 0;
   type_yylloc.start.included = type_yylloc.end.included = false;

   include_stack_ptr = 0;
}

void resetScannerPos(CodePosition pos)
{
   YY_FLUSH_BUFFER;
   yylloc.start = yylloc.end = pos;
   type_yylloc.start = type_yylloc.end = pos;
   expression_yylloc.start = expression_yylloc.end = pos;
}
