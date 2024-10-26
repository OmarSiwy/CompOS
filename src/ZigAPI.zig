// This File must include all the other .zig files in the project
// This is a library of its own used to support the C Library

// Compile-time array generation
const std = @import("std");

// Compile-time Fibonacci calculation in Zig
fn fibonacciZig(n: u32) u32 {
    return switch (n) {
        0 => 0,
        1 => 1,
        else => fibonacciZig(n - 1) + fibonacciZig(n - 2),
    };
}

export const fibonnaci_300 = fibonacciZig(40);
