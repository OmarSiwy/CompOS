const std = @import("std");

// Global state
var buffer: [1024 * 1024]u8 align(@alignOf(usize)) = undefined; // 1MB buffer
var fba = std.heap.FixedBufferAllocator.init(&buffer);
const allocator = fba.allocator();

pub fn AllocatorInit(heap_start: *anyopaque, heap_size: usize) callconv(.C) u8 {
    _ = heap_start;
    _ = heap_size;
    return 1;
}

pub fn AllocatorDeinit() callconv(.C) void {
    // Reset the allocator
    fba = std.heap.FixedBufferAllocator.init(&buffer);
}

pub fn malloc(size: usize) callconv(.C) ?*anyopaque {
    if (size == 0) return null;
    
    // Add size prefix
    const total_size = size + @sizeOf(usize);
    const mem = allocator.alloc(u8, total_size) catch return null;
    
    // Store size at start
    const size_ptr = @as(*usize, @ptrCast(@alignCast(mem.ptr)));
    size_ptr.* = size;
    
    // Return pointer after size
    return @as(*anyopaque, @ptrCast(@alignCast(mem.ptr + @sizeOf(usize))));
}

pub fn calloc(num: usize, size: usize) callconv(.C) ?*anyopaque {
    // Check for overflow
    const requested_size = num *% size;
    if (size != 0 and requested_size / size != num) return null;
    if (requested_size == 0) return null;

    // Allocate memory
    const ptr = malloc(requested_size) orelse return null;
    
    // Zero the memory
    const data = @as([*]u8, @ptrCast(ptr));
    @memset(data[0..requested_size], 0);
    
    return ptr;
}

pub fn realloc(ptr: ?*anyopaque, new_size: usize) callconv(.C) ?*anyopaque {
    if (ptr == null and new_size > 0) return malloc(new_size);
    if (new_size == 0) {
        if (ptr) |p| free(p);
        return null;
    }

    if (ptr) |p| {
        // Get original size
        const size_ptr = @as(*usize, @ptrCast(@alignCast(@as([*]u8, @ptrCast(p)) - @sizeOf(usize))));
        const old_size = size_ptr.*;

        // If sizes match, no need to reallocate
        if (new_size == old_size) return ptr;

        // Allocate new memory
        const new_ptr = malloc(new_size) orelse return null;
        
        // Copy data
        const copy_size = @min(old_size, new_size);
        const old_data = @as([*]u8, @ptrCast(p));
        const new_data = @as([*]u8, @ptrCast(new_ptr));
        @memcpy(new_data[0..copy_size], old_data[0..copy_size]);
        
        // Free old memory
        free(p);
        
        return new_ptr;
    }
    return null;
}

pub fn free(ptr: ?*anyopaque) callconv(.C) void {
    if (ptr == null) return;
    
    // Get original size
    const size_ptr = @as(*usize, @ptrCast(@alignCast(@as([*]u8, @ptrCast(ptr.?)) - @sizeOf(usize))));
    const size = size_ptr.*;
    
    // Free entire allocation including size prefix
    const full_ptr = @as([*]u8, @ptrCast(size_ptr));
    allocator.free(full_ptr[0..(size + @sizeOf(usize))]);
}
