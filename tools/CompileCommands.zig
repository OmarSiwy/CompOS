// Credits to: https://github.com/the-argus/zig-compile-commands
const std = @import("std");

// here's the static memory!!!!
var compile_steps: ?[]*std.Build.Step.Compile = null;

const CSourceFiles = std.Build.Module.CSourceFiles;

const CompileCommandEntry = struct {
    arguments: []const []const u8,
    directory: []const u8,
    file: []const u8,
    output: []const u8,
};

pub fn createStep(b: *std.Build, name: []const u8, targets: []*std.Build.Step.Compile) void {
    const step = b.allocator.create(std.Build.Step) catch @panic("Allocation failure, probably OOM");

    compile_steps = targets;

    step.* = std.Build.Step.init(.{
        .id = .custom,
        .name = "cc_file",
        .makeFn = makeCdb,
        .owner = b,
    });

    const cdb_step = b.step(name, "Create compile_commands.json");
    cdb_step.dependOn(step);
}

fn extractIncludeDirsFromCompileStepInner(b: *std.Build, step: *std.Build.Step.Compile, lazy_path_output: *std.ArrayList(std.Build.LazyPath)) void {
    std.debug.print("items: {d}\n", .{step.root_module.include_dirs.items.len});
    for (step.root_module.include_dirs.items) |include_dir| {
        const path_str = include_dir.path.getPath(b);

        switch (include_dir) {
            .other_step => |other_step| {
                for (other_step.installed_headers.items) |header_step| {
                    std.debug.print("Appending header step source\n", .{});
                    lazy_path_output.append(header_step.getSource()) catch @panic("OOM");
                }
                var local_lazy_path_output = std.ArrayList(std.Build.LazyPath).init(b.allocator);
                defer local_lazy_path_output.deinit();
                extractIncludeDirsFromCompileStepInner(b, other_step, &local_lazy_path_output);
                lazy_path_output.appendSlice(local_lazy_path_output.items) catch @panic("OOM");
            },
            .path => {
                std.debug.print("Appending path: {s}\n", .{path_str});
                lazy_path_output.append(include_dir.path) catch @panic("OOM");
            },
            .path_system => {
                std.debug.print("Appending system path: {s}\n", .{path_str});
                lazy_path_output.append(include_dir.path_system) catch @panic("OOM");
            },
            .framework_path => |path| {
                std.log.warn("Found framework include path- compile commands generation for this is untested.", .{});
                lazy_path_output.append(path) catch @panic("OOM");
            },
            .framework_path_system => |path| {
                std.log.warn("Found system framework include path- compile commands generation for this is untested.", .{});
                lazy_path_output.append(path) catch @panic("OOM");
            },
            .path_after => |path| {
                std.log.warn("Found path_after- compile commands generation for this is untested.", .{});
                lazy_path_output.append(path) catch @panic("OOM");
            },
            else => {
                std.debug.print("Unknown include_dir type\n", .{});
            },
        }
    }
}

pub fn extractIncludeDirsFromCompileStep(b: *std.Build, step: *std.Build.Step.Compile) []const []const u8 {
    var dirs = std.ArrayList(std.Build.LazyPath).init(b.allocator);
    defer dirs.deinit();

    // Populates dirs
    extractIncludeDirsFromCompileStepInner(b, step, &dirs);

    var dirs_as_strings = std.ArrayList([]const u8).init(b.allocator);
    defer dirs_as_strings.deinit();

    // Resolve lazy paths all at once
    for (dirs.items) |lazy_path| {
        std.debug.print("Resolving lazy path: {s}\n", .{lazy_path.getPath(b)});
        dirs_as_strings.append(lazy_path.getPath(b)) catch @panic("OOM");
    }

    return dirs_as_strings.toOwnedSlice() catch @panic("OOM");
}

