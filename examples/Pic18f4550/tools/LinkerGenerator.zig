const std = @import("std");

/// Target Specifications
/// Memory Region that the target supports
pub const MemoryRegion = struct {
    kind: enum { flash, ram, io, reserved, private },
    offset: u32,
    length: u32,
    name: []const u8 = "default",
    readable: bool = true,
    writeable: bool = true,
    executable: bool = false,
};

/// Target Specifications
pub const TargetType = struct {
    mcu_name: []const u8,
    mcu_arch: []const u8,
    mcu_family: []const u8,
    mcu_sub_family: []const u8,
    memory_regions: []const MemoryRegion,
    memory_alignment: u32,
};

/// Supported Targets
pub const Targets = struct {
    pub const STM32F103 = TargetType{
        .mcu_name = "STM32F103",
        .mcu_arch = "armv7-m",
        .mcu_family = "STM32F1",
        .mcu_sub_family = "STM32F103",
        .memory_regions = &[_]MemoryRegion{
            MemoryRegion{ .kind = .flash, .offset = 0x08000000, .length = 0x00040000 }, // 256KB flash
            MemoryRegion{ .kind = .ram, .offset = 0x20000000, .length = 0x00005000 }, // 20KB RAM
        },
        .memory_alignment = 8, // 8-byte alignment
    };

    pub const STM32F407 = TargetType{
        .mcu_name = "STM32F407",
        .mcu_arch = "armv7e-m",
        .mcu_family = "STM32F4",
        .mcu_sub_family = "STM32F407",
        .memory_regions = &[_]MemoryRegion{
            MemoryRegion{ .kind = .flash, .offset = 0x08000000, .length = 0x00100000 }, // 1MB flash
            MemoryRegion{ .kind = .ram, .offset = 0x20000000, .length = 0x00020000 }, // 128KB RAM
        },
        .memory_alignment = 16, // 16-byte alignment
    };

    pub const STM32F030 = TargetType{
        .mcu_name = "STM32F030",
        .mcu_arch = "armv6-m",
        .mcu_family = "STM32F0",
        .mcu_sub_family = "STM32F030",
        .memory_regions = &[_]MemoryRegion{
            MemoryRegion{ .kind = .flash, .offset = 0x08000000, .length = 0x00008000 }, // 32KB flash
            MemoryRegion{ .kind = .ram, .offset = 0x20000000, .length = 0x00000800 }, // 8KB RAM
        },
        .memory_alignment = 4, // 4-byte alignment
    };

    pub const STM32H743 = TargetType{
        .mcu_name = "STM32H743",
        .mcu_arch = "armv7e-m",
        .mcu_family = "STM32H7",
        .mcu_sub_family = "STM32H743",
        .memory_regions = &[_]MemoryRegion{
            MemoryRegion{ .kind = .flash, .offset = 0x08000000, .length = 0x00200000 }, // 2MB flash
            MemoryRegion{ .kind = .ram, .offset = 0x24000000, .length = 0x00080000 }, // 512KB RAM
        },
        .memory_alignment = 32, // 32-byte alignment for high-performance MCU
    };

    pub const STM32L476 = TargetType{
        .mcu_name = "STM32L476",
        .mcu_arch = "armv7e-m",
        .mcu_family = "STM32L4",
        .mcu_sub_family = "STM32L476",
        .memory_regions = &[_]MemoryRegion{
            MemoryRegion{ .kind = .flash, .offset = 0x08000000, .length = 0x00080000 }, // 512KB flash
            MemoryRegion{ .kind = .ram, .offset = 0x20000000, .length = 0x00018000 }, // 96KB RAM
        },
        .memory_alignment = 8, // 8-byte alignment
    };

    pub const STM32F303 = TargetType{
        .mcu_name = "STM32F303",
        .mcu_arch = "armv7-m",
        .mcu_family = "STM32F3",
        .mcu_sub_family = "STM32F303",
        .memory_regions = &[_]MemoryRegion{
            MemoryRegion{ .kind = .flash, .offset = 0x08000000, .length = 0x00080000 }, // 512KB flash
            MemoryRegion{ .kind = .ram, .offset = 0x20000000, .length = 0x00010000 }, // 64KB RAM
        },
        .memory_alignment = 8, // 8-byte alignment
    };

    pub const PIC18F2550 = TargetType{
        .mcu_name = "PIC18F2550",
        .mcu_arch = "pic18",
        .mcu_family = "PIC18",
        .mcu_sub_family = "PIC18F2550",
        .memory_regions = &[_]MemoryRegion{
            MemoryRegion{ .kind = .flash, .offset = 0x00000000, .length = 0x00007FFF }, // 32KB flash
            MemoryRegion{ .kind = .ram, .offset = 0x00000000, .length = 0x00000800 }, // 2KB RAM
            MemoryRegion{ .kind = .io, .offset = 0x00000000, .length = 0x000000F0 }, // I/O memory
        },
        .memory_alignment = 1, // 1-byte alignment for PIC
    };

    pub const PIC18F4550 = TargetType{
        .mcu_name = "PIC18F4550",
        .mcu_arch = "pic18",
        .mcu_family = "PIC18",
        .mcu_sub_family = "PIC18F4550",
        .memory_regions = &[_]MemoryRegion{
            MemoryRegion{ .kind = .flash, .offset = 0x00000000, .length = 0x0000FFFF }, // 64KB flash
            MemoryRegion{ .kind = .ram, .offset = 0x00000000, .length = 0x00001000 }, // 4KB RAM
            MemoryRegion{ .kind = .io, .offset = 0x00000000, .length = 0x000000F0 }, // I/O memory
        },
        .memory_alignment = 1, // 1-byte alignment for PIC
    };
};

