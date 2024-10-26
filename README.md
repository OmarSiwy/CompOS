## 🚀 **A-RTOS-M**

### 🧐 **Why Choose A-RTOS-M?**

A-RTOS-M brings priority-based, preemptive scheduling to your project, providing ultra-low task-switching overhead. Thanks to Zig's powerful compile-time semantics, you get the efficiency of Zig with seamless C interoperability. Enjoy a lightweight, powerful RTOS solution with an edge in embedded systems.

#### 🌟 **About Zig**

**Benefits**:

- 🕒 **Compile-Time Semantics**: Powerful compile-time processing for optimized builds.
- ✅ **In-House Testing**: Write and run tests directly within Zig, ensuring robustness.
- 🔗 **C Interoperability**: Zero runtime overhead when calling Zig from C.
- 🔧 **Advanced Compiler Options**: More configuration flexibility than Clang with no added runtime overhead.

**Limitations**:

- 🛠️ **Clang Dependency**: Relies on Clang, which is sometimes suboptimal for embedded development.

---

### 📖 **How to Use A-RTOS-M**

#### ⚡ **Zig**

Add the following dependency to your `build.zig.zon` to integrate A-RTOS-M.

📄 **build.zig.zon**:

````zig
.dependencies = .{
    .A_RTOS_M = .{
        .url = "https://github.com/OmarSiwy/A-RTOS-M/archive/refs/tags/v0.0.6.tar.gz",
        .hash = "12206cc38df5a25da72f1214c8e1bc019f3dbd5c0fd358b229de40dcb5f97abc770c",
    },
},


📄 **build.zig:**

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

#### ⚙️  C/C++

**Conan**:

Not Currently Supported due to multiple variations in setup; additional workflows are being explored.

**Build from Source**:

```Bash
# Option #1:
# Ensure Zig V0.13 is installed
zig build -DCompile_Target=testing -DOptimization=ReleaseFast -DLibrary_Type=Static

mv ./zig-out/lib/libA-RTOS-M.a <ProjectDir>

# Option #2:
docker compose up run build-static
mv ./zig-out/lib/libA-RTOS-M.a <ProjectDir>
```
````
