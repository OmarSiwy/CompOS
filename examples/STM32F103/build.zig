const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const target_name: []const u8 = "PIC18F4550";
    const output_path = "tools/pic18f4550_linker.ld";

    const ARTOS = b.dependency("A_RTOS_M", .{
        .Compile_Target = "STM32F103",
        .Optimization = "ReleaseSafe",
        .Library_Type = "Static",
    });

    const linker = ARTOS.artifact("A_RTOS_M");
    linker.linker.generateLinker(target_name, output_path) catch {
        std.debug.print("Failed to generate linker script for target: {s}\n", .{target_name});
        return;
    };
    const exe = b.addExecutable(.{
        .name = "project",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .linkerscript = output_path,
    });

    exe.linkLibrary(ARTOS.artifact("A_RTOS_M"));
    exe.linkSystemLibrary("c");
    exe.install(); // Installs .hex file to flash
}
