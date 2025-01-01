const std = @import("std");
const builtin = @import("builtin");
const testing = std.testing;

// Track total allocated memory
var total_allocated: usize = 0;
var allocation_count: usize = 0;

fn trackAllocation(size: usize) void {
    total_allocated += size;
    allocation_count += 1;
}

fn trackFree(size: usize) void {
    total_allocated -= size;
    allocation_count -= 1;
}

// List Allocator Tests
test "List Allocator - malloc" {
    const c = @cImport({
        @cDefine("USE_LIST_ALLOCATOR", "1");
        @cInclude("virtualization/memory/heap.h");
    });
    var heap_memory: [1024]u8 align(8) = undefined;
    try testing.expect(c.AllocatorInit(&heap_memory, heap_memory.len) == 1);

    // Test NULL allocation
    const null_ptr = c.malloc(0);
    try testing.expect(null_ptr == @as(?*anyopaque, null));

    // Test normal allocation
    const size: usize = 32;
    const ptr = c.malloc(size);
    if (ptr == null) return error.MallocFailed;
    trackAllocation(size);

    // Test memory access
    const slice = @as([*]u8, @ptrCast(@alignCast(ptr)))[0..size];
    @memset(slice, 0xAA);
    for (slice) |byte| {
        try testing.expect(byte == 0xAA);
    }

    // Cleanup
    c.free(ptr);
    trackFree(size);
}

test "List Allocator - calloc" {
    const c = @cImport({
        @cDefine("USE_LIST_ALLOCATOR", "1");
        @cInclude("virtualization/memory/heap.h");
    });
    var heap_memory: [1024]u8 align(8) = undefined;
    try testing.expect(c.AllocatorInit(&heap_memory, heap_memory.len) == 1);

    const elements: usize = 4;
    const element_size: usize = 8;
    const ptr = c.calloc(elements, element_size);
    if (ptr == null) return error.CallocFailed;
    trackAllocation(elements * element_size);

    // Verify zero initialization
    const slice = @as([*]u8, @ptrCast(@alignCast(ptr)))[0 .. elements * element_size];
    for (slice) |byte| {
        try testing.expect(byte == 0);
    }

    c.free(ptr);
    trackFree(elements * element_size);
}
