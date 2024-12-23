# 🚀 **CompOS**

**Zero-task allocation overhead and ultra-low context-switching scheduling for your projects.**

---

## **Table of Contents**

1. [Why Choose CompOS?](#why-choose-compos)
2. [About Zig](#about-zig)
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

CompOS introduces **zero-task allocation overhead** and **context-switching based scheduling**, delivering ultra-low task-switching overhead. Leveraging **Zig's powerful compile-time semantics** and seamless **compatibility with Clang**, CompOS integrates effortlessly into Zig-based and C/C++ projects.

---

## **About Zig**

### **Benefits**:
- **Compile-time power**: Zig enables highly optimized code using its compile-time evaluation and metaprogramming capabilities.
- **Safety features**: Built-in safety checks help eliminate common programming errors.
- **Performance**: Zig focuses on minimal overhead, making it ideal for real-time systems.

### **Limitations**:
- Zig's ecosystem is still growing, and some tools or libraries may not yet be available.
- Requires familiarity with Zig and its unique features for optimal use.

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
zig build test -Doptimize=ReleaseSafe -DCompile_Target=testing -DLibrary_Type=Static
```

### **Building IntelliSense**

Generate a compilation database for IntelliSense:

```bash
zig build cdb -Doptimize=ReleaseSafe -DCompile_Target=testing -DLibrary_Type=Static
```

### **Building for Your Project**

To build CompOS for your project:

```bash
zig build -Doptimize=ReleaseSafe -DCompile_Target=testing -DLibrary_Type=Static
```

---

## **Resources**

- **[Operating System: Three Easy Pieces](https://assets/book-cover-two.jpg)**

---
