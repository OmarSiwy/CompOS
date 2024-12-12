const std = @import("std");
pub const OSBuilder = @import("build");
const targets = OSBuilder.Targets;

const CompOS = @This();

pub fn build(b: *std.Build) !void {
    // -Doptimize=<Debug/ReleaseSafe/ReleaseFast/ReleaseSmall>
    const optimize = b.standardOptimizeOption(.{});
    // -DCompile_Target=<Target>
    const TargetStr = b.option([]const u8, "Compile_Target", "The build target").?;
    // -DLibrary_Type=<Static/Shared>
    const lib_type_str = b.option([]const u8, "Library_Type", "The type of library").?;

    const lib = try OSBuilder.init(b, .{
        .optimize = optimize,
        .target = TargetStr,
        .lib_type = lib_type_str,
    });
    b.installArtifact(lib);

    // Test setup
    const main_tests = b.addTest(.{
        .name = "Testing",
        .root_source_file = b.path("tests/main_test.zig"),
        .link_libc = true,
    });

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
    main_tests.root_module.addIncludePath(b.path("inc"));
    main_tests.linkLibrary(lib);
    const run_unit_tests = b.addRunArtifact(main_tests);
    test_step.dependOn(&run_unit_tests.step);

    // Compile Commands for Intellisense
    OSBuilder.AddCompileCommandStep(b, lib);
}
