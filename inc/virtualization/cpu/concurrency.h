#ifndef COMPOS_CONCURRENCY_H_
#define COMPOS_CONCURRENCY_H_

#include "types.h"

typedef struct Mutex {
    int locked;
} Mutex;

typedef struct Semaphore {
    int count;
} Semaphore;

typedef struct MessageQueue {
    void* data;
    size_t size;
} MessageQueue;

#endif // COMPOS_CONCURRENCY_H_
