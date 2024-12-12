#include "virutalization/cpu/concurrency.h"

/* ========================= Mutex Implementation ========================= */
void MUTEX_INIT(mutex *m) {
  m->owner = (void *)0; // No owner
  m->locked = 0;        // Set to unlocked
}

int MUTEX_LOCK(mutex *m) {
  if (m->locked == 0) {   // Check if unlocked
    m->locked = 1;        // Lock it
    m->owner = (void *)1; // Assign dummy owner (you can expand this)
    return 1;             // Success
  }
  return 0; // Already locked
}

void MUTEX_UNLOCK(mutex *m) {
  m->locked = 0;        // Set to unlocked
  m->owner = (void *)0; // Clear owner
}

/* ======================== Semaphore Implementation ======================== */
void SEMAPHORE_INIT(semaphore *s, size_t initial_count, size_t max_count) {
  s->curr_count = initial_count; // Set initial count
  s->max_count = max_count;      // Set max count
  s->owner = (void *)0;          // No owner
}

int SEMAPHORE_TAKE(semaphore *s) {
  if (s->curr_count > 0) { // If available
    s->curr_count--;       // Decrement the count
    return 1;              // Success
  }
  return 0; // Unavailable
}

void SEMAPHORE_GIVE(semaphore *s) {
  if (s->curr_count < s->max_count) { // If below max count
    s->curr_count++;                  // Increment the count
  }
}

/* ===================== Message Queue Implementation ====================== */
void QUEUE_INIT(message_queue *q, void *buffer, size_t item_size,
                size_t capacity) {
  q->buffer = buffer;
  q->item_size = item_size;
  q->capacity = capacity;
  q->head = 0;
  q->tail = 0;
  q->count = 0;
}

int QUEUE_ENQUEUE(message_queue *q, const void *item) {
  if (q->count == q->capacity) {
    return 0; // Queue full
  }
  // Copy item into queue
  size_t offset = (q->tail * q->item_size);
  char *dest = (char *)q->buffer + offset;
  const char *src = (const char *)item;

  for (size_t i = 0; i < q->item_size; i++) {
    dest[i] = src[i]; // Copy item byte-by-byte
  }

  q->tail = (q->tail + 1) % q->capacity; // Circular buffer
  q->count++;
  return 1; // Success
}

int QUEUE_DEQUEUE(message_queue *q, void *item) {
  if (q->count == 0) {
    return 0; // Queue empty
  }
  // Copy item out of queue
  size_t offset = (q->head * q->item_size);
  char *src = (char *)q->buffer + offset;
  char *dest = (char *)item;

  for (size_t i = 0; i < q->item_size; i++) {
    dest[i] = src[i]; // Copy item byte-by-byte
  }

  q->head = (q->head + 1) % q->capacity; // Circular buffer
  q->count--;
  return 1; // Success
}

/* ======================= Atomic Flags Implementation ===================== */
void ATOMIC_FLAG_SET(atomic_flag *flag) {
  flag->flag = 1; // Set the flag
}

void ATOMIC_FLAG_CLEAR(atomic_flag *flag) {
  flag->flag = 0; // Clear the flag
}

int ATOMIC_FLAG_TEST_AND_SET(atomic_flag *flag) {
  int previous = flag->flag; // Store current value
  flag->flag = 1;            // Set the flag
  return previous;           // Return previous value
}
