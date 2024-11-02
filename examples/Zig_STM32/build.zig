const std = @import("std");
const CompOS = @import("CompOS");
const OSBuilder = CompOS.OSBuilder;

pub fn build(b: *std.Build) !void {
    const lib = try OSBuilder.init(b, .{
        .optimize = .ReleaseFast,
        .target = "STM32F103",
        .lib_type = "Static",
    });
    _ = lib;

    const target_name: []const u8 = "STM32F103";
    const output_path = "STM32F103_linker.ld";
    try OSBuilder.generateLinker(target_name, output_path);

    // Create the main executable
    const exe = try OSBuilder.AddFirmware(b, .{
        .name = "firmware.elf",
        .root_source_file = b.path("src/main.zig"),
        .target = OSBuilder.GetTarget(),
        .optimize = OSBuilder.GetOptimize(),
    });
    exe.setLinkerScript(b.path(output_path));
    b.install_path = "install";
    b.installArtifact(exe);

    // Generate binary output
    const bin = exe.addObjCopy(.{ .format = .bin });
    const installBin = b.addInstallBinFile(bin.getOutput(), "output.bin");

    b.getInstallStep().dependOn(&installBin.step);

    // Generate compile commands for Intellisense
    OSBuilder.AddCompileCommandStep(b, exe);
}
