const std = @import("std");
const ARTOS = @import("A_RTOS_M");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const target_name: []const u8 = "PIC18F4550";
    const output_path = "tools/pic18f4550_linker.ld";

    const ArtosDep = b.dependency("A_RTOS_M", .{
        .Compile_Target = "STM32F407",
        .Optimization = "ReleaseSafe",
        .Library_Type = "Static",
    });

    // Retrieve the main artifact from A_RTOS_M
    const ArtosExe = ArtosDep.artifact("A_RTOS_M");

    // Generate the linker script using the linker tool from A_RTOS_M
    ARTOS.AddGeneratedLinker(target_name, output_path);

    // Create the main executable, linking with the generated linker script
    const exe = b.addExecutable(.{
        .name = "project.elf",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .linkerscript = output_path,
    });
    exe.linkLibrary(ArtosExe); // Link the A_RTOS_M library
    b.installArtifact(exe);

    // Generate binary output
    const bin = exe.addObjCopy(.{ .format = .bin });
    const installBin = b.addInstallBinFile(bin.getOutput(), "output.bin");
    b.getInstallStep().dependOn(&installBin.step);

    // Generate compile commands for Intellisense
    ARTOS.AddCompileCommandStep(b, exe);
}
