const std = @import("std");

pub fn GlobFiles(b: *std.Build, path: []const u8, extension: []const u8) ![][]const u8 {
    var sources = std.ArrayList([]const u8).init(b.allocator);
    defer sources.deinit();
    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    var walker = try dir.walk(b.allocator);
    defer walker.deinit();

    const allowed_exts = [_][]const u8{extension};
    while (try walker.next()) |entry| {
        const ext = std.fs.path.extension(entry.basename);
        const is_file = for (allowed_exts) |e| {
            if (std.mem.eql(u8, ext, e)) break true;
        } else false;
        if (is_file) {
            try sources.append(b.pathJoin(&[_][]const u8{ path, entry.path }));
        }
    }

    return sources.toOwnedSlice();
}

pub const exec_settings = struct {
    name: []const u8,
    target: []const u8,
    optimize: bool,
    root_source_file: []const u8,
};

pub fn MakeExecutable(b: *std.Build, settings: exec_settings, sources: [][]const u8) !void {
    const target = settings.target;
    const name = settings.name;
    const optimize = settings.optimize;
    const debug = settings.root_source_file;

    // Craete the Library


}
