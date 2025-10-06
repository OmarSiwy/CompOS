# 🚀 **CompOS**

**Zero-task allocation overhead and ultra-low context-switching scheduling for your projects.**

<p align="center">
  <img src="assets/architecture-diagram.svg" alt="CompOS Architecture Diagram" width="100%">
</p>

<span style="color:red;">**Currently Project is written in C and Zig, however it will be transitioned to fully Zig once functionality is implemented for better performance.**</span>

---

## **Table of Contents**

1. [Why Choose CompOS?](#why-choose-compos)
2. [About Zig and C++](#about-zig-and-c)
    - [Benefits](#benefits)
    - [Limitations](#limitations)
3. [How to Use CompOS](#how-to-use-compos)
    - [Using with Zig](#using-with-zig)
    - [Using with C/C++](#using-with-cc)
4. [Development](#development)
    - [Testing](#testing)
    - [Building IntelliSense](#building-intellisense)
    - [Building for Your Project](#building-for-your-project)
5. [Resources](#resources)

---

## **Why Choose CompOS?**

CompOS recognizes existing RTOS structures and mimics them at a lower-cost, more performant abstraction through utilizing the power of new compiler features that Zig and C++ offer. (**Benchmarks are not done yet but it would be 1.5x performance while being slightly better memory effiency**). This library can be used with any C ABI-compatible languages.

---

## **About Zig and C++**

### Traditional FreeRTOS Tasks Challenges:
1. Require **separate stacks** for each task, consuming significant memory.
2. Use **manual creation and management** via `xTaskCreate`, leading to verbose code.
3. Depend on **synchronization mechanisms** like semaphores or notifications, adding complexity.
4. Suffer **memory overhead** due to pre-allocated stacks, regardless of actual usage.
5. Introduce **context switching latency**, which impacts real-time responsiveness.

### Zig’s `async`/`await` Solution:
1. **State Machines Replace Stacks**: 
   - Zig coroutines store only the minimal state (variables and execution point), eliminating the need for per-task stacks.
2. **Explicit Control with `await`**:
   - Coroutines yield control explicitly at `await`, making them cooperative and reducing unnecessary context switches.
3. **Reduced Memory Usage**:
   - Tasks no longer require stacks, dramatically decreasing memory consumption.
4. **Simplified Task Model**:
   - Fewer APIs and boilerplate code compared to traditional task creation and management.

### C++ Consteval and Constexpr Benefits:
5. **Compile-Time Optimization with `comptime`**:
   - Know the exact number of coroutines at compile time, enabling aggressive memory and performance optimizations.
6. **Eliminate Heap Usage**:
   - With all tasks and resources defined at compile time, the system can operate entirely without a heap.

### Zig Benefit:
7. **Unit Testing**:
   - No need for google tests, instead use Zig's built in testing framework.

    Just Run:
    ```bash
    zig build -Dtest=true test --summary all
    ```
---

## **How to Use CompOS**

### **Using with Zig**

Add the following dependency to your `build.zig.zon` to integrate CompOS into your project:

📄 **build.zig.zon**:

```zig
.dependencies = .{
    .CompOS = .{
        .url = "https://github.com/OmarSiwy/CompOS/archive/refs/tags/v0.0.6.tar.gz",
        .hash = "12206cc38df5a25da72f1214c8e1bc019f3dbd5c0fd358b229de40dcb5f97abc770c",
    },
},
```

📄 **build.zig**:

```zig
const ARTOS = b.dependency("CompOS", .{
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
exe.linkLibrary(ARTOS.artifact("CompOS"));
```

### **Using with C/C++**

To build and use CompOS with C/C++:

```bash
zig build -Doptimize=ReleaseSafe -DCompile_Target=testing -DLibrary_Type=Static

# Use the generated library and source files with your makefile (see examples for details).
```

---

## **Development**

### **Testing**

Run tests with the following command:

```bash
zig build -Doptimize=ReleaseSafe -DCompile_Target=testing -DLibrary_Type=Static cdb # Generate Compile Commands file
zig build -Doptimize=ReleaseSafe -DCompile_Target=testing -DLibrary_Type=Static size # Find Library Size
```

### **Building for Your Project from Source**

To build CompOS for your project:

```bash
zig build -Doptimize=ReleaseSafe -DCompile_Target=testing -DLibrary_Type=Static cdb # Nested Compile Commands for your project <3
```

---

## **Resources**

- **[Operating System: Three Easy Pieces](https://assets/book-cover-two.jpg)**

---
