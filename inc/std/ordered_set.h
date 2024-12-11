#ifndef COMPOS_ORDERED_SET_H_
#define COMPOS_ORDERED_SET_H_

/** @brief Structure for a node in the ordered set. */
typedef struct ordered_set_node {
  void *data;                    /**< Pointer to the data stored in the node. */
  struct ordered_set_node *next; /**< Pointer to the next node. */
} ordered_set_node;

/** @brief Structure for the ordered set. */
typedef struct ordered_set {
  int size;                   /**< Number of unique elements in the set. */
  ordered_set_node *head;     /**< Pointer to the head node of the set. */
  int (*cmp)(void *, void *); /**< Comparison function for ordering elements. */
} ordered_set;

/** @brief Creates a new ordered set.
 *  @param cmp Comparison function for sorting elements (returns -1, 0, or 1).
 *  @return A newly initialized ordered set.
 */
extern struct ordered_set ORDERED_SET_CREATE(int (*cmp)(void *, void *));

/** @brief Frees all memory associated with the ordered set.
 *  @param set Pointer to the ordered set to free.
 */
extern void ORDERED_SET_FREE(struct ordered_set *set);

/** @brief Clears all elements in the ordered set but retains allocated memory.
 *  @param set Pointer to the ordered set to clear.
 */
extern void ORDERED_SET_CLEAR(struct ordered_set *set);

/** @brief Inserts a new element into the ordered set.
 *  @param data Pointer to the data to insert.
 *  @param set Pointer to the ordered set.
 *
 *  Inserts the element only if it does not already exist in the set.
 */
extern void ORDERED_SET_INSERT(void *data, struct ordered_set *set);

/** @brief Removes an element from the ordered set.
 *  @param data Pointer to the data to remove.
 *  @param set Pointer to the ordered set.
 */
extern void ORDERED_SET_REMOVE(void *data, struct ordered_set *set);

/** @brief Checks if an element exists in the ordered set.
 *  @param data Pointer to the data to search for.
 *  @param set Pointer to the ordered set.
 *  @return 1 if the element exists, 0 otherwise.
 */
extern int ORDERED_SET_CONTAINS(void *data, struct ordered_set *set);

/** @brief Finds the smallest element in the ordered set.
 *  @param set Pointer to the ordered set.
 *  @return Pointer to the smallest element, or NULL if the set is empty.
 */
extern void *ORDERED_SET_MIN(struct ordered_set *set);

/** @brief Finds the largest element in the ordered set.
 *  @param set Pointer to the ordered set.
 *  @return Pointer to the largest element, or NULL if the set is empty.
 */
extern void *ORDERED_SET_MAX(struct ordered_set *set);

/** @brief Macro for iterating through all elements in the ordered set.
 *  @param set Pointer to the ordered set.
 *  @param node Variable used as the iterator.
 */
#define ORDERED_SET_FOREACH(set, node)                                         \
  for (ordered_set_node *node = (set)->head; node != NULL; node = node->next)

#endif // COMPOS_ORDERED_SET_H_
