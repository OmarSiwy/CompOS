### Event-Driven RTOS (Currently in heavy development)

### Learning:

- [ ] Task Scheduling (Task Switching and Scheduling Algorithms)
- [ ] Memory Management (Stacks and Heaps, dynamic memory allocation)
- [ ] Interrupt Handling (Interrupt Service Routines)
- [ ] Synchronization Primitives (Mutexes, Semaphores, and Event Flags)

### Zig

1. Get the Hash Needed:

```bash
curl -L https://github.com/OmarSiwy/A-RTOS-M/archive/refs/tags/0.1.0.tar.gz | sha256sum
```

```Zig
{
    .dependencies = .{
        .a_rtos_m = .{
            .url = "https://github.com/OmarSiwy/A-RTOS-M/archive/refs/tags/v0.0.2.tar.gz",
            .hash = "12206cc38df5a25da72f1214c8e1bc019f3dbd5c0fd358b229de40dcb5f97abc770c",
        }
    },
}

```
