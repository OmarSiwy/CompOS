const std = @import("std");
const CompOS = @import("CompOS");
const OsBuilder = CompOS.OsBuilder;

pub fn build(b: *std.Build) !void {
    // Set target and optimization options
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const target_name: []const u8 = "STM32F103";
    const output_path = "STM32F103_linker.ld";

    // Initialize OsBuilder and generate linker
    OsBuilder.init(b);
    try OsBuilder.generateLinker(target_name, output_path);

    // Set up dependency on CompOS
    const Target: []const u8 = "STM32F103";
    const Type: []const u8 = "Static";
    const mz_dep = b.dependency("CompOS", .{
        .optimize = .ReleaseFast,
        .Compile_Target = Target,
        .Library_Type = Type,
    });

    // Create the main executable
    const exe = b.addExecutable(.{
        .name = "project",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
    });
    exe.linkLibrary(mz_dep.artifact("CompOS"));
    exe.is_linking_libc = true;
    b.installArtifact(exe);

    // Generate binary output
    const bin = exe.addObjCopy(.{ .format = .bin });
    const installBin = b.addInstallBinFile(bin.getOutput(), "output.bin");
    b.getInstallStep().dependOn(&installBin.step);

    // Generate compile commands for Intellisense
    OsBuilder.AddCompileCommandStep(b, exe);
}
