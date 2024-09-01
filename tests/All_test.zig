pub const A = @import("add_test.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
