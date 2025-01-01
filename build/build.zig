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
            .name = "CompOS",
            .root_source_file = .{ .cwd_relative = build_root ++ "/../src/ZigAPI.zig" },
            .optimize = .ReleaseSmall,
            .target = TargetOption,
            .strip = true,
            .single_threaded = true,
            .pic = false, // No position independent code needed for static lib
        }),
        .Shared => b.addSharedLibrary(.{
            .name = "CompOS",
            .root_source_file = .{ .cwd_relative = build_root ++ "/../src/ZigAPI.zig" },
            .optimize = .ReleaseSmall,
            .target = TargetOption,
            .strip = true,
            .single_threaded = true,
            .pic = true,
        }),
    };
    lib.linker_allow_shlib_undefined = true;
    lib.dead_strip_dylibs = true;

    // Add C source files with LTO flags
    const source_slice = try OSBuilder.make.GlobFiles(b, "src/", ".c");
    const cflags = .{
        "-std=c99",
        "-Os", // Optimize for size
        "-fdata-sections", // Put data in separate sections
        "-ffunction-sections", // Put functions in separate sections
        "-fno-unwind-tables", // Remove unwind tables
        "-fno-asynchronous-unwind-tables", // Remove async unwind tables
        "-fno-stack-protector", // Remove stack protector
        "-fomit-frame-pointer", // Remove frame pointer
        "-fno-exceptions", // No exceptions
        "-fno-rtti", // No runtime type info
        "-fno-common", // No common symbols
        "-fno-ident", // Remove ident section
        "-fno-builtin", // No builtin functions
        "-fno-plt", // No PLT
        "-fno-stack-check", // No stack checking
        "-mno-red-zone", // No red zone
        "-fwhole-program", // Enable whole program optimization
        "-ffunction-sections", // Put each function in its own section
        "-fdata-sections", // Put each data item in its own section
        "-Wl,--gc-sections", // Remove unused sections
        "-Wl,--strip-all", // Strip all symbols
        "-Wl,--build-id=none", // No build ID
        "-Wl,-z,norelro", // No relro
        "-Wl,--hash-style=gnu", // Use GNU hash style
        "-Wl,--no-eh-frame-hdr", // No exception frame headers
        "-Wl,--icf=all", // Identical code folding
        if (TargetEnumVal == .testing) "-DTESTING_MODE" else "",
    };
    lib.addCSourceFiles(.{
        .files = source_slice,
        .flags = &cflags,
    });
    lib.addIncludePath(.{ .cwd_relative = build_root ++ "/../inc" });

    // Install the library first
    const install_lib = b.addInstallArtifact(lib, .{});

    // Add size step after installation
    const lib_extension = if (std.mem.eql(u8, lib_type_str, "Shared")) "so" else "a";
    const lib_path = b.fmt("zig-out/lib/libCompOS.{s}", .{lib_extension});
    const size_step = b.addSystemCommand(&[_][]const u8{
        "size",
        "-A", // Show section sizes
        lib_path,
    });
    size_step.step.dependOn(&install_lib.step);

    // Add size as a build step option
    const size_step_option = b.step("size", "Display size information of the built artifact");
    size_step_option.dependOn(&size_step.step);

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
