#![no_std]
#![no_main]
#![warn(clippy::arithmetic)]

mod vga;

use core::arch::asm;
use core::panic::PanicInfo;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[no_mangle]
pub extern "C" fn _start() -> ! {
    vga::test_print();

    unsafe {
        loop {
            asm!("hlt");
        }
    }
}
