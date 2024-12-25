const std = @import("std");
const c = @cImport(@cInclude("std/list.h"));
const expect = std.testing.expect;

test "List API - Initialization" {
    const lst = c.ListInit();
    try expect(lst != null);
    c.ListDestroy(lst);
}

test "List API - PushBack and Size" {
    const lst = c.ListInit();
    try expect(lst != null);

    var val1: u32 = 10;
    const data1: *anyopaque = @ptrCast(&val1);
    c.ListPushBack(lst, data1);
    try expect(c.ListSize(lst) == 1);

    var val2: u32 = 20;
    const data2: *anyopaque = @ptrCast(&val2);
    c.ListPushBack(lst, data2);
    try expect(c.ListSize(lst) == 2);

    c.ListDestroy(lst);
}

test "List API - PushFront" {
    const lst = c.ListInit();
    try expect(lst != null);

    var val1: u32 = 10;
    const data1: ?*anyopaque = @ptrCast(&val1);
    c.ListPushFront(lst, data1);
    try expect(c.ListSize(lst) == 1);

    var val2: u32 = 5;
    const data2: ?*anyopaque = @ptrCast(&val2);
    c.ListPushFront(lst, data2);
    try expect(c.ListSize(lst) == 2);

    const front_anyopaque = c.ListGetFront(lst);
    const front: ?*anyopaque = @ptrCast(front_anyopaque);
    try expect(front.* == val2);

    c.ListDestroy(lst);
}

test "List API - Access Operations" {
    const lst = c.ListInit();
    try expect(lst != null);

    var val1: u32 = 10;
    var val2: u32 = 20;
    var val3: u32 = 30;

    const data1: ?*anyopaque = @ptrCast(&val1);
    const data2: ?*anyopaque = @ptrCast(&val2);
    const data3: ?*anyopaque = @ptrCast(&val3);

    c.ListPushBack(lst, data1);
    c.ListPushBack(lst, data2);
    c.ListPushBack(lst, data3);

    const front_anyopaque = c.ListGetFront(lst);
    const front: ?*anyopaque = @ptrCast(front_anyopaque);
    const front_val: u32 = @ptrToInt(@ptrCast(*u32, @alignCast(@alignOf(*u32), front.?.*)));

    const back_anyopaque = c.ListGetBack(lst);
    const back: ?*anyopaque = @ptrCast(back_anyopaque);
    const back_val: u32 = @ptrToInt(@ptrCast(*u32, @alignCast(@alignOf(*u32), back.?.*)));

    const middle_anyopaque = c.ListAt(lst, 1);
    const middle: ?*anyopaque = @ptrCast(middle_anyopaque);
    const middle_val: u32 = @ptrToInt(@ptrCast(*u32, @alignCast(@alignOf(*u32), middle.?.*)));

    try expect(front_val == val1);
    try expect(back_val == val3);
    try expect(middle_val == val2);

    c.ListDestroy(lst);
}

test "List API - Empty and Destroy" {
    const lst = c.ListInit();
    try expect(c.ListEmpty(lst) != 0);

    var val: u32 = 42;
    const data: *anyopaque = @ptrCast(&val);
    c.ListPushBack(lst, data);
    try expect(c.ListEmpty(lst) == 0);

    c.ListDestroy(lst);
}
