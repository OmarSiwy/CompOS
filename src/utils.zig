// Compile-time array generation
const std = @import("std");

const SIZE = 10;
pub const precomputed_array = comptime make_array(SIZE);

comptime fn make_array(size: usize) [size]u32 {
    var arr: [size]u32 = undefined;
    for (arr) |*value, index| {
        value.* = @intCast(u32, index * index);
    }
    return arr;
}

// Function to access the precomputed array from C
export fn get_precomputed_array() *const u32 {
    return &precomputed_array;
}

// Define a struct
pub const MyStruct = struct {
    a: i32,
    b: i64,
};

// Generate a description of the struct at compile-time
pub const struct_info = comptime std.meta.fields(MyStruct);

// Expose struct field count to C
export fn get_struct_field_count() usize {
    return struct_info.len;
}

