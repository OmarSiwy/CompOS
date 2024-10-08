const std = @import("std");
const zcc = @import("compile_commands.zig");

const LibraryType = enum {
    Static,
    Shared,
};

const OptimizeMode = enum {
    Debug,
    ReleaseSafe,
    ReleaseFast,
    ReleaseSmall,
};

const TargetType = enum {
    M0,
    M1,
    M2,
    M3,
    M4,
};

const cflags = .{
    "-std=c99",
    "-Wall",
    "-W",
    "-g",
    "-O2",
    "-ffast-math",
};

pub fn build(b: *std.Build) !void {
    // Options to Build Library according to needs
    const optimize_mode = b.option(OptimizeMode, "Optimization", "The Optimization level to use from @OptimizeMode").?; // What Optimization Mode would you like, refer to @OptimizeMode
    const optimize = switch (optimize_mode) {
        OptimizeMode.Debug => std.builtin.Mode.Debug,
        OptimizeMode.ReleaseSafe => std.builtin.Mode.ReleaseSafe,
        OptimizeMode.ReleaseFast => std.builtin.Mode.ReleaseFast,
        OptimizeMode.ReleaseSmall => std.builtin.Mode.ReleaseSmall,
    };

    const build_target = b.option(TargetType, "Compile_Target", "The Build Target to use from @TargetType").?; // What Target are you building for, refer to @TargetType
    const target = switch (build_target) { // Picks Linker Script to provide to consumer, and target details
        TargetType.M0 => b.standardTargetOptions(.{}),
        TargetType.M1 => b.standardTargetOptions(.{}),
        TargetType.M2 => b.standardTargetOptions(.{}),
        TargetType.M3 => b.standardTargetOptions(.{}),
        TargetType.M4 => b.standardTargetOptions(.{}),
    };

    const lib_type = b.option(LibraryType, "Library_Type", "The Type of Library to use from @LibraryType").?; // Shared or Static Library, refer to @Library-Type
    const lib = switch (lib_type) {
        LibraryType.Static => b.addStaticLibrary(.{
            .name = "A-RTOS-M",
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
        LibraryType.Shared => b.addSharedLibrary(.{
            .name = "A-RTOS-M",
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    };
    std.debug.print("Lib Type: {any} | OptimizeMode: {any} | Build Target: {any}\n", .{ lib_type, optimize, target });

    // Collect & Compile all source files
    var sources = std.ArrayList([]const u8).init(b.allocator); // Array to store all file addresses
    defer sources.deinit();
    {
        var dir = try std.fs.cwd().openDir("src", .{ .iterate = true });
        var walker = try dir.walk(b.allocator);
        defer walker.deinit();

        const allowed_exts = [_][]const u8{".c"};
        while (try walker.next()) |entry| {
            const ext = std.fs.path.extension(entry.basename);
            const include_file = for (allowed_exts) |e| {
                if (std.mem.eql(u8, ext, e))
                    break true;
            } else false;
            if (include_file) { // if file extension is .c, then added it ot the array
                try sources.append(b.pathJoin(&[_][]const u8{ "src", entry.path }));
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
