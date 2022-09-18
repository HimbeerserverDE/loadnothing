#![no_std]
#![no_main]

#![warn(clippy::arithmetic)]

use core::arch::asm;
use core::ops::{Add, Mul};
use core::panic::PanicInfo;

static HELLO: &[u8] = b"Hello Stage2!";

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[no_mangle]
pub extern "C" fn _start() -> ! {
    let vga_buffer = 0xb8000 as *mut u8;
    let vga_max = 0xf9e;

    // Clear the screen
    for i in 0..vga_max {
        unsafe {
            *vga_buffer.offset((i as isize).mul(2)) = 0x00;
            *vga_buffer.offset((i as isize).mul(2).add(1)) = 0x07;
        }
    }

    // Print welcome message
    for (i, &byte) in HELLO.iter().enumerate() {
        unsafe {
            *vga_buffer.offset((i as isize).mul(2)) = byte;
            *vga_buffer.offset((i as isize).mul(2).add(1)) = 0x07;
        }
    }

    unsafe {
        loop {
            asm!("hlt");
        }
    }
}
