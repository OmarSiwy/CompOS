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
