const std = @import("std");
const builtin = @import("builtin");
const c = @cImport({
    @cInclude("virtualization/memory/heap.h");
});
const page_size = std.mem.page_size;

// Initialize heap memory for tests
var heap_memory: [page_size * 64]u8 align(16) = undefined;

test "C malloc - basic allocation" {
    if (c.AllocatorInit(&heap_memory, heap_memory.len) == 0) {
        return error.HeapInitFailed;
    }
    defer c.AllocatorDeinit();

    const size: usize = 1024;
    const ptr = c.malloc(size);
    defer c.free(ptr);
    if (ptr == null) return error.AllocationFailed;

    // Test we can write to the memory
    const data: [*]u8 = @ptrCast(ptr);
    data[0] = 0xFF;
    data[size - 1] = 0xFF;
    try std.testing.expect(data[0] == 0xFF);
    try std.testing.expect(data[size - 1] == 0xFF);
}

test "C calloc - zeroed memory" {
    if (c.AllocatorInit(&heap_memory, heap_memory.len) == 0) {
        return error.HeapInitFailed;
    }
    defer c.AllocatorDeinit();

    const num_elements: usize = 100;
    const element_size: usize = 4;

    const ptr = c.calloc(num_elements, element_size);
    defer c.free(ptr);
    if (ptr == null) return error.AllocationFailed;

    // Check that memory is zeroed
    const data: [*]u8 = @ptrCast(ptr);
    var i: usize = 0;
    while (i < num_elements * element_size) : (i += 1) {
        try std.testing.expect(data[i] == 0);
    }
}

test "C realloc - expand allocation" {
    if (c.AllocatorInit(&heap_memory, heap_memory.len) == 0) {
        return error.HeapInitFailed;
    }
    defer c.AllocatorDeinit();

    const initial_size: usize = 70;
    const larger_size: usize = page_size * 2 + 50;

    // Initial allocation
    var ptr = c.malloc(initial_size);
    if (ptr == null) return error.AllocationFailed;

    // Write some data
    const data: [*]u8 = @ptrCast(ptr);
    data[0] = 0x12;
    data[60] = 0x34;

    // Reallocate to larger size
    ptr = c.realloc(ptr, larger_size);
    if (ptr == null) return error.ReallocationFailed;
    defer c.free(ptr);

    // Check if data was preserved
    const new_data: [*]u8 = @ptrCast(ptr);
    try std.testing.expect(new_data[0] == 0x12);
    try std.testing.expect(new_data[60] == 0x34);
}

test "C realloc - special cases" {
    if (c.AllocatorInit(&heap_memory, heap_memory.len) == 0) {
        return error.HeapInitFailed;
    }
    defer c.AllocatorDeinit();

    // Test realloc of NULL pointer (should act like malloc)
    const size: usize = 100;
    var ptr = c.realloc(null, size);
    if (ptr == null) return error.AllocationFailed;

    // Write some data
    const data: [*]u8 = @ptrCast(ptr);
    data[0] = 0x12;

    // Test shrinking
    ptr = c.realloc(ptr, 50);
    if (ptr == null) return error.ReallocationFailed;

    // Original data should be preserved
    const shrunk_data: [*]u8 = @ptrCast(ptr);
    try std.testing.expect(shrunk_data[0] == 0x12);

    // Test realloc to size 0 (should free)
    _ = c.realloc(ptr, 0);
}

test "C memory functions - error cases" {
    if (c.AllocatorInit(&heap_memory, heap_memory.len) == 0) {
        return error.HeapInitFailed;
    }
    defer c.AllocatorDeinit();

    // Test calloc with overflow
    try std.testing.expect(c.calloc(std.math.maxInt(usize), 2) == null);

    // Test free with NULL
    c.free(null); // Should not crash

    // Test malloc(0) - implementation defined, but should not crash
    const ptr = c.malloc(0);
    if (ptr != null) c.free(ptr);
}

test "C malloc - stress test" {
    if (c.AllocatorInit(&heap_memory, heap_memory.len) == 0) {
        return error.HeapInitFailed;
    }
    defer c.AllocatorDeinit();

    const num_iterations: usize = 5;
    const min_size: usize = @sizeOf(usize);
    const max_size: usize = 256;

    var i: usize = 0;
    var rng = std.rand.DefaultPrng.init(@as(u64, 43));
    const random = rng.random();

    while (i < num_iterations) : (i += 1) {
        // Allocate a random-sized block between min_size and max_size
        const size: usize = min_size + random.uintAtMost(usize, max_size - min_size);
        const ptr = c.malloc(size);
        if (ptr == null) {
            std.debug.print("Failed to allocate {} bytes at iteration {}\n", .{ size, i });
            return error.AllocationFailed;
        }

        // Write to memory
        const data = @as([*]u8, @ptrCast(ptr.?));
        const val: u8 = @truncate(i);
        @memset(data[0..size], val);

        // Verify memory contents
        try std.testing.expect(data[0] == val);
        try std.testing.expect(data[size - 1] == val);

        // Reallocate memory to a new size
        const new_size: usize = min_size + random.uintAtMost(usize, max_size - min_size);
        const new_ptr = c.realloc(ptr, new_size);
        if (new_ptr == null) {
            std.debug.print("Failed to reallocate from {} to {} bytes at iteration {}\n", .{ size, new_size, i });
            return error.ReallocationFailed;
        }

        // Verify old data is preserved after reallocation
        const new_data: [*]u8 = @ptrCast(new_ptr);
        try std.testing.expect(new_data[0] == val);

        // Free the memory
        c.free(new_ptr);
    }

    const end_time = std.time.microTimestamp();
    const total_duration = end_time - std.time.microTimestamp();
    std.debug.print("Total time for test, took {} microseconds\n", .{total_duration});
    std.debug.print("Stress test with {} iterations completed successfully.\n", .{num_iterations});
}
