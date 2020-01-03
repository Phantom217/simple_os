#![feature(lang_items)]
#![no_std]

#[lang = "eh_personality"]
extern fn eh_personality() {}

#[lang = "panic_impl"]
#[no_mangle]
pub extern fn rust_begin_panic(_msg: &core::panic::PanicInfo) -> ! {
    loop {}
}
