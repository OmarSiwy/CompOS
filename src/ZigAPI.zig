// This File must include all the other .zig files in the project
// This is a library of its own used to support the C Library

pub const MAX_TASKS: usize = 16;
pub const TIME_SLICE = 10;

export fn Schedular_Max_Tasks() usize {
    return MAX_TASKS;
}

export fn Schedular_Time_Slice() usize {
    return TIME_SLICE;
}
