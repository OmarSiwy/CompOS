const std = @import("std");

test {
    // Must be called to run nested tests
    std.testing.refAllDecls(@This());

    _ = @import("heap_test.zig"); // runs tests inside file
}
