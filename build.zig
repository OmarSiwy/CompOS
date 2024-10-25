const std = @import("std");

/// Exposed Libraries to the user:
/// Compile-Commands.Zig Generator:
const zcc = @import("tools/Compile_commands.zig");

/// Linker-Script.Zig Generator:
const linker = @import("tools/LinkerGenerator.zig");

/// Target Selection for Building:
const suptarget = @import("tools/SupportedTargets.zig");

const cflags = .{
    "-std=c99",
    "-Wall",
    "-W",
    "-g",
    "-O2",
    "-ffast-math",
};

const OptimizeMode = enum { Debug, ReleaseSafe, ReleaseFast, ReleaseSmall };
const LibraryType = enum { Static, Shared };

pub fn build(b: *std.Build) !void {
    // Optimization Mode
    const optimize_mode_str = b.option([]const u8, "Optimization", "The Optimization level").?;
    const optimize_mode = std.meta.stringToEnum(OptimizeMode, optimize_mode_str) orelse {
        std.debug.print("Received unknown optimization mode: {s}\n", .{optimize_mode_str});
        return error.UnknownOptimizationMode;
    };
    const optimize = switch (optimize_mode) {
        .Debug => std.builtin.Mode.Debug,
        .ReleaseSafe => std.builtin.Mode.ReleaseSafe,
        .ReleaseFast => std.builtin.Mode.ReleaseFast,
        .ReleaseSmall => std.builtin.Mode.ReleaseSmall,
    };

    // Build Target
    const TargetStr = b.option([]const u8, "Compile_Target", "The build target").?;
    const TargetEnumVal = std.meta.stringToEnum(suptarget.Targets.TargetEnum, TargetStr) orelse {
        std.debug.print("Received unknown optimization mode: {s}\n", .{TargetStr});
        return error.UnknownOptimizationMode;
    };
    const TargetOption = switch (TargetEnumVal) {
        .STM32F103, .STM32F407, .STM32F030, .STM32H743, .STM32F303, .STM32L476 => b.standardTargetOptions(
            .{ .default_target = .{ .cpu_arch = .arm, .cpu_model = .determined_by_cpu_arch, .os_tag = .freestanding } },
        ),
    };

    // Library Type
    const lib_type_str = b.option([]const u8, "Library_Type", "The type of library").?;
    const lib_type = std.meta.stringToEnum(LibraryType, lib_type_str) orelse {
        std.debug.print("Received unknown optimization mode: {s}\n", .{optimize_mode_str});
        return error.UnknownOptimizationMode;
    };
    const lib = switch (lib_type) {
        .Static => b.addStaticLibrary(.{
            .name = "A-RTOS-M",
            .target = TargetOption,
            .optimize = optimize,
            .root_source_file = .{ .cwd_relative = "src/helper.zig" },
            .link_libc = true,
        }),
        .Shared => b.addSharedLibrary(.{
            .name = "A-RTOS-M",
            .target = TargetOption,
            .optimize = optimize,
            .root_source_file = .{ .cwd_relative = "src/helper.zig" },
            .link_libc = true,
        }),
    };

    lib.linker = linker;

    // Collect & Compile all source files (.c and .zig)
    var sources = std.ArrayList([]const u8).init(b.allocator); // Array to store all file addresses
    defer sources.deinit();
    {
        var dir = try std.fs.cwd().openDir("src", .{ .iterate = true });
        var walker = try dir.walk(b.allocator);
        defer walker.deinit();

        const allowed_exts_c = [_][]const u8{".c"};
        while (try walker.next()) |entry| {
            const ext = std.fs.path.extension(entry.basename);

            // Handle C files
            const is_c_file = for (allowed_exts_c) |e| {
                if (std.mem.eql(u8, ext, e)) break true;
            } else false;
            if (is_c_file) {
                try sources.append(b.pathJoin(&[_][]const u8{ "src", entry.path }));
                continue;
            }
        }
    }
    const source_slice = try sources.toOwnedSlice();
    std.debug.print("Source files: {s}\n", .{source_slice});

    // Add Header and Source Files to Library
    lib.addCSourceFiles(.{
        .files = source_slice,
        .flags = &cflags,
    });
    lib.addIncludePath(.{ .cwd_relative = "inc" });
    // lib.installLibraryHeaders(); // not sure if needed or not
    std.debug.print("Header Files in build: {any}\n", .{lib.root_module.include_dirs.items});

    b.installArtifact(lib);

    // Extra for maintability
    // TESTING ________________________________________________________________
    const main_tests = b.addTest(.{
        .name = "Testing",
        .root_source_file = .{ .cwd_relative = "tests/All_test.zig" },
        .link_libc = true,
    });

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    main_tests.root_module.addIncludePath(.{ .cwd_relative = "inc" });
    main_tests.linkLibrary(lib);

    const run_unit_tests = b.addRunArtifact(main_tests);
    test_step.dependOn(&run_unit_tests.step);

    // COMPILE COMMANDS FOR INTELLISENSE _________________________________________________________
    var targets = std.ArrayList(*std.Build.Step.Compile).init(b.allocator);
    defer targets.deinit();
    targets.append(lib) catch @panic("OOM");
    zcc.createStep(b, "cdb", targets.toOwnedSlice() catch @panic("OOM"));
}
