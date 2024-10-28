const std = @import("std");
pub const OsBuilder = @import("build");
const targets = OsBuilder.Targets;

const OptimizeMode = enum { Debug, ReleaseSafe, ReleaseFast, ReleaseSmall };
const LibraryType = enum { Static, Shared };

const CompOs = @This();

pub fn build(b: *std.Build) !void {
    const library = OsBuilder.init(b);
    _ = library;

    // -Doptimize=<Debug/ReleaseSafe/ReleaseFast/ReleaseSmall>
    const optimize = b.standardOptimizeOption(.{});
    // -DCompile_Target=<Target>
    const TargetStr = b.option([]const u8, "Compile_Target", "The build target").?;
    // -DLibrary_Type=<Static/Shared>
    const lib_type_str = b.option([]const u8, "Library_Type", "The type of library").?;

    // Target []const u8 to enum
    std.debug.print("Target: {s}\n", .{TargetStr});
    const TargetEnumVal = std.meta.stringToEnum(targets.Targets.TargetEnum, TargetStr) orelse {
        std.debug.print("Received unknown target: {s}\n", .{TargetStr});
        return error.UnknownTarget;
    };
    const selected_target = try targets.SelectTarget(TargetStr);

    var TargetOption: std.Build.ResolvedTarget = undefined; // Declare `TargetOption` with the appropriate type

    TargetOption = switch (TargetEnumVal) {
        .STM32F103, .STM32F407, .STM32F030, .STM32H743, .STM32F303, .STM32L476 => b.standardTargetOptions(.{
            .default_target = .{
                .cpu_arch = .thumb,
                .cpu_model = .{ .explicit = selected_target.cpu_model },
                .os_tag = .freestanding,
                .abi = .none,
            },
        }),
        else => b.standardTargetOptions(.{}),
    };

    // Library Type []const u8 to enum
    const lib_type = std.meta.stringToEnum(LibraryType, lib_type_str) orelse {
        std.debug.print("Received unknown library type: {s}\n", .{lib_type_str});
        return error.UnknownLibraryType;
    };

    // Define library component with selected library type
    const zig_part_of_lib = switch (lib_type) {
        .Static => b.addStaticLibrary(.{
            .name = "helper",
            .root_source_file = b.path("src/ZigAPI.zig"),
            .optimize = optimize,
            .target = TargetOption,
            .strip = true,
        }),
        .Shared => b.addSharedLibrary(.{
            .name = "helper",
            .root_source_file = b.path("src/ZigAPI.zig"),
            .optimize = optimize,
            .target = TargetOption,
            .strip = true,
        }),
    };
    const lib = switch (lib_type) {
        .Static => b.addStaticLibrary(.{
            .name = "CompOS",
            .target = TargetOption,
            .optimize = optimize,
            .link_libc = true,
            .strip = true,
        }),
        .Shared => b.addSharedLibrary(.{
            .name = "CompOS",
            .target = TargetOption,
            .optimize = optimize,
            .link_libc = true,
            .strip = true,
        }),
    };
    lib.linkLibrary(zig_part_of_lib);
    lib.dead_strip_dylibs = true;

    // Collect & Compile source files (.c and .zig)
    const source_slice = try OsBuilder.make.GlobFiles(b, "src", ".c");

    const cflags = .{ "-std=c99", "-Wall", "-W", "-g", "-O2", "-ffast-math", "-ffunction-sections", "-fdata-sections" };
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
    OsBuilder.AddCompileCommandStep(b, lib);
}