/// @brief Genereates a new Linker Script File under specifics for a supported target
///
/// This function should only be used in the Makefile/Build System to generate a new linker script file
/// Refer to the examples in the `examples` directory for more information
///
/// @param target The target to generate the linker script for
/// @param output_path relative path to this file
pub comptime fn GenerateLinkerFile(target: TargetType, output_path: []const u8, entry_point: []const u8) void {
    const file = try std.fs.cwd().createFile(output_path, .{});
    defer file.close();

    const writer = file.writer();
    try writer.print(
        \\/* Generated Linker Script
        \\ * Target: {[mcu_name]s}
        \\ * MCU Architecture: {[mcu_arch]s}
        \\ * MCU Family: {[mcu_family]s}
        \\ * MCU Sub-Family: {[mcu_sub_family]s}
        \\ */
        \\ENTRY({entry_point});
    , .{
        .mcu_name = target.mcu_name,
        .mcu_arch = target.mcu_arch,
        .mcu_family = target.mcu_family,
        .mcu_sub_family = target.mcu_sub_family,
        .entry_point = entry_point,
    });

    // Write MEMORY section
    try writer.writeAll("MEMORY\n{\n");
    for (target.memory_regions, 0..) |region, i| {
        const region_name = switch (region.kind) {
            .flash => "flash",
            .ram => "ram",
            .io => "io",
            .reserved => "reserved",
            .private => region.name,
        };

        try writer.print("  {s}{d} ({s}{s}{s}) : ORIGIN = 0x{X:0>8}, LENGTH = 0x{X:0>8}\n", .{ region_name, i, if (region.readable) "r" else "", if (region.writeable) "w" else "", if (region.executable) "x" else "!", region.offset, region.length });
    }

    try writer.writeAll("}\n\n");

    // Align based on MCU-specific alignment
    const alignment = target.memory_alignment;

    // Write SECTIONS part of the linker script
    try writer.print(
        \\SECTIONS
        \\{
        \\  .isr_vector :
        \\  {
        \\     KEEP(*(.isr_vector))
        \\  } > flash0
        \\
        \\  .text : ALIGN({d})
        \\  {
        \\    KEEP(*(startup))
        \\    *(.text*)
        \\  } > flash0
        \\
        \\  .data : AT > flash0 ALIGN({d})
        \\  {
        \\    _data_start = .;
        \\    *(.data*)
        \\    *(.rodata)
        \\    _data_end = .;
        \\  } > ram0
        \\
        \\  .bss (NOLOAD) : ALIGN({d})
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
        \\}
    , .{ alignment, alignment, alignment });

    // Add memory overflow assertions
    try writer.writeAll(
        \\  ASSERT(SIZEOF(.text) + SIZEOF(.data) < LENGTH(flash0), "Flash memory overflow");
    );
    try writer.writeAll(
        \\  ASSERT(SIZEOF(.bss) < LENGTH(ram0), "RAM overflow");
    );
}

/// Entry point to the Zig program, responsible for generating the linker script.
pub comptime fn generateLinker(target: []const u8, output_path: []const u8) !void {
    const selected_target = selectTarget(target) orelse return std.debug.print("Target not found: {s}\n", .{target});

    // Generate linker script for the selected target
    try GenerateLinkerFile(selected_target, output_path, 8, "main");
    std.debug.print("Linker script generated at: {s}\n", .{output_path});
}

/// Selects the target based on the name provided from the command line.
comptime fn selectTarget(name: []const u8) ?TargetType {
    // Match target name to the correct target definition
    if (std.mem.eql(u8, name, "STM32F103")) {
        return Targets.STM32F103;
    } else if (std.mem.eql(u8, name, "STM32F407")) {
        return Targets.STM32F407;
    } else if (std.mem.eql(u8, name, "STM32F030")) {
        return Targets.STM32F030;
    } else if (std.mem.eql(u8, name, "STM32H743")) {
        return Targets.STM32H743;
    } else if (std.mem.eql(u8, name, "STM32L476")) {
        return Targets.STM32L476;
    } else if (std.mem.eql(u8, name, "PIC18F2550")) {
        return Targets.PIC18F2550;
    } else if (std.mem.eql(u8, name, "PIC18F4550")) {
        return Targets.PIC18F4550;
    }
    return null;
}
