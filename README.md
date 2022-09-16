# loadnothing
Can I run boot code?

Requires nasm, parted, dosfstools and qemu-system-x86.

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
