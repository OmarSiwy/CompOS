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

    // Generate the linker script
    ARTOS.AddGeneratedLinker(target_name, output_path) catch {
        std.debug.print("Failed to generate linker script for target: {s}\n", .{target_name});
        return;
    };

    // Create an executable with the generated linker script
    const exe = b.addExecutable(.{
        .name = "project",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .linkerscript = output_path,
    });

    // Link the external library
    exe.linkLibrary(ARTOS.artifact("A_RTOS_M"));
    exe.install(); // Installs the .hex file for flashing

    // Generate compile commands for Intellisense
    ARTOS.AddCompileCommandStep(b, exe);

    // Emit all binary formats
    ARTOS.EmitAll(b);

    // Print ELF file size for reference
    ARTOS.PrintSize(b);
}
