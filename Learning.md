# Commenting Using Doxygen, two formats using JavaDoc Style:

```C++
// Before Functions/Classes/Enums:
// Version 1:
/**
 *
 *
 */

// Verion 2:
//
/***********************************************************
 *
 *
 *
 **********************************************************/

// After Variables:
int var; /**Detailed Description of the variable here */
```

# Cross-Talk between Zig and C Files in the same Project:

```C++
// Zig to C:
// Zig Side
export fn say_hello_from_zig() void {
    @import("std").debug.print("Hello from Zig!\n", .{});
}

// C Side
extern void say_hello_from_zig();

// Build Changes:
// Nothing, it is handled as long as the file is in src/
```

# Clang Information

## Declaration of Variable Location

```C
// Function placed in the .text section (program code)
__attribute__((section(".text"))) void my_function() {
    // Code goes here
}

// Global variable placed in the .data section (initialized global variables)
__attribute__((section(".data"))) int global_initialized = 10;

// Uninitialized variable placed in the .bss section (uninitialized globals)
__attribute__((section(".bss"))) int global_uninitialized;

// Constant placed in the .rodata section (read-only data)
__attribute__((section(".rodata"))) const char message[] = "Hello, World!";

const int my_const __attribute__((section(".idata"))) = 42;

```

## Linker Script

# Embedded Informaton
