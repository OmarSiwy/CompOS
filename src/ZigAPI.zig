// This File must include all the other .zig files in the project
// This is a library of its own used to support the C Library

export fn fibonnaci(n: u32) u32 {
    if (n == 0) {
        return 0;
    } else if (n == 1) {
        return 1;
    } else {
        return fibonnaci(n - 1) + fibonnaci(n - 2);
    }
}
