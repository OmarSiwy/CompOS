const std = @import("std");
pub const Targets = @import("tools/SupportedTargets.zig");
pub const make = @import("tools/MakeTools.zig");

const OSBuilder = @This();

const LibraryType = enum { Static, Shared };
pub const InitOptions = struct {
    optimize: std.builtin.OptimizeMode,
    target: []const u8,
    lib_type: []const u8,
};

var library: *std.Build.Step.Compile = undefined;
var TargetOption: std.Build.ResolvedTarget = undefined;
var optimize: std.builtin.OptimizeMode = undefined;

fn root() []const u8 {
    return comptime (std.fs.path.dirname(@src().file) orelse ".");
}
const build_root = root();

pub fn GetTarget() std.Build.ResolvedTarget {
    return TargetOption;
}

pub fn GetOptimize() std.builtin.OptimizeMode {
    return optimize;
}

pub fn AddFirmware(b: *std.Build, custom_options: std.Build.ExecutableOptions) !*std.Build.Step.Compile {
    if (library == undefined) {
        return error.LibraryNotInitialized;
    }

    const exe = b.addExecutable(custom_options);
    exe.linkLibrary(library);
    return exe;
}

pub fn init(b: *std.Build, options: InitOptions) !*std.Build.Step.Compile {
    optimize = options.optimize;
    const TargetStr = options.target;
    const lib_type_str = options.lib_type;

    const TargetEnumVal = std.meta.stringToEnum(Targets.Targets.TargetEnum, TargetStr) orelse {
        std.debug.print("Received unknown target: {s}\n", .{TargetStr});
        return error.UnknownTarget;
    };
    const selected_target = Targets.SelectTarget(TargetStr);
    if (selected_target == null and !std.mem.eql(u8, TargetStr, "testing")) {
        std.debug.print("Target {s} is not supported\n", .{TargetStr});
        return error.UnsupportedTarget;
    }
    TargetOption = switch (TargetEnumVal) {
        .STM32F103, .STM32F407, .STM32F030, .STM32H743, .STM32F303, .STM32L476 => b.standardTargetOptions(.{
            .default_target = .{
                .cpu_arch = .thumb,
                .cpu_model = .{ .explicit = selected_target.?.cpu_model },
                .os_tag = .freestanding,
                .abi = .none,
            },
        }),
        else => b.standardTargetOptions(.{}),
    };

    const lib_type = std.meta.stringToEnum(LibraryType, lib_type_str) orelse {
        std.debug.print("Received unknown library type: {s}\n", .{lib_type_str});
        return error.UnknownLibraryType;
    };

    // Define library component with selected library type
    const lib = switch (lib_type) {
        .Static => b.addStaticLibrary(.{
            .name = "helper",
            .root_source_file = .{ .cwd_relative = build_root ++ "/../src/ZigAPI.zig" },
            .optimize = optimize,
            .target = TargetOption,
            .strip = true,
        }),
        .Shared => b.addSharedLibrary(.{
            .name = "helper",
            .root_source_file = .{ .cwd_relative = build_root ++ "/../src/ZigAPI.zig" },
            .optimize = optimize,
            .target = TargetOption,
            .strip = true,
        }),
    };
    lib.dead_strip_dylibs = true;

    // Collect & Compile source files (.c and .zig)
    const source_slice = try OSBuilder.make.GlobFiles(b, "src/", ".c");
    const cflags = .{ "-std=c99", "-Wall", "-W", "-g", "-O2", "-ffast-math", "-ffunction-sections", "-fdata-sections" };
    lib.addCSourceFiles(.{
        .files = source_slice,
        .flags = &cflags,
    });
    lib.addIncludePath(.{ .cwd_relative = build_root ++ "/../inc" });

    library = lib;
    return lib;
}

pub fn build(b: *std.Build) void {
    _ = b;
}

/// Entry point to the Zig program, responsible for generating the linker script.
pub fn generateLinker(target: []const u8, output_path: []const u8) !void {
    const Linker = @import("tools/LinkerGenerator.zig");
    const selected_target = Targets.SelectTarget(target);

    // Generate linker script for the selected target
    const targets = selected_target.?;
    try Linker.GenerateLinkerFile(targets.*, output_path, "_start");
    std.debug.print("Linker script generated at: {s}\n", .{output_path});
}

pub fn AddCompileCommandStep(b: *std.Build, lib: *std.Build.Step.Compile) void {
    const zcc = @import("tools/CompileCommands.zig");
    var targets_files = std.ArrayList(*std.Build.Step.Compile).init(b.allocator);
    defer targets_files.deinit();
    targets_files.append(lib) catch @panic("OOM");
    zcc.createStep(b, "cdb", targets_files.toOwnedSlice() catch @panic("OOM"));
}
