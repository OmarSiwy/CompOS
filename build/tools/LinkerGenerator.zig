const std = @import("std");
const Targets = @import("SupportedTargets.zig");

/// @brief Generates a new Linker Script File under specifics for a supported target
///
/// This function should only be used in the Makefile/Build System to generate a new linker script file
/// Refer to the examples in the `examples` directory for more information
///
/// @param target The target to generate the linker script for
/// @param output_path relative path to this file
pub fn GenerateLinkerFile(target: Targets.TargetType, output_path: []const u8, entry_point: []const u8) !void {
    const file = try std.fs.cwd().createFile(output_path, .{});
    defer file.close();

    const writer = file.writer();
    try writer.print("ENTRY(\"{s}\");\n", .{entry_point});

    // Write MEMORY section
    try writer.writeAll("MEMORY\n{\n");

    // Define counters for each region type
    var flash_counter: u32 = 0;
    var ram_counter: u32 = 0;
    var io_counter: u32 = 0;
    var reserved_counter: u32 = 0;
    var private_counter: u32 = 0;

    for (target.memory_regions) |region| {
        // Determine the region name and index based on the type
        var region_index: u32 = 0;
        const region_name: []const u8 = switch (region.kind) {
            .flash => blk: {
                region_index = flash_counter;
                flash_counter += 1;
                break :blk "flash";
            },
            .ram => blk: {
                region_index = ram_counter;
                ram_counter += 1;
                break :blk "ram";
            },
            .io => blk: {
                region_index = io_counter;
                io_counter += 1;
                break :blk "io";
            },
            .reserved => blk: {
                region_index = reserved_counter;
                reserved_counter += 1;
                break :blk "reserved";
            },
            .private => blk: {
                region_index = private_counter;
                private_counter += 1;
                break :blk region.name;
            },
        };

        try writer.print("  {s}{d} ({s}{s}{s}) : ORIGIN = 0x{x:0>8}, LENGTH = 0x{x:0>8}\n", .{
            region_name,
            region_index,
            if (region.readable) "r" else "",
            if (region.writeable) "w" else "",
            if (region.executable) "x" else "!",
            region.offset,
            region.length,
        });
    }

    try writer.writeAll("}\n\n");

    // Align based on MCU-specific alignment
    const alignment = target.memory_alignment;

    // Write SECTIONS part of the linker script
    try writer.writeAll(
        \\
        \\ SECTIONS{
        \\  .isr_vector :
        \\  {
        \\     KEEP(*(.isr_vector))
        \\  } > flash0
        \\ 
        \\  .text : ALIGN(
    );
    try writer.print("{d})\n", .{alignment});
    try writer.writeAll(
        \\  {
        \\    KEEP(*(startup))
        \\    *(.text*)
        \\  } > flash0
        \\ 
        \\ .data :
    );
    try writer.writeAll(
        \\  {
        \\    _data_start = .;
        \\    *(.data*)
        \\    *(.rodata)
        \\    _data_end = .;
        \\  } > ram0 AT> flash0
        \\ 
        \\  .bss (NOLOAD) : ALIGN(
    );
    try writer.print("{d})\n", .{alignment});
    try writer.writeAll(
        \\  {
        \\    _bss_start = .;
        \\    *(.bss*)
        \\    _bss_end = .;
        \\  } > ram0
        \\  _data_load_start = LOADADDR(.data);
        \\
        \\  .stack (NOLOAD) : ALIGN(8)
        \\  {
        \\     _stack_start = .;
        \\     . = . + 0x1000; /* Example 4KB stack */
        \\     _stack_end = .;
        \\  } > ram0
        \\ 
        \\  .heap (NOLOAD) : ALIGN(8)
        \\  {
        \\     _heap_start = .;
        \\     . = . + 0x4000; /* Example 16KB heap */
        \\     _heap_end = .;
        \\  } > ram0
        \\ }
    );

    // Add memory overflow assertions
    try writer.writeAll(
        \\ ASSERT(SIZEOF(.text) + SIZEOF(.data) < LENGTH(flash0), "Flash memory overflow");
        \\ ASSERT(SIZEOF(.bss) < LENGTH(ram0), "RAM overflow");
    );
}