fn getCSources(b: *std.Build, steps: []const *std.Build.Step.Compile) []*CSourceFiles {
    var allocator = b.allocator;
    var res = std.ArrayList(*CSourceFiles).init(allocator);

    // move the compile steps into a mutable dynamic array, so we can add
    // any child steps
    var compile_steps_list = std.ArrayList(*std.Build.Step.Compile).init(b.allocator);
    compile_steps_list.appendSlice(steps) catch @panic("OOM");

    var index: u32 = 0;

    // list may be appended to during the loop, so use a while
    while (index < compile_steps_list.items.len) {
        const step = compile_steps_list.items[index];

        var shared_flags = std.ArrayList([]const u8).init(allocator);
        defer shared_flags.deinit();

        // catch all the system libraries being linked, make flags out of them
        for (step.root_module.link_objects.items) |link_object| {
            switch (link_object) {
                .system_lib => {
                    shared_flags.append(linkFlag(allocator, link_object.system_lib.name)) catch @panic("OOM");
                },
                else => {},
            }
        }

        if (step.is_linking_libc) {
            std.debug.print("Linking libc\n", .{});
            shared_flags.append(linkFlag(allocator, "c")) catch @panic("OOM");
        }
        if (step.is_linking_libcpp) {
            std.debug.print("Linking libcpp\n", .{});
            shared_flags.append(linkFlag(allocator, "c++")) catch @panic("OOM");
        }

        // make flags out of all include directories
        for (extractIncludeDirsFromCompileStep(b, step)) |include_dir| {
            shared_flags.append(includeFlag(b.allocator, include_dir)) catch @panic("OOM");
        }

        for (step.root_module.link_objects.items) |link_object| {
            switch (link_object) {
                .static_path => {
                    std.debug.print("Skipping static path\n", .{});
                    continue;
                },
                .other_step => {
                    std.debug.print("Appending other step\n", .{});
                    compile_steps_list.append(link_object.other_step) catch @panic("OOM");
                },
                .system_lib => {
                    std.debug.print("Skipping system lib\n", .{});
                    continue;
                },
                .assembly_file => {
                    std.debug.print("Skipping assembly file\n", .{});
                    continue;
                },
                .win32_resource_file => {
                    std.debug.print("Skipping win32 resource file\n", .{});
                    continue;
                },
                .c_source_file => {
                    const path = link_object.c_source_file.file.getPath(b);
                    var files_mem = allocator.alloc([]const u8, 1) catch @panic("Allocation failure, probably OOM");
                    files_mem[0] = path;

                    const source_file = allocator.create(CSourceFiles) catch @panic("Allocation failure, probably OOM");

                    var flags = std.ArrayList([]const u8).init(allocator);
                    flags.appendSlice(link_object.c_source_file.flags) catch @panic("OOM");
                    flags.appendSlice(shared_flags.items) catch @panic("OOM");

                    source_file.* = CSourceFiles{
                        .root = .{
                            .src_path = .{
                                .owner = b,
                                .sub_path = "src", // MAYBE________________________________________________________________________
                            },
                        },
                        .files = files_mem,
                        .flags = flags.toOwnedSlice() catch @panic("OOM"),
                    };

                    res.append(source_file) catch @panic("OOM");
                },
                .c_source_files => {
                    var source_files = link_object.c_source_files;
                    var flags = std.ArrayList([]const u8).init(allocator);
                    flags.appendSlice(source_files.flags) catch @panic("OOM");
                    flags.appendSlice(shared_flags.items) catch @panic("OOM");
                    source_files.flags = flags.toOwnedSlice() catch @panic("OOM");

                    res.append(source_files) catch @panic("OOM");
                },
            }
        }
        index += 1;
    }

    return res.toOwnedSlice() catch @panic("OOM");
}

fn makeCdb(step: *std.Build.Step, prog_node: std.Progress.Node) anyerror!void {
    if (compile_steps == null) {
        @panic("No compile steps registered. Programmer error in createStep");
    }
    _ = prog_node;
    const allocator = step.owner.allocator;

    var compile_commands = std.ArrayList(CompileCommandEntry).init(allocator);
    defer compile_commands.deinit();

    // initialize file and struct containing its future contents
    const cwd: std.fs.Dir = std.fs.cwd();
    var file = try cwd.createFile("compile_commands.json", .{});
    defer file.close();

    const cwd_string = try dirToString(cwd, allocator);
    const c_sources = getCSources(step.owner, compile_steps.?);

    // fill compile command entries, one for each file
    for (c_sources) |c_source_file_set| {
        const flags = c_source_file_set.flags;
        for (c_source_file_set.files) |c_file| {
            const file_str = if (std.fs.path.isAbsolute(c_file))
                c_file
            else
                std.fs.path.join(allocator, &[_][]const u8{ cwd_string, c_file }) catch @panic("OOM");

            const output_str = std.fmt.allocPrint(allocator, "{s}.o", .{file_str}) catch @panic("OOM");

            var arguments = std.ArrayList([]const u8).init(allocator);
            // pretend this is clang compiling
            arguments.append("clang") catch @panic("OOM");
            arguments.append(c_file) catch @panic("OOM");
            arguments.appendSlice(&.{ "-o", output_str }) catch @panic("OOM");
            arguments.appendSlice(flags) catch @panic("OOM");

            const entry = CompileCommandEntry{
                .arguments = arguments.toOwnedSlice() catch @panic("OOM"),
                .output = output_str,
                .file = file_str,
                .directory = cwd_string,
            };
            compile_commands.append(entry) catch @panic("OOM");
        }
    }

    try writeCompileCommands(&file, compile_commands.items);
}

fn writeCompileCommands(file: *std.fs.File, compile_commands: []CompileCommandEntry) !void {
    const options = std.json.StringifyOptions{
        .whitespace = .indent_tab,
        .emit_null_optional_fields = false,
    };

    try std.json.stringify(compile_commands, options, file.*.writer());
}

fn dirToString(dir: std.fs.Dir, allocator: std.mem.Allocator) ![]const u8 {
    var real_dir = try dir.openDir(".", .{});
    defer real_dir.close();
    return std.fs.realpathAlloc(allocator, ".") catch |err| {
        std.debug.print("Error encountered in converting directory to string.\n", .{});
        return err;
    };
}

fn linkFlag(ally: std.mem.Allocator, lib: []const u8) []const u8 {
    return std.fmt.allocPrint(ally, "-l{s}", .{lib}) catch @panic("OOM");
}

fn includeFlag(ally: std.mem.Allocator, path: []const u8) []const u8 {
    return std.fmt.allocPrint(ally, "-I{s}", .{path}) catch @panic("OOM");
}
