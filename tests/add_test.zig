const std = @import("std");

const c = @cImport({
    @cInclude("error_handler.h");
});

// `c.add` is the C function imported from `error_handler.h`
test "add function adds two integers" {
    const a = 5;
    const b = 7;
    const result = c.add(a, b);
    try std.testing.expect(result == 12);
}

test "add function with negative numbers" {
    const a = -5;
    const b = -7;
    const result = c.add(a, b);
    try std.testing.expect(result == -12);
}

test "add function with zero" {
    const a = 0;
    const b = 7;
    const result = c.add(a, b);
    try std.testing.expect(result == 7);
}
