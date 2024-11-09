#ifndef COMPOS_ATOMIC_H
#define COMPOS_ATOMIC_H

#define ATOMIC_ENTER_CRITICAL()                                                \
  do {                                                                         \
    __asm__ volatile("cpsid i");                                               \
  } while (0)

#define ATOMIC_EXIT_CRITICAL()                                                 \
  do {                                                                         \
    __asm__ volatile("cpsie i");                                               \
  } while (0)

#endif
