const std = @import("std");

test {
    // Must be called to run nested tests
    std.testing.refAllDecls(@This());

    _ = @import("list_test.zig"); // runs tests inside file
}
