default_target: boot.bin
.PHONY: clean

boot.bin: boot.asm
	nasm -f bin -o boot.bin boot.asm

clean:
	rm -f boot.bin
