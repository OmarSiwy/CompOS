### Event-Driven RTOS (Currently in heavy development)

### Learning:

- [ ] Task Scheduling (Task Switching and Scheduling Algorithms)
- [ ] Memory Management (Stacks and Heaps, dynamic memory allocation)
- [ ] Interrupt Handling (Interrupt Service Routines)
- [ ] Synchronization Primitives (Mutexes, Semaphores, and Event Flags)

### Zig

**Place the following inside you build.zig.zon:**

**build.zig.zon**:

```Zig
.dependencies = .{
    .A_RTOS_M = .{
        .url = "https://github.com/OmarSiwy/A-RTOS-M/archive/refs/tags/v0.0.6.tar.gz",
        .hash = "12206cc38df5a25da72f1214c8e1bc019f3dbd5c0fd358b229de40dcb5f97abc770c",
    },
},

```

**build.zig:**

```Zig
const ARTOS = b.dependency("A_RTOS_M", .{
    .Compile_Target = "<MCU_NAME>",
    .Optimization = "ReleaseSafe or Debug or ReleaseSmall or ...",
    .Library_Type = "Static or Shared",
});

// Your project setup:
const exe = b.addExecutable(.{
    .name = "project",
    .target = target,
    .optimize = optimize,
    .root_source_file = .{ .cwd_relative = "src/main.zig" },
    .linkerscript = output_path,
});
exe.linkLibrary(ARTOS.artifact("A_RTOS_M"));
```

### C/C++

```Bash
# Build from source:

```
