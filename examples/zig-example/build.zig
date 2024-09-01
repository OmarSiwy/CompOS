const std = @import("std");

pub fn build(b: *std.Build) void {
    // Optimizations/Target
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Link with A-RTOS-M Library
    const exe = b.addExecutable(.{
        .name = "my_project",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "src/main.zig" },
    });

    // Link against the external library
    exe.addIncludePath("path/to/A-RTOS-M/inc");
    exe.linkLibPath("path/to/A-RTOS-M/zig-out/lib");
    exe.linkSystemLibrary("A-RTOS-M");

    b.installArtifact(exe);
}
