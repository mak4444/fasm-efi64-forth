
format pe64 dll efi
entry main

macro Wortbirne Name,CName,FLine,Flags {
	align 8
	DQ	CName
	DD	Flags,FLine
	DQ	DEFLAST
DEFLAST = $
	DB	@F-$-1
	DB      Name
@@:
}

macro CONSTANT_W Name,Value,FLine,Flags {
	align 8
	DQ	@F
	DD	Flags,FLine
	DQ	DEFLAST
DEFLAST = $
	DB	@F-$-1
	DB      Name
@@:	call	_DOCONSTANT
	dq	Value
}

macro VARIABLE_W Name,Value,FLine,Flags {
	align 8
	DQ	@F
	DD	Flags,FLine
	DQ	DEFLAST
DEFLAST = $
	DB	@F-$-1
	DB      Name
@@:	call	_DOCREATE
	dq	Value
}

macro VIEW_S Flags {
	dq	SVIEWLINK,0
	SVIEWLINK=$-16
}

macro S_VIEW_PATH Path {
	dq	SVIEWLINK,-1
	SVIEWLINK=$-16
	db @F-(SVIEWLINK+16)-1
	db Path
@@:
}

section '.text' code executable readable

; To use the uefi Input/Output functions
include 'uefi.inc'

_SYSTAB:
	call _DUP
	mov  rax, [efi_ptr]
	RET

_IMAGEHANDLE:
	call _DUP
	mov  rax, [efi_handler]
	RET

_UZTYPE:
	uefi_call_wrapper ConOut, OutputString, ConOut, rax
	jmp _DROP

_GETMAXXY1:
;	uefi_call_wrapper ConOut, QueryMode, ConOut, Mode.Mode , rax
	jmp _DROP

main:

	; Initialize UEFI library
	InitializeLib


	; Equivalent to SystemTable->ConOut->OutputString(SystemTable->ConOut, "Message")
	uefi_call_wrapper ConOut, OutputString, ConOut, welcome_message

	mov	rbp,SPP
	mov	rax,CTOP ; to DP
	call	_FMAIN
	ret

_DROP = _DgreatS
_RSHIFT = _greatgreat
_LSHIFT = _lessless
_1add  = _CHARadd
_INVERT = _NOT
_0save = _OFF
_INVERT = _NOT
_PERFORM = _loadEXECUTE


DEFLAST=0
SVIEWLINK=0

fimg:
include 'Forth64S/src/src_PRIMITIVES.INC'
include 'Forth64S/src/src_VARS.INC'
include 'Forth64S/src/src_HPROC.INC'
include 'Forth64S/src/macroopt.INC'
include 'Forth64S/src/NUMB_PARSE_IO.INC'
include 'Forth64S/src/LITERAL.INC'
include 'Forth64S/src/src_FIND_INTERP.INC'
include 'Forth64S/src/TERM/INCLUDE.INC'
include 'Forth64S/src/fstart.INC'

	DQ	@f
	DQ	0	; flags
	DQ	0	; Link einfügen  Insert Link
	DEFLAST=$
	DB 6     ; Länge des Namensfeldes berechnen  Calculate length of name field
	DB "IMGLIT"    ; Namen anfügen  Insert name string
@@:	call	_DOCONSTANT
	DQ	fimg

include 'Forth64S/src/GHEADERS.INC'

_ORIGVIEWLINK:
	call	_DOCONSTANT
	DQ	SVIEWLINK

_FORTH_ORIG:
	call	_DOCONSTANT
	DQ	DEFLAST

_FORTHsubWORDLIST:
	call	_DOCREATE
	DQ	DEFLAST
	DQ	0	; link
	DQ	@f
@@:	db	5
	db	"FORTH"   
_VOCsubLIST:
	call	_DOCREATE
	DQ	_FORTHsubWORDLIST + 5 + 8

_CONTEXT_SIZE: 
	call	_DOCONSTANT
	DQ	 @f - ( _CONTEXT + 5 )

_CONTEXT:
	call _DOCREATE
	DQ _FORTHsubWORDLIST + 5 
	DQ 15 DUP (0)
@@:	DQ	0

_CURRENT:
; This variable holds the address of the word list to which new definitions are added.
	call _DOCREATE
	DQ _FORTHsubWORDLIST + 5 



section '.data' data readable writeable

	INPUT_KEY				EFI_INPUT_KEY
	welcome_message du		'UEFI64 Firth OS',13,10,0
	tst_message 		du '$',0

	section ".efitext" data readable writeable

align 8
TIBB	DB 512 DUP (?)
CTOP	DB 0x100000 DUP (?)
SPP	DQ 10 DUP (?)
bytes_count dd ?
character dd ?
	  dd ?

section '.reloc' fixups data discardable
