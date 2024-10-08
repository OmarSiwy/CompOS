### Event-Driven RTOS (Currently in heavy development)

switches task only when an event of higher priority is ready (priority scheduling/preemptive priority)

a task has 3 states

- Running (runnign on cpy)
- Ready (ready to be executed)
- Blocked (waiting for an event)

these tasks are placed in a queue

[[Resource Starvation]]
Happens when a process is denied neccesary resources to process it work, usually occurs due to scheduling or mutual exlcusion algorithms, can cause **denial-of-service attack**

[[How to include it it into your program]]

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
