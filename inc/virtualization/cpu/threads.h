#ifndef COMPOS_THREADS_H_
#define COMPOS_THREADS_H_

// Threads are data structure that each have their own address space
// This address space shares:
// Heap
// But has a different stack
// It usually has a (TCB) Thread Control Block
//  - Virtual Address Space
//  - Registers and Program Counter
//  - Stack Pointer
//  - MetaData

typedef struct {
  void *stack_pointer;
  void *program_counter;
  void *registers;
  void *virtual_address_space;
  void *heap;
  void *metadata;
} TCB; // Thread Control Block

// Context Switching must be implemented to switch between threads

#endif // COMPOS_THREADS_H_
