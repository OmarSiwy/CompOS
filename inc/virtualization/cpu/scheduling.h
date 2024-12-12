#ifndef COMPOS_SCHEDULING_H_
#define COMPOS_SCHEDULING_H_

#include "types.h"

/* ----------------------------------------------------------------------
 * Task State and Run Queue Definitions
 * ---------------------------------------------------------------------- */
typedef enum {
  TASK_READY,   /**< Task is ready to run */
  TASK_RUNNING, /**< Task is currently running */
  TASK_DONE     /**< Task has completed execution */
} task_state;

typedef void (*task_function_t)(void *context);

typedef struct {
  task_function_t func; /**< Pointer to the task function */
  void *context;        /**< Context or arguments passed to the task */
  task_state state;     /**< Current state of the task */
  size_t task_id;       /**< Task ID for reference */
} task_t;

/* Run Queue */
typedef struct {
  task_t *tasks;     /**< Pointer to the array of tasks */
  size_t task_count; /**< Number of active tasks */
  size_t max_tasks;  /**< Maximum number of tasks (from ZigAPI) */
} run_queue_t;

/* ----------------------------------------------------------------------
 * Scheduler API
 * ---------------------------------------------------------------------- */

/** @brief Initialize the scheduler */
extern void SCHEDULER_INIT(run_queue_t *queue);

/** @brief Register a new task */
extern int SCHEDULER_ADD_TASK(run_queue_t *queue, task_function_t func,
                              void *context);

/** @brief Run the scheduler */
extern void SCHEDULER_RUN(run_queue_t *queue);

/** @brief Yield control back to the scheduler */
extern void SCHEDULER_YIELD(void);

/** @brief Get the maximum number of tasks (from ZigAPI) */
extern size_t SCHEDULER_MAX_TASKS(void);

#endif // COMPOS_SCHEDULING_H_
