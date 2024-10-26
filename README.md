## A-RTOS-M

### Why A-RTOS-M?

This RTOS variation uses priority and premptive scheduling to give you the lowest overhead on task switching, utilizing compile-time semantics from Zig, while still providing usage through C and Zig if you want.

#### About Zig

**Benefits**:

- Compile Time semantics
- In-House Testing using Zig Test
- 0 runtime overhead interoperability with C
- Compiler has more options than typical Clang with 0 runtime overhead

**Limitations**:

- Limited to Clang which isn't perfectly optimal for Embedded Development

### To Use:

#### Zig

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

#### C/C++

**Conan**:

Not Currently Supported due to the many versions

**Build from Source**:

```Bash
# Option #1:
# Have Zig V0.13 Installed:
zig build -DCompile_Target=testing -DOptimization=ReleaseFast -DLibrary_Type=Static

mv ./zig-out/lib/libA-RTOS-M.a <ProjectDir>

# Option #2:
docker compose up run build-static
mv ./zig-out/lib/libA-RTOS-M.a <ProjectDir>
```

### Editing this Repo:

### Re-Uploading for Conan

```Bash
# Run tools/UploadConan.sh
```
