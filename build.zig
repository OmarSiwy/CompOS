const std = @import("std");
/// Target Selection for Building
const suptarget = @import("tools/SupportedTargets.zig");

const cflags = .{
    "-std=c99",
    "-Wall",
    "-W",
    "-g",
    "-O2",
    "-ffast-math",
    "-ffunction-sections",
    "-fdata-sections",
};

const OptimizeMode = enum { Debug, ReleaseSafe, ReleaseFast, ReleaseSmall };
const LibraryType = enum { Static, Shared };

const ARTOS = @This();

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
        std.debug.print("Received unknown target: {s}\n", .{TargetStr});
        return error.UnknownTarget;
    };
    const selected_target = suptarget.SelectTarget(TargetEnumVal);

    var TargetOption: std.Build.ResolvedTarget = undefined; // Declare `TargetOption` with the appropriate type

    if (selected_target) |target| {
        TargetOption = switch (TargetEnumVal) {
            .STM32F103, .STM32F407, .STM32F030, .STM32H743, .STM32F303, .STM32L476 => b.standardTargetOptions(.{
                .default_target = .{
                    .cpu_arch = .thumb,
                    .cpu_model = .{ .explicit = target.cpu_model },
                    .os_tag = .freestanding,
                    .abi = .none,
                },
            }),
            else => b.standardTargetOptions(.{}),
        };
    } else {
        TargetOption = b.standardTargetOptions(.{});
    }

    // Library Type
    const lib_type_str = b.option([]const u8, "Library_Type", "The type of library").?;
    const lib_type = std.meta.stringToEnum(LibraryType, lib_type_str) orelse {
        std.debug.print("Received unknown library type: {s}\n", .{lib_type_str});
        return error.UnknownLibraryType;
    };

    // Define library component with selected library type
    const zig_part_of_lib = switch (lib_type) {
        .Static => b.addStaticLibrary(.{
            .name = "helper",
            .root_source_file = .{ .cwd_relative = "src/ZigAPI.zig" },
            .optimize = optimize,
            .target = TargetOption,
            .strip = true,
        }),
        .Shared => b.addSharedLibrary(.{
            .name = "helper",
            .root_source_file = .{ .cwd_relative = "src/ZigAPI.zig" },
            .optimize = optimize,
            .target = TargetOption,
            .strip = true,
        }),
    };
    const lib = switch (lib_type) {
        .Static => b.addStaticLibrary(.{
            .name = "A-RTOS-M",
            .target = TargetOption,
            .optimize = optimize,
            .link_libc = true,
            .strip = true,
        }),
        .Shared => b.addSharedLibrary(.{
            .name = "A-RTOS-M",
            .target = TargetOption,
            .optimize = optimize,
            .link_libc = true,
            .strip = true,
        }),
    };
    lib.linkLibrary(zig_part_of_lib);
    lib.dead_strip_dylibs = true;

    // Collect & Compile source files (.c and .zig)
    var sources = std.ArrayList([]const u8).init(b.allocator);
    defer sources.deinit();
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
        }
    }

    const source_slice = try sources.toOwnedSlice();

    lib.addCSourceFiles(.{
        .files = source_slice,
        .flags = &cflags,
    });
    lib.addIncludePath(.{ .cwd_relative = "inc" });

    b.installArtifact(lib);

    // Test setup
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

    // Compile Commands for Intellisense
    AddCompileCommandStep(b, lib);
}

pub fn AddGeneratedLinker(target: []const u8, output_path: []const u8) void {
    const linker = @import("tools/LinkerGenerator.zig");
    linker.generateLinker(target, output_path);
}

pub fn AddCompileCommandStep(b: *std.Build, lib: *std.Build.Step.Compile) void {
    const zcc = @import("tools/CompileCommands.zig");
    var targets = std.ArrayList(*std.Build.Step.Compile).init(b.allocator);
    defer targets.deinit();
    targets.append(lib) catch @panic("OOM");
    zcc.createStep(b, "cdb", targets.toOwnedSlice() catch @panic("OOM"));
}
