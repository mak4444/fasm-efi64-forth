\ 28.Mar.2000 Andrey Cherezov  Copyright [C] RU FIG 

REQUIRE [IF] ForthLib\tools\CompIF3.4th
REQUIRE [IFNDEF]  ForthLib\tools\ifdef.4th

[IFNDEF] LOCALS_EXIT
REQUIRE CODE ForthLib\asm\gasm64.4th
code LOCALS_EXIT
        pop     %rbx
        add     %rbx,%rsp
        ret
END-CODE
[THEN]

MODULE: vocLocalsSupport

VARIABLE uLocalsCnt
VARIABLE uLocalsUCnt
VARIABLE uPrevCurrent
VARIABLE uAddDepth

: LocalOffs ( n -- offs )
  2+ CELLS uAddDepth @ +
;

BASE @ HEX
 

: RALLOT,  ( n --  )
\ CELLS NEGATE LIT,  S"  RP@ + RP! " EVALUATE
 0 DO 0 LIT,  POSTPONE >R LOOP
 ;

: CompileLocalRec ( u -- )
  LocalOffs   LIT,
  S"  RP@ + " EVALUATE
;

: CompileLocal@ ( n -- )
  CompileLocalRec 
  S" @ " EVALUATE
;

: CompileLocal! ( n -- )
  CompileLocalRec
  S" ! " EVALUATE
;

VARIABLE TEMP-DP
VARIABLE TEMP-LAST

: CompileLocalsInit
  TEMP-DP @ DP ! 
  TEMP-LAST @  LAST !
  uPrevCurrent @ SET-CURRENT
  uLocalsUCnt @ ?DUP
  IF  RALLOT,
  THEN 
  uLocalsCnt @ uLocalsUCnt @ - ?DUP
  IF  0 DO  POSTPONE >R LOOP
 THEN
  uLocalsCnt  @ ?DUP
  IF CELLS LIT,  POSTPONE >R ['] LOCALS_EXIT LIT, POSTPONE >R
  THEN
;


\ : CompileLocal@ ( n -- )
\   LocalOffs LIT, POSTPONE RP+@
\ ;


BASE !

WORDLIST CONSTANT widLocals@

CREATE  TEMP-BUF 1000 ALLOT

: LocalsStartup
  GET-CURRENT uPrevCurrent !
  ALSO vocLocalsSupport
  ALSO widLocals@ CONTEXT ! DEFINITIONS
  HERE TEMP-DP !
  LAST @  TEMP-LAST !
  TEMP-BUF DP ! 
  widLocals@  0!
  uLocalsCnt 0!
  uLocalsUCnt 0!
  uAddDepth 0!
;

: LocalsCleanup
  PREVIOUS PREVIOUS
;


: ProcessLocRec ( "name" -- u )
  [CHAR] ] PARSE
  STATE 0!
  EVALUATE CELL 1- + CELL / \ делаем кратным 4
  -1 STATE ! 
\  DUP uLocalsCnt +!
  uLocalsCnt @
;

: CreateLocArray
  [CHAR] [ PSKIP
  ProcessLocRec
  CREATE ,
  DUP uLocalsCnt +!  
;

: LocalsRecDoes@ ( -- u )
  DOES>  @ CompileLocalRec
;


: LocalsRecDoes@2 ( -- u )
  ProcessLocRec , 
  DUP uLocalsCnt +!
  DOES> @ CompileLocalRec
;

: LocalsDoes@
  uLocalsCnt @ ,
  uLocalsCnt 1+!
  DOES>  @  CompileLocal@
;

: ;; POSTPONE ; ; IMMEDIATE


: ^ 
  ' >BODY @ 
  CompileLocalRec
; IMMEDIATE


: -> ' >BODY @ CompileLocal!  ; IMMEDIATE

WARNING DUP @ SWAP 0!

: AT
  [COMPILE] ^
; IMMEDIATE

: TO ( "name" -- )
  >IN @ PARSE-NAME widLocals@ SEARCH-WORDLIST 1 =
  IF >BODY @ CompileLocal! DROP
  ELSE >IN ! [COMPILE] TO
  THEN
; IMMEDIATE

WARNING !

WARNING @ WARNING 0!
\ ===
\ переопределение соответствующих слов для возможности использовать
\ временные переменные внутри  цикла DO LOOP  и независимо от изменения
\ содержимого стека возвратов  словами   >R   R>
C" DO_SIZE" FIND NIP 0=
[IF] 3 CELLS CONSTANT DO_SIZE
[THEN]


: DO    POSTPONE DO      DO_SIZE              uAddDepth +! ; IMMEDIATE
: ?DO   POSTPONE ?DO     DO_SIZE              uAddDepth +! ; IMMEDIATE
: LOOP  POSTPONE LOOP    DO_SIZE NEGATE       uAddDepth +! ; IMMEDIATE
: +LOOP POSTPONE +LOOP   DO_SIZE NEGATE       uAddDepth +! ; IMMEDIATE
: >R    POSTPONE >R      1 CELLS  uAddDepth +! ; IMMEDIATE
: R>    POSTPONE R>     -1 CELLS  uAddDepth +! ; IMMEDIATE
: RDROP POSTPONE RDROP  -1 CELLS  uAddDepth +! ; IMMEDIATE
: 2>R   POSTPONE 2>R     2 CELLS  uAddDepth +! ; IMMEDIATE
: 2R>   POSTPONE 2R>    -2 CELLS  uAddDepth +! ; IMMEDIATE


\ ===

: ;  LocalsCleanup
    S" ;" EVALUATE
; IMMEDIATE

WARNING !

\ =====================================================================


EXPORT

: {
  
  LocalsStartup
  BEGIN
    BL PSKIP PeekChar DUP [CHAR] \ <> 
                    OVER [CHAR] - <>  AND
                    OVER [CHAR] } <>  AND
                    OVER [CHAR] | <>  AND
                    SWAP [CHAR] ) XOR AND
  WHILE

    CREATE  LocalsDoes@ IMMEDIATE
  REPEAT
  PeekChar >IN 1+! DUP [CHAR] } <>
  IF
     DUP [CHAR] \ =
    SWAP [CHAR] | = OR
    IF
      BEGIN
        BL PSKIP PeekChar DUP 
         DUP [CHAR] - <> 
        SWAP [CHAR] } <>  AND
        SWAP [CHAR] ) XOR AND
      WHILE
        PeekChar [CHAR] [ =
        IF  CreateLocArray  LocalsRecDoes@
        ELSE
             CREATE LATEST DUP C@ + C@
             [CHAR] [ =
             IF  
               LocalsRecDoes@2
             ELSE
               LocalsDoes@ 1
             THEN
        THEN        uLocalsUCnt +!
        IMMEDIATE
      REPEAT
    THEN
    [CHAR] } PARSE 2DROP
  ELSE DROP THEN
  CompileLocalsInit
;; IMMEDIATE

;MODULE
