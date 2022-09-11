default_target: vm
.PHONY: vm clean

magic.bin:
	echo -en "\x55\xAA" > magic.bin

stage1/boot.bin: stage1/boot.asm
	nasm -f bin -o stage1/boot.bin stage1/boot.asm

nothing.img: magic.bin stage1/boot.bin
	dd if=/dev/zero of=nothing.img bs=2M count=1
	parted -s nothing.img mklabel msdos
	parted -s -a optimal nothing.img mkpart primary fat32 1M 100%
	doas losetup /dev/loop1 nothing.img
	doas mkfs.fat /dev/loop1p1
	doas losetup -d /dev/loop1
	dd if=stage1/boot.bin of=nothing.img bs=1 count=446 conv=notrunc
	dd if=magic.bin of=nothing.img bs=1 seek=510 count=2 conv=notrunc

vm: clean nothing.img
	qemu-system-x86_64 -hda nothing.img

clean:
	rm -f magic.bin stage1/boot.bin nothing.img
