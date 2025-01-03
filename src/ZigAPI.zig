const ZigHeap = @import("./virtualization/memory/ZigHeap.zig");
// Heap Implemenentation export
const c = @cImport({
    @cInclude("../inc/virtualization/memory/heap.h");
});
comptime {
    if (@hasDecl(c, "USE_ZIG_ALLOCATOR")) {
        @export(ZigHeap.AllocatorInit, .{ .name = "AllocatorInit" });
        @export(ZigHeap.AllocatorDeinit, .{ .name = "AllocatorDeinit" });
        @export(ZigHeap.malloc, .{ .name = "malloc" });
        @export(ZigHeap.calloc, .{ .name = "calloc" });
        @export(ZigHeap.realloc, .{ .name = "realloc" });
        @export(ZigHeap.free, .{ .name = "free" });
    }
}
