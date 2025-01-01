const std = @import("std");

const heap = @cImport({
    @cInclude("virtualization/memory/heap.h");
});

const use_zig_allocator = @hasDecl(heap, "USE_ZIG_ALLOCATOR");

const ZigHeap = struct {
    allocator: std.mem.Allocator,
    gpa: std.heap.GeneralPurposeAllocator(.{}),
    
    pub fn init() ZigHeap {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        return .{
            .allocator = gpa.allocator(),
            .gpa = gpa,
        };
    }

    pub fn deinit(self: *ZigHeap) void {
        _ = self.gpa.deinit();
    }
};

var global_heap: ZigHeap = undefined;

// Only export the functions if USE_ZIG_ALLOCATOR is defined
comptime {
    if (use_zig_allocator) {
        @export(init, .{ .name = "init" });
        @export(malloc, .{ .name = "malloc" });
        @export(calloc, .{ .name = "calloc" });
        @export(realloc, .{ .name = "realloc" });
        @export(free, .{ .name = "free" });
    }
}

pub fn init(heap_start: *anyopaque, heap_size: usize) u8 {
    _ = heap_start;
    _ = heap_size;
    global_heap = ZigHeap.init();
    return 1; // Return 1 for success to match C convention
}

pub fn malloc(size: usize) ?*anyopaque {
    if (size == 0) return null;
    
    // Allocate with size prefix to store allocation size
    const alloc_size = size + @sizeOf(usize);
    const mem = global_heap.allocator.alloc(u8, alloc_size) catch return null;
    
    // Store size at start of allocation
    const size_ptr = @as(*usize, @ptrCast(@alignCast(mem.ptr)));
    size_ptr.* = size;
    
    // Return pointer after size storage
    return @ptrCast(mem.ptr + @sizeOf(usize));
}

pub fn calloc(n: usize, size: usize) ?*anyopaque {
    const total_size = n *% size;
    if (total_size == 0 or n > std.math.maxInt(usize) / size) return null;
    
    if (malloc(total_size)) |ptr| {
        @memset(@as([*]u8, @ptrCast(ptr))[0..total_size], 0);
        return ptr;
    }
    return null;
}

pub fn realloc(ptr: ?*anyopaque, new_size: usize) ?*anyopaque {
    if (new_size == 0) {
        if (ptr) |p| free(p);
        return null;
    }
    
    if (ptr == null) return malloc(new_size);
    
    const p = @as([*]u8, @ptrCast(ptr.?)) - @sizeOf(usize);
    const size_ptr = @as(*usize, @ptrCast(@alignCast(p)));
    const old_size = size_ptr.*;
    
    // Allocate new block with size prefix
    const alloc_size = new_size + @sizeOf(usize);
    const new_mem = global_heap.allocator.alloc(u8, alloc_size) catch return null;
    
    // Store new size
    const new_size_ptr = @as(*usize, @ptrCast(@alignCast(new_mem.ptr)));
    new_size_ptr.* = new_size;
    
    // Copy old data
    const copy_size = @min(old_size, new_size);
    @memcpy(new_mem[(@sizeOf(usize))..(@sizeOf(usize) + copy_size)], p[@sizeOf(usize)..(@sizeOf(usize) + copy_size)]);
    
    // Free old allocation
    global_heap.allocator.free(p[0..old_size + @sizeOf(usize)]);
    
    return @ptrCast(new_mem.ptr + @sizeOf(usize));
}

pub fn free(ptr: ?*anyopaque) void {
    if (ptr) |p| {
        const base_ptr = @as([*]u8, @ptrCast(p)) - @sizeOf(usize);
        const size_ptr = @as(*usize, @ptrCast(@alignCast(base_ptr)));
        const size = size_ptr.*;
        global_heap.allocator.free(base_ptr[0 .. size + @sizeOf(usize)]);
    }
}
