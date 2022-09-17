# loadnothing
Can I run boot code?

Requires nasm and qemu-system-x86.

Rust nightly needs to be installed. If no nightly toolchain shows up
when you run `rustup toolchain list`, install it:

```sh
rustup toolchain install nightly
```

# Building
Follow the instructions below to build the project without running it.

```sh
rustup default nightly
rustup component add rust-src

make nothing.img
```

# Running
Simply type `make` to build and run the project.
QEMU may require a VNC viewer.

If it's working you should see "Hello Stage2!" on the screen.

# Real Hardware
It is possible to test this project on real hardware.
The only supported platform at the moment is x86. UEFI is not supported
and UEFI support is unlikely to be added in the future. If you use UEFI
make sure to enable CSM / Legacy Boot in your UEFI settings. If you don't have CSM you can still use a virtual machine as explained above.

You can use `dd` to write the `nothing.img` file to a block device
of your choice (but only if you've built it). It is exactly 32 MiB in size.

**This will overwrite the partition table so be careful not to write
to the wrong device.**

You can then boot from the device. It should once again print "Hello Stage2!".
