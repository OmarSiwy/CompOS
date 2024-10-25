// Compile-time array generation
const std = @import("std");

const SIZE = 10;

// Define a struct
pub const MyStruct = struct {
    a: i32,
    b: i64,
};

// Generate a description of the struct at compile-time
pub const struct_info = std.meta.fields(MyStruct);

// Expose struct field count to C
export fn get_struct_field_count() usize {
    return struct_info.len;
}
