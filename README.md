### Event-Driven RTOS

switches task only when an event of higher priority is ready (priority scheduling/preemptive priority)

a task has 3 states

- Running (runnign on cpy)
- Ready (ready to be executed)
- Blocked (waiting for an event)

these tasks are placed in a queue

[[Resource Starvation]]
Happens when a process is denied neccesary resources to process it work, usually occurs due to scheduling or mutual exlcusion algorithms, can cause **denial-of-service attack**
