const std = @import("std");
pub const Targets = @import("tools/SupportedTargets.zig");
pub const make = @import("tools/MakeTools.zig");

const OSBuilder = @This();

pub fn build(b: *std.Build) !void {
    _ = b;
}

pub fn init(b: *std.Build) void {
    _ = b;
}

/// Entry point to the Zig program, responsible for generating the linker script.
pub fn generateLinker(target: []const u8, output_path: []const u8) !void {
    const Linker = @import("tools/LinkerGenerator.zig");
    const selected_target = try Targets.SelectTarget(target);

    // Generate linker script for the selected target
    try Linker.GenerateLinkerFile(selected_target.*, output_path, "_start");
    std.debug.print("Linker script generated at: {s}\n", .{output_path});
}

pub fn AddCompileCommandStep(b: *std.Build, lib: *std.Build.Step.Compile) void {
    const zcc = @import("tools/CompileCommands.zig");
    var targets_files = std.ArrayList(*std.Build.Step.Compile).init(b.allocator);
    defer targets_files.deinit();
    targets_files.append(lib) catch @panic("OOM");
    zcc.createStep(b, "cdb", targets_files.toOwnedSlice() catch @panic("OOM"));
}
