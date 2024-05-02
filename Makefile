SOURCES = ./EFI64_4TH.ASM

FORTH_SRC = Forth64S/promram.4 \
 disk_nmt/ForthSrc/src_PRIMITIVES.4 \
 disk_nmt/ForthSrc/src_HPROC.4 \
 disk_nmt/ForthSrc/src_VARS.4 \
 disk_nmt/ForthSrc/macroopt.4 \
 disk_nmt/ForthSrc/NUMB_PARSE_IO.4 \
 disk_nmt/ForthSrc/LITERAL.4 \
 disk_nmt/ForthSrc/src_FIND_INTERP.4 \
 disk_nmt/ForthSrc/TERM/INCLUDE.4 \
 disk_nmt/ForthSrc/fstart.4 \
 Forth64S/Meta_x86_64/SRC/gasm64.4th \
 Forth64S/Meta_x86_64/SRC/disfasm.4 \
 Forth64S/Meta_x86_64/SRC/tc.f \
 Forth64S/src/global.4 \
 Forth64S/Meta_x86_64/SRC/mlist.f \
 Forth64S/Meta_x86_64/SRC/lex.4th \
 Forth64S/Meta_x86_64/mhead0.f \
 Forth64S/Meta_x86_64/SRC/macroopt.4 

all:	EFI64_4TH.EFI

FORTH_INC: $(FORTH_SRC)
	cd Forth64S;./FComp.sh

EFI64_4TH.EFI: $(SOURCES) FORTH_INC 
	fasm EFI64_4TH.ASM

run:	all
	./copyefi.sh
	./qemuboot.sh 

clean:
	rm -f EFI64_4TH.EFI Forth64S/src/*.INC
	
