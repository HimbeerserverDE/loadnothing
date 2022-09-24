default_target: bochs
.PHONY: qemu bochs clean

stage1/boot.bin: stage1/boot.asm stage2/target/x86-loadnothing/release/stage2
	nasm -DSTAGE2SIZE=$$(du -b stage2/target/x86-loadnothing/release/stage2 | cut -f1) -f bin -o stage1/boot.bin stage1/boot.asm

stage2/target/x86-loadnothing/release/stage2: stage2/src/main.rs stage2/src/vga.rs
	cd stage2 && cargo build --release

nothing.img: stage2/target/x86-loadnothing/release/stage2 stage1/boot.bin
	cp -p base.img nothing.img
	dd if=stage1/boot.bin of=nothing.img bs=1 count=446 conv=notrunc
	echo -en "\x55\xAA" | dd of=nothing.img bs=1 seek=510 count=2 conv=notrunc
	dd if=stage2/target/x86-loadnothing/release/stage2 of=nothing.img bs=512 seek=1 conv=notrunc

bochs: nothing.img
	bochs -q

qemu: nothing.img
	qemu-system-x86_64 -drive format=raw,file=nothing.img

clean:
	rm -f stage1/boot.bin nothing.img
	cd stage2 && cargo clean
