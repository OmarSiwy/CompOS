const std = @import("std");
const CompOS = @import("CompOS");
const OSBuilder = CompOS.OSBuilder;

pub fn build(b: *std.Build) !void {
    const lib = try OSBuilder.init(b, .{
        .optimize = .ReleaseFast,
        .target = "STM32F103",
        .lib_type = "Static",
    });
    b.installArtifact(lib);

    const target_name: []const u8 = "STM32F103";
    const output_path = "STM32F103_linker.ld";
    try OSBuilder.generateLinker(target_name, output_path);

    // Create the main executable
    const exe = try OSBuilder.AddFirmware(b, .{
        .name = "firmware.elf",
        .target = OSBuilder.GetTarget(),
        .optimize = OSBuilder.GetOptimize(),
        .strip = true,
        .unwind_tables = false,
        .error_tracing = false,
        .single_threaded = true,
        .omit_frame_pointer = true,
    });

    // Collect & Compile source files (.c and .zig)
    const source_slice = try OSBuilder.make.GlobFiles(b, "src/", ".c");
    const cflags = .{ "-std=c99", "-Wall", "-W", "-g", "-O2", "-ffast-math", "-ffunction-sections", "-fdata-sections" };
    exe.addCSourceFiles(.{
        .files = source_slice,
        .flags = &cflags,
    });
    exe.addIncludePath(.{ .cwd_relative = "inc" });

    // Set the Linker Script
    exe.setLinkerScript(b.path(output_path));
    b.installArtifact(exe);

    // Generate binary output
    const bin = exe.addObjCopy(.{ .format = .bin });
    const installBin = b.addInstallBinFile(bin.getOutput(), "output.bin");

    b.getInstallStep().dependOn(&installBin.step);

    // Generate compile commands for Intellisense
    OSBuilder.AddCompileCommandStep(b, exe);
}
