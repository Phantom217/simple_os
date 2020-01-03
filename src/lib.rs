#![feature(lang_items)]
#![no_std]

#[lang = "eh_personality"]
extern fn eh_personality() {}

#[lang = "panic_impl"]
pub extern fn rust_begin_panic(_msg: &core::panic::PanicInfo) -> ! {
    loop {}
}

#[no_mangle]
pub extern fn kmain() -> ! {
    unsafe {
        let vga = 0xb8000 as *mut u64;

        *vga = 0x2f592f412f4b2f4f;
    };

    loop {}
}
