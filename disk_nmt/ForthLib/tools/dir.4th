
  /EFI_FILE_INFO 512 2* + CONSTANT FILEINFO_SIZE
CREATE FILEINFO  FILEINFO_SIZE ALLOT
0 VALUE DIR_ID
: NEXTFILE  ( -- flg )
 FILEINFO FILEINFO_SIZE DIR_ID READ-FILE THROW  ;

: $DIR ( addr len -- )
  R/O  OPEN-FILE THROW TO DIR_ID
  BEGIN FILEINFO FILEINFO_SIZE DIR_ID READ-FILE THROW 
  WHILE FILEINFO FI.FileName UZTYPE 9 EMIT
	FILEINFO FI.Attribute @ EFI_FILE_DIRECTORY  AND IF ." <dir>" THEN  CR
  REPEAT  
  DIR_ID CLOSE-FILE DROP
;

: DIR PARSE-NAME $DIR ;

 CREATE CUR_DIR 1 C, '0' C, 0 , 100 ALLOT \ CUR_DIR 100 ERASE

: $CHDIR ( adr len -- )
 DUP 0= IF 2DROP BREAK
 CUR_DIR COUNT + 1- C@ '\' <> IF '\' CUR_DIR $C+! THEN
 OVER W@  $2E2E ( ..) =
  IF 2DROP
	CUR_DIR C@ 1 = IF BREAK
	BEGIN -1 CUR_DIR +!
	      CUR_DIR COUNT + 1- C@ '\' =
	UNTIL
  BREAK
 OVER 1+ C@ '\' = \ root
 IF  CUR_DIR $!
 ELSE CUR_DIR $+!                        		
 THEN
 ;

CREATE vol_handles 0 ,
CREATE vol_count 0 ,

: LOCHAND ( -- flg )
	vol_handles
	vol_count
	0
	EFI_SIMPLE_FILE_SYSTEM_GUID
	ByProtocol
	BOOTSERV LocateHandleBuffer @ 5XSYS
;

CREATE CUR_DRIVE 0 ,

: SETDRIVE ( n -- flg )
	CUR_DRIVE
	EFI_SIMPLE_FILE_SYSTEM_GUID
	ROT CELLS vol_handles @ + @
	BOOTSERV HandleProtocol @ 3XSYS
;

\- CUR_ROOT CREATE CUR_ROOT 0 ,

: OPEN-VOLUME ( -- flg )
	CUR_ROOT
	CUR_DRIVE @
	CUR_DRIVE @ OpenVolume @ 2XSYS
;
\ https://github.com/rhboot/shim/blob/main/lib/simple_file.c
: SETROOT ( n -- flg )
 LOCHAND DUP IF BREAK DROP
  SETDRIVE DUP IF BREAK DROP
 OPEN-VOLUME ;

: >DIREFIFILENAME ( adr1 len adr -- adr )
  2 PICK 
  1+ C@ '\' =
  IF   2 PICK C@ '0' XOR SETROOT THROW
	>R 2- SWAP 2+ SWAP R> ASCII-UZ
  BREAK
 CUR_DIR COUNT + 1- C@ '\' <> IF '\' CUR_DIR $C+! THEN
 CUR_DIR 2+ C@ '\' = IF CUR_DIR 1+ C@ '0' XOR SETROOT DUP IF $3001 CUR_DIR W! THEN THROW THEN
 CUR_DIR COUNT 1- SWAP 1+ SWAP ROT ASCII-UZ \  adr1 len adr
 DUP>R CUR_DIR C@ 1- 2* + ASCII-UZ DROP R> Z/TO\
 ;

' >DIREFIFILENAME TO >EFIFILENAME

: CD PARSE-NAME $CHDIR ;

[IFNDEF] UZSIM_OPEN-FILE
: UZSIM_OPEN-FILE ( uzadr fam -- fid flg )
	0 SWAP ROT \ 0 fam uzadr
	0 >R RP@
	CUR_ROOT @ 
	VOLUME F_Open @ 5XSYS R> SWAP
;
[THEN]

: CD-OPEN-FILE ( c-addr u fam -- fileid ior )
 3DUP >R 2>R
 [ ' OPEN-FILE DEFER@ COMPILE, ] DUP 0= IF 2RDROP RDROP BREAK 
  2DROP
   2R> FILE-BUFF  >EFIFILENAME0
   R>  UZOPEN-FILE
;

: SM-OPEN-FILE ( c-addr u fam -- fileid ior )
 3DUP >R 2>R
     >R FILE-BUFF  >EFIFILENAME R>  UZSIM_OPEN-FILE
   DUP 0= IF 2RDROP RDROP BREAK 
  2DROP
   2R> FILE-BUFF  >EFIFILENAME0
   R>  UZOPEN-FILE
;

\ ' CD-OPEN-FILE TO OPEN-FILE

' SM-OPEN-FILE TO OPEN-FILE

[IFNDEF] $MKDIR

: $MKDIR  ( c-adr len -- )
	FILE-BUFF >EFIFILENAME0
	EFI_FILE_DIRECTORY
	R/W >CREATE
	ROT \ atr fam uzadr
	0 >R RP@
	VOLUME \ CUR_ROOT @ 
	VOLUME F_Open @ 5XSYS THROW R>
	CLOSE-FILE DROP ;

[THEN]

\- MKDIR : MKDIR PARSE-NAME $MKDIR ;
