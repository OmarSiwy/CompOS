const builtin = @import("builtin");

export fn _start() callconv(.Naked) noreturn {
    asm volatile ("bl main");
    unreachable;
}

export fn main() noreturn {
    @panic("Testing panic handler");
}
