#ifndef COMPOS_CONCURRENCY_H_
#define COMPOS_CONCURRENCY_H_

#include "types.h"

/* ========================= Mutex Implementation ========================= */
typedef struct {
  void *owner;   /**< Task or entity currently holding the mutex */
  size_t locked; /**< Lock state: 0 = unlocked, 1 = locked */
} mutex;

/** @brief Initialize a mutex */
extern void MUTEX_INIT(mutex *m);

/** @brief Attempt to lock the mutex (non-blocking)
 *  @return 1 if locked successfully, 0 if already locked.
 */
extern int MUTEX_LOCK(mutex *m);

/** @brief Unlock the mutex */
extern void MUTEX_UNLOCK(mutex *m);

/* ======================== Semaphore Implementation ======================== */
typedef struct {
  void *owner;       /**< Task or entity owning the semaphore */
  size_t curr_count; /**< Current semaphore count */
  size_t max_count;  /**< Maximum semaphore count */
} semaphore;

/** @brief Initialize a semaphore */
extern void SEMAPHORE_INIT(semaphore *s, size_t initial_count,
                           size_t max_count);

/** @brief Take (decrement) the semaphore
 *  @return 1 if successful, 0 if the semaphore is unavailable.
 */
extern int SEMAPHORE_TAKE(semaphore *s);

/** @brief Give (increment) the semaphore */
extern void SEMAPHORE_GIVE(semaphore *s);

/* ===================== Message Queue Implementation ====================== */
typedef struct {
  void *buffer;     /**< Pointer to pre-allocated queue memory */
  size_t item_size; /**< Size of each item in the queue */
  size_t capacity;  /**< Maximum number of items in the queue */
  size_t head;      /**< Index of the head item */
  size_t tail;      /**< Index of the tail item */
  size_t count;     /**< Current number of items */
} message_queue;

/** @brief Initialize a message queue */
extern void QUEUE_INIT(message_queue *q, void *buffer, size_t item_size,
                       size_t capacity);

/** @brief Enqueue an item into the queue
 *  @return 1 if successful, 0 if the queue is full.
 */
extern int QUEUE_ENQUEUE(message_queue *q, const void *item);

/** @brief Dequeue an item from the queue
 *  @return 1 if successful, 0 if the queue is empty.
 */
extern int QUEUE_DEQUEUE(message_queue *q, void *item);

/* ======================= Atomic Flags Implementation ===================== */
typedef struct {
  volatile size_t flag; /**< Atomic flag: 0 = clear, 1 = set */
} atomic_flag;

/** @brief Set the atomic flag */
extern void ATOMIC_FLAG_SET(atomic_flag *flag);

/** @brief Clear the atomic flag */
extern void ATOMIC_FLAG_CLEAR(atomic_flag *flag);

/** @brief Test and set the atomic flag atomically
 *  @return Previous value of the flag.
 */
extern int ATOMIC_FLAG_TEST_AND_SET(atomic_flag *flag);

#endif // COMPOS_CONCURRENCY_H_

/* ===================== Doxygen Usage Examples =========================== */

/**
 * @example mutex_example.c
 * @brief Example for using a Mutex.
 *
 * @code
 * #include "concurrency.h"
 *
 * mutex m;
 *
 * void critical_section() {
 *     if (MUTEX_LOCK(&m)) {
 *         // Perform critical section work
 *         // ...
 *
 *         MUTEX_UNLOCK(&m);
 *     }
 * }
 *
 * int main() {
 *     MUTEX_INIT(&m);
 *
 *     critical_section(); // Safely lock and unlock the mutex
 *
 *     return 0;
 * }
 * @endcode
 */

/**
 * @example semaphore_example.c
 * @brief Example for using a Semaphore.
 *
 * @code
 * #include "concurrency.h"
 *
 * semaphore s;
 *
 * void producer() {
 *     SEMAPHORE_GIVE(&s); // Increment semaphore count
 * }
 *
 * void consumer() {
 *     if (SEMAPHORE_TAKE(&s)) {
 *         // Perform consumer operation
 *     }
 * }
 *
 * int main() {
 *     SEMAPHORE_INIT(&s, 0, 5); // Initial count = 0, max count = 5
 *
 *     producer();
 *     consumer();
 *
 *     return 0;
 * }
 * @endcode
 */

/**
 * @example queue_example.c
 * @brief Example for using a Message Queue.
 *
 * @code
 * #include "concurrency.h"
 *
 * message_queue q;
 * char buffer[10][16]; // Buffer to hold 10 messages of size 16 bytes
 *
 * void producer() {
 *     const char *msg = "Hello";
 *     QUEUE_ENQUEUE(&q, msg);
 * }
 *
 * void consumer() {
 *     char received[16];
 *     if (QUEUE_DEQUEUE(&q, received)) {
 *         // Use received message
 *     }
 * }
 *
 * int main() {
 *     QUEUE_INIT(&q, buffer, 16, 10); // Item size = 16 bytes, capacity = 10
 *
 *     producer();
 *     consumer();
 *
 *     return 0;
 * }
 * @endcode
 */

/**
 * @example atomic_flag_example.c
 * @brief Example for using Atomic Flags.
 *
 * @code
 * #include "concurrency.h"
 *
 * atomic_flag flag;
 *
 * void task() {
 *     if (!ATOMIC_FLAG_TEST_AND_SET(&flag)) {
 *         // Perform work if flag was previously clear
 *
 *         ATOMIC_FLAG_CLEAR(&flag); // Clear the flag
 *     }
 * }
 *
 * int main() {
 *     ATOMIC_FLAG_CLEAR(&flag); // Initialize flag to clear
 *
 *     task();
 *
 *     return 0;
 * }
 * @endcode
 */

#endif // COMPOS_CONCURRENCY_H_
