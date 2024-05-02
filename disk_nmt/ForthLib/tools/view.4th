CR .( S" VIEW" *INCL )
\+ TR2SEE ' TR2SEE TO 'TR4BR
\+ NGRCR ' NGRCR	TO CR

REQUIRE [IF]            ~MAK\CompIF1.f
REQUIRE CASE            ~MAK\case.f
REQUIRE [IFNDEF]        ~nn\lib\ifdef.f

\- $VIEW	DEFER $VIEW ' 2DROP TO $VIEW
\- $EDIT	DEFER $EDIT ' 2DROP TO $EDIT

\- VSHRIFT@ 14 CONSTANT VSHRIFT@

0 VALUE  ?RUS
0 VALUE FILECHANGED?

\- BETWEEN : BETWEEN  ( n1 min max -- f )  1+ WITHIN ;

0 VALUE CLIP_KS
0 VALUE CLIP_X

$0 VALUE V_DELAY1
$0 VALUE V_DELAY2

\- CTRL_KEY2_PAGE_UP   0x189 CONSTANT CTRL_KEY2_PAGE_UP
\- CTRL_KEY2_PAGE_DOWN 0x191 CONSTANT CTRL_KEY2_PAGE_DOWN
\- CTRL_KEY2_HOME 0x187 CONSTANT CTRL_KEY2_HOME
\- CTRL_KEY2_END  0x18F CONSTANT CTRL_KEY2_END

\ CREATE T_IMG    VIDBUF-SIZE ALLOT

\- /STRING : /STRING DUP >R - SWAP R> + SWAP ;

[IFNDEF] SCAN
: SCAN ( adr len char -- adr' len' )
\ Scan for char through addr for len, returning addr' and len' of char.
        >R 2DUP R> -ROT
        OVER + SWAP
        ?DO DUP I C@ =
                IF LEAVE
                ELSE >R 1 -1 D+ R>
                THEN
        LOOP DROP ;
[THEN]

0 VALUE H_SCROLLING

: MCOLS COLS  H_SCROLLING + ;

[IFNDEF] VIEW-SIZE 0x40000 CONSTANT VIEW-SIZE
[THEN]

[IFNDEF] ON : ON TRUE SWAP ! ;
[THEN]

[IFNDEF] OFF : OFF FALSE SWAP ! ;
[THEN]

[IFNDEF] BREAK : BREAK POSTPONE EXIT POSTPONE THEN ; IMMEDIATE
[THEN]

\- U<= : U<= U> 0= ;

1 8 LSHIFT CONSTANT MAX#ED_FN
1 6 LSHIFT CONSTANT SIZE#ED_FN

$FFFF CONSTANT UNDO_B_SIZE
222
\ DUP 2* CONSTANT  UNDO_S_SIZE
CELL 2+ * CONSTANT  UNDO_A_SIZE
\- VDP><DDP : VDP><DDP ;
\- DALLOT : DALLOT ALLOT ;
VDP><DDP
\- VIEW_BUF VARIABLE VIEW_BUF  VIEW-SIZE CELL+ DALLOT
\- CLIPBOARD VARIABLE CLIPBOARD  VIEW-SIZE CELL+ DALLOT
VARIABLE EDIT_FN_B SIZE#ED_FN	MAX#ED_FN * DALLOT
EDIT_FN_B SIZE#ED_FN	MAX#ED_FN * ERASE
VARIABLE EDIT_SL_B 2 CELLS	MAX#ED_FN * DALLOT

VARIABLE UNDO_BODY UNDO_B_SIZE 1+ DALLOT
VARIABLE UNDO_A_BUF  UNDO_A_SIZE CELL+ 2+ CELL+ DALLOT
\ VARIABLE UNDO_S_BUF  UNDO_S_SIZE 2+ DALLOT
VDP><DDP

UNDO_A_BUF CELL+ CONSTANT UNDO_S_BUF

  VIEW_BUF -1 =
[IF]   VIEW-SIZE ALLOCATE THROW TO VIEW_BUF
[THEN]


VIEW_BUF  VIEW-SIZE ERASE

0 VALUE #ED_FN

: >UNDO_B_BUF ( c -- )
 UNDO_BODY UNDO_BODY 1+ UNDO_B_SIZE CMOVE>
 UNDO_BODY C! ;

: >UNDO_BUF ( adr len -- )
\ UNDO_S_BUF UNDO_S_BUF 2+ UNDO_S_SIZE CMOVE>

 UNDO_A_BUF UNDO_A_BUF CELL+ 2+ UNDO_A_SIZE CMOVE>
 UNDO_S_BUF W!
 UNDO_A_BUF !
 ;

: >UNDO ( adr len -- )
 >R
 UNDO_BODY UNDO_BODY R@ + UNDO_B_SIZE R@ - CMOVE>
 DUP  UNDO_BODY R@ + UNDO_BODY  DO COUNT I C!  LOOP DROP \ C@ UNDO_BODY C!
 R>  >UNDO_BUF
;

: EDIT_FN  EDIT_FN_B #ED_FN SIZE#ED_FN * + ;
: EDIT_SL  EDIT_SL_B #ED_FN 2 CELLS * + ;

: NEXT_F #ED_FN 1+ MAX#ED_FN 1- AND TO #ED_FN ;
: LAST_F
BEGIN
 #ED_FN 1- MAX#ED_FN 1- AND TO #ED_FN
 EDIT_FN @
UNTIL
 ;

: EDIT_FN!  ( ADDR LEN -- )
 DUP 2+ SIZE#ED_FN U> IF 2DROP BREAK
    EDIT_FN $!   ;

S" autoexec.4th" EDIT_FN!
0 0 EDIT_SL 2!

[IFNDEF] LPLACE
: LPLACE         ( addr len dest -- )
	2DUP 2>R
	CELL+ SWAP MOVE
	2R> ! ;
[THEN]

\- UCOMPARE : UCOMPARE COMPARE ;

[IFNDEF] USEARCH
: USEARCH ( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 flag ) \ 94 STRING
    2>R 2DUP
    BEGIN
      DUP 1+ R@ >
    WHILE
      OVER 2R@ TUCK UCOMPARE 0=
      IF RDROP RDROP 2SWAP 2DROP TRUE EXIT THEN
      1- SWAP 1+ SWAP
    REPEAT RDROP RDROP 2DROP 0
