const std = @import("std");

pub const Chip = struct {
    name: []const u8, // Name of the chip
    flash_origin: u64, // Start address of flash memory
    flash_size: u64, // Size of flash memory in bytes
    ram_origin: u64, // Start address of RAM memory
    ram_size: u64, // Size of RAM memory in bytes
    stack_top: u64, // Top of the stack (end of RAM)

    cpu_arch: []const u8 = "arm", // CPU architecture

    pub fn new(name: []const u8, flash_origin: ?u64, flash_size: ?u64, ram_origin: ?u64, ram_size: ?u64) ?Chip {
        if (flash_origin == null or flash_size == null or ram_origin == null or ram_size == null) {
            inline for (chips) |chip| {
                if (std.mem.eql(u8, chip.name, name)) {
                    return chip;
                }
            }
            @panic("Data for chip cannot be found, please provide other information!");
        }
        return Chip{
            .name = name,
            .flash_origin = flash_origin,
            .flash_size = flash_size,
            .ram_origin = ram_origin,
            .ram_size = ram_size,
            .stack_top = ram_origin + ram_size, // Stack top = end of RAM
        };
    }
};

// Predefined dataset of chips
const chips = [_]Chip{
    Chip.new("STM32F407VG", 0x08000000, 512 * 1024, 0x20000000, 128 * 1024),
    Chip.new("STM32F103C8", 0x08000000, 64 * 1024, 0x20000000, 20 * 1024),
    Chip.new("STM32H743ZI", 0x08000000, 2048 * 1024, 0x24000000, 512 * 1024),
    Chip.new("STM32F103RB", 0x08000000, 128 * 1024, 0x20000000, 20 * 1024),
};
