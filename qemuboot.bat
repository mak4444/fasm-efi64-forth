rem https://github.com/queso-fuego/UEFI-GPT-image-creator - ./bios64_app.bin ./bios64.bin
qemu-system-x86_64 -bios OVMF.fd -hda fat:rw:disk_nmt -hdb fat:rw:Forth64S\Meta_x86_64 

