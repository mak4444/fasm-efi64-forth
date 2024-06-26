\ 345678901234567890123456789012345678901234567890123456789012345678901234567890
.( Autoexec.4th)

\- IMAGEHANDLE &IMAGEHANDLE @ CONSTANT IMAGEHANDLE
\- SYSTAB &SYSTAB @ CONSTANT SYSTAB
\- VOLUME &VOLUME @ CONSTANT VOLUME

\- REQUIRED : REQUIRED ( waddr wu laddr lu -- )
\- REQUIRED  2SWAP  SFIND  IF DROP 2DROP EXIT  ELSE 2DROP  INCLUDED THEN ;
\- REQUIRE : REQUIRE ( "word" "libpath" -- ) PARSE-NAME PARSE-NAME  REQUIRED ;
\- LAST-NON 0 VALUE LAST-NON
\- :NONAME : :NONAME ( C: -- colon-sys ) ( S: -- xt ) \ 94 CORE EXT
\- :NONAME  HERE DUP TO LAST-NON [COMPILE] ] ;
\- RECURSE : RECURSE \ Compile a call to the current (not yet finished) definition.
\- RECURSE	LAST @ NAME> LAST-NON UMAX COMPILE, ; IMMEDIATE
 ERRFILENAME 0!
 REQUIRE VIEWS_SEARCH ForthLib\tools\defview.4th 

 REQUIRE [IF] ForthLib\tools\CompIF3.4th
 REQUIRE [IFNDEF]  ForthLib\tools\ifdef.4th
 REQUIRE CASE-INS ForthLib\lib\caseins.4th 
 REQUIRE STRUCTURES{ ForthLib\lib\structures.4th 
: 4FIELD 3 + 3 ANDC 4 FIELD ;
: 8FIELD 7 + 7 ANDC 8 FIELD ;
: *FIELD 8FIELD ;
: @FIELD $F + $F ANDC 8 FIELD ;
[IFNDEF] WWWW
[THEN]

 FLOAD ForthLib\include\eficon.4th 

 1 SYSTAB ST*CONOUT @ DUP EnableCursor @ 2XSYS DROP

3 VALUE COLOR@
: S_COLOR! ( n -- )
 DUP  SYSTAB ST*CONOUT @ DUP
 OI.SetAttribute @ 2XSYS THROW
 TO COLOR@ ;

\+ COLOR! ' S_COLOR! TO COLOR!
\- COLOR! ' S_COLOR! ->DEFER COLOR!
\- COLOR@ : COLOR@ TEXTOUTPUTMODE tm.Attribute C@ ;

\- EFI_BLUE   1 CONSTANT EFI_BLUE  
\- EFI_GREEN  2 CONSTANT EFI_GREEN 
\- EFI_RED    4 CONSTANT EFI_RED
\- EFI_BRIGHT 8 CONSTANT EFI_BRIGHT   
: >BG 4 << ; 3 COLOR! 

 REQUIRE EFI_ERROR_DO ForthLib\ext\error.4th 
\- SCFASET : SCFASET ( cfa adr len -- ) SNFAFIND DUP 0= IF -13 THROW THEN NAME>C ! ;
\- CFASET : CFASET  ( cfa <name> -- )  PARSE-NAME SCFASET ;
\- LABSET : LABSET  ( cfa -- )  HERE CFASET ;

\- \EOF : \EOF  ( -- )  BEGIN REFILL 0= UNTIL  POSTPONE \ ;
\- CURSOR ' NOOP ->DEFER CURSOR


 REQUIRE SEE ForthLib\asm\disgasm.4th 
\+ F_?.NAME>S ' F_?.NAME>S  TO ?.NAME>S
 FLOAD ForthLib\tools\words.4th 

 FLOAD ForthLib\include\efidef.4th 
 FLOAD ForthLib\include\efiapi.4th 
 FLOAD ForthLib\include\efiprot.4th 

\ - ROWS $28 VALUE ROWS
\ - COLS $80 VALUE COLS

\- ROWS 25 VALUE ROWS
\- COLS 80 VALUE COLS

\ 2 SYSTAB ST*CONOUT @ IO*Mode @ tm.Mode L!

: GETMAXXY0 ( -- x y flg )
  0 >R RP@  0 >R RP@
  SYSTAB ST*CONOUT @ IO*Mode @ tm.Mode L@
  SYSTAB ST*CONOUT @ DUP QueryMode @ 4XSYS 2R> ROT ;

 GETMAXXY0
 [IF]  2DROP
 [ELSE] TO COLS TO ROWS
 [THEN]

: NGETMAXXY ( n  -- x y flg )
  0 >R RP@  0 >R RP@ ROT
  SYSTAB ST*CONOUT @ DUP QueryMode @ 4XSYS 2R> ROT ;

1 \ TEXTOUTPUTMODE tm.CursorRow 0=
[IF]

ROWS COLS * CONSTANT MON_SIZE
 
0  VALUE GETX
ROWS 2- VALUE GETY

: GETXY  GETX GETY ;
: SETXY2
  2DUP SWAP SYSTAB ST*CONOUT @ DUP
  SetCursorPosition @ 3XSYS DROP
 TO GETY TO GETX ;

\+ SETXY ' SETXY2 TO SETXY
\- SETXY ' SETXY2 ->DEFER SETXY

: XY_EMIT_SET ( c -- )
  DUP	$D = IF  DROP 0		TO GETX BREAK
	$A = IF GETY 1+ ROWS 1- UMIN TO GETY BREAK
  GETY COLS * GETX + 1+
  OVER 8  = IF 2- 0MAX THEN
  MON_SIZE 1- UMIN 
  COLS /MOD TO GETY TO GETX ;

: S_EMIT DUP  [ ' EMIT DEFER@ COMPILE, ]  XY_EMIT_SET ;

' S_EMIT TO EMIT 

[THEN]

\ - GETXY : GETXY  TEXTOUTPUTMODE tm.CursorColumn L@  TEXTOUTPUTMODE tm.CursorRow L@ ;

: BASETXT_MOD
 [ ' COLOR! DEFER@ LIT, ] TO COLOR!
 [ ' COLOR@ DEFER@ LIT, ] TO COLOR@
 [ ' EMIT DEFER@ LIT, ] TO EMIT
 [ ' TYPE DEFER@ LIT, ] TO TYPE
  ['] NOOP TO CURSOR
;

 REQUIRE CODE ForthLib\asm\gasm64.4th
\- DROP, : DROP,	$086D8D4800458B48 , ;
\- DUP, : DUP,	$00458948F86D8D48 , ;

REQUIRE 1XSYS ForthLib/lib/syscall.4th 

[IFNDEF] ALLOCATE
: ALLOCATE ( u -- a-addr ior ) 
 0 >R RP@ SWAP 
 EfiBootServicesData
 BOOTSERV BS_AllocatePool @ 3XSYS R> SWAP ;
[THEN]

\- FREE : FREE ( a-addr -- ior ) BOOTSERV BS_FreePool @ 1XSYS ;

FLOAD ForthLib\GOP\gop.4th 
FLOAD ForthLib\rus\koi8.4th 
FLOAD ForthLib\GOP\gremit.4 
FLOAD ForthLib\rus\rkey.4th

 REQUIRE CO ForthLib\tools\acc.4th CO

 REQUIRE VIEW ForthLib\tools\view.4th 

: PAGE   SYSTAB ST*ConOut @  DUP ClearScreen @ 1XSYS DROP ;


[IFNDEF] UZTYPE
: UZTYPE ( uzadr -- )
 SYSTAB ST*ConOut @
 DUP OutputString @ 2XSYS DROP ;
[THEN]

\- UZEMIT : UZEMIT ( ucod -- ) >R RP@ UZTYPE RDROP ;

: UZtest BEGIN BEGIN DUP  UZEMIT DUP 2 COLOR!  H.  3 COLOR! 1+ DUP $3F AND 0= UNTIL  KEY BL = UNTIL ;

REQUIRE DIR ForthLib\tools\dir.4th 
REQUIRE FCOPY ForthLib\tools\fcopy.4th 

[IFNDEF] DELETE-FILE
: DELETE-FILE ( c-addr u -- ior )
  R/W OPEN-FILE DUP IF BREAK DROP
  VOLUME F_Delete @ 1XSYS ;
[THEN]

REQUIRE NC ForthLib\tools\NNC.4th
REQUIRE EFICALL ForthLib\lib\eficall.4th 

:NONAME
." WORDS -  List the definition names" CR
." EDIT ( <filename> ) - text editor" CR
." REE  - continue of editing" CR
." E> ( <name> ) - Hyperlink (in EDIT f11 hyperlink, f12 return)" CR
." SEE ( <name> ) - disasm" CR
." DISA ( addr -- ) - disasm" CR
." NC - file manager"  CR
; ->DEFER HELP              

LASTSTP: KETST
LASTSTP: : KETST BEGIN KEYEX DUP h. KEYDATA KeyShiftState L@ h.  $20 OR 'q' = UNTIL ;
 LASTSTP: fload work\asmtst.4th 
 LASTSTP: ' GCCOUTPUTRESET DISA 
LASTSTP: EFICALL RedHatBin\bltgrid.efi
LASTSTP: e> see 
LASTSTP: DIR ForthSrc 
LASTSTP: CUR_DIR 44 dump
LASTSTP: BASETXT_MOD
LASTSTP: GEMIT_MOD
LASTSTP: nc
LASTSTP: 0 NGETMAXXY H. H. H.
\ 5 TO MAX-VIEW-Y

.( TRY) CR
.( SEE ABS) CR
.( ' +  DISA  \ Esc - quit anyother - continue ) CR
.( CD 1\ \ change directory. 1 - nunber of disk)  CR
.( NC \ file manager)  CR
.( E> SEE  \ in EDIT f11 hyperlink, f12 return ) CR   
.( EFICALL RedHatBin\bltgrid.efi \ ELF file run) CR

\ dsdsdsd

