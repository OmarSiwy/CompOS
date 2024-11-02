/// Target Specifications
const std = @import("std");

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
    cpu_model: *const std.Target.Cpu.Model,
};

/// Supported Targets
pub const Targets = struct {
    pub const TargetEnum = enum {
        STM32F103,
        STM32F407,
        STM32F030,
        STM32H743,
        STM32L476,
        STM32F303,
        testing,
    };

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
        .cpu_model = &std.Target.arm.cpu.cortex_m3,
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
        .cpu_model = &std.Target.arm.cpu.cortex_m4,
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
        .cpu_model = &std.Target.arm.cpu.cortex_m0,
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
        .cpu_model = &std.Target.arm.cpu.cortex_m7,
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
        .cpu_model = &std.Target.arm.cpu.cortex_m4,
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
        .cpu_model = &std.Target.arm.cpu.cortex_m4,
    };
};

/// SelectTarget function with error handling
pub fn SelectTarget(TargetStr: []const u8) ?*const TargetType {
    const TargetEnumVal = std.meta.stringToEnum(Targets.TargetEnum, TargetStr);
    if (TargetEnumVal == null) {
        std.debug.print("Error: Unknown target '{s}'\n", .{TargetStr});
        return null;
    }
    const target_enum = TargetEnumVal.?;
    return switch (target_enum) {
        .STM32F103 => &Targets.STM32F103,
        .STM32F407 => &Targets.STM32F407,
        .STM32F030 => &Targets.STM32F030,
        .STM32H743 => &Targets.STM32H743,
        .STM32L476 => &Targets.STM32L476,
        .STM32F303 => &Targets.STM32F303,
        .testing => return null,
    };
}
