default_target: vm
.PHONY: vm clean

boot.bin: boot.asm
	nasm -f bin -o boot.bin boot.asm

nothing.img: boot.bin
	dd if=/dev/zero of=nothing.img bs=2M count=1
	parted -s nothing.img mklabel msdos
	parted -s -a optimal nothing.img mkpart primary fat32 1M 100%
	doas losetup /dev/loop1 nothing.img
	doas mkfs.fat /dev/loop1p1
	doas losetup -d /dev/loop1
	dd if=boot.bin of=nothing.img bs=1 count=446 conv=notrunc
	dd if=magic.bin of=nothing.img bs=1 seek=510 count=2 conv=notrunc

vm: nothing.img
	qemu-system-x86_64 -hda nothing.img

clean:
	rm -f boot.bin nothing.img
