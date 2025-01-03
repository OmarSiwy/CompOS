const std = @import("std");
pub const OSBuilder = @import("build");
const targets = OSBuilder.Targets;
const CompOS = @This();

fn root() []const u8 {
    return comptime (std.fs.path.dirname(@src().file) orelse ".");
}
const build_root = root();

pub fn build(build_ctx: *std.Build) !void {
    const target_options = build_ctx.standardTargetOptions(.{});
    const optimize = build_ctx.standardOptimizeOption(.{});
    const is_test = build_ctx.option(bool, "test", "Run test suite") orelse false;

    if (!is_test) { // Normal Library build
        const compile_target = build_ctx.option([]const u8, "Compile_Target", "Target to compile for") orelse "testing";
        const library_type = build_ctx.option([]const u8, "Library_Type", "Type of library to build (Static/Shared)") orelse "Static";

        const library = try OSBuilder.init(
            build_ctx,
            .{
                .optimize = optimize,
                .target = compile_target,
                .lib_type = library_type,
            },
            "",
        );

        const size_step_option = build_ctx.step("size", "Display size information of the built artifact");
        const size_step = build_ctx.addSystemCommand(&[_][]const u8{
            "size",
            "-A",
            "-d",
            library.getEmittedBin().getPath(build_ctx),
        });
        size_step.step.dependOn(&library.step);
        size_step_option.dependOn(&size_step.step);

        // Compile Commands for Intellisense
        OSBuilder.AddCompileCommandStep(build_ctx, library);
    } else {
        // Test scenarios
        const test_step = build_ctx.step("test", "Run all test scenarios");

        const allocator_options = [_][]const u8{
            // "USE_LIST_ALLOCATOR",
            "USE_ZIG_ALLOCATOR",
            "USE_CLANG_ALLOCATOR",
        };

        // Build test scenarios
        inline for (allocator_options) |allocator| {
            const test_name = build_ctx.fmt("test_scenario_{s}", .{allocator});

            // Build the library
            const lib = try OSBuilder.init(
                build_ctx,
                .{
                    .optimize = .Debug,
                    .target = "testing",
                    .lib_type = "Static",
                },
                allocator, // Add -D prefix
            );

            // Create test runner
            const run_test = build_ctx.addTest(.{
                .name = test_name,
                .root_source_file = .{ .cwd_relative = "tests/main_test.zig" },
                .optimize = .Debug,
                .target = target_options,
                .link_libc = true,
            });

            // Link with the library and add include paths
            run_test.linkLibrary(lib);
            run_test.addIncludePath(.{ .cwd_relative = build_root ++ "/inc" });
            run_test.addIncludePath(.{ .cwd_relative = build_root ++ "/src" });

            run_test.defineCMacro("TESTING_MODE", "1");
            run_test.defineCMacro(allocator, "1");

            // Create run step for this test
            const run_test_step = build_ctx.addRunArtifact(run_test);
            run_test_step.step.dependOn(&lib.step);
            test_step.dependOn(&run_test_step.step);
        }
    }
}
