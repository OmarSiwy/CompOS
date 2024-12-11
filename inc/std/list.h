#ifndef COMPOS_LIST_H_
#define COMPOS_LIST_H_

/** @brief Structure for a singly linked list node. */
typedef struct list_node_S {
  void *data;               /**< Pointer to the data stored in the node. */
  struct list_node_S *next; /**< Pointer to the next node in the list. */
} list_node_S;

/** @brief Structure for a generic singly linked list. */
typedef struct list {
  int size;          /**< Number of elements in the list. */
  list_node_S *head; /**< Pointer to the head node. */
} list;

/** @brief Creates a new list.
 *  @param arr Initial array to populate the list (optional, NULL if empty).
 *  @return A newly initialized list.
 */
extern struct list LIST_CREATE(void *arr);

/** @brief Creates a copy of the given list.
 *  @param list Pointer to the list to be copied.
 *  @return A new list that is a copy of the input list.
 */
extern struct list LIST_COPY(struct list *list);

/** @brief Frees all memory associated with the list.
 *  @param list Pointer to the list to be freed.
 */
extern void LIST_FREE(struct list *list);

/** @brief Clears all elements in the list but retains the allocated memory.
 *  @param list Pointer to the list to be cleared.
 */
extern void LIST_CLEAR(struct list *list);

/** @brief Adds a single element to the end of the list.
 *  @param data Pointer to the data to be added.
 *  @param list Pointer to the target list.
 */
extern void LIST_ADD_ELEMENT(void *data, struct list *list);

/** @brief Appends an array of elements to the list.
 *  @param data Pointer to the array of elements.
 *  @param size Number of elements in the array.
 *  @param list Pointer to the target list.
 */
extern void LIST_APPEND_ARRAY(void *data, int size, struct list *list);

/** @brief Appends another list's data to the current list.
 *  @param data Pointer to the list whose elements will be appended.
 *  @param size Number of elements to append.
 *  @param list Pointer to the target list.
 */
extern void LIST_APPEND_LIST(struct list *data, int size, struct list *list);

/** @brief Appends data from a vector to the list.
 *  @param data Pointer to the vector containing elements.
 *  @param size Number of elements to append.
 *  @param list Pointer to the target list.
 */
extern void LIST_APPEND_VECTOR(struct vector *data, int size,
                               struct list *list);

/** @brief Removes the last element from the list.
 *  @param list Pointer to the list.
 */
extern void LIST_POP(struct list *list);

/** @brief Reverses the elements of the list.
 *  @param list Pointer to the list to be reversed.
 */
extern void LIST_REVERSE(struct list *list);

/** @brief Removes the first occurrence of a specific element from the list.
 *  @param data Pointer to the data to be removed.
 *  @param list Pointer to the target list.
 */
extern void LIST_REMOVE(void *data, struct list *list);

/** @brief Appends an element after a specific node in the list.
 *  @param data Pointer to the data to be added.
 *  @param list Pointer to the target list.
 */
extern void LIST_APPEND_AFTER(void *data, struct list *list);

/** @brief Appends an element before a specific node in the list.
 *  @param data Pointer to the data to be added.
 *  @param list Pointer to the target list.
 */
extern void LIST_APPEND_BEFORE(void *data, struct list *list);

/** @brief Finds the middle node of the list.
 *  @param list Pointer to the list.
 *  @return Pointer to the middle node.
 */
extern struct list *LIST_MIDDLE(struct list *list);

/** @brief Checks if the list contains a cycle.
 *  @param list Pointer to the list to check.
 *  @return 1 if a cycle is found, 0 otherwise.
 */
extern int LIST_HAS_CYCLE(struct list *list);

/** @brief Merges two sorted lists into one sorted list.
 *  @param list1 Pointer to the first sorted list.
 *  @param list2 Pointer to the second sorted list.
 *  @param cmp Comparison function for sorting (returns -1, 0, or 1).
 *  @return A new sorted list containing elements from both lists.
 */
extern struct list LIST_MERGE_SORTED(struct list *list1, struct list *list2,
                                     int (*cmp)(void *, void *));

/** @brief Counts the occurrences of a specific value in the list.
 *  @param list Pointer to the list to search.
 *  @param data Pointer to the value to count.
 *  @param cmp Comparison function to compare list elements with the value.
 *  @return The number of occurrences of the specified value.
 */
extern int LIST_COUNT_OCCURRENCES(struct list *list, void *data,
                                  int (*cmp)(void *, void *));

/** @brief Removes duplicate elements from the list.
 *  @param list Pointer to the list to remove duplicates from.
 *  @param cmp Comparison function to determine equality between elements.
 */
extern void LIST_REMOVE_DUPLICATES(struct list *list,
                                   int (*cmp)(void *, void *));

/** @brief Macro for iterating through all nodes in the list.
 *  @param list Pointer to the list.
 *  @param node Variable used as the iterator.
 */
#define LIST_FOREACH(list, node)                                               \
  for (list_node_S *node = (list)->head; node != NULL; node = node->next)

/** @brief Converts a vector to a list.
 *  @param list Pointer to the vector to be converted.
 *  @return A list containing the vector's elements.
 */
extern struct list VECTOR_TO_LIST(struct list *list);

/** @brief Converts a list to a vector.
 *  @param list Pointer to the list to be converted.
 *  @return A vector containing the list's elements.
 */
extern struct list LIST_TO_VECTOR(struct list *list);

#endif // COMPOS_LIST_H_