;
[THEN]

\- LCOUNT : LCOUNT   CELL+ DUP CELL- @ ; 
\- CLIPBOARD! : CLIPBOARD! ( adr len -- )	CLIPBOARD LPLACE ;
\- CLIPBOARD@ : CLIPBOARD@ ( -- adr len )	CLIPBOARD LCOUNT ;
\- CLIPBOARD# : CLIPBOARD# ( -- len )		CLIPBOARD @ ;
\- CLIPBOARD? : CLIPBOARD? ( -- len )		CLIPBOARD @ ;

\- VIEWCOLOR 0x1F VALUE VIEWCOLOR
VARIABLE VIEW-MAX-POINT

ROWS 6 - VALUE MAX-VIEW-Y

VARIABLE VIEW-#Y0
VARIABLE VIEW-X
VARIABLE VIEW-Y
VARIABLE VIEW0-X
VARIABLE VIEW0-Y

VIEW_BUF VALUE ADDR_CUR
VARIABLE BLOCK-BIG
VARIABLE BLOCK-END
VARIABLE BLOCK-#

VARIABLE XBLOCK-BIG
VARIABLE YBLOCK-BIG
VARIABLE XBLOCK-END
VARIABLE YBLOCK-END


DEFER VVVEMIT
DEFER VVVGETXY_V
DEFER VVVSETXY_V

:  VVVGETXY ( -- x y )  VVVGETXY_V SWAP H_SCROLLING + SWAP 1- ;
:  VVVSETXY ( x y -- )  1+ SWAP H_SCROLLING - SWAP VVVSETXY_V  ;

: MOCK_SETXY
  2dup setxy
  VIEW0-Y !  VIEW0-X ! ;
: MOCK_GETXY  VIEW0-X @  VIEW0-Y @ ;

: CUR@_V  ( -- N )
  VVVGETXY_V  MCOLS * + ;

: CUR@  ( -- N )
  VVVGETXY  MCOLS * + ;

:  MOCK_EMIT ( c -- )
DROP  VVVGETXY_V  \  SETXY 
 SWAP 1+ SWAP 
 VVVSETXY_V
;

: VIEW_CUR@  ( -- N )
 VIEW-X @ VIEW-Y @ ( 1+) MCOLS *  + ;

0 VALUE MOCK_FLG

: C_ED ( -- )
   GETXY
 YBLOCK-BIG @  YBLOCK-END @ 2DUP U> IF SWAP THEN

 BETWEEN \ WITHIN
   IF  XBLOCK-BIG @  XBLOCK-END @ 2DUP U> IF SWAP THEN  WITHIN  0x22 AND COLOR@ XOR  COLOR!
   ELSE DROP
   THEN
;

: EMIT_ED ( n -- )
 COLOR@ SWAP
 C_ED  EMIT 
 COLOR!
 ;


