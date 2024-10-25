const std = @import("std");
const LinkerGenerator = @import("tools/LinkerGenerator.zig");

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

    ARTOS.linker.generateLinker(target_name, output_path) catch {
        std.debug.print("Failed to generate linker script for target: {s}\n", .{target_name});
        return;
    };

    const exe = b.addExecutable(.{
        .name = "pic_project",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .linkerscript = output_path,
    });

    exe.linkLibrary(ARTOS.artifact("A_RTOS_M"));
    b.installArtifact(exe);
    exe.linkSystemLibrary("c");
    b.installArtifact(exe);
}
