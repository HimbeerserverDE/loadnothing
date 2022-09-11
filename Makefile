default_target: vm
.PHONY: vm clean

stage1/boot.bin: stage1/boot.asm
	nasm -f bin -o stage1/boot.bin stage1/boot.asm

magic.bin:
	echo -en "\x55\xAA" > magic.bin

stage2/target/x86_64-loadnothing/debug/stage2: stage2/src/main.rs
	cd stage2 && cargo build

nothing.img: magic.bin stage1/boot.bin stage2/target/x86_64-loadnothing/debug/stage2
	dd if=/dev/zero of=nothing.img bs=32M count=1
	parted -s nothing.img mklabel msdos
	parted -s -a optimal nothing.img mkpart primary fat32 16M 100%
	doas losetup /dev/loop1 nothing.img
	doas mkfs.fat /dev/loop1p1
	doas losetup -d /dev/loop1
	dd if=stage1/boot.bin of=nothing.img bs=1 count=446 conv=notrunc
	dd if=magic.bin of=nothing.img bs=1 seek=510 count=2 conv=notrunc
	dd if=stage2/target/x86_64-loadnothing/debug/stage2 of=nothing.img bs=512 seek=1 conv=notrunc

vm: nothing.img
	qemu-system-x86_64 -hda nothing.img

clean:
	rm -f magic.bin stage1/boot.bin nothing.img
	cd stage2 && cargo clean
