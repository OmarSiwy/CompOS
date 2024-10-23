const std = @import("std");
const LinkerGenerator = @import("tools/LinkerGenerator.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(
        .name = "pic_project",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{.path = "src/main.zig"},
    );

    exe.linkSystemLibrary("A-RTOS-M");

    const target_name = "PIC18F4550";
    const output_path = "tools/pic18f4550_linker.ld";
    comptime LinkerGenerator.generateLinker(target_name, output_path);

    exe.linkSystemLibrary("c");
    exe.install();
}