: REAL_OUT
        ['] EMIT_ED TO  VVVEMIT
        [']  GETXY TO  VVVGETXY_V
        [']  SETXY TO  VVVSETXY_V
        FALSE TO MOCK_FLG
;

: MOCK_OUT

        [']  MOCK_EMIT TO  VVVEMIT
        [']  MOCK_GETXY TO  VVVGETXY_V
       [']  MOCK_SETXY TO  VVVSETXY_V
        TRUE TO MOCK_FLG
        GETXY  MOCK_SETXY
;

:  MOCK1_EMIT ( c -- )
 DROP  VVVGETXY_V
 COLS * +  1+  COLS /MOD
 VVVSETXY_V
;

: CLP_EMIT

\  VVVGETXY
 MOCK_GETXY
 YBLOCK-BIG @  YBLOCK-END @ 2DUP U> IF SWAP THEN
 BETWEEN


   IF  XBLOCK-BIG @  XBLOCK-END @ 2DUP U> IF SWAP THEN  WITHIN 
	IF  DUP CLIPBOARD LCOUNT + C!  CLIPBOARD 1+!
	THEN
   ELSE DROP
   THEN
  MOCK1_EMIT
;  

: CLP_OUT
 ['] CLP_EMIT TO  VVVEMIT
 ['] MOCK_GETXY TO  VVVGETXY_V
 ['] MOCK_SETXY TO  VVVSETXY_V
  0 TO MOCK_FLG
        GETXY  MOCK_SETXY
;

: S_MOCK_OUT
 SHIFT@ IF BREAK
  MOCK_OUT
;

\ ' EMIT TO  VVVEMIT

: EMITTAB

  SHIFT@ IF THEN

  DUP 9 =
        IF DROP
         BEGIN BL VVVEMIT VVVGETXY 1+ DROP 7 AND 0=
		VVVGETXY_V DROP 0= OR
\		VVVGETXY_V DROP COLS 1- U> OR  \  DUP IF 1 EMIT THEN
         UNTIL
        ELSE  VVVEMIT
        THEN ;

: AA_DEL ( ADDR1 ADDR2 -- )
  2DUP DUP  VIEW_BUF - VIEW-MAX-POINT @ - NEGATE CMOVE
  - NEGATE VIEW-MAX-POINT +!
   ADDR_CUR VIEW_BUF VIEW-MAX-POINT @ + UMIN TO ADDR_CUR
 -1 TO FILECHANGED? ;

: AA-DEL ( ADDR1 ADDR2 -- )
  2DUP TUCK - >UNDO  AA_DEL ;

: PBACK ( ADDR -- )
  DUP 1- AA_DEL ;

0 VALUE VIEW-EMIT-END

: LINE-END?  ( ADDR -- ADDR+1 C FLAG )

 COUNT
 DUP 0xD = IF DROP  DUP  FILECHANGED? >R PBACK R> TO FILECHANGED? 1- COUNT  THEN
 DUP 0xA = IF FALSE EXIT THEN
 OVER VIEW_BUF - VIEW-MAX-POINT @ U<= ;

: COLOR-SET   ( ADDR -- ADDR )
  DUP BLOCK-BIG @  BLOCK-END @  WITHIN  0x33 AND VIEWCOLOR XOR  COLOR! ;

: VIEW-EMIT  ( ADDR C -- ADDR )
\  COLOR-SET
 VIEW-EMIT-END IF DROP BREAK
 VVVGETXY DROP MCOLS 1-  U< 0=  MOCK_FLG 0= AND
        IF     \ COLOR@ 0xFF XOR COLOR!  DROP '>' VVVEMIT
               \ COLOR@ 0xFF XOR COLOR!
		 -1 TO VIEW-EMIT-END VVVEMIT
	BREAK
  EMITTAB VVVGETXY_V DROP 0=  TO VIEW-EMIT-END  ;

: VIEW_PUT   ( c -- )
	VIEW-X @ MCOLS 2- -  0MAX H_SCROLLING + TO H_SCROLLING

	ADDR_CUR DUP DUP 1+ DUP TO ADDR_CUR
        OVER VIEW_BUF - VIEW-MAX-POINT @  - NEGATE
        CMOVE>  C!
	VIEW-MAX-POINT @ 1+ VIEW-SIZE UMIN VIEW-MAX-POINT !
;

0 VALUE X_OFFSET1
0 VALUE X_OFFSET2
0 VALUE X_OFFSET3
0 VALUE X_OFFSET4

: SPACES_ED       ( N  -- )
    0MAX COLS MIN ?DUP
    IF      0 ?DO BL VVVEMIT LOOP 
    THEN
;

:  VIEW-LINE-FROM ( adr -- adr )
  VIEW_CUR@ CUR@ U>=
  IF   VIEW-X @  TO X_OFFSET1  VVVGETXY DROP  TO X_OFFSET2
  THEN
  MOCK_FLG IF
 0  VIEW0-Y @ 1+ MOCK_setxy
 BREAK

   VIEW-EMIT-END IF BREAK
  MCOLS  VVVGETXY DROP -
 SPACES_ED
\ MOCK_getxy DROP IF  0  VIEW0-Y @ 1+ MOCK_setxy THEN
\ getxy DROP IF  CR THEN
;

: BLOCK-SET
 SHIFT@
  MOCK_FLG AND
  IF XBLOCK-END 0! XBLOCK-BIG 0!

        BLOCK-BIG @ ADDR_CUR =
        IF DUP BLOCK-BIG ! ELSE

        BLOCK-END @ ADDR_CUR =
        IF DUP BLOCK-END !
        THEN    THEN

        BLOCK-END @ BLOCK-BIG @ U<
 IF
        BLOCK-END @ BLOCK-BIG @
        BLOCK-END ! BLOCK-BIG !
 THEN

  THEN ;

: H_SCROLL_DO ( adr -- adr+ )
	VIEW_CUR@ CUR@ U>=
        IF   0  TO X_OFFSET3
	THEN
   H_SCROLLING
   BEGIN  DUP
   WHILE  SWAP  COUNT
	DUP  $A =
	IF  DROP VIEW_CUR@ CUR@ U>=
        	IF SWAP TO X_OFFSET3
		ELSE NIP
		THEN 1-  0 
	ELSE
	9 =
	IF   SWAP
		H_SCROLLING - NEGATE  8 / 1+ 8 *
		H_SCROLLING - NEGATE  
		DUP 0<
		IF  DROP 1- 0
		THEN	
	ELSE
	  SWAP 1-
	THEN	THEN
   REPEAT DROP ;

: VIEW-LINE-XY2A-. ( ADDR -- ADDR1 )
  0 TO VIEW-EMIT-END
	H_SCROLL_DO
   BEGIN
	  VIEW_CUR@ CUR@ U>=
          IF
		BLOCK-SET DUP TO ADDR_CUR 
		0 TO X_OFFSET1
		0 TO X_OFFSET2
          THEN

  COLOR-SET
  LINE-END?
   WHILE  VIEW-EMIT
   REPEAT
	DROP
  VIEW-LINE-FROM
    ADDR_CUR VIEW-MAX-POINT @ VIEW_BUF + UMIN TO ADDR_CUR
;

: VIEW-LINE-A2XY-. ( ADDR -- ADDR1 )
   0 TO VIEW-EMIT-END
	H_SCROLL_DO
         0 TO X_OFFSET3
   BEGIN  ADDR_CUR OVER U< 0=
          IF VVVGETXY  VIEW-Y ! VIEW-X !
		0 TO X_OFFSET1
		0 TO X_OFFSET2
          THEN
        COLOR-SET
        LINE-END?
   WHILE  VIEW-EMIT
   REPEAT DROP VIEW-LINE-FROM ;

:  VIEW-PAGE-INIT ( -- ADDR MAX-VIEW-Y 0 )
   H_SCROLLING 0 VVVSETXY
   VIEW-#Y0 @ VIEW_BUF +
   MAX-VIEW-Y 0 ;

0 VALUE P_LAST_ADR

: VIEW-PAGE1   \  set VIEW-XY
   VIEW-PAGE-INIT
   ?DO  VIEW-LINE-A2XY-. LOOP TO P_LAST_ADR ;

: BLOCK-NEW
  SHIFT@
  IF
        BLOCK-BIG @ ADDR_CUR <>
        BLOCK-END @ ADDR_CUR <> AND
        IF ( $24 EMIT#) ADDR_CUR DUP BLOCK-BIG ! BLOCK-END !
        THEN
  THEN ;

: NEW_BLK_ED
   VIEW-Y @ 1+ YBLOCK-END @ <>
   VIEW-X @ H_SCROLLING -  XBLOCK-END @ <>   OR
 IF   VIEW-Y @ 1+	DUP YBLOCK-END ! YBLOCK-BIG ! 
      VIEW-X @	H_SCROLLING - DUP XBLOCK-END ! XBLOCK-BIG ! 
 THEN
\  ADDR_CUR DUP BLOCK-BIG ! BLOCK-END !
;

: VIEW-PAGE \ set ADDR_CUR
 VIEW-X @  H_SCROLLING UMIN TO H_SCROLLING
 VIEW-X @  MCOLS 1- - 0MAX H_SCROLLING + TO H_SCROLLING
  BLOCK-NEW
 VIEW-#Y0 @  VIEW_BUF + H_SCROLL_DO  BLOCK-SET 
 TO ADDR_CUR
   VIEW-PAGE-INIT
   DO  VIEW-LINE-XY2A-. LOOP TO P_LAST_ADR ;

variable vvvccc

: NEXT-LINE ( ADDR LEN -- ADDR1 LEN1 )
     0xA SCAN DUP IF  1 /STRING  THEN  ;

: VIEW-#Y0>      ( -- OFFSET LEN )
 VIEW-#Y0 @ DUP VIEW-MAX-POINT @ - NEGATE
 >R VIEW_BUF + R> ;

: >VIEW_UP ( offset -- )
        1-
        DUP
        IF      BEGIN 1-
                        DUP VIEW_BUF + C@ 0xA =
                        OVER 0=    OR
                UNTIL
	        DUP VIEW_BUF + C@ 0xA = IF 1+ THEN
        THEN
        VIEW-#Y0  ! ;

20 CONSTANT VSEARCHBUFLEN
VARIABLE VSEARCHBUF VSEARCHBUFLEN DALLOT
0 VALUE VSEARCHLEN
0 VALUE VSEARCHX
\- DUTYFILENAME VARIABLE DUTYFILENAME 0x104 DALLOT
VARIABLE DUTYFILENAMEBAK 0x104 DALLOT
0 VALUE VIEWFID

1 [IF]
: VIEWFILEREAD ( -- flg )

  DUTYFILENAME COUNT
  R/O OPEN-FILE 
  IF    DROP
	  CR ." do you wish to create "  DUTYFILENAME COUNT TYPE ."  file? Y/N" 
	KEY 0x20 OR 'y' <> IF -1 BREAK
	DUTYFILENAME COUNT R/W CREATE-FILE THROW TO VIEWFID
	S"  " VIEWFID WRITE-FILE THROW  0 
  ELSE	
	TO VIEWFID
	VIEW_BUF VIEW-SIZE VIEWFID  READ-FILE THROW
  THEN
	 VIEW-MAX-POINT !
  0 TO FILECHANGED?
  VIEWFID CLOSE-FILE DROP
  0
;
[THEN]

[IFNDEF] $MEM2FILE

: $MEM2FILE ( addr len c-addr u -- )
\ F7_ED
  R/W  CREATE-FILE THROW
  >R
    R@ WRITE-FILE DROP

   R> CLOSE-FILE  THROW ;
[THEN]

: EDITFILESAVE
  VIEW_BUF VIEW-MAX-POINT @  DUTYFILENAME COUNT $MEM2FILE
  0 TO FILECHANGED? ;

:   P_ADDR_CUR
   ADDR_CUR VIEW-#Y0 @ VIEW_BUF + P_LAST_ADR  WITHIN 0=
   IF   ADDR_CUR VIEW_BUF - VIEW-#Y0 !
        6 0     
       DO   VIEW-#Y0 @  >VIEW_UP
	 VIEW-#Y0 @ 0= IF LEAVE THEN
        LOOP
   THEN ;

: ALT_F3_DO
 ADDR_CUR 1+ VIEW-MAX-POINT @ VIEW_BUF - ADDR_CUR 1+ + 
			 VSEARCHBUF VSEARCHLEN USEARCH
			IF DROP TO ADDR_CUR   P_ADDR_CUR
ADDR_CUR DUP BLOCK-BIG ! VSEARCHLEN + BLOCK-END ! 
  VIEW-PAGE1
			ELSE 2DROP
			THEN ;

\- BACK_BKEY 0x8 CONSTANT BACK_BKEY

: PAGE_UP_DO
   VIEW-#Y0 @
	IF MAX-VIEW-Y 0
		?DO VIEW-#Y0 @  >VIEW_UP
			VIEW-#Y0 @ 0= IF LEAVE THEN
		LOOP
	THEN ;

: VIEW_DOWN
 VIEW-Y @  MAX-VIEW-Y 1- U<
	IF    VIEW-Y 1+!    S_MOCK_OUT
	ELSE  VIEW-#Y0> \ OFFSET LEN
	        MAX-VIEW-Y 0 ?DO NEXT-LINE LOOP NIP
	        IF  VIEW-#Y0>  NEXT-LINE DROP
	            VIEW_BUF - VIEW-#Y0   !
	        THEN
	THEN
                       MOCK_OUT VIEW-PAGE
\			REAL_OUT VIEW-PAGE

\ VIEW-PAGE
;
1 [IF]
: VIEW-DEL_PUT
\ ADDR_CUR 1+ ADDR_CUR AA-DEL
 ADDR_CUR C@ >UNDO_B_BUF
 $FE >UNDO_B_BUF
 ADDR_CUR 1 >UNDO_BUF
 ADDR_CUR C!
 ADDR_CUR 1+ TO ADDR_CUR
;

[ELSE]

: VIEW-DEL_PUT
 ADDR_CUR 1+ ADDR_CUR AA-DEL
 $FF >UNDO_B_BUF
 ADDR_CUR 1 >UNDO_BUF	
 VIEW_PUT
;
[THEN]

: VIEW-PUT   ( c -- )
 DUP $A =
 IF	VIEW-Y @ MAX-VIEW-Y 1- = 
	if VIEW-#Y0>  NEXT-LINE DROP
	   VIEW_BUF - VIEW-#Y0   !
	then
 ELSE \ CURSOR% @ 5 U>  ADDR_CUR C@ $A <> AND
\	IF  VIEW-DEL_PUT
\ 	BREAK
 THEN

 $FF >UNDO_B_BUF
 ADDR_CUR 1 >UNDO_BUF	
 VIEW_PUT
;

: VVVREAD ( y -- )	VIEW-#Y0 0! 
				VIEWFILEREAD IF THEN
				DUP 4 - 0 MAX 0
				?DO VIEW-#Y0> \ OFFSET LEN
				   MAX-VIEW-Y 0
				   ?DO NEXT-LINE LOOP NIP
				        IF VIEW-#Y0>  NEXT-LINE DROP
				           VIEW_BUF - VIEW-#Y0   !
				        THEN
				LOOP
				3 MIN  VIEW-Y !
				VIEW-PAGE ;

: VIEW_TYPE  ( adr len -- )
	>R
	ADDR_CUR DUP r@ + DUP TO ADDR_CUR
        OVER VIEW_BUF - VIEW-MAX-POINT @  - NEGATE	CMOVE>
	ADDR_CUR ADDR_CUR R@ -	DO COUNT I C! LOOP DROP
	VIEW-MAX-POINT @ R> + VIEW-SIZE UMIN VIEW-MAX-POINT ! ;

VARIABLE ED_TIB $100 ALLOT

: CTRL_E
	0 ROWS 1- SETXY
	15 TO MAX-VIEW-Y
	TUCK - 
 ED_TIB $!
 ED_TIB COUNT ['] EVALUATE
\ TRGO TRACE
 CATCH ." ERR=" . \ ERROR_DO
	." (" .S ." )" CR
	VIEW-X 0!
	VIEW_DOWN
	REAL_OUT VIEW-PAGE
;

: CUR_LINE ( -- b-adr end-adr )
        ADDR_CUR 
	BEGIN	DUP VIEW_BUF VIEW-MAX-POINT @ + U< 0= DUP 0=
		IF DROP COUNT $A = DUP 0=
			IF DROP  0  THEN
		THEN
	UNTIL
        ADDR_CUR 
	BEGIN	VIEW_BUF OVER U< DUP
		IF DROP 1- DUP C@ $A <> DUP 0=
			IF DROP 1+ 0 THEN
		THEN  0=
	UNTIL
;

: VIEW-ALLOC ( len -- adr )
  DUP>R	IF
		$FF >UNDO_B_BUF
		ADDR_CUR r@ >UNDO_BUF
		ADDR_CUR DUP R@ +
                OVER VIEW_BUF - VIEW-MAX-POINT @  - NEGATE
		CMOVE>               \ allocate memory

  V_DELAY2 0 ?DO LOOP
		R@ VIEW-MAX-POINT +!  
	THEN	ADDR_CUR DUP R> +  TO ADDR_CUR
;

\ : VIEW-SPACES  0 ?DO BL VIEW-PUT LOOP  ;
: VIEW-SPACES  ( len -- ) DUP VIEW-ALLOC  SWAP BLANK ;

: VIEW-PUTS ( adr len -- ) 
   X_OFFSET1
  X_OFFSET2 -
  X_OFFSET3 + TO   X_OFFSET4 
  X_OFFSET4  0MAX VIEW-SPACES
  DUP   VIEW-ALLOC  SWAP  CMOVE
 -1 TO FILECHANGED? ;

:  CLIPBOARD_TYPE
	CLIPBOARD? VIEW-MAX-POINT @ + VIEW-SIZE U<
	CLIPBOARD@ SWAP @ +  CLIP_KS = AND
	IF	VIEW-Y @
	   CLIPBOARD@
	   BEGIN DUP
	   WHILE DUP  CLIP_X U<
		IF    VIEW-PUTS 0 0
		ELSE  OVER CLIP_X VIEW-PUTS  CLIP_X /STRING
		THEN  VIEW_DOWN
	   REPEAT 2DROP
	   VIEW-Y !
           BLOCK-END @ BLOCK-BIG !

		REAL_OUT VIEW-PAGE

	ELSE	ADDR_CUR BLOCK-BIG ! CLIPBOARD@ VIEW-PUTS
		ADDR_CUR BLOCK-END ! VIEW-PAGE1  
	THEN ;

\- 1-! : 1-!  -1 SWAP +! ;

\- ANDC  : ANDC INVERT AND ;

: FUNC-KEY ( C -- )

            CASE

[IFDEF] VIEWS_SEARCH
  KEY2_F11	OF FILECHANGED? IF EDITFILESAVE THEN
		0 0 SETXY
			ADDR_CUR
			BEGIN DUP C@ BL U>
			WHILE 1-
			REPEAT 1+
			ADDR_CUR
			BEGIN DUP C@ BL U>
			WHILE 1+
			REPEAT
			OVER -  CR ." <" 2DUP TYPE ." |"
			VIEWS_SEARCH ?DUP DUP H.  ." |"
			IF  COUNT	2DUP TYPE ." |"
    DUTYFILENAME COUNT EDIT_FN!
       ADDR_CUR VIEW-#Y0 @ EDIT_SL 2!
		NEXT_F  DUTYFILENAME $! VIEW-X 0! 
		 $C - L@ VVVREAD
			THEN 
		ENDOF
[THEN]
  KEY2_F12	OF	LAST_F EDIT_FN COUNT DUTYFILENAME $!
			VIEWFILEREAD IF THEN

\			EDIT_SL 2@ SWAP VIEW-X ! VVVREAD
			EDIT_SL 2@ VIEW-#Y0 ! TO ADDR_CUR
			S_MOCK_OUT VIEW-PAGE1  REAL_OUT VIEW-PAGE			
		ENDOF

  KEY2_F9	OF
\  VIEWS_SEARCH ?DUP
\		    IF  SWAP $C - L@ TO VIEW#Y0 COUNT $EDIT  THEN  
		ENDOF

 KEY2_LEFT      OF  VIEW-X @
                        IF      -1  VIEW-X +!
                        MOCK_OUT VIEW-PAGE
			ELSE

				ADDR_CUR VIEW_BUF -
		                IF MOCK_OUT
					ADDR_CUR  1-  BLOCK-SET
					 TO ADDR_CUR

					 VIEW-PAGE1 \  VIEW-PAGE
                		THEN

                        THEN 
			REAL_OUT VIEW-PAGE
		ENDOF

 KEY2_RIGHT     OF \  VIEW-X @  MCOLS 1- U<  IF
			VIEW-X 1+!
                        MOCK_OUT VIEW-PAGE
			REAL_OUT VIEW-PAGE

                    \    THEN
		ENDOF

 KEY2_LEFT CTL+ OF \ Crrl <-
		   ADDR_CUR VIEW_BUF -
                  IF   BLOCK-NEW \	 TRGO TRACE
			ADDR_CUR 
			BEGIN DUP C@ BL > SWAP 1- \ c adr
				TUCK  C@ BL > XOR
			UNTIL
			BLOCK-SET  TO ADDR_CUR S_MOCK_OUT VIEW-PAGE1 \ VIEW-PAGE
                  THEN
           ENDOF

  KEY2_RIGHT CTL+ OF \ Crrl ->
	   ADDR_CUR   VIEW_BUF VIEW-MAX-POINT @ +  U<
                  IF   BLOCK-NEW \	 TRGO TRACE
			ADDR_CUR 
			BEGIN DUP C@ BL > SWAP 1+ \ c adr
				TUCK  C@ BL > XOR
			UNTIL
			BLOCK-SET  TO ADDR_CUR S_MOCK_OUT VIEW-PAGE1 \ VIEW-PAGE
                  THEN
           ENDOF

 KEY2_F1    OF	0 0 SETXY
\ CR ."	Left			Character left	"
\ CR ."	Right			Character right	"
\ CR ."	Up			Line up		"
\ CR ."	DownLine		down		"
CR ."	Ctrl-Left		Word left	"
CR ."	Ctrl-Right		Word right	"
\  TAB  Ctrl-Up"		TAB	." Scroll screen up
\  TAB  Ctrl-Down"		TAB	." Scroll screen down
\ CR ."	PgUp			Page up		"
\ CR ."	PgDn			Page down	"
\ CR ."	Home			Start of line	"
\ CR ."	End			End of line	"
CR ."	Ctrl-Home, Ctrl-PgUp	Start of file	"
CR ."	Ctrl-End, Ctrl-PgDn	End of file	"

\ CR ."	Del			Delete char	"
\ CR ."	BS			Delete char left"
CR ."	Ctrl-Y			Delete line	"
CR ."	Ctrl-Z			Delete line	"
\ CR ."	Ctrl-K#                  Delete to end of line
\ CR ."	Ctrl-BS#                 Delete word left
\ CR ."	Ctrl-T, Ctrl-Del#        Delete word right

CR ."	Shift-Cursor keys	Select block	"
CR ."	Alt cursor keys		Select vertical block	"
CR ."	Shift-Ins		Paste block from clipboard	"
CR ."	Shift-Del		Cut block	"
CR ."	Ctrl-Ins		Copy block to clipboard	"
CR ."	F2			Save file	"
CR ."	Ctrl-F			Search		"
CR ."	Alt-F3			Continue search	"
CR ."	F11			Hyperlink	"
CR ."	F12			Previous Hyperlink	"
CR ."	Alt-BS, Ctrl-Z		Undo		"
CR ."	Ctrl-Enter		RUN line	"

KEY DROP VIEW-PAGE

           ENDOF
[IFDEF] DUMP_BASE

 KEY2_F6   OF \ F6
\  TRGO TRACE
	VIEW_BUF NEGATE DUMP_BASE !
	0 0 SETXY
		VIEW-#Y0 @ VIEW_BUF +  $120 DUMP_X
	DUMP_BASE 0! KEY DROP VIEW-PAGE
           ENDOF
[THEN]
 KEY2_UP OF  VIEW-Y @
		IF   -1  VIEW-Y +!  S_MOCK_OUT
		ELSE  VIEW-#Y0 @ ?DUP
		   IF >VIEW_UP
		   THEN
		THEN
                        MOCK_OUT VIEW-PAGE
			REAL_OUT VIEW-PAGE
	 ENDOF    \ Up
 KEY2_DOWN      OF VIEW_DOWN REAL_OUT VIEW-PAGE
		ENDOF

 KEY2_PAGE_UP   OF MOCK_OUT PAGE_UP_DO VIEW-PAGE REAL_OUT VIEW-PAGE
        	ENDOF   \  Page Up

 KEY2_PAGE_UP CTL+	OF VIEW-#Y0 0! VIEW-PAGE1 VIEW-Y 0!
			ENDOF
 CTRL_KEY2_HOME  CTL+	OF VIEW-#Y0 0! VIEW-PAGE1 VIEW-Y 0!
			ENDOF
	$19	OF \ CTRL Y
			CUR_LINE
			2DUP XOR
			IF	AA-DEL VIEW-PAGE1 THEN
		ENDOF
  CASE
 $D CTL+ OF\
 'e' CTL+ OF\
 'E' CTL+ OF;		CUR_LINE
			2DUP XOR
			IF \ ATTRIB@ >R
				CTRL_E
			THEN
		ENDOF

 KEY2_PAGE_DOWN OF      MOCK_OUT
                        MAX-VIEW-Y 0
                        ?DO VIEW-#Y0> \ OFFSET LEN
                           MAX-VIEW-Y 0
                           ?DO NEXT-LINE LOOP NIP
                                IF VIEW-#Y0>  NEXT-LINE DROP
                                   VIEW_BUF - VIEW-#Y0   !
                                THEN
                        LOOP VIEW-PAGE REAL_OUT VIEW-PAGE  ENDOF   \ Page Down
		CASE
 KEY2_END CTL+      OF\
 KEY2_PAGE_DOWN  CTL+ OF;
 VIEW-MAX-POINT @ VIEW-#Y0 ! \ VIEW-PAGE
  PAGE_UP_DO 
 VIEW_BUF  VIEW-MAX-POINT @ + TO ADDR_CUR VIEW-PAGE1
		ENDOF

 KEY2_HOME      OF VIEW-X 0! MOCK_OUT VIEW-PAGE REAL_OUT VIEW-PAGE  ENDOF   \ Home

 KEY2_END       OF

   VIEW-X 0! VIEW-Y 1+!  MOCK_OUT
  H_SCROLLING 
 VIEW-PAGE  
  ADDR_CUR 1- BLOCK-SET TO ADDR_CUR VIEW-PAGE1
 to H_SCROLLING

  VIEW-PAGE


  REAL_OUT VIEW-PAGE

                ENDOF   \ End

 BACK_BKEY      OF  ADDR_CUR VIEW_BUF -
                  IF
\                            ADDR_CUR 1- 1 >UNDO
                    ADDR_CUR  ADDR_CUR 1-   AA-DEL
                        ADDR_CUR 1- TO ADDR_CUR
		        VIEW-PAGE1
                  THEN
                ENDOF

 KEY2_DELETE       OF	SHIFT@
                     IF
[IFDEF] CLIPBOARD!

		XBLOCK-BIG @
		XBLOCK-END @  <>
		  IF

		XBLOCK-BIG @  XBLOCK-END @  UMIN  H_SCROLLING +	 VIEW-X !
		YBLOCK-BIG @  YBLOCK-END @  UMIN 1- VIEW-Y !

		CLIPBOARD 0!

 CLP_OUT
 VIEW-PAGE
        [']  MOCK1_EMIT TO  VVVEMIT

		XBLOCK-BIG @
		XBLOCK-END @  - ABS TO CLIP_X
			CLIPBOARD@ SWAP @ +  TO CLIP_KS

		YBLOCK-BIG @  YBLOCK-END @ - ABS 0
		DO	ADDR_CUR XBLOCK-BIG @  XBLOCK-END @ - ABS + ADDR_CUR
		AA-DEL VIEW-Y 1+! VIEW-PAGE
		LOOP		
		ADDR_CUR XBLOCK-BIG @  XBLOCK-END @ - ABS + ADDR_CUR
		XBLOCK-BIG @  XBLOCK-END !
		 REAL_OUT
		  ELSE
			BLOCK-BIG @ BLOCK-END @  OVER - CLIPBOARD!
			BLOCK-END @ BLOCK-BIG @  DUP BLOCK-END ! DUP TO ADDR_CUR
		  THEN 

[THEN]			
                     ELSE
                        ADDR_CUR 1+ ADDR_CUR
                     THEN 

			AA-DEL      VIEW-PAGE1
                ENDOF

	CASE
  KEY2_INSERT CTL+  OF\
  'c' CTL+  OF\
  'C' CTL+  OF;

		XBLOCK-BIG @
		XBLOCK-END @  <>
		  IF
		CLIPBOARD 0!
			CLP_OUT
 VIEW-PAGE REAL_OUT

		XBLOCK-BIG @
		XBLOCK-END @  - ABS TO CLIP_X
			CLIPBOARD@ SWAP @ +  TO CLIP_KS

\	GETXY 2>R 0 ROWS 1- 3 - SETXY \ cr ." e="
\ VIEW-Y @ . ADDR_CUR VIEW_BUF - h.
\	2R> SETXY \ $ffffff 0 do loop

		  ELSE
\+ CLIPBOARD!   BLOCK-BIG @ BLOCK-END @  OVER - CLIPBOARD!
		  THEN 


                ENDOF

[IFDEF] CLIPBOARD?
		CASE
	'v' CTL+ OF\
	'V' CTL+ OF;   CLIPBOARD_TYPE
                ENDOF

   KEY2_INSERT  OF   SHIFT@
		   IF   CLIPBOARD_TYPE
		   ELSE	 CURSOR% @ 5 U< VSHRIFT@ AND 3 OR CURSOR% !
		   THEN
		ENDOF
[THEN]
        KEY2_F2 OF  EDITFILESAVE
                ENDOF
   KEY2_CTRL_R OF
\+ VIEWFILEREAD VIEWFILEREAD
\+ VIEWFILEREAD  0 TO FILECHANGED? VIEW-PAGE
                ENDOF
[IFDEF] ACCEPT2
        KEY2_CTRL_F OF
			GETXY
			VSEARCHX 0 SETXY  VSEARCHBUFLEN SPACES
			VSEARCHX 0 SETXY 
	  		VSEARCHBUF  VSEARCHBUFLEN  ACCEPT2 TO VSEARCHLEN
			SETXY
			ALT_F3_DO
		ENDOF
[THEN]
\    DUP   0xFF AND ?DUP        IF


	KEY2_F3 OF  ALT_F3_DO ENDOF
		CASE
	 8 ALT+ OF\
	'Z' CTL+ OF\
	'z' CTL+ OF;
			UNDO_A_BUF @ 
			DUP -1 = IF DROP BREAK
			TO ADDR_CUR P_ADDR_CUR
			UNDO_BODY C@ $FF =
			IF	ADDR_CUR UNDO_S_BUF W@ + ADDR_CUR AA_DEL
				VIEW-PAGE1
				UNDO_BODY 1+ UNDO_BODY UNDO_B_SIZE CMOVE
			ELSE
			UNDO_BODY C@ $FE =
			IF	
                                UNDO_BODY 1+ C@  ADDR_CUR C! 
				UNDO_BODY 2+ UNDO_BODY UNDO_B_SIZE 1- CMOVE
				VIEW-PAGE1
			ELSE
				UNDO_BODY UNDO_S_BUF W@ VIEW_TYPE
				VIEW-PAGE1
				UNDO_BODY UNDO_S_BUF W@ + UNDO_BODY UNDO_B_SIZE UNDO_S_BUF W@ - CMOVE

			THEN	THEN
			UNDO_A_BUF CELL+ 2+ UNDO_A_BUF UNDO_A_SIZE CELL+ CMOVE
\			UNDO_S_BUF 2+ UNDO_S_BUF UNDO_S_SIZE CMOVE			

		ENDOF
        $11 OF  \ Ctr Q
		?RUS 0= TO ?RUS
	    ENDOF

	KEY2_DOWN	ALT+ OF NEW_BLK_ED VIEW-Y @ 1+ DUP VIEW-Y ! 1+ YBLOCK-END ! VIEW-PAGE ENDOF
	KEY2_UP		ALT+ OF NEW_BLK_ED VIEW-Y @ 1- DUP VIEW-Y ! 1+ YBLOCK-END ! VIEW-PAGE ENDOF
	KEY2_RIGHT	ALT+ OF NEW_BLK_ED VIEW-X @ 1+ DUP VIEW-X ! H_SCROLLING - XBLOCK-END ! VIEW-PAGE ENDOF
	KEY2_LEFT	ALT+ OF NEW_BLK_ED VIEW-X @ 1- DUP VIEW-X ! H_SCROLLING - XBLOCK-END ! VIEW-PAGE ENDOF

                DUP
                DUP $FF ANDC 0=
		IF
	                DUP 0xD = IF DROP 0xA THEN
\			?E2R
			DUP 
  X_OFFSET4 0MAX VIEW-SPACES
  VIEW-PUT
  V_DELAY1 0 ?DO LOOP
\ ." %" TOGGG
        	        VIEW-PAGE1  -1 TO FILECHANGED?
		THEN DROP
\       THEN
            ENDCASE
\ VIEW-PAGE
;

\- VIEW#Y0 0 VALUE VIEW#Y0
0 VALUE VIEW#X0


: VIEW_LOOP
  COLOR@ >R
  GETXY 2>R

   REAL_OUT    VIEW-PAGE
        BEGIN
  REAL_OUT

 0xF COLOR! 
\     SETXY? 2>R 0 0 SETXY SHIFT@ . 2R> SETXY
\ ." &&&"

0 0 SETXY  COLS SPACES
0 0 SETXY DUTYFILENAME COUNT TYPE
 FILECHANGED? IF ."  *" THEN
 ."  Point "  ( 9 EMIT) ADDR_CUR VIEW_BUF - h. ." / " VIEW-MAX-POINT @ h.
   ADDR_CUR C@ ." $" H. 

  X_OFFSET1
  X_OFFSET2 -
  X_OFFSET3 + TO   X_OFFSET4 

\  X_OFFSET4 . 

 ." Blk "  BLOCK-BIG @ VIEW_BUF - U. ." - "  BLOCK-END @ VIEW_BUF - U.

  H_SCROLLING .

  ."  sh "  GETXY DROP TO VSEARCHX \ VSEARCHBUF  VSEARCHLEN TYPE

        VIEW-X @ H_SCROLLING - VIEW-Y @ 1+ SETXY

         KEY \ 'U' EMIT#

  DUP KEY2_F10  <>
	OVER KEY2_ESC <> AND
        WHILE
  FUNC-KEY
        REPEAT DROP

  2R> SETXY
  R>  COLOR!
\  T_IMG VIDBUF  VIDBUF-SIZE CMOVE
;

VARIABLE E>YY

: _VIEW  ( -- )
\  VIDBUF T_IMG  VIDBUF-SIZE CMOVE

\   0x3 COLOR!  0 0 SETXY  MCOLS SPACES
  
   E>YY  0!
  0 TO H_SCROLLING

   VIEW-#Y0 0! VIEW#X0 H_SCROLLING UMAX VIEW-X !
   VIEW_BUF DUP TO ADDR_CUR DUP BLOCK-BIG ! BLOCK-END !
   


        VIEW#Y0 4 - 0 MAX 0
        ?DO VIEW-#Y0> \ OFFSET LEN
           MAX-VIEW-Y 0
           ?DO NEXT-LINE LOOP NIP
                IF VIEW-#Y0>  NEXT-LINE DROP
                   VIEW_BUF - VIEW-#Y0   !  
		else   E>YY 1+!
                THEN
        LOOP      
	E>YY @ 3 +  VIEW#Y0 1- 0 MAX UMIN VIEW-Y !

         H_SCROLLING TO VIEW#X0
         0 TO VIEW#Y0
	VIEW_LOOP
;
\ - VIEWSEARCH VARIABLE VIEWSEARCH 0x104 DALLOT

\ S" QWERTY" VIEWSEARCH $!
[IFDEF] &START_INIT
: VIEWINIT
 ." <VIEWINIT"
 [ &START_INIT @ COMPILE, ]
DUTYFILENAME 0!
\ ." VIEW-MAX-POINT 0!" CR KEY $20 OR 'a' = IF EXIT THEN
VIEW-MAX-POINT 0!
\ ERRFILE 0!
\ ." MAX#ED_FN 0 DO NEXT_F EDIT_FN 0! LOOP" CR KEY $20 OR 'a' = IF EXIT THEN
 MAX#ED_FN 0 DO NEXT_F EDIT_FN 0! LOOP
 ." VIEWINIT>" CR

\ VIEWSEARCH 0!
;

' VIEWINIT &START_INIT !

[THEN]

\ EOF
\- 4C! : 4C! ! ;
: $VIEW0  (  adrR lenR \ idfR  -- )

  DUTYFILENAME $!
  DUTYFILENAME COUNT EDIT_FN! 0 0 EDIT_SL 2!
  -1 UNDO_A_BUF ! \  $955 >UNDO  $956 >UNDO  $957 >UNDO  $958 >UNDO 
\  -1 UNDO_A_BUF 2+ ! \  $955 >UNDO  $956 >UNDO  $957 >UNDO  $958 >UNDO 
  -1 UNDO_A_BUF  UNDO_A_SIZE + CELL+ 2+ 4C!
\ UNDO_A_BUF  UNDO_A_SIZE CELL+ 2+
  VIEWFILEREAD IF BREAK
  _VIEW   ;


' $VIEW0 TO $VIEW

: ?EDITFILESAVE
 FILECHANGED? DUP
  IF  DROP
  CR  ." SAVE the FILE? Y/N"
  DUP
  BEGIN DROP    KEY 0x20 OR   
	DUP 'y' = 
	SWAP 'n' =  	\ Y= X=
	OVER OR 
  UNTIL
  THEN
 IF EDITFILESAVE
 THEN CR

;

: $EDIT0
  0 TO FILECHANGED?
   $VIEW
   ?EDITFILESAVE
;
' $EDIT0 TO $EDIT

: REE \ continue editing
 DUTYFILENAME @ 0= IF BREAK
 VIEW_LOOP ?EDITFILESAVE
;

: EDIT  PARSE-NAME  $EDIT ;


[IFDEF] ER>IN
: ERROR_ED
   [ ' ERROR_DO DEFER@ COMPILE, ]
 ERRFILENAME C@ IF
  CR  ." PRESS ANY KEY TO EDIT"
    KEY DROP

  ERR-LINE @  TO VIEW#Y0  ER>IN @  TO VIEW#X0
  ERRFILENAME COUNT $EDIT
  THEN
 ;
' ERROR_ED TO ERROR_DO
[THEN]
\- OK : OK DUTYFILENAME COUNT INCLUDED ;


\- VIEW#Y0	0 VALUE VIEW#Y0

: E>   PARSE-NAME VIEWS_SEARCH ?DUP
  IF  SWAP $C - L@ TO VIEW#Y0 COUNT $EDIT  THEN  
;
